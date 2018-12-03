/datum/cyberspace
	var/list/connected_zs //We receive files from these

	var/z //Our z-level

	var/width
	var/height
	var/mwidth = 100
	var/mheight = 100

	var/area/cyberspace/area

	var/list/files = list() //Machines that exist both in real- and cyberspace.
	var/list/turfs = list()

	//This is the only list here that is lazy, because in theory the others should be filled as long as this datum exists in any meaningful way.
	var/list/intelligences

	var/list/nodes = list()
	var/list/exits = list()
	var/starting_exits = 10
	var/list/kernels = list()
	var/starting_kernels = 5

	var/destruction_ratio = 50

/datum/cyberspace/New(list/connected_zs)
	if(!config.cyberspace)
		return

	src.connected_zs = connected_zs
	create_z(connected_zs)

/datum/cyberspace/proc/create_z()
	set waitfor = FALSE

	LAZYADD(SScyberspace.cyber_zs, src)

	z = ++world.maxz

	//-------GENERATE CYBERSPACE-----
	area = new()
	area.name = "cyberspace #[z]"

	mwidth = min(mwidth, world.maxx)
	mheight = min(mheight, world.maxy)

	width = mwidth - mwidth % CYBERSIZE + 1
	height = mheight - mheight % CYBERSIZE + 1

	//Set up the area
	for(var/i in 1 to width)
		for(var/j in 1 to height)
			var/turf/T = locate(i, j, z)
			area.contents += T
			turfs += T
			CHECK_TICK

	//Build wall columns.
	for(var/i in 1 to width step CYBERSIZE)
		for(var/j in 1 to height)
			var/turf/T = locate(i, j, z)
			T.ChangeTurf(/turf/unsimulated/cyber/wall)
			CHECK_TICK

	//Build wall rows.
	for(var/i in 1 to width)
		for(var/j in 1 to height step CYBERSIZE)
			var/turf/T = locate(i, j, z)
			T.ChangeTurf(/turf/unsimulated/cyber/wall)
			CHECK_TICK

	//Make the room and place a node in the center
	for(var/i in 1 + round(CYBERSIZE / 2) to width step CYBERSIZE)
		for(var/j in 1 + round(CYBERSIZE / 2) to height step CYBERSIZE)
			var/turf/T = locate(i, j, z)
			var/datum/map_template/M = SSmapping.cyber_templates[pick(SSmapping.cyber_templates)]
			M.load(T, TRUE)
			new/obj/cyber/node(T)
			CHECK_TICK

	//Make doors in columns.
	for(var/i in 1 + round(CYBERSIZE / 2) to width step CYBERSIZE)
		for(var/j in 1 to height step CYBERSIZE)
			var/turf/T = locate(i, j, z)
			if(is_border(T))
				continue
			T.ChangeTurf(/turf/unsimulated/cyber/floor)
			CHECK_TICK

	//Make doors in rows.
	for(var/i in 1 to width step CYBERSIZE)
		for(var/j in 1 + round(CYBERSIZE / 2) to height step CYBERSIZE)
			var/turf/T = locate(i, j, z)
			if(is_border(T))
				continue
			T.ChangeTurf(/turf/unsimulated/cyber/floor)
			CHECK_TICK

	for(var/i in 1 to starting_kernels)
		new/obj/cyber/kernel(pick_floor())

	for(var/i in 1 to starting_exits)
		new/obj/cyber/exit(pick_floor())

	SScyberspace.setup()

/datum/cyberspace/proc/pick_floor()
	var/turf/unsimulated/cyber/floor/F = null
	var/tries = 0
	while(tries < 100 && (!istype(F) || !can_place_file(F)))
		F = pick(turfs)
		tries++
	return F

/datum/cyberspace/proc/can_place_file(turf/T)
	for(var/obj/cyber/O in T)
		if(!istype(O, /obj/cyber/file) && !istype(O, /obj/cyber/folder))
			return FALSE
	return TRUE

/datum/cyberspace/proc/health()
	set waitfor = FALSE

	if(is_destroyed())
		destroy_cyberspace()
		return
	var/new_color = rgb((length(kernels) * 255 / starting_kernels - 255) * -1,length(kernels) * 255 / starting_kernels,0)
	for(var/turf/T in turfs)
		animate(T, color = new_color, time = 20)
		CHECK_TICK

/datum/cyberspace/proc/is_destroyed()
	return length(kernels) == 0

/datum/cyberspace/proc/destroy_cyberspace()
	set waitfor = FALSE

	log_and_message_admins("Destroying [area.name].")

	for(var/mob/living/M in intelligences)
		to_chat(M, SPAN_DANGER(SPAN_BOLD("ERROR! ERROR! CYBERSPACE STRUCTURE COMPROMISED! PLEASE RE-G|\[\\&@{#...")))
		sound_to(M, sound('sound/misc/interference.ogg'))

	var/batch = length(turfs) / destruction_ratio
	while(length(turfs))
		var/list/to_destroy = list()
		for(var/j in 1 to batch)
			var/turf/unsimulated/cyber/floor/T = pick_n_take(turfs)
			if(!T)
				break

			if(is_border(T))
				continue

			if(!istype(T))
				T.ChangeTurf(/turf/unsimulated/cyber/floor)
			T.name = "segmentation fault"
			T.desc = ""
			T.color = COLOR_BLUE
			T.density = FALSE
			T.opacity = FALSE
			to_destroy += T
			T.overlays += icon('icons/obj/cyberspace.dmi', "warning")
		sleep(10 SECONDS)
		for(var/turf/unsimulated/cyber/floor/T in to_destroy)
			T.name = ""
			T.desc = ""
			T.color = COLOR_BLACK
			T.density = TRUE
			T.overlays -= icon('icons/obj/cyberspace.dmi', "warning")
			for(var/atom/movable/AM in T.contents)
				if(!AM.simulated)
					return

				if(istype(AM, /mob/living/silicon/ai))
					to_chat(AM, SPAN_WARNING("<b>INTELLIGENCE ID [AM] ERASED.</b><br>RECOVERY IMPOSSIBLE. GOODBYE."))
				qdel(AM)

	log_and_message_admins("[area.name] destroyed.")

/datum/cyberspace/proc/is_border(turf/T)
	return T.x == 1 || T.y == 1 || T.x == width || T.y == height