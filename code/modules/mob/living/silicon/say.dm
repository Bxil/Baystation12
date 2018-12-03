/mob/living/silicon/say(var/message, var/sanitize = 1)
	return ..(sanitize ? sanitize(message) : message)

/mob/living/silicon/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	log_say("[key_name(src)] : [message]")

/mob/living/silicon/robot/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	..()
	if(message_mode)
		if(!is_component_functioning("radio"))
			to_chat(src, "<span class='warning'>Your radio isn't functional at this time.</span>")
			return 0
		if(message_mode == "general")
			message_mode = null
		return silicon_radio.talk_into(src,message,message_mode,verb,speaking)

/mob/living/silicon/ai/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	..()
	if(message_mode)
		if (ai_radio.disabledAi || stat)
			to_chat(src, "<span class='danger'>System Error - Transceiver Disabled.</span>")
			return 0
		if(message_mode == "general")
			message_mode = null
		return ai_radio.talk_into(src,message,message_mode,verb,speaking)

/mob/living/silicon/pai/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	..()
	if(message_mode)
		if(message_mode == "general")
			message_mode = null
		return silicon_radio.talk_into(src,message,message_mode,verb,speaking)

/mob/living/silicon/say_quote(var/text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return speak_query
	else if (ending == "!")
		return speak_exclamation
	return speak_statement

/mob/living/silicon/say_understands(var/other,var/datum/language/speaking = null)
	//These only pertain to common. Languages are handled by mob/say_understands()
	if (!speaking)
		if (istype(other, /mob/living/carbon))
			return 1
		if (istype(other, /mob/living/silicon))
			return 1
		if (istype(other, /mob/living/carbon/brain))
			return 1
	return ..()