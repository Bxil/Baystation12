//Multiple realspace presences in cyberspace grouped into a folder.

/obj/cyber/folder
	name = "cyberfolder"
	desc = "unnamed"
	icon_state = "folder"
	var/limit = 10

/obj/cyber/folder/Initialize()
	. = ..()
	maptext = "00"
	maptext_x = 8
	maptext_y = 6
	var/turf/T = get_turf(src)
	if(!T)
		return
	for(var/obj/cyber/file/F in T)
		store(F)

/obj/cyber/folder/examine(mob/user)
	to_chat(user,"<br>\icon[src] <b>FOLDER: [desc]. [length(contents)]/[limit]</b>")
	if(!length(contents))
		to_chat(user, "EMPTY.")
		return
	to_chat(user, "STORED:")
	for(var/obj/cyber/file/F in contents)
		to_chat(user, "\icon[F.real][F.name]")

/obj/cyber/folder/Crossed(obj/cyber/file/F)
	if(!istype(F))
		return
	store(F)

/obj/cyber/folder/proc/store(obj/cyber/file/F)
	if(length(contents) == limit)
		return
	F.forceMove(src)
	maptext = "<code>[length(contents) < 10 ? 0 : ""][length(contents)]</code>"

/obj/cyber/folder/death()
	for(var/obj/cyber/file/F in contents)
		F.death()
	..()