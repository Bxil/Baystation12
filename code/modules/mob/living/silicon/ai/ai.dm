/mob/living/silicon/ai
	name = "Artificial Intelligence"
	icon = 'icons/obj/cyberspace.dmi'
	icon_state = "intelligence"
	health = 255
	maxHealth = 255
	mob_flags = MOB_FLAG_NO_SHADOW
	pixel_z = 0
	shouldnt_see = list(/obj/effect/rune)
	anchored = FALSE
	var/icon_dead = "intelligence-dead"
	var/datum/cyberspace/cyberspace //Let's point back to our cyberspace.

	var/list/connected_robots = list()
	var/last_announcement = ""
	var/message_cooldown = 0
	var/control_disabled = FALSE
	var/datum/announcement/priority/announcement
	var/emergency_message_cooldown = FALSE
	var/carded

	var/intercepts_communication = FALSE	// Whether the AI intercepts fax and emergency transmission communications.

	silicon_camera = /obj/item/device/camera/siliconcam/ai_camera
	silicon_radio = /obj/item/device/radio/headset/heads/ai_integrated
	var/obj/item/device/radio/headset/heads/ai_integrated/ai_radio
	var/obj/item/device/multitool/aiMulti
	var/multitool_mode = FALSE

	//Realworld stuff
	var/mob/living/real //Do we have a realspace counterpart and if so who is it?
	var/braindamage = 0 //How much brain damage to deal to the real after leaving.

	var/list/nodes //Number of owned nodes contribute to our processing power.

	var/global/list/ai_verbs_default = list(
		/mob/living/silicon/ai/proc/ai_announcement,
		/mob/living/silicon/ai/proc/ai_call_shuttle,
		/mob/living/silicon/ai/proc/ai_emergency_message,
		/mob/living/silicon/ai/proc/ai_roster,
		/mob/living/silicon/ai/proc/ai_statuschange,
		/mob/living/silicon/ai/proc/ai_checklaws,
		/mob/living/silicon/ai/proc/control_integrated_radio,
		/mob/living/silicon/ai/proc/sensor_mode,
		/mob/living/silicon/ai/proc/show_laws_verb,
		/mob/living/silicon/ai/proc/multitool_mode
	)

	//In case we entered from real space, let's remove these.
	var/global/list/ai_verbs_real_blacklist = list(
		/mob/living/silicon/ai/proc/ai_checklaws,
		/mob/living/silicon/ai/proc/show_laws_verb
	)

	var/global/list/custom_ai_icons_by_ckey_and_name

/mob/living/silicon/ai/Initialize(mapload, datum/ai_laws/L, _real)
	announcement = new()
	announcement.title = "A.I. Announcement"
	announcement.announcement_type = "A.I. Announcement"
	announcement.newscast = TRUE

	real = _real

	if(real)
		SetName(ckeyEx(real.name))
	else
		var/list/possibleNames = GLOB.ai_names

		var/pickedName = null
		while(!pickedName)
			pickedName = pick(GLOB.ai_names)
			for (var/mob/living/silicon/ai/A in GLOB.silicon_mob_list)
				if (A.real_name == pickedName && possibleNames.len > 1) //fixing the theoretically possible infinite loop
					possibleNames -= pickedName
					pickedName = null

		fully_replace_character_name(pickedName)

	if(istype(L))
		laws = L

	aiMulti = new(src)

	if (istype(loc, /turf))
		add_ai_verbs(src)

	//Languages
	add_language(LANGUAGE_ROBOT_GLOBAL, 1)
	add_language(LANGUAGE_EAL, 1)
	add_language(LANGUAGE_HUMAN_EURO, 1)
	add_language(LANGUAGE_HUMAN_ARABIC, 1)
	add_language(LANGUAGE_HUMAN_CHINESE, 1)
	add_language(LANGUAGE_HUMAN_IBERIAN, 1)
	add_language(LANGUAGE_HUMAN_INDIAN, 1)
	add_language(LANGUAGE_HUMAN_RUSSIAN, 1)
	add_language(LANGUAGE_HUMAN_SELENIAN, 1)
	add_language(LANGUAGE_UNATHI_SINTA, 1)
	add_language(LANGUAGE_SKRELLIAN, 1)
	add_language(LANGUAGE_GUTTER, 1)
	add_language(LANGUAGE_SPACER, 1)
	add_language(LANGUAGE_SIGN, 0)

	hud_list[HEALTH_HUD]      = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD]      = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[LIFE_HUD] 		  = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[ID_HUD]          = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[WANTED_HUD]      = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")

	for(var/datum/cyberspace/C in SScyberspace.cyber_zs)
		if(C.z == z)
			cyberspace = C
			break

	LAZYADD(cyberspace.intelligences, src)

	for(var/A in subtypesof(/obj/item/ai_action))
		new A(src)

	health_color()

	ai_radio = new silicon_radio(src)
	ai_radio.myAi = src

	. = ..()

/mob/living/silicon/ai/proc/on_mob_init()
	to_chat(src, "<B>You are playing the [station_name()]'s AI. The AI does not exist on the physical plane, but can interact with many machines on board the installation.</B>")
	to_chat(src, "Use say [get_language_prefix()]b to speak to your cyborgs through binary.")
	to_chat(src, "For department channels, use the following say commands:")

	var/radio_text = ""
	for(var/i = 1 to silicon_radio.channels.len)
		var/channel = silicon_radio.channels[i]
		var/key = get_radio_key_from_channel(channel)
		radio_text += "[key] - [channel]"
		if(i != silicon_radio.channels.len)
			radio_text += ", "

	to_chat(src, radio_text)

	show_laws()

	job = "AI"

/mob/living/silicon/ai/Destroy()
	for(var/robot in connected_robots)
		var/mob/living/silicon/robot/S = robot
		S.connected_ai = null
	connected_robots.Cut()

	ai_radio = null

	QDEL_NULL(announcement)
	QDEL_NULL(aiMulti)

	LAZYREMOVE(cyberspace.intelligences, src)
	cyberspace = null
	nodes = null
	if(real)
		mind.transfer_to(real)
		real.adjustBrainLoss(braindamage)
		real.teleop = null
		real = null

	..()

/mob/living/silicon/ai/on_update_icon()
	if(stat == DEAD)
		icon_state = icon_dead

/mob/living/silicon/ai/proc/add_ai_verbs()
	verbs |= ai_verbs_default
	verbs -= /mob/living/verb/ghost
	if(real)
		verbs -= ai_verbs_real_blacklist
		silicon_subsystems -= /datum/nano_module/law_manager

/mob/living/silicon/ai/proc/remove_ai_verbs()
	verbs -= ai_verbs_default
	verbs += /mob/living/verb/ghost

/mob/living/silicon/ai/proc/health_color()
	color = rgb(initial(health) - health,health,0)

/mob/living/silicon/ai/proc/get_processing_power()
	return LAZYLEN(nodes)

/mob/living/silicon/ai/fully_replace_character_name(pickedName as text)
	..()
	announcement.announcer = pickedName
	setup_icon()

/mob/living/silicon/ai/proc/setup_icon()
	if(LAZYACCESS(custom_ai_icons_by_ckey_and_name, "[ckey][real_name]"))
		return
	var/list/custom_icons = list()
	LAZYSET(custom_ai_icons_by_ckey_and_name, "[ckey][real_name]", custom_icons)

	var/file = file2text(CUSTOM_ITEM_SYNTH_CONFIG)
	var/lines = splittext(file, "\n")

	var/custom_icon_states = icon_states(CUSTOM_ITEM_SYNTH)

	for(var/line in lines)
	// split & clean up
		var/list/Entry = splittext(line, ":")
		for(var/i = 1 to Entry.len)
			Entry[i] = trim(Entry[i])

		if(Entry.len < 2)
			continue
		if(Entry.len == 2) // This is to handle legacy entries
			Entry[++Entry.len] = Entry[1]

		if(Entry[1] == src.ckey && Entry[2] == src.real_name)
			var/alive_icon_state = "[Entry[3]]-ai"
			var/dead_icon_state = "[Entry[3]]-ai-crash"

			if(!(alive_icon_state in custom_icon_states))
				to_chat(src, SPAN_WARNING("Custom display entry found but the icon state '[alive_icon_state]' is missing!"))
				continue

			if(!(dead_icon_state in custom_icon_states))
				dead_icon_state = initial(icon_dead)

			custom_icons += TRUE
			icon_state = alive_icon_state
			icon_dead = dead_icon_state
	update_icon()

/mob/living/silicon/ai/proc/wipe()
	// Guard against misclicks, this isn't the sort of thing we want happening accidentally
	if(alert("WARNING: This will immediately ghost you, removing your character from the round permanently (similar to cryo and robotic storage). Are you entirely sure you want to do this?",
					"Delete System32?", "No", "No", "Yes") != "Yes")
		return

	if(is_special_character(src))
		log_and_message_admins("removed themselves from the round.")

	// We warned you.
	GLOB.global_announcer.autosay("[src] has been moved to intelligence storage.", "Artificial Intelligence Oversight")

	//Handle job slot/tater cleanup.
	clear_client()