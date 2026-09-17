-- RatHub v12.0 | Whitelist + Wide/Short Layout

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- WHITELIST CHECK
local Whitelist = {
    ["batyr5555557"] = "Owner",
    ["erybard"] = "Tester"
}

local username = LocalPlayer.Name
local accessLevel = Whitelist[username]

local function spawnFn(f) pcall(function() task.spawn(f) end) end
local function waitFn(t) pcall(function() task.wait(t) end) end

-- Clean old hubs
pcall(function()
    for _, v in ipairs(game.CoreGui:GetChildren()) do
        if v.Name:sub(1, 6) == "RatHub" then v:Destroy() end
    end
    if gethui then
        for _, v in ipairs(gethui():GetChildren()) do
            if v.Name:sub(1, 6) == "RatHub" then v:Destroy() end
        end
    end
end)

-- Parent fallback
local Gui = Instance.new("ScreenGui")
Gui.Name = "RatHubWideV12"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999999
local parent = game.CoreGui
pcall(function() if gethui then parent = gethui() end end)
Gui.Parent = parent

-- ACCESS DENIED SCREEN
if not accessLevel then
    local Deny = Instance.new("Frame")
    Deny.Size = UDim2.new(0, 300, 0, 80)
    Deny.Position = UDim2.new(0.5, -150, 0.5, -40)
    Deny.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
    Deny.BorderSizePixel = 0
    Deny.Parent = Gui
    
    local dc = Instance.new("UICorner", Deny)
    dc.CornerRadius = UDim.new(0, 8)
    
    local ds = Instance.new("UIStroke", Deny)
    ds.Color = Color3.fromRGB(255, 50, 50)
    ds.Thickness = 2
    
    local dt = Instance.new("TextLabel")
    dt.Size = UDim2.new(1, 0, 1, 0)
    dt.BackgroundTransparency = 1
    dt.Text = "ACCESS DENIED\nUSER: " .. username .. "\nWHITELIST ONLY"
    dt.TextColor3 = Color3.fromRGB(255, 80, 80)
    dt.TextSize = 16
    dt.Font = Enum.Font.Code
    dt.TextWrapped = true
    dt.Parent = Deny
    
    spawnFn(function()
        waitFn(4)
        Gui:Destroy()
    end)
    return -- STOP EXECUTION HERE FOR UNAUTHORIZED USERS
end

-- MAIN FRAME (WIDE & SHORT)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 450, 0, 230)
Main.Position = UDim2.new(0.5, -225, 0.8, -240) -- Bottom center-ish
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = true
Main.Parent = Gui

local mainCorner = Instance.new("UICorner", Main)
mainCorner.CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(0, 255, 120)
mainStroke.Thickness = 1.2

-- TOP BAR
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 28)
Top.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Top.BorderSizePixel = 0
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "RATHUB | " .. string.upper(accessLevel) .. ": " .. username
Title.TextColor3 = Color3.fromRGB(0, 255, 120)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 26, 0, 26)
HideBtn.Position = UDim2.new(1, -60, 0, 1)
HideBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
HideBtn.Text = "_"
HideBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
HideBtn.TextSize = 16
HideBtn.Font = Enum.Font.Code
HideBtn.Parent = Top
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -30, 0, 1)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Top
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- MINI ICON
local Mini = Instance.new("TextButton")
Mini.Size = UDim2.new(0, 50, 0, 50)
Mini.Position = UDim2.new(0.85, 0, 0.8, 0)
Mini.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Mini.BorderSizePixel = 0
Mini.Text = "4080"
Mini.TextColor3 = Color3.fromRGB(0, 255, 120)
Mini.TextSize = 14
Mini.Font = Enum.Font.Code
Mini.Visible = false
Mini.Parent = Gui
Instance.new("UICorner", Mini).CornerRadius = UDim.new(0, 12)
local miniStroke = Instance.new("UIStroke", Mini)
miniStroke.Color = Color3.fromRGB(0, 255, 120)
miniStroke.Thickness = 1.5

-- TAB BAR (Horizontal wide)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -10, 0, 35)
TabBar.Position = UDim2.new(0, 5, 0, 30)
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

pcall(function()
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
end)

-- CONTENT AREA
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -10, 1, -70)
ContentArea.Position = UDim2.new(0, 5, 0, 68)
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

pcall(function()
    ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
end)

-- LOGIC
local Tabs = {}
local order = 0

local function addLabel(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
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

local function addScriptButton(name, url)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
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
    
    local busy = false
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        btn.Text = "  LOADING..."
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        
        spawnFn(function()
            local ok = pcall(function()
                local code = game:HttpGet(url)
                assert(code and #code > 0)
                loadstring(code)()
            end)
            
            if ok then
                btn.Text = "  EXECUTED"
                btn.BackgroundColor3 = Color3.fromRGB(10, 40, 20)
                btn.TextColor3 = Color3.fromRGB(100, 255, 150)
            else
                btn.Text = "  404 / FAILED"
                btn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
                btn.TextColor3 = Color3.fromRGB(255, 80, 80)
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
        addScriptButton("Ruby Hub", "https://raw.githubusercontent.com/bloxfruitsnokey/Redz/refs/heads/main/Ruby/update.luau")
        addScriptButton("Emerald Hub", "https://raw.githubusercontent.com/bloxfruitsnokey/Redz/refs/heads/main/Emerald/update.luau")
        addScriptButton("Redz Hub V2", "https://raw.githubusercontent.com/UCT-hub/main/refs/heads/main/redz-v2")
    elseif tabName == "Arsenal" then
        addLabel("ARSENAL", Color3.fromRGB(255, 100, 100))
        addScriptButton("PulseHub", "https://pulsehub.gg/arsenal")
    elseif tabName == "Da Hood" then
        addLabel("DA HOOD", Color3.fromRGB(255, 100, 100))
        addScriptButton("PulseHub", "https://pulsehub.gg/dahood")
    elseif tabName == "Brookhaven" then
        addLabel("BROOKHAVEN", Color3.fromRGB(255, 100, 100))
        addScriptButton("CmdX", "https://raw.githubusercontent.com/AZYsGaming/CMD-X/main/loader")
    elseif tabName == "Grow Garden" then
        addLabel("GROW A GARDEN", Color3.fromRGB(255, 100, 100))
        addScriptButton("PulseHub", "https://pulsehub.gg/growagarden")
    elseif tabName == "Universal" then
        addLabel("UNIVERSAL", Color3.fromRGB(255, 220, 80))
        addScriptButton("Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
        addScriptButton("Dex Explorer", "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")
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
createTab("Arsenal")
createTab("Da Hood")
createTab("Brookhaven")
createTab("Grow Garden")
createTab("Universal")
createTab("More Games")

switchTab("Blox Fruits")

-- HIDE/SHOW
local function hideToMini()
    Main.Visible = false
    Mini.Visible = true
end

HideBtn.MouseButton1Click:Connect(hideToMini)
Mini.MouseButton1Click:Connect(function()
    Main.Visible = true
    Mini.Visible = false
end)

-- DRAG LOGIC
local dragging, dragStart, startPos = false, nil, nil

Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
