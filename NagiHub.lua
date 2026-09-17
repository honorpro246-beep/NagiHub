-- NagiHub V1.0.21 | Full Build + BK's Hub + Ethos Hub
-- All protections intact. No truncation.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local waitFn = (task and task.wait) or wait
local spawnFn = (task and task.spawn) or spawn
local delayFn = (task and task.delay) or delay or function(t, f) spawnFn(function() waitFn(t) f() end) end

local bxor = (bit32 and bit32.bxor) or (bit and bit.bxor) or function(a, b)
    local res = 0
    for i = 0, 31 do
        local p = 2^i
        local aa, bb = math.floor(a / p) % 2, math.floor(b / p) % 2
        if aa ~= bb then res = res + p end
    end
    return res
end

local Janitor = {}
Janitor.__index = Janitor
function Janitor.new() return setmetatable({_tasks = {}}, Janitor) end
function Janitor:Add(task)
    if type(task) == "table" and task.Disconnect then table.insert(self._tasks, task)
    elseif type(task) == "function" then table.insert(self._tasks, task)
    elseif typeof(task) == "Instance" then table.insert(self._tasks, function() if task and task.Destroy then task:Destroy() end end) end
    return task
end
function Janitor:Cleanup()
    for _, t in ipairs(self._tasks) do
        if type(t) == "function" then pcall(t)
        elseif type(t) == "table" and t.Disconnect then pcall(t.Disconnect, t) end
    end
    self._tasks = {}
end

local AccessState = (function()
    local _level = 1
    return {
        get = function() return _level end,
        set = function(l) _level = l end,
        has = function(req) return _level >= req end
    }
end)()

local SALT = "NagiHub_V103_Salt_8x92mf"

local function mul32(a, b)
    local a_hi = math.floor(a / 65536)
    local a_lo = a % 65536
    local term1 = ((a_hi * b) % 65536) * 65536
    local term2 = a_lo * b
    return (term1 + term2) % 4294967296
end

local function _H(s)
    local h1, h2 = 0x811c9dc5, 0x84222325
    local combined = SALT .. s .. SALT
    for i = 1, #combined do
        local b = string.byte(combined, i)
        h1 = mul32(h1, 0x01000193)
        h1 = bxor(h1, b)
        h2 = mul32(h2, 0x01000193)
        h2 = bxor(h2, (b * 31) % 256)
    end
    return string.format("%08x%08x", h1, h2)
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
        if type(v.Name) == "string" and (v.Name:sub(1, 7) == "NagiHub" or v.Name:sub(1, 6) == "RatHub") then
            v:Destroy()
        end
    end
end)

local Gui = Instance.new("ScreenGui")
local function randomName()
    local s = ""
    for i = 1, 12 do s = s .. string.char(math.random(97, 122)) end
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

local function isAllowedUrl(url)
    for _, prefix in ipairs(AllowedPrefixes) do
        if url:sub(1, #prefix) == prefix then return true end
    end
    return false
end

local function safeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(res) == "string" then return res end
    
    local req = request or http_request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
    if req then
        local ok2, res2 = pcall(req, { Url = url, Method = "GET" })
        if ok2 and res2 then
            if type(res2) == "string" then return res2 end
            if type(res2) == "table" and res2.Body then return res2.Body end
        end
    end
    return ""
end

local function fetchAndRun(url)
    if not isAllowedUrl(url) then error("blocked url") end
    
    local code = safeHttpGet(url)
    if not code or #code == 0 then error("empty response") end
    
    if code:sub(1, 9) == "404: Not " or code:sub(1, 4) == "404:" or code:find("Repository not found") then 
        error("404 text") 
    end
    
    local head = code:sub(1, 32):lower()
    if head:find("<!doctype html", 1, true) or head:find("<html", 1, true) then 
        error("html page") 
    end
    
    if not loadstring then error("no loadstring") end
    local fn, err = loadstring(code)
    if not fn then error("syntax: " .. tostring(err)) end
    
    if setfenv then pcall(setfenv, fn, setmetatable({}, {__index = getfenv and getfenv() or _G})) end
    
    local ok, runErr = pcall(fn)
    if not ok then error("run: " .. tostring(runErr)) end
end

local function BuildMainUI()
    local maid = Janitor.new()
    
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
    Title.Text = "NagiHub V1.0.21 | " .. accessText
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

    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Size = UDim2.new(1, -10, 1, -10)
    ContentScroll.Position = UDim2.new(0, 5, 0, 5)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.ScrollBarThickness = 4
    ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 120)
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentScroll.Parent = ContentArea
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 4)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentScroll

    maid:Add(ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    end))

    local Tabs = {}
    local order = 0
    local tabCount = 0
    
    local currentToken = { cancelled = false }

    local function addLabel(text, color)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color or Color3.fromRGB(150, 150, 150)
        lbl.TextSize = 12
        lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = order
        order = order + 1
        lbl.Parent = ContentScroll
    end

    local function addScriptButton(name, url, requiredAccess)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.Text = "  " .. name
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 12
        btn.Font = Enum.Font.Code
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        order = order + 1
        btn.Parent = ContentScroll
        maid:Add(Instance.new("UICorner", btn)).CornerRadius = UDim.new(0, 4)

        if not AccessState.has(requiredAccess) then
            btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            btn.TextColor3 = Color3.fromRGB(150, 100, 100)
            btn.Text = "🔒 " .. name
            maid:Add(btn.MouseButton1Click:Connect(function()
                if not btn or not btn.Parent then return end
                btn.Text = "  NO ACCESS"
                waitFn(1)
                if btn and btn.Parent then btn.Text = "🔒 " .. name end
            end))
            return
        end

        local busy = false
        maid:Add(btn.MouseButton1Click:Connect(function()
            if busy then return end
            busy = true
            btn.Text = "  LOADING..."
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            
            local myToken = currentToken
            
            spawnFn(function()
                if myToken.cancelled then return end
                
                local errMsg = nil
                local ok = pcall(function()
                    local status, err = pcall(fetchAndRun, url)
                    if not status then
                        errMsg = err
                        error(err)
                    end
                end)
                
                if myToken.cancelled or not btn or not btn.Parent then return end

                if ok then
                    btn.Text = "  EXECUTED"
                    btn.BackgroundColor3 = Color3.fromRGB(10, 40, 20)
                    btn.TextColor3 = Color3.fromRGB(100, 255, 150)
                else
                    local errStr = tostring(errMsg or "unknown")
                    if errStr:find("404") then btn.Text = "  ERR: 404"
                    elseif errStr:find("syntax") then btn.Text = "  ERR: SYNTAX"
                    elseif errStr:find("run") then btn.Text = "  ERR: CRASH"
                    else btn.Text = "  ERR: FETCH" end
                    btn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
                    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
                    warn("[NagiHub] Error running " .. name .. ": " .. errStr)
                end
                waitFn(2)
                if not myToken.cancelled and btn and btn.Parent then
                    btn.Text = "  " .. name
                    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
                end
                busy = false
            end)
        end))
    end

    local function switchTab(tabName)
        currentToken.cancelled = true
        currentToken = { cancelled = false }
        
        order = 0
        for _, v in ipairs(ContentScroll:GetChildren()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then v:Destroy() end
        end
        for name, btn in pairs(Tabs) do
            if name == tabName then
                btn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
                btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            else
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end

        if tabName == "Blox Fruits" then
            addLabel("BLOX FRUITS", Color3.fromRGB(0, 255, 120))
            addScriptButton("Ruby Hub", "https://raw.githubusercontent.com/bloxfruitsnokey/Redz/refs/heads/main/Ruby/update.luau", 2)
            addScriptButton("Emerald Hub", "https://raw.githubusercontent.com/bloxfruitsnokey/Redz/refs/heads/main/Emerald/update.luau", 2)
            addScriptButton("Redz Hub V2", "https://raw.githubusercontent.com/UCT-hub/main/refs/heads/main/redz-v2", 2)
        elseif tabName == "Brookhaven" then
            addLabel("BROOKHAVEN", Color3.fromRGB(0, 255, 120))
            addScriptButton("Slayer Hub", "https://raw.githubusercontent.com/Slayerzxz/slayerhub/refs/heads/main/brookhaven.lua", 2)
            addScriptButton("KitK4t Hub", "https://rawscripts.net/raw/Universal-Script-KitK4t-Hub-137923", 2)
            addScriptButton("TXR Hub", "https://raw.githubusercontent.com/yelelode/UNO/refs/heads/main/source.lua", 1)
        elseif tabName == "Arsenal" then
            addLabel("ARSENAL", Color3.fromRGB(255, 100, 100))
            addScriptButton("PulseHub", "https://pulsehub.gg/arsenal", 2)
            addScriptButton("Ethos Hub", "https://raw.githubusercontent.com/TKyoka/AetherHub/main/Arsenal", 1)
        elseif tabName == "Da Hood" then
            addLabel("DA HOOD", Color3.fromRGB(255, 100, 100))
            addScriptButton("PulseHub", "https://pulsehub.gg/dahood", 2)
        elseif tabName == "Steal a Egg" then
            addLabel("STEAL A EGG", Color3.fromRGB(255, 220, 80))
            addScriptButton("BK's Hub", "https://api.luarmor.net/files/v4/loaders/9ee4edde227ac85f50872bf9e4226508.lua", 2)
        elseif tabName == "Grow Garden" then
            addLabel("GROW A GARDEN", Color3.fromRGB(255, 100, 100))
            addScriptButton("PulseHub", "https://pulsehub.gg/growagarden", 2)
        elseif tabName == "Universal" then
            addLabel("UNIVERSAL", Color3.fromRGB(255, 220, 80))
            addScriptButton("Aimbot v1", "https://raw.githubusercontent.com/honorpro246-beep/Aimbot/refs/heads/main/Aimbot.lua", 1)
            addScriptButton("Gojo R6", "https://cloak-and-script.lovable.app/api/s/w2hffm2ve5?k=fe1b649e332d0a819c5c74cc", 1)
            addScriptButton("Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", 1)
            addScriptButton("Dex Explorer", "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua", 1)
        elseif tabName == "More Games" then
            addLabel("MORE GAMES", Color3.fromRGB(150, 150, 150))
            addLabel("Coming soon...", Color3.fromRGB(100, 100, 100))
        end
    end

    local function createTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 85, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 12
        btn.Font = Enum.Font.Code
        btn.AutoButtonColor = false
        tabCount = tabCount + 1
        btn.LayoutOrder = tabCount
        btn.Parent = TabScroll
        maid:Add(Instance.new("UICorner", btn)).CornerRadius = UDim.new(0, 4)
        Tabs[name] = btn
        maid:Add(btn.MouseButton1Click:Connect(function() switchTab(name) end))
    end

    createTab("Blox Fruits")
    createTab("Brookhaven")
    createTab("Arsenal")
    createTab("Da Hood")
    createTab("Steal a Egg")
    createTab("Grow Garden")
    createTab("Universal")
    createTab("More Games")
    switchTab("Blox Fruits")

    local dragging = false
    local dragStart = nil
    local startPos = nil
    local mainActiveInput = nil

    local miniDragging = false
    local miniDragStart = nil
    local miniActiveInput = nil

    maid:Add(Top.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not mainActiveInput then
            mainActiveInput = input
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end))

    maid:Add(Mini.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not miniActiveInput then
            miniActiveInput = input
            miniDragging = true
            miniDragStart = input.Position
        end
    end))

    maid:Add(UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and input == mainActiveInput and dragStart and startPos then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
            if miniDragging and input == miniActiveInput and miniDragStart then
                local delta = input.Position - miniDragStart
                Mini.Position = UDim2.new(0.03, delta.X, 0.5, -25 + delta.Y)
            end
        end
    end))

    maid:Add(UIS.InputEnded:Connect(function(input)
        if input == mainActiveInput then
            mainActiveInput = nil
            dragging = false
        end
        if input == miniActiveInput then
            local dist = (input.Position - miniDragStart).Magnitude
            if dist < 10 then
                Main.Visible = true
                Mini.Visible = false
            end
            miniActiveInput = nil
            miniDragging = false
        end
    end))
    
    maid:Add(UIS.InputCancelled:Connect(function(input)
        if input == mainActiveInput then mainActiveInput = nil; dragging = false end
        if input == miniActiveInput then miniActiveInput = nil; miniDragging = false end
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
KeyTitle.Text = "NagiHub V1.0.21 | Активация"
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
    s = s:gsub("^[%s\194\160\226\128\139\227\128\128]+", "")
    s = s:gsub("[%s\194\160\226\128\139\227\128\128]+$", "")
    s = s:gsub("\r", "")
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
