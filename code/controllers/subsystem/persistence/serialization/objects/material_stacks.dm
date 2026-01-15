/obj/item/stack/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, amount)
