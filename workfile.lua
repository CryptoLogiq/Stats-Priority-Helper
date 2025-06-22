--[[
Extract Data of "Wyr3d's IcyVeins Stats" addon ! stocked in stats.lua !!!
source : https://www.curseforge.com/wow/addons/wyr3ds-icy-veins-statistic-prior/files/5700116
]]--

local addonName, StatsPriorityHelper = ...
local SPH = LibStub("AceAddon-3.0"):GetAddon("StatsPriorityHelper")
StatsPriorityHelper = SPH

SPH.ExtractData = {}
local ExtractData = SPH.ExtractData

-- Déclarer la SavedVariables
MyAddonStatPriorities = MyAddonStatPriorities or {}

-- Table de conversion Anglais US -> API (inclut les abréviations de stats.lua)
local convertEnUStoStatAPI = {
    ["Strength"] = "ITEM_MOD_STRENGTH_SHORT",
    ["Str"] = "ITEM_MOD_STRENGTH_SHORT",
    ["Agility"] = "ITEM_MOD_AGILITY_SHORT",
    ["Agi"] = "ITEM_MOD_AGILITY_SHORT",
    ["Stamina"] = "ITEM_MOD_STAMINA_SHORT",
    ["Stam"] = "ITEM_MOD_STAMINA_SHORT",
    ["Intellect"] = "ITEM_MOD_INTELLECT_SHORT",
    ["Int"] = "ITEM_MOD_INTELLECT_SHORT",
    ["Spirit"] = "ITEM_MOD_SPIRIT_SHORT",
    ["Mana"] = "ITEM_MOD_MANA_SHORT",
    ["Mana Regeneration"] = "ITEM_MOD_MANA_REGENERATION_SHORT",
    ["Hit"] = "ITEM_MOD_HIT_RATING_SHORT",
    ["SpHit"] = "ITEM_MOD_HIT_RATING_SHORT",
    ["Crit"] = "ITEM_MOD_CRIT_RATING_SHORT",
    ["SpCrit"] = "ITEM_MOD_CRIT_RATING_SHORT",
    ["Haste"] = "ITEM_MOD_HASTE_RATING_SHORT",
    ["SpHaste"] = "ITEM_MOD_HASTE_RATING_SHORT",
    ["Mastery"] = "ITEM_MOD_MASTERY_RATING_SHORT",
    ["Mast"] = "ITEM_MOD_MASTERY_RATING_SHORT",
    ["Versatility"] = "ITEM_MOD_VERSATILITY",
    ["Vers"] = "ITEM_MOD_VERSATILITY",
    ["Expertise"] = "ITEM_MOD_EXPERTISE_RATING_SHORT",
    ["Expert"] = "ITEM_MOD_EXPERTISE_RATING_SHORT",
    ["Defense"] = "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT",
    ["Def"] = "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT",
    ["Dodge"] = "ITEM_MOD_DODGE_RATING_SHORT",
    ["Parry"] = "ITEM_MOD_PARRY_RATING_SHORT",
    ["Block"] = "ITEM_MOD_BLOCK_RATING_SHORT",
    ["Attack Power"] = "ITEM_MOD_ATTACK_POWER_SHORT",
    ["AttPwr"] = "ITEM_MOD_ATTACK_POWER_SHORT",
    ["Spell Power"] = "ITEM_MOD_SPELL_POWER_SHORT",
    ["SpDam"] = "ITEM_MOD_SPELL_POWER_SHORT",
    ["SpPow"] = "ITEM_MOD_SPELL_POWER_SHORT",
    ["HealPwr"] = "ITEM_MOD_SPELL_POWER_SHORT",
    ["Spell Penetration"] = "ITEM_MOD_SPELL_PENETRATION_SHORT",
    ["SpPen"] = "ITEM_MOD_SPELL_PENETRATION_SHORT",
    ["Armor Penetration"] = "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
    ["ArmPen"] = "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
    ["Resilience"] = "ITEM_MOD_PVP_RESILIENCE_RATING_SHORT",
    ["Resil"] = "ITEM_MOD_PVP_RESILIENCE_RATING_SHORT",
    ["PvP Power"] = "ITEM_MOD_PVP_POWER_RATING_SHORT",
    ["Fire Resistance"] = "ITEM_MOD_FIRE_RESISTANCE_SHORT",
    ["Resist"] = "ITEM_MOD_FIRE_RESISTANCE_SHORT",
    ["Frost Resistance"] = "ITEM_MOD_FROST_RESISTANCE_SHORT",
    ["Nature Resistance"] = "ITEM_MOD_NATURE_RESISTANCE_SHORT",
    ["Arcane Resistance"] = "ITEM_MOD_ARCANE_RESISTANCE_SHORT",
    ["Shadow Resistance"] = "ITEM_MOD_SHADOW_RESISTANCE_SHORT",
    ["Armor"] = "ITEM_MOD_ARMOR",
    ["Armour"] = "ITEM_MOD_ARMOR"
}

-- Mappage des spécialisations (stats.lua -> noms Blizzard en anglais)
local specMapping = {
    ["Holy"] = "Holy", ["Protect"] = "Protection", ["Retadin"] = "Retribution",
    ["Holy Healer"] = "Holy", ["Protect Tank"] = "Protection", ["Retribution"] = "Retribution",
    ["Caster"] = "Balance", ["Melee"] = "Feral", ["Tank"] = "Guardian",
    ["Healer"] = "Restoration", ["Shadow"] = "Shadow", ["Elemental"] = "Elemental",
    ["Enhancement"] = "Enhancement", ["Restro"] = "Restoration", ["Arms"] = "Arms",
    ["Fury"] = "Fury", ["Protect Survival"] = "Protection", ["Protect Damage"] = "Protection",
    ["Blood"] = "Blood", ["Frost"] = "Frost", ["Unholy"] = "Unholy",
    ["BeastMaster"] = "Beast Mastery", ["Marksman"] = "Marksmanship", ["Survivalist"] = "Survival",
    ["Arcane"] = "Arcane", ["Fire"] = "Fire", ["Ice"] = "Frost", ["Disipline"] = "Discipline",
    ["Assassin"] = "Assassination", ["Combat"] = "Combat", ["Stealth"] = "Subtlety"
}

-- Mappage des classes
local classMapping = {
    ["DEATHKNIGHT"] = "DEATHKNIGHT", ["DEMONHUNTER"] = "DEMONHUNTER", ["DRUID"] = "DRUID",
    ["EVOKER"] = "EVOKER", ["HUNTER"] = "HUNTER", ["MAGE"] = "MAGE", ["MONK"] = "MONK",
    ["PALADIN"] = "PALADIN", ["PRIEST"] = "PRIEST", ["ROGUE"] = "ROGUE", ["SHAMAN"] = "SHAMAN",
    ["WARLOCK"] = "WARLOCK", ["WARRIOR"] = "WARRIOR"
}

-- Fonction pour parser les priorités de stats
function ExtractData:Parse(input)
    local priorities = {}
    local weight = 1 -- Priorité croissante (1 = plus haute)
    
    for segment in input:gmatch("[^>]+") do
        for stat in segment:gmatch("[^=]+") do
            stat = stat:gsub("^%s*(.-)%s*$", "%1"):gsub("[%d%.]+%%", ""):gsub("cap.*", ""):gsub("%s*S%-Cap%+?", ""):gsub("%d+%%+", "")
            local statKey = convertEnUStoStatAPI[stat]
            if statKey then
                table.insert(priorities, { key = statKey, weight = weight })
            end
        end
        weight = weight + 1
    end
    return priorities
end

-- Fonction pour sauvegarder les priorités
function ExtractData:Save(class, spec, input)
    local mappedClass = classMapping[class] or class
    local mappedSpec = specMapping[spec] or spec
    local priorities = self:Parse(input)
    if not MyAddonStatPriorities[mappedClass] then
        MyAddonStatPriorities[mappedClass] = {}
    end
    MyAddonStatPriorities[mappedClass][mappedSpec] = priorities
end

-- Exporter vers SPH_Database.lua
function ExtractData:ExportToSPHDatabase()
    local StatsSPH = SPH.StatsSPH or {}
    for class, specs in pairs(MyAddonStatPriorities) do
        StatsSPH[class] = StatsSPH[class] or {}
        for spec, priorities in pairs(specs) do
            local specIndex
            for idx, name in pairs(SPH.specNames[class] or {}) do
                if name == spec then
                    specIndex = idx
                    break
                end
            end
            if specIndex then
                local statsForSPH = {}
                for _, stat in ipairs(priorities) do
                    table.insert(statsForSPH, _G[stat.key])
                end
                StatsSPH[class][specIndex] = statsForSPH
            end
        end
    end
    SPH.StatsSPH = StatsSPH
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
        return classMapping[class] or class, spec
    end
    return classMapping[class] or class, nil
end

-- Fonction pour afficher les priorités dans un tooltip
function ExtractData:AddToTooltip(tooltip)
    if IsWyr3dAddonLoaded() then return end
    local class, spec = GetPlayerClassSpec()
    if not MyAddonStatPriorities[class] or not MyAddonStatPriorities[class][spec] then
        return
    end
    tooltip:AddLine("\nStat Priorities:")
    local priorities = MyAddonStatPriorities[class][spec]
    for _, stat in ipairs(priorities) do
        tooltip:AddLine("Priority " .. stat.weight .. ": " .. _G[stat.key])
    end
end

-- Vérifier les stats d’un item
function ExtractData:CheckItemStats(tooltip, itemLink)
    if not itemLink then return end
    local stats = C_Item.GetItemStats(itemLink)
    if not stats then return end
    
    local class, spec = GetPlayerClassSpec()
    if not MyAddonStatPriorities[class] or not MyAddonStatPriorities[class][spec] then
        return
    end
    
    local priorities = MyAddonStatPriorities[class][spec]
    local matchedStats = {}
    
    for statKey, _ in pairs(stats) do
        for _, priority in ipairs(priorities) do
            if priority.key == statKey then
                table.insert(matchedStats, { key = statKey, weight = priority.weight })
                break
            end
        end
    end
    
    if #matchedStats > 0 then
        tooltip:AddLine("\nPriority Stats Found:")
        table.sort(matchedStats, function(a, b) return a.weight < b.weight end)
        for _, stat in ipairs(matchedStats) do
            tooltip:AddLine("Priority " .. stat.weight .. ": " .. _G[stat.key])
        end
    end
end

-- Initialisation et extraction depuis stats.lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name == addonName then
        local tempClass
        local addOnMock = {
            AddStatPriority = function(self, class)
                tempClass = class
                return self
            end,
            SetPriority = function(self, spec, priority)
                ExtractData:Save(tempClass, spec, priority)
                return self
            end,
            SetDefaultPriority = function(self, priority)
                ExtractData:Save(tempClass, spec, priority)
                return self
            end
        }
        
        -- Simuler stats.lua (exemple partiel)
        addOnMock:AddStatPriority("PALADIN")
            :SetPriority("Holy", "Int > Haste > Crit > Mast > Vers")
            :SetPriority("Protection", "Haste > Mast > Vers = Crit > Str = Stam")
            :SetPriority("Retribution", "Str > Mast > Hit > Expert > Crit > Haste")
        
        -- Exporter vers SPH_Database.lua
        ExtractData:ExportToSPHDatabase()
        
        -- Afficher pour débogage
        for class, specs in pairs(MyAddonStatPriorities) do
            for spec, priorities in pairs(specs) do
                print("Class: " .. class .. ", Spec: " .. spec)
                for _, stat in ipairs(priorities) do
                    print("Priority " .. stat.weight .. ": " .. _G[stat.key] .. " (" .. stat.key .. ")")
                end
            end
        end
    end
end)

-- Hook pour tooltips
hooksecurefunc("GameTooltip_OnTooltipSetItem", function(tooltip)
    local _, itemLink = tooltip:GetItem()
    ExtractData:AddToTooltip(tooltip)
    ExtractData:CheckItemStats(tooltip, itemLink)
end)