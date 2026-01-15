/obj/structure/extinguisher_cabinet/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, opened)

/obj/structure/extinguisher_cabinet/PersistentInitialize(list/attributes)
	. = ..()
	if(opened)
		update_appearance()

/obj/structure/plaque/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, name)
	. += NAMEOF(src, desc)
	. += NAMEOF(src, engraved)

/obj/structure/closet/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, name)
	// we need these to keep track of paint jobs via airlock painters
	. += NAMEOF(src, icon_state)
	. += NAMEOF(src, base_icon_state)
	. += NAMEOF(src, icon_door)

	. += NAMEOF(src, welded)
	. += NAMEOF(src, opened)
	. += NAMEOF(src, locked)

/obj/structure/closet/get_custom_save_vars(save_flags)
	//basically if this closet has never been opened then don't save its contents cause it will spawn its own stuff
	if(!opened && contents_initialized)
		.[NAMEOF(src, contents_initialized)] = contents_initialized

/obj/structure/closet/PersistentInitialize(list/attributes)
	//the maploader flattens reccursive contents out on the turf(e.g. like a backpack having stuff but its inside the closet)
	//but closets on init takes everything on the turf even stuff that does not belong to it
	//so we move out stuff that isnt ours
	. = ..()
	for(var/attribute, resolved_value in attributes)
		if(attribute == "contents")
			var/atom/drop = drop_location()
			for(var/obj/thing in contents)
				if(!(thing in resolved_value))
					thing.forceMove(drop)

			return

/obj/structure/frame/machine/PersistentInitialize(list/attributes)
	. = ..()
	for(var/obj/item/part as anything in contents)
		if(istype(part, /obj/item/circuitboard/machine))
			var/list/added_components = req_components.Copy()
			circuit = part
			circuit_added(part)
			req_components = added_components
		else
			LAZYADD(part, components)

/obj/structure/frame/computer/PersistentInitialize(list/attributes)
	. = ..()
	for(var/attribute, resolved_value in attributes)
		if(attribute == "board")
			circuit = resolved_value
			circuit.forceMove(src)
			circuit_added(resolved_value)
			break
