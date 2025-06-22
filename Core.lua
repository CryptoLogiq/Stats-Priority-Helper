local addonName, StatsPriorityHelper = ...

-- Stocker l'addon dans une table globale

local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local SPH = LibStub("AceAddon-3.0"):GetAddon("StatsPriorityHelper")

StatsPriorityHelper = SPH

-- Vars globals for my addon :
SPH.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
SPH.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
SPH.IsBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
SPH.IsWotLK = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
SPH.IsCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

SPH.versionGame = "Unknow"
if SPH.IsClassic then
    SPH.versionGame = "Classic"
elseif SPH.IsBCC then
    SPH.versionGame = "Burning Crusade"
elseif SPH.IsWotLK then
    SPH.versionGame = "Wotlk"
elseif SPH.IsCata then
    SPH.versionGame = "Cataclysm"
else
    SPH.versionGame = "Retail"
end


-- StatAPIConverter.lua: Module pour convertir les clés API ITEM_MOD_*_SHORT vers noms en anglais US
SPH.convertStatAPI_EnUS = {
["ITEM_MOD_STRENGTH_SHORT"]= "Strength",
["ITEM_MOD_AGILITY_SHORT"]= "Agility",
["ITEM_MOD_STAMINA_SHORT"]= "Stamina",
["ITEM_MOD_INTELLECT_SHORT"]= "Intellect",
["ITEM_MOD_SPIRIT_SHORT"]= "Spirit",
["ITEM_MOD_MANA_SHORT"]= "Mana",
["ITEM_MOD_MANA_REGENERATION_SHORT"]= "Mana Regeneration",
["ITEM_MOD_HIT_RATING_SHORT"]= "Hit",
["ITEM_MOD_CRIT_RATING_SHORT"]= "Crit",
["ITEM_MOD_HASTE_RATING_SHORT"]= "Haste",
["ITEM_MOD_MASTERY_RATING_SHORT"]= "Mastery",
["ITEM_MOD_VERSATILITY"]= "Versatility",
["ITEM_MOD_EXPERTISE_RATING_SHORT"]= "Expertise",
["ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"]= "Defense",
["ITEM_MOD_DODGE_RATING_SHORT"]= "Dodge",
["ITEM_MOD_PARRY_RATING_SHORT"]= "Parry",
["ITEM_MOD_BLOCK_RATING_SHORT"]= "Block",
["ITEM_MOD_ATTACK_POWER_SHORT"]= "Attack Power",
["ITEM_MOD_SPELL_POWER_SHORT"]= "Spell Power",
["ITEM_MOD_SPELL_PENETRATION_SHORT"]= "Spell Penetration",
["ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT"]= "Armor Penetration",
["ITEM_MOD_PVP_RESILIENCE_RATING_SHORT"]= "Resilience",
["ITEM_MOD_PVP_POWER_RATING_SHORT"]= "PvP Power",
["ITEM_MOD_FIRE_RESISTANCE_SHORT"]= "Fire Resistance",
["ITEM_MOD_FROST_RESISTANCE_SHORT"]= "Frost Resistance",
["ITEM_MOD_NATURE_RESISTANCE_SHORT"]= "Nature Resistance",
["ITEM_MOD_ARCANE_RESISTANCE_SHORT"]= "Arcane Resistance",
["ITEM_MOD_SHADOW_RESISTANCE_SHORT"]= "Shadow Resistance",
["ITEM_MOD_ARMOR"]= "Armor"
}

-- StatEnUStoAPIConverter.lua: Module pour convertir les noms de stats en anglais US vers les clés API ITEM_MOD_*_SHORT
SPH.convertEnUStoStatAPI = {
    ["Strength"] = "ITEM_MOD_STRENGTH_SHORT",
    ["Agility"] = "ITEM_MOD_AGILITY_SHORT",
    ["Stamina"] = "ITEM_MOD_STAMINA_SHORT",
    ["Intellect"] = "ITEM_MOD_INTELLECT_SHORT",
    ["Spirit"] = "ITEM_MOD_SPIRIT_SHORT",
    ["Mana"] = "ITEM_MOD_MANA_SHORT",
    ["Mana Regeneration"] = "ITEM_MOD_MANA_REGENERATION_SHORT",
    ["Hit"] = "ITEM_MOD_HIT_RATING_SHORT",
    ["Crit"] = "ITEM_MOD_CRIT_RATING_SHORT",
    ["Haste"] = "ITEM_MOD_HASTE_RATING_SHORT",
    ["Mastery"] = "ITEM_MOD_MASTERY_RATING_SHORT",
    ["Versatility"] = "ITEM_MOD_VERSATILITY",
    ["Expertise"] = "ITEM_MOD_EXPERTISE_RATING_SHORT",
    ["Defense"] = "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT",
    ["Dodge"] = "ITEM_MOD_DODGE_RATING_SHORT",
    ["Parry"] = "ITEM_MOD_PARRY_RATING_SHORT",
    ["Block"] = "ITEM_MOD_BLOCK_RATING_SHORT",
    ["Attack Power"] = "ITEM_MOD_ATTACK_POWER_SHORT",
    ["Spell Power"] = "ITEM_MOD_SPELL_POWER_SHORT",
    ["Spell Penetration"] = "ITEM_MOD_SPELL_PENETRATION_SHORT",
    ["Armor Penetration"] = "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
    ["Resilience"] = "ITEM_MOD_PVP_RESILIENCE_RATING_SHORT",
    ["PvP Power"] = "ITEM_MOD_PVP_POWER_RATING_SHORT",
    ["Fire Resistance"] = "ITEM_MOD_FIRE_RESISTANCE_SHORT",
    ["Frost Resistance"] = "ITEM_MOD_FROST_RESISTANCE_SHORT",
    ["Nature Resistance"] = "ITEM_MOD_NATURE_RESISTANCE_SHORT",
    ["Arcane Resistance"] = "ITEM_MOD_ARCANE_RESISTANCE_SHORT",
    ["Shadow Resistance"] = "ITEM_MOD_SHADOW_RESISTANCE_SHORT",
    ["Armor"] = "ITEM_MOD_ARMOR"
}

-- Vérifier si l'addon Wyr3d est chargé
function SPH.IsWyr3dAddonLoaded()
    return IsAddOnLoaded("Wyr3dsIcyVeinsStatsPriorities")
end