/obj/item/reagent_containers/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, amount_per_transfer_from_this)

/obj/item/reagent_containers/PersistentInitialize(list/attributes)
	. = ..()
	update_appearance()

/obj/machinery/duct/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, duct_layer)
	. += NAMEOF(src, duct_color)
	. -= NAMEOF(src, color)

/obj/item/lazarus_injector/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, loaded)

/obj/item/lazarus_injector/PersistentInitialize(list/attributes)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/hypospray/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, used_up)

/obj/machinery/shower/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, intended_on)
	. += NAMEOF(src, actually_on)
	. += NAMEOF(src, has_water_reclaimer)
	. += NAMEOF(src, mode)

/obj/machinery/shower/PersistentInitialize(list/attributes)
	. = ..()
	update_actually_on(intended_on)
