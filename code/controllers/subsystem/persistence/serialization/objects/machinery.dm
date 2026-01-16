/obj/machinery/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, panel_open)

/obj/machinery/get_custom_save_vars(save_flags)
	. = ..()

	if(length(component_parts))
		//export datum component parts seperately
		var/list/datum_components = list()
		for(var/datum/stock_part/part in component_parts)
			datum_components += part.type
		//if we have an atom part defer refreshing parts
		if(!(locate(/atom/movable) in (component_parts - circuit)))
			datum_components += "refresh"
		//save as custom var
		if(datum_components.len)
			.["datum_components"] = datum_components

	//export everything else
	if(contents.len)
		.[NAMEOF(src, contents)] = contents

/obj/machinery/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "datum_components")
			//remove existing parts
			for(var/datum/stock_part/part in component_parts)
				component_parts -= part

			//add new parts
			for(var/part_path in resolved_value)
				//signal to refresh parts
				if(istext(part_path))
					RefreshParts()
					break
				component_parts += GLOB.stock_part_datums[part_path]
			attributes -= attribute

		if(attribute == "contents")
			var/list/contents = resolved_value
			var/list/req_components = null

			//remove default parts
			circuit = null
			for(var/atom/part in component_parts)
				component_parts -= part
				qdel(part)

			//locate circuit board & filter required components if applicable
			var/obj/item/circuitboard/board = locate() in contents
			if(!QDELETED(board))
				circuit = board
				circuit.forceMove(src)
				contents -= circuit
				component_parts += circuit
				if(istype(board, /obj/item/circuitboard/machine))
					var/obj/item/circuitboard/machine/mech = circuit
					if(length(mech.req_components)) //vat grower dont have this
						req_components = mech.req_components.Copy()

			//replacement components for machine boards
			var/list/def_components = list()
			if(istype(board, /obj/item/circuitboard/machine))
				var/obj/item/circuitboard/machine/mech_board = board
				if(length(mech_board.def_components))
					def_components = mech_board.def_components

			//other stuff which can also be part of component_parts should be filtered out
			var/should_refresh = FALSE
			for(var/atom/movable/thing in contents)
				thing.forceMove(src)

				for(var/part_type in req_components)
					if(thing.type == (def_components[part_type] || part_type))
						//append the part
						component_parts += thing

						//time to refresh
						should_refresh = TRUE

						//keep track of how much more are required
						var/count = req_components[part_type] - 1
						if(!count)
							req_components -= part_type
							continue
						req_components[part_type] = count

			if(should_refresh)
				RefreshParts()
			attributes -= attribute

	update_appearance()

	return ..()

/obj/machinery/camera/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, network)
	. += NAMEOF(src, camera_construction_state)
	. += NAMEOF(src, camera_upgrade_bitflags)
	. += NAMEOF(src, camera_enabled)

/obj/machinery/camera/PersistentInitialize(list/attributes)
	. = ..()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_XRAY)
		upgradeXRay()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_EMP_PROOF)
		upgradeEmpProof()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_MOTION)
		upgradeMotion()

// in game built cameras spawn deconstructed
/obj/machinery/camera/autoname/deconstructed/substitute_with_typepath(map_string)
	if(camera_construction_state != CAMERA_STATE_FINISHED)
		return FALSE

	var/cache_key = "[type]-[dir]"
	var/replacement_type = /obj/machinery/camera/autoname/directional
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/directional = ""
		switch(dir)
			if(NORTH)
				directional = "/north"
			if(SOUTH)
				directional = "/south"
			if(EAST)
				directional = "/east"
			if(WEST)
				directional = "/west"

		var/full_path = "[replacement_type][directional]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert [src] to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(cached_typepath)
		var/obj/machinery/camera/autoname/directional/typepath = cached_typepath
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, network, network)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, camera_upgrade_bitflags, camera_upgrade_bitflags)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, camera_enabled, camera_enabled)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, panel_open, panel_open)

		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	return cached_typepath

/obj/machinery/button/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, device)
	. += NAMEOF(src, board)

/obj/machinery/button/PersistentInitialize(list/attributes)
	. = ..()
	setup_device()
	update_appearance()

/obj/machinery/conveyor_switch/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, conveyor_speed)
	. += NAMEOF(src, position)
	. += NAMEOF(src, oneway)

/obj/machinery/conveyor_switch/PersistentInitialize(list/attributes)
	. = ..()
	update_appearance()
	update_linked_conveyors()
	update_linked_switches()

/obj/machinery/conveyor/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, speed)

/obj/machinery/photocopier/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, paper_stack)

/// CHECK IF ID_TAGS ARE NEEDED FOR FIREDOOR/FIREALARMS
/obj/machinery/door/firedoor/get_save_vars(save_flags=ALL)
	. = ..()
	. -= NAMEOF(src, id_tag)

/obj/machinery/firealarm/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, buildstage)
	. -= NAMEOF(src, id_tag)

/obj/machinery/suit_storage_unit/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, density)
	. += NAMEOF(src, state_open)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, safeties)
	// ignore card reader stuff for now

/obj/machinery/suit_storage_unit/get_custom_save_vars(save_flags=ALL)
	. = ..()
	// since these aren't inside contents only save the typepaths
	if(suit)
		.[NAMEOF(src, suit_type)] = suit.type
	if(helmet)
		.[NAMEOF(src, helmet_type)] = helmet.type
	if(mask)
		.[NAMEOF(src, mask_type)] = mask.type
	if(mod)
		.[NAMEOF(src, mod_type)] = mod.type
	if(storage)
		.[NAMEOF(src, storage_type)] = storage.type

/obj/machinery/power/portagrav/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, on)
	. += NAMEOF(src, wire_mode)
	. += NAMEOF(src, grav_strength)
	. += NAMEOF(src, range)

/obj/machinery/power/portagrav/PersistentInitialize(list/attributes)
	. = ..()
	if(on)
		turn_on()

/obj/machinery/biogenerator/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, biomass)
	. += NAMEOF(src, welded_down)

/obj/machinery/biogenerator/PersistentInitialize(list/attributes)
	. = ..()
	update_appearance()

/obj/machinery/mecha_part_fabricator/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, drop_direction)

/obj/machinery/mecha_part_fabricator/get_custom_save_vars(save_flags)
	. = ..()

	if(QDELETED(rmat.silo))
		.["local_container"] = SSmaterials.to_list(rmat.mat_container)

/obj/machinery/mecha_part_fabricator/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "local_container")
			rmat.disconnect()

			SSmaterials.set_list(rmat.mat_container, resolved_value)

			attributes -= attribute

			break

	return ..()

/obj/machinery/autolathe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, hacked)
	. += NAMEOF(src, disabled)
	. += NAMEOF(src, drop_direction)

/obj/machinery/autolathe/get_custom_save_vars(save_flags)
	. = ..()

	.["local_container"] = SSmaterials.to_list(materials)

/obj/machinery/autolathe/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "local_container")
			SSmaterials.set_list(materials, resolved_value)

			attributes -= attribute

			break

	return ..()

/obj/machinery/plumbing/synthesizer/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, reagent_id)
	. += NAMEOF(src, amount)

/obj/machinery/ore_silo/get_custom_save_vars(save_flags)
	. = ..()

	.["materials"] = SSmaterials.to_list(materials)

/obj/machinery/ore_silo/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "materials")
			SSmaterials.set_list(materials, resolved_value)

			attributes -= attribute

			break

	return ..()

/obj/machinery/rnd/production/get_custom_save_vars(save_flags)
	. = ..()

	if(QDELETED(materials.silo))
		.["local_container"] = SSmaterials.to_list(materials.mat_container)

/obj/machinery/rnd/production/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "local_container")
			materials.disconnect()

			SSmaterials.set_list(materials.mat_container, resolved_value)

			attributes -= attribute

			break

	return ..()

/obj/machinery/component_printer/get_custom_save_vars(save_flags)
	. = ..()

	if(QDELETED(materials.silo))
		.["local_container"] = SSmaterials.to_list(materials.mat_container)

/obj/machinery/component_printer/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "local_container")
			materials.disconnect()

			SSmaterials.set_list(materials.mat_container, resolved_value)

			attributes -= attribute

			break

	return ..()

/obj/machinery/bouldertech/get_custom_save_vars(save_flags)
	. = ..()

	if(QDELETED(silo_materials.silo))
		.["local_container"] = SSmaterials.to_list(silo_materials.mat_container)

/obj/machinery/bouldertech/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "local_container")
			silo_materials.disconnect()

			SSmaterials.set_list(silo_materials.mat_container, resolved_value)

			attributes -= attribute

			break

	return ..()

/obj/machinery/mineral/ore_redemption/get_custom_save_vars(save_flags)
	. = ..()

	if(QDELETED(materials.silo))
		.["local_container"] = SSmaterials.to_list(materials.mat_container)

/obj/machinery/mineral/ore_redemption/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "local_container")
			materials.disconnect()

			SSmaterials.set_list(materials.mat_container, resolved_value)

			attributes -= attribute

			break

	return ..()

/obj/machinery/chem_heater/get_save_vars()
	. = ..()
	. += NAMEOF(src, target_temperature)
	. += NAMEOF(src, heater_coefficient)
	. += NAMEOF(src, on)
	. += NAMEOF(src, dispense_volume)
	. += NAMEOF(src, beaker)

/obj/machinery/airalarm/get_save_vars()
	. = ..()
	. -= NAMEOF(src, name)
	. += NAMEOF(src, buildstage)

/obj/machinery/airalarm/get_custom_save_vars(save_flags)
	. = ..()

	var/list/tlv_data = list()
	for(var/key in tlv_collection)
		var/datum/tlv/data = tlv_collection[key]
		tlv_data[key] = "[data.warning_min]/[data.warning_max]/[data.hazard_min]/[data.hazard_max]"
	.["tlv"] = tlv_data

	.[NAMEOF(src, danger_level)] = danger_level
	.["selected_mode"] = selected_mode.type

	.[NAMEOF(src, allow_link_change)] = allow_link_change
	if(length(air_sensor_chamber_id))
		.["air_sensor"] = air_sensor_chamber_id

/obj/machinery/airalarm/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "tlv")
			var/list/tlv_list = resolved_value
			for(var/tlv_key in tlv_list)
				var/datum/tlv/setting = tlv_collection[tlv_key]

				var/list/data = splittext(tlv_list[tlv_key], "/")
				setting.warning_min = text2num(data[1])
				setting.warning_max = text2num(data[2])
				setting.hazard_min = text2num(data[3])
				setting.hazard_max = text2num(data[4])

			update_appearance()

			attributes -= attribute

		else if(attribute == "selected_mode")
			select_mode(src, resolved_value, TRUE)

			attributes -= attribute

		else if(attribute == "air_sensor")
			air_sensor_chamber_id = resolved_value

			setup_chamber_link()

			attributes -= attribute

	return ..()

/obj/machinery/modular_computer/get_custom_save_vars(save_flags)
	. = ..()

	//so we dont save the internal cpu and stuff
	. -= NAMEOF(src, contents)

	//to save starting programs of the cpu
	var/list/stored_files = list()
	for(var/datum/computer_file/file in cpu.stored_files)
		if(file.type in cpu.starting_programs)
			continue
		stored_files += file
	if(length(stored_files))
		.["stored_files"] = stored_files

/obj/machinery/modular_computer/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "stored_files")
			for(var/program_type in resolved_value)
				var/datum/computer_file/program = new program_type
				if(!cpu.store_file(program))
					qdel(program)

			attributes -= attribute

			break

	return ..()

/obj/machinery/vending/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, credits_contained)
	. += NAMEOF(src, all_products_free)
	on_deconstruction()

/obj/machinery/vending/custom/get_save_vars(save_flags)
	var/temp = linked_account
	linked_account = null
	. = ..()
	linked_account = temp

/obj/machinery/vending/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "contents")
			var/obj/item/circuitboard/machine/vendor/board = locate() in resolved_value
			board.set_type(type)
			..()

			for(var/datum/data/vending_product/record in product_records + coin_records + hidden_records)
				for(var/obj/item/thing as anything in resolved_value)
					if(thing.type == record.product_path)
						LAZYADD(record.returned_products, thing)
						record.amount += 1
						break

			break

	return ..()

/obj/machinery/space_heater/PersistentInitialize(list/attributes)
	. = ..()
	cell = locate(/obj/item/stock_parts/power_store) in contents

/obj/machinery/electrolyzer/PersistentInitialize(list/attributes)
	. = ..()
	cell = locate() in contents

/obj/machinery/reagentgrinder/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "contents")
			var/obj/item/reagent_containers/find = locate() in resolved_value
			if(!QDELETED(find))
				QDEL_NULL(beaker)
				beaker = find
				beaker.forceMove(src)
				resolved_value -= find
				update_appearance(UPDATE_OVERLAYS)
				break

	return ..()

/obj/machinery/chem_master/PersistentInitialize(list/attributes)
	. = ..()
	beaker = locate() in contents
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/chem_dispenser/PersistentInitialize(list/attributes)
	. = ..()
	cell = locate() in contents
	beaker = locate() in contents

/obj/machinery/door/window/PersistentInitialize(list/attributes)
	. = ..()
	for(var/attribute, resolved_value in attributes)
		if(attribute == "electronics")
			var/obj/item/electronics/airlock/saved = resolved_value
			if(saved.one_access)
				req_one_access = saved.accesses
			else if(length(saved.req_access))
				req_access = saved.accesses

			return
