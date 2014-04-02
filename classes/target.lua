--[[
  @Authors: Ben Dol (BeniS)
  @Details: Target setting class that represents a 
            target logic setting.
]]

TargetSetting = {}
TargetSetting.__index = TargetSetting

TargetSetting.__class = "TargetSetting"

TargetSetting.new = function(movement, stance, attack, range, equip)
  setting = {
    movement = 0,
    stance = "",
    attack = nil,
    range = {100, 0},
    equip = {}
  }
  setting.movement = movement
  setting.stance = stance
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

function TargetSetting:getStance()
  return self.stance
end

function TargetSetting:setStance(stance)
  self.stance = stance
end

function TargetSetting:getAttack()
  return self.attack
end

function TargetSetting:setAttack(attack)
  self.attack = attack
end

function TargetSetting:getRange()
  return self.range
end

function TargetSetting:setRange(range)
  self.range = range
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

Target.new = function(name, priority, settings, loot, alarm)
  target = {
    name = "",
    priority = 0,
    settings = {},
    loot = true,
    alarm = false
  }

  target.name = name
  target.priority = priority
  target.settings = settings
  target.loot = loot
  target.alarm = alarm

  setmetatable(target, Target)
  return target
end

-- gets/sets

function Target:getName()
  return self.name
end

function Target:setName(name)
  local oldName = self.name
  if name ~= oldName then
    self.name = name

    signalcall(self.onNameChange, self, name, oldName)
  end
end

function Target:getPriority()
  return self.priority
end

function Target:setPriority(priority)
  local oldPriority = self.priority
  if priority ~= oldPriority then
    self.priority = priority

    signalcall(self.onPriorityChange, self, priority, oldPriority)
  end
end

function Target:getSettings()
  return self.settings
end

function Target:getSetting(index)
  return self.settings[index]
end

function Target:setSettings(settings)
  local oldSettings = self.settings
  if settings ~= oldSettings then
    self.settings = settings

    signalcall(self.onSettingsChange, self, settings, oldSettings)
  end
end

function Target:addSetting(setting)
  if not table.contains(self.settings, setting) then
    table.insert(self.settings, setting)

    signalcall(self.onAddSetting, self, setting)
  end
end

function Target:getLoot()
  return self.loot
end

function Target:setLoot(loot)
  local oldLoot = self.loot
  if loot ~= oldLoot then
    self.loot = loot

    signalcall(self.onLootChange, self, loot, oldLoot)
  end
end

function Target:getAlarm()
  return self.alarm
end

function Target:setAlarm(alarm)
  local oldAlarm = self.alarm
  if alarm ~= oldAlarm then
    self.alarm = alarm

    signalcall(self.onSettingsChange, self, alarm, oldAlarm)
  end
end

-- methods