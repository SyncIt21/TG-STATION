/obj/machinery/portable_atmospherics/get_save_vars()
	. = ..()
	. -= NAMEOF(src, anchored)
	if(anchored)
		. += list(list("anchored" = anchored))

	var/datum/gas_mixture/gasmix = return_air()
	if(gasmix)
		initial_gas_mix = gasmix.to_string()
		. += NAMEOF(src, initial_gas_mix)

/obj/machinery/portable_atmospherics/canister/get_save_vars()
	. = ..()
	. += NAMEOF(src, valve_open)
	. += NAMEOF(src, release_pressure)
	. -= NAMEOF(src, contents)

/obj/machinery/atmospherics/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	. += NAMEOF(src, initialize_directions)
	. -= NAMEOF(src, contents)
	if(on)
		. += list(list("on" = on))

/obj/machinery/atmospherics/pipe/get_save_vars()
	. = ..()

	//save the pipeline just once
	if(parent)
		if(!saved_pipelines[parent])
			. += list(list("air" = parent.air.to_string()))
			saved_pipelines[parent] = TRUE
		return

	//save temporary air in the absence of a pipeline
	if(air_temporary)
		. += list(list("air" = air_temporary.to_string()))

/obj/machinery/atmospherics/components/get_save_vars()
	. = ..()
	if(!override_naming)
		// Prevents saving the dynamic name with \proper due to it converting to "???"
		. -= NAMEOF(src, name)
	. += NAMEOF(src, welded)

	var/list/datum/gas_mixture/stored_airs = list("airs" = list())
	for(var/i in 1 to device_type)
		var/datum/gas_mixture/stored_air = airs[i]
		if(stored_air.total_moles() > MINIMUM_MOLE_COUNT)
			//because list values are parsed at the = sign so we replace it
			stored_airs["airs"] += replacetext(stored_air.to_string(), "=", "%") + "/[i]"

	if(length(stored_airs["airs"]))
		. += list(stored_airs)

/obj/machinery/atmospherics/components/unary/thermomachine/get_save_vars()
	. = ..()
	. += NAMEOF(src, target_temperature)

/obj/machinery/atmospherics/components/binary/crystallizer/get_save_vars()
	. = ..()
	. += list(list("internal" = replacetext(internal.to_string(), "=", "%")))
	if(selected_recipe)
		. += list(list("recipe" = selected_recipe.id))
	. += NAMEOF(src, gas_input)

/obj/machinery/atmospherics/components/binary/pump/get_save_vars()
	. = ..()
	. += NAMEOF(src, target_pressure)

/obj/machinery/atmospherics/components/unary/outlet_injector/get_save_vars()
	. = ..()
	. += NAMEOF(src, id_tag)
	. += NAMEOF(src, volume_rate)

/obj/machinery/atmospherics/components/unary/vent_pump/get_save_vars()
	. = ..()
	. += NAMEOF(src, id_tag)
	. += NAMEOF(src, pump_direction)
	. += NAMEOF(src, pressure_checks)
	. += NAMEOF(src, external_pressure_bound)
	. += NAMEOF(src, internal_pressure_bound)
	. += NAMEOF(src, fan_overclocked)

/obj/machinery/computer/atmos_control/get_save_vars()
	. = ..()
	. += NAMEOF(src, atmos_chambers)
	. += NAMEOF(src, was_multi_tooled)
	if(was_multi_tooled)
		. += NAMEOF(src, connected_sensors)

/obj/machinery/air_sensor/get_save_vars()
	. = ..()
	. += NAMEOF(src, id_tag)
	. += NAMEOF(src, chamber_id)

	var/obj/machinery/atmospherics/components/unary/outlet_injector/inlet = GLOB.objects_by_id_tag[inlet_id || ""]
	if(istype(inlet) && !QDELETED(inlet))
		. += NAMEOF(src, inlet_id)

	var/obj/machinery/atmospherics/components/unary/vent_pump/outlet = GLOB.objects_by_id_tag[outlet_id || ""]
	if(istype(outlet) && !QDELETED(outlet))
		. += NAMEOF(src, outlet_id)

/obj/machinery/atmospherics/components/binary/passive_gate/get_save_vars()
	. = ..()
	. += NAMEOF(src, target_pressure)

/obj/machinery/atmospherics/components/binary/pressure_valve/get_save_vars()
	. = ..()
	. += NAMEOF(src, target_pressure)

/obj/machinery/atmospherics/components/binary/temperature_gate/get_save_vars()
	. = ..()
	. += NAMEOF(src, target_temperature)
	. += NAMEOF(src, inverted)

/obj/machinery/atmospherics/components/binary/volume_pump/get_save_vars()
	. = ..()
	. += NAMEOF(src, transfer_rate)
	. += NAMEOF(src, overclocked)

/obj/machinery/atmospherics/components/binary/temperature_pump/get_save_vars()
	. = ..()
	. += NAMEOF(src, heat_transfer_rate)

/obj/machinery/atmospherics/components/trinary/mixer/get_save_vars()
	. = ..()
	. += NAMEOF(src, target_pressure)
	. += NAMEOF(src, node1_concentration)
	. += NAMEOF(src, node2_concentration)

/obj/machinery/atmospherics/components/unary/vent_scrubber/get_save_vars()
	. = ..()
	. += NAMEOF(src, scrubbing)
	. += NAMEOF(src, volume_rate)
	. += NAMEOF(src, widenet)

	if(filter_types.len)
		. += list("filters" = filter_types)

/obj/machinery/atmospherics/components/trinary/filter/get_save_vars()
	. = ..()
	. += NAMEOF(src, transfer_rate)
	. += NAMEOF(src, filter_type)
