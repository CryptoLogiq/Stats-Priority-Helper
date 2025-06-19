--[[
 Extract Data of "Wyr3d's IcyVeins Stats" addon ! stocked in stats.lua !!!
 source : https://www.curseforge.com/wow/addons/wyr3ds-icy-veins-statistic-prior/files/5700116
]]--

local addonName, StatsPriorityHelper = ...
StatsPriorityHelper.ExtractData = {}
local ExtractData = StatsPriorityHelper.ExtractData

-- Déclarer la SavedVariables
MyAddonStatPriorities = MyAddonStatPriorities or {}

-- Liste des stats valides
local validStats = {
    "Force", "Agilité", "Endurance", "Intelligence", "Esprit",
    "Toucher", "Coup Critique", "Hâte", "Maîtrise", "Versatilité",
    "Pénétration d'armure", "Puissance d'attaque", "Puissance des sorts"
}

-- Fonction pour parser les priorités de stats avec pourcentages
function ExtractData:Parse(input)
    local priorities = {}
    local currentGroup = {}
    
    -- Séparer par ">" pour les niveaux de priorité
    for segment in input:gmatch("[^>]+") do
        currentGroup = {}
        -- Séparer par "=" pour les stats de même poids
        for stat in segment:gmatch("[^=]+") do
            stat = stat:gsub("^%s*(.-)%s*$", "%1")
            local percentage = stat:match("(%d+%%)")
            local cleanStat = stat:gsub("[%d%.]+%%", ""):gsub("cap.*", "")
            
            for _, validStat in ipairs(validStats) do
                if cleanStat:lower() == validStat:lower() then
                    table.insert(currentGroup, { name = validStat, percentage = percentage })
                    break
                end
            end
        end
        if #currentGroup > 0 then
            table.insert(priorities, currentGroup)
        end
    end
    
    return priorities
end

-- Fonction pour sauvegarder les priorités
function ExtractData:Save(class, spec, input)
    local priorities = self:Parse(input)
    if not MyAddonStatPriorities[class] then
        MyAddonStatPriorities[class] = {}
    end
    MyAddonStatPriorities[class][spec] = priorities
end

-- Vérifier si l'addon Wyr3d est chargé
local function IsWyr3dAddonLoaded()
    return IsAddOnLoaded("Wyr3dsIcyVeinsStatsPriorities")
end

-- Obtenir classe et spécialisation du joueur
local function GetPlayerClassSpec()
    local _, class = UnitClass("player")
    local specID = GetSpecialization()
    if specID then
        local spec = select(2, GetSpecializationInfo(specID))
        return class, spec
    end
    return class, nil
end

-- Fonction pour afficher les priorités dans un tooltip
function ExtractData:AddToTooltip(tooltip)
    if IsWyr3dAddonLoaded() then return end
    
    local class, spec = GetPlayerClassSpec()
    if not MyAddonStatPriorities[class] or not MyAddonStatPriorities[class][spec] then
        return
    end
    
    tooltip:AddLine("\nPriorités des stats :")
    local priorities = MyAddonStatPriorities[class][spec]
    for i, group in ipairs(priorities) do
        local statNames = {}
        for _, stat in ipairs(group) do
            local display = stat.name
            if stat.percentage then
                display = display .. " (" .. stat.percentage .. ")"
            end
            table.insert(statNames, display)
        end
        tooltip:AddLine("Priorité " .. i .. ": " .. table.concat(statNames, " = "))
    end
end