
/obj/item/weapon/gun
	//Fire delay is modified by this, then used to determine the time after last firing to count as the weapon
	//recovering from all the overheat it has accumulated
	//Example: fire_delay 10 with a fullclear_mod of 2 means the player must wait for 20 before firing for the heat to
	//be cleared.
	var/overheat_fullclear_delay = 3 SECONDS
	var/overheat_fullclear_at = 0
	var/overheat_sfx = null
	var/overheat_capacity = -1 //If set above -1, a weapon will decrement this counter per-shot until it hits 0.
	var/heat_current = 0
	var/datum/progressbar/heat_bar
	var/heat_per_shot = 1

/obj/item/weapon/gun/process()
	world << "[src.type]/process()"

	if(process_heat())
		return

	return PROCESS_KILL

/obj/item/weapon/gun/proc/process_heat()
	world << "/obj/item/weapon/gun/proc/process_heat()"
	if(heat_current > 0)
		//cool down slightly
		add_heat(-1)

		//are we overheated?
		if(overheat_fullclear_at)
			if(heat_current <= 0)
				clear_overheat()
				color = initial(color)
			else
				//flash red and white
				if(color == "#ff0000")
					color = "#ffff00"
				else
					color = "#ff0000"

		//continue processing
		return 1

	//stop processing
	return 0

/obj/item/weapon/gun/proc/add_heat(var/new_val)
	world << "/obj/item/weapon/gun/proc/add_heat([new_val])"
	heat_current = heat_current + new_val

	if(heat_current > 0)
		if(!heat_bar)
			heat_bar = new (src.loc, overheat_capacity, src)
			GLOB.processing_objects.Add(src)
		heat_bar.update(heat_current)

		if(heat_current >= overheat_capacity)
			do_overheat()
	else
		qdel(heat_bar)
		heat_bar = null
		GLOB.processing_objects.Remove(src)

/obj/item/weapon/gun/proc/do_overheat()
	overheat_fullclear_at = world.time + overheat_fullclear_delay + overheat_capacity * 0.5 SECONDS
	var/mob/M = src.loc
	visible_message("\icon[src] <span class = 'warning'>[M]'s [src] overheats!</span>",\
		"\icon[src] <span class = 'warning'>Your [src] overheats!</span>",)
	if(overheat_sfx)
		playsound(M,overheat_sfx,100,1)

/obj/item/weapon/gun/proc/clear_overheat()
	overheat_fullclear_at = 0
	heat_current = 0
	if(heat_bar)
		qdel(heat_bar)
		heat_bar = null

/obj/item/weapon/gun/proc/check_overheat()
	if(overheat_fullclear_at)
		to_chat(src.loc,"\icon[src] <span class='warning'>[src] clunks as you pull the trigger, \
			it has overheated and needs to ventilate heat...</span>")
		return 1
	return 0
