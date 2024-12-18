local _, NS = ...

local pairs = pairs
local next = next
local tostring = tostring

local tsort = table.sort
local tinsert = table.insert

local GetSpellTexture = C_Spell.GetSpellTexture

NS.CVAR_DATA = {
  ["showAlways"] = {
    name = "Show nameplates Always (CVar: 'nameplateShowAll')",
    desc = "In order for banners to show up on nameplates, this setting must be enabled.",
    cVar = "nameplateShowAll",
    order = 1,
    enabled = false,
  },
  ["showFriends"] = {
    name = "Show Friendly nameplates (CVar: 'nameplateShowFriends')",
    desc = "In order for banners to show up on friendly nameplates, this setting must be enabled.",
    cVar = "nameplateShowFriends",
    order = 2,
    enabled = false,
  },
  ["showFriendlyTotems"] = {
    name = "Show Friendly Totems (CVar: 'nameplateShowFriendlyTotems')",
    desc = "In order for banners to show up on friendly totem nameplates, this setting must be enabled.",
    cVar = "nameplateShowFriendlyTotems",
    order = 3,
    enabled = false,
  },
  ["showFriendlyGuardians"] = {
    name = "Show Friendly Guardians (CVar: 'nameplateShowFriendlyGuardians')",
    desc = "In order for banners to show up on friendly guardian nameplates, this setting must be enabled.",
    cVar = "nameplateShowFriendlyGuardians",
    order = 4,
    enabled = false,
  },
  ["showEnemies"] = {
    name = "Show Enemy nameplates (CVar: 'nameplateShowEnemies')",
    desc = "In order for banners to show up on enemy nameplates, this setting must be enabled.",
    cVar = "nameplateShowEnemies",
    order = 5,
    enabled = false,
  },
  ["showEnemyTotems"] = {
    name = "Show Enemy Totems (CVar: 'nameplateShowEnemyTotems')",
    desc = "In order for banners to show up on enemy totem nameplates, this setting must be enabled.",
    cVar = "nameplateShowEnemyTotems",
    order = 6,
    enabled = false,
  },
  ["showEnemyGuardians"] = {
    name = "Show Enemy Guardians (CVar: 'nameplateShowEnemyGuardians')",
    desc = "In order for banners to show up on enemy guardian nameplates, this setting must be enabled.",
    cVar = "nameplateShowEnemyGuardians",
    order = 7,
    enabled = false,
  },
}

-- spellId is used to get an iconId
NS.NPC_DATA = {
  ["101398"] = {
    name = "Psyfiend",
    spellId = 199824,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 0.49, 0, 1, 1 },
    enabled = true,
  },
  ["119052"] = {
    name = "War Banner",
    spellId = 236320,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 1, 0, 1, 1 },
    enabled = true,
  },
  ["107100"] = {
    name = "Observer",
    spellId = 112869,
    cVar = "nameplateShow(Friendly/Enemy)Guardians",
    glow = { 1, 0.69, 0, 1 },
    enabled = true,
  },
  ["135002"] = {
    name = "Demonic Tyrant",
    spellId = 265187,
    cVar = "nameplateShow(Friendly/Enemy)Guardians",
    glow = { 1, 0.69, 0, 1 },
    enabled = true,
  },
  ["17252"] = { -- NEED GLOW
    name = "Grimoire: Felguard",
    spellId = 30146,
    cVar = "nameplateShow(Friendly/Enemy)Guardians",
    enabled = true,
  },
  ["225493"] = { -- NEED GLOW
    name = "Doomguard",
    spellId = 453568,
    cVar = "nameplateShow(Friendly/Enemy)Guardians",
    enabled = true,
  },
  ["103673"] = { -- NEED GLOW
    name = "Darkglare",
    spellId = 205180,
    cVar = "nameplateShow(Friendly/Enemy)Guardians",
    enabled = true,
  },
  ["27829"] = { -- NEED GLOW
    name = "Gargoyle",
    spellId = 317250,
    cVar = "nameplateShow(Friendly/Enemy)Guardians",
    enabled = true,
  },
  ["105451"] = {
    name = "Counterstrike Totem",
    spellId = 204331,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 1, 0.27, 0.59, 1 },
    enabled = true,
  },
  ["5925"] = {
    name = "Grounding Totem",
    spellId = 204336,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 1, 0, 1, 1 },
    enabled = true,
  },
  ["97369"] = {
    name = "Liquid Magma Totem",
    spellId = 192222,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 1, 0.69, 0, 1 },
    enabled = true,
  },
  ["53006"] = {
    name = "Spirit Link Totem",
    spellId = 98008,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 0, 1, 0.78, 1 },
    enabled = true,
  },
  ["5913"] = {
    name = "Tremor Totem",
    spellId = 8143,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 0.49, 0.9, 0.08, 1 },
    enabled = true,
  },
  ["179867"] = {
    name = "Static Field Totem",
    spellId = 355580,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 0, 1, 0.78, 1 },
    enabled = true,
  },
  ["61245"] = {
    name = "Capacitor Totem",
    spellId = 192058,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 1, 0.69, 0, 1 },
    enabled = true,
  },
  ["105427"] = {
    name = "Totem of Wrath",
    spellId = 204330,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 0.78, 0.51, 0.39, 1 },
    enabled = true,
  },
  ["104818"] = {
    name = "Ancestral Protection Totem",
    spellId = 207399,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 0, 1, 0.78, 1 },
    enabled = true,
  },
  ["59764"] = {
    name = "Healing Tide Totem",
    spellId = 108280,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 0, 1, 0.39, 1 },
    enabled = true,
  },
  ["59712"] = {
    name = "Stone Bulwark Totem",
    spellId = 108270,
    cVar = "nameplateShow(Friendly/Enemy)Totems",
    glow = { 0.98, 0.75, 0.17, 1 },
    enabled = true,
  },
}

NS.NPC_SHOW_LIST = {}

for npcId, _ in pairs(NS.NPC_DATA) do
  tinsert(NS.NPC_SHOW_LIST, npcId)
end

NS.NPC_HIDE_LIST = {
  "89",
  "416",
  "417",
  "1860",
  "1863",
  "229798",
  "63508",
  "143622",
  "98035",
  "135816",
  "136402",
  "136399",
  "31216",
  "95072",
  "29264",
  "27829",
  "24207",
  "69791",
  "69792",
  "26125",
  "62821",
  "62822",
  "142666",
  "142668",
  "32641",
  "32642",
  "189988",
  "103822",
  "198489",
  "26125",
  "55659",
  "62982",
  "105419",
  "198757",
  "192337",
  "89715",
  "165189",
  "103268",
  "65282",
  "99541",
  "163366",
  "103320",
  "17252",
  "110063",
  "197280",
  "19668",
  "166949",
  "107024",
  "100820",
  "95061",
  "77942",
  "77936",
  "61056",
  "61029",
  "106988",
  "54983",
  "62005",
  "32638",
  "32639",
  "208441",
  "224466",
  "97022",
  "217429",
  "231086",
  "231085",
}

NS.SortListByName = function(a, b)
  if a and b then
    local _, aNPCInfo = next(a)
    local _, bNPCInfo = next(b)
    local aName = aNPCInfo.name
    local bName = bNPCInfo.name
    if aName and bName then
      if aName ~= bName then
        return aName < bName
      end
    end
  end
end

local DefaultDatabase = {
  general = {
    test = false,
    ignoreNameplateAlpha = true,
    ignoreNameplateScale = true,
    offsetX = 0,
    offsetY = 0,
    fontSize = 12,
    fontFamily = "Friz Quadrata TT",
    fontColor = {
      r = 255 / 255,
      g = 255 / 255,
      b = 255 / 255,
      a = 1.0,
    },
    backgroundColor = {
      r = 175 / 255,
      g = 34 / 255,
      b = 47 / 255,
      a = 1.0,
    },
    borderColor = {
      r = 255 / 255,
      g = 255 / 255,
      b = 255 / 255,
      a = 1.0,
    },
    labelEnabled = true,
    label = "Kill",
    includeUnitName = true,
    uppercase = false,
    lowercase = false,
  },
  cvars = {
    showAlways = false,
    showFriends = false,
    showFriendlyTotems = false,
    showFriendlyGuardians = false,
    showEnemies = false,
    showEnemyTotems = false,
    showEnemyGuardians = false,
  },
  npcs = {},
}
NS.DefaultDatabase = DefaultDatabase

NS.OFFSET = {
  x = DefaultDatabase.general.offsetX,
  y = DefaultDatabase.general.offsetY,
}

local npcList = {}
for npcId, npcData in pairs(NS.NPC_DATA) do
  local iconId = GetSpellTexture(npcData.spellId)
  local npc = {
    [npcId] = {
      name = npcData.name,
      enabled = npcData.enabled,
      icon = iconId,
      spellId = npcData.spellId,
      cVar = npcData.cVar,
    },
  }
  tinsert(npcList, npc)
end
tsort(npcList, NS.SortListByName)
for i = 1, #npcList do
  local npc = npcList[i]
  if npc then
    local npcId, npcInfo = next(npc)
    local NPC_ID = tostring(npcId)
    NS.DefaultDatabase.npcs[NPC_ID] = {
      enabled = npcInfo.enabled,
    }
  end
end

--[[
-- nameplatePersonalShowAlways - 0
-- nameplatePersonalShowInCombat - 1
-- nameplatePersonalShowWithTarget - 1
-- nameplateShowAll - 1 - Show nameplates at all times. (Needs to be 1)
-- nameplateShowDebuffsOnFriendly - 1
-- nameplateShowEnemies - 1
-- nameplateShowEnemyGuardians - 1
-- nameplateShowEnemyMinions - 0
-- nameplateShowEnemyMinus - 0
-- nameplateShowEnemyPets - 0
-- nameplateShowEnemyTotems - 1
-- nameplateShowFriendlyBuffs - 1
-- nameplateShowFriendlyGuardians - 1 - Turn this on to display Unit Nameplates for friendly guardians. (this setting shows warlock observer, demonic tyrant)
-- nameplateShowFriendlyMinions - 0 - Friendly pets, guardians, totems (there are individual options for each of these)
-- nameplateShowFriendlyNPCs - 0
-- nameplateShowFriendlyPets - 0
-- nameplateShowFriendlyTotems - 1
-- nameplateShowFriends - 1
-- nameplateShowOnlyNames - Whether to hide the nameplate bars.
-- nameplateShowPersonalCooldowns - 1
-- nameplateShowSelf - 1
-- nameplateTargetBehindMaxDistance - 60 - The max distance to show the target nameplate when the target is behind the camera.
-- nameplateTargetRadialPosition - 1 - When target is off screen, position its nameplate radially around sides and bottom.
-- ShowClassColorInFriendlyNameplate - 1 - Class color for friendly nameplates.
-- ShowClassColorInNameplate - 1 - Toggles class colors in the background of Nameplate health bar for enemy players.
-- showVKeyCastbarOnlyOnTarget - Only show the enemy cast bar on your current target.
-- showVKeyCastbarSpellName - 1 - Show the name of the spell on the cast bar on nameplates.
-- /run SetCVar("nameplateShowPersonalCooldowns", 1)
-- /run SetCVar("autoSelfCast", GetCVarDefault("autoSelfCast"))
-- /run print(GetCVar("nameplatePersonalShowWithTarget"))
-- /console cvar_default
]]
