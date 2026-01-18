// Don't forget to look into other atmos subtypes for variables to save and initialize
// knock it out now before it gets forgotten in the future
/obj/machinery/meter/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_layer)

/obj/machinery/atmospherics/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	. += NAMEOF(src, on)
	. += NAMEOF(src, vent_movement)

	. -= NAMEOF(src, id_tag)

/obj/machinery/atmospherics/PersistentInitialize(list/attributes)
	. = ..()
	if(on)
		set_on(TRUE)

/obj/machinery/atmospherics/pipe/get_custom_save_vars(save_flags)
	. = ..()

	//save the pipeline just once
	if(parent)
		if(!GLOB.map_export_saved_pipelines[parent])
			.["air"] = parent.air.to_string()
			GLOB.map_export_saved_pipelines[parent] = TRUE
		return

	//save temporary air in the absence of a pipeline
	if(air_temporary)
		.["air"] = air_temporary.to_string()

/obj/machinery/atmospherics/pipe/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "air")
			var/datum/gas_mixture/air_mixture = SSair.parse_gas_string(resolved_value)
			if(parent)
				parent.set_air(air_mixture)
			else
				air_temporary = air_mixture

			attributes -= attribute

			break

	return ..()

/obj/machinery/atmospherics/pipe/smart/substitute_with_typepath()
	var/base_type = /obj/machinery/atmospherics/pipe/smart/manifold4w
	var/cache_key = "[base_type]-[pipe_color]-[hide]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/color_path = ""
		switch(pipe_color)
			if(COLOR_YELLOW)
				color_path = "/yellow"
			if(ATMOS_COLOR_OMNI)
				color_path = "/general"
			if(COLOR_CYAN)
				color_path = "/cyan"
			if(COLOR_VIBRANT_LIME)
				color_path = "/green"
			if(COLOR_ENGINEERING_ORANGE)
				color_path = "/orange"
			if(COLOR_PURPLE)
				color_path = "/purple"
			if(COLOR_DARK)
				color_path = "/dark"
			if(COLOR_BROWN)
				color_path = "/brown"
			if(COLOR_STRONG_VIOLET)
				color_path = "/violet"
			if(COLOR_LIGHT_PINK)
				color_path = "/pink"
			if(COLOR_RED)
				color_path = "/scrubbers"
			if(COLOR_BLUE)
				color_path = "/supply"
			else
				color_path = "/general"

		var/visible_path = hide ? "/hidden" : "/visible"

		var/layer_path = ""
		if(piping_layer != 3)
			layer_path = "/layer[piping_layer]"

		var/full_path = "[base_type][color_path][visible_path][layer_path]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			stack_trace("Failed to convert pipe to typepath: [full_path]")
			return type

	return GLOB.map_export_typepath_cache[cache_key]

// these spawn underneath cryo machines and will duplicate after every save
/obj/machinery/atmospherics/components/unary/is_saveable(turf/current_loc, list/obj_blacklist)
	if(locate(/obj/machinery/cryo_cell) in loc)
		return FALSE

	return ..()

/obj/machinery/atmospherics/components/unary/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, welded)

/obj/machinery/atmospherics/components/unary/vent_pump/substitute_with_typepath()
	var/base_type
	if(istype(src, /obj/machinery/atmospherics/components/unary/vent_pump/high_volume))
		base_type = /obj/machinery/atmospherics/components/unary/vent_pump/high_volume
	else
		base_type = /obj/machinery/atmospherics/components/unary/vent_pump

	var/cache_key = "[base_type]-[on]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/on_path = on ? "/on" : ""

		var/layer_path = ""
		if(piping_layer != 3)
			layer_path = "/layer[piping_layer]"

		var/full_path = "[base_type][on_path][layer_path]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			stack_trace("Failed to convert vent scrubber to typepath: [full_path]")
			return type

	return GLOB.map_export_typepath_cache[cache_key]

/obj/machinery/atmospherics/components/unary/vent_pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, pump_direction)
	. += NAMEOF(src, pressure_checks)
	. += NAMEOF(src, internal_pressure_bound)
	. += NAMEOF(src, external_pressure_bound)
	. += NAMEOF(src, fan_overclocked)

/obj/machinery/atmospherics/components/unary/vent_scrubber/substitute_with_typepath()
	var/base_type = /obj/machinery/atmospherics/components/unary/vent_scrubber
	var/cache_key = "[base_type]-[on]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/on_path = on ? "/on" : ""

		var/layer_path = ""
		if(piping_layer != 3)
			layer_path = "/layer[piping_layer]"

		var/full_path = "[base_type][on_path][layer_path]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			stack_trace("Failed to convert vent scrubber to typepath: [full_path]")
			return type

	return GLOB.map_export_typepath_cache[cache_key]

/obj/machinery/atmospherics/components/unary/vent_scrubber/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, scrubbing)
	. += NAMEOF(src, filter_types)
	. += NAMEOF(src, widenet)

/obj/machinery/atmospherics/components/unary/vent_scrubber/get_custom_save_vars(save_flags)
	. = ..()
	if(filter_types.len)
		.["filters"] = filter_types

/obj/machinery/atmospherics/components/unary/vent_scrubber/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "filters")
			filter_types.Cut()
			for(var/gas_type in resolved_value)
				filter_types += gas_type
			atmos_conditions_changed()

			attributes -= attribute

			break

	if(widenet)
		set_widenet(widenet)

	return ..()

/obj/machinery/atmospherics/components/unary/thermomachine/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_temperature)

/obj/machinery/atmospherics/components/trinary/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, flipped)

/obj/machinery/atmospherics/components/trinary/filter/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, transfer_rate)
	. += NAMEOF(src, filter_type)

/obj/machinery/atmospherics/components/trinary/mixer/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_pressure)
	. += NAMEOF(src, node1_concentration)
	. += NAMEOF(src, node2_concentration)

/obj/machinery/atmospherics/components/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, welded)

	if(override_naming)
		. += NAMEOF(src, name)

/obj/machinery/atmospherics/components/get_custom_save_vars(save_flags)
	. = ..()

	var/list/datum/gas_mixture/stored_airs = list()
	for(var/i in 1 to device_type)
		var/datum/gas_mixture/stored_air = airs[i]
		if(stored_air.total_moles() > MINIMUM_MOLE_COUNT)
			//because list values are parsed at the = sign so we replace it
			stored_airs += stored_air.to_string() + "/[i]"

	if(length(stored_airs["airs"]))
		.["airs"] += stored_airs

/obj/machinery/atmospherics/components/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "airs")
			for(var/gas in resolved_value)
				var/list/gas_data = splittext(gas, "/")
				airs[text2num(gas_data[2])].merge(SSair.parse_gas_string(gas_data[1]))

			attributes -= attribute

			break

	return ..()

/obj/machinery/atmospherics/components/binary/crystallizer/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, gas_input)

/obj/machinery/atmospherics/components/binary/crystallizer/get_custom_save_vars(save_flags)
	. = ..()
	.["internal"] = internal.to_string()
	if(selected_recipe)
		.["recipe"] = selected_recipe.id

/obj/machinery/atmospherics/components/binary/crystallizer/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "internal")
			internal.merge(SSair.parse_gas_string(resolved_value))

			attributes -= attribute

		else if(attribute == "recipe")
			selected_recipe = GLOB.gas_recipe_meta[resolved_value]
			update_parents() //prevent the machine from stopping because of the recipe change and the pipenet not updating
			moles_calculations()

			attributes -= attribute

	return ..()

/obj/item/pipe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)

/obj/machinery/portable_atmospherics/canister/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, valve_open)
	. += NAMEOF(src, release_pressure)
	. += NAMEOF(src, name)
	. += NAMEOF(src, desc)
	. += NAMEOF(src, icon_state)
	. += NAMEOF(src, base_icon_state)
	. += NAMEOF(src, greyscale_colors)
	. += NAMEOF(src, greyscale_config)

/obj/machinery/portable_atmospherics/get_custom_save_vars(save_flags=ALL)
	. = ..()
	var/datum/gas_mixture/gasmix = air_contents
	.[NAMEOF(src, initial_gas_mix)] = gasmix.to_string()

/obj/machinery/portable_atmospherics/PersistentInitialize(list/attributes)
	. = ..()
	if((greyscale_colors != initial(greyscale_colors)) || (greyscale_config != initial(greyscale_config)))
		set_greyscale(greyscale_colors, greyscale_config)

	if(!anchored)
		return

	var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
	if(!possible_port)
		return

	connect(possible_port)
	update_appearance()

/obj/machinery/atmospherics/components/binary/volume_pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, transfer_rate)
	. += NAMEOF(src, overclocked)

/obj/machinery/atmospherics/components/binary/pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_pressure)

/obj/machinery/atmospherics/components/binary/temperature_pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, heat_transfer_rate)

/obj/machinery/atmospherics/components/binary/temperature_gate/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_temperature)
	. += NAMEOF(src, inverted)

/obj/machinery/atmospherics/components/binary/pressure_valve/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_pressure)

/obj/machinery/atmospherics/components/binary/passive_gate/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_pressure)

/obj/machinery/atmospherics/components/binary/dp_vent_pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, pump_direction)
	. += NAMEOF(src, external_pressure_bound)
	. += NAMEOF(src, input_pressure_min)
	. += NAMEOF(src, output_pressure_max)
	. += NAMEOF(src, pressure_checks)

/obj/machinery/atmospherics/components/binary/circulator/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, active)
	. += NAMEOF(src, flipped)
	. += NAMEOF(src, mode)

/obj/machinery/atmospherics/components/unary/outlet_injector/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, volume_rate)

/obj/machinery/air_sensor/get_save_vars()
	. = ..()
	. += NAMEOF(src, chamber_id)
	. -= NAMEOF(src, contents)

/obj/machinery/air_sensor/get_custom_save_vars(save_flags)
	. = ..()

	var/obj/machinery/atmospherics/components/unary/outlet_injector/expected_input
	var/obj/machinery/atmospherics/components/unary/vent_pump/expected_output
	for(var/obj/machinery/atmospherics/components/unary/device in oview(4, src))
		if(istype(device, /obj/machinery/atmospherics/components/unary/outlet_injector))
			expected_input = device
		else if(istype(device, /obj/machinery/atmospherics/components/unary/vent_pump))
			expected_output = device

	var/obj/machinery/atmospherics/components/unary/outlet_injector/inlet = GLOB.objects_by_id_tag[inlet_id || ""]
	if(istype(inlet) && !QDELETED(inlet) && inlet != expected_input)
		var/turf/target_turf = get_turf(inlet)
		.["inlet_coords"] = list(target_turf.x, target_turf.y, target_turf.z)

	var/obj/machinery/atmospherics/components/unary/vent_pump/outlet = GLOB.objects_by_id_tag[outlet_id || ""]
	if(istype(outlet) && !QDELETED(outlet) && outlet != expected_output)
		var/turf/target_turf = get_turf(outlet)
		.["outlet_coords"] = list(target_turf.x, target_turf.y, target_turf.z)

/obj/machinery/air_sensor/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "inlet_coords")
			var/obj/machinery/atmospherics/components/unary/outlet_injector/inlet = locate() in TURF_FROM_COORDS_LIST(resolved_value)

			inlet_id = inlet.id_tag

			attributes -= attribute

		else if(attribute == "outlet_coords")
			var/obj/machinery/atmospherics/components/unary/vent_pump/outlet = locate() in TURF_FROM_COORDS_LIST(resolved_value)

			outlet_id = outlet.id_tag

			attributes -= attribute

	return ..()

/obj/machinery/computer/atmos_control/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, atmos_chambers)

/obj/machinery/atmospherics/components/unary/hypertorus/core/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, start_power)
	. += NAMEOF(src, start_cooling)
	. += NAMEOF(src, start_fuel)
	. += NAMEOF(src, start_moderator)
	. += NAMEOF(src, heating_conductor)
	. += NAMEOF(src, magnetic_constrictor)
	. += NAMEOF(src, fuel_injection_rate)
	. += NAMEOF(src, moderator_injection_rate)
	. += NAMEOF(src, current_damper)
	. += NAMEOF(src, waste_remove)
	. += NAMEOF(src, moderator_scrubbing)
	. += NAMEOF(src, moderator_filtering_rate)

/obj/machinery/atmospherics/components/unary/hypertorus/core/get_custom_save_vars(save_flags)
	. = ..()
	if(!isnull(selected_fuel))
		.["fuel"] = selected_fuel.id

	.["activate"] = list(
		airs[1].volume,
		internal_fusion.total_moles() ? internal_fusion.to_string() : "N/A",
		active
	)

/obj/machinery/atmospherics/components/unary/hypertorus/core/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "power")
			start_power = TRUE

			update_use_power(ACTIVE_POWER_USE)

			attributes -= attribute

		else if(attribute == "fuel")
			selected_fuel = GLOB.hfr_fuels_list[resolved_value]

			attributes -= attribute

		else if(attribute == "activate")
			attributes -= attribute

			if(!check_part_connectivity())
				continue

			airs[1].volume = resolved_value[1]
			if(resolved_value[2] != "N/A")
				internal_fusion.merge(SSair.parse_gas_string(resolved_value[2]))
			update_parents() //prevent the machine from stopping because of the recipe change and the pipenet not updating
			linked_input.update_parents()
			linked_output.update_parents()
			linked_moderator.update_parents()

			linked_interface.connected_core = src
			if(resolved_value[3])
				activate(usr)

	return ..()
