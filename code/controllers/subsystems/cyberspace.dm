SUBSYSTEM_DEF(cyberspace)
	name = "Cyberspace"
	flags = SS_NO_FIRE

	var/list/cyber_zs //Values are /datum/cyberspace.

	var/list/init_queue //Machines yet to be put into cyberspace.

/datum/controller/subsystem/cyberspace/Initialize()
	if(!config.cyberspace)
		return

	setup()

	. = ..()

/datum/controller/subsystem/cyberspace/proc/setup()
	//-------RELAY TELECOMMS TO CYBERSPACE-----
	//Machines made during the round will automatically do this themselves.
	for(var/obj/machinery/telecomms/T in telecomms_list)
		var/datum/cyberspace/C = get_linked_cyber(T?.z)
		if(C)
			T.listening_levels += C.z

	//-------INIT CYBERSTUFF-------
	var/amount = 0
	for(var/atom/movable/A in init_queue)
		if(A.create_cyber_file())
			amount++
			LAZYREMOVE(init_queue, A)
			CHECK_TICK

	testing("Initialized [amount] cyberfiles in [LAZYLEN(cyber_zs)] cyberspaces!")

/datum/controller/subsystem/cyberspace/proc/get_linked_cyber(z)
	for(var/datum/cyberspace/C in cyber_zs)
		if(z in C.connected_zs)
			return C
	return null