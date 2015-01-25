require('timers')
require('util')

local function bunny_has_slots( target )
    for i=0,5,1 do
    if not target:GetItemInSlot(i) then
      return true
    end
  end
  return false
end

local function bunny_internal_spawn_poop(position, team, level)
  local poop = CreateUnitByName("npc_dota_bunny_poop", position, true, nil, nil, team)
  poop:FindAbilityByName("bunny_poop"):SetLevel(level)
end

function bunny_spawnPoop( event )
  bunny_internal_spawn_poop(event.target:GetAbsOrigin(), event.caster:GetTeam(), event.ability:GetLevel())
end

function bunny_poopTouch( event )
  -- target is source because we might delete caster
  event.ability:ApplyDataDrivenModifier(event.target, event.target, "modifier_poop_slow", nil)
  PrintTable(event)
  print(event.ability:GetLevelSpecialValueFor("poop_damage", (event.ability:GetLevel() - 1)))
  local damageTable = {
    victim = event.target,
    attacker = event.caster,
    damage = event.ability:GetLevelSpecialValueFor("poop_damage", (event.ability:GetLevel() - 1)),
    damage_type = event.ability:GetAbilityDamageType(),
  }
  if (bunny_has_slots(event.target)) then
    local item = CreateItem("item_poop", event.target, event.target)
    -- item:SetLevel(event.ability:GetLevel())
    event.target:AddItem(item)
    print("ADD THIS POOP")
  else
    print("full sloted")
    bunny_spawnPoop ( {target = event.target, caster = event.caster, ability = event.ability } )
    damageTable.damage = damageTable.damage * 2
  end
  PrintTable(damageTable)
  ApplyDamage(damageTable)
  if (not event.caster:IsHero()) then
    event.caster:RemoveSelf()
  end
end

function bunny_getPoops( event )
  -- PrintTable(event)
  if event.target ~= nil then
    if (event.target:HasModifier("modifier_poop")) then
      event.ability:ApplyDataDrivenModifier(event.caster, event.caster, "modifier_poop_stack", nil)
      event.caster:SetModifierStackCount("modifier_poop_stack", nil, event.caster:GetModifierStackCount("modifier_poop_stack", nil) + 1)
      event.target:RemoveSelf()
    end
  end
  for i,ent in pairs(event.target_entities) do
    if (ent:HasModifier("modifier_poop")) then
      print("Take this poop !")
      event.ability:ApplyDataDrivenModifier(event.caster, event.caster, "modifier_poop_stack", nil)
      event.caster:SetModifierStackCount("modifier_poop_stack", nil, event.caster:GetModifierStackCount("modifier_poop_stack", nil) + 1)
      ent:RemoveSelf()
    end
  end
end

function bunny_dig_releasePoops( event )
  PrintTable(event)
  local poopNumber = event.caster:GetModifierStackCount("modifier_poop_stack", nil) + 1
  local rangeSpawn = event.ability:GetLevelSpecialValueFor("range_release_poops", (event.ability:GetLevel() - 1))
  local halfRangeSpawn = rangeSpawn / 2
  for i = 0, poopNumber, 1 do
    local vectorSpawn = RandomVector(RandomInt(halfRangeSpawn, rangeSpawn))
    bunny_internal_spawn_poop(event.caster:GetAbsOrigin() + vectorSpawn, event.caster:GetTeam(), event.ability:GetLevel())
  end
end

local function bunny_internal_create_projectile_poo(event, target)
  if (event.caster:GetModifierStackCount("modifier_poop_stack", nil) <= 0) then
    return
  end
  event.caster:SetModifierStackCount("modifier_poop_stack", nil, event.caster:GetModifierStackCount("modifier_poop_stack", nil) - 1)
  ProjectileManager:CreateTrackingProjectile({
    Target=target,
    Source = event.caster,
    Ability = event.ability,
    EffectName="particles/econ/events/coal/coal_projectile.vpcf",
    bDodgeable=1,
    bProvidesVision=1,
    iVisionRadius=300,
    vSpawnOrigin = event.caster:GetAbsOrigin(),
    fDistance = 2000,
    fStartRadius = 64,
    fEndRadius = 64,
    vVelocity = event.caster:GetForwardVector() * 1200,
    fExpireTime = GameRules:GetGameTime() + 10.0,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    bDeleteOnHit = true,
    bHasFrontalCone = false,
    bReplaceExisting = false,
    iVisionTeamNumber = event.caster:GetTeamNumber(),
    iMoveSpeed = 1200
  })
end

function bunny_create_projectile_poo( event )
  -- PrintTable(event)
  if event.target ~= nil then
    bunny_internal_create_projectile_poo(event, event.target)
  end
  for i,ent in pairs(event.target_entities) do
    -- bunny_internal_create_projectile_poo(event, ent)
  end
end

function bunny_internal_spawnEgg(owner, position, level, team)
  local egg = CreateUnitByName("npc_dota_bunny_egg", position, true, nil, nil, team)
  egg:FindAbilityByName("bunny_egg"):SetLevel(level)
end

function bunny_internal_crash_egg(event)
  print("throw egg to crash")
  local heroes = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, 
                              Vector(0, 0, 0),
                              nil,
                              FIND_UNITS_EVERYWHERE,
                              DOTA_UNIT_TARGET_TEAM_BOTH,
                              DOTA_UNIT_TARGET_HERO,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

  -- TODO: alert eggs spawn
  local rangeSpawn = event.ability:GetLevelSpecialValueFor("egg_range_spawn", (event.ability:GetLevel() - 1))
  local halfRangeSpawn = rangeSpawn / 2
  local teamCaster = event.caster:GetTeam()
  local nbEggs = event.ability:GetLevelSpecialValueFor("egg_number", (event.ability:GetLevel() - 1))
  for _,hero in pairs(heroes) do
    for _ = 1, nbEggs, 1 do
      bunny_internal_spawnEgg(hero, hero:GetAbsOrigin() + RandomVector(RandomInt(halfRangeSpawn, rangeSpawn)), event.ability:GetLevel(), teamCaster)
    end
  end
end

function bunny_egg_touch(event)
  event.ability:ApplyDataDrivenModifier(event.target, event.target, "modifier_egg_shield", nil)
  event.ability:ApplyDataDrivenModifier(event.target, event.target, "modifier_egg_shield_stack", nil)
  event.target:SetModifierStackCount("modifier_egg_shield_stack", nil, event.target:GetModifierStackCount("modifier_egg_shield_stack", nil) + 1)
      
  event.caster:RemoveSelf()
end

function bunny_egg_shield_lose_stack(event)
  event.target:SetModifierStackCount("modifier_egg_shield_stack", nil, event.target:GetModifierStackCount("modifier_egg_shield_stack", nil) - 1)
end

function bunny_egg_shield( event)
  PrintTable( event )
end

function bunny_summon_easter_eggs( event )
  PrintTable(event)
  PrintTable(event.ability:GetCursorPosition())
  bunny_internal_crash_egg( event)
  Timers:CreateTimer(0.5, function()
      print ("Hello. I'm running 0.5 seconds after you called me.")
      return nil
    end
  )
end

function bunny_test( event )
  -- PrintTable(event)
end