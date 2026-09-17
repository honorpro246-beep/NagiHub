-- NagiHub V1.0.1 | Final Links Edition
-- Keys hashed only. URLs plain. Delta-safe.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local waitFn = (task and task.wait) or wait
local spawnFn = (task and task.spawn) or spawn
local httpGet = game.HttpGet

pcall(function() math.randomseed(tick()) end)

local function _H(s)
    local h1, h2 = 0x811c9dc5, 0x1b873593
    for i = 1, #s do
        local b = string.byte(s, i)
        h1 = (h1 * 31 + b) % 4294967296
        h2 = (h2 * 37 + b) % 4294967296
    end
    return string.format("%08x%08x", h1, h2)
end

local _K = {
    ["4608a5a01733a05a"] = 3, 
    ["8b6b61832dd32cc1"] = 3, 
    ["59a15cfe73ae4158"] = 2, ["06e2a2b49bd2fdda"] = 2, ["945b86ea542edb4c"] = 2,
    ["61e21060829d2112"] = 2, ["60b4914c8a1a99be"] = 2, ["248b93f6b18d29d0"] = 2,
    ["d1ccd9acd9b1e652"] = 2, ["5f45bde2920dc3c4"] = 2, ["2cc0728cc067ed56"] = 2,
    ["730d8278606576a2"] = 2, ["ef75caeeef6c1248"] = 2, ["9cb710a41790ceca"] = 2,
    ["2a2ff4dacfecac3c"] = 2, ["d0c41904ec320af6"] = 2, ["3df7b9709e445f1a"] = 2,
    ["ba6001e62d4afac0"] = 2, ["67a1479c556fb742"] = 2, ["86b90c526336b93c"] = 2,
    ["9bae4ffc2a10f36e"] = 2, ["08e1f068dc234792"] = 2
}

local CurrentAccess = 1
local failCount = 0
local lockUntil = 0

pcall(function()
    local root = game.CoreGui
    if gethui then root = gethui() end
    for _, v in ipairs(root:GetChildren()) do
        if type(v.Name) == "string" and (v.Name:sub(1, 7) == "NagiHub" or v.Name:sub(1, 6) == "RatHub") then
            v:Destroy()
        end
    end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "NagiHub_" .. tostring(math.random(100000, 999999))
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
if Gui.Parent == nil then pcall(function() trySetParent(Players.LocalPlayer:WaitForChild("PlayerGui")) end) end

local function hasAccess(requiredAccess)
    return CurrentAccess >= requiredAccess
end

local AllowedHosts = {
    ["raw.githubusercontent.com"] = true,
    ["rawscripts.net"] = true,
    ["pulsehub.gg"] = true,
    ["cloak-and-script.lovable.app"] = true
}

local function getHost(url)
    return url:match("^https?://([^/]+)")
end

local function safeHttpGet(url)
    local code = ""
    local ok, res = pcall(function() return httpGet(game, url, true) end)
    if ok and type(res) == "string" and #res > 0 then
        code = res
    end
    if code == "" then
        local req = request or (syn and syn.request) or (http and http.request)
        if req then
            local ok2, res2 = pcall(function()
                return req({ Url = url, Method = "GET" })
            end)
            if ok2 and res2 and res2.Success and res2.Body then
                code = res2.Body
            elseif ok2 and res2 and res2.StatusCode == 200 and res2.Body then
                code = res2.Body
            end
        end
    end
    return code
end

local function fetchAndRun(url)
    local host = getHost(url)
    if not host or not AllowedHosts[host] then error("blocked host") end
    
    local code = safeHttpGet(url)
    
    if not code or #code == 0 then error("empty response") end
    
    local head = code:sub(1, 32):lower()
    if head:find("<!doctype html", 1, true) or head:find("<html", 1, true) then 
        error("404 html page") 
    end
    
    if not loadstring then error("no loadstring") end
    
    local fn, err = loadstring(code)
    if not fn then error("syntax: " .. tostring(err)) end
    
    local ok, runErr = pcall(fn)
    if not ok then error("run: " .. tostring(runErr)) end
end

local function BuildMainUI()
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 450, 0, 280)
    Main.Position = UDim2.new(0.5, -225, 0.5, -140)
    Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Visible = true
    Main.Parent = Gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local mainStroke = Instance.new("UIStroke", Main)
    mainStroke.Color = Color3.fromRGB(0, 255, 120)
    mainStroke.Thickness = 1.2

    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1, 0, 0, 32)
    Top.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Top.BorderSizePixel = 0
    Top.Parent = Main
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 10)

    local accessText = "FREE"
    if CurrentAccess == 2 then accessText = "PREMIUM"
    elseif CurrentAccess == 3 then accessText = "OWNER" end

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "NagiHub V1.0.1 | " .. accessText
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
    Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -30, 0, 3)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.Parent = Top
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

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
    Instance.new("UICorner", Mini).CornerRadius = UDim.new(0, 12)
    local miniStroke = Instance.new("UIStroke", Mini)
    miniStroke.Color = Color3.fromRGB(0, 255, 120)
    miniStroke.Thickness = 1.5

    HideBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
        Mini.Visible = true
    end)
    Mini.MouseButton1Click:Connect(function()
        Main.Visible = true
        Mini.Visible = false
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -10, 0, 35)
    TabBar.Position = UDim2.new(0, 5, 0, 35)
    TabBar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Main
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

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
    pcall(function() TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X end)

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -10, 1, -75)
    ContentArea.Position = UDim2.new(0, 5, 0, 72)
    ContentArea.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = Main
    Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 8)

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
    pcall(function() ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y end)

    local Tabs = {}
    local order = 0

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
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        if not hasAccess(requiredAccess) then
            btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            btn.TextColor3 = Color3.fromRGB(150, 100, 100)
            btn.Text = "🔒 " .. name
            btn.MouseButton1Click:Connect(function()
                btn.Text = "  NO ACCESS"
                waitFn(1)
                btn.Text = "🔒 " .. name
            end)
            return
        end

        local busy = false
        btn.MouseButton1Click:Connect(function()
            if busy then return end
            busy = true
            btn.Text = "  LOADING..."
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            spawnFn(function()
                local errMsg = nil
                local ok = pcall(function()
                    local status, err = pcall(fetchAndRun, url)
                    if not status then
                        errMsg = err
                        error(err)
                    end
                end)
                
                if ok then
                    btn.Text = "  EXECUTED"
                    btn.BackgroundColor3 = Color3.fromRGB(10, 40, 20)
                    btn.TextColor3 = Color3.fromRGB(100, 255, 150)
                else
                    local errStr = tostring(errMsg or "unknown")
                    if errStr:find("404") or errStr:find("html") then
                        btn.Text = "  ERR: 404"
                    elseif errStr:find("syntax") then
                        btn.Text = "  ERR: SYNTAX"
                    elseif errStr:find("run") then
                        btn.Text = "  ERR: CRASH"
                    else
                        btn.Text = "  ERR: FETCH"
                    end
                    btn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
                    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
                    warn("[NagiHub] Error running " .. name .. ": " .. errStr)
                end
                waitFn(2)
                btn.Text = "  " .. name
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                btn.TextColor3 = Color3.fromRGB(220, 220, 220)
                busy = false
            end)
        end)
    end

    local function switchTab(tabName)
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
        elseif tabName == "Da Hood" then
            addLabel("DA HOOD", Color3.fromRGB(255, 100, 100))
            addScriptButton("PulseHub", "https://pulsehub.gg/dahood", 2)
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
        btn.LayoutOrder = #Tabs
        btn.Parent = TabScroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        Tabs[name] = btn
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
    end

    createTab("Blox Fruits")
    createTab("Brookhaven")
    createTab("Arsenal")
    createTab("Da Hood")
    createTab("Grow Garden")
    createTab("Universal")
    createTab("More Games")
    switchTab("Blox Fruits")

    local dragging, dragStart, startPos = false, nil, nil
    local miniDragging, miniDragStart, miniStartPos = false, nil, nil

    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Mini.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniDragging = true
            miniDragStart = input.Position
            miniStartPos = Mini.Position
        end
    end)

    local changedConn = UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and dragStart and startPos then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
            if miniDragging and miniDragStart and miniStartPos then
                local delta = input.Position - miniDragStart
                Mini.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X, miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y)
            end
        end
    end)

    local endedConn = UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            miniDragging = false
        end
    end)

    Gui.AncestryChanged:Connect(function(_, newParent)
        if newParent == nil then
            pcall(function() changedConn:Disconnect() end)
            pcall(function() endedConn:Disconnect() end)
        end
    end)
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
KeyTitle.Text = "NagiHub V1.0.1 | Активация"
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
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function doValidate()
    if tick() < lockUntil then
        StatusLabel.Text = "Слишком много попыток"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    local key = trim(KeyInput.Text)
    local hash = _H(key)
    
    if _K[hash] then
        CurrentAccess = _K[hash]
        failCount = 0
        local accessText = "FREE"
        if CurrentAccess == 2 then accessText = "PREMIUM"
        elseif CurrentAccess == 3 then accessText = "OWNER" end
        
        StatusLabel.Text = "✓ Доступ получен: " .. accessText
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
        waitFn(0.7)
        KeyFrame:Destroy()
        BuildMainUI()
    else
        failCount = failCount + 1
        if failCount >= 5 then
            lockUntil = tick() + 15
            failCount = 0
            StatusLabel.Text = "Заблокировано на 15 секунд"
        else
            StatusLabel.Text = "✗ Неверный ключ"
        end
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

ValidateBtn.MouseButton1Click:Connect(doValidate)
KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then doValidate() end
end)

FreeBtn.MouseButton1Click:Connect(function()
    if tick() < lockUntil then
        StatusLabel.Text = "Слишком много попыток"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    CurrentAccess = 1
    StatusLabel.Text = "Free доступ активирован"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    waitFn(0.7)
    KeyFrame:Destroy()
    BuildMainUI()
end)
