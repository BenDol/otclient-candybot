-- Auto Rune Maker Logic
AfkModule.RuneMake = {}
RuneMake = AfkModule.RuneMake

function RuneMake.Event(event)
  if g_game.isOnline() then
    local words = AfkModule.getPanel():getChildById('RuneSpellText'):getText()
    local player = g_game.getLocalPlayer()

    if BotModule.isPrecisionMode() then
      local spell = Spells.getSpellByWords(words)

      if spell and player:getSoul() < spell.soul then
        BotLogger.warning("Not enough soul points("..spell.soul..") to make this rune.")

        EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(3000, 7000))
        return false
      end
    end
    
    if not AfkModule.getPanel():getChildById('RuneMakeOpenContainer'):isChecked() then
      g_game.talk(words)
      EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(6000, 15000))
    end

    local blankRune = player:getItem(Runes.blank) -- blank rune item
    if blankRune ~= nil then
      g_game.talk(words)
    end
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, math.random(3000, 7000))
end