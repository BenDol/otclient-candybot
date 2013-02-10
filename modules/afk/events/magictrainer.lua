-- Magic Train Logic
AfkModule.MagicTrain = {}
MagicTrain = AfkModule.MagicTrain

function MagicTrain.Event(event)
  if g_game.isOnline() then
    local player = g_game.getLocalPlayer()
    if not player then return end

    local manaRequired = AfkModule.getPanel():getChildById('MagicTrainManaRequired'):getValue()
    if player:getManaPercent() >= manaRequired then
      local words = AfkModule.getPanel():getChildById('MagicTrainSpellText'):getText()

      local spell = nil
      if BotModule.isPrecisionMode() then
        spell = Spells.getSpellByWords(words)
      end

      if spell then
        if player:getMana() >= spell.mana then
          g_game.talk(spell.words)
        end
      else
        g_game.talk(words)
      end
    end
  end

  EventHandler.rescheduleEvent(AfkModule.getModuleId(), event, Helper.safeDelay(2000, 3000))
end