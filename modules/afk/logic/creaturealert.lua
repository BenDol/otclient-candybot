-- Creature Alert Logic
AfkModule.CreatureAlert = {}
CreatureAlert = AfkModule.CreatureAlert

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
      if v ~= player and CreatureList.isBlackListed(v:getName()) then
        alert = true
        break
      end
    end
  else -- white
    for k, v in pairs (creatures) do
      if v ~= player and not CreatureList.isWhiteListed(v:getName()) then
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
  g_sounds.playMusic('alert.ogg', 0)
end

function CreatureAlert.stopAlert()
  g_sounds.stopMusic(0)
end