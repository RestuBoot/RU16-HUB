--[[
    🔶 RU16 Universal GUI - Horizontal Final
    ✦ Mobile & PC friendly
    ✦ Draggable, scrollable, bold yellow style
    ✦ All features toggleable
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")

-- 📦 Cleanup globals
_G.CONNS = {}
_G.FEATURES = {}

-- 📌 Setup GUI
local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "RU16_GUI"
GUI.ResetOnSpawn = false

-- 🟡 Open Button
local openBtn = Instance.new("TextButton", GUI)
openBtn.Text = "Open GUI"
openBtn.Size = UDim2.new(0, 100, 0, 40)
openBtn.Position = UDim2.new(0, 20, 0, 80)
openBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 0)
openBtn.TextColor3 = Color3.new(0, 0, 0)
openBtn.Font = Enum.Font.SourceSansBold
openBtn.TextSize = 18
openBtn.Draggable = true
openBtn.Active = true

-- 🟨 Main Frame
local main = Instance.new("ScrollingFrame", GUI)
main.Size = UDim2.new(0, 340, 0, 260)
main.Position = UDim2.new(0, 140, 0, 80)
main.CanvasSize = UDim2.new(0, 0, 0, 400)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.Visible = false
main.ScrollBarThickness = 4
main.Active = true
main.Draggable = true

local grid = Instance.new("UIGridLayout", main)
grid.CellSize = UDim2.new(0, 160, 0, 40)
grid.CellPadding = UDim2.new(0, 5, 0, 5)

-- 🔁 Toggle Creator
function createToggle(name, func)
    local btn = Instance.new("TextButton", main)
    btn.Text = "☐ " .. name
    btn.BackgroundColor3 = Color3.fromRGB(255, 230, 0)
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "☑ " or "☐ ") .. name
        func(state)
    end)
end

-- ✅ WalkSpeed
createToggle("WalkSpeed", function(state)
    if state then
        _G.CONNS.ws = RunService.Heartbeat:Connect(function()
            pcall(function() LP.Character.Humanoid.WalkSpeed = 100 end)
        end)
    else
        if _G.CONNS.ws then _G.CONNS.ws:Disconnect() end
        LP.Character.Humanoid.WalkSpeed = 16
    end
end)

-- ✅ Infinite Jump
createToggle("Infinite Jump", function(state)
    _G.FEATURES.infj = state
    if not _G.CONNS.infj then
        _G.CONNS.infj = UIS.JumpRequest:Connect(function()
            if _G.FEATURES.infj then
                LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

-- ✅ Noclip
createToggle("Noclip", function(state)
    if state then
        _G.CONNS.noclip = RunService.Stepped:Connect(function()
            for _, v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    else
        if _G.CONNS.noclip then _G.CONNS.noclip:Disconnect() end
    end
end)

-- ✅ Invisible
createToggle("Invisible", function(state)
    for _, v in pairs(LP.Character:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.Transparency = state and 1 or 0
        end
    end
end)

-- ✅ ESP
createToggle("Player ESP", function(state)
    if state then
        _G.CONNS.esp = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not p.Character:FindFirstChild("ESP") then
                        local gui = Instance.new("BillboardGui", p.Character)
                        gui.Name = "ESP"
                        gui.Adornee = p.Character.Head
                        gui.Size = UDim2.new(0, 150, 0, 20)
                        gui.StudsOffset = Vector3.new(0, 2, 0)
                        gui.AlwaysOnTop = true

                        local label = Instance.new("TextLabel", gui)
                        label.Name = "Tag"
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.new(1, 1, 1)
                        label.Font = Enum.Font.SourceSansBold
                        label.TextSize = 14
                    end
                    local dist = math.floor((p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude)
                    local tag = p.Character:FindFirstChild("ESP") and p.Character.ESP:FindFirstChild("Tag")
                    if tag then
                        tag.Text = p.Name .. " [" .. dist .. "m]"
                    end
                    if not p.Character:FindFirstChild("ESPBox") then
                        local box = Instance.new("BoxHandleAdornment", p.Character)
                        box.Name = "ESPBox"
                        box.Adornee = p.Character.HumanoidRootPart
                        box.Size = Vector3.new(4, 6, 2)
                        box.Color3 = Color3.fromRGB(255, 255, 0)
                        box.Transparency = 0.5
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                    end
                end
            end
        end)
    else
        if _G.CONNS.esp then _G.CONNS.esp:Disconnect() end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("ESP") then p.Character.ESP:Destroy() end
                if p.Character:FindFirstChild("ESPBox") then p.Character.ESPBox:Destroy() end
            end
        end
    end
end)

-- ✅ Fling
createToggle("Fling", function(state)
    if state then
        local hrp = LP.Character:WaitForChild("HumanoidRootPart")
        _G.CONNS.fling = RunService.Heartbeat:Connect(function()
            hrp.Velocity = Vector3.new(200, 0, 0)
        end)
    else
        if _G.CONNS.fling then _G.CONNS.fling:Disconnect() end
    end
end)

-- ✅ Teleport Dropdown
local selected = nil
local dropdown = Instance.new("TextButton", main)
dropdown.Text = "Select Player"
dropdown.BackgroundColor3 = Color3.fromRGB(255, 230, 0)
dropdown.TextColor3 = Color3.new(0, 0, 0)
dropdown.Font = Enum.Font.SourceSansBold
dropdown.TextSize = 16
dropdown.MouseButton1Click:Connect(function()
    local others = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(others, p.Name) end
    end
    selected = others[math.random(1, #others)]
    dropdown.Text = "🎯 " .. selected
end)

local tpBtn = Instance.new("TextButton", main)
tpBtn.Text = "Teleport"
tpBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
tpBtn.TextColor3 = Color3.new(0, 0, 0)
tpBtn.Font = Enum.Font.SourceSansBold
tpBtn.TextSize = 16
tpBtn.MouseButton1Click:Connect(function()
    local plr = Players:FindFirstChild(selected or "")
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character:MoveTo(plr.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
    end
end)

-- ✅ Hide GUI
local hide = Instance.new("TextButton", main)
hide.Text = "Hide GUI"
hide.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
hide.TextColor3 = Color3.new(1, 1, 1)
hide.Font = Enum.Font.SourceSansBold
hide.TextSize = 16
hide.MouseButton1Click:Connect(function()
    main.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    openBtn.Visible = false
end)