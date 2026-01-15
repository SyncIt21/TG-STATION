/turf/open/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, broken)
	. += NAMEOF(src, burnt)

// Save atmos data
/turf/open/get_custom_save_vars(save_flags=ALL)
	. = ..()

	if(!(save_flags & SAVE_TURFS_ATMOS))
		return .

	// is_safe_turf checks if the temperature, gas mix, pressure is in the goldilock safe zones
	// if it is safe, we skip saving atmos and use the default to help compress our map save size
	if(!is_safe_turf(src, dense_atoms=TRUE)) // compare optimization times in tracy with this check enabled vs without
		var/datum/gas_mixture/turf_gasmix = return_air()
		.[NAMEOF(src, initial_gas_mix)] = turf_gasmix.to_string()

	// save a list of all atoms that should be shown open the turf
	var/list/atoms_above = list()
	for(var/atom/movable/thing in contents)
		///We don't deal with atoms that don't go under a tile
		if(!HAS_TRAIT(thing, TRAIT_UNDERTILE))
			continue
		///If we have atoms that are meant to be on top of the tile
		if(!HAS_TRAIT(thing, TRAIT_UNDERFLOOR))
			atoms_above += thing.name
	if(atoms_above.len)
		.["atoms_above"] = atoms_above

/turf/open/PersistentInitialize(list/attributes)
	. = ..()

	for(var/attribute, resolved_value in attributes)
		if(attribute == "atoms_above")
			for(var/atom/movable/thing in contents)
				///We don't deal with atoms that don't go under a tile
				if(!HAS_TRAIT(thing, TRAIT_UNDERTILE))
					continue
				///Send the signal to display everything on top
				if(thing.name in resolved_value)
					SEND_SIGNAL(thing, COMSIG_OBJ_HIDE, UNDERFLOOR_INTERACTABLE)
			break

	if(broken || burnt)
		update_appearance()

/turf/open/floor/light/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, on)
	. += NAMEOF(src, state)
	. += NAMEOF(src, currentcolor)

/turf/open/floor/light/PersistentInitialize(list/attributes)
	. = ..()
	update_appearance()
