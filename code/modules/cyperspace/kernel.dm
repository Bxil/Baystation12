//No kernels = cyberspace gets deleted.

/obj/cyber/kernel
	name = "Kernel"
	icon_state = "kernel"
	anchored = TRUE //So the AI doesn't gather and hide them all.

/obj/cyber/kernel/Initialize()
	. = ..()
	cyberspace.kernels += src
	name = "[name] #[length(cyberspace.kernels)]"

/obj/cyber/kernel/death()
	set waitfor = FALSE

	animate(src, alpha = 0, time = 17)

	sleep(17) //wait for the death animation to end

	for(var/mob/living/M in cyberspace.intelligences)
		shake_camera(M, 25)
		to_chat(M, SPAN_DANGER("[name] destroyed at [loc]!"))
	qdel(src)

/obj/cyber/kernel/Destroy()
	cyberspace.kernels -= src
	cyberspace.health()
	. = ..()