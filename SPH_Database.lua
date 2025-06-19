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

SPH.specToStats = specToStats
SPH.specNames = specNames
