local addonName, StatsPriorityColors = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConsole = LibStub("AceConsole-3.0")

-- Créer l'objet addon avec AceAddon
local SPC = AceAddon:NewAddon("StatsPriorityColors", "AceEvent-3.0")

-- Valeurs par défaut pour la base de données
local defaults = {
    char = {
        logs = {},
        settings = {
            debugEnabled = true, -- Activer la journalisation par défaut
            chatOutputEnabled = true, -- Activer la sortie dans le Chat Frame par défaut
            enabledCategories = {
                SPEC = true, TOOLTIP = true, STAT = true, INIT = true,
                EVENT = true, COLOR = true, DEBUG = true
            }
        }
    }
}

-- Couleurs pour les catégories de logs
local categoryColors = {
    SPEC = "|cFF00FFFF",   -- Bleu
    TOOLTIP = "|cFF00FF00", -- Vert
    STAT = "|cFFFFFF00",   -- Jaune
    INIT = "|cFF00FFFF",   -- Cyan
    EVENT = "|cFFFF00FF",  -- Magenta
    COLOR = "|cFFFFA500",  -- Orange
    DEBUG = "|cFF808080"   -- Gris
}

-- Fonction de journalisation
function SPC:WriteLog(message, category)
    if not self.db.char.settings.debugEnabled then return end
    category = category or "DEBUG"
    if not self.db.char.settings.enabledCategories[category] then return end
    if not self.db.char.logs[category] then self.db.char.logs[category] = {} end
    local logs = self.db.char.logs[category]
    table.insert(logs, { timestamp = date("%Y-%m-%d %H:%M:%S"), message = message })
    if #logs > 1000 then table.remove(logs, 1) end
    -- Afficher dans le Chat Frame si activé
    if self.db.char.settings.chatOutputEnabled then
        local color = categoryColors[category] or "|cFF808080"
        local r, g, b = 0.5, 0.5, 0.5 -- Gris par défaut
        if color:match("^|cFF(%x%x)(%x%x)(%x%x)") then
            r = tonumber(color:match("^|cFF(%x%x)"), 16) / 255
            g = tonumber(color:match("^|cFF%x%x(%x%x)"), 16) / 255
            b = tonumber(color:match("^|cFF%x%x%x%x(%x%x)"), 16) / 255
        end
        DEFAULT_CHAT_FRAME:AddMessage("[SPC][" .. category .. "] " .. message, r, g, b)
    end
end

-- Tableaux d'options pour AceConfig
local options = {
    type = "group",
    args = {
        debug = {
            type = "group",
            name = "Debug",
            args = {
                enableDebug = {
                    type = "toggle",
                    name = "Enable Debug Logging",
                    desc = "Enable or disable all debug logs",
                    get = function() return SPC.db.char.settings.debugEnabled end,
                    set = function(_, value) SPC.db.char.settings.debugEnabled = value end,
                },
                chatOutput = {
                    type = "toggle",
                    name = "Enable Chat Output",
                    desc = "Enable or disable debug logs in the Chat Frame",
                    get = function() return SPC.db.char.settings.chatOutputEnabled end,
                    set = function(_, value) SPC.db.char.settings.chatOutputEnabled = value end,
                },
                show = {
                    type = "execute",
                    name = "Afficher la fenêtre de débogage",
                    func = function() SPC:ShowDebugWindow() end
                },
                hide = {
                    type = "execute",
                    name = "Masquer la fenêtre de débogage",
                    func = function() SPC:HideDebugWindow() end
                }
            }
        }
    }
}

-- Enregistrer les options dans le panneau Blizzard
AceConfig:RegisterOptionsTable("StatsPriorityColors", options)
AceConfigDialog:AddToBlizOptions("StatsPriorityColors", "StatsPriorityColors")

-- Fenêtre de débogage
local debugWindow
function SPC:ShowDebugWindow()
    if not debugWindow then
        debugWindow = AceGUI:Create("Frame")
        debugWindow:SetTitle("StatsPriorityColors Debug")
        debugWindow:SetWidth(600)
        debugWindow:SetHeight(400)
        debugWindow:EnableResize(false)
        
        -- Groupe d'onglets
        local tabGroup = AceGUI:Create("TabGroup")
        tabGroup:SetLayout("Flow")
        tabGroup:SetTabs({
            {text = "Logs", value = "logs"},
            {text = "Options", value = "options"}
        })
        tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
            container:ReleaseChildren()
            if group == "logs" then
                SPC:CreateLogsTab(container)
            elseif group == "options" then
                SPC:CreateOptionsTab(container)
            end
        end)
        debugWindow:AddChild(tabGroup)
        tabGroup:SelectTab("logs")
    end
    debugWindow:Show()
end

function SPC:HideDebugWindow()
    if debugWindow then
        debugWindow:Hide()
    end
end

function SPC:CreateLogsTab(container)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    
    local categories = { "All", "SPEC", "TOOLTIP", "STAT", "INIT", "EVENT", "COLOR", "DEBUG" }
    local btnALLcat
    
    for _, cat in ipairs(categories) do
        local currentCat = cat  -- Capture la valeur courante de cat
        local btn = AceGUI:Create("Button")
        btn:SetText(cat)
        btn:SetWidth(100)
        btn:SetCallback("OnClick", function()
            scrollFrame:ReleaseChildren()
            local logText = ""
            if currentCat == "All" then
                for _, category in ipairs(categories) do
                    if category ~= "All" and self.db.char.logs[category] then
                        for _, log in ipairs(self.db.char.logs[category]) do
                            logText = logText .. categoryColors[category] .. "[" .. log.timestamp .. "] [" .. category .. "]|r " .. log.message .. "\n"
                        end
                    end
                end
            else
                if self.db.char.logs[currentCat] then
                    for _, log in ipairs(self.db.char.logs[currentCat]) do
                        logText = logText .. categoryColors[currentCat] .. "[" .. log.timestamp .. "] [" .. currentCat .. "]|r " .. log.message .. "\n"
                    end
                end
            end
            local label = AceGUI:Create("Label")
            label:SetText(logText)
            label:SetFullWidth(true)
            scrollFrame:AddChild(label)
        end)
        container:AddChild(btn)
        if cat == "All" then btnALLcat = btn end
    end
    
    if btnALLcat then
        btnALLcat:Fire("OnClick")
    end
end

function SPC:CreateOptionsTab(container)
    local debugCb = AceGUI:Create("CheckBox")
    debugCb:SetLabel("Enable Debug Logging")
    debugCb:SetValue(self.db.char.settings.debugEnabled)
    debugCb:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.char.settings.debugEnabled = value
    end)
    container:AddChild(debugCb)
    
    local chatCb = AceGUI:Create("CheckBox")
    chatCb:SetLabel("Enable Chat Output")
    chatCb:SetValue(self.db.char.settings.chatOutputEnabled)
    chatCb:SetCallback("OnValueChanged", function(widget, event, value)
        self.db.char.settings.chatOutputEnabled = value
    end)
    container:AddChild(chatCb)
    
    for cat, enabled in pairs(self.db.char.settings.enabledCategories) do
        local cb = AceGUI:Create("CheckBox")
        cb:SetLabel(cat)
        cb:SetValue(enabled)
        cb:SetCallback("OnValueChanged", function(widget, event, value)
            self.db.char.settings.enabledCategories[cat] = value
        end)
        container:AddChild(cb)
    end
end

-- Commandes slash
AceConsole:RegisterChatCommand("spc", function(input)
    local command, subcommand = strsplit(" ", input)
    if command == "debug" then
        if subcommand == "show" then
            SPC:ShowDebugWindow()
        elseif subcommand == "hide" then
            SPC:HideDebugWindow()
        end
    end
end)

-- Initialisation
function SPC:OnInitialize()
    self.db = AceDB:New("StatsPriorityColors", defaults, true)
    self:WriteLog("Debug system initialized", "INIT")
end

-- Enregistrement des événements
SPC:RegisterEvent("ADDON_LOADED", function(event, addon)
    if addon == addonName then
        SPC:WriteLog("ADDON_LOADED pour StatsPriorityColors", "INIT")
    end
end)