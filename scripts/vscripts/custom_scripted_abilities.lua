function dice_attack(event)
 
	local dice1 = RandomInt(1, 6)
	local dice2 = RandomInt(1, 6)
	local trueDamage = event.Damage * (dice1 + dice2)
	local damageTable = {
		victim = event.target, attacker = event.caster, damage = trueDamage, damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end


function LLgiveUnitDataDrivenModifier(source, target, modifier,dur)
    --source and target should be hscript-units. The same unit can be in both source and target
    local item = CreateItem( "lady_luck_item_modifier_master", nil, nil)
    item:ApplyDataDrivenModifier( source, target, modifier, {duration=dur} )
end

function RandomDebuff(event)

	local source = event.caster
	local target = event.target

	local random = RandomInt(1, 6)

	if     random == 1 then LLgiveUnitDataDrivenModifier(source, target, "random_debuff_stun", event.RStun)
    elseif random == 2 then LLgiveUnitDataDrivenModifier(source, target, "random_debuff_disarmed", event.RDisarm)
    elseif random == 3 then LLgiveUnitDataDrivenModifier(source, target, "random_debuff_slow", event.RSlow)
	elseif random == 4 then LLgiveUnitDataDrivenModifier(source, target, "random_debuff_miss", event.RMiss)
    elseif random == 5 then LLgiveUnitDataDrivenModifier(source, target, "random_debuff_silenced", event.RSilence)
    elseif random == 6 then LLgiveUnitDataDrivenModifier(source, target, "random_debuff_root", event.RRoot)
    end
end


function lady_luck_fire_noble_phantasm(args)
	local caster = args.caster
	local angleX = RandomFloat( -0.5, 0.5 )
	local angleY = RandomFloat( -0.5, 0.5 )
	local vector = caster:GetForwardVector()
	--A Liner Projectile must have a table with projectile info
	local info = 
	{
		Ability = args.ability,
        	EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
        	vSpawnOrigin = caster:GetCenter(),
        	fDistance = 1700,
        	fStartRadius = 50,
        	fEndRadius = 50,
        	Source = caster,
        	bHasFrontalCone = false,
        	bReplaceExisting = false,
        	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        	fExpireTime = GameRules:GetGameTime() + 100.0,
		bDeleteOnHit = true,
		vVelocity = Vector(vector.x + angleX , vector.y + angleY, 0) * 800,
		bProvidesVision = false,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)
end

function change_damage_enemy(event)
	local chance = RandomInt(0, 1000)
	if chance <= 500 then event.attacker:Heal(event.Damage * 0.45 , event.attacker) return
	else event.Damage = event.Damage * 0.75
	end

	local damagePhysic = {
		victim = event.attacker, attacker = event.attacker, damage = event.Damage, damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	--print ("Enemy: "..chance)
	ApplyDamage(damagePhysic)
end

function change_damage_ally(event)
	local chance = RandomInt(0, 1000)
	if chance <= 250 then event.attacker:Heal(event.Damage * 1, event.attacker) return
	elseif chance <= 750 then event.Damage = event.Damage * 0.6
	end

	local damageMagic = {
		victim = event.attacker, attacker = event.attacker, damage = event.Damage, damage_type = DAMAGE_TYPE_MAGICAL,
	}
	--print ("Ally: "..chance)
	ApplyDamage(damageMagic)
end