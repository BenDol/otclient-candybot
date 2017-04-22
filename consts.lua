--[[
  @Authors: Ben Dol (BeniS)
  @Details: Constant variable declartions.
]]

Consts = {}

RestoreType = {
  cast = 1,
  item = 2
}

Potions = {
  ['Ultimate HP'] = 8473,
  ['Great HP'] = 7591,
  ['Strong HP'] = 7588,
  ['HP'] = 266,
  ['Great MP'] = 238,
  ['Strong MP'] = 237,
  ['MP'] = 268,
  ['Great SP'] = 7642
}

Foods = {
  ['Walnut'] = 836,
  ['Peanut'] = 841,
  ['Marlin'] = 901,
  ['Cream Cake'] = 904,
  ['Carrot'] = 3595,
  ['Meat'] = 3577,
  ['Fish'] = 3578,
  ['Salmon'] = 3579,
  ['Shrimp'] = 3581,
  ['Ham'] = 3582,
  ['Dragon Ham'] = 3583,
  ['Pears'] = 3584,
  ['Bread'] = 3600,
  ['Northern Pike'] = 3580,
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
  ['Tomato'] = 3596,
  ['Corn'] = 3597,
  ['Cookie'] = 3598,
  ['Candy Cane'] = 3599,
  ['Roll'] = 3601,
  ['Brown Bread'] = 3602,
  ['Lump of Dough'] = 3604,
  ['Egg'] = 3606,
  ['Cheese'] = 3607,
  ['Red Mushroom'] = 3724,
  ['White Mushroom '] = 3723,
  ['Brown Mushroom'] = 3725,
  ['Orange Mushroom'] = 3726,
  ['Dark Mushroom'] = 3728,
  ['Some Mushrooms (Brown)'] = 3729,
  ['Some Mushrooms'] = 3730,
  ['Fire Mushroom'] = 3731,
  ['Green Mushroom'] = 3732,
  ['Mango'] = 5096,
  ['Tortoise Eggs'] = 5678,
  ['Cake'] = 6277,
  ['Lump of Cake Dough'] = 6276,
  ['Decorated Cake'] = 6278,
  ['Valentine\'s Cake'] = 6392,
  ['Gingerbreadman'] = 6500,
  ['Coloured Egg (Blue)'] = 6543,
  ['Coloured Egg (Green)'] = 6544,
  ['Coloured Egg (Purple)'] = 6545,
  ['Coloured Egg (Red)'] = 6542,
  ['Coloured Egg (Yellow)'] = 6541,
  ['Candy'] = 6569,
  ['Bar of Chocolate'] = 6574,
  ['Rainbow Trout'] = 7158,
  ['Green Perch'] = 7159,
  ['Ice Cream Cone (Crispy Chocolate Chips)'] = 7372,
  ['Ice Cream Cone (Velvet Vanilla)'] = 7373,
  ['Ice Cream Cone (Chilly Cherry)'] = 7375,
  ['Potato'] = 8010,
  ['Plum'] = 8011,
  ['Raspberry'] = 8012,
  ['Lemon'] = 8013,
  ['Cucumber'] = 8014,
  ['Onion'] = 8015,
  ['Beetroot'] = 8017,
  ['Lump of Chocolate Dough'] = 8018,
  ['Chocolate Cake'] = 8019,
  ['Yummy Gummy Worm'] = 8177,
  ['Bulb of Garlic'] = 8197,
  ['Baking Tray (With Dough)'] = 8020,
  ['Rice Ball'] = 10329,
  ['Ectoplasmic Sushi'] = 11681,
  ['Haunch of Boar'] = 12310,
  ['Deepling Filet'] = 14085,
  ['Soft Cheese'] = 17820,
  ['Rat Cheese'] = 17821,
  ['Meat @ Rare'] = 2666,
  ['Ham @ Rare'] = 2671,
}

RingIds = {
  [3092] = 3095, [3091] = 3094, [3093] = 3096, [3052] = 3089, [3098] = 3100,
  [3097] = 3099, [3051] = 3088, [3053] = 3090, [3049] = 3086, [9593] = 9593,
  [9393] = 9392, [3007] = 3007, [6299] = 6300, [9585] = 9585, [3048] = 3048,
  [3050] = 3087, [3245] = 3245, [3006] = 3006, [349] = 349, [3004] = 3004
}

Rings = {
  ['Dwarven Ring'] = 3097,
  ['Time Ring'] = 3053,
  ['Energy Ring'] = 3051,
  ['Stealth Ring'] = 3049,
  ['Ring of Healing'] = 3098,
  ['Life Ring'] = 3052,
  ['Might Ring'] = 3048
}

Amulets = {
  ['Stone Skin Amulet'] = 3081,
  ['Glacier Amulet'] = 815,
  ['Dragon Necklace'] = 3085,
  ['Sacred Tree Amulet'] = 9302
}

Spears = {
  ['Spear'] = 3277,
  ['Enchanted Spear'] = 7367,
  ['Royal Spear'] = 7378,
  ['Small Stone'] = 1781,
  ['Throwing Star'] = 3287,
  ['Assassin Star'] = 7368
}

Fishing = {
  ['Fishing Rod'] = 3483,
  ['Worm'] = 3492,
  ['Tiles'] = {4597,4598,4599,4600,4601,4602},
  ['Weight'] = 8.30
}

Runes = {
  blank = 3147
  -- blank = 2260 -- raretibia
}

Water = { 4597,4598,4599,4600,4601,4602,4635,4639,4640 }

Flasks = { 283, 284, 285 }

AttackModes = {
  None = "No Mode",
  SpellMode = "Spell Mode",
  ItemMode = "Item Mode"
}

--[[Locales.installLocale({
  name = "pt",
  translation = {
    ["Kilouco\'s Bot"] = 'Bot do Kilouco',
    ["Support"] = 'Apoiar',

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
    ["Spell to use"] = "Magia a ser usada"
  }
})]]