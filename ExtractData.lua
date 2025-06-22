--[[
Extract Data of "Wyr3d's IcyVeins Stats" addon ! stocked in stats.lua !!!
source : https://www.curseforge.com/wow/addons/wyr3ds-icy-veins-statistic-prior/files/5700116
]]--

local addonName, StatsPriorityHelper = ...

local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local SPH = LibStub("AceAddon-3.0"):GetAddon("StatsPriorityHelper")
StatsPriorityHelper = SPH

SPH.ExtractData = {}


local StatsSPH = SPH.StatsSPH
local specNames = SPH.specNames

local ExtractData = SPH.ExtractData

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
    if not SPH.StatsSPH[class] then
        SPH.StatsSPH[class] = {}
    end
    SPH.StatsSPH[class][spec] = priorities
end


local lastClass = "Unknow"
function  ExtractData.AddStatPriority(_, pClass)
    if not StatsSPH[pClass] then
        StatsSPH[pClass] = {}
    end
    lastClass = pClass
end

function  ExtractData.SetPriority(_, specName, textImport)
    if not lastSpec then 
        SPH:WriteLog("SetPriority Error :"..tostring(specName).." ["..tostring(textImport).."]","DEBUG")
        return
    end
    ExtractData:Save(lastClass, specName, textImport)
    
end