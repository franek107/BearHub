-- ================================================
-- BearHub v2 - Full Script (z poprawionym Rapid Fire)
-- WalkSpeed, JumpPower, Inventory ESP, Rapid Fire fix
-- ================================================

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local SoundService = game:GetService("SoundService")
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CLICK_SOUND_ID = "rbxassetid://6895079853"
local SLIDER_SOUND_ID = "rbxassetid://5765856907"
local DRAG_SOUND_ID = "rbxassetid://5765856907"

local PURPLE = Color3.fromRGB(100, 70, 200)
local GRAY = Color3.fromRGB(60, 60, 70)
local DARK = Color3.fromRGB(35, 35, 42)
local CHECK_ICON = "rbxassetid://6031094667"
local BEAR_ICON = "rbxassetid://7733658504"

--============================================================
-- USTAWIENIA
--============================================================
local ESP = {
	Enabled = true,
	MaxDistance = 300,
	ShowLocalPlayer = false,
	VisibleOnly = false,
	Box = {Enabled=false, Color=Color3.fromRGB(255,255,255)},
	Skeleton = {Enabled=true, Color=Color3.fromRGB(255,255,255)},
	Name = {Enabled=true, Color=Color3.fromRGB(255,255,255)},
	ID = {Enabled=false, Color=Color3.fromRGB(255,255,255)},
	HealthBar = {Enabled=false, Color=Color3.fromRGB(0,255,0)},
	Distance = {Enabled=false, Color=Color3.fromRGB(255,255,255)},
	Snaplines = {Enabled=false, Color=Color3.fromRGB(100,70,200)},
	Inventory = {Enabled=false, Color=Color3.fromRGB(255,200,100)},
}

local TRIGGERBOT = {
	Enabled = false, KeybindName = "NONE", KeybindCheck = nil,
	Type = "First Person", ShowFOV = false,
	FOVColor = Color3.fromRGB(100, 70, 200), FOV = 30,
	ExcludeDead = false, VisibleOnly = false,
	MaxDistance = 250, ShotDelay = 100,
}

local AIMBOT = {
	Enabled = false, KeybindName = "NONE", KeybindCheck = nil,
	DrawFOV = false, FOVColor = Color3.fromRGB(100, 70, 200),
	VisibleCheck = false, ExcludeDead = true,
	Bone = "Head", FOV = 10, MaxDistance = 250,
	SmoothX = 80, SmoothY = 80,
}

local HITBOX = {Enabled = false, Bone = "Head", Size = 0}

local MISC = {
	SemiGod = false,
	NoRecoil = false,
	NoSpread = false,
	InfAmmo = false,
	NoClip = false,
	NoClipSpeed = 30,
	SuperPunch = false,
	PunchMultiplier = 100,
	RapidFire = false,
	RapidFireLevel = 20,
	WalkSpeedEnabled = false,
	WalkSpeedValue = 16,
	JumpPowerEnabled = false,
	JumpPowerValue = 50,
}

local SPECTATE = {Target = nil, Active = false}
local mbHeld = {[1]=false,[2]=false,[3]=false,[4]=false,[5]=false}

local espGui = Instance.new("ScreenGui"); espGui.Name = "BearHub_ESP"; espGui.ResetOnSpawn = false; espGui.IgnoreGuiInset = true; espGui.DisplayOrder = 100; espGui.Parent = playerGui
local fovGui = Instance.new("ScreenGui"); fovGui.Name = "BearHub_FOV"; fovGui.ResetOnSpawn = false; fovGui.IgnoreGuiInset = true; fovGui.DisplayOrder = 99; fovGui.Parent = playerGui
local gui = Instance.new("ScreenGui"); gui.Name = "BearHub"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 9999; gui.Parent = playerGui

--============================================================
-- FUNKCJE POMOCNICZE
--============================================================
do
	local function playSound(id, volume, pitch)
		local s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = volume or 0.3
		s.PlaybackSpeed = pitch or 1
		s.Parent = SoundService
		s:Play()
		s.Ended:Connect(function() s:Destroy() end)
	end

	_G.BearHub_playClick = function() playSound(CLICK_SOUND_ID, 0.25, 1.2) end
	_G.BearHub_playSlider = function() playSound(SLIDER_SOUND_ID, 0.15, 1.5) end

	_G.BearHub_doClick = function()
		pcall(function() VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0) end)
		task.wait(0.01)
		pcall(function() VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0) end)
	end

	local dragSoundObj, dragSoundPlaying = nil, false
	_G.BearHub_startDragSound = function()
		if dragSoundPlaying then return end
		dragSoundPlaying = true
		dragSoundObj = Instance.new("Sound")
		dragSoundObj.SoundId = DRAG_SOUND_ID
		dragSoundObj.Volume = 0.12
		dragSoundObj.PlaybackSpeed = 0.8
		dragSoundObj.Looped = true
		dragSoundObj.Parent = SoundService
		dragSoundObj:Play()
	end

	_G.BearHub_stopDragSound = function()
		if not dragSoundPlaying then return end
		dragSoundPlaying = false
		if dragSoundObj then
			dragSoundObj:Stop()
			dragSoundObj:Destroy()
			dragSoundObj = nil
		end
	end
end

local playClick = _G.BearHub_playClick
local playSlider = _G.BearHub_playSlider
local doClick = _G.BearHub_doClick
local startDragSound = _G.BearHub_startDragSound
local stopDragSound = _G.BearHub_stopDragSound

--============================================================
-- SPECTATE + TELEPORT
--============================================================
do
	local function getRoot(char)
		if not char then return nil end
		return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	end

	local function startSpectate(target)
		if target and target.Character then
			local hum = target.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				Camera.CameraSubject = hum
				SPECTATE.Target = target
				SPECTATE.Active = true
			end
		end
	end

	local function stopSpectate()
		SPECTATE.Active = false
		SPECTATE.Target = nil
		local myChar = player.Character
		if myChar then
			local hum = myChar:FindFirstChildOfClass("Humanoid")
			if hum then Camera.CameraSubject = hum end
		end
	end

	_G.BearHub_startSpectate = startSpectate
	_G.BearHub_stopSpectate = stopSpectate

	_G.BearHub_teleportTo = function(target)
		local myRoot = getRoot(player.Character)
		local targetRoot = getRoot(target.Character)
		if myRoot and targetRoot then
			myRoot.CFrame = targetRoot.CFrame + Vector3.new(0,3,0)
			return true, "Teleported to " .. target.Name
		end
		return false, "Failed"
	end

	_G.BearHub_bringPlayer = function(target)
		local myRoot = getRoot(player.Character)
		local targetRoot = getRoot(target.Character)
		if myRoot and targetRoot then
			targetRoot.CFrame = myRoot.CFrame * CFrame.new(0,0,-3)
			return true, "Brought " .. target.Name
		end
		return false, "Failed"
	end
end

local startSpectate = _G.BearHub_startSpectate
local stopSpectate = _G.BearHub_stopSpectate
local teleportTo = _G.BearHub_teleportTo
local bringPlayer = _G.BearHub_bringPlayer

--============================================================
-- ESP + INVENTORY
--============================================================
do
	local fovCircle = Instance.new("Frame", fovGui)
	fovCircle.BackgroundTransparency = 1
	fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
	fovCircle.Position = UDim2.new(0.5,0,0.5,0)
	fovCircle.Visible = false
	local stroke = Instance.new("UIStroke", fovCircle)
	stroke.Color = PURPLE
	stroke.Thickness = 1.5
	Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1,0)

	local fovCircleAim = fovCircle:Clone()
	fovCircleAim.Parent = fovGui

	local espObjects = {}
	local inventoryCache = {}
	local lastCacheTime = {}

	local function getPlayerInventory(plr)
		local now = tick()
		if lastCacheTime[plr] and now - lastCacheTime[plr] < 1.2 then
			return inventoryCache[plr] or {}
		end
		local items = {}
		if plr.Character then
			for _, v in ipairs(plr.Character:GetChildren()) do
				if v:IsA("Tool") then table.insert(items, v.Name) end
			end
		end
		local bp = plr:FindFirstChildOfClass("Backpack")
		if bp then
			for _, v in ipairs(bp:GetChildren()) do
				if v:IsA("Tool") then table.insert(items, v.Name) end
			end
		end
		inventoryCache[plr] = items
		lastCacheTime[plr] = now
		return items
	end

	local function makeLine(parent)
		local f = Instance.new("Frame", parent)
		f.BackgroundColor3 = Color3.new(1,1,1)
		f.BorderSizePixel = 0
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Visible = false
		return f
	end

	local function makeText(parent, sz)
		local t = Instance.new("TextLabel", parent)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.GothamBold
		t.TextSize = sz or 14
		t.TextColor3 = Color3.new(1,1,1)
		t.TextStrokeTransparency = 0
		t.TextStrokeColor3 = Color3.new(0,0,0)
		t.Size = UDim2.new(0, 240, 0, 18)
		t.Visible = false
		return t
	end

	local function drawLine(f, p1, p2, th)
		local dx = p2.X - p1.X
		local dy = p2.Y - p1.Y
		local len = math.sqrt(dx*dx + dy*dy)
		f.Position = UDim2.new(0, (p1.X+p2.X)/2, 0, (p1.Y+p2.Y)/2)
		f.Size = UDim2.new(0, len, 0, th or 1)
		f.Rotation = math.deg(math.atan2(dy, dx))
	end

	local function createESPData(plr)
		local h = Instance.new("Folder", espGui)
		h.Name = plr.Name
		local d = {
			holder = h,
			boxTop = makeLine(h), boxBot = makeLine(h), boxLeft = makeLine(h), boxRight = makeLine(h),
			skeleton = {}, snapline = makeLine(h),
			healthBg = makeLine(h), healthFill = makeLine(h),
			name = makeText(h, 14), id = makeText(h, 12),
			distance = makeText(h, 12), inventory = makeText(h, 11),
		}
		for i = 1, 12 do d.skeleton[i] = makeLine(h) end
		espObjects[plr] = d
		return d
	end

	local function hideAll(d)
		for k,v in pairs(d) do
			if k ~= "holder" then
				if type(v) == "table" then
					for _,x in pairs(v) do pcall(function() x.Visible = false end) end
				else pcall(function() v.Visible = false end) end
			end
		end
	end

	local R15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"}}
	local R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

	local function w2s(pos)
		local v = Camera:WorldToViewportPoint(pos)
		return Vector2.new(v.X, v.Y), v.Z > 0, v.Z
	end

	local function updateESP()
		if not ESP.Enabled then
			for _, d in pairs(espObjects) do hideAll(d) end
			return
		end

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == player and not ESP.ShowLocalPlayer then continue end
			local char = plr.Character
			if not char then continue end

			local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
			local head = char:FindFirstChild("Head")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not root or not head or not hum or hum.Health <= 0 then continue end

			local dist = (Camera.CFrame.Position - root.Position).Magnitude
			if dist > ESP.MaxDistance then continue end

			local sp, onScreen = w2s(root.Position)
			if not onScreen then continue end

			local data = espObjects[plr] or createESPData(plr)
			local hp = w2s(head.Position + Vector3.new(0,0.5,0))
			local lp = w2s(root.Position - Vector3.new(0,3,0))
			local bH = math.clamp(math.abs(lp.Y - hp.Y), 20, 800)
			local bW = bH * 0.55
			local tY, bY = hp.Y, lp.Y
			local lX, rX = sp.X - bW/2, sp.X + bW/2

			-- Box, Name, Distance, Inventory, Skeleton, Snaplines, HealthBar (skrócone dla czytelności)
			if ESP.Box.Enabled then
				drawLine(data.boxTop, Vector2.new(lX,tY), Vector2.new(rX,tY), 1)
				drawLine(data.boxBot, Vector2.new(lX,bY), Vector2.new(rX,bY), 1)
				drawLine(data.boxLeft, Vector2.new(lX,tY), Vector2.new(lX,bY), 1)
				drawLine(data.boxRight, Vector2.new(rX,tY), Vector2.new(rX,bY), 1)
				for _,f in pairs({data.boxTop,data.boxBot,data.boxLeft,data.boxRight}) do
					f.BackgroundColor3 = ESP.Box.Color
					f.Visible = true
				end
			end

			local offset = 0
			if ESP.Name.Enabled then
				data.name.Text = plr.DisplayName
				data.name.Position = UDim2.new(0, sp.X, 0, tY - 18)
				data.name.TextColor3 = ESP.Name.Color
				data.name.Visible = true
				offset = 18
			end

			if ESP.Distance.Enabled then
				data.distance.Text = math.floor(dist) .. "m"
				data.distance.Position = UDim2.new(0, sp.X, 0, bY + 8 + offset)
				data.distance.TextColor3 = ESP.Distance.Color
				data.distance.Visible = true
				offset = offset + 16
			end

			if ESP.Inventory.Enabled then
				local inv = getPlayerInventory(plr)
				local txt = #inv > 0 and table.concat(inv, ", ") or "Empty"
				if #txt > 38 then txt = txt:sub(1,35) .. "..." end
				data.inventory.Text = "[" .. txt .. "]"
				data.inventory.Position = UDim2.new(0, sp.X, 0, bY + 8 + offset)
				data.inventory.TextColor3 = ESP.Inventory.Color
				data.inventory.Visible = true
			end

			-- Skeleton i reszta (możesz rozwinąć jeśli chcesz)
			if ESP.Skeleton.Enabled then
				local bones = char:FindFirstChild("UpperTorso") and R15 or R6
				for i, pair in ipairs(bones) do
					local a = char:FindFirstChild(pair[1])
					local b = char:FindFirstChild(pair[2])
					if a and b then
						local s1 = w2s(a.Position)
						local s2 = w2s(b.Position)
						drawLine(data.skeleton[i], s1, s2, 2)
						data.skeleton[i].BackgroundColor3 = ESP.Skeleton.Color
						data.skeleton[i].Visible = true
					end
				end
			end
		end
	end

	RunService.RenderStepped:Connect(updateESP)
end

--============================================================
-- MOVEMENT + COMBAT (WalkSpeed, JumpPower, RapidFire - NAPRAWIONY)
--============================================================
do
	-- WalkSpeed & JumpPower
	RunService.Heartbeat:Connect(function()
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				if MISC.WalkSpeedEnabled then hum.WalkSpeed = MISC.WalkSpeedValue end
				if MISC.JumpPowerEnabled then hum.JumpPower = MISC.JumpPowerValue end
			end
		end
	end)

	-- NoClip + Fly
	local flying = false
	local bv, bg = nil, nil
	RunService.Stepped:Connect(function()
		if MISC.NoClip and player.Character then
			for _, part in ipairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.CanCollide = false
				end
			end
			if not flying then
				flying = true
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				if root then
					bv = Instance.new("BodyVelocity", root); bv.MaxForce = Vector3.new(9e9,9e9,9e9)
					bg = Instance.new("BodyGyro", root); bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.P = 10000
				end
			end
			if bv and bg then
				local cam = Camera.CFrame
				local move = Vector3.new()
				if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
				bv.Velocity = move.Unit * (MISC.NoClipSpeed or 30)
				bg.CFrame = cam
			end
		elseif flying then
			flying = false
			if bv then bv:Destroy() bv = nil end
			if bg then bg:Destroy() bg = nil end
		end
	end)

	-- Rapid Fire - NAPRAWIONY (nie zacina myszki)
	local currentToolConnection = nil
	local function startRapidFire(tool)
		if currentToolConnection then currentToolConnection:Disconnect() end
		currentToolConnection = tool.Activated:Connect(function()
			if not MISC.RapidFire then return end
			local delay = math.max((MISC.RapidFireLevel / 20) * 0.09, 0.008)
			for _ = 1, 5 do
				pcall(function()
					VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
					task.wait(0.008)
					VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
				end)
				task.wait(delay)
			end
		end)
	end

	local function hookTool(tool)
		if not tool:IsA("Tool") then return end
		tool.Equipped:Connect(function()
			if MISC.RapidFire then
				startRapidFire(tool)
			end
		end)
	end

	player.CharacterAdded:Connect(function(c)
		task.wait(0.4)
		for _, tool in pairs(c:GetChildren()) do hookTool(tool) end
		c.ChildAdded:Connect(hookTool)
	end)

	task.spawn(function()
		while true do
			task.wait(2)
			if player.Character then
				for _, tool in pairs(player.Character:GetChildren()) do hookTool(tool) end
			end
			local bp = player:FindFirstChildOfClass("Backpack")
			if bp then
				for _, tool in pairs(bp:GetChildren()) do hookTool(tool) end
			end
		end
	end)
end

--============================================================
-- GUI
--============================================================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 700, 0, 480)
main.Position = UDim2.new(0.5, -350, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 190, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, -200, 1, -20)
contentArea.Position = UDim2.new(0, 200, 0, 10)
contentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

local contentTitle = Instance.new("TextLabel", contentArea)
contentTitle.Size = UDim2.new(1, -20, 0, 40)
contentTitle.Position = UDim2.new(0, 15, 0, 10)
contentTitle.BackgroundTransparency = 1
contentTitle.Text = "Visualization"
contentTitle.TextColor3 = Color3.new(1,1,1)
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextSize = 20
contentTitle.TextXAlignment = Enum.TextXAlignment.Left

local pagesFrame = Instance.new("Frame", contentArea)
pagesFrame.Size = UDim2.new(1,0,1,-55)
pagesFrame.Position = UDim2.new(0,0,0,55)
pagesFrame.BackgroundTransparency = 1

local function createPage(name)
	local p = Instance.new("ScrollingFrame", pagesFrame)
	p.Size = UDim2.new(1,0,1,0)
	p.BackgroundTransparency = 1
	p.ScrollBarThickness = 4
	p.ScrollBarImageColor3 = PURPLE
	p.Visible = false
	p.AutomaticCanvasSize = Enum.AutomaticSize.Y
	return p
end

local vizPage = createPage("Visualization")
local aimPage = createPage("AimAssistance")
local miscPage = createPage("Miscellaneous")
local playersPage = createPage("Players")
local settingsPage = createPage("Settings")

-- GUI Helpers (mkSection, mkCheck, mkSlider itd.)
local function mkSection(parent, text, order)
	local l = Instance.new("TextLabel", parent)
	l.Size = UDim2.new(1,0,0,28)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(160,160,170)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = order
end

local function mkCheck(parent, text, tbl, key, order)
	local h = Instance.new("Frame", parent)
	h.Size = UDim2.new(1,0,0,30)
	h.BackgroundTransparency = 1
	h.LayoutOrder = order
	local enabled = tbl[key] or false
	local box = Instance.new("TextButton", h)
	box.Size = UDim2.new(0,22,0,22)
	box.Position = UDim2.new(0,5,0.5,-11)
	box.BackgroundColor3 = enabled and PURPLE or GRAY
	box.Text = ""
	Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)
	local checkImg = Instance.new("ImageLabel", box)
	checkImg.Size = UDim2.new(0.8,0,0.8,0)
	checkImg.Position = UDim2.new(0.1,0,0.1,0)
	checkImg.BackgroundTransparency = 1
	checkImg.Image = CHECK_ICON
	checkImg.Visible = enabled
	local label = Instance.new("TextLabel", h)
	label.Size = UDim2.new(1,-40,1,0)
	label.Position = UDim2.new(0,35,0,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200,200,210)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	box.MouseButton1Click:Connect(function()
		playClick()
		enabled = not enabled
		tbl[key] = enabled
		box.BackgroundColor3 = enabled and PURPLE or GRAY
		checkImg.Visible = enabled
	end)
end

local function mkSlider(parent, text, minV, maxV, def, suffix, tbl, key, order)
	local h = Instance.new("Frame", parent)
	h.Size = UDim2.new(1,0,0,50)
	h.BackgroundTransparency = 1
	h.LayoutOrder = order
	local value = def
	local label = Instance.new("TextLabel", h)
	label.Size = UDim2.new(0.6,0,0,20)
	label.Position = UDim2.new(0,5,0,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200,200,210)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	local valueLabel = Instance.new("TextLabel", h)
	valueLabel.Size = UDim2.new(0.4,0,0,20)
	valueLabel.Position = UDim2.new(0.6,0,0,0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(value) .. (suffix or "")
	valueLabel.TextColor3 = Color3.fromRGB(150,150,160)
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextSize = 13
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	local bg = Instance.new("Frame", h)
	bg.Size = UDim2.new(1,-10,0,6)
	bg.Position = UDim2.new(0,5,0,30)
	bg.BackgroundColor3 = Color3.fromRGB(50,50,60)
	Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
	local fill = Instance.new("Frame", bg)
	fill.Size = UDim2.new((value-minV)/(maxV-minV),0,1,0)
	fill.BackgroundColor3 = PURPLE
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
	local knob = Instance.new("Frame", bg)
	knob.Size = UDim2.new(0,16,0,16)
	knob.Position = UDim2.new((value-minV)/(maxV-minV),-8,0.5,-8)
	knob.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
	local hitbox = Instance.new("TextButton", bg)
	hitbox.Size = UDim2.new(1,20,0,30)
	hitbox.Position = UDim2.new(0,-10,0.5,-15)
	hitbox.BackgroundTransparency = 1
	hitbox.Text = ""
	local dragging = false
	hitbox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startDragSound()
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if dragging then stopDragSound() end
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local pos = input.Position.X
			local barPos = bg.AbsolutePosition.X
			local barSize = bg.AbsoluteSize.X
			local percent = math.clamp((pos - barPos) / barSize, 0, 1)
			value = math.floor(minV + (maxV - minV) * percent)
			fill.Size = UDim2.new(percent,0,1,0)
			knob.Position = UDim2.new(percent,-8,0.5,-8)
			valueLabel.Text = tostring(value) .. (suffix or "")
			tbl[key] = value
		end
	end)
end

-- Tworzenie zakładek (skrócone)
local tabs = {"Visualization", "AimAssistance", "Miscellaneous", "Players"}
for i, name in ipairs(tabs) do
	local btn = Instance.new("TextButton", sidebar)
	btn.Size = UDim2.new(1,-20,0,36)
	btn.Position = UDim2.new(0,10,0,100 + (i-1)*46)
	btn.BackgroundColor3 = Color3.fromRGB(25,25,35)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(180,180,190)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.MouseButton1Click:Connect(function()
		playClick()
		for _, page in pairs({vizPage, aimPage, miscPage, playersPage}) do
			page.Visible = false
		end
		if name == "Visualization" then vizPage.Visible = true; contentTitle.Text = "Visualization"
		elseif name == "AimAssistance" then aimPage.Visible = true; contentTitle.Text = "Aim Assistance"
		elseif name == "Miscellaneous" then miscPage.Visible = true; contentTitle.Text = "Miscellaneous"
		elseif name == "Players" then playersPage.Visible = true; contentTitle.Text = "Players" end
	end)
end
vizPage.Visible = true

-- Miscellaneous Page (z nowymi opcjami)
mkSection(miscPage, "Movement", 1)
mkCheck(miscPage, "WalkSpeed", MISC, "WalkSpeedEnabled", 2)
mkSlider(miscPage, "WalkSpeed Value", 0, 50, 16, "", MISC, "WalkSpeedValue", 3)
mkCheck(miscPage, "JumpPower", MISC, "JumpPowerEnabled", 4)
mkSlider(miscPage, "JumpPower", 1, 100, 50, "", MISC, "JumpPowerValue", 5)
mkCheck(miscPage, "NoClip + Fly", MISC, "NoClip", 6)
mkSlider(miscPage, "NoClip Speed", 1, 100, 30, " m/s", MISC, "NoClipSpeed", 7)

mkSection(miscPage, "Combat", 8)
mkCheck(miscPage, "Semi God", MISC, "SemiGod", 9)
mkCheck(miscPage, "No Recoil", MISC, "NoRecoil", 10)
mkCheck(miscPage, "No Spread", MISC, "NoSpread", 11)
mkCheck(miscPage, "Infinite Ammo", MISC, "InfAmmo", 12)
mkCheck(miscPage, "Rapid Fire", MISC, "RapidFire", 13)
mkSlider(miscPage, "Rapid Fire Level (0 = max)", 0, 20, 20, "", MISC, "RapidFireLevel", 14)

mkSection(miscPage, "Super Punch", 15)
mkCheck(miscPage, "Enable Super Punch", MISC, "SuperPunch", 16)
mkSlider(miscPage, "Punch Multiplier", 1, 200, 100, "x", MISC, "PunchMultiplier", 17)

print("BearHub v2 - Załadowano pomyślnie | Rapid Fire naprawiony | WalkSpeed & JumpPower dodane")
