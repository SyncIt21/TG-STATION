/obj/machinery/restore_saved_value(attribute, resolved_value)
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

		return

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

		//other stuff which can also be part of component_parts should be filtered out
		var/should_refresh = FALSE
		for(var/atom/movable/thing in contents)
			thing.forceMove(src)

			for(var/part_type in req_components)
				if(istype(thing, part_type))
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

		return

	..()

/obj/machinery/chem_heater/restore_saved_value(attribute, resolved_value)
	if(attribute == "contents")
		QDEL_NULL(beaker)

		beaker = locate() in resolved_value

		return ..()

	..()

/obj/machinery/ore_silo/restore_saved_value(attribute, resolved_value)
	if(attribute == "materials")
		SSmaterials.set_list(materials, resolved_value)

		return

	..()

/obj/machinery/autolathe/restore_saved_value(attribute, resolved_value)
	if(attribute == "local_container")
		SSmaterials.set_list(materials, resolved_value)

		return

	..()

/obj/machinery/rnd/production/restore_saved_value(attribute, resolved_value)
	if(attribute == "local_container")
		materials.disconnect()

		SSmaterials.set_list(materials.mat_container, resolved_value)

		return

	..()

/obj/machinery/mecha_part_fabricator/restore_saved_value(attribute, resolved_value)
	if(attribute == "local_container")
		rmat.disconnect()

		SSmaterials.set_list(rmat.mat_container, resolved_value)

		return

	..()


/obj/machinery/component_printer/restore_saved_value(attribute, resolved_value)
	if(attribute == "local_container")
		materials.disconnect()

		SSmaterials.set_list(materials.mat_container, resolved_value)

		return

	..()

/obj/machinery/bouldertech/restore_saved_value(attribute, resolved_value)
	if(attribute == "local_container")
		silo_materials.disconnect()

		SSmaterials.set_list(silo_materials.mat_container, resolved_value)

		return

	..()

/obj/machinery/mineral/ore_redemption/restore_saved_value(attribute, resolved_value)
	if(attribute == "local_container")
		materials.disconnect()

		SSmaterials.set_list(materials.mat_container, resolved_value)

		return

	..()

/obj/machinery/space_heater/restore_saved_value(attribute, resolved_value)
	if(attribute == "contents")
		QDEL_NULL(cell)

		cell = locate(/obj/item/stock_parts/power_store) in resolved_value

		return ..()

	..()

/obj/machinery/electrolyzer/restore_saved_value(attribute, resolved_value)
	if(attribute == "contents")
		QDEL_NULL(cell)

		cell = locate() in resolved_value

		return ..()

	..()

/obj/machinery/modular_computer/restore_saved_value(attribute, resolved_value)
	//restore saved files
	if(attribute == "stored_files")
		for(var/program_type in resolved_value)
			var/datum/computer_file/program = text2path(program_type)
			program = new program
			if(!cpu.store_file(program))
				qdel(program)

		return

	..()

/obj/machinery/power/apc/restore_saved_value(attribute, resolved_value)
	if(attribute == "cell")
		cell = resolved_value
		update_appearance()
		return

	..()

/obj/machinery/reagentgrinder/restore_saved_value(attribute, resolved_value)
	if(attribute == "contents")
		QDEL_NULL(beaker)

		beaker = locate() in resolved_value

		update_appearance(UPDATE_OVERLAYS)

		return ..()

	..()

/obj/machinery/chem_master/restore_saved_value(attribute, resolved_value)
	if(attribute == "beaker")
		QDEL_NULL(beaker)

		beaker = resolved_value

		update_appearance(UPDATE_OVERLAYS)

		return

	..()

/obj/machinery/chem_dispenser/restore_saved_value(attribute, resolved_value)
	if(attribute == "contents")
		QDEL_NULL(cell)
		cell = locate() in resolved_value

		QDEL_NULL(beaker)
		beaker = locate() in resolved_value

		update_appearance()

		return

	..()

/obj/machinery/power/supermatter_crystal/restore_saved_value(attribute, resolved_value)
	if(attribute == "absorbed_gases")
		absorbed_gasmix = SSair.parse_gas_string(resolved_value)

		return

	..()

/obj/machinery/airalarm/restore_saved_value(attribute, resolved_value)
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

		return

	if(attribute == "selected_mode")
		select_mode(src, resolved_value, TRUE)

		return

	if(attribute == "air_sensor")
		air_sensor_chamber_id = resolved_value

		setup_chamber_link()

		return

	..()

/obj/machinery/research/anomaly_refinery/restore_saved_value(attribute, resolved_value)
	if(attribute == "contents")
		..()

		for(var/obj/item/thing in contents)
			if(istype(thing, /obj/item/raw_anomaly_core))
				inserted_core = thing
			else if(istype(thing, inserted_bomb))
				inserted_bomb = thing

		return

	..()

/obj/machinery/conveyor_switch/restore_saved_value(attribute, resolved_value)
	if(attribute == "position")
		addtimer(CALLBACK(src, PROC_REF(on_user_activation), usr, resolved_value), 1 SECONDS)
		return

	..()

/obj/machinery/conveyor/restore_saved_value(attribute, resolved_value)
	if(attribute == "id")
		LAZYADD(GLOB.conveyors_by_id[resolved_value], src)

		return

	..()

/obj/machinery/vending/restore_saved_value(attribute, resolved_value)
	if(attribute == "contents")
		..()

		for(var/obj/item/thing as anything in contents)
			for(var/datum/data/vending_product/record in product_records + coin_records + hidden_records)
				if(thing.type == record.product_path)
					LAZYADD(record.returned_products, thing)
					break

		return

	..()
