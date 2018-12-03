/mob/living/silicon/ai/shared_nano_interaction()
	if (check_unable(1, 0))
		return STATUS_CLOSE
	return ..()

/mob/living/silicon/ai/default_can_use_topic(var/obj/O)
	. = shared_nano_interaction()
	if(. != STATUS_INTERACTIVE)
		return

	if ((O.cyberfile?.Adjacent(src) && (O.z in cyberspace.connected_zs)) || O.Adjacent(src))
		return STATUS_INTERACTIVE
	return STATUS_CLOSE

/mob/living/silicon/ai/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	..()
	if(message_mode)
		if (ai_radio.disabledAi || stat)
			to_chat(src, SPAN_DANGER("System Error - Transceiver Disabled."))
			return 0
		if(message_mode == "general")
			message_mode = null
		return ai_radio.talk_into(src,message,message_mode,verb,speaking)

/proc/check_for_interception()
	for(var/mob/living/silicon/ai/A in SSmobs.mob_list)
		if(A.intercepts_communication)
			return A

/atom/proc/attack_ai(mob/user as mob)
	return

/mob/living/silicon/ai/UnarmedAttack(atom/A)
	if(!stat && Adjacent(A))
		A.attack_hand(src)