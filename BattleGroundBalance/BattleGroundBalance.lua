local addonName = ...

local CreateFrame, UnitName, GetRealmName, select, IsInInstance, WorldStateScoreFrame, SetBattlefieldScoreFaction, RequestBattlefieldScoreData, GetNumBattlefieldScores, GetBattlefieldScore, print, tonumber, math_max, math_min , ipairs =
      CreateFrame, UnitName, GetRealmName, select, IsInInstance, WorldStateScoreFrame, SetBattlefieldScoreFaction, RequestBattlefieldScoreData, GetNumBattlefieldScores, GetBattlefieldScore, print, tonumber, math.max, math.min , ipairs

local Addon = CreateFrame("Frame")
local playerKey = UnitName("player") .. " - " .. GetRealmName()
local ASSETS = "Interface\\AddOns\\BattleGroundBalance\\Artwork\\"

local WrapperFrame = CreateFrame("Frame", nil, UIParent)
WrapperFrame:SetFrameStrata("DIALOG")
WrapperFrame:SetSize(295, 95)
WrapperFrame:SetMovable(true)
WrapperFrame:EnableMouse(false)
WrapperFrame:SetClampedToScreen(true)
WrapperFrame:RegisterForDrag("LeftButton")
WrapperFrame.isLocked = true
WrapperFrame:SetScript("OnDragStart", function(self)
    if not self.isLocked then
        self:StartMoving()
    end
end)
WrapperFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    local uiX, uiY = UIParent:GetCenter()
    BattleGroundBalanceDB[playerKey].x = x - uiX
    BattleGroundBalanceDB[playerKey].y = y - uiY
end)

local hitbox = WrapperFrame:CreateTexture(nil, "OVERLAY")
hitbox:SetTexture(0, 0.5, 0, 0.5)
hitbox:SetAllPoints(true)
hitbox:Hide()
local moveText = WrapperFrame:CreateFontString(nil, "OVERLAY")
moveText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
moveText:SetText("DRAG")
moveText:SetPoint("CENTER")
moveText:SetTextColor(1, 1, 1)
moveText:Hide()

local ParentFrame = CreateFrame("Frame", nil, WrapperFrame)
ParentFrame:SetFrameStrata("HIGH")
ParentFrame:SetSize(295, 95)
ParentFrame:SetPoint("CENTER")
ParentFrame:Hide()
ParentFrame.AllyIcon = ParentFrame:CreateTexture(nil, "BACKGROUND")
ParentFrame.AllyIcon:SetTexture(ASSETS .. "AllianceLogo")
ParentFrame.AllyIcon:SetPoint("CENTER", -85, 30)
ParentFrame.AllyIcon:SetHeight(40)
ParentFrame.AllyIcon:SetWidth(40)
ParentFrame.AllyHK = ParentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ParentFrame.AllyHK:SetPoint("LEFT", ParentFrame.AllyIcon, "RIGHT", -5, 0)
ParentFrame.HordeIcon = ParentFrame:CreateTexture(nil, "BACKGROUND")
ParentFrame.HordeIcon:SetTexture(ASSETS .. "HordeLogo")
ParentFrame.HordeIcon:SetPoint("CENTER", 85, 30)
ParentFrame.HordeIcon:SetHeight(40)
ParentFrame.HordeIcon:SetWidth(40)
ParentFrame.HordeHK = ParentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ParentFrame.HordeHK:SetPoint("RIGHT", ParentFrame.HordeIcon, "LEFT", 5, 0)

local damageBar = CreateFrame("Frame", nil, ParentFrame)
damageBar:SetFrameStrata("HIGH")
damageBar:SetSize(200, 27)
damageBar:SetPoint("CENTER", 0, 0)
damageBar:SetBackdrop({edgeFile = ASSETS .. "UI-Tooltip-Border", edgeSize = 17})
damageBar.leftTexture = damageBar:CreateTexture(nil, "BACKGROUND")
damageBar.leftTexture:SetTexture(ASSETS .. "UI-StatusBar")
damageBar.leftTexture:SetVertexColor(0.2, 0.4, 1)
damageBar.leftTexture:SetPoint("LEFT", 4, 0)
damageBar.leftTexture:SetHeight(20)
damageBar.leftTextPct = damageBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
damageBar.leftTextPct:SetPoint("CENTER", damageBar.leftTexture, "CENTER", 0, 1)
damageBar.leftIcon = damageBar:CreateTexture(nil, "BACKGROUND")
damageBar.leftIcon:SetTexture(ASSETS .. "DamagerIcon")
damageBar.leftIcon:SetPoint("LEFT", -24, 0)
damageBar.leftIcon:SetWidth(25)
damageBar.leftIcon:SetHeight(25)
damageBar.leftTextCnt = damageBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
damageBar.leftTextCnt:SetPoint("RIGHT", damageBar.leftIcon, "LEFT")
damageBar.rightTexture = damageBar:CreateTexture(nil, "BACKGROUND")
damageBar.rightTexture:SetTexture(ASSETS .. "UI-StatusBar")
damageBar.rightTexture:SetVertexColor(0.9, 0.1, 0.1)
damageBar.rightTexture:SetPoint("RIGHT", -4, 0)
damageBar.rightTexture:SetHeight(20)
damageBar.rightTextPct = damageBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
damageBar.rightTextPct:SetPoint("CENTER", damageBar.rightTexture, "CENTER", 0, 1)
damageBar.rightIcon = damageBar:CreateTexture(nil, "BACKGROUND")
damageBar.rightIcon:SetTexture(ASSETS .. "DamagerIcon")
damageBar.rightIcon:SetTexCoord(1, 0, 0, 1)
damageBar.rightIcon:SetPoint("RIGHT", 24, 0)
damageBar.rightIcon:SetWidth(25)
damageBar.rightIcon:SetHeight(25)
damageBar.rightTextCnt = damageBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
damageBar.rightTextCnt:SetPoint("LEFT", damageBar.rightIcon, "RIGHT")

local healingBar = CreateFrame("Frame", nil, ParentFrame)
healingBar:SetFrameStrata("HIGH")
healingBar:SetSize(200, 27)
healingBar:SetPoint("CENTER", 0, -26.6)
healingBar:SetBackdrop({edgeFile = ASSETS .. "UI-Tooltip-Border", edgeSize = 17})
healingBar:SetBackdropBorderColor(1, 1, 1, 1)
healingBar.leftTexture = healingBar:CreateTexture(nil, "BACKGROUND")
healingBar.leftTexture:SetTexture(ASSETS .. "UI-StatusBar")
healingBar.leftTexture:SetVertexColor(0.2, 0.4, 1)
healingBar.leftTexture:SetPoint("LEFT", 4, 0)
healingBar.leftTexture:SetHeight(20)
healingBar.leftTextPct = healingBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
healingBar.leftTextPct:SetPoint("CENTER", healingBar.leftTexture, "CENTER", 0, 1)
healingBar.leftIcon = healingBar:CreateTexture(nil, "BACKGROUND")
healingBar.leftIcon:SetTexture(ASSETS .. "HealerIcon")
healingBar.leftIcon:SetPoint("LEFT", -23.5, 0)
healingBar.leftIcon:SetWidth(23)
healingBar.leftIcon:SetHeight(23)
healingBar.leftTextCnt = healingBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
healingBar.leftTextCnt:SetPoint("RIGHT", healingBar.leftIcon, "LEFT", -1, 0)
healingBar.rightTexture = healingBar:CreateTexture(nil, "BACKGROUND")
healingBar.rightTexture:SetTexture(ASSETS .. "UI-StatusBar")
healingBar.rightTexture:SetVertexColor(0.9, 0.1, 0.1)
healingBar.rightTexture:SetPoint("RIGHT", -4, 0)
healingBar.rightTexture:SetHeight(20)
healingBar.rightTextPct = healingBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
healingBar.rightTextPct:SetPoint("CENTER", healingBar.rightTexture, "CENTER", 0, 1)
healingBar.rightIcon = healingBar:CreateTexture(nil, "BACKGROUND")
healingBar.rightIcon:SetTexture(ASSETS .. "HealerIcon")
healingBar.rightIcon:SetTexCoord(1, 0, 0, 1)
healingBar.rightIcon:SetPoint("RIGHT", 23.5, 0)
healingBar.rightIcon:SetWidth(23)
healingBar.rightIcon:SetHeight(23)
healingBar.rightTextCnt = healingBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
healingBar.rightTextCnt:SetPoint("LEFT", healingBar.rightIcon, "RIGHT", 0.5, 0)

local function Initialize()
    BattleGroundBalanceDB = BattleGroundBalanceDB or {}
    BattleGroundBalanceDB[playerKey] = BattleGroundBalanceDB[playerKey] or { x = 0, y = 0, scale = 1 }
    local db = BattleGroundBalanceDB[playerKey]
    WrapperFrame:ClearAllPoints()
    WrapperFrame:SetPoint("CENTER", UIParent, "CENTER", db.x, db.y)
    WrapperFrame:SetSize(295 * db.scale, 95 * db.scale)
    ParentFrame:SetScale(db.scale)
end

local function UpdateBars()
    local inBG = select(2, IsInInstance()) == "pvp"
    if inBG or not WrapperFrame.isLocked then
        ParentFrame:Show()
    else
        ParentFrame:Hide()
    end
    if WorldStateScoreFrame:IsShown() and WorldStateScoreFrame.selectedTab and WorldStateScoreFrame.selectedTab > 1 then return end
    local aHKs, hHKs = 0, 0
    local aPctDmg, hPctDmg = 0.5, 0.5
    local aPctHeal, hPctHeal = 0.5, 0.5
    local aDamagers, hDamagers = 0, 0
    local aHealers = (BattleGroundHealers and BattleGroundHealers.AllianceCount) or 0
    local hHealers = (BattleGroundHealers and BattleGroundHealers.HordeCount) or 0
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
        if aDmg >= 100000 and hDmg >= 100000 then
            local totalDmg = aDmg + hDmg
            aPctDmg = aDmg / totalDmg
            hPctDmg = hDmg / totalDmg
        end
        if aHeal >= 50000 and hHeal >= 50000 then
            local totalHeal = aHeal + hHeal
            aPctHeal = aHeal / totalHeal
            hPctHeal = hHeal / totalHeal
        end
        aDamagers = aCnt - aHealers
        hDamagers = hCnt - hHealers
    end
    ParentFrame.AllyHK:SetText(aHKs .. " HK") 
    damageBar.leftTexture:SetWidth(192 * aPctDmg)
    damageBar.rightTexture:SetWidth(192 * hPctDmg)
    damageBar.leftTextPct:SetText(string.format("%.0f%%", aPctDmg * 100))
    damageBar.rightTextPct:SetText(string.format("%.0f%%", hPctDmg * 100))
    damageBar.leftTextCnt:SetText(aDamagers)
    damageBar.rightTextCnt:SetText(hDamagers)
    ParentFrame.HordeHK:SetText(hHKs .. " HK")
    healingBar.leftTexture:SetWidth(192 * aPctHeal)
    healingBar.rightTexture:SetWidth(192 * hPctHeal)
    healingBar.leftTextPct:SetText(string.format("%.0f%%", aPctHeal * 100))
    healingBar.rightTextPct:SetText(string.format("%.0f%%", hPctHeal * 100))
    healingBar.leftTextCnt:SetText(aHealers)
    healingBar.rightTextCnt:SetText(hHealers)
end

local updateTimer = 0
ParentFrame:SetScript("OnUpdate", function(self, elapsed)
    updateTimer = updateTimer + elapsed
    if updateTimer >= 2.5 then
        updateTimer = 0
        UpdateBars()
    end
end)

Addon:RegisterEvent("ADDON_LOADED")
Addon:RegisterEvent("PLAYER_ENTERING_WORLD")
Addon:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        Initialize()
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateBars()
    end
end)

local HelpTextList = {
    '  |cff8788ee======= BattleGroundBalance Commands =======|r',
    '  |cff00FF98 /bgb move|r : Toggle frame lock/unlock',
    '  |cff00FF98 /bgb scale #|r : Set frame scale (0.5 to 2)',
    '  |cff8788ee=========================================|r'
}

local function BGBprint(...)
	print("|cff00FF98[BattleGroundBalance]:|r", ...)
end

SLASH_BGB1 = "/bgb"
SlashCmdList["BGB"] = function(msg)
    local cmd, rest = msg:match("^(%S+)%s*(.-)$")
    if cmd == "move" then
        WrapperFrame.isLocked = not WrapperFrame.isLocked
        if WrapperFrame.isLocked then
            WrapperFrame:EnableMouse(false)
            hitbox:Hide()
            moveText:Hide()
            BGBprint("Frame locked")
        else
            WrapperFrame:EnableMouse(true)
            hitbox:Show()
            moveText:Show()
            BGBprint("Frame unlocked")
        end
        UpdateBars()
    elseif cmd == "scale" then
        if rest == "" then
            BGBprint("Current scale is " .. BattleGroundBalanceDB[playerKey].scale)
        else
            local scale = tonumber(rest)
            if scale then
                scale = math_max(0.5, math_min(2, scale))
                BattleGroundBalanceDB[playerKey].scale = scale
                ParentFrame:SetScale(scale)
                WrapperFrame:SetSize(295 * scale, 95 * scale)
                BGBprint("Scale set to " .. scale)
            else
                BGBprint("Invalid scale value")
            end
        end
    else
        for _, line in ipairs(HelpTextList) do
            print(line)
        end
    end
end
