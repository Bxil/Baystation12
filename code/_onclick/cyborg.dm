/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(var/atom/A, var/params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(istype(loc, /mob/living/exosuit) && !(A in src.contents))
		var/mob/living/exosuit/M = loc
		return M.ClickOn(A, params, src)

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(incapacitated())
		return

	if(!canClick())
		return

	face_atom(A) // change direction to face what you clicked on

	if(silicon_camera.in_camera_mode)
		silicon_camera.camera_mode_off()
		if(is_component_functioning("camera"))
			silicon_camera.captureimage(A, usr)
		else
			to_chat(src, "<span class='userdanger'>Your camera isn't functional.</span>")
		return

	/*
	cyborg restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
		return
	*/

	var/obj/item/W = get_active_hand()

	// Cyborgs have no range-checking unless there is item use
	if(!W)
		A.add_hiddenprint(src)
		A.attack_robot(src)
		return

	// buckled cannot prevent machine interlinking but stops arm movement
	if( buckled )
		return

	if(W == A)

		W.attack_self(src)
		return

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
	if(A == loc || (A in loc) || (A in contents))
		// No adjacency checks

		var/resolved = W.resolve_attackby(A, src, params)
		if(!resolved && A && W)
			W.afterattack(A, src, 1, params) // 1 indicates adjacency
		return

	if(!isturf(loc))
		return

	var/sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		if(A.Adjacent(src)) // see adjacent.dm

			var/resolved = W.resolve_attackby(A, src, params)
			if(!resolved && A && W)
				W.afterattack(A, src, 1, params) // 1 indicates adjacency
			return
		else
			W.afterattack(A, src, 0, params)
			return
	return

//Middle click cycles through selected modules.
/mob/living/silicon/robot/MiddleClickOn(var/atom/A)
	cycle_modules()
	return

//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs
/mob/living/silicon/robot/CtrlShiftClickOn(var/atom/A)
	A.BorgCtrlShiftClick(src)

/mob/living/silicon/robot/ShiftClickOn(var/atom/A)
	A.BorgShiftClick(src)

/mob/living/silicon/robot/CtrlClickOn(var/atom/A)
	return A.BorgCtrlClick(src)

/mob/living/silicon/robot/AltClickOn(var/atom/A)
	A.BorgAltClick(src)

/atom/proc/BorgCtrlShiftClick(var/mob/living/silicon/robot/user) //forward to human click if not overriden
	CtrlShiftClick(user)

/atom/proc/BorgShiftClick(var/mob/living/silicon/robot/user) //forward to human click if not overriden
	ShiftClick(user)

/atom/proc/BorgCtrlClick(var/mob/living/silicon/robot/user) //forward to human click if not overriden
	return CtrlClick(user)

/obj/machinery/door/airlock/BorgCtrlClick()
	if(usr.incapacitated())
		return
	if(!electrified_until)
		// permanent shock
		Topic(src, list("command"="electrify_permanently", "activate" = "1"))
	else
		// disable/6 is not in Topic; disable/5 disables both temporary and permanent shock
		Topic(src, list("command"="electrify_permanently", "activate" = "0"))
	return 1

/obj/machinery/power/apc/BorgCtrlClick()
	if(usr.incapacitated())
		return FALSE
	Topic(src, list("breaker"="1"))
	return TRUE

/obj/machinery/turretid/BorgCtrlClick()
	if(usr.incapacitated())
		return FALSE
	Topic(src, list("command"="enable", "value"="[!enabled]"))
	return TRUE

/atom/proc/BorgAltClick(var/mob/living/silicon/robot/user)
	AltClick(user)
	return

/obj/machinery/door/airlock/BorgAltClick()  // Electrifies doors.
	if(usr.incapacitated())
		return
	if(!electrified_until)
		// permanent shock
		Topic(src, list("command"="electrify_permanently", "activate" = "1"))
	else
		// disable/6 is not in Topic; disable/5 disables both temporary and permanent shock
		Topic(src, list("command"="electrify_permanently", "activate" = "0"))
	return 1

/obj/machinery/turretid/BorgAltClick() //toggles lethal on turrets
	if(usr.incapacitated())
		return
	Topic(src, list("command"="lethal", "value"="[!lethal]"))
	return 1

/obj/machinery/atmospherics/binary/pump/BorgAltClick()
	return AltClick()

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A)
	A.attack_robot(src)

/mob/living/silicon/robot/RangedAttack(atom/A, var/params)
	A.attack_robot(src)
	return TRUE

/atom/proc/attack_robot(mob/user as mob)
	attack_ai(user)
	return
