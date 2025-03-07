/mob/living/var/pain_shock_stage = 0
/mob/living/var/pain_level = 0 //Gets overwritten every tick! If you want to add pain "resistance" or constain pain, see update_pain_level()
/mob/living/var/pain_numb = 0 // When this is set, the mob isn't affected by shock or pain, but can't see their health.

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/update_pain_level()
	if(pain_numb)
		pain_level = 0
		return

	pain_level = 					\
	1	* src.getOxyLoss() + 		\
	0.7	* src.getToxLoss() + 		\
	1.5	* src.getFireLoss(TRUE) + 		\
	1.2	* src.getBruteLoss(TRUE) + 		\
	1.7	* src.getCloneLoss() + 		\
	2	* src.halloss

	for(var/datum/reagent/R in reagents.reagent_list)
		pain_level -= R.pain_resistance

	if(src.slurring) //We're drunk, dulls the pain a bit
		pain_level -= 20

	// broken or ripped off organs will add quite a bit of pain
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = src
		for(var/datum/organ/external/organ in M.organs)
			if (!organ)
				continue
			if(!organ.is_organic())
				continue
			if((organ.status & ORGAN_DESTROYED) && !organ.amputated)
				pain_level += 45
			else if(organ.status & ORGAN_BROKEN || organ.open)
				pain_level += 30
				if(organ.status & ORGAN_SPLINTED)
					pain_level -= 25

	if(pain_level < 0)
		pain_level = 0

	return pain_level


/mob/living/carbon/proc/handle_shock() //Currently only used for humans
	update_pain_level()


/mob/living/carbon/proc/total_painkillers()
	for(var/datum/reagent/R in reagents.reagent_list)
		. += R.pain_resistance

/mob/living/carbon/proc/has_painkillers()
	return total_painkillers() > 0 
