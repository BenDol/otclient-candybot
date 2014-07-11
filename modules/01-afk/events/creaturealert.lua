--[[
  @Authors: Ben Dol (BeniS)
  @Details: Creature alert event logic
]]

AfkModule.CreatureAlert = {}
CreatureAlert = AfkModule.CreatureAlert

local alertSoundChannel = g_sounds.getChannel(1)

function CreatureAlert.Event(event)
  local blackList = AlertList.getBlackList()
  local whiteList = AlertList.getWhiteList()

  local player = g_game.getLocalPlayer()
  if not player then return end

  local creatures = {}
  creatures = g_map.getSpectators(player:getPosition(), false)

  local alert = false
  if AlertList.getBlackOrWhite() then 
    -- black
    for k, v in pairs (creatures) do
      if v ~= player and AlertList.isBlackListed(v:getName()) then
        alert = true
        break
      end
    end
  else 
    -- white
    for k, v in pairs (creatures) do
      if v ~= player and not AlertList.isWhiteListed(v:getName()) then
        alert = true
        break
      end
    end
  end

  if alert then
    CreatureAlert.alert()
  else
    CreatureAlert.stopAlert()
  end

  return 800
end

function CreatureAlert.alert()
  alertSoundChannel:enqueue('alert.ogg', 0)
end

function CreatureAlert.stopAlert()
  alertSoundChannel:stop()
end