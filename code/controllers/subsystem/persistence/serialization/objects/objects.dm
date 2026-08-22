/obj/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, req_access)
	. += NAMEOF(src, id_tag)
	. += NAMEOF(src, obj_flags)

/obj/effect/decal/cleanable/blood/footprints/get_save_vars(save_flags)
	. = ..()
	. -= NAMEOF(src, icon_state)

/obj/item/get_custom_save_vars(save_flags)
	. = ..()
	if(contents.len && atom_storage)
		.[NAMEOF(src, contents)] = contents

/obj/item/photo/get_save_vars(save_flags)
	. = ..()
	. -= NAMEOF(src, icon)

/obj/item/card/id/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, registered_name)
	. += NAMEOF(src, assignment)
	. += NAMEOF(src, access)
	. += NAMEOF(src, trim)

/obj/item/card/id/get_custom_save_vars(save_flags)
	. = ..()

	if(registered_account.add_to_accounts)
		.["data"] = list(
			registered_account.account_job.type,
			registered_account.account_balance,
			registered_account.mining_points,
			registered_account.bitrunning_points
		)

/obj/item/card/id/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "data")
			var/list/data = resolved_value

			registered_account.account_job = SSjob.get_job_type(data[1])
			registered_account.account_balance = data[2]
			registered_account.mining_points = data[3]
			registered_account.bitrunning_points = data[4]

			attributes -= attribute

			break

	return ..()

/obj/item/modular_computer/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, internal_cell)
	. += NAMEOF(src, stored_id)

/obj/item/modular_computer/get_custom_save_vars(save_flags)
	. = ..()

	//we dont save stuff like the cpu directly as that errors in init
	. -= NAMEOF(src, contents)

	//store all programs that don't load up on default
	var/list/stored_files = list()
	for(var/datum/computer_file/program in stored_files)
		if(program.type in starting_programs)
			continue
		stored_files += program.type
	if(length(stored_files))
		.["stored_files"] += stored_files

/obj/item/modular_computer/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "stored_files")
			for(var/datum/computer_file/program in resolved_value)
				program = new
				if(!store_file(program))
					qdel(program)

			attributes -= attribute

			break

	return ..()

/obj/item/construction/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, matter)
	. += NAMEOF(src, construction_upgrades)

/obj/item/construction/rcd/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, root_category)
	. += NAMEOF(src, design_category)
	. += NAMEOF(src, rcd_design_path)
	. += NAMEOF(src, design_title)
	. += NAMEOF(src, mode)
	. += NAMEOF(src, construction_mode)

/obj/item/construction/rtd/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, root_category)
	. += NAMEOF(src, design_category)
	. += NAMEOF(src, selected_direction)

/obj/item/construction/rld/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, color_choice)
	. += NAMEOF(src, mode)

/obj/item/pipe_dispenser/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, p_dir)
	. += NAMEOF(src, p_init_dir)
	. += NAMEOF(src, p_flipped)
	. += NAMEOF(src, paint_color)
	. += NAMEOF(src, category)
	. += NAMEOF(src, pipe_layers)
	. += NAMEOF(src, multi_layer)
	. += NAMEOF(src, upgrade_flags)

/obj/item/mod/core/standard/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, cell)

/obj/item/mod/control/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, core)
	. += NAMEOF(src, theme)

/obj/item/mod/control/get_custom_save_vars(save_flags)
	. = ..()
	. -= NAMEOF(src, contents)

	var/list/modules = list()
	for(var/obj/item/mod/module/installed in contents)
		modules += installed
	.["modules"] = modules

/obj/item/mod/control/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "core")
			QDEL_NULL(core)

			var/obj/item/mod/core/resolved_core = resolved_value
			resolved_core.install(src)

			attributes -= attribute

		else if(attribute == "modules")
			for(var/obj/item/mod/module/installed in contents)
				qdel(installed)

			for(var/obj/item/mod/module/mod in resolved_value)
				install(mod)

			attributes -= attribute

	return ..()

/obj/item/gun/energy/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, cell)

/obj/item/gun/energy/get_custom_save_vars(save_flags)
	. = ..()
	.[NAMEOF(src, cell_type)] = null

/obj/item/gun/energy/recharge/kinetic_accelerator/get_custom_save_vars(save_flags)
	. = ..()

	if(modkits.len)
		var/list/modrefs = list()
		for(var/obj/item/borg/upgrade/modkit/installed in modkits)
			modrefs += installed
		.["modkits"] = modrefs

/obj/item/gun/energy/recharge/kinetic_accelerator/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "modkits")
			for(var/obj/item/borg/upgrade/modkit/mod in resolved_value)
				mod.forceMove(src)

			attributes -= attribute

			break

	return ..()

/obj/item/tank/get_custom_save_vars(save_flags)
	. = ..()
	if(air_contents)
		.["air"] = air_contents.to_string()

/obj/item/tank/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "air")
			air_contents.merge(SSair.parse_gas_string(resolved_value))

			attributes -= attribute

			break

	return ..()

/obj/item/transfer_valve/get_save_vars(save_flags)
	. += NAMEOF(src, tank_one)
	. += NAMEOF(src, tank_two)
	. += NAMEOF(src, attached_device)

/obj/item/disk/tech_disk/get_custom_save_vars(save_flags)
	. = ..()

	.["stored_nodes"] = stored_nodes

/obj/item/disk/tech_disk/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "stored_nodes")
			stored_nodes.Cut()

			stored_nodes += resolved_value

			attributes -= attribute

	return ..()

/obj/item/assembly/control/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, sync_doors)

/obj/item/holosign_creator/get_custom_save_vars(save_flags)
	. = ..()

	var/list/turf_data = list()
	for(var/obj/structure/holosign/hologram as anything in signs)
		var/turf/holo_turf = get_turf(hologram)
		turf_data += "[holo_turf.x]$[holo_turf.y]$[holo_turf.z]"
	.["signs"] = turf_data

/obj/item/holosign_creator/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == "signs")
			for(var/text_loc in resolved_value)
				var/list/loc_list = splittext(text_loc, "$")
				for(var/i in 1 to loc_list.len)
					loc_list[i] = text2num(loc_list[i])
				var/obj/structure/holosign/hologram = locate(holosign_type) in TURF_FROM_COORDS_LIST(loc_list)
				hologram.projector = src
				LAZYADD(signs, hologram)

			attributes -= attribute

			break

	return ..()

/obj/item/boulder/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, durability)

/obj/item/circuitboard/machine/vendor/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, all_products_free)

/obj/item/vending_refill/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, products)
	. += NAMEOF(src, contraband)
	. += NAMEOF(src, premium)

/obj/item/vending_refill/custom/get_custom_save_vars(save_flags)
	. = ..()
	if(contents.len)
		.[NAMEOF(src, contents)] = contents

/obj/item/electronics/airlock/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, accesses)
	. += NAMEOF(src, one_access)
	. += NAMEOF(src, unres_sides)
	. += NAMEOF(src, passed_name)
	. += NAMEOF(src, passed_cycle_id)
	. += NAMEOF(src, shell)

/obj/item/plaque/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, name)
	. += NAMEOF(src, desc)
	. += NAMEOF(src, engraved)
