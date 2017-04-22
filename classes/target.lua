--[[
  @Authors: Ben Dol (BeniS)
  @Details: Target setting class that represents a 
            target logic setting.
]]
if not CandyConfig then
  dofile("candyconfig.lua")
end

TargetSetting = extends(CandyConfig, "TargetSetting")

TargetSetting.create = function(target, movement, stance, attack, range, equip, follow, priority)
  local setting = TargetSetting.internalCreate()

  setting.movement = MovementSetting.create()
  setting.stance = stance or FightOffensive
  setting.attack = attack or Attack.create()
  setting.range = range or {100, 0}
  setting.equip = equip or {}
  setting.target = target
  setting.follow = follow ~= nil and follow or true
  setting.priority = priority or 0
  setting.index = 0
  
  return setting
end


function TargetSetting:clone() 
  local setting = TargetSetting.internalCreate()
  table.merge(setting, self)
  setting.range = {self.range[2], 0}
  setting.movement = self.movement:clone()

  if self.attack then
    setting.attack = self.attack:clone()
  end
  return setting
end

function TargetSetting:getPriority()
  return self.priority
end

function TargetSetting:setPriority(priority)
  local oldPriority = self.priority
  if priority ~= oldPriority then
    self.priority = priority

    signalcall(self.onPriorityChange, self, priority, oldPriority)
  end
end

function TargetSetting:getMovement()
  return self.movement
end

function TargetSetting:setMovementType(type)
  if self.movement.type ~= type then 
    self.movement.type = type

    signalcall(self.onMovementChange, self, self.movement)
  end
end

function TargetSetting:setMovementRange(range)
  if self.movement.range ~= range then 
    self.movement.range = range

    signalcall(self.onMovementChange, self, self.movement)
  end
end

function TargetSetting:getStance()
  return self.stance
end

function TargetSetting:setStance(stance)
  local oldStance = self.stance
  if stance ~= oldStance then
    self.stance = stance

    signalcall(self.onStanceChange, self, stance, oldStance)
  end
end

function TargetSetting:getAttack()
  return self.attack
end

function TargetSetting:setAttack(attack)
  local oldAttack = self.attack
  if attack ~= oldAttack then
    self.attack = attack

    signalcall(self.onAttackChange, self, attack, oldAttack)
  end
end

function TargetSetting:getRange(index)
  local range = self.range
  if index and self:isIndexValid(index) then
    range = self.range[index]
  end
  return range
end

function TargetSetting:setRange(range, index)
  if not index then
    local oldRange = self.range
    if oldRange ~= range then
      self.range = range

      signalcall(self.onRangeChange, self, range, oldRange)
    end
  else
    if self:isIndexValid(index) then
      local oldRange = self.range[index]
      if oldRange ~= range then
        self.range[index] = range

        signalcall(self.onRangeChange, self, range, oldRange, index)
      end
    else
      perror("Invalid index provided: " .. index)
    end
  end
end

function TargetSetting:getEquip()
  return self.equip
end

function TargetSetting:setEquip(equip)
  local oldEquip = self.equip
  if equip ~= oldEquip then
    self.equip = equip

    signalcall(self.onEquipChange, self, equip, oldEquip)
  end
end

function TargetSetting:getFollow()
  return self.follow
end

function TargetSetting:setFollow(follow)
  local oldFollow = self.follow
  if follow ~= oldFollow then
    self.follow = follow

    signalcall(self.onFollowChange, self, follow, oldFollow)
  end
end

function TargetSetting:getTarget()
  return self.target
end

function TargetSetting:setTarget(target)
  local oldTarget = self.target
  if target ~= oldTarget then
    self.target = target
    
    signalcall(self.onTargetChange, self, target, oldTarget)
  end
end

function TargetSetting:getIndex()
  return self.index
end

function TargetSetting:setIndex(index)
  local oldIndex = self.index
  if index ~= oldIndex then
    self.index = index
    
    signalcall(self.onIndexChange, self, index, oldIndex)
  end
end

function TargetSetting:isIndexValid(index)
  return index > 0 and index < 3
end


function TargetSetting:toNode()
  local node = CandyConfig.toNode(self)
  
  -- complex nodes

  node.range = self.range
  node.equip = self.equip
  node.priority = self.priority

  if self.attack then
    node.attack = self.attack:toNode()
  end
  
  if self.movement then
    node.movement = self.movement:toNode()
  end
  return node
end

function TargetSetting:parseNode(node)
  CandyConfig.parseNode(self, node)

  -- complex parse

  if node.range then
    for k,v in pairs(node.range) do
      self.range[tonumber(k)] = tonumber(v)
    end
  end
  if node.equip then
    self.equip = node.equip
  end
  if node.priority then
  	self.priority = tonumber(node.priority)
  end
  if node.attack then
    self.attack = Attack.create()
    self.attack:parseNode(node.attack)
  end
  if node.movement then
    self.movement:parseNode(node.movement)
  end
end

--[[ Target Class]]

Target = extends(CandyConfig, "Target")

Target.create = function(name, settings, loot, antiks)
  local target = Target.internalCreate()
  
  target.name = name or ""
  target.settings = settings or {}
  target.loot = loot ~= nil and loot or true
  target.antiks = antiks ~= nil and antiks or true
  
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

function Target:getSetting(index)
  return self.settings[index]
end

function Target:getSettings()
  return self.settings
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
    setting:setTarget(self)
    setting:setIndex(#self.settings + 1)
    table.insert(self.settings, setting)

    signalcall(self.onAddSetting, self, setting)
  end
end

function Target:removeSetting(setting)
  if table.contains(self.settings, setting) then
    local index = setting:getIndex()
    table.remove(self.settings, index)
    for k, v in pairs(self.settings) do
      v:setIndex(k)
    end
    signalcall(self.onRemoveSetting, self, setting)
  end
end

function Target:getAntiKS()
  return self.antiks
end

function Target:setAntiKS(AntiKS)
  local oldAntiKS = self.antiks
  if AntiKS ~= oldAntiKS then
    self.antiks = AntiKS

    signalcall(self.onAntiKSChange, self, AntiKS, oldAntiKS)
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

-- methods

function Target:toNode()
  local node = CandyConfig.toNode(self)
  
  -- complex nodes

  if self.settings then
    node.settings = {}
    for i,setting in pairs(self.settings) do
      if setting then
        node.settings[i] = setting:toNode()
      end
    end
  end
  return node
end

function Target:parseNode(node)
  CandyConfig.parseNode(self, node)

  -- complex parse

  if node.settings then
    self.settings = {}
    for k,v in pairs(node.settings) do
      local setting = TargetSetting.create(self)
      setting:parseNode(v)
      self.settings[tonumber(k)] = setting
    end
  end
end

MovementSetting = extends(CandyConfig, "MovementSetting")

MovementSetting.create = function(movementType, range)
  local movement = MovementSetting.internalCreate()
  movement.type = tonumber(movementType) or Movement.None
  movement.range = tonumber(range) or 4
  
  return movement
end

function MovementSetting:clone()
  return MovementSetting.create(self.type, self.range)
end

function MovementSetting:toNode()
  return CandyConfig.toNode(self)
end


function MovementSetting:parseNode(node)
  CandyConfig.parseNode(self, node)

  -- complex parse

  self.type = tonumber(self.type)
  self.range = tonumber(self.range)
end

function MovementSetting:getRange()
  return self.range
end

function MovementSetting:getType() 
  return self.type
end
