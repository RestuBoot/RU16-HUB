-- RU16 Universal GUI FINAL - by ChatGPT
local Players, RunService, UIS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, GUI = Players.LocalPlayer, Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "RU16_GUI"; GUI.ResetOnSpawn = false

-- State
local conns, state = {}, {}

-- Open Button
local openBtn = Instance.new("TextButton", GUI)
openBtn.Text = "☰"; openBtn.Size = UDim2.new(0, 45, 0, 45)
openBtn.Position = UDim2.new(0, 10, 0.3, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
openBtn.TextColor3 = Color3.new(0,0,0)
openBtn.Font = Enum.Font.SourceSansBold; openBtn.TextSize = 20
openBtn.Active, openBtn.Draggable = true, true

-- Main Frame
local frame = Instance.new("ScrollingFrame", GUI)
frame.Size = UDim2.new(0, 360, 0, 260)
frame.Position = UDim2.new(0, 70, 0.3, 0)
frame.CanvasSize = UDim2.new(0,0,0,500)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Visible = false; frame.ScrollBarThickness = 4
frame.Active, frame.Draggable = true, true

local layout = Instance.new("UIGridLayout", frame)
layout.CellSize = UDim2.new(0,170,0,40)
layout.CellPadding = UDim2.new(0,5,0,5)

openBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Toggle creator
function createToggle(name, func)
    local b = Instance.new("TextButton", frame)
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    b.TextColor3 = Color3.new(0,0,0)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 15
    b.Text = "☐ " .. name
    local on = false
    b.MouseButton1Click:Connect(function()
        on = not on
        b.Text = (on and "☑ " or "☐ ") .. name
        func(on)
    end)
end

-- WalkSpeed
createToggle("WalkSpeed", function(on)
    if on then
        conns.ws = RunService.Heartbeat:Connect(function()
            pcall(function() LP.Character.Humanoid.WalkSpeed = 80 end)
        end)
    else
        if conns.ws then conns.ws:Disconnect() end
        pcall(function() LP.Character.Humanoid.WalkSpeed = 16 end)
    end
end)

-- Infinite Jump
createToggle("Infinite Jump", function(on)
    state.infj = on
    if not conns.infj then
        conns.infj = UIS.JumpRequest:Connect(function()
            if state.infj then
                LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

-- Noclip
createToggle("Noclip", function(on)
    if on then
        conns.noclip = RunService.Stepped:Connect(function()
            for _,v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    else if conns.noclip then conns.noclip:Disconnect() end end
end)

-- Invisible
createToggle("Invisible", function(on)
    for _,v in pairs(LP.Character:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.Transparency = on and 1 or 0
        end
    end
end)

-- ESP
createToggle("ESP", function(on)
    if on then
        conns.esp = RunService.RenderStepped:Connect(function()
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                    if not p.Character:FindFirstChild("ESP") then
                        local bb = Instance.new("BillboardGui", p.Character)
                        bb.Name = "ESP"; bb.Adornee = p.Character.Head
                        bb.Size = UDim2.new(0,150,0,20); bb.AlwaysOnTop = true
                        bb.StudsOffset = Vector3.new(0,2,0)
                        local txt = Instance.new("TextLabel", bb)
                        txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.new(1,1,1); txt.Font = Enum.Font.SourceSansBold
                        txt.TextSize = 14; txt.Name = "T"
                    end
                    local dist = math.floor((p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude)
                    if p.Character:FindFirstChild("ESP") and p.Character.ESP:FindFirstChild("T") then
                        p.Character.ESP.T.Text = p.Name .. " ["..dist.."m]"
                    end
                end
            end
        end)
    else
        if conns.esp then conns.esp:Disconnect() end
        for _,p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESP") then
                p.Character.ESP:Destroy()
            end
        end
    end
end)

-- Fling
createToggle("Fling", function(on)
    local root = LP.Character:FindFirstChild("HumanoidRootPart")
    if on then
        conns.fling = RunService.Heartbeat:Connect(function()
            if root then root.RotVelocity = Vector3.new(0, 500, 0) end
        end)
    else
        if conns.fling then conns.fling:Disconnect() end
        if root then root.RotVelocity = Vector3.zero end
    end
end)

-- God Mode
createToggle("God Mode", function(on)
    local hum = LP.Character:FindFirstChild("Humanoid")
    if on and hum then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        for _,ev in pairs(getconnections(hum.HealthChanged)) do ev:Disable() end
    end
end)

-- Teleport
local tpPlayer = nil
local selectBtn = Instance.new("TextButton", frame)
selectBtn.Text = "🎯 Select Player"
selectBtn.Size = UDim2.new(0,160,0,40)
selectBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
selectBtn.TextColor3 = Color3.new(0,0,0)
selectBtn.Font = Enum.Font.SourceSansBold; selectBtn.TextSize = 14
selectBtn.MouseButton1Click:Connect(function()
    local others = {}
    for _,p in pairs(Players:GetPlayers()) do if p ~= LP then table.insert(others, p.Name) end end
    tpPlayer = others[math.random(1, #others)]
    selectBtn.Text = "🎯 "..tpPlayer
end)

local goBtn = Instance.new("TextButton", frame)
goBtn.Text = "🚀 Teleport"
goBtn.Size = UDim2.new(0,160,0,40)
goBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
goBtn.TextColor3 = Color3.new(0,0,0)
goBtn.Font = Enum.Font.SourceSansBold; goBtn.TextSize = 14
goBtn.MouseButton1Click:Connect(function()
    local p = Players:FindFirstChild(tpPlayer or "")
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character:MoveTo(p.Character.HumanoidRootPart.Position + Vector3.new(0,3,0))
    end
end)
