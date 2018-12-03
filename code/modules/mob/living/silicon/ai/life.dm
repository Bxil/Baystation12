/mob/living/silicon/ai/Life()
	if(stat == DEAD)
		return
	health_color()

	if(health < 1)
		death()

	//Ohoho! Would you look at that, a realspace person in cyberspace? Let's punish them.
	if(real)
		var/skill = real.get_skill_value(SKILL_COMPUTER)
		if(rand(0, skill * 10) == 0)
			braindamage++

		//Uh oh. We died!
		if(real.stat == DEAD)
			health = min(0, health - (1 + SKILL_PROF - real.get_skill_value(SKILL_COMPUTER)))

	handle_actions()
	process_queued_alarms()
	handle_regular_hud_updates()

	if(eyeobj)
		switch(sensor_mode)
			if (1/*SEC_HUD*/)
				process_sec_hud(src,0,eyeobj)
			if (2/*MED_HUD*/)
				process_med_hud(src,0,eyeobj)
