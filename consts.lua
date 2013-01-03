options = {
  ['AutoHeal'] = false,
  ['HealSpellText'] = 'exura',
  ['HealthText'] = '75%',

  ['AutoHealthItem'] = false,
  ['ItemHealthText'] = '75%',
  ['CurrentHealthItem'] = 266,
  
  ['AutoManaItem'] = false,
  ['ItemManaText'] = '75%',
  ['CurrentManaItem'] = 268,

  ['AutoHaste'] = false,
  ['HasteSpellText'] = 'utani hur',
  ['HasteText'] = '50%',

  ['AutoParalyzeHeal'] = false,
  ['ParalyzeHealText'] = 'utani hur',

  ['AutoManaShield'] = false,
  ['CreatureAlert'] = false,
  ['BlackList'] = '',
  ['WhiteList'] = '',

  ['AutoEat'] = false,
  ['AutoEatSelect'] = 'Meat',

  ['AntiKick'] = false,
  ['AutoFishing'] = false,

  ['RuneMake'] = false,
  ['RuneSpellText'] = 'adori gran',
  ['RuneMakeOpenContainer'] = true,
  
  ['AutoReplaceWeapon'] = false,
  ['AutoReplaceWeaponSelect'] = 'Left Hand',
  ['ItemToReplace'] = 3277,

  ['MagicTrain'] = false,
  ['MagicTrainSpellText'] = 'utani hur'
}

potions = {
  ['Ultimate HP'] = 8473,
  ['Great HP'] = 7591,
  ['Strong HP'] = 7588,
  ['HP'] = 266,
  ['Great MP'] = 238,
  ['Strong MP'] = 237,
  ['MP'] = 268,
  ['Great SP'] = 7642
}

foods = {
  ['Carrot'] = 3595,
  ['Meat'] = 3577,
  ['Fish'] = 3578,
  ['Salmon'] = 3579,
  ['Ham'] = 3582,
  ['Dragon Ham'] = 3583,
  ['Pears'] = 3584,
  ['Bread'] = 3600,
  ['Pear'] = 3584,
  ['Apple'] = 3585,
  ['Orange'] = 3586,
  ['Banana'] = 3587,
  ['Blueberry'] = 3588,
  ['Coconut'] = 3589,
  ['Cherry'] = 3590,
  ['Strawberry'] = 3591,
  ['Grape'] = 3592,
  ['Melon'] = 3593,
  ['Pumpkin'] = 3594,
  ['Cookie'] = 3598,
  ['Candy Cane'] = 3599,
  ['Roll'] = 3601,
  ['Brown Bread'] = 3602,
  ['Cheese'] = 3607,
  ['Brown Mushroom'] = 3725,
  ['Tortoise Eggs'] = 5678,
  ['Fire Mushroom'] = 3731
}

rings = {
  ['Time Ring'] = 3053,
  ['Energy Ring'] = 3051,
  ['Stealth Ring'] = 3049,
  ['Ring of Healing'] = 3098,
  ['Life Ring'] = 3052,
  ['Might Ring'] = 3048
}

amulets = {
  ['Stone Skin Amulet'] = 3081,
  ['Glacier Amulet'] = 815,
  ['Dragon Necklace'] = 3085,
  ['Sacred Tree Amulet'] = 9302
}

spells = {
  ['Strong Haste'] = 'utani gran hur',
  ['Haste'] = 'utani hur',
  ['Charge'] = 'utani tempo hur'
}

dashDelays = {
  ['Slow'] = 300,
  ['Normal'] = 120,
  ['Fast'] = 0
}

spears = {
  ['Spear'] = 3277,
  ['Enchanted Spear'] = 7367,
  ['Royal Spear'] = 7378,
  ['Small Stone'] = 1781,
  ['Throwing Star'] = 3287,
  ['Assassin Star'] = 7368
}

fishing = {
  ['fishing rod'] = 3483,
  ['worm'] = 3492
}

water = { 4599 }

t = {
  name = "pt",
  translation = {
    ["Kilouco\'s Bot"] = 'Bot do Kilouco',
    ["Protection"] = 'Proteção',

    ["Auto Heal"] = "Auto Recuperação",
    ["Heal your character automatically."] = 'Recupera o personagem automaticamente.',
    ["Spell text:"] = "Palavras da magia:",
    ["Health Item"] = "Item de Vida",
    ["Automatically use health items/potions on self."] = "Usar itens de vida em si mesmo automaticamente.",
    ["Select\nitem"] = "Selecione\nitem",
    ["On health lower than:"] = "Com vida menor que:",
    ["Mana Item"] = "Item de Mana",
    ["Automatically use mana items/potions on self."] = "Usar itens de mana em si mesmo automaticamente.",
    ["On mana lower than:"] = "Com mana menor que:",
    ["Auto Haste"] = "Haste automático",
    ["Haste your character automatically."] = "Dá \"Haste\" automaticamente.",
    ["DO NOT haste when\nhealth lower than:"] = "NÃO DAR haste em\nvida menor que:",
    ["Auto Paralyze Heal"] = "Recuperar \"paralyze\"",
    ["Automatically cast a spell when paralized."] = "Solta uma magia quando paralisado.",
    ["Spell to use when paralyzed."] = "Magia para quando quando paralisado.",
    ["Auto Magic Shield"] = "Magic Shield automático",
    ["Automatically keeps character magic shielded."] = "Mantém o jogador com Magic Shield.",

    ["Alert on creature appearance"] = "Alertar no aparecimento de criaturas.",
    ["Play a sound alert when a creature appears"] = "Toca um alerta sonoro quando uma criatura aparece.",
    ["Creature List"] = "Lista de criaturas",
    ["Eat Food"] = "Comer",
    ["Eat food automatically."] = "Come automaticamente.",
    ["Anti-kick"] = "Anti-kick",
    ["Character \"dances\" to avoid being kicked for being idle for too long."] = "Personagem do jogador \"dança\" para evitar de ser derrubado do jogo.",
    ["Auto Fishing"] = "Pesca automática",
    ["Player will be fishing as long as there are worms."] = "Jogador ficará pescando enquanto houver minhoca.",
    ["Rune Maker"] = "Rune Maker",
    ["Automatically make runes."] = "Faz runas automaticamente.",
    ["Rune Spell Text"] = "Magia de runa",
    ["Check open containers"] = "Verificar conteiners",
    ["Check if there is a blank rune in an open container\nin order to avoid saying the spell worlds repetitively\nwithout the magic item."] = "Verifica se há \"Blank Rune\" visível em uma mochila aberta\npara evitar que o personagem fique repetindo\nas palavras mágicas sem o item.",
    ["Auto Replace Weapons"] = "Repor armas",
    ["Automatically \"refill\" used throwing weapons (container of replacing items must be open)."] = "Automaticamente repõe armas de jogar como as \"Spears\".",
    ["Item to replace with"] = "Item a ser reposto",
    ["Select\nitem"] = "Selecionar\nitem",
    ["Magic Training"] = "Treinar nível mágico",
    ["Trains magic level (use a spell whenever mana is full)."] = "Treina nível mágico (usa uma magia sempre que a mana está cheia).",
    ["Spell to use"] = "Magia a ser usada",




}}
Locales.installLocale(t)