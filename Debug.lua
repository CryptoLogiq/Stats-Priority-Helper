local addonName, StatsPriorityColors = ...

-- Color codes for debug categories
local categoryColors = {
    SPEC = "|cFF00FFFF",   -- Blue
    TOOLTIP = "|cFF00FF00", -- Green
    STAT = "|cFFFFFF00",   -- Yellow
    INIT = "|cFF00FFFF",   -- Cyan
    EVENT = "|cFFFF00FF",  -- Magenta
    COLOR = "|cFFFFA500",  -- Orange
    DEBUG = "|cFF808080"   -- Gray
}

-- Temporary log queue for early logs
local logQueue = {}
local MAX_QUEUE_SIZE = 100 -- Limit queue size to prevent overflow

-- Flag to track if ADDON_LOADED has fired
local isAddonLoaded = false

-- Logging function
local function WriteLog(message, category)
    if isAddonLoaded and not LogSPCDB then
        return -- Skip logging if LogSPCDB is unexpectedly nil after ADDON_LOADED
    end

    local timestamp = date("%Y-%m-%d %H:%M:%S")
    category = category or "DEBUG"

    if not isAddonLoaded then
        -- Add to queue if ADDON_LOADED hasn't fired
        if #logQueue < MAX_QUEUE_SIZE then
            table.insert(logQueue, { message = message, category = category, timestamp = timestamp })
        end
        return
    end

    -- Initialize LogSPCDB
    if not LogSPCDB.settings then
        LogSPCDB.settings = {
            enabledCategories = {
                SPEC = true, TOOLTIP = true, STAT = true, INIT = true,
                EVENT = true, COLOR = true, DEBUG = true
            }
        }
    end
    if not LogSPCDB.logs then LogSPCDB.logs = {} end
    if not LogSPCDB.logs[category] then LogSPCDB.logs[category] = {} end

    if not LogSPCDB.settings.enabledCategories[category] then return end

    local logs = LogSPCDB.logs[category]
    table.insert(logs, { timestamp = timestamp, message = message })
    if #logs > 1000 then table.remove(logs, 1) end
end
StatsPriorityColors.WriteLog = WriteLog

-- Create debug window
local SPCDebugFrame = CreateFrame("Frame", "SPCDebugFrame", UIParent, "BasicFrameTemplateWithInset")
SPCDebugFrame:SetSize(600, 400)
SPCDebugFrame:SetPoint("CENTER")
SPCDebugFrame:SetMovable(true)
SPCDebugFrame:EnableMouse(true)
SPCDebugFrame:RegisterForDrag("LeftButton")
SPCDebugFrame:SetScript("OnDragStart", SPCDebugFrame.StartMoving)
SPCDebugFrame:SetScript("OnDragStop", SPCDebugFrame.StopMovingOrSizing)
SPCDebugFrame:Hide()

-- Title
SPCDebugFrame.title = SPCDebugFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
SPCDebugFrame.title:SetPoint("TOP", 0, -5)
SPCDebugFrame.title:SetText("StatsPriorityColors Debug")

-- Tabs
local function CreateTabButton(name, text, xOffset)
    local button = CreateFrame("Button", nil, SPCDebugFrame)
    button:SetSize(100, 30)
    button:SetPoint("TOPLEFT", 10 + xOffset, -30)
    button:SetText(text)
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    return button
end

SPCDebugFrame.logsTab = CreateTabButton("SPCDebugLogsTab", "Logs", 0)
SPCDebugFrame.optionsTab = CreateTabButton("SPCDebugOptionsTab", "Options", 100)

-- Logs panel
local logsPanel = CreateFrame("Frame", nil, SPCDebugFrame)
logsPanel:SetPoint("TOPLEFT", 10, -60)
logsPanel:SetPoint("BOTTOMRIGHT", -10, 10)
logsPanel:Hide()

-- Scrolling message frame for logs
logsPanel.scrollFrame = CreateFrame("ScrollingMessageFrame", nil, logsPanel)
logsPanel.scrollFrame:SetPoint("TOPLEFT", 0, -40)
logsPanel.scrollFrame:SetPoint("BOTTOMRIGHT", -20, 0)
logsPanel.scrollFrame:SetFontObject(GameFontNormal)
logsPanel.scrollFrame:SetMaxLines(1000)
logsPanel.scrollFrame:EnableMouseWheel(true)
logsPanel.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    if delta > 0 then self:ScrollUp() else self:ScrollDown() end
end)

-- Filter buttons
local filterButtons = {}
local categories = { "All", "SPEC", "TOOLTIP", "STAT", "INIT", "EVENT", "COLOR", "DEBUG" }
for i, cat in ipairs(categories) do
    local btn = CreateFrame("Button", nil, logsPanel)
    btn:SetSize(80, 20)
    btn:SetPoint("TOPLEFT", (i-1)*85, 0)
    btn:SetText(cat)
    btn:SetNormalFontObject("GameFontNormalSmall")
    btn:SetHighlightFontObject("GameFontHighlightSmall")
    btn:SetScript("OnClick", function()
        logsPanel.scrollFrame:Clear()
        if cat == "All" then
            for _, category in ipairs(categories) do
                if category ~= "All" and LogSPCDB and LogSPCDB.logs[category] then
                    for _, log in ipairs(LogSPCDB.logs[category]) do
                        logsPanel.scrollFrame:AddMessage(categoryColors[category] .. "[" .. log.timestamp .. "] [" .. category .. "]|r " .. log.message)
                    end
                end
            end
        else
            if LogSPCDB and LogSPCDB.logs[cat] then
                for _, log in ipairs(LogSPCDB.logs[cat]) do
                    logsPanel.scrollFrame:AddMessage(categoryColors[cat] .. "[" .. log.timestamp .. "] [" .. cat .. "]|r " .. log.message)
                end
            end
        end
    end)
    filterButtons[cat] = btn
end

-- Options panel
local optionsPanel = CreateFrame("Frame", nil, SPCDebugFrame)
optionsPanel:SetPoint("TOPLEFT", 10, -60)
optionsPanel:SetPoint("BOTTOMRIGHT", -10, 10)
optionsPanel:Hide()

-- Checkboxes for categories
local checkboxes = {}
for i, cat in ipairs(categories) do
    if cat ~= "All" then
        local cb = CreateFrame("CheckButton", "SPCDebugCB" .. cat, optionsPanel, "InterfaceOptionsCheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 10, -20 - (i-1)*30)
        _G[cb:GetName() .. "Text"]:SetText(cat)
        cb:SetChecked(LogSPCDB and LogSPCDB.settings and LogSPCDB.settings.enabledCategories[cat])
        cb:SetScript("OnClick", function(self)
            if LogSPCDB and LogSPCDB.settings then
                LogSPCDB.settings.enabledCategories[cat] = self:GetChecked()
            end
        end)
        checkboxes[cat] = cb
    end
end

-- Tab switching
SPCDebugFrame.logsTab:SetScript("OnClick", function()
    logsPanel:Show()
    optionsPanel:Hide()
    filterButtons["All"]:Click()
end)
SPCDebugFrame.optionsTab:SetScript("OnClick", function()
    logsPanel:Hide()
    optionsPanel:Show()
end)

-- Show logs tab by default
SPCDebugFrame.logsTab:Click()

-- Slash commands
SLASH_SPC1 = "/spc"
SlashCmdList["SPC"] = function(msg)
    local command, subcommand = strsplit(" ", msg)
    if command == "debug" then
        if subcommand == "show" then
            SPCDebugFrame:Show()
        elseif subcommand == "hide" then
            SPCDebugFrame:Hide()
        end
    end
end

-- Interface Options integration for Cataclysm Classic
local function CreateOptionsPanel()
    -- Create a frame for the options panel
    local optionsFrame = CreateFrame("Frame", "SPCOptionsFrame", InterfaceOptionsFramePanelContainer)
    optionsFrame.name = "StatsPriorityColors"
    optionsFrame:Hide()

    -- Set up the title
    local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("StatsPriorityColors Options")

    -- Attach SPCDebugFrame to the options panel
    SPCDebugFrame:SetParent(optionsFrame)
    SPCDebugFrame:ClearAllPoints()
    SPCDebugFrame:SetPoint("TOPLEFT", 16, -40)
    SPCDebugFrame:SetPoint("BOTTOMRIGHT", -16, 16)
    SPCDebugFrame:Show()

    -- Add to Interface Options
    InterfaceOptions_AddFrame(optionsFrame)
end

-- Frame to process queued logs in batches
local queueProcessor = CreateFrame("Frame")
local BATCH_SIZE = 50
local function ProcessQueue()
    if not LogSPCDB then return end
    local count = math.min(BATCH_SIZE, #logQueue)
    for i = 1, count do
        local queuedLog = table.remove(logQueue, 1)
        if queuedLog then
            WriteLog(queuedLog.message, queuedLog.category)
        end
    end
    if #logQueue == 0 then
        queueProcessor:SetScript("OnUpdate", nil)
    end
end

-- Register for ADDON_LOADED to create options panel and process queued logs
local debugFrame = CreateFrame("Frame")
debugFrame:RegisterEvent("ADDON_LOADED")
debugFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize LogSPCDB
        if not LogSPCDB then
            LogSPCDB = {}
        end
        -- Log queue size for debugging
        WriteLog("Processing logQueue with " .. #logQueue .. " entries", "DEBUG")
        -- Start processing queue in batches
        queueProcessor:SetScript("OnUpdate", ProcessQueue)
        -- Mark addon as loaded
        isAddonLoaded = true
        -- Create options panel
        CreateOptionsPanel()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)