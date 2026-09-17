-- Pre-Release Teaser | Green Hub Style

local Players = game:GetService("Players")

-- Clean old teasers
pcall(function()
    for _, v in ipairs(game.CoreGui:GetChildren()) do
        if v.Name == "RatTeaser" then v:Destroy() end
    end
    if gethui then
        for _, v in ipairs(gethui():GetChildren()) do
            if v.Name == "RatTeaser" then v:Destroy() end
        end
    end
end)

-- Parent fallback
local Gui = Instance.new("ScreenGui")
Gui.Name = "RatTeaser"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999999

local parent = game.CoreGui
pcall(function()
    if gethui then parent = gethui() end
end)
Gui.Parent = parent

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 120)
Main.Position = UDim2.new(0.5, -160, 0.5, -60)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Main.BorderSizePixel = 0
Main.Parent = Gui

local corner = Instance.new("UICorner", Main)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(0, 255, 120) -- THE GREEN
stroke.Thickness = 1.5

-- Title Label
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "СКРИПТ ЕЩЁ НЕ ВЫШЕЛ"
Title.TextColor3 = Color3.fromRGB(0, 255, 120) -- THE GREEN
Title.TextSize = 20
Title.Font = Enum.Font.Code
Title.Parent = Main

-- Sub Label
local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, -20, 0, 25)
Sub.Position = UDim2.new(0, 10, 0, 50)
Sub.BackgroundTransparency = 1
Sub.Text = "Ждите релиза..."
Sub.TextColor3 = Color3.fromRGB(150, 150, 150)
Sub.TextSize = 16
Sub.Font = Enum.Font.Code
Sub.Parent = Main

-- Animated dots for waiting
spawn(function()
    local dots = ""
    while true do
        wait(0.5)
        dots = dots .. "."
        if #dots > 3 then dots = "" end
        pcall(function()
            Sub.Text = "Ждите релиза" .. dots
        end)
    end
end)

-- Close button (small, top right, green style)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(0, 255, 120) -- THE GREEN
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Main

local closeCorner = Instance.new("UICorner", CloseBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)
