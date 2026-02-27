GLOBAL_LIST_INIT(save_file_chars, list(
	"a","b","c","d","e",
	"f","g","h","i","j",
	"k","l","m","n","o",
	"p","q","r","s","t",
	"u","v","w","x","y",
	"z","A","B","C","D",
	"E","F","G","H","I",
	"J","K","L","M","N",
	"O","P","Q","R","S",
	"T","U","V","W","X",
	"Y","Z",
))


/**Map exporter
* Inputting a list of turfs into convert_map_to_tgm() will output a string
* with the turfs and their objects / areas on said turf into the TGM mapping format
* for .dmm files. This file can then be opened in the map editor or imported
* back into the game.
* ============================
* This has been made semi-modular so you should be able to use these functions
* elsewhere in code if you ever need to get a file in the .dmm format
**/
/proc/to_list_string(list/build_from, list/obj/local_refs, list/obj/global_refs)
	var/list/build_into = list()
	build_into += "list("
	var/first_entry = TRUE
	for(var/item in build_from)
		CHECK_TICK
		if(!first_entry)
			build_into += ", "
		if(isnum(item) || isnull(build_from[item]))
			build_into += "[tgm_encode(item, local_refs, global_refs)]"
		else
			build_into += "[tgm_encode(item, local_refs, global_refs)] = [tgm_encode(build_from[item], local_refs, global_refs)]"
		first_entry = FALSE
	build_into += ")"
	return build_into.Join("")

/// Takes a constant, encodes it into a TGM valid string
/proc/tgm_encode(value, list/local_refs, list/global_refs)
	if(istext(value))
		//Prevent symbols from being because otherwise you can name something
		// [";},/obj/item/gun/energy/laser/instakill{name="da epic gun] and spawn yourself an instakill gun.
		var/list/replacement_characters = list("{"="", "}"="", "\""="", ","="")
		HASHTAG_NEWLINES_AND_TABS(value, replacement_characters)
		return "\"[value]\""
	if(isnum(value) || ispath(value))
		return "[value]"
	if(islist(value))
		return to_list_string(value, local_refs, global_refs)
	if(isnull(value))
		return "null"
	if(isicon(value) || isfile(value))
		return "'[value]'"
	if(isatom(value))
		var/atom/data = value
		if(QDELETED(data))
			return "null"

		var/ref = REF(data)
		//already written
		if(global_refs[ref])
			return ref
		//write to file
		local_refs[ref] = global_refs[ref] = data

		return ref
	if(isdatum(value))
		var/datum/thing = value
		return "[thing.type]"
	// not handled:
	// - pops: /obj{name="foo"}
	// - new(), newlist(), icon(), matrix(), sound()

	// fallback: string
	return tgm_encode("[value]", local_refs, global_refs)

/proc/generate_tgm_metadata(atom/object, list/local_refs, list/global_refs, write_ref = FALSE, save_flags = ALL)
	var/list/data_to_add = list()
	var/alist/custom_vars
	var/list/vars_to_save = object.get_save_vars()

	if(save_flags & SAVE_OBJECTS_VARIABLES)
		vars_to_save = GLOB.map_export_save_vars_cache[object.type] || object.get_save_vars(save_flags)
		custom_vars = object.get_custom_save_vars(save_flags)
	else // these are the default variables that should save regardless
		vars_to_save = list("dir", "pixel_x", "pixel_y")

	// Tracks variables handled by get_custom_save_vars() This ensures the default variable saving loop
	// correctly skips these names. A separate list is necessary because custom_vars can contain null or FALSE values.
	var/list/custom_var_names
	for(var/custom_variable, custom_value in custom_vars)
		if(custom_variable == REF_ATTRIBUTES || custom_variable == INTERNAL_ID)
			stack_trace("[custom_variable] is a protected variable name and cannot be exported")
			continue

		if(custom_variable == "contents")
			custom_value = object.contents.Copy() //otherwise this would error in tgm_encode_list() with bad index cause its protected
		var/text_value = tgm_encode(custom_value, local_refs, global_refs)
		if(!custom_value)
			continue

		LAZYSET(custom_var_names, custom_variable, TRUE)
		if(isatom(custom_value) || islist(custom_value) || !(custom_variable in object.vars))
			custom_variable = "#[custom_variable]"
		LAZYADD(data_to_add, TGM_VAR_LINE(custom_variable, text_value))

	for(var/variable in vars_to_save)
		// skip variables that use custom serialization
		if(LAZYACCESS(custom_var_names, variable))
			continue
		if(variable == REF_ATTRIBUTES || variable == INTERNAL_ID)
			stack_trace("[variable] is a protected variable name and cannot be exported")
			continue

		var/value = object.vars[variable]
		if(value == initial(object.vars[variable]) || !issaved(object.vars[variable]))
			continue
		if(variable == "icon_state" && object.smoothing_flags)
			continue
		if(variable == "icon" && object.smoothing_flags)
			continue
		if(variable == "contents")
			stack_trace("contents should belong in custom attributes")
			continue
		if(variable == REF_ATTRIBUTES || variable == INTERNAL_ID)
			stack_trace("[variable] is a protected variable name and cannot be exported")
			continue
		if(islist(value))
			var/error
			var/list/work_left = list(value)
			while(!error && work_left.len)
				var/list/data = popleft(work_left)
				for(var/i in 1 to data.len)
					var/k = data[i]
					if(isnum(k))
						continue
					var/v = data[k]
					if(isnull(v))
						v = k
						k = i

					if(isatom(k) || isatom(v))
						error = isatom(k) ? "[k]" : "[v]"
					if(error)
						break

					if(islist(v))
						work_left += list(v)
			if(error)
				stack_trace("Atom element [error] found in list. Use get_custom_save_vars() to save this list.)")
				continue

		var/text_value = tgm_encode(value, local_refs, global_refs)
		if(!text_value)
			continue
		LAZYADD(data_to_add, TGM_VAR_LINE(variable, text_value))

	if(write_ref)
		LAZYADD(data_to_add, TGM_VAR_LINE(INTERNAL_ID, REF(object)))
	if(!data_to_add.len)
		return
	return TGM_VARS_BLOCK(data_to_add.Join(";\n\t"))

/proc/generate_tgm_typepath_metadata(list/data_to_seralize)
	var/list/data_to_add = list()

	for(var/variable in data_to_seralize)
		var/value = data_to_seralize[variable]

		value = tgm_encode(value)
		if(!value)
			continue
		data_to_add += TGM_VAR_LINE(variable, value)

	if(!length(data_to_add))
		return

	return TGM_VARS_BLOCK(data_to_add.Join(";\n\t"))
