/obj/machinery/light/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, on)
	. += NAMEOF(src, status)

/obj/machinery/light/get_custom_save_vars(save_flags)
	. = ..()
	. -= NAMEOF(src, contents)

	if(!QDELETED(cell))
		.[NAMEOF(src, has_mock_cell)] = FALSE
		.[NAMEOF(src, start_with_cell)] = FALSE
		.[NAMEOF(src, cell)] = cell

/obj/machinery/light/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "on")
			set_on(resolved_value)

			attributes -= attribute

			break

	return ..()

/obj/structure/light_construct/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stage)
	. += NAMEOF(src, fixture_type)

/obj/item/flashlight/get_custom_save_vars(save_flags=ALL)
	. = ..()
	if(light_on)
		.[NAMEOF(src, start_on)] = light_on

/obj/item/flashlight/flare/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, fuel)
