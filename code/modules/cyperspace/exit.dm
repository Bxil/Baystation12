/obj/cyber/exit
	name = "exit"
	icon_state = "exit"
	anchored = TRUE

/obj/cyber/exit/Initialize()
	. = ..()
	cyberspace.exits += src
	name = "[initial(name)] #[length(cyberspace.exits)]"

/obj/cyber/exit/attack_hand(mob/living/silicon/ai/user)
	if(!health)
		return

	if(!user.real)
		//We don't have a realspace counterpart so... it's basically cryoing.
		//(The wipe function offers the option of exiting.)
		user.wipe()
	else
		if(alert("Are you sure you want to return to realspace?","Exit Cyberspace", "No", "No", "Yes") != "Yes")
			return
		qdel(user) //Deleting the AI sends the mind back to the real body.
	user.visible_message("[user] disappates through \the [src].")

/obj/cyber/exit/death()
	health = 0