local addonName, StatsPriorityColors = ...

-- Store addon in global table
_G[addonName] = StatsPriorityColors

-- Map localized class names to English
local classLocalization = {
    ["Paladine"] = "PALADIN",
    ["Guerrier"] = "WARRIOR",
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
    },
    ["WARRIOR"] = {
        [1] = { -- Arms
            "Force",
            "Coup critique",
            "Hâte",
            "Maîtrise"
        },
        [2] = { -- Fury
            "Force",
            "Coup critique",
            "Hâte",
            "Maîtrise"
        },
        [3] = { -- Protection
            "Force",
            "Maîtrise",
            "Parade",
            "Esquive"
        }
    }
}

-- Map of specialization indices to names (for display)
local specNames = {
    ["PALADIN"] = {
        [1] = "Sacré",
        [2] = "Protection",
        [3] = "Rétribution"
    },
    ["WARRIOR"] = {
        [1] = "Armes",
        [2] = "Furie",
        [3] = "Protection"
    }
}

-- Color codes
local activeColorBright = "|cFFFFA500" -- Bright orange for active stats
local otherColor = "|cFF800080"        -- Purple for other specs
local resetColor = "|r"

-- Logging function
local function LogToFile(message)
    if not LogSPCDB then
        LogSPCDB = {}
    end
    if not LogSPCDB.logs then
        LogSPCDB.logs = {}
    end
    local timestamp = date("%Y-%m-%d %H:%M:%S")
    local logEntry = "[" .. timestamp .. "] " .. message
    table.insert(LogSPCDB.logs, logEntry)
    if #LogSPCDB.logs > 1000 then
        table.remove(LogSPCDB.logs, 1)
    end
    DEFAULT_CHAT_FRAME:AddMessage("[StatsPriorityColors] " .. message, 0.7, 0.7, 1.0)
end

-- Clear logs command
SLASH_SPCCLEARLOGS1 = "/spcclearlogs"
SlashCmdList["SPCCLEARLOGS"] = function()
    LogSPCDB.logs = {}
    DEFAULT_CHAT_FRAME:AddMessage("[StatsPriorityColors] Logs cleared")
end

-- Function to get the player's current specialization
local function GetPlayerSpec()
    local message = "[SPEC] Entering GetPlayerSpec"
    LogToFile(message)
    
    local localizedClass, _ = UnitClass("player")
    local class = classLocalization[localizedClass] or localizedClass
    local specIndex = GetPrimaryTalentTree() or 2
    local specName = specNames[class] and specNames[class][specIndex] or "Unknown"

    message = "[SPEC] Localized Class: " .. tostring(localizedClass) .. ", Mapped Class: " .. tostring(class) .. ", Spec: " .. tostring(specName) .. " (Index: " .. specIndex .. ")"
    LogToFile(message)
    
    return class, specIndex
end
StatsPriorityColors.GetPlayerSpec = GetPlayerSpec

-- Function to check if a stat is relevant
local function CheckStatRelevance(stat, activeStats, otherSpecsStats)
    local message = "[STAT] Checking stat: " .. (stat or "nil")
    LogToFile(message)
    
    if not stat then return nil, nil, nil end

    -- Étape 1 : Créer variables et vérifier primary/secondary
    local primary = string.find(stat, "^%+") ~= nil
    local secondary = string.find(stat, "Équipé :") ~= nil
    message = "[DEBUG] Primary: " .. tostring(primary) .. ", Secondary: " .. tostring(secondary)
    LogToFile(message)

    -- Étape 2 : Si primary ou secondary est vrai
    if primary or secondary then
        -- Étape 3 : Vérifier les stats dans specToStats
        for _, relevantStat in ipairs(activeStats) do
            local pattern = relevantStat:lower()
            if string.find(stat:lower(), pattern, 1, true) then
                message = "[STAT] Matched active stat: " .. relevantStat
                LogToFile(message)
                return relevantStat, "active", "active_bright"
            else
                message = "[DEBUG] No match for active stat: " .. relevantStat
                LogToFile(message)
            end
        end

        for _, relevantStat in ipairs(otherSpecsStats) do
            local pattern = relevantStat:lower()
            if string.find(stat:lower(), pattern, 1, true) then
                message = "[STAT] Matched other spec stat: " .. relevantStat
                LogToFile(message)
                return relevantStat, "other", "other"
            else
                message = "[DEBUG] No match for other stat: " .. relevantStat
                LogToFile(message)
            end
        end
    end

    return nil, nil, nil
end

-- Function to modify tooltip
local function ModifyTooltip(tooltip)
    local message = "[TOOLTIP] ModifyTooltip called for " .. (tooltip:GetName() or "nil")
    LogToFile(message)
    
    if not tooltip then
        message = "[TOOLTIP] Tooltip is nil"
        LogToFile(message)
        return
    end

    local class, specIndex = GetPlayerSpec()
    local activeStats = specToStats[class] and specToStats[class][specIndex] or {}

    if not activeStats[1] then
        message = "[TOOLTIP] No relevant stats for class=" .. tostring(class) .. " spec=" .. specIndex
        LogToFile(message)
        return
    end

    message = "[TOOLTIP] Active stats: [" .. table.concat(activeStats, ", ") .. "]"
    LogToFile(message)

    local otherSpecsStats = {}
    for i = 1, 3 do
        if i ~= specIndex and specToStats[class] and specToStats[class][i] then
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
        message = "[TOOLTIP] Line " .. i .. ": " .. (text or "nil")
        LogToFile(message)
        
        if text then
            local matchedStat, statType, colorType = CheckStatRelevance(text, activeStats, otherSpecsStats)
            if matchedStat then
                local color = (statType == "active") and activeColorBright or otherColor
                line:SetText(color .. text .. resetColor)
                message = "[COLOR] Colored stat: " .. matchedStat .. " as " .. (colorType or statType)
                LogToFile(message)
            end
        end
    end
end
StatsPriorityColors.ModifyTooltip = ModifyTooltip

-- Initialize addon
local function Initialize()
    local message = "[INIT] StatsPriorityColors loaded!"
    LogToFile(message)
    
    message = "[INIT] addonName: " .. tostring(addonName)
    LogToFile(message)

    message = "[INIT] Setting up tooltip hooks"
    LogToFile(message)
    
    GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        local message = "[TOOLTIP] GameTooltip OnTooltipSetItem triggered"
        LogToFile(message)
        ModifyTooltip(tooltip)
    end)
    ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        local message = "[TOOLTIP] ItemRefTooltip OnTooltipSetItem triggered"
        LogToFile(message)
        ModifyTooltip(tooltip)
    end)
    ShoppingTooltip1:HookScript("OnTooltipSetItem", function(tooltip)
        local message = "[TOOLTIP] ShoppingTooltip1 OnTooltipSetItem triggered"
        LogToFile(message)
        ModifyTooltip(tooltip)
    end)
    ShoppingTooltip2:HookScript("OnTooltipSetItem", function(tooltip)
        local message = "[TOOLTIP] ShoppingTooltip2 OnTooltipSetItem triggered"
        LogToFile(message)
        ModifyTooltip(tooltip)
    end)
end

-- Event frame to handle initialization and talent updates
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:SetScript("OnEvent", function(self, event, arg1)
    local message = "[EVENT] Triggered: " .. event .. (arg1 and (", arg1: " .. arg1) or "")
    LogToFile(message)
    
    if event == "PLAYER_LOGIN" or (event == "ADDON_LOADED" and arg1 == addonName) then
        Initialize()
        self:UnregisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_TALENT_UPDATE" then
        message = "[EVENT] Talent update detected, rechecking spec"
        LogToFile(message)
        GetPlayerSpec()
    end
end)

-- Debug: Confirm frame creation
local message = "[INIT] Event frame created and registered"
LogToFile(message)