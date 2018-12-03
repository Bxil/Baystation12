#define TRACKING_POSSIBLE 0
#define TRACKING_NO_COVERAGE 1
#define TRACKING_TERMINATE 2

/proc/InvalidPlayerTurf(turf/T as turf)
	return !(T && T.z in GLOB.using_map.player_levels)

// Used to allow the AI is write in mob names/camera name from the CMD line.
/datum/trackable
	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()
	var/list/cameras = list()

/proc/camera_sort(list/L)
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for (var/i = L.len, i > 0, i--)
		for (var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if (a.c_tag_order != b.c_tag_order)
				if (a.c_tag_order > b.c_tag_order)
					L.Swap(j, j + 1)
			else
				if (sorttext(a.c_tag, b.c_tag) < 0)
					L.Swap(j, j + 1)
	return L


mob/living/proc/near_camera()
	if (!isturf(loc))
		return 0
	else if(!cameranet.is_visible(src))
		return 0
	return 1

/mob/living/proc/tracking_status()
	// Easy checks first.
	var/obj/item/weapon/card/id/id = GetIdCard()
	if(id && id.prevent_tracking())
		return TRACKING_TERMINATE
	if(InvalidPlayerTurf(get_turf(src)))
		return TRACKING_TERMINATE
	if(invisibility >= INVISIBILITY_LEVEL_ONE) //cloaked
		return TRACKING_TERMINATE
	if(digitalcamo)
		return TRACKING_TERMINATE
	if(istype(loc,/obj/effect/dummy))
		return TRACKING_TERMINATE

	 // Now, are they viewable by a camera? (This is last because it's the most intensive check)
	return near_camera() ? TRACKING_POSSIBLE : TRACKING_NO_COVERAGE

/mob/living/silicon/robot/tracking_status()
	. = ..()
	if(. == TRACKING_NO_COVERAGE)
		return camera && camera.can_use() ? TRACKING_POSSIBLE : TRACKING_NO_COVERAGE

/mob/living/carbon/human/tracking_status()
	if(is_cloaked())
		. = TRACKING_TERMINATE
	else
		. = ..()

	if(. == TRACKING_TERMINATE)
		return

	if(. == TRACKING_NO_COVERAGE)
		var/turf/T = get_turf(src)
		if(T && (T.z in GLOB.using_map.station_levels) && hassensorlevel(src, SUIT_SENSOR_TRACKING))
			return TRACKING_POSSIBLE

mob/living/proc/tracking_initiated()

mob/living/silicon/robot/tracking_initiated()
	tracking_entities++
	if(tracking_entities == 1 && has_zeroth_law())
		to_chat(src, "<span class='warning'>Internal camera is currently being accessed.</span>")

mob/living/proc/tracking_cancelled()

mob/living/silicon/robot/tracking_cancelled()
	tracking_entities--
	if(!tracking_entities && has_zeroth_law())
		to_chat(src, "<span class='notice'>Internal camera is no longer being accessed.</span>")


#undef TRACKING_POSSIBLE
#undef TRACKING_NO_COVERAGE
#undef TRACKING_TERMINATE
