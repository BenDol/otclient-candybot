--[[
  @Authors: Ben Dol (BeniS)
  @Details: Target setting class that represents a 
            target logic setting.
]]

TargetSetting = {}
TargetSetting.__index = TargetSetting

TargetSetting.__class = "TargetSetting"

TargetSetting.new = function(movement, attack, range, equip)
  setting = {
    movement = 0,
    attack = nil,
    range = {0, 100},
    equip = {}
  }
  setting.movement = movement
  setting.attack = attack
  setting.range = range
  setting.equip = equip

  setmetatable(setting, TargetSetting)
  return setting
end

function TargetSetting:getMovement()
  return self.movement
end

function TargetSetting:setMovement(movement)
  self.movement = movement
end

function TargetSetting:getAttack()
  return self.attack
end

function TargetSetting:setAttack(attack)
  self.attack = attack
end

function TargetSetting:getEquip()
  return self.equip
end

function TargetSetting:setEquip(equip)
  self.equip = equip
end

--[[ Target Class]]

Target = {}
Target.__index = Target

Target.__class = "Target"

Target.new = function(creature, priority, settings, loot, alarm)
  target = {
    creature = nil,
    priority = 0,
    settings = {},
    loot = true,
    alarm = false
  }

  if not creature or type(creature) ~= 'userdata' then
    error('invalid creature provided.')
  end
  target.creature = creature
  target.priority = priority
  target.settings = settings
  target.loot = loot
  target.alarm = alarm

  setmetatable(target, Target)
  return target
end

-- gets/sets

function Target:getCreature()
  return self.creature
end

function Target:setCreature(creature)
  self.creature = creature
end

function Target:getPriority()
  return self.priority
end

function Target:setPriority(priority)
  self.priority = priority
end

function Target:getSettings()
  return self.settings
end

function Target:setSettings(settings)
  self.settings = settings
end

function Target:getLoot()
  return self.loot
end

function Target:setLoot(loot)
  self.loot = loot
end

function Target:getAlarm()
  return self.alarm
end

function Target:setAlarm(alarm)
  self.alarm = alarm
end

-- methods

