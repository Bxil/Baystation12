/obj/item/ai_action
	action_button_name = "Invalid AI action"

/obj/item/ai_action/attack_self(mob/user)
	to_chat(user, "Unexpected behavior. Please make an issue report.")
	CRASH("[type]'s attack_self is unset.")



/obj/item/ai_action/firewall
	action_button_name = "Toggle Firewall"

/obj/item/ai_action/firewall/attack_self(mob/living/silicon/ai/user)
	