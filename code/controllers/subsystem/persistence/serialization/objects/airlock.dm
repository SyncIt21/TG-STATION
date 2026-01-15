/obj/machinery/door/get_save_vars(save_flags=ALL)
	. = ..()
	. -= NAMEOF(src, density)
	. -= NAMEOF(src, opacity)
	return .

/obj/machinery/door/get_custom_save_vars(save_flags)
	. = ..()
	. -= NAMEOF(src, contents)

/obj/machinery/door/airlock/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, autoname)
	. += NAMEOF(src, emergency)

	if(!autoname)
		. += NAMEOF(src, name)

	. -= NAMEOF(src, density)
	. -= NAMEOF(src, opacity)

	if(QDELETED(electronics))
		. += NAMEOF(src, closeOtherId)
		if(length(req_one_access))
			. += NAMEOF(src, req_one_access)
		else if(length(req_access))
			. += NAMEOF(src, req_access)

/obj/machinery/door/airlock/get_custom_save_vars(save_flags)
	. = ..()

	if(!QDELETED(electronics))
		electronics.passed_cycle_id = closeOtherId
		if(length(req_one_access))
			electronics.one_access = 1
			electronics.accesses = req_one_access
		else if(length(req_access))
			electronics.accesses = req_access
		.[NAMEOF(src, electronics)] = electronics

/obj/machinery/door/airlock/PersistentInitialize(list/attributes)
	. = ..()
	for(var/attribute, resolved_value in attributes)
		if(attribute == "electronics")
			var/obj/item/electronics/airlock/saved = resolved_value
			closeOtherId = saved.passed_cycle_id
			if(saved.one_access)
				req_one_access = saved.accesses
			else if(length(saved.req_access))
				req_access = saved.accesses

			return

/obj/machinery/door/poddoor/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/machinery/door/window/get_save_vars(save_flags)
	. = ..()
	. -= NAMEOF(src, contents)

	if(QDELETED(electronics))
		if(length(req_one_access))
			. += NAMEOF(src, req_one_access)
		else if(length(req_access))
			. += NAMEOF(src, req_access)

/obj/machinery/door/window/get_custom_save_vars(save_flags)
	. = ..()

	if(!QDELETED(electronics))
		.[NAMEOF(src, electronics)] = electronics
