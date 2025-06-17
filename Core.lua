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
local activeColorBright = "|cFFFFA500" -- Orange vif pour les stats actives
local otherColor = "|cFF800080"        -- Violet pour les autres spés
local resetColor = "|r"

-- Database :
local classLocalization = SPC.classLocalization or {}
local specToStats = SPC.specToStats or {}
local specNames = SPC.specNames or {}

-- Obtenir la spécialisation du joueur
local function GetPlayerSpec(isInspect, isPet, talentGroup)
    SPC:WriteLog("Entering GetPlayerSpec", "SPEC")
    
    local localizedClass, _ = UnitClass("player")
    local class = classLocalization[localizedClass] or localizedClass
    
    if class ~= "PALADIN" then
        SPC:WriteLog("Classe non supportée : " .. tostring(class), "SPEC")
        return nil, nil
    end
    
    local specPrimary = GetPrimaryTalentTree(isInspect or false, isPet or false, 1)
    local specSecondary = GetPrimaryTalentTree(isInspect or false, isPet or false, 2) or 0
    if not specPrimary then
        SPC:WriteLog("Spécialisation non détectée", "SPEC")
        return nil, nil
    end
    
    local specPrimaryName = specNames[class][specPrimary] or "Unknown"
    local specSecondaryName = specNames[class][specSecondary] or "Unknown"
    local message = "Localized Class: " .. tostring(localizedClass) .. ", Mapped Class: " .. tostring(class) .. ", spec Primary ["..tostring(specPrimary).."] " .. tostring(specPrimaryName)
    message = message.. ", (spec Secondary ["..tostring(specSecondary).."] " .. tostring(specSecondaryName) .. ")"
    SPC:WriteLog( message, "SPEC")
    
    return class, specPrimary, specSecondary
end
StatsPriorityColors.GetPlayerSpec = GetPlayerSpec

-- Vérifier la pertinence d'une stat
--[[
]]
local function CheckStatRelevance(stat, activeStats, otherSpecsStats)
    local debugOutput = "Checking stat: " .. tostring(stat or "nil")
    
    if not stat then SPC:WriteLog(debugOutput.." [No stat...]", "STAT"); return nil, nil, nil end
    
    -- local primary = ( string.find(string.lower(stat), "^%+") or string.find(stat, "^%+") ) ~= nil
    -- local secondary = ( string.find(stat, "Équipé :") or string.find(string.lower(stat), "Équipé :") ) ~= nil
    
    -- if primary or secondary then
    for _, relevantStat in ipairs(activeStats) do
        local pattern = relevantStat:lower()
        if string.find(stat:lower(), pattern, 1, true) then
            debugOutput = debugOutput .. "[Matched active stat: " .. relevantStat.."]"
            SPC:WriteLog(debugOutput, "STAT")
            return relevantStat, "active", "active_bright"
        end
    end
    
    for _, relevantStat in ipairs(otherSpecsStats) do
        local pattern = relevantStat:lower()
        if string.find(stat:lower(), pattern, 1, true) then
            debugOutput = debugOutput .. "[Matched other stat: " .. relevantStat.."]"
            SPC:WriteLog(debugOutput, "STAT")
            return relevantStat, "other", "other"
        end
    end
    -- end
    return nil, nil, nil
end

-- Modifier le tooltip
local function ModifyTooltip(tooltip)
    SPC:WriteLog("ModifyTooltip called for " .. (tooltip:GetName() or "nil"), "TOOLTIP")
    
    if not tooltip then return end
    
    local class, specPrimary, specSecondary = GetPlayerSpec()
    if not class or not specPrimary then return end
    
    local activeStats = specToStats[class][specPrimary] or {}
    if not activeStats[1] then return end
    
    local otherSpecsStats = {}
    if specSecondary then
        if specToStats[class][specSecondary] then
            for _, stat in ipairs(specToStats[class][specSecondary]) do
                table.insert(otherSpecsStats, stat)
            end
        end
    end
    
    for i = 2, tooltip:NumLines() do
        local line = _G[tooltip:GetName() .. "TextLeft" .. i]
        local text = line and line:GetText()
        if text then
            local matchedStat, statType, _ = CheckStatRelevance(text, activeStats, otherSpecsStats)
            if matchedStat then
                local color = (statType == "active") and activeColorBright or otherColor
                line:SetText(color .. text .. resetColor)
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

-- Message de débogage pour confirmer le chargement
SPC:WriteLog("Debug.lua chargé", "INIT")