local addonName = ...

local CreateFrame, UnitName, GetRealmName, select, IsInInstance, WorldStateScoreFrame, SetBattlefieldScoreFaction, RequestBattlefieldScoreData, GetNumBattlefieldScores, GetBattlefieldScore, print, tonumber, math_max, math_min , ipairs =
      CreateFrame, UnitName, GetRealmName, select, IsInInstance, WorldStateScoreFrame, SetBattlefieldScoreFaction, RequestBattlefieldScoreData, GetNumBattlefieldScores, GetBattlefieldScore, print, tonumber, math.max, math.min , ipairs

local EventHandler = CreateFrame("Frame")
local playerKey = UnitName("player") .. " - " .. GetRealmName()
local ASSETS = "Interface\\AddOns\\BattleGroundBalance\\Artwork\\"

local db
local DefaultSettings = {
    x = 0,
    y = 0,
    scale = 1,
    width = 183,
    height = 27,
    iconSize = 40,
    fontSize = 12,
    dmgThreshold = 70000,
    healThreshold = 35000,
}

local SettingsLimits = {
    scale    = {0.5, 2},
    width    = {150, 500},
    height   = {20, 100},
    iconSize = {25, 100},
    fontSize = {10, 50},
    dmgThreshold  = {0, 200000},
    healThreshold = {0, 100000},
}

local WrapperFrame = CreateFrame("Frame", nil, UIParent)
local ParentFrame = CreateFrame("Frame", nil, WrapperFrame)
local damageBar = CreateFrame("Frame", nil, ParentFrame)
local healingBar = CreateFrame("Frame", nil, ParentFrame)

local function UpdateBarSize(bar)
    bar:SetSize(db.width, db.height)
    bar.leftTexture:SetHeight(db.height - 7)
    bar.rightTexture:SetHeight(db.height - 7)
end

local function UpdateIconSize(icon)
    icon:SetSize(db.iconSize, db.iconSize)
end

local function UpdateDpsIconSize(icon)
    icon:SetSize(0.62 * db.iconSize, 0.62 * db.iconSize)
end

local function UpdateHealIconSize(icon)
    icon:SetSize(0.55 * db.iconSize, 0.55 * db.iconSize)
end

local function UpdateFontString(fontString)
    fontString:SetFont("Fonts\\FRIZQT__.TTF", db.fontSize)
    fontString:SetTextColor(1, 0.82, 0)
    fontString:SetShadowOffset(1, -1)
end

local function UpdateWrapperFrame()
    WrapperFrame:ClearAllPoints()
    WrapperFrame:SetPoint("CENTER", UIParent, "CENTER", db.x, db.y)
    WrapperFrame:SetSize((db.width + 1.25 * db.iconSize + 3 * db.fontSize) * db.scale, (2 * db.height + db.iconSize) * db.scale)
end

local function UpdateParentFrame()
    UpdateIconSize(ParentFrame.AllyIcon)
    UpdateIconSize(ParentFrame.HordeIcon)
    UpdateFontString(ParentFrame.AllyHK)
    UpdateFontString(ParentFrame.HordeHK)
    ParentFrame:SetSize(db.width + 1.25 * db.iconSize + 3 * db.fontSize, 2 * db.height + db.iconSize)
    ParentFrame:SetScale(db.scale)
end

local function UpdateDamageBar()
    UpdateBarSize(damageBar)
    UpdateDpsIconSize(damageBar.leftIcon)
    UpdateDpsIconSize(damageBar.rightIcon)
    UpdateFontString(damageBar.leftTextPct)
    UpdateFontString(damageBar.leftTextCnt)
    UpdateFontString(damageBar.rightTextPct)
    UpdateFontString(damageBar.rightTextCnt)
end

local function UpdateHealingBar()
    UpdateBarSize(healingBar)
    UpdateHealIconSize(healingBar.leftIcon)
    UpdateHealIconSize(healingBar.rightIcon)
    UpdateFontString(healingBar.leftTextPct)
    UpdateFontString(healingBar.leftTextCnt)
    UpdateFontString(healingBar.rightTextPct)
    UpdateFontString(healingBar.rightTextCnt)
end

local function UpdateFrames()
    UpdateWrapperFrame()
    UpdateParentFrame()
    UpdateDamageBar()
    UpdateHealingBar()
end

local function BGBprint(...)
	print("|cff00FF98[BGB]:|r", ...)
end

WrapperFrame:SetFrameStrata("DIALOG")
WrapperFrame:SetMovable(true)
WrapperFrame:EnableMouse(false)
WrapperFrame:SetClampedToScreen(true)
WrapperFrame:RegisterForDrag("LeftButton")
WrapperFrame.clickbox = WrapperFrame:CreateTexture(nil, "OVERLAY")
WrapperFrame.clickbox:SetTexture(0, 0.5, 0, 0.5)
WrapperFrame.clickbox:SetAllPoints(true)
WrapperFrame.clickbox:Hide()
WrapperFrame.dragText = WrapperFrame:CreateFontString(nil, "OVERLAY")
WrapperFrame.dragText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
WrapperFrame.dragText:SetText("DRAG")
WrapperFrame.dragText:SetPoint("CENTER")
WrapperFrame.dragText:SetTextColor(1, 1, 1)
WrapperFrame.dragText:Hide()
WrapperFrame.isLocked = true
WrapperFrame:SetScript("OnDragStart", function(self)
    if not self.isLocked then
        self:StartMoving()
    end
end)
WrapperFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    local UIx, UIy = UIParent:GetCenter()
    BattleGroundBalanceDB[playerKey].x = x - UIx
    BattleGroundBalanceDB[playerKey].y = y - UIy
end)

ParentFrame:SetFrameStrata("HIGH")
ParentFrame:SetPoint("CENTER")
ParentFrame:Hide()
ParentFrame.AllyIcon = ParentFrame:CreateTexture(nil, "BACKGROUND")
ParentFrame.AllyIcon:SetTexture(ASSETS .. "AllianceLogo")
ParentFrame.AllyIcon:SetPoint("BOTTOMLEFT", damageBar, "TOPLEFT", -4, -4)
ParentFrame.AllyHK = ParentFrame:CreateFontString(nil, "OVERLAY")
ParentFrame.AllyHK:SetPoint("LEFT", ParentFrame.AllyIcon, "RIGHT", -5, 0)
ParentFrame.HordeIcon = ParentFrame:CreateTexture(nil, "BACKGROUND")
ParentFrame.HordeIcon:SetTexture(ASSETS .. "HordeLogo")
ParentFrame.HordeIcon:SetPoint("BOTTOMRIGHT", damageBar, "TOPRIGHT", 4, -4)
ParentFrame.HordeHK = ParentFrame:CreateFontString(nil, "OVERLAY")
ParentFrame.HordeHK:SetPoint("RIGHT", ParentFrame.HordeIcon, "LEFT", 5, 0)

damageBar:SetFrameStrata("HIGH")
damageBar:SetPoint("BOTTOM", healingBar, "TOP", 0, -1)
damageBar:SetBackdrop({edgeFile = ASSETS .. "UI-Tooltip-Border", edgeSize = 17})
damageBar.leftTexture = damageBar:CreateTexture(nil, "BACKGROUND")
damageBar.leftTexture:SetTexture(ASSETS .. "UI-StatusBar")
damageBar.leftTexture:SetVertexColor(0.2, 0.4, 1)
damageBar.leftTexture:SetPoint("LEFT", 4, 0)
damageBar.leftTextPct = damageBar:CreateFontString(nil, "OVERLAY")
damageBar.leftTextPct:SetPoint("CENTER", damageBar.leftTexture, "CENTER", 0, 1)
damageBar.leftIcon = damageBar:CreateTexture(nil, "BACKGROUND")
damageBar.leftIcon:SetTexture(ASSETS .. "DamagerIcon")
damageBar.leftIcon:SetPoint("RIGHT", damageBar, "LEFT", 1, 0.5)
damageBar.leftTextCnt = damageBar:CreateFontString(nil, "OVERLAY")
damageBar.leftTextCnt:SetPoint("RIGHT", damageBar.leftIcon, "LEFT")
damageBar.rightTexture = damageBar:CreateTexture(nil, "BACKGROUND")
damageBar.rightTexture:SetTexture(ASSETS .. "UI-StatusBar")
damageBar.rightTexture:SetVertexColor(0.9, 0.1, 0.1)
damageBar.rightTexture:SetPoint("RIGHT", -4, 0)
damageBar.rightTextPct = damageBar:CreateFontString(nil, "OVERLAY")
damageBar.rightTextPct:SetPoint("CENTER", damageBar.rightTexture, "CENTER", 0, 1)
damageBar.rightIcon = damageBar:CreateTexture(nil, "BACKGROUND")
damageBar.rightIcon:SetTexture(ASSETS .. "DamagerIcon")
damageBar.rightIcon:SetTexCoord(1, 0, 0, 1)
damageBar.rightIcon:SetPoint("LEFT", damageBar, "RIGHT", -1, 0.5)
damageBar.rightTextCnt = damageBar:CreateFontString(nil, "OVERLAY")
damageBar.rightTextCnt:SetPoint("LEFT", damageBar.rightIcon, "RIGHT")

healingBar:SetFrameStrata("HIGH")
healingBar:SetPoint("BOTTOM", 0, 5)
healingBar:SetBackdrop({edgeFile = ASSETS .. "UI-Tooltip-Border", edgeSize = 17})
healingBar:SetBackdropBorderColor(1, 1, 1, 1)
healingBar.leftTexture = healingBar:CreateTexture(nil, "BACKGROUND")
healingBar.leftTexture:SetTexture(ASSETS .. "UI-StatusBar")
healingBar.leftTexture:SetVertexColor(0.2, 0.4, 1)
healingBar.leftTexture:SetPoint("LEFT", 4, 0)
healingBar.leftTextPct = healingBar:CreateFontString(nil, "OVERLAY")
healingBar.leftTextPct:SetPoint("CENTER", healingBar.leftTexture, "CENTER", 0, 1)
healingBar.leftIcon = healingBar:CreateTexture(nil, "BACKGROUND")
healingBar.leftIcon:SetTexture(ASSETS .. "HealerIcon")
healingBar.leftIcon:SetPoint("RIGHT", healingBar, "LEFT", 0, 0.5)
healingBar.leftTextCnt = healingBar:CreateFontString(nil, "OVERLAY")
healingBar.leftTextCnt:SetPoint("RIGHT", healingBar.leftIcon, "LEFT", -1.5, 0)
healingBar.rightTexture = healingBar:CreateTexture(nil, "BACKGROUND")
healingBar.rightTexture:SetTexture(ASSETS .. "UI-StatusBar")
healingBar.rightTexture:SetVertexColor(0.9, 0.1, 0.1)
healingBar.rightTexture:SetPoint("RIGHT", -4, 0)
healingBar.rightTextPct = healingBar:CreateFontString(nil, "OVERLAY")
healingBar.rightTextPct:SetPoint("CENTER", healingBar.rightTexture, "CENTER", 0, 1)
healingBar.rightIcon = healingBar:CreateTexture(nil, "BACKGROUND")
healingBar.rightIcon:SetTexture(ASSETS .. "HealerIcon")
healingBar.rightIcon:SetTexCoord(1, 0, 0, 1)
healingBar.rightIcon:SetPoint("LEFT", healingBar, "RIGHT", 0, 0.5)
healingBar.rightTextCnt = healingBar:CreateFontString(nil, "OVERLAY")
healingBar.rightTextCnt:SetPoint("LEFT", healingBar.rightIcon, "RIGHT", 1.5, 0)

local aHKs, hHKs = 0, 0
local aPctDmg, hPctDmg = 0.5, 0.5
local aPctHeal, hPctHeal = 0.5, 0.5
local aDamagers, hDamagers = 0, 0
local aHealers = 0
local hHealers = 0

local function UpdateBarsData()
    ParentFrame.AllyHK:SetText(aHKs .. " HK") 
    damageBar.leftTexture:SetWidth((db.width - 8) * aPctDmg)
    damageBar.rightTexture:SetWidth((db.width - 8) * hPctDmg)
    damageBar.leftTextPct:SetText(string.format("%.0f%%", aPctDmg * 100))
    damageBar.rightTextPct:SetText(string.format("%.0f%%", hPctDmg * 100))
    damageBar.leftTextCnt:SetText(aDamagers)
    damageBar.rightTextCnt:SetText(hDamagers)
    ParentFrame.HordeHK:SetText(hHKs .. " HK")
    healingBar.leftTexture:SetWidth((db.width - 8) * aPctHeal)
    healingBar.rightTexture:SetWidth((db.width - 8) * hPctHeal)
    healingBar.leftTextPct:SetText(string.format("%.0f%%", aPctHeal * 100))
    healingBar.rightTextPct:SetText(string.format("%.0f%%", hPctHeal * 100))
    healingBar.leftTextCnt:SetText(aHealers)
    healingBar.rightTextCnt:SetText(hHealers)
end

local function UpdateScoreData()
    if not db then return end
    local inBG = select(2, IsInInstance()) == "pvp"
    if inBG or not WrapperFrame.isLocked then
        ParentFrame:Show()
    else
        ParentFrame:Hide()
    end
    if WorldStateScoreFrame:IsShown() and WorldStateScoreFrame.selectedTab and WorldStateScoreFrame.selectedTab > 1 then return end
    aHKs, hHKs = 0, 0
    aPctDmg, hPctDmg = 0.5, 0.5
    aPctHeal, hPctHeal = 0.5, 0.5
    aDamagers, hDamagers = 0, 0
    aHealers = (BattleGroundHealers and BattleGroundHealers.AllianceCount) or 0
    hHealers = (BattleGroundHealers and BattleGroundHealers.HordeCount) or 0
    if inBG then
        SetBattlefieldScoreFaction()
        RequestBattlefieldScoreData()
        local aDmg, hDmg, aHeal, hHeal = 0, 0, 0, 0
        local aCnt, hCnt = 0, 0
        for i = 1, GetNumBattlefieldScores() do
            local _, _, HKs, _, _, faction, _, _, _, _, damageDone, healingDone = GetBattlefieldScore(i)
            if faction == 1 then
                aCnt = aCnt +1
                aDmg = aDmg + damageDone
                aHeal = aHeal + healingDone
                if HKs > aHKs then
                    aHKs = HKs
                end
            elseif faction == 0 then
                hCnt = hCnt + 1
                hDmg = hDmg + damageDone
                hHeal = hHeal + healingDone
                if HKs > hHKs then
                    hHKs = HKs
                end
            end
        end
        if aDmg > db.dmgThreshold and hDmg > db.dmgThreshold then
            local totalDmg = aDmg + hDmg
            aPctDmg = aDmg / totalDmg
            hPctDmg = hDmg / totalDmg
        end
        if aHeal > db.healThreshold and hHeal > db.healThreshold then
            local totalHeal = aHeal + hHeal
            aPctHeal = aHeal / totalHeal
            hPctHeal = hHeal / totalHeal
        end
        aDamagers = aCnt - aHealers
        hDamagers = hCnt - hHealers
    end
    UpdateBarsData()
end

local updateTimer = 0
ParentFrame:SetScript("OnUpdate", function(self, elapsed)
    updateTimer = updateTimer + elapsed
    if updateTimer >= 5 then
        updateTimer = 0
        UpdateScoreData()
    end
end)

local function InitSettings()
    BattleGroundBalanceDB = BattleGroundBalanceDB or {}
    BattleGroundBalanceDB[playerKey] = BattleGroundBalanceDB[playerKey] or {}
    db = BattleGroundBalanceDB[playerKey]
    for k, v in pairs(DefaultSettings) do
        if db[k] == nil then
            db[k] = v
        end
    end
    for k in pairs(db) do
        if DefaultSettings[k] == nil then
            db[k] = nil
        end
    end
end

local function ResetSettings()
    for k, v in pairs(DefaultSettings) do
        db[k] = v
    end
    BGBprint("Settings reset to default")
end

local function HandleWrapperUnlock()
    if WrapperFrame.isLocked then
        WrapperFrame:EnableMouse(false)
        WrapperFrame.clickbox:Hide()
        WrapperFrame.dragText:Hide()
        BGBprint("Frame locked")
    else
        WrapperFrame:EnableMouse(true)
        WrapperFrame.clickbox:Show()
        WrapperFrame.dragText:Show()
        BGBprint("Frame unlocked")
    end
end

local function HandleSetting(cmd, rest)
    if rest == "" then
        BGBprint("Current " .. cmd .. " is " .. db[cmd])
        return
    end
    local value = tonumber(rest)
    if not value then
        BGBprint("Invalid " .. cmd .. " value")
        return
    end
    local limits = SettingsLimits[cmd]
    value = math_max(limits[1], math_min(limits[2], value))
    db[cmd] = value
    UpdateFrames()
    UpdateBarsData()
    BGBprint(cmd .. " set to " .. value)
end

local SettingsOrder = {
    {key = "scale",         label = "Set frame scale"},
    {key = "width",         label = "Set bar width"},
    {key = "height",        label = "Set bar height"},
    {key = "iconSize",      label = "Set icon size"},
    {key = "fontSize",      label = "Set font size"},
    {key = "dmgThreshold",  label = "Set min damage to show ratio"},
    {key = "healThreshold", label = "Set min healing to show ratio"},
}

local function BuildHelpTextList()
    local list = {
        '  |cff8788ee======= BattleGroundBalance Commands =======|r',
        '  |cff00FF98 /bgb lock|r : Toggle frame lock/unlock',
    }
    for _, entry in ipairs(SettingsOrder) do
        local limits = SettingsLimits[entry.key]
        list[#list + 1] = string.format(
            '  |cff00FF98 /bgb %s #|r : %s (%s to %s)',
            entry.key, entry.label, limits[1], limits[2]
        )
    end
    list[#list + 1] = '  |cff00FF98 /bgb reset|r : Reset all settings to default'
    list[#list + 1] = '  |cff8788ee=========================================|r'
    return list
end

local HelpTextList = BuildHelpTextList()

EventHandler:RegisterEvent("ADDON_LOADED")
EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
EventHandler:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        InitSettings()
        UpdateFrames()
        UpdateBarsData()
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateScoreData()
    end
end)

SLASH_BGB1 = "/bgb"
SlashCmdList["BGB"] = function(msg)
    local cmd, rest = msg:match("^(%S+)%s*(.-)$")
    if cmd == "lock" then
        WrapperFrame.isLocked = not WrapperFrame.isLocked
        HandleWrapperUnlock()
        UpdateScoreData()
    elseif SettingsLimits[cmd] then
        HandleSetting(cmd, rest)
    elseif cmd == "reset" then
        ResetSettings()
        UpdateFrames()
        UpdateBarsData()
    else
        for _, line in ipairs(HelpTextList) do
            print(line)
        end
    end
end
