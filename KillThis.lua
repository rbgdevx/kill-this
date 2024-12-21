local AddonName, NS = ...

local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitAffectingCombat = UnitAffectingCombat
local UnitName = UnitName
local issecure = issecure
local pairs = pairs
local LibStub = LibStub
local next = next
local select = select
local SetCVar = SetCVar
local GetCVar = GetCVar

local split = string.split

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local GetNamePlates = C_NamePlate.GetNamePlates
local After = C_Timer.After

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

local KillThis = {}
NS.KillThis = KillThis

local KillThisFrame = CreateFrame("Frame", AddonName .. "Frame")
KillThisFrame:SetScript("OnEvent", function(_, event, ...)
  if KillThis[event] then
    KillThis[event](KillThis, ...)
  end
end)
KillThisFrame.wasOnLoadingScreen = true
KillThisFrame.instanceType = nil
KillThisFrame.inArena = false
KillThisFrame.loaded = false
KillThisFrame.dbChanged = false
NS.KillThis.frame = KillThisFrame

local function GetUnitFrame(nameplate)
  return nameplate.UnitFrame
end

local function GetHealthBarFrame(nameplate)
  local UnitFrame = GetUnitFrame(nameplate)
  return UnitFrame.HealthBarsContainer
end

local function createString(unit)
  local label = NS.db.general.labelEnabled and NS.db.general.label .. " " or ""
  local str = NS.db.general.includeUnitName and label .. UnitName(unit) or "Kill This"
  local upperCaseStr = string.upper(str)
  local lowerCaseStr = string.lower(str)
  local finalString = NS.db.general.uppercase and upperCaseStr or NS.db.general.lowercase and lowerCaseStr or str

  return finalString
end

local function CreateText(banner, unit)
  local text = banner:CreateFontString(nil, "OVERLAY")

  text:SetFont(SharedMedia:Fetch("font", NS.db.general.fontFamily), NS.db.general.fontSize, "NONE")
  text:SetTextColor(
    NS.db.general.fontColor.r,
    NS.db.general.fontColor.g,
    NS.db.general.fontColor.b,
    NS.db.general.fontColor.a
  )
  text:SetShadowColor(0, 0, 0, 1.0)
  text:SetShadowOffset(1, -1)
  text:SetJustifyH("CENTER")
  text:SetJustifyV("MIDDLE")
  text:SetPoint("CENTER", banner, "CENTER", 0, 0)
  text:Show()

  local str = createString(unit)
  text:SetText(str)

  banner:SetWidth(text:GetStringWidth() + 12)
  banner:SetHeight(text:GetStringHeight() + 8)

  banner.text = text
end

local borderSize = 7
local borderOffset = 4
local borderInset = 1

local function CreateTexture(banner)
  local background = CreateFrame("Frame", nil, banner, "BackdropTemplate")

  background:SetBackdrop({
    bgFile = SharedMedia:Fetch("background", "Solid"),
    edgeFile = SharedMedia:Fetch("border", "Blizzard Tooltip"),
    edgeSize = borderSize,
    insets = {
      left = borderInset,
      right = borderInset,
      top = borderInset,
      bottom = borderInset,
    },
  })
  background:SetBackdropBorderColor(
    NS.db.general.borderColor.r,
    NS.db.general.borderColor.g,
    NS.db.general.borderColor.b,
    NS.db.general.borderColor.a
  )
  background:SetBackdropColor(
    NS.db.general.backgroundColor.r,
    NS.db.general.backgroundColor.g,
    NS.db.general.backgroundColor.b,
    NS.db.general.backgroundColor.a
  )

  background:SetFrameLevel(banner:GetFrameLevel())
  background:ClearAllPoints()
  background:SetPoint("BOTTOMLEFT", banner, "BOTTOMLEFT", -1 * borderOffset, -1 * borderOffset)
  background:SetPoint("TOPRIGHT", banner, "TOPRIGHT", borderOffset, borderOffset)
  background:Show()

  banner.background = background
end

local function CreateBanner(parent, unit)
  local banner = CreateFrame("Frame", nil, parent)

  banner:SetWidth(150)
  banner:SetHeight(25)
  banner:SetIgnoreParentAlpha(NS.db.general.ignoreNameplateAlpha)
  banner:SetIgnoreParentScale(NS.db.general.ignoreNameplateScale)
  banner:SetAlpha(1)
  banner:SetScale(1)

  banner:ClearAllPoints()
  banner:SetPoint("BOTTOM", parent, "TOP", NS.OFFSET.x, NS.OFFSET.y)
  banner:Show()

  CreateText(banner, unit)
  CreateTexture(banner)

  return banner
end

local function addBanner(nameplate, guid)
  local unit = nameplate.namePlateUnitToken

  local isPlayer = UnitIsPlayer(unit)
  local isSelf = UnitIsUnit(unit, "player")
  local isFriend = UnitIsFriend("player", unit)
  local isEnemy = UnitIsEnemy("player", unit)
  -- local canAttack = UnitCanAttack("player", unit)
  local isDeadOrGhost = UnitIsDeadOrGhost(unit)

  local npcID = select(6, split("-", guid))
  local hideDead = isDeadOrGhost
  local hideSelf = isSelf
  local hidePlayers = isPlayer
  local hideFriendly = NS.db.general.showFriendly == false and isFriend
  local hideEnemy = NS.db.general.showEnemy == false and isEnemy
  local hideNotInList = NS.isNPCInList(NS.NPC_SHOW_LIST, npcID) ~= true
  local hideTestMode = not NS.db.general.test
  local hideNotEnabled = not NS.db.npcs[npcID] or NS.db.npcs[npcID].enabled ~= true
  local hideBanner = hideTestMode
    and (hideDead or hideSelf or hidePlayers or hideFriendly or hideEnemy or hideNotInList or hideNotEnabled)

  if hideBanner then
    if nameplate.killThisBanner then
      nameplate.killThisBanner:Hide()
    end
    return
  end

  if not nameplate.killThisBanner then
    nameplate.killThisBanner = CreateBanner(nameplate, unit)
  end

  local str = createString(unit)
  nameplate.killThisBanner.text:SetText(str)
  nameplate.killThisBanner.text:SetFont(
    SharedMedia:Fetch("font", NS.db.general.fontFamily),
    NS.db.general.fontSize,
    "NONE"
  )
  nameplate.killThisBanner.text:SetTextColor(
    NS.db.general.fontColor.r,
    NS.db.general.fontColor.g,
    NS.db.general.fontColor.b,
    NS.db.general.fontColor.a
  )
  nameplate.killThisBanner.background:SetBackdropBorderColor(
    NS.db.general.borderColor.r,
    NS.db.general.borderColor.g,
    NS.db.general.borderColor.b,
    NS.db.general.borderColor.a
  )
  nameplate.killThisBanner.background:SetBackdropColor(
    NS.db.general.backgroundColor.r,
    NS.db.general.backgroundColor.g,
    NS.db.general.backgroundColor.b,
    NS.db.general.backgroundColor.a
  )
  nameplate.killThisBanner:SetIgnoreParentAlpha(NS.db.general.ignoreNameplateAlpha)
  nameplate.killThisBanner:SetIgnoreParentScale(NS.db.general.ignoreNameplateScale)
  nameplate.killThisBanner:SetWidth(nameplate.killThisBanner.text:GetStringWidth() + 12)
  nameplate.killThisBanner:SetHeight(nameplate.killThisBanner.text:GetStringHeight() + 8)
  nameplate.killThisBanner:ClearAllPoints()
  nameplate.killThisBanner:SetPoint("BOTTOM", nameplate, "TOP", NS.OFFSET.x, NS.OFFSET.y)
  nameplate.killThisBanner:Show()
end

local function refreshNameplates(override)
  if not override and KillThisFrame.wasOnLoadingScreen then
    return
  end

  for _, nameplate in pairs(GetNamePlates(issecure())) do
    if nameplate then
      local guid = UnitGUID(nameplate.namePlateUnitToken)
      if guid then
        KillThis:attachToNameplate(nameplate, guid)
      end
    end
  end
end

NS.resetCVars = function()
  -- All Nameplates
  local nameplateShowAll = GetCVar("nameplateShowAll")
  NS.db.cvars.showAlways = nameplateShowAll == 1 and true or false
  SetCVar("nameplateShowAll", nameplateShowAll)

  -- Friendly Nameplates
  local nameplateShowFriends = GetCVar("nameplateShowFriends")
  NS.db.cvars.showFriends = nameplateShowFriends == 1 and true or false
  SetCVar("nameplateShowFriends", nameplateShowFriends)

  local nameplateShowFriendlyTotems = GetCVar("nameplateShowFriendlyTotems")
  NS.db.cvars.showFriendlyTotems = nameplateShowFriendlyTotems == 1 and true or false
  SetCVar("nameplateShowFriendlyTotems", nameplateShowFriendlyTotems)

  local nameplateShowFriendlyGuardians = GetCVar("nameplateShowFriendlyGuardians")
  NS.db.cvars.showFriendlyGuardians = nameplateShowFriendlyGuardians == 1 and true or false
  SetCVar("nameplateShowFriendlyGuardians", nameplateShowFriendlyGuardians)

  -- Enemy Nameplates
  local nameplateShowEnemies = GetCVar("nameplateShowEnemies")
  NS.db.cvars.showEnemies = nameplateShowEnemies == 1 and true or false
  SetCVar("nameplateShowEnemies", nameplateShowEnemies)

  local nameplateShowEnemyTotems = GetCVar("nameplateShowEnemyTotems")
  NS.db.cvars.showEnemyTotems = nameplateShowEnemyTotems == 1 and true or false
  SetCVar("nameplateShowEnemyTotems", nameplateShowEnemyTotems)

  local nameplateShowEnemyGuardians = GetCVar("nameplateShowEnemyGuardians")
  NS.db.cvars.showEnemyGuardians = nameplateShowEnemyGuardians == 1 and true or false
  SetCVar("nameplateShowEnemyGuardians", nameplateShowEnemyGuardians)

  refreshNameplates(true)
end

local function updateCVars()
  -- All Nameplates
  SetCVar("nameplateShowAll", NS.db.cvars.showAlways and 1 or 0)

  -- Friendly Nameplates
  SetCVar("nameplateShowFriends", NS.db.cvars.showFriends and 1 or 0)
  SetCVar("nameplateShowFriendlyTotems", NS.db.cvars.showFriendlyTotems and 1 or 0)
  SetCVar("nameplateShowFriendlyGuardians", NS.db.cvars.showFriendlyGuardians and 1 or 0)

  -- Enemy Nameplates
  SetCVar("nameplateShowEnemies", NS.db.cvars.showEnemies and 1 or 0)
  SetCVar("nameplateShowEnemyTotems", NS.db.cvars.showEnemyTotems and 1 or 0)
  SetCVar("nameplateShowEnemyGuardians", NS.db.cvars.showEnemyGuardians and 1 or 0)
end

function KillThis:detachFromNameplate(nameplate)
  if nameplate.HealthBarsContainer then
    nameplate.HealthBarsContainer:SetAlpha(1)
  end
  if nameplate.killThisBanner ~= nil then
    nameplate.killThisBanner:Hide()
  end
end

function KillThis:attachToNameplate(nameplate, guid)
  if not nameplate.rbgdAnchorFrame then
    local attachmentFrame = GetHealthBarFrame(nameplate)
    nameplate.rbgdAnchorFrame = CreateFrame("Frame", nil, attachmentFrame)
    nameplate.rbgdAnchorFrame:SetFrameStrata("HIGH")
    nameplate.rbgdAnchorFrame:SetFrameLevel(attachmentFrame:GetFrameLevel() + 1)
  end

  addBanner(nameplate, guid)
end

function KillThis:NAME_PLATE_UNIT_REMOVED(unitToken)
  local nameplate = GetNamePlateForUnit(unitToken, issecure())

  if nameplate then
    self:detachFromNameplate(nameplate)
  end
end

function KillThis:NAME_PLATE_UNIT_ADDED(unitToken)
  local nameplate = GetNamePlateForUnit(unitToken, issecure())
  local guid = UnitGUID(unitToken)

  if nameplate and guid then
    self:attachToNameplate(nameplate, guid)
  end
end
local ShuffleFrame = CreateFrame("Frame")
ShuffleFrame.eventRegistered = false

function KillThis:PLAYER_REGEN_ENABLED()
  KillThisFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
  ShuffleFrame.eventRegistered = false

  refreshNameplates()
end

function KillThis:GROUP_ROSTER_UPDATE()
  if not KillThisFrame.inArena then
    return
  end

  local name = AuraUtil.FindAuraByName("Arena Preparation", "player", "HELPFUL")
  if not name then
    return
  end

  if UnitAffectingCombat("player") then
    if not ShuffleFrame.eventRegistered then
      KillThisFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
      ShuffleFrame.eventRegistered = true
    end
  else
    refreshNameplates()
  end
end

function KillThis:ARENA_OPPONENT_UPDATE()
  if not KillThisFrame.inArena then
    return
  end

  local name = AuraUtil.FindAuraByName("Arena Preparation", "player", "HELPFUL")
  if not name then
    return
  end

  if UnitAffectingCombat("player") then
    if not ShuffleFrame.eventRegistered then
      KillThisFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
      ShuffleFrame.eventRegistered = true
    end
  else
    refreshNameplates()
  end
end

function KillThis:PLAYER_LEAVING_WORLD()
  After(2, function()
    KillThisFrame.wasOnLoadingScreen = false
  end)
end

function KillThis:LOADING_SCREEN_DISABLED()
  After(2, function()
    KillThisFrame.wasOnLoadingScreen = false
  end)
end

function KillThis:LOADING_SCREEN_ENABLED()
  KillThisFrame.wasOnLoadingScreen = true
end

local function instanceCheck()
  local inInstance, instanceType = IsInInstance()
  KillThisFrame.inArena = inInstance and (instanceType == "arena")
end

function KillThis:PLAYER_ENTERING_WORLD()
  KillThisFrame.wasOnLoadingScreen = true

  instanceCheck()

  updateCVars()

  if not KillThisFrame.loaded then
    KillThisFrame.loaded = true

    KillThisFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    KillThisFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    KillThisFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
    KillThisFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    KillThisFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    KillThisFrame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
  end

  if IsInInstance() then
    KillThisFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  else
    KillThisFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

function KillThis:PLAYER_LOGIN()
  KillThisFrame:UnregisterEvent("PLAYER_LOGIN")

  KillThisFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  KillThisFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
  KillThisFrame:RegisterEvent("LOADING_SCREEN_ENABLED")
  KillThisFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
end
KillThisFrame:RegisterEvent("PLAYER_LOGIN")

function NS.OnDbChanged()
  updateCVars()
  refreshNameplates(true)
end

function NS.Options_SlashCommands(_)
  AceConfigDialog:Open(AddonName)
end

function NS.Options_Setup()
  AceConfig:RegisterOptionsTable(AddonName, NS.AceConfig)
  AceConfigDialog:AddToBlizOptions(AddonName, AddonName)

  SLASH_KT1 = "/killthis"
  SLASH_KT2 = "/kt"

  function SlashCmdList.KT(message)
    NS.Options_SlashCommands(message)
  end
end

function KillThis:ADDON_LOADED(addon)
  if addon == AddonName then
    KillThisFrame:UnregisterEvent("ADDON_LOADED")

    KillThisDB = KillThisDB and next(KillThisDB) ~= nil and KillThisDB or {}

    NS.BuildCVars(KillThisDB)

    -- Copy any settings from default if they don't exist in current profile
    NS.CopyDefaults(NS.DefaultDatabase, KillThisDB)

    -- Reference to active db profile
    -- Always use this directly or reference will be invalid
    NS.db = KillThisDB

    -- Remove table values no longer found in default settings
    NS.CleanupDB(KillThisDB, NS.DefaultDatabase)

    NS.BuildNPCOptions()

    NS.OFFSET = {
      x = NS.db.general.offsetX,
      y = NS.db.general.offsetY,
    }

    NS.Options_Setup()
  end
end
KillThisFrame:RegisterEvent("ADDON_LOADED")
