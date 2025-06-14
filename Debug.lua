local addonName, addon = ...
local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local SPC = LibStub("AceAddon-3.0"):NewAddon("StatsPriorityColors", "AceEvent-3.0")

-- Valeurs par défaut
local defaults = {
    char = {
        logs = {},
        settings = {
            debugEnabled = true,
            chatOutputEnabled = false, -- always false by defaut
            enabledCategories = {
                SPEC = true,
                TOOLTIP = true,
                STAT = true,
                INIT = true,
                EVENT = true,
                COLOR = true,
                DEBUG = true
            }
        }
    }
}

-- Couleurs des catégories
local categoryColors = {
    SPEC = "|cFF00FFFF",
    TOOLTIP = "|cFF00FF00",
    STAT = "|cFFFFFF00",
    INIT = "|cFF00FFFF",
    EVENT = "|cFFFF00FF",
    COLOR = "|cFFFFA500",
    DEBUG = "|cFF808080"
}

-- Catégories de logs
local categories = { "All", "SPEC", "TOOLTIP", "STAT", "INIT", "EVENT", "COLOR", "DEBUG" }

-- Fonction de journalisation
function SPC:WriteLog(message, category)
    if not self.db.char.settings.debugEnabled then return end
    category = category or "DEBUG"
    if not self.db.char.settings.enabledCategories[category] then return end
    if not self.db.char.logs[category] then self.db.char.logs[category] = {} end
    local logs = self.db.char.logs[category]
    table.insert(logs, { timestamp = date("%Y-%m-%d %H:%M:%S"), message = message })
    if #logs > 1000 then table.remove(logs, 1) end
    if self.db.char.settings.chatOutputEnabled then
        local color = categoryColors[category] or "|cFF808080"
        local r, g, b = 0.5, 0.5, 0.5
        if color:match("^|cFF(%x%x)(%x%x)(%x%x)") then
            r = tonumber(color:match("^|cFF(%x%x)"), 16) / 255
            g = tonumber(color:match("^|cFF%x%x(%x%x)"), 16) / 255
            b = tonumber(color:match("^|cFF%x%x%x%x(%x%x)"), 16) / 255
        end
        DEFAULT_CHAT_FRAME:AddMessage("[SPC][" .. category .. "] " .. message, r, g, b)
    end
end

-- Fenêtre de débogage
function SPC:ShowDebugWindow()
    if not SPC.debugWindow then
        SPC.debugWindow = AceGUI:Create("Frame")
        SPC.debugWindow:SetTitle("StatsPriorityColors Debug")
        SPC.debugWindow:SetWidth(800)
        SPC.debugWindow:SetHeight(400)
        SPC.debugWindow:EnableResize(false)
        SPC.debugWindow:SetLayout("Flow")
        
        -- Cadre gauche pour la navigation
        local leftGroup = AceGUI:Create("SimpleGroup")
        leftGroup:SetLayout("List")
        leftGroup:SetWidth(100)
        leftGroup:SetFullHeight(true)
        SPC.debugWindow:AddChild(leftGroup)
        
        -- Boutons de navigation
        local logsBtn = AceGUI:Create("Button")
        logsBtn:SetText("Logs")
        logsBtn:SetWidth(98)
        logsBtn:SetCallback("OnClick", function()
            SPC.currentPanel = "logs"
            SPC:ShowLogsPanel()
        end)
        leftGroup:AddChild(logsBtn)
        
        local optionsBtn = AceGUI:Create("Button")
        optionsBtn:SetText("Options")
        optionsBtn:SetWidth(98)
        optionsBtn:SetCallback("OnClick", function()
            SPC.currentPanel = "options"
            SPC:ShowOptionsPanel()
        end)
        leftGroup:AddChild(optionsBtn)
        
        -- Cadre droit pour le contenu
        local rightGroup = AceGUI:Create("SimpleGroup")
        rightGroup:SetLayout("Fill")
        rightGroup:SetWidth(700)
        rightGroup:SetFullHeight(true)
        SPC.debugWindow:AddChild(rightGroup)
        
        -- Stocker les références
        SPC.debugWindow.leftGroup = leftGroup
        SPC.debugWindow.rightGroup = rightGroup
        
        -- Afficher le panneau Logs initialement
        SPC.currentPanel = "logs"
        SPC:ShowLogsPanel()
    else
        if SPC.currentPanel == "logs" then
            SPC:ShowLogsPanel()
        elseif SPC.currentPanel == "options" then
            SPC:ShowOptionsPanel()
        end
    end
    SPC.debugWindow:Show()
    SPC.debugWindow.isHidden = false
end

function SPC:HideDebugWindow()
    if SPC.debugWindow then
        SPC.debugWindow:Hide()
        SPC.debugWindow.isHidden = true
    end
end

-- Afficher le panneau Logs
function SPC:ShowLogsPanel()
    local rightGroup = SPC.debugWindow.rightGroup
    rightGroup:ReleaseChildren()
    
    -- Sous-cadre supérieur pour les onglets
    local topTabs = AceGUI:Create("SimpleGroup")
    topTabs:SetLayout("Flow")
    topTabs:SetFullWidth(true)
    topTabs:SetHeight(30)
    rightGroup:AddChild(topTabs)
    
    for _, cat in ipairs(categories) do
        local btn = AceGUI:Create("Button")
        btn:SetText(cat)
        btn:SetWidth(98)
        btn:SetCallback("OnClick", function()
            SPC:DisplayLogs(cat)
        end)
        topTabs:AddChild(btn)
    end
    
    -- Sous-cadre inférieur pour le contenu
    local contentArea = AceGUI:Create("ScrollFrame")
    contentArea:SetLayout("Fill")
    contentArea:SetFullWidth(true)
    contentArea:SetHeight(370)
    rightGroup:AddChild(contentArea)
    
    -- Afficher les logs "All" initialement
    SPC:DisplayLogs("All")
end

-- Afficher les logs pour une catégorie
function SPC:DisplayLogs(category)
    local rightGroup = SPC.debugWindow.rightGroup
    local contentArea = rightGroup.children[2]
    if not contentArea then return end
    contentArea:ReleaseChildren()
    
    local logText = ""
    if category == "All" then
        for _, cat in ipairs(categories) do
            if cat ~= "All" and self.db.char.logs[cat] then
                for _, log in ipairs(self.db.char.logs[cat]) do
                    logText = logText .. categoryColors[cat] .. "[" .. log.timestamp .. "] [" .. cat .. "]|r " .. log.message .. "\n"
                end
            end
        end
    else
        if self.db.char.logs[category] then
            for _, log in ipairs(self.db.char.logs[category]) do
                logText = logText .. categoryColors[category] .. "[" .. log.timestamp .. "] [" .. category .. "]|r " .. log.message .. "\n"
            end
        end
    end
    
    local label = AceGUI:Create("Label")
    label:SetText(logText or "Aucun log trouvé.")
    label:SetFullWidth(true)
    contentArea:AddChild(label)
end

-- Afficher le panneau Options
function SPC:ShowOptionsPanel()
    local rightGroup = SPC.debugWindow.rightGroup
    rightGroup:ReleaseChildren()
    
    -- Sous-cadre supérieur pour les onglets
    local topTabs = AceGUI:Create("SimpleGroup")
    topTabs:SetLayout("Flow")
    topTabs:SetFullWidth(true)
    topTabs:SetHeight(30)
    rightGroup:AddChild(topTabs)
    
    local tabs = { "Debug", "Personnage" }
    for _, tab in ipairs(tabs) do
        local btn = AceGUI:Create("Button")
        btn:SetText(tab)
        btn:SetWidth(98)
        btn:SetCallback("OnClick", function()
            SPC:DisplayOptions(tab)
        end)
        topTabs:AddChild(btn)
    end
    
    -- Sous-cadre inférieur pour le contenu
    local contentArea = AceGUI:Create("SimpleGroup")
    contentArea:SetLayout("List")
    contentArea:SetFullWidth(true)
    contentArea:SetHeight(370)
    rightGroup:AddChild(contentArea)
    
    -- Afficher l’onglet "Debug" initialement
    SPC:DisplayOptions("Debug")
end

-- Afficher le contenu des options
function SPC:DisplayOptions(tab)
    local rightGroup = SPC.debugWindow.rightGroup
    local contentArea = rightGroup.children[2]
    if not contentArea then return end
    contentArea:ReleaseChildren()
    
    if tab == "Debug" then
        -- Case à cocher pour activer le débogage
        local debugToggle = AceGUI:Create("CheckBox")
        debugToggle:SetLabel("Activer le débogage")
        debugToggle:SetValue(SPC.db.char.settings.debugEnabled)
        debugToggle:SetDescription("Active ou désactive les messages de débogage dans le chat.")
        debugToggle:SetCallback("OnValueChanged", function(widget, event, value)
            SPC.db.char.settings.debugEnabled = value
            SPC:WriteLog("Débogage " .. (value and "activé" or "désactivé"), "DEBUG")
        end)
        contentArea:AddChild(debugToggle)
        
        -- Case à cocher pour les logs dans le chat
        local chatToggle = AceGUI:Create("CheckBox")
        chatToggle:SetLabel("Afficher les logs dans le chat")
        chatToggle:SetValue(SPC.db.char.settings.chatOutputEnabled)
        chatToggle:SetDescription("Affiche les messages de débogage dans la fenêtre de chat.")
        chatToggle:SetCallback("OnValueChanged", function(widget, event, value)
            SPC.db.char.settings.chatOutputEnabled = value
            SPC:WriteLog("Logs dans le chat " .. (value and "activés" or "désactivés"), "DEBUG")
        end)
        contentArea:AddChild(chatToggle)
    elseif tab == "Personnage" then
        local label = AceGUI:Create("Label")
        label:SetText("Options spécifiques au personnage (à implémenter).")
        label:SetFullWidth(true)
        contentArea:AddChild(label)
    end
end

-- Initialisation
function SPC:OnInitialize()
    self.db = AceDB:New("StatsPriorityColors", defaults, true)
    self:WriteLog("Système de débogage initialisé", "INIT")
    
    -- Définir les options pour le menu in-game
    local options = {
        name = "StatsPriorityColors",
        type = "group",
        args = {
            debugEnabled = {
                type = "toggle",
                name = "Activer le débogage",
                desc = "Active ou désactive les messages de débogage dans le chat.",
                get = function() return self.db.char.settings.debugEnabled end,
                set = function(_, value)
                    self.db.char.settings.debugEnabled = value
                    self:WriteLog("Débogage " .. (value and "activé" or "désactivé"), "DEBUG")
                end,
            },
            chatOutputEnabled = {
                type = "toggle",
                name = "Afficher les logs dans le chat",
                desc = "Affiche les messages de débogage dans la fenêtre de chat.",
                get = function() return self.db.char.settings.chatOutputEnabled end,
                set = function(_, value)
                    self.db.char.settings.chatOutputEnabled = value
                    self:WriteLog("Logs dans le chat " .. (value and "activés" or "désactivés"), "DEBUG")
                end,
            },
        },
    }
    AceConfig:RegisterOptionsTable("StatsPriorityColors", options)
    AceConfigDialog:AddToBlizOptions("StatsPriorityColors", "StatsPriorityColors")
end

-- Commandes slash
AceConsole:RegisterChatCommand("spc", function(input)
    local command, subcommand = strsplit(" ", input)
    if command == "debug" then
        if subcommand == "show" then
            SPC:ShowDebugWindow()
        elseif subcommand == "hide" then
            SPC:HideDebugWindow()
        elseif subcommand == "toggle" then
            SPC.debugWindow.isHidden = not SPC.debugWindow.isHidden
            if SPC.debugWindow.isHidden then
                SPC:HideDebugWindow()
            else
                SPC:ShowDebugWindow()
            end
        end
    end
end)

-- Message de débogage pour confirmer le chargement
SPC:WriteLog("Debug.lua chargé", "INIT")