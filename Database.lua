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

-- Correspondance des noms de classes localisés vers l'anglais
local classLocalization = {
    ["Paladine"] = "PALADIN",
}

-- Correspondance des spécialisations aux stats pertinentes (en français)
local specToStats = {
    ["PALADIN"] = {
        {"Intelligence", "Puissance des sorts", "Hâte", "Esprit", "Critique", "Maîtrise" },-- 1 Sacré
        { "Endurance", "Maîtrise", "Toucher", "Expertise", "Esquive", "Parade", "Critique" },-- 2 Protection
        {"Force", "Maîtrise", "Toucher 8%", "Expertise", "Critique", "Hâte" } -- 3 Rétribution
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

SPC.classLocalization = classLocalization
SPC.specToStats = specToStats
SPC.specNames = specNames
