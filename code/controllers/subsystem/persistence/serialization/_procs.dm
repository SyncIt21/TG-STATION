/atom
/**
 * List of variables to include when it is serialized.
 *
 * Always use NAMEOF(src, varname) for the keys to ensure compile-time checking.
 * Do NOT return variable values or custom data in this proc.
 *
 * Returns: Array list of variable names to be serialized
 */
/atom/proc/get_save_vars(save_flags=ALL)
	. = list()
	. += NAMEOF(src, color)
	. += NAMEOF(src, dir)
	. += NAMEOF(src, pixel_x)
	. += NAMEOF(src, pixel_y)
	. += NAMEOF(src, density)
	. += NAMEOF(src, opacity)

	if(uses_integrity)
		. += NAMEOF(src, resistance_flags)

	GLOB.map_export_save_vars_cache[type] = .

/atom/movable/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, anchored)

/**
 * Overrides the variables of an object with a custom value when it is serialized.
 *
 * Always use NAMEOF(src, varname) for the keys to ensure compile-time checking.
 * Examples:
 * - Saving a object reference as a savable id_tag
 * - Saving a calculated value
 *
 * Returns: Assoicated list of variables with custom values to be serialized
 */
/atom/proc/get_custom_save_vars(save_flags=ALL)
	SHOULD_CALL_PARENT(TRUE)

	. = list()
	if(uses_integrity && (atom_integrity != max_integrity))
		.[NAMEOF(src, atom_integrity)] = atom_integrity

	if(!QDELETED(reagents) && reagents.total_volume)
		var/list/reagent_list = list(
			"max_volume" = reagents.maximum_volume,
			"flags" =  reagents.flags,
			"temp" = reagents.chem_temp
		)
		for(var/datum/reagent/reg as anything in reagents.reagent_list)
			reagent_list[reg.type] = "[reg.volume]/[reg.ph]/[reg.purity]"
		.["reagents"] = reagent_list

	if(HAS_TRAIT(src, TRAIT_UNDERTILE) && !HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		.["reveal"] = TRUE

/**
 * Similar to [LateInitialize], executes code necessary for atoms loaded from persistence that require extra setup.
 *
 * This procedure is called only when an atom is created via mapload and when CONFIG_GET(flag/persistent_save_enabled) is enabled.
 * It runs immediately after all saved variables have been restored, after both [Initialize] and [LateInitialize],
 * but before general post-initialization signals are sent.
 *
 * It is the ideal place to run code that restores the previous state of atoms, such as:
 * - Calling update_appearance() to correct the visual state based on restored variables.
 * - Reinserting contents into storage atoms (e.g., lockers, bags) after they were temporarily moved out during the persistence save process.
 *
 * Atoms created at runtime (non-mapload) will skip this call.
 */
/atom/proc/PersistentInitialize(list/attributes)
	set waitfor = FALSE
	SHOULD_CALL_PARENT(TRUE)

	for(var/attribute, resolved_value in attributes)
		if(attribute == NAMEOF(src, atom_integrity))
			update_integrity(resolved_value)

		else if(attribute == "reagents")
			var/list/reagent_list = resolved_value

			create_reagents(text2num(popkey(reagent_list, "max_volume")), text2num(popkey(reagent_list, "flags")))
			var/temp = text2num(popkey(reagent_list, "temp"))
			for(var/reg_path in reagent_list)
				var/list/reg_data = splittext(reagent_list[reg_path], "/")
				reagents.add_reagent(
					reg_path,
					text2num(reg_data[1]),
					reagtemp = temp,
					added_purity = text2num(reg_data[2]),
					added_ph = text2num(reg_data[3])
				)

		else if(attribute == "reveal")
			SEND_SIGNAL(src, COMSIG_OBJ_HIDE, UNDERFLOOR_INTERACTABLE)

		else
			vars[attribute] = resolved_value

/atom/movable/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "contents")
			for(var/obj/item in contents)
				qdel(item)

			for(var/obj/item in resolved_value)
				if(atom_storage)
					atom_storage.attempt_insert(item, override = TRUE, messages = FALSE, force = STORAGE_FULLY_LOCKED)
				else
					item.forceMove(src)

			attributes -= attribute
			continue

		var/atom/data = resolved_value
		if(isatom(data))
			var/value = vars[attribute]
			if(isatom(value)) //it may contain an default value which we want to delete
				qdel(value)
			vars[attribute] = data
			if(ismovable(data))
				var/atom/movable/move = data
				move.forceMove(src)
			attributes -= attribute

	..()

/**
 * Check if an atom is savable for serilization during map export.
 *
 * For atoms that will always be blacklisted do NOT use this proc. Use the blacklist in map_writer.dm
 * Examples:
 * - [/obj/machinery/atmospherics/components/unary] spawns beneath cryo tubes that causes duplication
 * - [/obj/machinery/power/terminal] spawns beneath APC's that causes duplication
 * - [/obj/structure/transport/linear/tram] needs to skip multi-tile object checks
 *
 * Returns: Boolean
 */
/atom/proc/is_saveable(turf/current_loc, list/obj_blacklist)
	if(obj_blacklist[type])
		return FALSE
	if(flags_1 & HOLOGRAM_1)
		return FALSE

	return TRUE

/atom/movable/is_saveable(turf/current_loc, list/obj_blacklist)
	if(is_multi_tile_object(src) && (src.loc != current_loc))
		return FALSE

	return ..()

/obj/item/is_saveable(turf/current_loc, list/obj_blacklist)
	if(item_flags & ABSTRACT)
		return FALSE

	return ..()

///Returns The typepath for map export serialization.
/atom/proc/substitute_with_typepath()
	return type
