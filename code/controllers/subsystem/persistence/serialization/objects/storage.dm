/obj/item/storage/briefcase/secure/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stored_lock_code)

/obj/item/wallframe/secure_safe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stored_lock_code)

/obj/structure/secure_safe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stored_lock_code)

/obj/structure/safe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, open)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, tumblers)
	. += NAMEOF(src, explosion_count)

/obj/structure/safe/get_custom_save_vars(save_flags=ALL)
	. = ..()
	// we don't need to set new tumblers otherwise the tumblers list grows out of control
	.[NAMEOF(src, number_of_tumblers)] = 0

/obj/structure/safe/PersistentInitialize(list/attributes)
	. = ..()
	update_appearance()

/obj/item/clipboard/PersistentInitialize(list/attributes)
	. = ..()

	for(var/clipboard_obj in contents)
		if(istype(clipboard_obj, /obj/item/pen))
			pen = clipboard_obj
		if(istype(clipboard_obj, /obj/item/paper))
			continue // paper is by default inside contents
	update_appearance()

/obj/structure/mop_bucket/janitorialcart/PersistentInitialize(list/attributes)
	. = ..()

	for(var/jani_obj in contents)
		if(istype(jani_obj, /obj/item/storage/bag/trash))
			mybag = jani_obj
		else if(istype(jani_obj, /obj/item/mop))
			mymop = jani_obj
		else if(istype(jani_obj, /obj/item/pushbroom))
			mybroom = jani_obj
		else if(istype(jani_obj, /obj/item/reagent_containers/spray/cleaner))
			myspray = jani_obj
		else if(istype(jani_obj, /obj/item/lightreplacer))
			myreplacer = jani_obj
		else if(istype(jani_obj, /obj/item/clothing/suit/caution))
			// held_signs is a list so slightly different
			held_signs += jani_obj

	update_appearance()


/obj/item/mod/module/storage/PersistentInitialize(list/attributes)
	atom_storage.set_locked(STORAGE_NOT_LOCKED)

	. = ..()

	atom_storage.set_locked(STORAGE_FULLY_LOCKED)
