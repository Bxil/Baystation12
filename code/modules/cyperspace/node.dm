/obj/cyber/node
	name = "cybernode"
	icon_state = "node"
	anchored = TRUE
	var/mob/living/silicon/ai/owner

/obj/cyber/node/Initialize()
	. = ..()
	cyberspace.nodes += src

/obj/cyber/node/Destroy()
	LAZYREMOVE(cyberspace.nodes, src)
	if(owner)
		LAZYREMOVE(owner.nodes, src)
		to_chat(owner, SPAN_WARNING("Claimed [src] destroyed at [loc]!"))
		owner = null
	. = ..()

/obj/cyber/node/examine(mob/user)
	. = ..()
	to_chat(user, "[owner ? "<b>OWNER</b>: [owner]" : "UNCLAIMED."]")

/obj/cyber/node/attack_hand(mob/living/silicon/ai/user)
	if(owner == user)
		if(alert("Are you sure you want to release \the [src]?","Release [src]", "No", "No", "Yes") != "Yes")
			return
		user.visible_message("[user] releases \the [src].", "You release \the [src].")
		remove_owner()
	else if(owner)
		to_chat(user, SPAN_NOTICE("Access to this [src] is restricted."))
	else
		user.visible_message("[user] begins claiming \the [src].", "You begin claiming \the [src].")
		overlays += "node-claiming"
		if(!do_after(user, 20 SECONDS, src))
			overlays.Cut()
			return
		overlays.Cut()
		overlays += "node-claimed"
		owner = user
		user.visible_message("[user] claims \the [src]!", "You claim \the [src]!")
		LAZYADD(owner.nodes, src)

/obj/cyber/node/proc/remove_owner()
	overlays.Cut()
	LAZYREMOVE(owner.nodes, src)
	owner = null

/obj/cyber/node/death()
	overlays.Cut()
	if(owner)
		to_chat(owner, SPAN_WARNING("Claimed [src] has been killed at [loc]!"))
		remove_owner()