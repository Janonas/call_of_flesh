 /**
  * tgui state: default_state
  *
  * Checks a number of things -- mostly physical distance for humans and view for robots.
 **/

/var/global/datum/ui_state/default/default_state = new()

/datum/ui_state/default/can_use_topic(atom/movable/src_object, mob/user)
	return user.default_can_use_topic(src_object) // Call the individual mob-overriden procs.

/mob/proc/default_can_use_topic(atom/movable/src_object)
	return UI_CLOSE // Don't allow interaction by default.

/mob/living/default_can_use_topic(atom/movable/src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		. = min(., shared_living_ui_distance(src_object)) // Check the distance...
	if(. == UI_INTERACTIVE) // Non-human living mobs can only look, not touch.
		return UI_UPDATE

/mob/living/carbon/human/default_can_use_topic(atom/movable/src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		. = min(., shared_living_ui_distance(src_object)) // Check the distance...
		// Derp a bit if we have brain loss.
		if(prob(getBrainLoss()))
			return UI_UPDATE

/mob/living/silicon/robot/default_can_use_topic(atom/movable/src_object)
	. = shared_ui_interaction(src_object)
	if(. <= UI_DISABLED)
		return

	// Robots can interact with anything they can see.
	if(get_dist(src, src_object) <= src.client.view)
		return UI_INTERACTIVE
	return UI_DISABLED // Otherwise they can keep the UI open.

/mob/living/silicon/ai/default_can_use_topic(atom/movable/src_object)
	. = shared_ui_interaction(src_object)
	if(. < UI_INTERACTIVE)
		return

	// The AI can interact with anything it can see nearby, or with cameras.
	if((get_dist(src, src_object) <= src.client.view) || cameranet.checkTurfVis(get_turf_pixel(src_object)))
		return UI_INTERACTIVE
	return UI_CLOSE

/mob/living/simple_animal/drone/default_can_use_topic(atom/movable/src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		. = min(., shared_living_ui_distance(src_object)) // Drones can only use things they're near.

/mob/living/silicon/pai/default_can_use_topic(atom/movable/src_object)
	// pAIs can only use themselves and the owner's radio.
	if((src_object == src || src_object == radio) && !stat)
		return UI_INTERACTIVE
	else
		return ..()
