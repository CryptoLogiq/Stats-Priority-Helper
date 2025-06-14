local addonName, StatsPriorityColors = ...

-- Stocker l'addon dans une table globale
_G[addonName] = StatsPriorityColors

local SPC = LibStub("AceAddon-3.0"):GetAddon("StatsPriorityColors")

-- Correspondance des noms de classes localisés vers l'anglais
local classLocalization = {
    ["Paladine"] = "PALADIN",
}

-- Correspondance des spécialisations aux stats pertinentes (en français)
local specToStats = {
    ["PALADIN"] = {
        [1] = { -- Sacré
            "Intelligence",
            "Esprit",
            "Puissance des sorts",
            "Hâte"
        },
        [2] = { -- Protection
            "Force",
            "Maîtrise",
            "Parade",
            "Esquive"
        },
        [3] = { -- Rétribution
            "Force",
            "Maîtrise",
            "Coup critique",
            "Hâte"
        }
    }
}

-- Noms des spécialisations (pour affichage)
local specNames = {
    ["PALADIN"] = {
        [1] = "Sacré",
        [2] = "Protection",
        [3] = "Rétribution"
    }
}

-- Codes de couleur pour les tooltips
local activeColorBright = "|cFFFFA500" -- Orange vif pour les stats actives
local otherColor = "|cFF800080"        -- Violet pour les autres spés
local resetColor = "|r"

-- Obtenir la spécialisation du joueur
local function GetPlayerSpec()
    SPC:WriteLog("Entering GetPlayerSpec", "SPEC")
    
    local localizedClass, _ = UnitClass("player")
    local class = classLocalization[localizedClass] or localizedClass
    
    if class ~= "PALADIN" then
        SPC:WriteLog("Classe non supportée : " .. tostring(class), "SPEC")
        return nil, nil
    end
    
    local specIndex = GetPrimaryTalentTree()
    if not specIndex then
        SPC:WriteLog("Spécialisation non détectée", "SPEC")
        return nil, nil
    end
    
    local specName = specNames[class][specIndex] or "Unknown"
    SPC:WriteLog("Localized Class: " .. tostring(localizedClass) .. ", Mapped Class: " .. tostring(class) .. ", Spec: " .. tostring(specName) .. " (Index: " .. specIndex .. ")", "SPEC")
    
    return class, specIndex
end
StatsPriorityColors.GetPlayerSpec = GetPlayerSpec

-- Vérifier la pertinence d'une stat
local function CheckStatRelevance(stat, activeStats, otherSpecsStats)
    SPC:WriteLog("Checking stat: " .. (stat or "nil"), "STAT")
    
    if not stat then return nil, nil, nil end

    local primary = string.find(stat, "^%+") ~= nil
    local secondary = string.find(stat, "Équipé :") ~= nil

    if primary or secondary then
        for _, relevantStat in ipairs(activeStats) do
            local pattern = relevantStat:lower()
            if string.find(stat:lower(), pattern, 1, true) then
                SPC:WriteLog("Matched active stat: " .. relevantStat, "STAT")
                return relevantStat, "active", "active_bright"
            end
        end

        for _, relevantStat in ipairs(otherSpecsStats) do
            local pattern = relevantStat:lower()
            if string.find(stat:lower(), pattern, 1, true) then
                SPC:WriteLog("Matched other spec stat: " .. relevantStat, "STAT")
                return relevantStat, "other", "other"
            end
        end
    end

    return nil, nil, nil
end

-- Modifier le tooltip
local function ModifyTooltip(tooltip)
    SPC:WriteLog("ModifyTooltip called for " .. (tooltip:GetName() or "nil"), "TOOLTIP")
    
    if not tooltip then return end

    local class, specIndex = GetPlayerSpec()
    if not class or not specIndex then return end

    local activeStats = specToStats[class][specIndex] or {}
    if not activeStats[1] then return end

    local otherSpecsStats = {}
    for i = 1, 3 do
        if i ~= specIndex and specToStats[class][i] then
            for _, stat in ipairs(specToStats[class][i]) do
                local exists = false
                for _, existingStat in ipairs(otherSpecsStats) do
                    if existingStat == stat then
                        exists = true
                        break
                    end
                end
                if not exists then
                    table.insert(otherSpecsStats, stat)
                end
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