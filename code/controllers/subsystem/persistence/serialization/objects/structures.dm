/obj/structure/sign/painting/get_save_vars(save_flags)
	. = ..()
	. -= NAMEOF(src, icon)

/obj/structure/falsewall/get_save_vars(save_flags)
	. = ..()
	. -= NAMEOF(src, icon)

/obj/structure/tank_dispenser/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, oxygentanks)
	. += NAMEOF(src, plasmatanks)

/obj/structure/reflector/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, finished)
	. += NAMEOF(src, can_rotate)
	. += NAMEOF(src, rotation_angle)

/obj/structure/ore_vent/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, tapped)
	. += NAMEOF(src, discovered)

/obj/structure/frame/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, state)

/obj/structure/frame/machine/get_custom_save_vars(save_flags)
	. = ..()
	if(!QDELETED(circuit))
		.[NAMEOF(src, req_components)] = req_components
		.[NAMEOF(src, contents)] = contents

/obj/structure/frame/computer/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, circuit)

/obj/structure/window/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, state)

/obj/structure/door_assembly/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, state)
	. += NAMEOF(src, electronics)

/obj/structure/windoor_assembly/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, state)
	. += NAMEOF(src, secure)
	. += NAMEOF(src, facing)
	. += NAMEOF(src, electronics)
