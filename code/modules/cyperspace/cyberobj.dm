/obj/cyber
	name = "cyberspace error"
	icon = 'icons/obj/cyberspace.dmi'
	var/datum/cyberspace/cyberspace //Let's point to our cyberspace.
	var/health = 255

/obj/cyber/Initialize()
	. = ..()

	for(var/datum/cyberspace/C in SScyberspace.cyber_zs)
		if(C.z == z)
			cyberspace = C
			break

	health_color()

/obj/cyber/Destroy()
	cyberspace = null
	. = ..()

/obj/cyber/proc/health_color()
	color = rgb(initial(health) - health,health,0)

/obj/cyber/proc/damage(amount)
	if(health < 1)
		return
	health -= amount
	if(health < 1)
		death()
	health_color()

/obj/cyber/proc/death()
	qdel(src)