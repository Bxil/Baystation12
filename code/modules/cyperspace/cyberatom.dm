/atom/movable
	//movable_flags = MOVABLE_FLAG_CYBERSPACE - add this flag to make the atom have cyberspace presence
	var/cyber_icon = 'icons/obj/cyberspace.dmi'
	var/cyber_icon_state = "lock" //how do we appear on cyberspace files?
	var/cybertype = /obj/cyber/file
	var/obj/cyber/file/cyberfile

/atom/movable/Initialize()
	. = ..()
	if((movable_flags & MOVABLE_FLAG_CYBERSPACE) && config.cyberspace)
		if(!SScyberspace.initialized || !create_cyber_file())
			LAZYADD(SScyberspace.init_queue, src)

/atom/movable/Destroy()
	if(cyberfile)
		cyberfile.death()
		cyberfile = null
	. = ..()

/atom/movable/proc/create_cyber_file()
	if(cyberfile)
		return FALSE

	var/turf/turf = get_turf(src)
	if(!turf)
		return FALSE

	var/datum/cyberspace/C = SScyberspace.get_linked_cyber(turf.z)
	if(!C || C.is_destroyed())
		return FALSE

	cyberfile = new cybertype(C.pick_floor(), src)
	return TRUE

//Need to do something snowflakey? Override this.
/atom/movable/proc/virtual_act(mob/user)
	attack_ai(user)