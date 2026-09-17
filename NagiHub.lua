local function addMaintenanceButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = "🔧 " .. name .. " (Тех. работы)"
    btn.TextColor3 = Color3.fromRGB(120, 120, 120)
    btn.TextSize = 12
    btn.Font = Enum.Font.Code
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    order = order + 1
    btn.Parent = ContentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            btn.Text = "⏳ Скоро будет..."
            task.wait(1.5)
            btn.Text = "🔧 " .. name .. " (Тех. работы)"
        end)
    end)
end

-- Использование внутри любого таба:
-- addMaintenanceButton("Название скрипта")
