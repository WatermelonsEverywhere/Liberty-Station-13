//////////////////////////////
//			Psionic Misc.
//////////////////////////////
/obj/item/psi_injector
	name = "cerebrix inhaler"
	desc = "A modified inhaler which delivers over-saturated cerebrix diluted in water before being aerosolized. Unlike a direct injection or drinking, this method prevents overdosing or nasty side \
	side effects at the cost of spending more cerebrix for what it returns in essence. Useful for psions to allow them to directly and easily regain essence a limited number of times."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "psi_inhaler"
	force = WEAPON_FORCE_HARMLESS
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_PLASTIC = 1, MATERIAL_GLASS = 1)
	var/use = 4 // Number of times it can be used.
	var/point_per_use = 1 // Amount of points it give to a psion each use.

/obj/item/psi_injector/update_icon()
	if(use <= 0)
		icon_state = "psi_inhaler_used"


/obj/item/psi_injector/examine(mob/user)
	..()
	to_chat(user, "It has [use] uses left.")
	to_chat(user, "It can give [point_per_use] essence per use to a psion.")

/obj/item/psi_injector/attack(atom/target, mob/user)
	update_icon()
	if(ishuman(target)) // Check if it's an actual mob and not a wall
		var/mob/living/carbon/human/T = target
		var/obj/item/organ/internal/psionic_tumor/PT = T.random_organ_by_process(BP_PSION)
		if(PT) // Is the target a psion
			if(PT.max_psi_points - PT.psi_points >= point_per_use) // Is there space to give the psion the points?
				if(use) // Do we have uses left?
					user.visible_message("[user] injects [target] with the [src].", "You inject [target] with the [src]!")
					PT.psi_points += point_per_use
					use--
					update_icon()
					return
				else
					to_chat(user, "The [src.name] has no doses left.")
					update_icon()
					return
			else
				to_chat(user, "[T.name] already has the maximum amount of essence \his body can hold.")
				update_icon()
				return
		else
			to_chat(user, "You can't inject this into a non-psion.")
			return
	..()

/datum/design/research/item/clothing/tinfoil
	name = "Blue-Ink Psionic Shielding Apparatus"
	desc = "The product of an eccentric scientist who was fed up with telepathic cat-calls. This device shields the wearer from recieving \
	telepathic messages, but also prevents psions from using their abilities altogether when worn. The perfect Psionic Containment device. \
	Despite the advanced technology involved, it looks a little like a tin-foil hat."
	build_path = /obj/item/clothing/head/psionic/tinfoil

/obj/item/clothing/head/psionic/tinfoil
	name = "Blue-Ink Psionic Shielding Apparatus"
	icon_state = "tinfoil"
	desc = "The product of an eccentric scientist who was fed up with telepathic cat-calls. This device shields the wearer from recieving \
	telepathic messages, but also prevents psions from using their abilities altogether when worn. The perfect Psionic Containment device. \
	Despite the advanced technology involved, it looks a little like a tin-foil hat."
	origin_tech = list(TECH_MAGNET = 6)
	matter = list(MATERIAL_STEEL = 1, MATERIAL_SILVER = 0.5)
	psi_blocking = 10
	price_tag = 150

// The object that make the shield
/obj/item/shield_projector/line/psionic
	name = "psionic shield projector"
	desc = ""
	line_length = 3
	always_on = TRUE
	high_color = "#8000ff"
	low_color = "#FF0000"

/obj/item/shield_projector/line/psionic/New(loc, var/cog, var/_dir)
	dir = _dir
	if(cog >= 40)
		line_length = 5
	else
		line_length = 3 // Mininum size I think we can make without errors
	..()

/obj/item/shield_projector/line/psionic/create_shield(newloc, new_dir)
	var/obj/effect/directional_shield/psionic/S = new(newloc, src)
	S.dir = new_dir
	active_shields += S

// The shield itself
/obj/effect/directional_shield/psionic
	name = "directional combat shield"
	desc = "A wide shield, which has the property to block incoming projectiles but allow outgoing projectiles to pass it."
	density = TRUE // People can't move pass these shields.

/obj/effect/directional_shield/psionic/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
    if(air_group || (height==0))
        return TRUE
    else if(istype(mover, /obj/item/projectile))
        var/obj/item/projectile/P = mover
        if(istype(P, /obj/item/projectile/test) || P.testing) // Turrets need to try to kill the shield and so their test bullet needs to penetrate.
            return TRUE

        var/bad_arc = reverse_direction(dir) // Arc of directions from which we cannot block.
        if(check_parry_arc(src, bad_arc, P)) // This is actually for mobs but it will work for our purposes as well.
            return FALSE
        else
            return TRUE
    return FALSE

// Commenting out in case Custodians want a repurposed psi-blocking ring or something.
/*
/obj/item/clothing/gloves/psionic_ring
	name = "Ring of Dispelling"
	desc = "A sacred ring of metal, said to have been used in the production of the original cruciform prototypes. The Cartographer has blessed it, giving it powerful anti-psionic properties, and bestowed it to the upper church for use in psionic crises. It is irreplacable."
	icon_state = "ring_of_dispel"
	price_tag = 1000
	psi_blocking = 50
*/

