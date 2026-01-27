/obj/structure/cable/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, cable_color)
	. += NAMEOF(src, cable_layer)

	. -= NAMEOF(src, color)

/obj/item/stack/cable_coil/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, cable_color)

	// wires modify several vars immediately after init which results
	// in excessive save data that should be omitted
	. -= NAMEOF(src, pixel_x)
	. -= NAMEOF(src, pixel_y)
	. -= NAMEOF(src, color)

/obj/item/rwd/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, current_amount)
	. += NAMEOF(src, cable_layer)

/obj/item/rwd/get_custom_save_vars(save_flags)
	. = ..()
	if(!QDELETED(cable))
		.["cable_coil"] = cable.amount

/obj/item/rwd/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "cable_coil")
			cable = new (src, resolved_value)

			update_appearance()

			attributes -= attribute

			break

	return ..()

/obj/machinery/power/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, cable_layer)

/obj/machinery/power/apc/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, opened)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, coverlocked)
	. += NAMEOF(src, lighting)
	. += NAMEOF(src, equipment)
	. += NAMEOF(src, environ)
	. += NAMEOF(src, cell_type)

/obj/machinery/power/apc/get_custom_save_vars(save_flags)
	. = ..()
	if(!auto_name)
		.[NAMEOF(src, name)] = name

/obj/machinery/power/apc/get_custom_save_vars(save_flags=ALL)
	. = ..()
	if(emergency_lights || nightshift_lights)
		.["lights"] = list(emergency_lights, nightshift_lights)

	if(!QDELETED(cell))
		.[NAMEOF(src, cell)] = cell

/obj/machinery/power/apc/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "cell")
			cell = resolved_value
			cell.forceMove(src)
			update_appearance()

			attributes -= attribute

		else if(attribute == "lights")
			addtimer(CALLBACK(src, PROC_REF(lights), resolved_value), 1 SECONDS)

			attributes -= attribute

	return ..()

/obj/machinery/power/apc/proc/lights(list/lights)
	if(lights[1])
		emergency_lights = TRUE
		for(var/obj/machinery/light/area_light as anything in get_lights())
			if(!initial(area_light.no_low_power)) //If there was an override set on creation, keep that override
				area_light.no_low_power = emergency_lights
				INVOKE_ASYNC(area_light, TYPE_PROC_REF(/obj/machinery/light/, update), FALSE)
			CHECK_TICK

	if(lights[2])
		toggle_nightshift_lights(usr)

/obj/machinery/power/smes/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, input_level)
	. += NAMEOF(src, output_level)

/obj/item/stock_parts/power_store/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, corrupted)
	. += NAMEOF(src, charge)

/obj/item/stock_parts/power_store/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "charge")
			give(resolved_value)

			attributes -= attribute

			break

	return ..()

/obj/machinery/power/port_gen/pacman/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, active)
	. += NAMEOF(src, sheets)
	. += NAMEOF(src, sheet_left)

/obj/machinery/power/port_gen/pacman/PersistentInitialize(list/attributes)
	. = ..()
	if(active)
		active = FALSE // gets reset to TRUE after TogglePower()
		TogglePower()

/obj/machinery/power/solar/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, material_type)
	. += NAMEOF(src, power_tier)

/obj/machinery/power/solar/get_custom_save_vars(save_flags)
	. = ..()
	. -= NAMEOF(src, contents)

/obj/machinery/power/solar/PersistentInitialize(list/attributes)
	. = ..()
	update_appearance()

/obj/machinery/power/solar_control/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, track)

/obj/machinery/power/solar_control/get_custom_save_vars(save_flags=ALL)
	. = ..()
	if(track == SOLAR_TRACK_TIMED)
		.[NAMEOF(src, azimuth_rate)] = azimuth_rate
		.[NAMEOF(src, azimuth_target)] = azimuth_target

/obj/machinery/power/solar_control/PersistentInitialize(list/attributes)
	. = ..()
	search_for_connected()
	switch(track)
		if(SOLAR_TRACK_AUTO)
			if(connected_tracker)
				connected_tracker.sun_update(SSsun, SSsun.azimuth)
			else
				track = SOLAR_TRACK_OFF
		if(SOLAR_TRACK_TIMED)
			set_panels(azimuth_target)

/obj/machinery/power/tracker/get_custom_save_vars(save_flags)
	. = ..()
	. -= NAMEOF(src, contents)

/obj/machinery/power/emitter/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, active)
	. += NAMEOF(src, welded)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, projectile_type)
	. += NAMEOF(src, projectile_sound)
	. += NAMEOF(src, fire_rate_mod)
	. += NAMEOF(src, no_shot_counter)

/obj/machinery/power/emitter/PersistentInitialize(list/attributes)
	. = ..()
	diskie = locate(/obj/item/emitter_disk) in contents
	update_appearance()

/obj/structure/reflector/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, rotation_angle)
	. += NAMEOF(src, finished)
	. += NAMEOF(src, can_rotate)

/obj/machinery/atmos_shield_gen/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, locked)
	. += NAMEOF(src, on)
	. += NAMEOF(src, max_range)

/obj/machinery/power/supermatter_crystal/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, internal_energy)
	. += NAMEOF(src, damage)

/obj/machinery/power/supermatter_crystal/get_custom_save_vars(save_flags)
	. = ..()
	if(absorbed_gasmix)
		.["absorbed_gases"] = absorbed_gasmix.to_string()

/obj/machinery/power/supermatter_crystal/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "absorbed_gases")
			absorbed_gasmix = SSair.parse_gas_string(resolved_value)

			attributes -= attribute

			break

	return ..()

