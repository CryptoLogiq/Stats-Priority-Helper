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
if AddOn.IsClassic then
    SPH.versionGame = "Classic"
elseif AddOn.IsBCC then
    SPH.versionGame = "Burning Crusade"
elseif AddOn.IsWotLK then
    SPH.versionGame = "Wotlk"
elseif AddOn.IsCata then
    SPH.versionGame = "Cataclysm"
else
    SPH.versionGame = "Retail"
end