--[[
  @Authors: zygzagZ
  @Details: Friend healer event logic
]]

PvpModule.Healer = {}
Healer = PvpModule.Healer

-- Variables

Healer.lastTarget = 0

-- Methods

function Healer.init()

end

function Healer.terminate()

end

function Healer.connect()
  connect(Player, { onHealthPercentChange = Healer.onHealthChange })
  addEvent(function()
    local spec = g_map.getSpectators(g_game.getLocalPlayer():getPosition(), true)
    for k, v in pairs(spec) do
      if v:isPlayer() then 
        Healer.onHealthChange(v, v:getHealthPercent())
      end
    end
  end)
end

function Healer.disconnect()
  disconnect(Player, { onHealthPercentChange = Healer.onHealthChange })
end

function Healer.onHealthChange(friend, health) 
  local player = g_game.getLocalPlayer()
  if table.contains(PvpModule.Friends, friend:getName()) then
    if health <= CandyBot.getOption('HealerTreshold') then
      if player:getHealthPercent() >= CandyBot.getOption('HealerSelfHealth') and player:getManaPercent() >= CandyBot.getOption('HealerSelfMana') then
        if g_map.isSightClear(player:getPosition(), friend:getPosition()) then
          g_game.talk(CandyBot.getOption('HealerSpell'):gsub("friend", friend:getName()))
        end
      end
    end
  end
end