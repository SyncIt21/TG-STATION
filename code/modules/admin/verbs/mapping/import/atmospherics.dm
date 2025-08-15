/obj/machinery/portable_atmospherics/restore_saved_value(attribute, resolved_value)
	if(attribute == "anchored")
		var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
		if(!QDELETED(possible_port))
			addtimer(CALLBACK(src, PROC_REF(connect), possible_port), 1 SECONDS)

		return

	..()

/obj/machinery/atmospherics/restore_saved_value(attribute, resolved_value)
	if(attribute == "on")
		on = FALSE

		set_on(TRUE)

		return

	..()

/obj/machinery/atmospherics/pipe/restore_saved_value(attribute, resolved_value)
	if(attribute == "air")
		var/datum/gas_mixture/air_mixture = SSair.parse_gas_string(resolved_value)
		if(parent)
			parent.set_air(air_mixture)
		else
			air_temporary = air_mixture
		return

	..()

/obj/machinery/atmospherics/components/restore_saved_value(attribute, resolved_value)
	if(attribute == "airs")
		for(var/gas in resolved_value)
			var/list/gas_data = splittext(gas, "/")
			airs[text2num(gas_data[2])].merge(SSair.parse_gas_string(replacetext(gas_data[1], "%", "=")))

		return

	..()

/obj/machinery/atmospherics/components/binary/crystallizer/restore_saved_value(attribute, resolved_value)
	if(attribute == "internal")
		internal.merge(SSair.parse_gas_string(replacetext(resolved_value, "%", "=")))

		return

	if(attribute == "recipe")
		selected_recipe = GLOB.gas_recipe_meta[resolved_value]
		update_parents() //prevent the machine from stopping because of the recipe change and the pipenet not updating
		moles_calculations()

		return

	..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/restore_saved_value(attribute, resolved_value)
	if(attribute == "filters")
		filter_types.Cut()
		for(var/gas_type in resolved_value)
			filter_types += gas_type
		atmos_conditions_changed()

		return

	..()
