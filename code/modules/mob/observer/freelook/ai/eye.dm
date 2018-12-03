// AI EYE
//
// A mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.

/mob/observer/eye/cameranet
	name = "Inactive Camera Eye"
	name_sufix = "Camera Eye"

/mob/observer/eye/cameranet/New()
	..()
	visualnet = cameranet