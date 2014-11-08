--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto rune maker event logic
]]

AfkModule.RuneMake = {}
RuneMake = AfkModule.RuneMake

function RuneMake.Event(event)
  if g_game.isOnline() then
    local words = AfkModule.getPanel():getChildById('RuneSpellText'):getText()
    local player = g_game.getLocalPlayer()

    -- Check if we are attacking
    if g_game.isAttacking() then
      return Helper.safeDelay(3000, 6000)
    end

    if BotModule.isPrecisionMode() then
      local spell = Spells.getSpellByWords(words)

      local reschedule = false
      if spell then
        if player:getSoul() < spell.soul then
          BotLogger.warning("Not enough soul points("..spell.soul..") to make this rune.")
          reschedule = true
        elseif player:getMana() < spell.mana then
          BotLogger.warning("Not enough mana("..spell.mana..") to make this rune.")
          reschedule = true
        end

        if reschedule then
          return Helper.safeDelay(3000, 9000)
        end
      end
    end
    local talkDelay = Helper.safeDelay(150, 600)

    local checkContainer = AfkModule.getPanel():getChildById(
      'RuneMakeOpenContainer'):isChecked()
    
    if not checkContainer and not g_game.isOfficialTibia() then
      scheduleEvent(function() g_game.talk(words) end, talkDelay)
      return Helper.safeDelay(3000, 9000)
    end

    local blankRune = player:getItem(Runes.blank) -- blank rune item
    if blankRune ~= nil then
      scheduleEvent(function() g_game.talk(words) end, talkDelay)
    end
  end

  return Helper.safeDelay(3000, 9000)
end