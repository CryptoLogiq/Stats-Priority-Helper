local addonName, StatsPriorityHelper = ...

-- Stocker l'addon dans une table globale
-- if not _G[addonName] then
--     _G[addonName] = StatsPriorityHelper
-- end

local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local SPH = LibStub("AceAddon-3.0"):GetAddon("StatsPriorityHelper")

StatsPriorityHelper = SPH


-- Codes de couleur pour les tooltips
local primaryColor = "|cFFFFA500" -- Orange (#FFA500) , comme pour les objets épiques, pour indiquer l'importance.
local secondColor = "|cFF00FFFF"        -- Cyan (#00FFFF), mets une legere evidence pour la seconde spécialisation.
local badColor = "|cFFFF0000"        -- Red (#FF0000), mets en rouge car on s'en fou de cette stat...
local greenColor = "|cFFAAD372"        -- Red (#AAD372), mets en rouge car on s'en fou de cette stat...
local resetColor = "|r"

-- Database :
local StatsSPH = SPH.StatsSPH or {}
local specNames = SPH.specNames or {}

-- var locales for self player connected
local ClassNameLocal = nil
local class = nil
local specPrimaryID = nil
local specSecondaryID = nil
local specPrimaryName = nil
local specSecondaryName = nil
local specPrimaryIcon = nil
local specSecondarIcon = nil

local activeStats = nil
local secondSpecsStats = nil
local badStats = {"+", "Augmente"}
local ignoreStats = {"(",")"}

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
StatsPriorityHelper.GetSpecIcon = GetSpecIcon


-- Obtenir la spécialisation du joueur
local function GetPlayerSpec(isInspect, isPet, talentGroup)
    SPH:WriteLog("Entering GetPlayerSpec", "SPEC")
    
    if not ClassNameLocal then
        ClassNameLocal, class = UnitClass("player")
    end
    
    if not specNames[class] then
        SPH:WriteLog("Classe non supportée : " .. tostring(class), "SPEC")
        return nil, nil
    end
    
    
    -- local specPrimaryID = GetPrimaryTalentTree(isInspect or false, isPet or false, 1)
    if not specPrimaryID then
        specPrimaryID = GetActiveTalentGroup(isInspect or false, isPet or false, 1) or false
        specSecondaryID = GetPrimaryTalentTree(isInspect or false, isPet or false, 2) or false
        if not specPrimaryID then
            SPH:WriteLog("Spécialisation non détectée", "SPEC")
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
    
    local message = "Class: " .. tostring(ClassNameLocal) .. ", spec Primary ["..tostring(specPrimaryID).."] " .. tostring(specPrimaryName)
    if specSecondaryID then
        message = message.. ", (spec Secondary ["..tostring(specSecondaryID).."] " .. tostring(specSecondaryName) .. ")"
    end
    SPH:WriteLog( message, "SPEC")
    
    return class, specPrimaryID, specSecondaryID
end
StatsPriorityHelper.GetPlayerSpec = GetPlayerSpec

-- Vérifier la pertinence d'une stat
local function CheckStatRelevance(stat, activeStats, secondSpecsStats, badStats)  
    if not stat then SPH:WriteLog(" [Error CheckStat as No stat...]", "STAT"); return nil, nil, nil end
    
    local debugOutput = "Checking stat: " .. tostring(stat or "nil")
    
    local primarySpecMatched = false
    local secondarySpecMatched = false
    local badStatsMatched = false
    
    -- if detect set bonus stat then ignore this line...
    local pattern = "("
    if string.find(stat, pattern, 1, true) then
        for n=1, 8 do
            local ignoredStat = "("..tostring(n)..")"
            if string.find(stat, ignoredStat, 1, true) then
                debugOutput = debugOutput .. "[Matched ignored stat: " .. ignoredStat.."]"
                SPH:WriteLog(debugOutput, "STAT")
                return false, false, false
            end
        end
    end
    
    for _, relevantStat in ipairs(activeStats) do
        local pattern = relevantStat:lower()
        if string.find(stat:lower(), pattern, 1, true) then
            debugOutput = debugOutput .. "[Matched active stat: " .. relevantStat.."]"
            SPH:WriteLog(debugOutput, "STAT")
            primarySpecMatched = true
        end
    end
    
    for _, relevantStat in ipairs(secondSpecsStats) do
        local pattern = relevantStat:lower()
        if string.find(stat:lower(), pattern, 1, true) then
            debugOutput = debugOutput .. "[Matched second stat: " .. relevantStat.."]"
            SPH:WriteLog(debugOutput, "STAT")
            secondarySpecMatched = true
        end
    end
    
    for _, relevantStat in ipairs(badStats) do
        local pattern = relevantStat:lower()
        if string.find(stat:lower(), pattern, 1, true) then
            debugOutput = debugOutput .. "[Matched bad stat: " .. relevantStat.."]"
            SPH:WriteLog(debugOutput, "STAT")
            badStatsMatched = true
        end
    end
    
    if primarySpecMatched or secondarySpecMatched or badStatsMatched then
        if primarySpecMatched and secondarySpecMatched then
            return true, "alls", primaryColor
        elseif primarySpecMatched then
            return true, "active", primaryColor
        elseif secondarySpecMatched then
            return true, "second", secondColor
        elseif badStatsMatched then
            return true, "badStats", badColor
        end
    end
    
    return false, false, false
end

-- Modifier le tooltip
local function ModifyTooltip(tooltip)
    
    if tooltip ~= GameTooltip then return end
    
    SPH:WriteLog("ModifyTooltip called for " .. (tooltip:GetName() or "nil"), "TOOLTIP")
    
    if not tooltip then return end
    if not class or not specPrimaryID then
        class, specPrimaryID, specSecondaryID = GetPlayerSpec()
        if not class or not specPrimaryID then return end
    end
    
    if not activeStats then
        activeStats = StatsSPH[class][specPrimaryID] or {}
    end
    if not activeStats[1] then return end
    
    if not secondSpecsStats then
        secondSpecsStats = {}
    end
    if specSecondaryID and not secondSpecsStats[1] then
        if StatsSPH[class][specSecondaryID] then
            for _, stat in ipairs(StatsSPH[class][specSecondaryID]) do
                table.insert(secondSpecsStats, stat)
            end
        end
    end
    
    if not specPrimaryName then
        local specPrimaryName = specNames[class][specPrimaryID] or "Unknown"
        local specSecondaryName = "Unknown"
    end
    
    if specSecondaryID and not specSecondaryName then
        specSecondaryName = specNames[class][specSecondaryID] or "Unknown"
    end
    
    local count = {matched=false, primary = 0, secondary = 0, bad = 0}
    
    for i = 2, tooltip:NumLines() do
        local line = _G[tooltip:GetName() .. "TextLeft" .. i]
        local text = line and line:GetText()
        
        if text then
            local matchedStat, statType, color = CheckStatRelevance(text, activeStats, secondSpecsStats, badStats)
            if matchedStat then
                count.matched = true
                if statType == "alls" then
                    line:SetText(text..resetColor.." ["..primaryColor..specPrimaryName..resetColor.." + "..secondColor..specSecondaryName..resetColor.."]")
                    count.primary = count.primary + 1
                    count.secondary = count.secondary + 1
                elseif statType == "active" then
                    line:SetText(text..resetColor.." ["..primaryColor..specPrimaryName..resetColor.."]")
                    count.primary = count.primary + 1
                elseif statType == "second" then
                    line:SetText(text..resetColor.." ["..secondColor..specSecondaryName..resetColor.."]")
                    count.secondary = count.secondary + 1
                elseif statType == "badStats" then
                    line:SetText(text..badColor.." [ BAD ]"..resetColor)
                    count.bad = count.bad + 1
                end
            end
        end
    end
    
    if count.matched then
        local prim, sec, bad = false, false, false
        if count.primary >= count.secondary and count.primary > count.bad then
            prim = true
        end
        if count.secondary >= count.primary and count.secondary > count.bad then
            sec = true
        end
        if count.bad >= count.primary and count.bad >= count.secondary then
            bad = true
        end
        if prim and sec then
            tooltip:AddLine(primaryColor.."[Stats Priority] ".. greenColor.." This item is good for your spec :"..greenColor.." ["..primaryColor..specPrimaryName..greenColor.." + "..secondColor..specSecondaryName..greenColor.."]"..resetColor)
        elseif prim then
            tooltip:AddLine(primaryColor.."[Stats Priority] ".. greenColor.." This item is good for your spec :"..greenColor.." ["..secondColor..specPrimaryName..greenColor.."]"..resetColor)
        elseif sec then
            tooltip:AddLine(primaryColor.."[Stats Priority] ".. greenColor.." This item is good for your spec :"..greenColor.." ["..secondColor..specSecondaryName..greenColor.."]"..resetColor)
        elseif bad then
            tooltip:AddLine(primaryColor.."[Stats Priority] ".. badColor.." This item is not for you !"..resetColor)
        end
    end
    
end
StatsPriorityHelper.ModifyTooltip = ModifyTooltip

-- Initialisation
local function Initialize()
    SPH:WriteLog("StatsPriorityHelper loaded!", "INIT")
    
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