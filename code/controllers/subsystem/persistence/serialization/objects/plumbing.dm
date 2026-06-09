/obj/machinery/plumbing/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "reagents")
			var/type = reagents.type

			qdel(reagents)

			reagents = type

			break

	return ..()

/obj/machinery/plumbing/acclimator/get_save_vars()
	. = ..()
	. += NAMEOF(src, target_temperature)
	. += NAMEOF(src, acclimate_state)

/obj/machinery/plumbing/bottler/get_save_vars()
	. = ..()
	. += NAMEOF(src, wanted_amount)

/obj/machinery/plumbing/disposer/get_save_vars()
	. = ..()
	. += NAMEOF(src, disposal_rate)

/obj/machinery/plumbing/fermenter/get_save_vars()
	. = ..()
	. += NAMEOF(src, eat_dir)

/obj/machinery/plumbing/filter/get_custom_save_vars(save_flags)
	. = ..()
	if(left.len)
		. += NAMEOF(src, left)
	if(right.len)
		. += NAMEOF(src, right)

/obj/machinery/plumbing/grinder_chemical/get_save_vars()
	. = ..()
	. += NAMEOF(src, grinding)

/obj/machinery/plumbing/buffer/PersistentInitialize(list/attributes)
	if(anchored && !length(connections))
		screwdriver_act()

	return ..()

/obj/machinery/plumbing/pill_press/get_save_vars()
	. = ..()
	. += NAMEOF(src, product_name)
	. += NAMEOF(src, pill_duration)

/obj/machinery/plumbing/pill_press/get_custom_save_vars(save_flags)
	. = ..()
	.["product_type"] = packaging_type

/obj/machinery/plumbing/pill_press/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "product_type")
			packaging_type = resolved_value

			max_volume = initial(packaging_type.volume)
			current_volume = clamp(current_volume, 5, max_volume)

			if(ispath(packaging_type, /obj/item/reagent_containers/applicator/patch))
				packaging_category = CAT_PATCHES
			else if(ispath(packaging_type, /obj/item/reagent_containers/applicator/pill))
				packaging_category = CAT_PILLS
			else
				packaging_category = "Bottles"

			attributes -= attribute


	return ..()

/obj/machinery/plumbing/buffer/get_save_vars()
	. = ..()
	. += NAMEOF(src, activation_volume)
	. += NAMEOF(src, mode)

/obj/machinery/plumbing/reaction_chamber/get_save_vars()
	. = ..()
	. += NAMEOF(src, required_reagents)
	. += NAMEOF(src, catalysts)
	. += NAMEOF(src, emptying)
	. += NAMEOF(src, target_temperature)

/obj/machinery/plumbing/reaction_chamber/PersistentInitialize(list/attributes)
	. = ..()
	if(emptying)
		RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagent_change))

/obj/machinery/plumbing/reaction_chamber/chem/get_save_vars()
	. = ..()
	. += NAMEOF(src, acidic_limit)
	. += NAMEOF(src, alkaline_limit)

/obj/machinery/plumbing/splitter/get_save_vars()
	. = ..()
	. += NAMEOF(src, transfer_straight)
	. += NAMEOF(src, transfer_left)
	. += NAMEOF(src, transfer_right)

/obj/machinery/plumbing/synthesizer/get_save_vars()
	. = ..()
	. += NAMEOF(src, reagent_id)

/obj/machinery/plumbing/sender/get_custom_save_vars(save_flags)
	. = ..()

	if(!QDELETED(target))
		var/turf/target_turf = get_turf(target)
		.["target_coords"] = list(target_turf.x, target_turf.y, target_turf.z)

/obj/machinery/plumbing/sender/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "target_coords")
			target = locate() in TURF_FROM_COORDS_LIST(resolved_value)

			attribute -= attribute

			break

	return ..()
