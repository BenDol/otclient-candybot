-- Creature Alert Logic
AfkModule.CreatureAlert = {}
CreatureAlert = AfkModule.CreatureAlert

local alertSoundChannel = g_sounds.getChannel(1)

function CreatureAlert.Event(event)
  local blackList = CreatureList.getBlackList()
  local whiteList = CreatureList.getWhiteList()

  local player = g_game.getLocalPlayer()
  local creatures = {}

  local alert = false

  creatures = g_map.getSpectators(player:getPosition(), false)

  if not player then
    return
  end

  if CreatureList.getBlackOrWhite() then -- black
    for k, v in pairs (creatures) do
      if v ~= player and AlertList.isBlackListed(v:getName()) then
        alert = true
        break
      end
    end
  else -- white
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

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, 800)
end

function CreatureAlert.alert()
  alertSoundChannel:enqueue('alert.ogg', 0)
end

function CreatureAlert.stopAlert()
  alertSoundChannel.stop()
end