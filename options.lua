local AddonName, NS = ...

local pairs = pairs
local tostring = tostring
local next = next
local GetCVar = GetCVar
local LibStub = LibStub

local tsort = table.sort
local tinsert = table.insert

local GetSpellTexture = C_Spell.GetSpellTexture

local SharedMedia = LibStub("LibSharedMedia-3.0")

local AceConfig = {
  name = AddonName,
  type = "group",
  childGroups = "tab",
  args = {
    general = {
      name = "General",
      type = "group",
      order = 1,
      args = {
        test = {
          name = "Enable test mode",
          desc = "Only works outside of instances.",
          type = "toggle",
          width = "full",
          order = 1,
          set = function(_, val)
            NS.db.general.test = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.test
          end,
        },
        ignoreNameplateAlpha = {
          name = "Ignore nameplate alpha",
          type = "toggle",
          width = "full",
          order = 2,
          set = function(_, val)
            NS.db.general.ignoreNameplateAlpha = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.ignoreNameplateAlpha
          end,
        },
        ignoreNameplateScale = {
          name = "Ignore nameplate scale",
          type = "toggle",
          width = "full",
          order = 3,
          set = function(_, val)
            NS.db.general.ignoreNameplateScale = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.ignoreNameplateScale
          end,
        },
        offsetX = {
          name = "Offset X",
          desc = "Offset left/right from the anchor point",
          type = "range",
          width = 1.25,
          order = 4,
          isPercent = false,
          min = -250,
          max = 250,
          step = 1,
          set = function(_, val)
            NS.db.general.offsetX = val
            NS.OFFSET.x = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.offsetX
          end,
        },
        offsetY = {
          name = "Offset Y",
          desc = "Offset top/bottom from the anchor point",
          type = "range",
          width = 1.25,
          order = 5,
          isPercent = false,
          min = -250,
          max = 250,
          step = 1,
          set = function(_, val)
            NS.db.general.offsetY = val
            NS.OFFSET.y = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.offsetY
          end,
        },
        spacer1 = {
          name = "",
          type = "description",
          order = 6,
          width = "full",
        },
        fontSize = {
          type = "range",
          name = "Font Size",
          width = 2.0,
          order = 7,
          min = 2,
          max = 64,
          step = 1,
          set = function(_, val)
            NS.db.general.fontSize = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.fontSize
          end,
        },
        spacer2 = {
          name = "",
          type = "description",
          order = 8,
          width = "full",
        },
        fontFamily = {
          type = "select",
          name = "Font Family",
          width = 2.0,
          order = 9,
          dialogControl = "LSM30_Font",
          values = SharedMedia:HashTable("font"),
          set = function(_, val)
            NS.db.general.fontFamily = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.fontFamily
          end,
        },
        spacer3 = {
          name = "",
          type = "description",
          order = 10,
          width = "full",
        },
        fontColor = {
          type = "color",
          name = "Font Color",
          width = 0.75,
          order = 11,
          hasAlpha = true,
          set = function(_, val1, val2, val3, val4)
            NS.db.general.fontColor.r = val1
            NS.db.general.fontColor.g = val2
            NS.db.general.fontColor.b = val3
            NS.db.general.fontColor.a = val4
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.fontColor.r,
              NS.db.general.fontColor.g,
              NS.db.general.fontColor.b,
              NS.db.general.fontColor.a
          end,
        },
        backgroundColor = {
          type = "color",
          name = "Background Color",
          width = 1.0,
          order = 12,
          hasAlpha = true,
          set = function(_, val1, val2, val3, val4)
            NS.db.general.backgroundColor.r = val1
            NS.db.general.backgroundColor.g = val2
            NS.db.general.backgroundColor.b = val3
            NS.db.general.backgroundColor.a = val4
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.backgroundColor.r,
              NS.db.general.backgroundColor.g,
              NS.db.general.backgroundColor.b,
              NS.db.general.backgroundColor.a
          end,
        },
        borderColor = {
          type = "color",
          name = "Border Color",
          width = 1.0,
          order = 13,
          hasAlpha = true,
          set = function(_, val1, val2, val3, val4)
            NS.db.general.borderColor.r = val1
            NS.db.general.borderColor.g = val2
            NS.db.general.borderColor.b = val3
            NS.db.general.borderColor.a = val4
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.borderColor.r,
              NS.db.general.borderColor.g,
              NS.db.general.borderColor.b,
              NS.db.general.borderColor.a
          end,
        },
        spacer4 = {
          name = "",
          type = "description",
          order = 14,
          width = "full",
        },
        labelEnabled = {
          name = "Label:",
          type = "toggle",
          width = 0.4,
          order = 15,
          set = function(_, val)
            NS.db.general.labelEnabled = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.labelEnabled
          end,
        },
        label = {
          name = "",
          desc = "",
          type = "input",
          width = 0.75,
          order = 16,
          disabled = function()
            return not NS.db.general.labelEnabled
          end,
          set = function(_, val)
            NS.db.general.label = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.label
          end,
        },
        spacer5 = {
          name = "",
          type = "description",
          order = 17,
          width = 0.1,
        },
        includeUnitName = {
          name = "Include Units Name (ex. 'Kill Psyfiend')",
          type = "toggle",
          width = 1.75,
          order = 18,
          set = function(_, val)
            NS.db.general.includeUnitName = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.includeUnitName
          end,
        },
        spacer6 = {
          name = "",
          type = "description",
          order = 19,
          width = "full",
        },
        uppercase = {
          name = "Uppercase",
          type = "toggle",
          width = 0.75,
          order = 20,
          set = function(_, val)
            NS.db.general.uppercase = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.uppercase
          end,
        },
        lowercase = {
          name = "Lowercase",
          type = "toggle",
          width = 0.75,
          order = 21,
          set = function(_, val)
            NS.db.general.lowercase = val
            NS.OnDbChanged()
          end,
          get = function(_)
            return NS.db.general.lowercase
          end,
        },
        cvars = {
          name = "Blizzard CVar Settings",
          type = "group",
          inline = true,
          order = 22,
          args = {
            varDesc = {
              name = "The following settings are required for the addon to work properly.",
              type = "description",
              width = "full",
              fontSize = "small",
              order = 1,
            },
            spacer1 = {
              name = "",
              type = "description",
              order = 2,
              width = "full",
            },
            showAlways = {
              name = "Show nameplates Always (CVar: 'nameplateShowAll')",
              desc = "In order for banners to show up on nameplates, this setting must be enabled.",
              type = "toggle",
              width = "full",
              order = 3,
              set = function(_, val)
                NS.db.cvars.showAlways = val
                NS.OnDbChanged()
              end,
              get = function(_)
                local cVar = GetCVar("nameplateShowAll") == 1 and true or false
                local db = NS.db.cvars.showAlways
                local val = cVar ~= db and cVar or db
                return val
              end,
            },
            showFriends = {
              name = "Show Friendly nameplates (CVar: 'nameplateShowFriends')",
              desc = "In order for banners to show up on friendly nameplates, this setting must be enabled.",
              type = "toggle",
              width = "full",
              order = 4,
              set = function(_, val)
                NS.db.cvars.showFriends = val
                NS.OnDbChanged()
              end,
              get = function(_)
                local cVar = GetCVar("nameplateShowFriends") == 1 and true or false
                local db = NS.db.cvars.showFriends
                local val = cVar ~= db and cVar or db
                return val
              end,
            },
            showFriendlyTotems = {
              name = "Show Friendly Totems (CVar: 'nameplateShowFriendlyTotems')",
              desc = "In order for banners to show up on friendly totem nameplates, this setting must be enabled.",
              type = "toggle",
              width = "full",
              order = 5,
              disabled = function()
                return not NS.db.cvars.showFriends
              end,
              set = function(_, val)
                NS.db.cvars.showFriendlyTotems = val
                NS.OnDbChanged()
              end,
              get = function(_)
                local cVar = GetCVar("nameplateShowFriendlyTotems") == 1 and true or false
                local db = NS.db.cvars.showFriendlyTotems
                local val = cVar ~= db and cVar or db
                return val
              end,
            },
            showFriendlyGuardians = {
              name = "Show Friendly Guardians (CVar: 'nameplateShowFriendlyGuardians')",
              desc = "In order for banners to show up on friendly guardian nameplates, this setting must be enabled.",
              type = "toggle",
              width = "full",
              order = 6,
              disabled = function()
                return not NS.db.cvars.showFriends
              end,
              set = function(_, val)
                NS.db.cvars.showFriendlyGuardians = val
                NS.OnDbChanged()
              end,
              get = function(_)
                local cVar = GetCVar("nameplateShowFriendlyGuardians") == 1 and true or false
                local db = NS.db.cvars.showFriendlyGuardians
                local val = cVar ~= db and cVar or db
                return val
              end,
            },
            showEnemies = {
              name = "Show Enemy nameplates (CVar: 'nameplateShowEnemies')",
              desc = "In order for banners to show up on enemy nameplates, this setting must be enabled.",
              type = "toggle",
              width = "full",
              order = 7,
              set = function(_, val)
                NS.db.cvars.showEnemies = val
                NS.OnDbChanged()
              end,
              get = function(_)
                local cVar = GetCVar("nameplateShowEnemies") == 1 and true or false
                local db = NS.db.cvars.showEnemies
                local val = cVar ~= db and cVar or db
                return val
              end,
            },
            showEnemyTotems = {
              name = "Show Enemy Totems (CVar: 'nameplateShowEnemyTotems')",
              desc = "In order for banners to show up on enemy totem nameplates, this setting must be enabled.",
              type = "toggle",
              width = "full",
              order = 8,
              disabled = function()
                return not NS.db.cvars.showEnemies
              end,
              set = function(_, val)
                NS.db.cvars.showEnemyTotems = val
                NS.OnDbChanged()
              end,
              get = function(_)
                local cVar = GetCVar("nameplateShowEnemyTotems") == 1 and true or false
                local db = NS.db.cvars.showEnemyTotems
                local val = cVar ~= db and cVar or db
                return val
              end,
            },
            showEnemyGuardians = {
              name = "Show Enemy Guardians (CVar: 'nameplateShowEnemyGuardians')",
              desc = "In order for banners to show up on enemy guardian nameplates, this setting must be enabled.",
              type = "toggle",
              width = "full",
              order = 9,
              disabled = function()
                return not NS.db.cvars.showEnemies
              end,
              set = function(_, val)
                NS.db.cvars.showEnemyGuardians = val
                NS.OnDbChanged()
              end,
              get = function(_)
                local cVar = GetCVar("nameplateShowEnemyGuardians") == 1 and true or false
                local db = NS.db.cvars.showEnemyGuardians
                local val = cVar ~= db and cVar or db
                return val
              end,
            },
            resetAllCVars = {
              name = "Reset All CVars Listed Above",
              desc = "Resets the CVars listed above to their default blizzard values.",
              type = "execute",
              width = 1.25,
              order = 10,
              func = function()
                NS.resetCVars()
              end,
            },
          },
        },
      },
    },
    npcs = {
      name = "NPCs",
      type = "group",
      childGroups = "tree",
      args = {
        title = {
          name = "If you want to add to this list message me on discord.",
          type = "description",
          order = 1,
          fontSize = "medium",
          width = "full",
        },
        discordDesc = {
          name = "Link:",
          type = "description",
          fontSize = "medium",
          order = 2,
          width = 0.2,
        },
        discord = {
          name = "",
          type = "input",
          order = 3,
          width = 1.2,
          get = function()
            return "https://discord.gg/A3g5qZqtdc"
          end,
        },
        spacer1 = {
          name = "",
          type = "description",
          order = 4,
          width = "full",
        },
      },
    },
  },
}
NS.AceConfig = AceConfig

NS.MakeNPCOption = function(npcId, npcInfo, index)
  local npcName = npcInfo.name
  local npcIcon = npcInfo.icon
  local npcEnabled = npcInfo.enabled
  local npcCVar = npcInfo.cVar
  local NPC_ID = tostring(npcId)

  local color = ""
  if npcEnabled then
    color = "|cFF00FF00" --green
  else
    color = "|cFFFF0000" --red
  end

  NS.AceConfig.args.npcs.args[NPC_ID] = {
    name = color .. npcName,
    icon = npcIcon,
    desc = "",
    type = "group",
    order = 10 + index,
    args = {
      cVar = {
        name = "Blizzard CVar: '" .. npcCVar .. "'",
        type = "description",
        fontSize = "small",
        width = "full",
        order = 1,
      },
      spacer1 = {
        name = "",
        type = "description",
        order = 2,
        width = "full",
      },
      enabled = {
        name = "Enable",
        type = "toggle",
        width = "full",
        order = 3,
        get = function(info)
          return NS.db[info[1]][info[2]][info[3]]
        end,
        set = function(info, value)
          NS.db[info[1]][info[2]][info[3]] = value

          if value then
            if value then
              color = "|cFF00FF00" --green
            else
              color = "|cFFFF0000" --red
            end

            NS.AceConfig.args.npcs.args[NPC_ID].name = color .. npcName
          else
            NS.AceConfig.args.npcs.args[NPC_ID].name = "|cFFFF0000" .. npcName
          end

          NS.OnDbChanged()
        end,
      },
    },
  }
end

-- NS.MakeCVarOption = function(key, cVarInfo, index)
--   local cVarName = cVarInfo.name
--   local cVarDesc = cVarInfo.desc
--   local cVarEnabled = cVarInfo.enabled

--   NS.AceConfig.args.general.args.cvars.args[key] = {
--     name = cVarName,
--     desc = cVarDesc,
--     type = "toggle",
--     width = "full",
--     order = 10 + index,
--     get = function(_)
--       return (NS.db and NS.db.cvars and next(NS.db.cvars) ~= nil) and NS.db.cvars[key] or cVarEnabled
--     end,
--     set = function(_, value)
--       NS.db.cvars[key] = value
--       NS.OnDbChanged()
--     end,
--   }
-- end

-- local npcList = {}
-- for npcId, npcData in pairs(NS.NPC_DATA) do
--   local iconID = GetSpellTexture(npcData.spellId)
--   local npc = {
--     [npcId] = {
--       name = npcData.name,
--       enabled = true,
--       icon = iconID,
--       spellId = npcData.spellId,
--       cVar = npcData.cVar,
--     },
--   }
--   tinsert(npcList, npc)
-- end
-- tsort(npcList, NS.SortListByName)
-- for i = 1, #npcList do
--   local npc = npcList[i]
--   if npc then
--     local npcId, npcInfo = next(npc)
--     NS.MakeNPCOption(npcId, npcInfo, i)
--   end
-- end

NS.BuildNPCOptions = function()
  local npcList = {}
  for npcId, npcInfo in pairs(NS.NPC_DATA) do
    local NPC_ID = tostring(npcId)
    local npcData = next(NS.db.npcs) ~= nil and NS.db.npcs[NPC_ID] or npcInfo
    local iconID = GetSpellTexture(npcInfo.spellId)
    local npc = {
      [npcId] = {
        name = npcInfo.name,
        enabled = npcData.enabled,
        icon = iconID,
        spellId = npcInfo.spellId,
        cVar = npcInfo.cVar,
      },
    }
    tinsert(npcList, npc)
  end
  tsort(npcList, NS.SortListByName)
  for i = 1, #npcList do
    local npc = npcList[i]
    if npc then
      local npcId, npcInfo = next(npc)
      NS.MakeNPCOption(npcId, npcInfo, i)
    end
  end
end

NS.BuildCVars = function(db)
  for key, cVarData in pairs(NS.CVAR_DATA) do
    local cVarEnabled = (db.cvars and next(db.cvars) ~= nil) and db.cvars[key]
      or (GetCVar(cVarData.cVar) == 1 and true or false)
    NS.DefaultDatabase.cvars[key] = cVarEnabled
  end
end
