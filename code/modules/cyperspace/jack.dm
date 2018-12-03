/obj/machinery/cyberjack
	name = "cyberjack"
	icon = 'icons/obj/cyberspace.dmi'
	icon_state = "intelligence"

	var/list/mobs

/obj/machinery/cyberjack/Initialize()
	. = ..()

	if(!SScyberspace.get_linked_cyber(z))
		new/datum/cyberspace(GetConnectedZlevels(z))

#define FAIL_MSG "And nothing happens."

/obj/machinery/cyberjack/attack_hand(mob/living/user)
	if(!istype(user) || isAI(user)) //You have no business here
		return

	user.visible_message("[user] touches \the [src].","You touch \the [src]...")

	if(!powered())
		to_chat(user, FAIL_MSG)
		return

	var/bodypart = user.hand ? HAND_RIGHT : HAND_LEFT
	if(ishuman(user) && user.get_covering_equipped_item(bodypart)) //You dummy.
		to_chat(user, FAIL_MSG)
		return

	if(prob(user.skill_fail_chance(SKILL_COMPUTER, 50, SKILL_EXPERT)))
		user.electrocute_act(rand(1,10), src, def_zone = pick(BP_R_HAND, BP_L_HAND))
		return

	var/datum/cyberspace/c = SScyberspace.get_linked_cyber(z)
	if(c.is_destroyed())
		if(LAZYLEN(c.intelligences))
			to_chat(user, FAIL_MSG + " But you swear you [pick("heard panicked screaming","felt something dying","saw everything falling apart")] for a moment .")
		else
			to_chat(user, FAIL_MSG)
		return

	if(!LAZYLEN(mobs))
		START_PROCESSING(SSmachines, src)

	LAZYADD(mobs, user)
	var/mob/living/silicon/ai/AI = new(get_turf(pick(c.exits)), , user)
	user.teleop = AI
	user.mind.transfer_to(AI)

/obj/machinery/cyberjack/Process()
	if(!LAZYLEN(mobs)) //There is nothing to process - move along.
		return PROCESS_KILL

	process_mobs()

/obj/machinery/cyberjack/Destroy()
	process_mobs(TRUE)
	. = ..()

/obj/machinery/cyberjack/proc/process_mobs(var/force_eject = FALSE)
	for(var/mob/M in mobs)
		if(M.mind) //We somehow have been ejected already. Time to move on.
			LAZYREMOVE(mobs, M)
		else if(force_eject || M.stat || !powered() || !M.Adjacent(src))
			M.teleop.mind.transfer_to(M)
			M.teleop = null
			LAZYREMOVE(mobs, M)

#undef FAIL_MSG