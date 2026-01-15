/obj/machinery/defibrillator_mount/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, clamps_locked)

/obj/machinery/defibrillator_mount/PersistentInitialize(list/attributes)
	. = ..()
	var/obj/item/defibrillator/defib_unit = locate(/obj/item/defibrillator) in contents
	defib = defib_unit

	if(is_operational && defib)
		begin_processing()

	update_appearance()

/obj/item/surgery_tray/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, is_portable)

/obj/item/surgery_tray/get_custom_save_vars(save_flags=ALL)
	. = ..()
	.[NAMEOF(src, starting_items)] = list() //prevents duping

/obj/machinery/scanner_gate/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, locked)
	. += NAMEOF(src, scangate_mode)
	. += NAMEOF(src, disease_threshold)
	. += NAMEOF(src, detect_species_id)
	. += NAMEOF(src, detect_nutrition)
	. += NAMEOF(src, reverse)
