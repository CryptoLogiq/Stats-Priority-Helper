local addonName, StatsPriorityColors = ...

-- Store addon in global table
_G[addonName] = StatsPriorityColors

-- Map localized class names to English
local classLocalization = {
    ["Paladine"] = "PALADIN",
}

-- Map of class specializations to relevant stats (in French, matching tooltip text)
local specToStats = {
    ["PALADIN"] = {
        [1] = { -- Holy
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
        [3] = { -- Retribution
            "Force",
            "Maîtrise",
            "Coup critique",
            "Hâte"
        }
    }
}

-- Map of specialization indices to names (for display)
local specNames = {
    ["PALADIN"] = {
        [1] = "Sacré",
        [2] = "Protection",
        [3] = "Rétribution"
    }
}

-- Color codes for tooltips
local activeColorBright = "|cFFFFA500" -- Bright orange for active stats
local otherColor = "|cFF800080"        -- Purple for other specs
local resetColor = "|r"

-- Function to get the player's current specialization
local function GetPlayerSpec()
    StatsPriorityColors.WriteLog("Entering GetPlayerSpec", "SPEC")
    
    local localizedClass, _ = UnitClass("player")
    local class = classLocalization[localizedClass] or localizedClass
    
    if class ~= "PALADIN" then
        StatsPriorityColors.WriteLog("Classe non supportée : " .. tostring(class), "SPEC")
        return nil, nil
    end
    
    local specIndex = GetPrimaryTalentTree()
    if not specIndex then
        StatsPriorityColors.WriteLog("Spécialisation non détectée", "SPEC")
        return nil, nil
    }
    
    local specName = specNames[class][specIndex] or "Unknown"
    StatsPriorityColors.WriteLog("Localized Class: " .. tostring(localizedClass) .. ", Mapped Class: " .. tostring(class) .. ", Spec: " .. tostring(specName) .. " (Index: " .. specIndex .. ")", "SPEC")
    
    return class, specIndex
end
StatsPriorityColors.GetPlayerSpec = GetPlayerSpec

-- Function to check if a stat is relevant
local function CheckStatRelevance(stat, activeStats, otherSpecsStats)
    StatsPriorityColors.WriteLog("Checking stat: " .. (stat or "nil"), "STAT")
    
    if not stat then return nil, nil, nil end

    local primary = string.find(stat, "^%+") ~= nil
    local secondary = string.find(stat, "Équipé :") ~= nil
    -- Removed verbose debug log to reduce queue size
    -- StatsPriorityColors.WriteLog("Primary: " .. tostring(primary) .. ", Secondary: " .. tostring(secondary), "DEBUG")

    if primary or secondary then
        for _, relevantStat in ipairs(activeStats) do
            local pattern = relevantStat:lower()
            if string.find(stat:lower(), pattern, 1, true) then
                StatsPriorityColors.WriteLog("Matched active stat: " .. relevantStat, "STAT")
                return relevantStat, "active", "active_bright"
            end
            -- Removed verbose debug log to reduce queue size
            -- StatsPriorityColors.WriteLog("No match for active stat: " .. relevantStat, "DEBUG")
        end

        for _, relevantStat in ipairs(otherSpecsStats) do
            local pattern = relevantStat:lower()
            if string.find(stat:lower(), pattern, 1, true) then
                StatsPriorityColors.WriteLog("Matched other spec stat: " .. relevantStat, "STAT")
                return relevantStat, "other", "other"
            end
            -- Removed verbose debug log to reduce queue size
            -- StatsPriorityColors.WriteLog("No match for other stat: " .. relevantStat, "DEBUG")
        end
    end

    return nil, nil, nil
end

-- Function to modify tooltip
local function ModifyTooltip(tooltip)
    StatsPriorityColors.WriteLog("ModifyTooltip called for " .. (tooltip:GetName() or "nil"), "TOOLTIP")
    
    if not tooltip then
        StatsPriorityColors.WriteLog("Tooltip is nil", "TOOLTIP")
        return
    end

    local class, specIndex = GetPlayerSpec()
    if not class or not specIndex then
        StatsPriorityColors.WriteLog("Classe ou spécialisation invalide", "TOOLTIP")
        return
    end

    local activeStats = specToStats[class][specIndex] or {}
    if not activeStats[1] then
        StatsPriorityColors.WriteLog("No relevant stats for class=" .. tostring(class) .. " spec=" .. specIndex, "TOOLTIP")
        return
    end

    StatsPriorityColors.WriteLog("Active stats: [" .. table.concat(activeStats, ", ") .. "]", "TOOLTIP")

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
        StatsPriorityColors.WriteLog("Line " .. i .. ": " .. (text or "nil"), "TOOLTIP")
        
        if text then
            local matchedStat, statType, colorType = CheckStatRelevance(text, activeStats, otherSpecsStats)
            if matchedStat then
                local color = (statType == "active") and activeColorBright or otherColor
                line:SetText(color .. text .. resetColor)
                StatsPriorityColors.WriteLog("Colored stat: " .. matchedStat .. " as " .. (colorType or statType), "COLOR")
            end
        end
    end
end
StatsPriorityColors.ModifyTooltip = ModifyTooltip

-- Initialize addon
local function Initialize()
    StatsPriorityColors.WriteLog("StatsPriorityColors loaded!", "INIT")
    StatsPriorityColors.WriteLog("Setting up tooltip hooks", "INIT")
    
    GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        StatsPriorityColors.WriteLog("GameTooltip OnTooltipSetItem triggered", "TOOLTIP")
        ModifyTooltip(tooltip)
    end)
    ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        StatsPriorityColors.WriteLog("ItemRefTooltip OnTooltipSetItem triggered", "TOOLTIP")
        ModifyTooltip(tooltip)
    end)
    ShoppingTooltip1:HookScript("OnTooltipSetItem", function(tooltip)
        StatsPriorityColors.WriteLog("ShoppingTooltip1 OnTooltipSetItem triggered", "TOOLTIP")
        ModifyTooltip(tooltip)
    end)
    ShoppingTooltip2:HookScript("OnTooltipSetItem", function(tooltip)
        StatsPriorityColors.WriteLog("ShoppingTooltip2 OnTooltipSetItem triggered", "TOOLTIP")
        ModifyTooltip(tooltip)
    end)
end

-- Event frame to handle initialization and talent updates
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:SetScript("OnEvent", function(self, event, arg1)
    StatsPriorityColors.WriteLog("Triggered: " .. event .. (arg1 and (", arg1: " .. arg1) or ""), "EVENT")
    
    if event == "PLAYER_LOGIN" or (event == "ADDON_LOADED" and arg1 == addonName) then
        Initialize()
        self:UnregisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_TALENT_UPDATE" then
        StatsPriorityColors.WriteLog("Talent update detected, rechecking spec", "EVENT")
        GetPlayerSpec()
    end
end)