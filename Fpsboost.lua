--// SUPER OP FPS BOOSTER
--// Single-file Roblox LocalScript
--// Put in StarterPlayerScripts or execute as a LocalScript

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// Settings
local enabled = false
local connections = {}

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SuperFPSBooster"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 230, 0, 115)
main.Position = UDim2.new(0.5, -115, 0.5, -57)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "⚡ SUPER FPS BOOST"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = main

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0, 0, 0, 35)
status.Size = UDim2.new(1, 0, 0, 25)
status.BackgroundTransparency = 1
status.Text = "Status: OFF"
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.Parent = main

local toggle = Instance.new("TextButton")
toggle.Position = UDim2.new(0, 20, 0, 68)
toggle.Size = UDim2.new(1, -40, 0, 35)
toggle.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
toggle.Text = "ENABLE BOOST"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 14
toggle.Font = Enum.Font.GothamBold
toggle.AutoButtonColor = true
toggle.Parent = main

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = toggle

--// Original lighting values
local oldGlobalShadows = Lighting.GlobalShadows
local oldFogEnd = Lighting.FogEnd
local oldBrightness = Lighting.Brightness

local function optimizeObject(obj)
	if obj:IsA("ParticleEmitter")
		or obj:IsA("Trail")
		or obj:IsA("Beam")
		or obj:IsA("Smoke")
		or obj:IsA("Fire")
		or obj:IsA("Sparkles") then
		
		obj.Enabled = false

	elseif obj:IsA("PostEffect") then
		obj.Enabled = false

	elseif obj:IsA("Decal")
		or obj:IsA("Texture") then
		
		obj.Transparency = 1

	elseif obj:IsA("PointLight")
		or obj:IsA("SpotLight")
		or obj:IsA("SurfaceLight") then
		
		obj.Enabled = false

	elseif obj:IsA("BasePart") then
		obj.CastShadow = false
	end
end

local function enableBoost()
	enabled = true

	--// Aggressive lighting optimization
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 100000
	Lighting.Brightness = 1

	--// Disable expensive lighting effects
	for _, obj in ipairs(Lighting:GetChildren()) do
		optimizeObject(obj)
	end

	--// Optimize everything currently loaded
	for _, obj in ipairs(Workspace:GetDescendants()) do
		optimizeObject(obj)
	end

	--// Automatically optimize newly created effects
	connections.DescendantAdded = Workspace.DescendantAdded:Connect(function(obj)
		if enabled then
			task.defer(function()
				if obj and obj.Parent then
					optimizeObject(obj)
				end
			end)
		end
	end)

	connections.LightingAdded = Lighting.ChildAdded:Connect(function(obj)
		if enabled then
			task.defer(function()
				optimizeObject(obj)
			end)
		end
	end)

	status.Text = "Status: ON"
	status.TextColor3 = Color3.fromRGB(80, 255, 120)

	toggle.Text = "DISABLE BOOST"
	toggle.BackgroundColor3 = Color3.fromRGB(45, 170, 80)
end

local function disableBoost()
	enabled = false

	for _, connection in pairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections)

	--// Restore basic lighting
	Lighting.GlobalShadows = oldGlobalShadows
	Lighting.FogEnd = oldFogEnd
	Lighting.Brightness = oldBrightness

	status.Text = "Status: OFF"
	status.TextColor3 = Color3.fromRGB(255, 80, 80)

	toggle.Text = "ENABLE BOOST"
	toggle.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
end

toggle.MouseButton1Click:Connect(function()
	if enabled then
		disableBoost()
	else
		enableBoost()
	end
end)

--// Make the GUI draggable
local dragging = false
local dragStart
local startPos

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		
		dragInput = input
	end
end)

RunService.RenderStepped:Connect(function()
	if dragging and dragInput then
		local delta = dragInput.Position - dragStart

		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
