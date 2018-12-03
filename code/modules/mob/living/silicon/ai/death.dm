/mob/living/silicon/ai/death(gibbed, deathmessage, show_dead_message)
	if(stat == DEAD)
		return
	remove_ai_verbs()

	for(var/obj/cyber/node/N in nodes)
		N.remove_owner()

	for(var/obj/machinery/ai_status_display/O in world)
		O.mode = 2

	icon_state = icon_dead
	LAZYREMOVE(cyberspace.intelligences, src)

	if (istype(loc, /obj/item/weapon/aicard))
		var/obj/item/weapon/aicard/card = loc
		card.update_icon()

	if(real)
		mind.transfer_to(real)
		real.teleop = null
	. = ..()