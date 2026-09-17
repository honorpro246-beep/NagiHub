-- Maintenance Teaser | Exact Teaser Size + Digital Font

local Players = game:GetService("Players")

local waitFunc = (task and task.wait) or wait

local function cleanName(root, name)
    for _, v in ipairs(root:GetChildren()) do
        if v.Name == name then
            v:Destroy()
        end
    end
end

pcall(function()
    cleanName(game.CoreGui, "RatTeaser")
    cleanName(game.CoreGui, "RatMaintenance")
end)

pcall(function()
    if type(gethui) == "function" then
        cleanName(gethui(), "RatTeaser")
        cleanName(gethui(), "RatMaintenance")
    end
end)

pcall(function()
    local plr = Players.LocalPlayer
    if plr then
        local pg = plr:FindFirstChildOfClass("PlayerGui")
        if pg then
            cleanName(pg, "RatTeaser")
            cleanName(pg, "RatMaintenance")
        end
    end
end)

local FONT = Enum.Font.Code
pcall(function()
    FONT = Enum.Font.PressStart2D
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "RatMaintenance"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999999

local function trySetParent(target)
    if not target then return false end
    local ok = pcall(function()
        Gui.Parent = target
    end)
    return ok and Gui.Parent == target
end

if type(gethui) == "function" then
    local ok, hui = pcall(gethui)
    if ok then trySetParent(hui) end
end

if Gui.Parent == nil then
    trySetParent(game:FindService("CoreGui"))
end

if Gui.Parent == nil then
    repeat waitFunc(0.1) until Players.LocalPlayer
    trySetParent(Players.LocalPlayer:WaitForChild("PlayerGui"))
end

-- Main Frame (точный размер как в тизере)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 120)
Main.Position = UDim2.new(0.5, -160, 0.5, -60)
Main.BackgroundColor3 = Color3.fromRGB(8, 12, 8)
Main.BorderSizePixel = 0
Main.Parent = Gui

local corner = Instance.new("UICorner", Main)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(0, 255, 65)
stroke.Thickness = 1.5

-- Title (точный размер как в тизере)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "ТЕХНИЧЕСКИЕ РАБОТЫ"
Title.TextColor3 = Color3.fromRGB(0, 255, 65)
Title.TextSize = 20
Title.Font = FONT
Title.Parent = Main

-- Sub (точный размер как в тизере)
local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, -20, 0, 25)
Sub.Position = UDim2.new(0, 10, 0, 50)
Sub.BackgroundTransparency = 1
Sub.Text = "СЕРВИС НЕДОСТУПЕН"
Sub.TextColor3 = Color3.fromRGB(140, 255, 170)
Sub.TextSize = 16
Sub.Font = FONT
Sub.Parent = Main

coroutine.wrap(function()
    local dots = ""
    while Gui.Parent do
        waitFunc(0.5)
        dots = dots .. "."
        if #dots > 3 then dots = "" end
        pcall(function()
            Sub.Text = "СЕРВИС НЕДОСТУПЕН" .. dots
        end)
    end
end)()

-- Close button (точный размер как в тизере)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 15)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.TextSize = 16
CloseBtn.Font = FONT
CloseBtn.Parent = Main

local closeCorner = Instance.new("UICorner", CloseBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

local closeStroke = Instance.new("UIStroke", CloseBtn)
closeStroke.Color = Color3.fromRGB(0, 255, 65)
closeStroke.Thickness = 1

CloseBtn.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)
