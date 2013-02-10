-- Auto Rune Maker Logic
AfkModule.RuneMake = {}
RuneMake = AfkModule.RuneMake

function RuneMake.Event(event)
  if g_game.isOnline() then
    local words = AfkModule.getPanel():getChildById('RuneSpellText'):getText()
    local player = g_game.getLocalPlayer()

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
          EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, Helper.safeDelay(3000, 9000))
          return false
        end
      end
    end
    local talkDelay = Helper.safeDelay(150, 600)

    local checkContainer = AfkModule.getPanel():getChildById('RuneMakeOpenContainer'):isChecked()
    if not checkContainer and not g_game.isOfficialTibia() then
      scheduleEvent(function() g_game.talk(words) end, talkDelay)
      EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, Helper.safeDelay(3000, 9000))
      return false
    end

    local blankRune = player:getItem(Runes.blank) -- blank rune item
    if blankRune ~= nil then
      scheduleEvent(function() g_game.talk(words) end, talkDelay)
    end
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, Helper.safeDelay(3000, 9000))
end