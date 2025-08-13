#define REF_ATTRIBUTE(prefix, value)(list(list("[prefix][replacetext(replacetext(REF(value), "\[", ""), "\]", "")]" = value)))

/obj/get_save_vars()
	. = ..()
	. += NAMEOF(src, req_access)
	. += NAMEOF(src, id_tag)

/obj/effect/decal/cleanable/blood/footprints/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)

/obj/item/get_save_vars()
	. = ..()
	if(contents.len && atom_storage)
		. += NAMEOF(src, contents)

/obj/item/stack/get_save_vars()
	. = ..()
	. += NAMEOF(src, amount)

/obj/docking_port/get_save_vars()
	. = ..()
	. += NAMEOF(src, dheight)
	. += NAMEOF(src, dwidth)
	. += NAMEOF(src, height)
	. += NAMEOF(src, shuttle_id)
	. += NAMEOF(src, width)

/obj/item/storage/get_save_vars()
	. = ..()
	. += NAMEOF(src, init_storage)

/obj/item/pipe/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)

/obj/docking_port/stationary/get_save_vars()
	. = ..()
	. += NAMEOF(src, roundstart_template)

/obj/item/stock_parts/power_store/get_save_vars()
	. = ..()
	. += NAMEOF(src, charge)
	. += NAMEOF(src, rigged)

/obj/item/photo/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)

/obj/item/card/id/get_save_vars()
	. = ..()
	. += NAMEOF(src, registered_name)
	. += NAMEOF(src, assignment)
	. += NAMEOF(src, access)

	if(registered_account)
		. += list(list("data" = list(
			registered_account.account_job.type,
			registered_account.account_balance,
			registered_account.mining_points,
			registered_account.bitrunning_points
		)))

/obj/item/modular_computer/get_save_vars()
	. = ..()

	//we dont save stuff like the cpu directly as that errors in init
	. -= NAMEOF(src, contents)

	//store power source
	if(!QDELETED(internal_cell))
		. += NAMEOF(src, internal_cell)

	//stored id slot
	if(!QDELETED(stored_id))
		. += NAMEOF(src, stored_id)

	//store all programs that don't load up on default
	var/list/stored_files = list("stored_files" = list())
	for(var/datum/computer_file/program in stored_files)
		if(program.type in starting_programs)
			continue
		stored_files["stored_files"] += "[program.type]"
	if(length(stored_files["stored_files"]))
		. += list(stored_files)

/obj/item/rwd/get_save_vars()
	. = ..()
	. += NAMEOF(src, current_amount)
	. += NAMEOF(src, cable_layer)
	if(!QDELETED(cable))
		. += list(list("cable_coil" = cable.amount))

/obj/item/construction/get_save_vars()
	. = ..()
	. += NAMEOF(src, matter)
	. += NAMEOF(src, construction_upgrades)

/obj/item/construction/rcd/get_save_vars()
	. = ..()
	. += NAMEOF(src, root_category)
	. += NAMEOF(src, design_category)
	. += NAMEOF(src, rcd_design_path)
	. += NAMEOF(src, design_title)
	. += NAMEOF(src, mode)
	. += NAMEOF(src, construction_mode)

/obj/item/construction/rtd/get_save_vars()
	. = ..()
	. += NAMEOF(src, root_category)
	. += NAMEOF(src, design_category)
	. += NAMEOF(src, selected_direction)

/obj/item/construction/rld/get_save_vars()
	. = ..()
	. += NAMEOF(src, color_choice)
	. += NAMEOF(src, mode)

/obj/item/pipe_dispenser/get_save_vars()
	. = ..()
	. += NAMEOF(src, p_dir)
	. += NAMEOF(src, p_init_dir)
	. += NAMEOF(src, p_flipped)
	. += NAMEOF(src, paint_color)
	. += NAMEOF(src, category)
	. += NAMEOF(src, pipe_layers)
	. += NAMEOF(src, multi_layer)
	. += NAMEOF(src, upgrade_flags)

/obj/item/mod/core/standard/get_save_vars()
	. = ..()
	if(!QDELETED(cell))
		. += NAMEOF(src, cell)

/obj/item/mod/module/anomaly_locked/get_save_vars()
	. = ..()
	. += NAMEOF(src, core)

/obj/item/mod/control/get_save_vars()
	. = ..()
	. += NAMEOF(src, core)
	. += NAMEOF(src, theme)
	. -= NAMEOF(src, contents)

	for(var/obj/item/mod/module/installed in contents)
		. += REF_ATTRIBUTE("module", installed)

/obj/item/gun/energy/recharge/kinetic_accelerator/get_save_vars()
	. = ..()

	for(var/obj/item/borg/upgrade/modkit/installed in modkits)
		. += REF_ATTRIBUTE("modkit", installed)

/obj/item/gun/energy/get_save_vars()
	. = ..()

	cell_type = null
	. += NAMEOF(src, cell_type)
	. += NAMEOF(src, cell)

/obj/item/tank/get_save_vars()
	. = ..()
	if(air_contents)
		. += list(list("air" = air_contents.to_string()))

/obj/item/transfer_valve/get_save_vars()
	. = ..()
	if(!QDELETED(tank_one))
		. += NAMEOF(src, tank_one)
	if(!QDELETED(tank_two))
		. += NAMEOF(src, tank_two)
	if(!QDELETED(attached_device))
		. += NAMEOF(src, attached_device)

/obj/item/disk/tech_disk/get_save_vars()
	. = ..()

	if(stored_research.researched_nodes.len)
		. += list(list("researched_nodes" = stored_research.researched_nodes))

	if(stored_research.visible_nodes.len)
		. += list(list("visible_nodes" = stored_research.visible_nodes))

	if(stored_research.available_nodes.len)
		. += list(list("available_nodes" = stored_research.available_nodes))

	if(stored_research.researched_designs.len)
		. += list(list("researched_designs" = stored_research.researched_designs))

	if(stored_research.hidden_nodes.len)
		. += list(list("hidden_nodes" = stored_research.hidden_nodes))

/obj/item/assembly/control/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, sync_doors)

/obj/item/holosign_creator/get_save_vars()
	. = ..()

	var/list/turf_data = list()
	for(var/obj/structure/holosign/hologram as anything in signs)
		var/turf/holo_turf = get_turf(hologram)
		turf_data += "[holo_turf.x]$[holo_turf.y]$[holo_turf.z]"
	. += list(list("signs" = turf_data))

/obj/item/boulder/get_save_vars()
	. = ..()
	. += NAMEOF(src, durability)

/obj/item/vending_refill/get_save_vars()
	. = ..()
	if(products)
		. += NAMEOF(src, products)
	if(contraband)
		. += NAMEOF(src, contraband)
	if(premium)
		. += NAMEOF(src, premium)

/obj/item/vending_refill/custom/get_save_vars()
	. = ..()
	if(contents.len)
		. += NAMEOF(src, contents)

#undef REF_ATTRIBUTE
