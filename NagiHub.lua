-- NagiHub V1.0.3 | Mobile Optimized Build
-- Zero GC spikes, dynamic drag, object pooling, thread cancellation.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local waitFn = (task and task.wait) or wait
local spawnFn = (task and task.spawn) or spawn
local delayFn = (task and task.delay) or delay or function(t, f) spawnFn(function() waitFn(t) f() end) end
local tCancel = (task and task.cancel) or function() end

-- Cached core functions to eliminate GC pressure
local mfloor = math.floor
local sbyte = string.byte
local schar = string.char
local sfind = string.find
local ssub = string.sub
local slower = string.lower
local sformat = string.format
local sgsub = string.gsub
local smatch = string.match
local tinsert = table.insert
local tclear = table.clear

local B = bit32 or bit
local _bxor = B and (B.bxor or B.xor)
if not _bxor then
    _bxor = function(a, b)
        local res = 0
        for i = 0, 31 do
            local p = 2^i
            if mfloor(a / p) % 2 ~= mfloor(b / p) % 2 then res = res + p end
        end
        return res
    end
end

local Janitor = {}
Janitor.__index = Janitor
function Janitor.new() return setmetatable({_tasks = {}}, Janitor) end
function Janitor:Add(task)
    local t = typeof(task)
    if t == "RBXScriptConnection" then
        tinsert(self._tasks, task)
    elseif t == "Instance" then
        tinsert(self._tasks, function() if task and task.Destroy then task:Destroy() end end)
    elseif t == "function" then
        tinsert(self._tasks, task)
    end
    return task
end
function Janitor:Cleanup()
    for _, t in ipairs(self._tasks) do
        if type(t) == "function" then pcall(t)
        elseif typeof(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end
    end
    self._tasks = {}
end

-- Secured Access State
local AccessState = (function()
    local _level = 1
    return {
        get = function() return _level end,
        set = function(l) if type(l) == "number" and l >= 1 and l <= 3 then _level = l end end,
        has = function(req) return _level >= req end
    }
end)()

local SALT = "NagiHub_V103_Salt_8x92mf"

local function mul32(a, b)
    local a_hi = mfloor(a / 65536)
    local a_lo = a % 65536
    local term1 = ((a_hi * b) % 65536) * 65536
    local term2 = a_lo * b
    return (term1 + term2) % 4294967296
end

local function _H(s)
    local h1, h2 = 0x811c9dc5, 0x84222325
    local combined = SALT .. s .. SALT
    local len = #combined
    for i = 1, len do
        local b = sbyte(combined, i)
        h1 = _bxor(mul32(h1, 0x01000193), b)
        h2 = _bxor(mul32(h2, 0x01000193), (b * 31) % 256)
    end
    return sformat("%08x%08x", h1, h2)
end

local _K = {
    ["39a038760b064300"] = 3, ["d2a7228b10bd193f"] = 3, 
    ["3b56e6142db2012e"] = 2, ["b7be832a652d9ad8"] = 2, ["c7edf788897e0436"] = 2,
    ["f12131e64f50af0c"] = 2, ["0c53cc8a77207f84"] = 2, ["7269d28cb0e00216"] = 2,
    ["7a7d3ab291d0de78"] = 2, ["83e58208e1d75976"] = 2, ["e3f965eeab488118"] = 2,
    ["d23926eadd3f4850"] = 2, ["3b764a54c71aadbe"] = 2, ["2118324aff540ac8"] = 2,
    ["b5669438561cee46"] = 2, ["6b90a14edee96168"] = 2, ["0781f6725ca1f9e0"] = 2,
    ["ff58e81c511e7f56"] = 2, ["f6301aa2deb14208"] = 2, ["515931d0c704c2d6"] = 2,
    ["64f5a9fe8bcfdd08"] = 2, ["c1fdc44a3cf952b0"] = 2
}

local failCount = 0
local lockUntil = 0

pcall(function()
    local root = (type(gethui) == "function" and gethui()) 
                 or game:FindService("CoreGui") 
                 or (Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui"))
    if not root then return end
    for _, v in ipairs(root:GetChildren()) do
        if type(v.Name) == "string" and (ssub(v.Name, 1, 7) == "NagiHub" or ssub(v.Name, 1, 6) == "RatHub") then
            v:Destroy()
        end
    end
end)

local Gui = Instance.new("ScreenGui")
local function randomName()
    local s = ""
    for i = 1, 12 do s = s .. schar(math.random(97, 122)) end
    return s
end
Gui.Name = randomName()
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999999
Gui.IgnoreGuiInset = true

local function trySetParent(target)
    if not target then return false end
    local ok = pcall(function() Gui.Parent = target end)
    return ok and Gui.Parent == target
end

if type(gethui) == "function" then
    local ok, hui = pcall(gethui)
    if ok then trySetParent(hui) end
end
if Gui.Parent == nil then trySetParent(game:FindService("CoreGui")) end

if Gui.Parent == nil and Players.LocalPlayer then
    local pgui = Players.LocalPlayer:WaitForChild("PlayerGui", 5)
    if pgui then trySetParent(pgui) end
    if Gui.Parent == nil then trySetParent(game:FindService("CoreGui")) end
end

local AllowedPrefixes = {
    "https://raw.githubusercontent.com/bloxfruitsnokey/Redz/",
    "https://raw.githubusercontent.com/UCT-hub/main/",
    "https://raw.githubusercontent.com/Slayerzxz/slayerhub/",
    "https://rawscripts.net/raw/Universal-Script-KitK4t-Hub-",
    "https://raw.githubusercontent.com/yelelode/UNO/",
    "https://pulsehub.gg/",
    "https://raw.githubusercontent.com/honorpro246-beep/Aimbot/",
    "https://cloak-and-script.lovable.app/api/",
    "https://raw.githubusercontent.com/EdgeIY/infiniteyield/",
    "https://raw.githubusercontent.com/infyiff/backup/",
    "https://api.luarmor.net/files/v4/loaders/",
    "https://raw.githubusercontent.com/TKyoka/AetherHub/"
}

local function isValidUrl(url)
    if type(url) ~= "string" then return false end
    if ssub(url, 1, 7) ~= "http://" and ssub(url, 1, 8) ~= "https://" then return false end
    for _, prefix in ipairs(AllowedPrefixes) do
        if ssub(url, 1, #prefix) == prefix then return true end
    end
    return false
end

local function safeHttpGet(url)
    if not isValidUrl(url) then return nil, "invalid url" end
    
    local req = request or http_request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
    if req then
        local ok, res = pcall(req, { Url = url, Method = "GET" })
        if ok and res then
            if type(res) == "string" then return res, nil end
            if type(res) == "table" and res.Body then return res.Body, nil end
        end
    end
    
    local ok, res = pcall(game.HttpGet, game, url, true)
    if ok and type(res) == "string" then return res, nil end
    
    return nil, "request failed"
end

local function fetchAndRun(url)
    local code, netErr = safeHttpGet(url)
    if netErr then error(netErr) end
    if not code or #code == 0 then error("empty response") end
    
    if ssub(code, 1, 9) == "404: Not " or ssub(code, 1, 4) == "404:" or sfind(code, "Repository not found") then 
        error("404 text") 
    end
    
    local head = slower(ssub(code, 1, 32))
    if sfind(head, "<!doctype html", 1, true) or sfind(head, "<html", 1, true) then 
        error("html page") 
    end
    
    if not loadstring then error("no loadstring") end
    local fn, err = loadstring(code)
    if not fn then error("syntax: " .. tostring(err)) end
    
    local ok, runErr = pcall(fn)
    if not ok then error("run: " .. tostring(runErr)) end
end

local TABS = {
    { name = "Blox Fruits", label = "BLOX FRUITS", color = Color3.fromRGB(0, 255, 120), scripts = {
        { name = "Ruby Hub", url = "https://raw.githubusercontent.com/bloxfruitsnokey/Redz/refs/heads/main/Ruby/update.luau", access = 2 },
        { name = "Emerald Hub", url = "https://raw.githubusercontent.com/bloxfruitsnokey/Redz/refs/heads/main/Emerald/update.luau", access = 2 },
        { name = "Redz Hub V2", url = "https://raw.githubusercontent.com/UCT-hub/main/refs/heads/main/redz-v2", access = 2 },
    }},
    { name = "Brookhaven", label = "BROOKHAVEN", color = Color3.fromRGB(0, 255, 120), scripts = {
        { name = "Slayer Hub", url = "https://raw.githubusercontent.com/Slayerzxz/slayerhub/refs/heads/main/brookhaven.lua", access = 2 },
        { name = "KitK4t Hub", url = "https://rawscripts.net/raw/Universal-Script-KitK4t-Hub-137923", access = 2 },
        { name = "TXR Hub", url = "https://raw.githubusercontent.com/yelelode/UNO/refs/heads/main/source.lua", access = 1 },
    }},
    { name = "Arsenal", label = "ARSENAL", color = Color3.fromRGB(255, 100, 100), scripts = {
        { name = "PulseHub", url = "https://pulsehub.gg/arsenal", access = 2 },
        { name = "Ethos Hub", url = "https://raw.githubusercontent.com/TKyoka/AetherHub/main/Arsenal", access = 1 },
    }},
    { name = "Da Hood", label = "DA HOOD", color = Color3.fromRGB(255, 100, 100), scripts = {
        { name = "PulseHub", url = "https://pulsehub.gg/dahood", access = 2 },
    }},
    { name = "Steal a Egg", label = "STEAL A EGG", color = Color3.fromRGB(255, 220, 80), scripts = {
        { name = "BK's Hub", url = "https://api.luarmor.net/files/v4/loaders/9ee4edde227ac85f50872bf9e4226508.lua", access = 2 },
    }},
    { name = "Grow Garden", label = "GROW A GARDEN", color = Color3.fromRGB(255, 100, 100), scripts = {
        { name = "PulseHub", url = "https://pulsehub.gg/growagarden", access = 2 },
    }},
    { name = "Universal", label = "UNIVERSAL", color = Color3.fromRGB(255, 220, 80), scripts = {
        { name = "Aimbot v1", url = "https://raw.githubusercontent.com/honorpro246-beep/Aimbot/refs/heads/main/Aimbot.lua", access = 1 },
        { name = "Gojo R6", url = "https://cloak-and-script.lovable.app/api/s/w2hffm2ve5?k=fe1b649e332d0a819c5c74cc", access = 1 },
        { name = "Infinite Yield", url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", access = 1 },
        { name = "Dex Explorer", url = "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua", access = 1 },
    }},
    { name = "More Games", label = "MORE GAMES", color = Color3.fromRGB(150, 150, 150), scripts = {} }
}

local function BuildMainUI()
    local maid = Janitor.new()
    local activeThreads = {}
    local tabScrolls = {}
    local tabBtnsUI = {}
    
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 450, 0, 280)
    Main.Position = UDim2.new(0.5, -225, 0.5, -140)
    Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ClipsDescendants = true
    Main.Visible = true
    Main.Parent = Gui
    maid:Add(Instance.new("UICorner", Main)).CornerRadius = UDim.new(0, 10)
    local mainStroke = Instance.new("UIStroke", Main)
    mainStroke.Color = Color3.fromRGB(0, 255, 120)
    mainStroke.Thickness = 1.2

    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1, 0, 0, 32)
    Top.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Top.BorderSizePixel = 0
    Top.Parent = Main
    maid:Add(Instance.new("UICorner", Top)).CornerRadius = UDim.new(0, 10)

    local accessText = "FREE"
    if AccessState.get() == 2 then accessText = "PREMIUM"
    elseif AccessState.get() == 3 then accessText = "OWNER" end

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "NagiHub V1.0.3 | " .. accessText
    Title.TextColor3 = Color3.fromRGB(0, 255, 120)
    Title.TextSize = 14
    Title.Font = Enum.Font.Code
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Top

    local HideBtn = Instance.new("TextButton")
    HideBtn.Size = UDim2.new(0, 26, 0, 26)
    HideBtn.Position = UDim2.new(1, -60, 0, 3)
    HideBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    HideBtn.Text = "_"
    HideBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
    HideBtn.TextSize = 16
    HideBtn.Font = Enum.Font.Code
    HideBtn.Parent = Top
    maid:Add(Instance.new("UICorner", HideBtn)).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -30, 0, 3)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.Parent = Top
    maid:Add(Instance.new("UICorner", CloseBtn)).CornerRadius = UDim.new(0, 6)

    local Mini = Instance.new("TextButton")
    Mini.Size = UDim2.new(0, 50, 0, 50)
    Mini.Position = UDim2.new(0.03, 0, 0.5, -25)
    Mini.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Mini.BorderSizePixel = 0
    Mini.Text = "NAGI"
    Mini.TextColor3 = Color3.fromRGB(0, 255, 120)
    Mini.TextSize = 12
    Mini.Font = Enum.Font.Code
    Mini.Visible = false
    Mini.Parent = Gui
    maid:Add(Instance.new("UICorner", Mini)).CornerRadius = UDim.new(0, 12)
    local miniStroke = Instance.new("UIStroke", Mini)
    miniStroke.Color = Color3.fromRGB(0, 255, 120)
    miniStroke.Thickness = 1.5

    maid:Add(HideBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
        Mini.Visible = true
    end))
    maid:Add(CloseBtn.MouseButton1Click:Connect(function()
        maid:Cleanup()
        Gui:Destroy()
    end))

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -10, 0, 35)
    TabBar.Position = UDim2.new(0, 5, 0, 35)
    TabBar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Main
    maid:Add(Instance.new("UICorner", TabBar)).CornerRadius = UDim.new(0, 8)

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -10, 1, -10)
    TabScroll.Position = UDim2.new(0, 5, 0, 5)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.ScrollingDirection = Enum.ScrollingDirection.X
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.Parent = TabBar
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabScroll

    maid:Add(TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X + 10, 0, 0)
    end))

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -10, 1, -75)
    ContentArea.Position = UDim2.new(0, 5, 0, 72)
    ContentArea.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = Main
    maid:Add(Instance.new("UICorner", ContentArea)).CornerRadius = UDim.new(0, 8)

    -- PRE-RENDER TAB CONTAINERS (Object Pooling)
    for _, tabDef in ipairs(TABS) do
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -10, 1, -10)
        scroll.Position = UDim2.new(0, 5, 0, 5)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 120)
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.Visible = false
        scroll.Parent = ContentArea
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 4)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll
        
        maid:Add(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end))
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = tabDef.label
        lbl.TextColor3 = tabDef.color
        lbl.TextSize = 12
        lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = 0
        lbl.Parent = scroll
        
        local order = 1
        for _, scriptDef in ipairs(tabDef.scripts) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.TextSize = 12
            btn.Font = Enum.Font.Code
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.AutoButtonColor = false
            btn.LayoutOrder = order
            order = order + 1
            btn.Parent = scroll
            maid:Add(Instance.new("UICorner", btn)).CornerRadius = UDim.new(0, 4)
            
            btn:SetAttribute("ScriptName", scriptDef.name)
            
            local function setNormalState()
                btn.Text = "  " .. scriptDef.name
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            end
            
            local function setLockedState()
                btn.Text = "🔒 " .. scriptDef.name
                btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
                btn.TextColor3 = Color3.fromRGB(150, 100, 100)
            end
            
            local function updateState()
                if not AccessState.has(scriptDef.access) then
                    setLockedState()
                else
                    setNormalState()
                end
            end
            updateState()
            
            maid:Add(btn.MouseButton1Click:Connect(function()
                if not AccessState.has(scriptDef.access) then
                    btn.Text = "  NO ACCESS"
                    waitFn(1)
                    if btn and btn.Parent then updateState() end
                    return
                end
                
                if activeThreads[btn] then return end
                
                btn.Text = "  LOADING..."
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                
                local thread = spawnFn(function()
                    local errMsg = nil
                    local ok = pcall(function()
                        local status, err = pcall(fetchAndRun, scriptDef.url)
                        if not status then
                            errMsg = err
                            error(err)
                        end
                    end)
                    
                    activeThreads[btn] = nil
                    
                    if not btn or not btn.Parent then return end
                    
                    if ok then
                        btn.Text = "  EXECUTED"
                        btn.BackgroundColor3 = Color3.fromRGB(10, 40, 20)
                        btn.TextColor3 = Color3.fromRGB(100, 255, 150)
                    else
                        local errStr = tostring(errMsg or "unknown")
                        if sfind(errStr, "404") then btn.Text = "  ERR: 404"
                        elseif sfind(errStr, "syntax") then btn.Text = "  ERR: SYNTAX"
                        elseif sfind(errStr, "run") then btn.Text = "  ERR: CRASH"
                        else btn.Text = "  ERR: FETCH" end
                        btn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
                        btn.TextColor3 = Color3.fromRGB(255, 80, 80)
                        warn("[NagiHub] Error running " .. scriptDef.name .. ": " .. errStr)
                    end
                    waitFn(2)
                    if btn and btn.Parent then updateState() end
                end)
                
                activeThreads[btn] = thread
            end))
        end
        
        tabScrolls[tabDef.name] = scroll
    end

    local function createTab(name, layoutOrder)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 85, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 12
        btn.Font = Enum.Font.Code
        btn.AutoButtonColor = false
        btn.LayoutOrder = layoutOrder
        btn.Parent = TabScroll
        maid:Add(Instance.new("UICorner", btn)).CornerRadius = UDim.new(0, 4)
        tabBtnsUI[name] = btn
        maid:Add(btn.MouseButton1Click:Connect(function() 
            -- Cancel loading threads on tab switch
            for b, thread in pairs(activeThreads) do
                pcall(tCancel, thread)
                activeThreads[b] = nil
                if b and b.Parent then
                    b.Text = "  " .. b:GetAttribute("ScriptName")
                    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    b.TextColor3 = Color3.fromRGB(220, 220, 220)
                end
            end
            
            for n, s in pairs(tabScrolls) do s.Visible = (n == name) end
            for n, b in pairs(tabBtnsUI) do
                if n == name then
                    b.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
                    b.TextColor3 = Color3.fromRGB(0, 0, 0)
                else
                    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    b.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
        end))
    end

    for i, tabDef in ipairs(TABS) do
        createTab(tabDef.name, i)
    end
    
    -- Initial tab state
    tabScrolls["Blox Fruits"].Visible = true
    tabBtnsUI["Blox Fruits"].BackgroundColor3 = Color3.fromRGB(0, 255, 120)
    tabBtnsUI["Blox Fruits"].TextColor3 = Color3.fromRGB(0, 0, 0)

    -- DYNAMIC DRAG OPTIMIZATION (No global InputChanged polling)
    local mainDragConn = nil
    local mainActiveInput = nil
    local dragStart = nil
    local startPos = nil

    maid:Add(Top.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not mainActiveInput then
            mainActiveInput = input
            dragStart = input.Position
            startPos = Main.Position
            
            if mainDragConn then mainDragConn:Disconnect() end
            mainDragConn = UIS.InputChanged:Connect(function(chInput)
                if chInput == mainActiveInput then
                    local delta = chInput.Position - dragStart
                    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
        end
    end))

    local miniDragConn = nil
    local miniActiveInput = nil
    local miniDragStart = nil

    maid:Add(Mini.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not miniActiveInput then
            miniActiveInput = input
            miniDragStart = input.Position
            
            if miniDragConn then miniDragConn:Disconnect() end
            miniDragConn = UIS.InputChanged:Connect(function(chInput)
                if chInput == miniActiveInput then
                    local delta = chInput.Position - miniDragStart
                    Mini.Position = UDim2.new(0.03, delta.X, 0.5, -25 + delta.Y)
                end
            end)
        end
    end))

    maid:Add(UIS.InputEnded:Connect(function(input)
        if input == mainActiveInput then
            mainActiveInput = nil
            if mainDragConn then mainDragConn:Disconnect() mainDragConn = nil end
        end
        if input == miniActiveInput then
            if miniDragStart then
                local dist = (input.Position - miniDragStart).Magnitude
                if dist < 10 then
                    Main.Visible = true
                    Mini.Visible = false
                end
            end
            miniActiveInput = nil
            miniDragStart = nil
            if miniDragConn then miniDragConn:Disconnect() miniDragConn = nil end
        end
    end))
    
    maid:Add(UIS.InputCancelled:Connect(function(input)
        if input == mainActiveInput then
            mainActiveInput = nil
            if mainDragConn then mainDragConn:Disconnect() mainDragConn = nil end
        end
        if input == miniActiveInput then
            miniActiveInput = nil
            miniDragStart = nil
            if miniDragConn then miniDragConn:Disconnect() miniDragConn = nil end
        end
    end))

    maid:Add(Gui.AncestryChanged:Connect(function(_, newParent)
        if newParent == nil then maid:Cleanup() end
    end))
end

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 380, 0, 220)
KeyFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
KeyFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
KeyFrame.BorderSizePixel = 0
KeyFrame.Visible = true
KeyFrame.Parent = Gui
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)
local keyStroke = Instance.new("UIStroke", KeyFrame)
keyStroke.Color = Color3.fromRGB(0, 255, 120)
keyStroke.Thickness = 1.5

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, -20, 0, 35)
KeyTitle.Position = UDim2.new(0, 10, 0, 10)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "NagiHub V1.0.3 | Активация"
KeyTitle.TextColor3 = Color3.fromRGB(0, 255, 120)
KeyTitle.TextSize = 18
KeyTitle.Font = Enum.Font.Code
KeyTitle.Parent = KeyFrame

local KeySub = Instance.new("TextLabel")
KeySub.Size = UDim2.new(1, -20, 0, 25)
KeySub.Position = UDim2.new(0, 10, 0, 50)
KeySub.BackgroundTransparency = 1
KeySub.Text = "Введите ключ для доступа"
KeySub.TextColor3 = Color3.fromRGB(180, 180, 180)
KeySub.TextSize = 14
KeySub.Font = Enum.Font.Code
KeySub.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 0, 35)
KeyInput.Position = UDim2.new(0, 10, 0, 85)
KeyInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
KeyInput.Text = ""
KeyInput.PlaceholderText = "Введите ключ..."
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Code
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = KeyFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 125)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Code
StatusLabel.Parent = KeyFrame

local ValidateBtn = Instance.new("TextButton")
ValidateBtn.Size = UDim2.new(0, 160, 0, 35)
ValidateBtn.Position = UDim2.new(0, 10, 0, 155)
ValidateBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
ValidateBtn.Text = "Активировать"
ValidateBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ValidateBtn.TextSize = 14
ValidateBtn.Font = Enum.Font.Code
ValidateBtn.Parent = KeyFrame
Instance.new("UICorner", ValidateBtn).CornerRadius = UDim.new(0, 6)

local FreeBtn = Instance.new("TextButton")
FreeBtn.Size = UDim2.new(0, 160, 0, 35)
FreeBtn.Position = UDim2.new(1, -170, 0, 155)
FreeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FreeBtn.Text = "Продолжить (Free)"
FreeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
FreeBtn.TextSize = 14
FreeBtn.Font = Enum.Font.Code
FreeBtn.Parent = KeyFrame
Instance.new("UICorner", FreeBtn).CornerRadius = UDim.new(0, 6)

local function trim(s)
    if type(s) ~= "string" then return "" end
    s = sgsub(s, "^[%s\194\160\226\128\139\227\128\128]+", "")
    s = sgsub(s, "[%s\194\160\226\128\139\227\128\128]+$", "")
    s = sgsub(s, "\r", "")
    return s
end

local isValidating = false

local function doValidate()
    if isValidating then return end
    isValidating = true
    
    if os.clock() < lockUntil then
        StatusLabel.Text = "Слишком много попыток"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        isValidating = false
        return
    end
    local key = trim(KeyInput.Text)
    local hash = _H(key)
    
    if _K[hash] then
        AccessState.set(_K[hash])
        failCount = 0
        local accessText = "FREE"
        if AccessState.get() == 2 then accessText = "PREMIUM"
        elseif AccessState.get() == 3 then accessText = "OWNER" end
        
        StatusLabel.Text = "✓ Доступ получен: " .. accessText
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
        
        delayFn(0.7, function()
            KeyFrame:Destroy()
            BuildMainUI()
        end)
    else
        failCount = failCount + 1
        if failCount >= 5 then
            lockUntil = os.clock() + 15
            failCount = 0
            StatusLabel.Text = "Заблокировано на 15 секунд"
        else
            StatusLabel.Text = "✗ Неверный ключ"
        end
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        isValidating = false
    end
end

ValidateBtn.MouseButton1Click:Connect(doValidate)
KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then doValidate() end
end)

FreeBtn.MouseButton1Click:Connect(function()
    if isValidating then return end
    isValidating = true
    
    if os.clock() < lockUntil then
        StatusLabel.Text = "Слишком много попыток"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        isValidating = false
        return
    end
    AccessState.set(1)
    StatusLabel.Text = "Free доступ активирован"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    
    delayFn(0.7, function()
        KeyFrame:Destroy()
        BuildMainUI()
    end)
end)
