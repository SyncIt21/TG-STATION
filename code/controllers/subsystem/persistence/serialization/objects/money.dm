/obj/item/holochip/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, credits)

/obj/item/stack/spacecash/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, amount)
	. += NAMEOF(src, value)

/obj/item/stack/spacecash/PersistentInitialize(list/attributes)
	. = ..()
	update_appearance()

/obj/machinery/computer/bank_machine/get_custom_save_vars(save_flags)
	. = ..()

	var/total_credits = synced_bank_account?.account_balance || 0
	if(total_credits > 0)
		.["total_credits"] = total_credits

/obj/machinery/computer/bank_machine/PersistentInitialize(list/attributes)
	for(var/attribute, value in attributes)
		if(attribute == "total_credits")
			synced_bank_account.adjust_money(value)

			attributes -= attribute

			break

	return ..()
