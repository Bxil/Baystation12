/turf/unsimulated/cyber
	icon = 'icons/turf/cyberspace.dmi'
	color = COLOR_GREEN
	dynamic_lighting = 0

/turf/unsimulated/cyber/wall
	name = "cyberwall"
	icon_state = "wall"
	density = TRUE
	opacity = TRUE

/turf/unsimulated/cyber/wall/attack_hand(mob/living/silicon/ai/user)
	if(!user.cyberspace.is_border(src))
		user.visible_message(SPAN_WARNING("[user] starts destroying \the [src]."), SPAN_WARNING("You start destroying \the [src]."))
		if(do_after(user, max(20 SECONDS - user.get_processing_power(), 1 SECONDS), src))
			ChangeTurf(/turf/unsimulated/cyber/floor)
	else
		to_chat(user, SPAN_NOTICE("It's a border wall. There is nothing behind."))


/turf/unsimulated/cyber/floor
	name = "cyberfloor"
	icon_state = "floor"
	density = FALSE
	opacity = FALSE

/turf/unsimulated/cyber/floor/Initialize()
	. = ..()
	name = "\proper memory address [x]x[y]"

/turf/unsimulated/cyber/floor/attack_hand(mob/living/silicon/ai/user)
	for(var/atom/movable/AM in src)
		if(AM.simulated)
			return //Can only build walls if it has nothing in it.
	user.visible_message(SPAN_WARNING("[user] starts constructing a wall on \the [src]."),SPAN_WARNING("You start constructing a wall on \the [src]."))
	if(do_after(user, max(20 SECONDS - user.get_processing_power(), 1 SECONDS), src))
		for(var/atom/movable/AM in src)
			if(AM.simulated)
				return //Can only build walls if it has nothing in it.
		ChangeTurf(/turf/unsimulated/cyber/wall)