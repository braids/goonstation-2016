/*	Bee Implant
 *
 *	By: Dieting Hippo
 *	For AssJam13
 */

/obj/item/implant/bee
	name = "bee implant"
	icon_state = "implant-r"
	impcolor = "r"
	var/activation_emote = "deathgasp"
	var/active = 0
	var/beeCount = 1

	implanted(mob/source as mob)
		..()
		if(source.mind)
			source.mind.store_memory("Your bee implant will detonate upon death.", 0, 0)
		boutput(source, "The implanted bee implant will detonate upon unintentional death.")

	trigger(emote, mob/source as mob)
		if (!source || (source != src.loc) || (source.stat != 2 && prob(99)) || src.active)
			return
		if (emote == src.activation_emote)

			. = 0
			for (var/obj/item/implant/bee/other_bee in src.loc)
				other_bee.active = 1 //This actually should include us, ok.
				.+= other_bee.beeCount //tally the total bee power we're dealing with here

			source.visible_message("[source] emits a joyous buzzing noise.")
			logTheThing("bombing", source, null, "triggered a bee implant on death.")
			var/turf/T = get_turf(src)
			src.set_loc(null) //so we don't get deleted prematurely by the blast.

			source.transforming = 1

			var/obj/overlay/Ov = new/obj/overlay(T)
			Ov.anchored = 1 //Create a big bomb explosion overlay.
			Ov.name = "Explosion"
			Ov.layer = NOLIGHT_EFFECTS_LAYER_BASE
			Ov.pixel_x = -17
			Ov.icon = 'icons/effects/hugeexplosion.dmi'
			Ov.icon_state = "explosion"

			var/list/throwjunk = list() //List of stuff to throw as if the explosion knocked it around.
			var/cutoff = 0 //So we don't freak out and throw more than ~25 things and act like the old mass driver bug.
			for(var/obj/item/I in source)
				cutoff++
				I.set_loc(T)
				if(cutoff <= 25)
					throwjunk += I

			spawn(0) //Delete the overlay when finished with it.
				// Spawn bees
				for(var/i=1; i<=(. * 5); i++)
					var/obj/critter/domestic_bee/B = null

					// Randomly pick what bee will spawn
					var/beeType = rand(0,100)
					if(beeType <= 70)
						B = new /obj/critter/domestic_bee(source.loc)
					else if(beeType <= 80)
						B = new /obj/critter/domestic_bee/buddy(source.loc)
					else if(beeType <= 83)
						B = new /obj/critter/domestic_bee/queen(source.loc)
					else if(beeType <= 86)
						B = new /obj/critter/domestic_bee/queen/big(source.loc)
					else if(beeType <= 88)
						B = new /obj/critter/domestic_bee/queen/big/buddy(source.loc)
					else if(beeType <= 90)
						B = new /obj/critter/domestic_bee/queen/omega(source.loc)
					else if(beeType <= 95)
						B = new /obj/critter/domestic_bee/heisenbee(source.loc)
					else if(beeType <= 92)
						B = new /obj/critter/domestic_bee/small(source.loc)
					else if(beeType <= 93)
						B = new /obj/critter/domestic_bee/zombee(source.loc)
					else if(beeType <= 94)
						B = new /obj/critter/domestic_bee/moon(source.loc)
					else if(beeType <= 95)
						B = new /obj/critter/domestic_bee/bubs(source.loc)
					else if(beeType <= 96)
						B = new /obj/critter/domestic_bee/overbee(source.loc)
					else if(beeType <= 97)
						B = new /obj/critter/domestic_bee/trauma(source.loc)
					else if(beeType <= 98)
						B = new /obj/critter/domestic_bee/chef(source.loc)
					else if(beeType <= 99)
						B = new /obj/critter/domestic_bee/santa(source.loc)
					else
						B = new /obj/critter/domestic_bee/creepy(source.loc)

					// Set bee properties
					B.beeMom = source
					B.beeMomCkey = source.ckey
					B.name = "li'l [B.beeMom.real_name]"
					B.desc = "This bee looks very much like [B.beeMom.real_name]. How peculiar."

					// Set bee color
					if (B.beeMom.bioHolder && B.beeMom.bioHolder.mobAppearance)
						B.beeKid = "[B.beeMom.bioHolder.mobAppearance.customization_first_color]"
						if (!B.beeMom.bioHolder.mobAppearance.customization_first_color)
							B.beeKid = "#FFFFFF"

					// Aggro bee on attacker
					if (B.beeMom.lastattacker && B.beeMom.lastattacker != B.beeMom && (B.beeMom.lastattackertime + 140) >= world.time)
						B.target = B.beeMom.lastattacker
						B.oldtarget_name = "[B.target]"
						B.visible_message("<span style=\"color:red\"><b>[B] buzzes angrily at [B.beeMom.lastattacker]!</b></span>")
						B.task = "chasing"

					B.update_icon()

				if(source)
					source.gib()

				for(var/obj/O in throwjunk) //Throw this junk around
					var/edge = get_edge_target_turf(T, pick(alldirs))
					O.throw_at(edge, 80, 4)

				sleep(15)
				qdel(Ov)
				qdel(src)

			return

/obj/item/implanter/bee
	name = "bee implanter"
	icon_state = "implanter1-g"
	New()
		src.imp = new /obj/item/implant/bee( src )

		..()
		return