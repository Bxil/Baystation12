//Realspace presence in cyberspace.

/obj/cyber/file
	name = "cyberfile"
	icon_state = "file"
	var/atom/movable/real

/obj/cyber/file/examine(mob/user)
	to_chat(user, "\icon[src]\icon[real] That's [name].")

/obj/cyber/file/Initialize(mapload, real)
	. = ..()

	src.real = real
	overlays += src.real.cyber_icon_state
	update()
	GLOB.name_set_event.register(real, src, .proc/update)
	GLOB.moved_event.register(real, src, .proc/update)
	cyberspace.files += cyberfile
	for(var/mob/living/M in cyberspace.intelligences)
		to_chat(M, "[name] created at [loc].")

	var/turf/T = get_turf(src)
	if(!T)
		return

	for(var/obj/cyber/C in T)
		if(istype(C, /obj/cyber/folder))
			var/obj/cyber/folder/F = C
			F.store(src)
			break
		if(istype(C, /obj/cyber/file) && C != src)
			new/obj/cyber/folder(T)
			break

/obj/cyber/file/Destroy()
	GLOB.name_set_event.unregister(real, src, .proc/update)
	GLOB.moved_event.unregister(real, src, .proc/update)
	real = null
	. = ..()

/obj/cyber/file/attack_hand(mob/user)
	var/turf/turf = get_turf(real)
	if(turf?.z in cyberspace.connected_zs)
		real.virtual_act(user)
	else
		to_chat(user, SPAN_NOTICE("Out of range of localized CyberNet.<br>Memory reserved for potentional return."))

/obj/cyber/file/Crossed(obj/cyber/folder/F)
	if(!istype(F))
		return
	F.store(src)

/obj/cyber/file/proc/update()
	var/atomname = replacetext(real.name, "\improper ", "")
	var/turf/turf = get_turf(real)
	if(!(turf?.z in cyberspace.connected_zs))
		overlays += "out-of-range"
		name = "[initial(name)] ([atomname] - OUT OF RANGE)"
		return

	overlays -= "out-of-range"

	var/area/A = get_area(real)
	if(A)
		var/areaname = replacetext(A.name, "\improper ", "")
		if(findtext(A.name, real.name))
			name = "[initial(name)] ([areaname])"
		else if(findtext(real.name, A.name))
			name = "[initial(name)] ([atomname])"
		else
			name = "[initial(name)] ([atomname] - [areaname])"
	else
		name = "[initial(name)] ([real.name])"

/obj/cyber/file/death()
	var/turf/turf = get_turf(real)
	if(turf?.z in cyberspace.connected_zs)
		real.emp_act(1)

	var/obj/cyber/trash/T = new(get_turf(src))
	T.name = "deleted [name]"
	T.overlays += real.cyber_icon_state
	..()