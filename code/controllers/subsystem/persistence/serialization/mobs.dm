// There is currently no [/mob/living/carbon] support due to complexity

///  B A S I C   M O B S  ///

/mob/living/is_saveable(turf/current_loc, list/obj_blacklist)
	return stat == DEAD ? FALSE : ..()  // what is dead may never die

/mob/living/basic/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stat)
	. += NAMEOF(src, health)

	. -= NAMEOF(src, density)

/mob/living/basic/PersistentInitialize(list/attributes)
	. = ..()
	updatehealth()

///  S I M P L E   A N I M A L S  ///

/mob/living/simple_animal/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stat)
	. += NAMEOF(src, health)

	. -= NAMEOF(src, density)

/mob/living/simple_animal/PersistentInitialize(list/attributes)
	. = ..()
	updatehealth()

/mob/living/silicon/robot/substitute_with_typepath()
	return /obj/item/robot_suit/prebuilt

/mob/living/silicon/ai/substitute_with_typepath()
	return /obj/structure/ai_core/latejoin_inactive

/mob/living/basic/parrot/get_custom_save_vars(save_flags)
	. = ..()
	if(!QDELETED(held_item))
		.[NAMEOF(src, held_item)] = held_item

/mob/living/basic/parrot/PersistentInitialize(list/attributes)
	for(var/attribute, resolved_value in attributes)
		if(attribute == NAMEOF(src, held_item))
			put_in_inactive_hand(resolved_value, forced = TRUE)

			attributes -= attribute

			break

	return ..()
