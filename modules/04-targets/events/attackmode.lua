--[[
  @Authors: Ben Dol (BeniS)
  @Details: Attack mode processor logic
]]

TargetsModule.AttackMode = {}
AttackMode = TargetsModule.AttackMode

-- Variables

-- Methods

function AttackMode.init()
  
end

function AttackMode.terminate()
  
end

function AttackMode.onStopped()
  
end

function AttackMode.Event(event)
  -- Cannot continue if still attacking or in pz
  local player = g_game.getLocalPlayer()
  if not g_game.isAttacking() then
    if player:hasState(PlayerStates.Swords) then
      return Helper.safeDelay(300, 500)
    else
      return Helper.safeDelay(1500, 2000)
    end
  elseif player:hasState(PlayerStates.Pz) then
    return 3000
  end
  local creature = g_game.getAttackingCreature()
  local target = TargetsModule.getTarget(creature:getName())
  if target then
    for index, setting in ipairs(target:getSettings()) do
      if setting:getRange(2) <= creature:getHealthPercent() and setting:getRange(1) >= creature:getHealthPercent() then
        local attack = setting:getAttack()
        if attack then
          local type = attack:getType()
          local item = attack:getItem()
          local words = attack:getWords()
          local radius = attack:getRadius()
          local radiusSqrt = math.floor(math.sqrt(radius))

          -- TODO: multi actions decider/queue
          if type == AttackModes.ItemMode and item > 0 then
            if radius == 0 then
              Helper.safeUseInventoryItemWith(item, creature, BotModule.isPrecisionMode())
              return Helper.safeDelay(300, 500)
            end
            -- let's find best tile to use the rune
            local playerPos = player:getPosition()
            local targets = AutoTarget.getBestTarget() or {creature}
            local pos = targets[1]:getPosition()
            local spec = g_map.getSpectators(pos, false, radius*2, radius*2)
            local playerDist = math.sqrt(radius)+1
            playerDist = playerDist * playerDist
            local bestPos, bestScore, bestDist = nil, -1, 0
            for x = -radiusSqrt, radiusSqrt do
              if g_map.isAwareOfPosition({x=pos.x+x+radiusSqrt, y=pos.y, z=pos.z}) and
                g_map.isAwareOfPosition({x=pos.x+x-radiusSqrt, y=pos.y, z=pos.z}) then
                for y = -radiusSqrt, radiusSqrt do
                  if g_map.isAwareOfPosition({x=pos.x, y=pos.y+y+radiusSqrt, z=pos.z}) and
                    g_map.isAwareOfPosition({x=pos.x, y=pos.y+y-radiusSqrt, z=pos.z}) then
                    local curPos, curDist, curScore = {x=pos.x+x, y=pos.y+y, z=pos.z}, 0, 0
                    local tile = g_map.getTile(curPos)
                    -- printContents('aware of ', curPos)
                    if tile and tile:isLookPossible() and g_map.isSightClear(playerPos, curPos) then
                      for k, v in pairs(spec) do
                        local vp = v:getPosition()
                        local dist = (vp.x-curPos.x)*(vp.x-curPos.x) + (vp.y-curPos.y)*(vp.y-curPos.y)
                        if v:isLocalPlayer() then
                          curDist = dist
                        elseif v:isPlayer() and dist <= playerDist then
                          curScore = -1
                          break
                        elseif dist <= radius and g_map.isSightClear(curPos, v:getPosition()) then
                          curScore = curScore + (table.contains(targets, v) and 1 or 0.1)
                        end
                      end
                      if curScore >= 0 and (curScore > bestScore or (curScore == bestScore and curDist < bestDist)) then
                        bestPos = curPos
                        bestDist = curDist
                        bestScore = curScore
                      end
                    end
                  end
                end
              end
            end
            if bestScore >= 1 then
              Helper.safeUseInventoryItemWith(item, g_map.getTile(bestPos):getTopUseThing(), BotModule.isPrecisionMode())
              return Helper.safeDelay(300, 500)
            end
          elseif type == AttackModes.SpellMode and words and words ~= "" then 
            local isPvP = false
            if radius > 0 then
              for k, v in pairs(g_map.getSpectatorsInRange(creature:getPosition(), false, radiusSqrt, radiusSqrt)) do
                if v:isPlayer() and not v:isLocalPlayer() then
                  isPvP = true
                  break
                end
              end
            end
            if not isPvP then
              Helper.castSpell(player, words, 1)
              return Helper.safeDelay(300, 500)
            end
          end
        end
      end
    end
  end

  -- Keep the event live
  return Helper.safeDelay(300, 500)
end