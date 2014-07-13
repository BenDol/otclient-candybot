UIPathMap = extends(UIMinimap, "UIPathMap")

function UIPathMap.create()
  return UIPathMap.internalCreate()
end

function UIPathMap:onCreate()
  UIMinimap.onCreate(self)
end

function UIPathMap:onSetup()
  UIMinimap.onSetup(self)
end

function UIPathMap:onDestroy()
  UIMinimap.onDestroy(self)
end

function UIPathMap:onVisibilityChange()
  UIMinimap.onVisibilityChange(self)
end

function UIPathMap:onCameraPositionChange(cameraPos)
  UIMinimap.onCameraPositionChange(self)
end

function UIPathMap:load()
  local settings = g_settings.getNode('Minimap')
  if settings then
    if settings.flags then
      for _,flag in pairs(settings.flags) do
        self:addFlag(flag.position, flag.icon, flag.description)
      end
    end
    self:setZoom(settings.zoom)
  end
end

function UIPathMap:save()
  local settings = { flags={} }
  for _,flag in pairs(self.flags) do
    table.insert(settings.flags, {
      position = flag.pos,
      icon = flag.icon,
      description = flag.description,
    })
  end
  settings.zoom = self:getZoom()
  g_settings.setNode('Minimap', settings)
end

function UIPathMap:addNode(pos, icon, description)
  --[[if not pos or not icon then return end
  local flag = self:getFlag(pos, icon, description)
  if flag or not icon then
    return
  end

  flag = g_ui.createWidget('MinimapFlag')
  self:insertChild(1, flag)
  flag.pos = pos
  flag.description = description
  flag.icon = icon
  flag:setIcon('/images/game/minimap/flag' .. icon)
  flag:setTooltip(description)
  flag.onMouseRelease = onFlagMouseRelease
  flag.onDestroy = function() table.removevalue(self.flags, flag) end
  table.insert(self.flags, flag)
  self:centerInPosition(flag, pos)]]
end

function UIPathMap:reset()
  UIMinimap.reset(self)
end

function UIPathMap:onMouseRelease(pos, button)
  if not self.allowNextRelease then return true end
  self.allowNextRelease = false

  local mapPos = self:getTilePosition(pos)
  if not mapPos then return end

  if button == MouseLeftButton then
    local player = g_game.getLocalPlayer()
    if self.autowalk then
      player:autoWalk(mapPos)
    end
    return true
  elseif button == MouseRightButton then
    local menu = g_ui.createWidget('PopupMenu')
    menu:addOption(tr('Create mark'), function() self:createFlagWindow(mapPos) end)
    menu:display(pos)
    return true
  end
  return false
end

function UIPathMap:createNodeWindow(pos)
  --[[if self.flagWindow then return end
  if not pos then return end

  self.flagWindow = g_ui.createWidget('MinimapFlagWindow', rootWidget)

  local positionLabel = self.flagWindow:getChildById('position')
  local description = self.flagWindow:getChildById('description')
  local okButton = self.flagWindow:getChildById('okButton')
  local cancelButton = self.flagWindow:getChildById('cancelButton')

  positionLabel:setText(string.format('%i, %i, %i', pos.x, pos.y, pos.z))

  local flagRadioGroup = UIRadioGroup.create()
  for i=0,19 do
    local checkbox = self.flagWindow:getChildById('flag' .. i)
    checkbox.icon = i
    flagRadioGroup:addWidget(checkbox)
  end

  flagRadioGroup:selectWidget(flagRadioGroup:getFirstWidget())

  local successFunc = function()
    self:addFlag(pos, flagRadioGroup:getSelectedWidget().icon, description:getText())
    self:destroyFlagWindow()
  end

  local cancelFunc = function()
    self:destroyFlagWindow()
  end

  okButton.onClick = successFunc
  cancelButton.onClick = cancelFunc

  self.flagWindow.onEnter = successFunc
  self.flagWindow.onEscape = cancelFunc

  self.flagWindow.onDestroy = function() flagRadioGroup:destroy() end]]
end

function UIPathMap:destroyNodeWindow()
  --[[if self.flagWindow then
    self.flagWindow:destroy()
    self.flagWindow = nil
  end]]
end
