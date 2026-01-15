/obj/docking_port/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, dheight)
	. += NAMEOF(src, dwidth)
	. += NAMEOF(src, height)
	. += NAMEOF(src, shuttle_id)
	. += NAMEOF(src, width)

/obj/docking_port/stationary/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, roundstart_template)

// The tram is a little tricky to save because all the [/obj/structure/transport/linear] get deleted except for the one at the bottom left of the tram. These all get used during Init to determine the size and shape of the tram.
// Next problem is the landmark [/obj/effect/landmark/transport/transport_id] gets attatched to the /datum/transport_controller/ and then deleted.
// To resolve these we are going to insert a transport structure on the same turf as any tram wall/floors.
// Then we lookup the landmark from the datum and insert it on the same turf that has the bottom left transport structure
// Without these fixes the tram will runtime on any map or ruins that has it setup

/obj/structure/transport/linear/tram/is_saveable(turf/current_loc, list/obj_blacklist)
	return TRUE // skip multi-tile object checks

/obj/machinery/elevator_control_panel/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, linked_elevator_id)
	. += NAMEOF(src, preset_destination_names)

/obj/machinery/lift_indicator/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, linked_elevator_id)
	. += NAMEOF(src, current_lift_floor)
