require('util')

function annie_pyromania_increase_stack( event )
  print("annie_pyromania_increase_stack")
  PrintTable(event)
  if (not event.caster:HasModifier("modifier_pyromania") and event.caster:HasAbility("annie_pyromania")) then
    event.caster:FindAbilityByName("annie_pyromania"):ApplyDataDrivenModifier(event.caster, event.caster, "modifier_pyromania", nil)
  end
  local modifierStackCount = event.caster:GetModifierStackCount("modifier_pyromania", nil)
  print(modifierStackCount)
  if (modifierStackCount < 5) then
    modifierStackCount = modifierStackCount + 1
    event.caster:SetModifierStackCount("modifier_pyromania", nil, modifierStackCount)
  end
  if (modifierStackCount >= 5) then
    event.caster.annie_possible_ability_to_stun = event.ability
  else
    event.caster.annie_possible_ability_to_stun = nil
  end
end

function annie_pyromania_stun( event )
  if (not event.caster:HasModifier("modifier_pyromania") and event.caster:HasAbility("annie_pyromania")) then
    event.caster:FindAbilityByName("annie_pyromania"):ApplyDataDrivenModifier(event.caster, event.caster, "modifier_pyromania", nil)
  end
  print("annie_pyromania_stun")
  PrintTable(event)
  local modifierStackCount = event.caster:GetModifierStackCount("modifier_pyromania", nil)
  if (event.caster.annie_possible_ability_to_stun == event.ability) then
    event.caster:SetModifierStackCount("modifier_pyromania", nil, 0)
    local stunDuration = 1.25 -- ugly hardcoded (didn't succeed in loading from lua)
    if (event.caster:GetLevel() >= 6) then
        stunDuration = 1.5
    end
    if (event.caster:GetLevel() >= 11) then -- not very optimized but it'll do.
        stunDuration = 1.75
    end
    print("stun duration:")
    print(stunDuration)
    if (event.target ~= nil) then
      event.target:AddNewModifier(event.caster, event.ability, "modifier_stunned", {duration = stunDuration})
    end
    PrintTable(event.target_entities)
    if (event.target_entities ~= nil) then
      for i,ent in pairs(event.target_entities) do
        ent:AddNewModifier(event.caster, event.ability, "modifier_stunned", {duration = stunDuration})
      end
    end
  end
end

function annie_disintegrate( event )
  print("annie_disintegrate")
  PrintTable(event)
  if (event.target:IsAlive()) then
    local damageTable = {
      victim = event.target,
      attacker = event.caster,
      damage = event.ability:GetAbilityDamage(),
      damage_type = event.ability:GetAbilityDamageType(),
    }
    ApplyDamage(damageTable)
    if (not event.target:IsAlive()) then
      event.ability:RefundManaCost()
      local var newCooldown = event.ability:GetCooldownTimeRemaining() / 2
      event.ability:EndCooldown()
      event.ability:StartCooldown(newCooldown)
    end
  end
  annie_pyromania_stun(event)
end

function debug_OnSpellStart( event )
  print("onSpellStart")
end