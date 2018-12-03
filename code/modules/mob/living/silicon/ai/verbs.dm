#define AI_CHECK_WIRELESS 1
#define AI_CHECK_RADIO 2

/mob/living/silicon/ai/proc/ai_roster()
	set category = "Silicon Commands"
	set name = "Show Crew Manifest"
	show_station_manifest()

/mob/living/silicon/ai/proc/ai_announcement()
	set category = "Silicon Commands"
	set name = "Make Announcement"

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	if(message_cooldown)
		to_chat(src, "Please allow one minute to pass between announcements.")
		return
	var/input = input(usr, "Please write a message to announce to the [station_name()] crew.", "A.I. Announcement")
	if(!input)
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	announcement.Announce(input)
	message_cooldown = TRUE
	spawn(600)//One minute cooldown
		message_cooldown = FALSE

/mob/living/silicon/ai/proc/ai_call_shuttle()
	set category = "Silicon Commands"
	set name = "Call Evacuation"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/confirm = alert("Are you sure you want to evacuate?", "Confirm Evacuation", "Yes", "No")

	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(confirm == "Yes")
		call_shuttle_proc(src)

	post_status("shuttle")

/mob/living/silicon/ai/proc/ai_recall_shuttle()
	set category = "Silicon Commands"
	set name = "Cancel Evacuation"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/confirm = alert("Are you sure you want to cancel the evacuation?", "Confirm Cancel", "Yes", "No")
	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(confirm == "Yes")
		cancel_call_proc(src)

/mob/living/silicon/ai/proc/ai_emergency_message()
	set category = "Silicon Commands"
	set name = "Send Emergency Message"

	if(check_unable(AI_CHECK_WIRELESS))
		return
	if(!is_relay_online())
		to_chat(usr, SPAN_WARNING("No Emergency Bluespace Relay detected. Unable to transmit message."))
		return
	if(emergency_message_cooldown)
		to_chat(usr, SPAN_WARNING("Arrays recycling. Please stand by."))
		return
	var/input = sanitize(input(usr, "Please choose a message to transmit to [GLOB.using_map.boss_short] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response. There is a 30 second delay before you may send another message, be clear, full and concise.", "To abort, send an empty message.", ""))
	if(!input)
		return
	Centcomm_announce(input, usr)
	to_chat(usr, SPAN_BOLD("Message transmitted."))
	log_say("[key_name(usr)] has made an IA [GLOB.using_map.boss_short] announcement: [input]")
	emergency_message_cooldown = 1
	spawn(300)
		emergency_message_cooldown = 0

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "Silicon Commands"
	set name = "AI Status"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	set_ai_status_displays(src)
	return

/mob/living/silicon/ai/proc/control_integrated_radio()
	set name = "Radio Settings"
	set desc = "Allows you to change settings of your radio."
	set category = "Silicon Commands"

	if(check_unable(AI_CHECK_RADIO))
		return

	to_chat(src, "Accessing Subspace Transceiver control...")
	if (src.silicon_radio)
		src.silicon_radio.interact(src)

/mob/living/silicon/ai/proc/sensor_mode()
	set name = "Set Sensor Augmentation"
	set category = "Silicon Commands"
	set desc = "Augment visual feed with internal sensor overlays"
	toggle_sensor_mode()

/mob/living/silicon/ai/proc/check_unable(var/flags = 0, var/feedback = 1)
	if(stat == DEAD)
		if(feedback) to_chat(src, SPAN_WARNING("You are dead!"))
		return 1

	if((flags & AI_CHECK_WIRELESS) && src.control_disabled)
		if(feedback) to_chat(src, SPAN_WARNING("Wireless control is disabled!"))
		return 1
	if((flags & AI_CHECK_RADIO) && src.ai_radio.disabledAi)
		if(feedback) to_chat(src, SPAN_WARNING("System Error - Transceiver Disabled!"))
		return 1
	return 0

/mob/living/silicon/ai/proc/is_in_cyberspace()
	return istype(loc, /turf)

// Pass lying down or getting up to our pet human, if we're in a rig.
/mob/living/silicon/ai/lay_down()
	set name = "Rest"
	set category = "IC"

	resting = 0
	var/obj/item/weapon/rig/rig = src.get_rig()
	if(rig)
		rig.force_rest(src)

/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "Silicon Commands"
	set name = "Show Laws"
	show_laws()

/mob/living/silicon/ai/show_laws(everyone = FALSE)
	var/who

	if (everyone)
		who = world
	else
		who = src
		to_chat(who, "<b>Obey these laws:</b>")

	src.laws_sanity_check()
	src.laws.show_laws(who)

/mob/living/silicon/ai/add_ion_law(law)
	..()
	for(var/mob/living/silicon/robot/R in GLOB.silicon_mob_list)
		if(R.lawupdate && (R.connected_ai == src))
			R.show_laws()

/mob/living/silicon/ai/proc/ai_checklaws()
	set category = "Silicon Commands"
	set name = "State Laws"
	open_subsystem(/datum/nano_module/law_manager)

/mob/living/silicon/ai/proc/multitool_mode()
	set name = "Toggle Multitool Mode"
	set category = "Silicon Commands"

	multitool_mode = !multitool_mode
	to_chat(src, SPAN_NOTICE("Multitool mode: [multitool_mode ? "E" : "Dise"]ngaged"))

#undef AI_CHECK_WIRELESS
#undef AI_CHECK_RADIO