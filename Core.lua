local addonName, StatsPriorityColors = ...

-- Stocker l'addon dans une table globale
-- if not _G[addonName] then
--     _G[addonName] = StatsPriorityColors
-- end

local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local SPC = LibStub("AceAddon-3.0"):GetAddon("StatsPriorityColors")

-- Codes de couleur pour les tooltips
local activeColorBright = "|cFFFFA500" -- Orange (#FFA500) , comme pour les objets épiques, pour indiquer l'importance.
local otherColor = "|cFF00FFFF"        -- Cyan (#00FFFF), visible et distinct, évitant le violet peu lisible.
local resetColor = "|r"

-- Database :
local classLocalization = SPC.classLocalization or {}
local specToStats = SPC.specToStats or {}
local specNames = SPC.specNames or {}

-- var locales for self player connected
local localizedClass = nil
local class = nil
local specPrimaryID = nil
local specSecondaryID = nil
local specPrimaryName = nil
local specSecondaryName = nil
local specPrimaryIcon = nil
local specSecondarIcon = nil

-- Obtenir l'icone de la spécialisation
local function GetSpecIcon(specIndex)
    if GetSpecializationInfo then
        local specID = GetSpecializationInfo(specIndex)
        if specID then
            local _, _, _, icon = GetSpecializationInfo(specIndex)
            return icon
        end
    end
    return nil
end
StatsPriorityColors.GetSpecIcon = GetSpecIcon


-- Obtenir la spécialisation du joueur
local function GetPlayerSpec(isInspect, isPet, talentGroup)
    SPC:WriteLog("Entering GetPlayerSpec", "SPEC")
    
    if not localizedClass then
        localizedClass, _ = UnitClass("player")
        class = classLocalization[localizedClass] or localizedClass
    end
    
    if class ~= "PALADIN" then
        SPC:WriteLog("Classe non supportée : " .. tostring(class), "SPEC")
        return nil, nil
    end
    
    
    -- local specPrimaryID = GetPrimaryTalentTree(isInspect or false, isPet or false, 1)
    if not specPrimaryID then
        specPrimaryID = GetActiveTalentGroup(isInspect or false, isPet or false, 1)
        specSecondaryID = GetPrimaryTalentTree(isInspect or false, isPet or false, 2) or false
        if not specPrimaryID then
            SPC:WriteLog("Spécialisation non détectée", "SPEC")
            return nil, nil
        else
            
            specPrimaryIcon = GetSpecIcon()
            
            if specSecondaryID then
                specSecondarIcon = GetSpecIcon(specSecondaryID)
            end
        end
    end
    
    
    if not specPrimaryName then
        
        specPrimaryName = specNames[class][specPrimaryID] or "Unknown"
        
        if specSecondaryID then
            specSecondaryName = specNames[class][specSecondaryID] or "Unknown"
        end
    end
    
    local message = "Localized Class: " .. tostring(localizedClass) .. ", Mapped Class: " .. tostring(class) .. ", spec Primary ["..tostring(specPrimaryID).."] " .. tostring(specPrimaryName)
    message = message.. ", (spec Secondary ["..tostring(specSecondaryID).."] " .. tostring(specSecondaryName) .. ")"
    SPC:WriteLog( message, "SPEC")
    
    return class, specPrimaryID, specSecondaryID
end
StatsPriorityColors.GetPlayerSpec = GetPlayerSpec

-- Vérifier la pertinence d'une stat
local function CheckStatRelevance(stat, activeStats, otherSpecsStats)  
    if not stat then SPC:WriteLog(debugOutput.." [Error CheckStat as No stat...]", "STAT"); return nil, nil, nil end
    
    local debugOutput = "Checking stat: " .. tostring(stat or "nil")
    
    local primarySpecMatched = false
    local secondarySpecMatched = false
    for _, relevantStat in ipairs(activeStats) do
        local pattern = relevantStat:lower()
        if string.find(stat:lower(), pattern, 1, true) then
            debugOutput = debugOutput .. "[Matched active stat: " .. relevantStat.."]"
            SPC:WriteLog(debugOutput, "STAT")
            primarySpecMatched = true
        end
    end
    
    for _, relevantStat in ipairs(otherSpecsStats) do
        local pattern = relevantStat:lower()
        if string.find(stat:lower(), pattern, 1, true) then
            debugOutput = debugOutput .. "[Matched other stat: " .. relevantStat.."]"
            SPC:WriteLog(debugOutput, "STAT")
            secondarySpecMatched = true
        end
    end
    
    if primarySpecMatched or secondarySpecMatched then
        if primarySpecMatched and secondarySpecMatched then
            return true, "alls", "active_bright"
        elseif primarySpecMatched then
            return true, "active", "active_bright"
        else
            return true, "other", "other"
        end
    end
    
    return false, false, false
end

-- Modifier le tooltip
local function ModifyTooltip(tooltip)
    SPC:WriteLog("ModifyTooltip called for " .. (tooltip:GetName() or "nil"), "TOOLTIP")
    
    if not tooltip then return end
    
    local class, specPrimaryID, specSecondaryID = GetPlayerSpec()
    if not class or not specPrimaryID then return end
    
    local activeStats = specToStats[class][specPrimaryID] or {}
    if not activeStats[1] then return end
    
    local otherSpecsStats = {}
    if specSecondaryID then
        if specToStats[class][specSecondaryID] then
            for _, stat in ipairs(specToStats[class][specSecondaryID]) do
                table.insert(otherSpecsStats, stat)
            end
        end
    end
    
    local specPrimaryName = specNames[class][specPrimaryID] or "Unknown"
    local specSecondaryName = "Unknown"
    if specSecondaryID then
        specSecondaryName = specNames[class][specSecondaryID] or "Unknown"
    end
    
    for i = 2, tooltip:NumLines() do
        local line = _G[tooltip:GetName() .. "TextLeft" .. i]
        local text = line and line:GetText()
        if text then
            local matchedStat, statType, _ = CheckStatRelevance(text, activeStats, otherSpecsStats)
            if matchedStat then
                local color = activeColorBright
                if statType == "alls" then
                    line:SetText(color .. text .. " ("..specPrimaryName..","..specSecondaryName..") " .. resetColor)
                    
                elseif statType == "active" then
                    line:SetText(color .. text .. " ("..specPrimaryName..") ".. resetColor)
                    
                elseif statType == "other" then
                    color = otherColor
                    line:SetText(color .. text .. " ("..specSecondaryName..") ".. resetColor)
                end
            end
        end
    end
end
StatsPriorityColors.ModifyTooltip = ModifyTooltip

-- Initialisation
local function Initialize()
    SPC:WriteLog("StatsPriorityColors loaded!", "INIT")
    
    GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        ModifyTooltip(tooltip)
    end)
    ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        ModifyTooltip(tooltip)
    end)
    ShoppingTooltip1:HookScript("OnTooltipSetItem", function(tooltip)
        ModifyTooltip(tooltip)
    end)
    ShoppingTooltip2:HookScript("OnTooltipSetItem", function(tooltip)
        ModifyTooltip(tooltip)
    end)
end

-- Gestion des événements
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_LOGIN" or (event == "ADDON_LOADED" and arg1 == addonName) then
        Initialize()
        self:UnregisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_TALENT_UPDATE" then
        GetPlayerSpec()
    end
end)