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

local FOV_SCALE_TRIGGER = 1
local FOV_SCALE_AIMBOT = 3

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
	SemiGod = false, NoRecoil = false, NoSpread = false, InfAmmo = false,
	NoClip = false, NoClipSpeed = 30,
	SuperPunch = false, PunchMultiplier = 100,
	RapidFire = false, RapidFireLevel = 20,
	WalkSpeedEnabled = false, WalkSpeed = 16,
	JumpPowerEnabled = false, JumpPower = 50,
}
local SPECTATE = {Target = nil, Active = false}

local mbHeld = {[1]=false,[2]=false,[3]=false,[4]=false,[5]=false}

local espGui = Instance.new("ScreenGui")
espGui.Name = "BearHub_ESP"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 100
espGui.Parent = playerGui

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "BearHub_FOV"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 99
fovGui.Parent = playerGui

local gui = Instance.new("ScreenGui")
gui.Name = "BearHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.Parent = playerGui

--============================================================
-- BLOK 1: FUNKCJE POMOCNICZE
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
		return s
	end

	_G.BearHub_playClick = function() playSound(CLICK_SOUND_ID, 0.25, 1.2) end
	_G.BearHub_playSlider = function() playSound(SLIDER_SOUND_ID, 0.15, 1.5) end

	_G.BearHub_doClick = function()
		local ok = false
		pcall(function()
			VIM:SendMouseButtonEvent(
				Camera.ViewportSize.X / 2,
				Camera.ViewportSize.Y / 2,
				0, true, game, 0
			)
			task.wait()
			VIM:SendMouseButtonEvent(
				Camera.ViewportSize.X / 2,
				Camera.ViewportSize.Y / 2,
				0, false, game, 0
			)
			ok = true
		end)
		if not ok then
			pcall(function()
				if mouse1click then mouse1click(); ok = true end
			end)
		end
		if not ok then
			pcall(function()
				if mouse1press and mouse1release then
					mouse1press()
					task.wait(0.02)
					mouse1release()
					ok = true
				end
			end)
		end
		return ok
	end

	local dragSoundObj = nil
	local dragSoundPlaying = false

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
-- BLOK 2: SPECTATE + TELEPORT/BRING/SWITCH
--============================================================
do
	local function getRoot(char)
		if not char then return nil end
		return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	end

	local function zeroVelocity(char)
		if not char then return end
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				pcall(function()
					p.Velocity = Vector3.new(0,0,0)
					p.AssemblyLinearVelocity = Vector3.new(0,0,0)
					p.AssemblyAngularVelocity = Vector3.new(0,0,0)
					p.RotVelocity = Vector3.new(0,0,0)
				end)
			end
		end
	end

	local function startSpectate(target)
		if not target or not target.Character then return end
		local hum = target.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function()
				Camera.CameraSubject = hum
				SPECTATE.Target = target
				SPECTATE.Active = true
			end)
		end
	end

	local function stopSpectate()
		SPECTATE.Target = nil
		SPECTATE.Active = false
		local myChar = player.Character
		if myChar then
			local myHum = myChar:FindFirstChildOfClass("Humanoid")
			if myHum then
				pcall(function() Camera.CameraSubject = myHum end)
			end
		end
	end

	_G.BearHub_startSpectate = startSpectate
	_G.BearHub_stopSpectate = stopSpectate

	_G.BearHub_teleportTo = function(target)
		if not target or not target.Character then return false, "Player has no character" end
		local myChar = player.Character
		if not myChar then return false, "You have no character" end
		local myRoot = getRoot(myChar)
		if not myRoot then return false, "You have no root part" end
		local targetRoot = getRoot(target.Character)
		if not targetRoot then return false, "Target has no root part" end
		
		task.spawn(function()
			local targetCFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
			local startTime = tick()
			while tick() - startTime < 0.5 do
				if not myChar.Parent or not myRoot.Parent then break end
				if not target.Character then break end
				local currentTargetRoot = getRoot(target.Character)
				if currentTargetRoot then
					targetCFrame = currentTargetRoot.CFrame + Vector3.new(0, 3, 0)
				end
				pcall(function()
					myRoot.CFrame = targetCFrame
					zeroVelocity(myChar)
				end)
				RunService.Heartbeat:Wait()
			end
		end)
		return true, "Teleported to " .. (target.DisplayName or target.Name)
	end

	_G.BearHub_bringPlayer = function(target)
		if not target or not target.Character then return false, "Player has no character" end
		local myChar = player.Character
		if not myChar then return false, "You have no character" end
		local myRoot = getRoot(myChar)
		if not myRoot then return false, "You have no root part" end
		local targetRoot = getRoot(target.Character)
		if not targetRoot then return false, "Target has no root part" end
		
		task.spawn(function()
			for i = 1, 5 do
				if not target.Character then break end
				local currentRoot = getRoot(target.Character)
				if not currentRoot or not currentRoot.Parent then break end
				local myCurrentRoot = getRoot(myChar)
				if not myCurrentRoot then break end
				
				pcall(function()
					local destination = myCurrentRoot.CFrame * CFrame.new(0, 0, -3) + Vector3.new(0, 2, 0)
					currentRoot.CFrame = destination
					zeroVelocity(target.Character)
				end)
				task.wait(0.05)
			end
		end)
		return true, "Brought " .. (target.DisplayName or target.Name)
	end

	_G.BearHub_switchPlaces = function(target)
		if not target or not target.Character then return false, "Player has no character" end
		local myChar = player.Character
		if not myChar then return false, "You have no character" end
		local myRoot = getRoot(myChar)
		if not myRoot then return false, "You have no root part" end
		local targetRoot = getRoot(target.Character)
		if not targetRoot then return false, "Target has no root part" end
		
		task.spawn(function()
			local myOriginalCFrame = myRoot.CFrame
			local targetOriginalCFrame = targetRoot.CFrame
			
			local startTime = tick()
			while tick() - startTime < 0.5 do
				if not myChar.Parent or not myRoot.Parent then break end
				if not target.Character then break end
				local currentTargetRoot = getRoot(target.Character)
				if not currentTargetRoot then break end
				
				pcall(function()
					myRoot.CFrame = targetOriginalCFrame + Vector3.new(0, 2, 0)
					zeroVelocity(myChar)
					currentTargetRoot.CFrame = myOriginalCFrame + Vector3.new(0, 2, 0)
					zeroVelocity(target.Character)
				end)
				RunService.Heartbeat:Wait()
			end
		end)
		return true, "Switched with " .. (target.DisplayName or target.Name)
	end

	task.spawn(function()
		while true do
			task.wait(0.5)
			if SPECTATE.Active and SPECTATE.Target then
				if not SPECTATE.Target.Parent or not SPECTATE.Target.Character then
					stopSpectate()
				else
					local hum = SPECTATE.Target.Character:FindFirstChildOfClass("Humanoid")
					if hum and Camera.CameraSubject ~= hum then
						pcall(function() Camera.CameraSubject = hum end)
					end
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(p)
		if SPECTATE.Target == p then stopSpectate() end
	end)
end

local startSpectate = _G.BearHub_startSpectate
local stopSpectate = _G.BearHub_stopSpectate
local teleportTo = _G.BearHub_teleportTo
local bringPlayer = _G.BearHub_bringPlayer
local switchPlaces = _G.BearHub_switchPlaces

--============================================================
-- MOUSE INPUT - Fixed to not interfere with GUI
--============================================================
UIS.InputBegan:Connect(function(inp, gameProcessed)
	if gameProcessed then return end
	local uit = inp.UserInputType
	if uit == Enum.UserInputType.MouseButton1 then mbHeld[1] = true
	elseif uit == Enum.UserInputType.MouseButton2 then mbHeld[2] = true
	elseif uit == Enum.UserInputType.MouseButton3 then mbHeld[3] = true
	elseif uit == Enum.UserInputType.MouseButton4 then mbHeld[4] = true
	elseif uit == Enum.UserInputType.MouseButton5 then mbHeld[5] = true end
end)

UIS.InputEnded:Connect(function(inp)
	local uit = inp.UserInputType
	if uit == Enum.UserInputType.MouseButton1 then mbHeld[1] = false
	elseif uit == Enum.UserInputType.MouseButton2 then mbHeld[2] = false
	elseif uit == Enum.UserInputType.MouseButton3 then mbHeld[3] = false
	elseif uit == Enum.UserInputType.MouseButton4 then mbHeld[4] = false
	elseif uit == Enum.UserInputType.MouseButton5 then mbHeld[5] = false end
end)

--============================================================
-- BLOK 3: ESP + FOV CIRCLES
--============================================================
do
	local fovCircle = Instance.new("Frame")
	fovCircle.BackgroundTransparency = 1
	fovCircle.BorderSizePixel = 0
	fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	fovCircle.Visible = false
	fovCircle.Parent = fovGui
	local fovStroke = Instance.new("UIStroke", fovCircle)
	fovStroke.Color = PURPLE
	fovStroke.Thickness = 1.5
	fovStroke.Transparency = 0.3
	Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

	local fovCircleAim = Instance.new("Frame")
	fovCircleAim.BackgroundTransparency = 1
	fovCircleAim.BorderSizePixel = 0
	fovCircleAim.AnchorPoint = Vector2.new(0.5, 0.5)
	fovCircleAim.Visible = false
	fovCircleAim.Parent = fovGui
	local fovStrokeAim = Instance.new("UIStroke", fovCircleAim)
	fovStrokeAim.Color = PURPLE
	fovStrokeAim.Thickness = 1.5
	fovStrokeAim.Transparency = 0.3
	Instance.new("UICorner", fovCircleAim).CornerRadius = UDim.new(1, 0)

	local function updateFOVCircle()
		if TRIGGERBOT.ShowFOV and TRIGGERBOT.Enabled then
			local r = TRIGGERBOT.FOV * FOV_SCALE_TRIGGER
			fovCircle.Size = UDim2.new(0, r*2, 0, r*2)
			fovCircle.Position = UDim2.new(0, Camera.ViewportSize.X/2, 0, Camera.ViewportSize.Y/2)
			fovStroke.Color = TRIGGERBOT.FOVColor
			fovCircle.Visible = true
		else fovCircle.Visible = false end
		if AIMBOT.DrawFOV and AIMBOT.Enabled then
			local r = AIMBOT.FOV * FOV_SCALE_AIMBOT
			fovCircleAim.Size = UDim2.new(0, r*2, 0, r*2)
			fovCircleAim.Position = UDim2.new(0, Camera.ViewportSize.X/2, 0, Camera.ViewportSize.Y/2)
			fovStrokeAim.Color = AIMBOT.FOVColor
			fovCircleAim.Visible = true
		else fovCircleAim.Visible = false end
	end

	local espObjects = {}

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
		t.AnchorPoint = Vector2.new(0.5, 0.5)
		t.Size = UDim2.new(0, 200, 0, 20)
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

	local function getPlayerInventory(plr)
		local items = {}
		if plr.Character then
			for _, child in ipairs(plr.Character:GetChildren()) do
				if child:IsA("Tool") then
					table.insert(items, child.Name)
				end
			end
		end
		local bp = plr:FindFirstChildOfClass("Backpack")
		if bp then
			for _, child in ipairs(bp:GetChildren()) do
				if child:IsA("Tool") then
					table.insert(items, child.Name)
				end
			end
		end
		return items
	end

	local function createESPData(plr)
		local h = Instance.new("Folder", espGui)
		h.Name = plr.Name
		local d = {
			holder = h,
			boxTop = makeLine(h), boxBot = makeLine(h),
			boxLeft = makeLine(h), boxRight = makeLine(h),
			skeleton = {}, snapline = makeLine(h),
			healthBg = makeLine(h), healthFill = makeLine(h),
			name = makeText(h, 14), id = makeText(h, 12), distance = makeText(h, 12),
			inventory = makeText(h, 11),
		}
		for i = 1, 12 do d.skeleton[i] = makeLine(h) end
		espObjects[plr] = d
		return d
	end

	local function hideAll(d)
		if not d then return end
		for k, v in pairs(d) do
			if k ~= "holder" then
				if type(v) == "table" then
					for _, x in pairs(v) do pcall(function() x.Visible = false end) end
				else pcall(function() v.Visible = false end) end
			end
		end
	end

	local function clearESP(plr)
		if espObjects[plr] then
			pcall(function() espObjects[plr].holder:Destroy() end)
			espObjects[plr] = nil
		end
	end

	local function fullRefresh()
		for plr in pairs(espObjects) do clearESP(plr) end
	end

	_G.BearHub_fullRefresh = fullRefresh

	local function w2s(pos)
		local ok, v = pcall(function() return Camera:WorldToViewportPoint(pos) end)
		if ok and v then return Vector2.new(v.X, v.Y), v.Z > 0, v.Z end
		return Vector2.new(0,0), false, -1
	end

	local function getPos(char, name)
		local p = char:FindFirstChild(name)
		if p and p:IsA("BasePart") then return p.Position end
		return nil
	end

	local function visCheck(tp, tc)
		local mc = player.Character
		if not mc then return false end
		local mh = mc:FindFirstChild("Head") or mc:FindFirstChild("HumanoidRootPart")
		if not mh then return false end
		local par = RaycastParams.new()
		par.FilterDescendantsInstances = {mc, tc}
		par.FilterType = Enum.RaycastFilterType.Exclude
		local ok, r = pcall(function() return workspace:Raycast(mh.Position, tp - mh.Position, par) end)
		return ok and r == nil
	end

	_G.BearHub_getPos = getPos
	_G.BearHub_visCheck = visCheck

	local R15 = {
		{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
		{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
		{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
		{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
		{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
	}
	local R6 = {
		{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
		{"Torso","Left Leg"},{"Torso","Right Leg"},
	}

	local inventoryCache = {}
	local inventoryCacheTick = {}
	local INVENTORY_CACHE_TIME = 1.0

	local function getCachedInventory(plr)
		local now = tick()
		if inventoryCache[plr] and inventoryCacheTick[plr] and (now - inventoryCacheTick[plr]) < INVENTORY_CACHE_TIME then
			return inventoryCache[plr]
		end
		local items = getPlayerInventory(plr)
		inventoryCache[plr] = items
		inventoryCacheTick[plr] = now
		return items
	end

	local function updateESP()
		Camera = workspace.CurrentCamera
		if not Camera then return end
		local cur = {}
		for _, p in ipairs(Players:GetPlayers()) do cur[p] = true end
		for plr in pairs(espObjects) do
			if not cur[plr] then clearESP(plr) end
		end
		for plr in pairs(inventoryCache) do
			if not cur[plr] then
				inventoryCache[plr] = nil
				inventoryCacheTick[plr] = nil
			end
		end
		if not ESP.Enabled then
			for _, d in pairs(espObjects) do hideAll(d) end
			return
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			local d = espObjects[plr]
			local skip = false
			if plr == player and not ESP.ShowLocalPlayer then
				if d then hideAll(d) end
				skip = true
			end
			if not skip then
				local char = plr.Character
				if not char or not char.Parent then
					if d then hideAll(d) end
					skip = true
				end
				if not skip then
					local hum = char:FindFirstChildOfClass("Humanoid")
					local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
					local head = char:FindFirstChild("Head")
					if not hum or not root or not head or hum.Health <= 0 then
						if d then hideAll(d) end
						skip = true
					end
					if not skip then
						local myChar = player.Character
						local mr = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
						local dist = mr and (mr.Position - root.Position).Magnitude or (Camera.CFrame.Position - root.Position).Magnitude
						if dist > ESP.MaxDistance then
							if d then hideAll(d) end
							skip = true
						end
						if not skip then
							local sp, on, dep = w2s(root.Position)
							if not on or dep <= 0 then
								if d then hideAll(d) end
								skip = true
							end
							if not skip then
								if ESP.VisibleOnly and plr ~= player then
									if not visCheck(root.Position, char) then
										if d then hideAll(d) end
										skip = true
									end
								end
								if not skip then
									if not d then d = createESPData(plr) end
									local hp = w2s(head.Position + Vector3.new(0,0.5,0))
									local lp = w2s(root.Position - Vector3.new(0,3,0))
									local bH = math.clamp(math.abs(lp.Y - hp.Y), 20, 800)
									local bW = bH * 0.55
									local tY, bY = hp.Y, lp.Y
									local lX, rX = sp.X - bW/2, sp.X + bW/2
									if ESP.Box.Enabled then
										drawLine(d.boxTop, Vector2.new(lX,tY), Vector2.new(rX,tY), 1)
										drawLine(d.boxBot, Vector2.new(lX,bY), Vector2.new(rX,bY), 1)
										drawLine(d.boxLeft, Vector2.new(lX,tY), Vector2.new(lX,bY), 1)
										drawLine(d.boxRight, Vector2.new(rX,tY), Vector2.new(rX,bY), 1)
										for _, f in pairs({d.boxTop,d.boxBot,d.boxLeft,d.boxRight}) do
											f.BackgroundColor3 = ESP.Box.Color
											f.Visible = true
										end
									else
										for _, f in pairs({d.boxTop,d.boxBot,d.boxLeft,d.boxRight}) do f.Visible = false end
									end

									local bottomOffset = 0

									if ESP.Name.Enabled then
										d.name.Text = plr.DisplayName or plr.Name
										d.name.Position = UDim2.new(0, sp.X, 0, tY - 15)
										d.name.TextColor3 = ESP.Name.Color
										d.name.Visible = true
									else d.name.Visible = false end
									if ESP.ID.Enabled then
										d.id.Text = "ID: " .. plr.UserId
										d.id.Position = UDim2.new(0, sp.X, 0, tY - (ESP.Name.Enabled and 30 or 15))
										d.id.TextColor3 = ESP.ID.Color
										d.id.Visible = true
									else d.id.Visible = false end

									if ESP.Distance.Enabled then
										d.distance.Text = math.floor(dist) .. "m"
										d.distance.Position = UDim2.new(0, sp.X, 0, bY + 12 + bottomOffset)
										d.distance.TextColor3 = ESP.Distance.Color
										d.distance.Visible = true
										bottomOffset = bottomOffset + 16
									else d.distance.Visible = false end

									if ESP.Inventory.Enabled then
										local items = getCachedInventory(plr)
										if #items > 0 then
											local invText = table.concat(items, ", ")
											if #invText > 40 then
												invText = string.sub(invText, 1, 37) .. "..."
											end
											d.inventory.Text = "[" .. invText .. "]"
											d.inventory.Position = UDim2.new(0, sp.X, 0, bY + 12 + bottomOffset)
											d.inventory.TextColor3 = ESP.Inventory.Color
											d.inventory.Size = UDim2.new(0, 300, 0, 20)
											d.inventory.Visible = true
											bottomOffset = bottomOffset + 16
										else
											d.inventory.Text = "[Empty]"
											d.inventory.Position = UDim2.new(0, sp.X, 0, bY + 12 + bottomOffset)
											d.inventory.TextColor3 = Color3.fromRGB(120, 120, 130)
											d.inventory.Size = UDim2.new(0, 300, 0, 20)
											d.inventory.Visible = true
											bottomOffset = bottomOffset + 16
										end
									else d.inventory.Visible = false end

									if ESP.HealthBar.Enabled then
										local bx = lX - 6
										local hp2 = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
										local ft = bY - (bY - tY) * hp2
										drawLine(d.healthBg, Vector2.new(bx,tY), Vector2.new(bx,bY), 4)
										d.healthBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
										d.healthBg.Visible = true
										drawLine(d.healthFill, Vector2.new(bx,ft), Vector2.new(bx,bY), 3)
										d.healthFill.BackgroundColor3 = Color3.fromRGB(math.floor(255*(1-hp2)), math.floor(255*hp2), 0)
										d.healthFill.Visible = true
									else
										d.healthBg.Visible = false
										d.healthFill.Visible = false
									end
									if ESP.Snaplines.Enabled then
										drawLine(d.snapline, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y), Vector2.new(sp.X, bY), 1)
										d.snapline.BackgroundColor3 = ESP.Snaplines.Color
										d.snapline.Visible = true
									else d.snapline.Visible = false end
									if ESP.Skeleton.Enabled then
										local bones = char:FindFirstChild("UpperTorso") and R15 or R6
										for i = 1, 12 do
											if d.skeleton[i] then
												if i <= #bones then
													local a = getPos(char, bones[i][1])
													local b = getPos(char, bones[i][2])
													if a and b then
														local s1, o1, d1 = w2s(a)
														local s2, o2, d2 = w2s(b)
														if o1 and o2 and d1 > 0 and d2 > 0 then
															drawLine(d.skeleton[i], s1, s2, 2)
															d.skeleton[i].BackgroundColor3 = ESP.Skeleton.Color
															d.skeleton[i].Visible = true
														else d.skeleton[i].Visible = false end
													else d.skeleton[i].Visible = false end
												else d.skeleton[i].Visible = false end
											end
										end
									else
										for i = 1, 12 do
											if d.skeleton[i] then d.skeleton[i].Visible = false end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	RunService.RenderStepped:Connect(function()
		pcall(updateESP)
		pcall(updateFOVCircle)
	end)

	task.spawn(function() while true do task.wait(5); pcall(fullRefresh) end end)

	player.CharacterAdded:Connect(function() task.wait(0.5); pcall(fullRefresh) end)

	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		Camera = workspace.CurrentCamera; pcall(fullRefresh)
	end)

	Players.PlayerAdded:Connect(function(p)
		p.CharacterAdded:Connect(function() task.wait(0.3); clearESP(p) end)
		p.CharacterRemoving:Connect(function() clearESP(p) end)
	end)

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			p.CharacterAdded:Connect(function() task.wait(0.3); clearESP(p) end)
			p.CharacterRemoving:Connect(function() clearESP(p) end)
		end
	end

	Players.PlayerRemoving:Connect(function(p) clearESP(p) end)
end

local fullRefresh = _G.BearHub_fullRefresh
local getPos = _G.BearHub_getPos
local visCheck = _G.BearHub_visCheck

--============================================================
-- BLOK 4: TRIGGERBOT + AIMBOT + HITBOX
--============================================================
do
	local lastShot = 0

	local function getTriggerTarget()
		if not TRIGGERBOT.Enabled then return nil end
		local vc = Camera.ViewportSize / 2
		local fr = TRIGGERBOT.FOV * FOV_SCALE_TRIGGER
		local best, bestD = nil, math.huge
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local char = plr.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					local head = char:FindFirstChild("Head")
					local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
					if hum and head and root then
						local doCheck = true
						if TRIGGERBOT.ExcludeDead and hum.Health <= 0 then doCheck = false end
						if doCheck then
							local myChar = player.Character
							local mr = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
							local dist = mr and (mr.Position - root.Position).Magnitude or 9999
							if dist > TRIGGERBOT.MaxDistance then doCheck = false end
						end
						if doCheck and TRIGGERBOT.VisibleOnly then
							if not visCheck(root.Position, char) then doCheck = false end
						end
						if doCheck then
							local ok, sp, on, d2 = pcall(function()
								local vec = Camera:WorldToViewportPoint(head.Position)
								return Vector2.new(vec.X, vec.Y), vec.Z > 0, vec.Z
							end)
							if ok and on and d2 and d2 > 0 then
								local sd = (sp - vc).Magnitude
								if sd <= fr and sd < bestD then best = plr; bestD = sd end
							end
						end
					end
				end
			end
		end
		return best
	end

	task.spawn(function()
		while true do
			task.wait(0.05)
			if TRIGGERBOT.Enabled and TRIGGERBOT.KeybindCheck and TRIGGERBOT.KeybindCheck() then
				local now = tick()
				if now - lastShot >= (TRIGGERBOT.ShotDelay / 1000 + 0.05) then
					local t = getTriggerTarget()
					if t then
						lastShot = now
						pcall(doClick)
					end
				end
			end
		end
	end)

	local function getBonePosition(char, boneChoice)
		if boneChoice == "Head" then return getPos(char, "Head")
		elseif boneChoice == "Torso" then return getPos(char, "UpperTorso") or getPos(char, "Torso") or getPos(char, "HumanoidRootPart")
		elseif boneChoice == "Legs" then return getPos(char, "LeftUpperLeg") or getPos(char, "Left Leg") or getPos(char, "LowerTorso") end
		return getPos(char, "Head")
	end

	local function getAimbotTarget()
		if not AIMBOT.Enabled then return nil end
		local vc = Camera.ViewportSize / 2
		local fr = AIMBOT.FOV * FOV_SCALE_AIMBOT
		local best, bestD, bestPos = nil, math.huge, nil
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local char = plr.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
					if hum and root then
						local doCheck = true
						if AIMBOT.ExcludeDead and hum.Health <= 0 then doCheck = false end
						if doCheck then
							local myChar = player.Character
							local mr = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
							local dist = mr and (mr.Position - root.Position).Magnitude or 9999
							if dist > AIMBOT.MaxDistance then doCheck = false end
						end
						if doCheck then
							local bonePos = getBonePosition(char, AIMBOT.Bone)
							if bonePos then
								if AIMBOT.VisibleCheck then
									if not visCheck(bonePos, char) then doCheck = false end
								end
								if doCheck then
									local ok, sp, on, d2 = pcall(function()
										local vec = Camera:WorldToViewportPoint(bonePos)
										return Vector2.new(vec.X, vec.Y), vec.Z > 0, vec.Z
									end)
									if ok and on and d2 and d2 > 0 then
										local sd = (sp - vc).Magnitude
										if sd <= fr and sd < bestD then best = plr; bestD = sd; bestPos = bonePos end
									end
								end
							end
						end
					end
				end
			end
		end
		return best, bestPos
	end

	RunService.RenderStepped:Connect(function()
		if AIMBOT.Enabled and AIMBOT.KeybindCheck and AIMBOT.KeybindCheck() then
			local target, targetPos = getAimbotTarget()
			if target and targetPos then
				pcall(function()
					local camPos = Camera.CFrame.Position
					local currentLook = Camera.CFrame.LookVector
					local desiredLook = (targetPos - camPos).Unit
					local alphaX = math.clamp(AIMBOT.SmoothX, 1, 100) / 100
					local alphaY = math.clamp(AIMBOT.SmoothY, 1, 100) / 100
					local newLook = Vector3.new(
						currentLook.X + (desiredLook.X - currentLook.X) * alphaX,
						currentLook.Y + (desiredLook.Y - currentLook.Y) * alphaY,
						currentLook.Z + (desiredLook.Z - currentLook.Z) * alphaX
					).Unit
					Camera.CFrame = CFrame.new(camPos, camPos + newLook)
				end)
			end
		end
	end)

	local savedMeshScales = {}
	local savedMeshOffsets = {}
	local hitboxHighlights = {}

	local HITBOX_BONE_MAP = {
		Head = {R15 = {"Head"}, R6 = {"Head"}},
		Torso = {R15 = {"UpperTorso", "LowerTorso"}, R6 = {"Torso"}},
		Legs = {R15 = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}, R6 = {"Left Leg", "Right Leg"}},
	}

	local function getHitboxParts(char)
		local isR15 = char:FindFirstChild("UpperTorso") ~= nil
		local rig = isR15 and "R15" or "R6"
		local names = HITBOX_BONE_MAP[HITBOX.Bone] and HITBOX_BONE_MAP[HITBOX.Bone][rig] or {"Head"}
		local parts = {}
		for _, name in ipairs(names) do
			local part = char:FindFirstChild(name)
			if part and part:IsA("BasePart") then table.insert(parts, part) end
		end
		return parts
	end

	local function findMesh(part)
		return part:FindFirstChildOfClass("SpecialMesh") or part:FindFirstChildOfClass("BlockMesh") or part:FindFirstChildOfClass("CylinderMesh") or part:FindFirstChildOfClass("FileMesh")
	end

	local function saveMeshData(part)
		local mesh = findMesh(part)
		if mesh and not savedMeshScales[mesh] then
			savedMeshScales[mesh] = mesh.Scale
			if mesh:IsA("SpecialMesh") then
				savedMeshOffsets[mesh] = mesh.Offset
			end
		end
	end

	local function restoreMesh(part)
		local mesh = findMesh(part)
		if mesh and savedMeshScales[mesh] then
			pcall(function()
				mesh.Scale = savedMeshScales[mesh]
				if mesh:IsA("SpecialMesh") and savedMeshOffsets[mesh] then
					mesh.Offset = savedMeshOffsets[mesh]
				end
			end)
			savedMeshScales[mesh] = nil
			savedMeshOffsets[mesh] = nil
		end
	end

	local function createHighlight(part)
		if hitboxHighlights[part] and hitboxHighlights[part].Parent then
			return hitboxHighlights[part]
		end
		local char = part.Parent
		if not char then return nil end
		local hlName = "BearHub_HL_" .. part.Name
		local existing = char:FindFirstChild(hlName)
		if existing then existing:Destroy() end
		local sphere = Instance.new("SelectionSphere")
		sphere.Name = hlName
		sphere.Adornee = part
		sphere.Color3 = Color3.fromRGB(255, 60, 60)
		sphere.SurfaceColor3 = Color3.fromRGB(255, 60, 60)
		sphere.SurfaceTransparency = 0.7
		sphere.Transparency = 0.5
		sphere.Parent = char
		hitboxHighlights[part] = sphere
		return sphere
	end

	local function removeHighlight(part)
		if hitboxHighlights[part] then
			pcall(function() hitboxHighlights[part]:Destroy() end)
			hitboxHighlights[part] = nil
		end
	end

	local function expandPart(part)
		if not part or not part.Parent then return end
		local scale = 1 + (HITBOX.Size * 0.15)
		local mesh = findMesh(part)
		if mesh then
			saveMeshData(part)
			pcall(function() mesh.Scale = savedMeshScales[mesh] * scale end)
		end
		local hl = createHighlight(part)
		if hl then
			hl.Adornee = part
			hl.Transparency = 0.5
			hl.SurfaceTransparency = 0.7
		end
	end

	local function restorePart(part)
		if not part or not part.Parent then return end
		restoreMesh(part)
		removeHighlight(part)
	end

	local function restoreAllForChar(char)
		if not char then return end
		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") then restorePart(part) end
		end
		for _, child in ipairs(char:GetChildren()) do
			if child.Name:find("BearHub_HL_") then
				pcall(function() child:Destroy() end)
			end
		end
	end

	local function cleanupDead()
		local toRemoveMesh = {}
		for mesh in pairs(savedMeshScales) do
			if not mesh or not mesh.Parent then table.insert(toRemoveMesh, mesh) end
		end
		for _, mesh in ipairs(toRemoveMesh) do
			savedMeshScales[mesh] = nil
			savedMeshOffsets[mesh] = nil
		end
		local toRemoveHL = {}
		for part in pairs(hitboxHighlights) do
			if not part or not part.Parent then table.insert(toRemoveHL, part) end
		end
		for _, part in ipairs(toRemoveHL) do
			hitboxHighlights[part] = nil
		end
	end

	local lastHitboxBone = "Head"
	local lastHitboxEnabled = false

	RunService.Heartbeat:Connect(function()
		local boneChanged = (lastHitboxBone ~= HITBOX.Bone)
		local enabledChanged = (lastHitboxEnabled ~= HITBOX.Enabled)
		lastHitboxBone = HITBOX.Bone
		lastHitboxEnabled = HITBOX.Enabled

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local char = plr.Character
				if char then
					if HITBOX.Enabled and HITBOX.Size > 0 then
						if boneChanged then restoreAllForChar(char) end
						local targetParts = getHitboxParts(char)
						local targetSet = {}
						for _, p in ipairs(targetParts) do targetSet[p] = true end
						for _, part in ipairs(char:GetChildren()) do
							if part:IsA("BasePart") and hitboxHighlights[part] and not targetSet[part] then
								restorePart(part)
							end
						end
						for _, part in ipairs(targetParts) do
							pcall(function() expandPart(part) end)
						end
					else
						if enabledChanged then restoreAllForChar(char) end
					end
				end
			end
		end
		cleanupDead()
	end)

	Players.PlayerAdded:Connect(function(p)
		p.CharacterAdded:Connect(function(char) task.wait(1); cleanupDead() end)
		p.CharacterRemoving:Connect(function()
			local char = p.Character
			if char then restoreAllForChar(char) end
		end)
	end)

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			p.CharacterAdded:Connect(function(char) task.wait(1); cleanupDead() end)
			p.CharacterRemoving:Connect(function()
				local char = p.Character
				if char then restoreAllForChar(char) end
			end)
		end
	end
end

--============================================================
-- BLOK 5: MISC + TOOLS + NOCLIP + SUPER PUNCH + RAPID FIRE + WALKSPEED + JUMPPOWER
--============================================================
do
	-- SEMI GOD MOD
	task.spawn(function()
		while true do
			task.wait(0.1)
			if MISC.SemiGod then
				local char = player.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						pcall(function()
							hum.MaxHealth = math.huge
							hum.Health = math.huge
						end)
					end
				end
			end
		end
	end)

	local function hookHumanoid(char)
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		hum.HealthChanged:Connect(function(hp)
			if MISC.SemiGod then
				pcall(function()
					hum.MaxHealth = math.huge
					hum.Health = math.huge
				end)
			end
		end)
	end

	if player.Character then hookHumanoid(player.Character) end
	player.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		hookHumanoid(c)
	end)

	-- HEAL
	_G.BearHub_healPlayer = function()
		local char = player.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function()
				hum.Health = hum.MaxHealth
			end)
		end
	end

	-- WALK SPEED + JUMP POWER
	task.spawn(function()
		while true do
			task.wait(0.1)
			local char = player.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					if MISC.WalkSpeedEnabled then
						pcall(function()
							hum.WalkSpeed = MISC.WalkSpeed
						end)
					end
					if MISC.JumpPowerEnabled then
						pcall(function()
							hum.UseJumpPower = true
							hum.JumpPower = MISC.JumpPower
						end)
					end
				end
			end
		end
	end)

	-- NOCLIP + FLY
	local flyBodyVelocity = nil
	local flyBodyGyro = nil
	local flying = false

	local function stopFly()
		flying = false
		if flyBodyVelocity then
			pcall(function() flyBodyVelocity:Destroy() end)
			flyBodyVelocity = nil
		end
		if flyBodyGyro then
			pcall(function() flyBodyGyro:Destroy() end)
			flyBodyGyro = nil
		end
	end

	local function startFly()
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then return end

		stopFly()
		flying = true

		flyBodyVelocity = Instance.new("BodyVelocity")
		flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
		flyBodyVelocity.Parent = root

		flyBodyGyro = Instance.new("BodyGyro")
		flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		flyBodyGyro.P = 9000
		flyBodyGyro.D = 500
		flyBodyGyro.Parent = root

		task.spawn(function()
			while flying and MISC.NoClip do
				RunService.RenderStepped:Wait()
				if not char.Parent then break end
				local currentRoot = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
				if not currentRoot then break end

				local speed = MISC.NoClipSpeed or 30

				local forward = 0
				local right = 0
				local up = 0

				if UIS:IsKeyDown(Enum.KeyCode.W) then forward = forward + 1 end
				if UIS:IsKeyDown(Enum.KeyCode.S) then forward = forward - 1 end
				if UIS:IsKeyDown(Enum.KeyCode.A) then right = right - 1 end
				if UIS:IsKeyDown(Enum.KeyCode.D) then right = right + 1 end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then up = up + 1 end
				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then up = up - 1 end

				local camCFrame = Camera.CFrame
				local camForward = camCFrame.LookVector
				local camRight = camCFrame.RightVector

				local moveVec = (camForward * forward + camRight * right + Vector3.new(0, up, 0))

				if moveVec.Magnitude > 0 then
					moveVec = moveVec.Unit * speed
				end

				pcall(function()
					if flyBodyVelocity and flyBodyVelocity.Parent then
						flyBodyVelocity.Velocity = moveVec
					end
					if flyBodyGyro and flyBodyGyro.Parent then
						flyBodyGyro.CFrame = camCFrame
					end
				end)
			end
			stopFly()
		end)
	end

	RunService.Stepped:Connect(function()
		if MISC.NoClip then
			local char = player.Character
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						pcall(function()
							part.CanCollide = false
						end)
					end
				end
				if not flying then
					startFly()
				end
			end
		else
			if flying then
				stopFly()
				local char = player.Character
				if char then
					for _, part in ipairs(char:GetDescendants()) do
						if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
							pcall(function()
								part.CanCollide = true
							end)
						end
					end
				end
			end
		end
	end)

	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		stopFly()
	end)

	-- TOOLS HOOK (includes Rapid Fire)
	local hookedTools = {}

	local function hookTool(tool)
		if not tool or not tool:IsA("Tool") then return end
		if hookedTools[tool] then return end
		hookedTools[tool] = true

		task.spawn(function()
			while tool.Parent do
				task.wait(0.05)

				if MISC.NoRecoil or MISC.NoSpread or MISC.InfAmmo or MISC.RapidFire then
					pcall(function()
						for _, v in ipairs(tool:GetDescendants()) do
							if v:IsA("NumberValue") or v:IsA("IntValue") then
								local n = v.Name:lower()

								if MISC.NoRecoil then
									if n:find("recoil") or n:find("kick") or n:find("camerashake") or n:find("shake") then
										v.Value = 0
									end
								end

								if MISC.NoSpread then
									if n:find("spread") or n:find("bulletspread") or n:find("firerandom") then
										v.Value = 0
									end
									if n:find("accuracy") then
										v.Value = 1
									end
								end

								if MISC.InfAmmo then
									if n == "ammo" or n == "currentammo" or n == "bullets" or n == "storedammo" 
										or n:find("magazine") or n:find("clip") or n:find("mag") 
										or n == "maxammo" or n == "reserveammo" or n == "totalammo" then
										v.Value = 999
									end
								end

								if MISC.RapidFire then
									local rfLevel = MISC.RapidFireLevel or 20
									local rfMultiplier = rfLevel / 20

									if n:find("firerate") or n:find("fire_rate") or n:find("rateof") then
										if rfMultiplier > 0 then
											if v.Value < 9000 then
												v.Value = v.Value / math.max(rfMultiplier, 0.01)
											end
										else
											v.Value = 99999
										end
									end

									if n:find("firedelay") or n:find("fire_delay") or n:find("delay") 
										or n:find("cooldown") or n:find("cool_down") or n:find("firecooldown")
										or n:find("shotcooldown") or n:find("shotdelay") or n:find("shot_delay")
										or n:find("fireinterval") or n:find("interval") or n:find("timebetween")
										or n:find("attackspeed") or n:find("attackcooldown") or n:find("attackdelay")
										or n:find("shootdelay") or n:find("shootcooldown") then
										v.Value = v.Value * rfMultiplier
									end

									if n:find("automatic") or n:find("auto") or n:find("isautomatic") then
										if v.Value == 0 then
											v.Value = 1
										end
									end
								end
							end

							if v:IsA("BoolValue") then
								local n = v.Name:lower()
								if MISC.InfAmmo then
									if n:find("reloading") or n:find("isreloading") then
										v.Value = false
									end
								end
								if MISC.RapidFire then
									if n:find("canfire") or n:find("canshoot") or n:find("ready") then
										v.Value = true
									end
									if n:find("cooling") or n:find("oncooldown") then
										v.Value = false
									end
								end
							end
						end

						local attrs = tool:GetAttributes()
						for name, val in pairs(attrs) do
							local n = name:lower()
							if type(val) == "number" then
								if MISC.NoRecoil and (n:find("recoil") or n:find("kick")) then
									tool:SetAttribute(name, 0)
								end
								if MISC.NoSpread and (n:find("spread") or n:find("accuracy")) then
									tool:SetAttribute(name, 0)
								end
								if MISC.InfAmmo and (n == "ammo" or n:find("magazine") or n:find("clip")) then
									tool:SetAttribute(name, 999)
								end
								if MISC.RapidFire then
									local rfLevel = MISC.RapidFireLevel or 20
									local rfMultiplier = rfLevel / 20
									if n:find("firedelay") or n:find("cooldown") or n:find("firerate") 
										or n:find("delay") or n:find("interval") or n:find("shotdelay") then
										if n:find("rate") then
											if rfMultiplier > 0 then
												tool:SetAttribute(name, val / math.max(rfMultiplier, 0.01))
											else
												tool:SetAttribute(name, 99999)
											end
										else
											tool:SetAttribute(name, val * rfMultiplier)
										end
									end
								end
							end
							if type(val) == "boolean" and MISC.RapidFire then
								if n:find("canfire") or n:find("canshoot") or n:find("ready") then
									tool:SetAttribute(name, true)
								end
							end
						end
					end)
				end
			end
			hookedTools[tool] = nil
		end)
	end

	local function scanTools(char)
		if not char then return end
		for _, t in ipairs(char:GetChildren()) do
			if t:IsA("Tool") then hookTool(t) end
		end
		char.ChildAdded:Connect(function(c)
			if c:IsA("Tool") then hookTool(c) end
		end)
	end

	local function scanBackpack()
		local bp = player:FindFirstChildOfClass("Backpack")
		if not bp then return end
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") then hookTool(t) end
		end
		bp.ChildAdded:Connect(function(c)
			if c:IsA("Tool") then hookTool(c) end
		end)
	end

	if player.Character then scanTools(player.Character) end
	player.CharacterAdded:Connect(function(c)
		task.wait(0.3)
		scanTools(c)
	end)
	task.spawn(function() task.wait(1); pcall(scanBackpack) end)

	task.spawn(function()
		while true do
			task.wait(3)
			if player.Character then pcall(function() scanTools(player.Character) end) end
			pcall(scanBackpack)
		end
	end)

	-- ============================================
	-- SUPER PUNCH
	-- ============================================
	local punchedTools = {}

	local function isPunchTool(tool)
		if not tool or not tool:IsA("Tool") then return false end
		local name = tool.Name:lower()
		return name:find("pi[eę]s?[cć]") or name:find("fist") or name:find("punch") or name:find("hand")
	end

	local function findAllDamageRemotes()
		local remotes = {}
		local function scan(parent, depth)
			if depth > 6 then return end
			pcall(function()
				for _, v in ipairs(parent:GetChildren()) do
					if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
						local n = v.Name:lower()
						if n:find("damage") or n:find("hit") or n:find("punch") or n:find("attack") 
							or n:find("melee") or n:find("fight") or n:find("combat") or n:find("strike")
							or n:find("swing") or n:find("weapon") or n:find("fist") or n:find("pi[eę]s?[cć]")
							or n:find("dmg") or n:find("kill") or n:find("hurt") then
							table.insert(remotes, v)
						end
					end
					if v:IsA("Folder") or v:IsA("Model") or v:IsA("Configuration") then
						scan(v, depth + 1)
					end
				end
			end)
		end
		scan(ReplicatedStorage, 0)
		scan(workspace, 0)
		return remotes
	end

	local function hookPunchTool(tool)
		if not isPunchTool(tool) then return end
		if punchedTools[tool] then return end
		punchedTools[tool] = true

		local activated = tool.Activated:Connect(function()
			if not MISC.SuperPunch then return end

			local multiplier = MISC.PunchMultiplier or 100

			local function getNearestTarget(maxDist)
				local myChar2 = player.Character
				if not myChar2 then return nil end
				local myRoot2 = myChar2:FindFirstChild("HumanoidRootPart") or myChar2:FindFirstChild("Torso")
				if not myRoot2 then return nil end

				local best, bestDist = nil, maxDist or 15
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= player and plr.Character then
						local hum = plr.Character:FindFirstChildOfClass("Humanoid")
						local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")
						if hum and hum.Health > 0 and targetRoot then
							local dist = (myRoot2.Position - targetRoot.Position).Magnitude
							if dist <= bestDist then
								local dir = (targetRoot.Position - myRoot2.Position).Unit
								local dot = dir:Dot(myRoot2.CFrame.LookVector)
								if dot > 0.2 then
									best = plr
									bestDist = dist
								end
							end
						end
					end
				end
				return best
			end

			local target = getNearestTarget(15)
			if not target then return end
			local targetChar = target.Character
			if not targetChar then return end
			local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
			if not targetHum or targetHum.Health <= 0 then return end

			task.spawn(function()
				for i = 1, multiplier do
					if not MISC.SuperPunch then break end
					if not target.Parent then break end
					local tHum = targetChar:FindFirstChildOfClass("Humanoid")
					if not tHum or tHum.Health <= 0 then break end

					pcall(function()
						tool:Activate()
					end)

					pcall(function()
						VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
						VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
					end)

					local remotes = findAllDamageRemotes()
					for _, remote in ipairs(remotes) do
						pcall(function()
							if remote:IsA("RemoteEvent") then
								remote:FireServer(target)
								remote:FireServer(target, targetHum)
								remote:FireServer(targetHum)
								remote:FireServer(targetChar)
								remote:FireServer(target.Character.HumanoidRootPart)
							end
						end)
					end

					task.wait(0.03)
				end
			end)
		end)

		tool.AncestryChanged:Connect(function()
			if not tool.Parent then
				punchedTools[tool] = nil
				if activated then activated:Disconnect() end
			end
		end)
	end

	local function scanForPunchTools()
		local char = player.Character
		if char then
			for _, t in ipairs(char:GetChildren()) do
				if t:IsA("Tool") then hookPunchTool(t) end
			end
		end
		local bp = player:FindFirstChildOfClass("Backpack")
		if bp then
			for _, t in ipairs(bp:GetChildren()) do
				if t:IsA("Tool") then hookPunchTool(t) end
			end
		end
	end

	scanForPunchTools()

	if player.Character then
		player.Character.ChildAdded:Connect(function(c)
			if c:IsA("Tool") then hookPunchTool(c) end
		end)
	end
	player.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		c.ChildAdded:Connect(function(ch)
			if ch:IsA("Tool") then hookPunchTool(ch) end
		end)
		scanForPunchTools()
	end)

	local bp = player:FindFirstChildOfClass("Backpack")
	if bp then
		bp.ChildAdded:Connect(function(c)
			if c:IsA("Tool") then hookPunchTool(c) end
		end)
	end

	task.spawn(function()
		while true do
			task.wait(2)
			pcall(scanForPunchTools)
		end
	end)

	-- ============================================
	-- RAPID FIRE - Fixed: checks if mouse is over GUI to not interfere
	-- ============================================
	local function isMouseOverGui()
		local mousePos = UIS:GetMouseLocation()
		local guiObjects = playerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
		for _, obj in ipairs(guiObjects) do
			-- Check if it belongs to our BearHub GUI
			local current = obj
			while current do
				if current == gui or current.Name == "BearHub" then
					return true
				end
				current = current.Parent
			end
		end
		return false
	end

	task.spawn(function()
		while true do
			if MISC.RapidFire and mbHeld[1] then
				local rfLevel = MISC.RapidFireLevel or 20
				if rfLevel < 20 then
					-- Don't rapid fire if mouse is over GUI
					if not isMouseOverGui() then
						local delay2 = (rfLevel / 20) * 0.15
						pcall(function()
							VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
							task.wait(0.01)
							VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
						end)
						task.wait(math.max(delay2, 0.01))
					else
						task.wait(0.05)
					end
				else
					task.wait(0.05)
				end
			else
				task.wait(0.05)
			end
		end
	end)
end

local healPlayer = _G.BearHub_healPlayer

--============================================================
-- BLOK 6: GUI - MAIN, SIDEBAR, COLOR PICKER
--============================================================
local main, sidebar, contentTitle, pagesFrame, colorPickerGui
local openCP
local cpGrid, hueBar

do
	local ORIGINAL_SIZE = UDim2.new(0, 700, 0, 450)

	main = Instance.new("Frame", gui)
	main.Name = "Main"
	main.Size = ORIGINAL_SIZE
	main.Position = UDim2.new(0.5, -350, 0.5, -225)
	main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Active = true
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

	sidebar = Instance.new("Frame", main)
	sidebar.Size = UDim2.new(0, 190, 1, 0)
	sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	sidebar.BorderSizePixel = 0
	sidebar.Active = true
	Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

	local bearIcon = Instance.new("ImageLabel", sidebar)
	bearIcon.Size = UDim2.new(0, 80, 0, 80)
	bearIcon.Position = UDim2.new(0.5, -40, 0, 15)
	bearIcon.BackgroundTransparency = 1
	bearIcon.Image = BEAR_ICON
	bearIcon.ImageColor3 = Color3.new(1, 1, 1)
	bearIcon.ScaleType = Enum.ScaleType.Fit

	local tabsFrame = Instance.new("Frame", sidebar)
	tabsFrame.Name = "TabsFrame"
	tabsFrame.Size = UDim2.new(1, -20, 1, -130)
	tabsFrame.Position = UDim2.new(0, 10, 0, 110)
	tabsFrame.BackgroundTransparency = 1
	local tfl = Instance.new("UIListLayout", tabsFrame)
	tfl.Padding = UDim.new(0, 6)
	tfl.SortOrder = Enum.SortOrder.LayoutOrder

	local contentArea = Instance.new("Frame", main)
	contentArea.Size = UDim2.new(1, -200, 1, -20)
	contentArea.Position = UDim2.new(0, 200, 0, 10)
	contentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	contentArea.BorderSizePixel = 0
	contentArea.ClipsDescendants = true
	Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

	contentTitle = Instance.new("TextLabel", contentArea)
	contentTitle.Size = UDim2.new(1, -20, 0, 40)
	contentTitle.Position = UDim2.new(0, 15, 0, 10)
	contentTitle.BackgroundTransparency = 1
	contentTitle.Text = "AimAssistance"
	contentTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	contentTitle.Font = Enum.Font.GothamBold
	contentTitle.TextSize = 20
	contentTitle.TextXAlignment = Enum.TextXAlignment.Left

	pagesFrame = Instance.new("Frame", contentArea)
	pagesFrame.Size = UDim2.new(1, 0, 1, -55)
	pagesFrame.Position = UDim2.new(0, 0, 0, 55)
	pagesFrame.BackgroundTransparency = 1

	colorPickerGui = Instance.new("Frame", main)
	colorPickerGui.Size = UDim2.new(0, 220, 0, 260)
	colorPickerGui.Position = UDim2.new(0.5, -110, 0.5, -130)
	colorPickerGui.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	colorPickerGui.BorderSizePixel = 0
	colorPickerGui.Visible = false
	colorPickerGui.ZIndex = 100
	colorPickerGui.Active = true
	Instance.new("UICorner", colorPickerGui).CornerRadius = UDim.new(0, 10)
	local cpStroke = Instance.new("UIStroke", colorPickerGui)
	cpStroke.Color = PURPLE
	cpStroke.Thickness = 2

	local cpTitleLbl = Instance.new("TextLabel", colorPickerGui)
	cpTitleLbl.Size = UDim2.new(1, 0, 0, 30)
	cpTitleLbl.BackgroundTransparency = 1
	cpTitleLbl.Text = "Pick Color"
	cpTitleLbl.TextColor3 = Color3.new(1,1,1)
	cpTitleLbl.Font = Enum.Font.GothamBold
	cpTitleLbl.TextSize = 14
	cpTitleLbl.ZIndex = 101

	local cpClose = Instance.new("TextButton", colorPickerGui)
	cpClose.Size = UDim2.new(0, 25, 0, 25)
	cpClose.Position = UDim2.new(1, -30, 0, 3)
	cpClose.BackgroundTransparency = 1
	cpClose.Text = "X"
	cpClose.TextColor3 = Color3.fromRGB(200,200,200)
	cpClose.Font = Enum.Font.GothamBold
	cpClose.TextSize = 16
	cpClose.ZIndex = 102
	cpClose.MouseButton1Click:Connect(function() playClick(); colorPickerGui.Visible = false end)

	cpGrid = Instance.new("Frame", colorPickerGui)
	cpGrid.Size = UDim2.new(1, -20, 0, 150)
	cpGrid.Position = UDim2.new(0, 10, 0, 35)
	cpGrid.BackgroundColor3 = Color3.fromRGB(255,0,0)
	cpGrid.BorderSizePixel = 0
	cpGrid.ZIndex = 101
	cpGrid.ClipsDescendants = true
	Instance.new("UICorner", cpGrid).CornerRadius = UDim.new(0, 6)

	local satOver = Instance.new("Frame", cpGrid)
	satOver.Size = UDim2.new(1,0,1,0)
	satOver.BackgroundColor3 = Color3.new(1,1,1)
	satOver.BorderSizePixel = 0
	satOver.ZIndex = 102
	local satGrad = Instance.new("UIGradient", satOver)
	satGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})

	local valOver = Instance.new("Frame", cpGrid)
	valOver.Size = UDim2.new(1,0,1,0)
	valOver.BackgroundColor3 = Color3.new(0,0,0)
	valOver.BorderSizePixel = 0
	valOver.ZIndex = 103
	local valGrad = Instance.new("UIGradient", valOver)
	valGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
	valGrad.Rotation = 90

	local cpCur = Instance.new("Frame", cpGrid)
	cpCur.Size = UDim2.new(0,10,0,10)
	cpCur.BackgroundColor3 = Color3.new(1,1,1)
	cpCur.BorderSizePixel = 0
	cpCur.ZIndex = 105
	Instance.new("UICorner", cpCur).CornerRadius = UDim.new(1,0)
	local cpCurStroke = Instance.new("UIStroke", cpCur)
	cpCurStroke.Color = Color3.new(0,0,0)
	cpCurStroke.Thickness = 1

	hueBar = Instance.new("Frame", colorPickerGui)
	hueBar.Size = UDim2.new(1,-20,0,20)
	hueBar.Position = UDim2.new(0,10,0,195)
	hueBar.BorderSizePixel = 0
	hueBar.ZIndex = 101
	hueBar.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0,6)
	local hueGrad = Instance.new("UIGradient", hueBar)
	hueGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
		ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
		ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
		ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
	})

	local hueSlider = Instance.new("Frame", hueBar)
	hueSlider.Size = UDim2.new(0,4,1,4)
	hueSlider.Position = UDim2.new(0,-2,0,-2)
	hueSlider.BackgroundColor3 = Color3.new(1,1,1)
	hueSlider.BorderSizePixel = 0
	hueSlider.ZIndex = 102
	Instance.new("UICorner", hueSlider).CornerRadius = UDim.new(0,2)

	local cpPrev = Instance.new("Frame", colorPickerGui)
	cpPrev.Size = UDim2.new(0,40,0,30)
	cpPrev.Position = UDim2.new(0,10,0,222)
	cpPrev.BackgroundColor3 = Color3.fromRGB(255,0,0)
	cpPrev.BorderSizePixel = 0
	cpPrev.ZIndex = 101
	Instance.new("UICorner", cpPrev).CornerRadius = UDim.new(0,6)

	local cpApply = Instance.new("TextButton", colorPickerGui)
	cpApply.Size = UDim2.new(0,80,0,28)
	cpApply.Position = UDim2.new(1,-95,0,223)
	cpApply.BackgroundColor3 = PURPLE
	cpApply.Text = "Apply"
	cpApply.TextColor3 = Color3.new(1,1,1)
	cpApply.Font = Enum.Font.GothamBold
	cpApply.TextSize = 13
	cpApply.ZIndex = 102
	cpApply.AutoButtonColor = false
	Instance.new("UICorner", cpApply).CornerRadius = UDim.new(0,6)

	local cH, cS, cV = 0, 1, 1
	local activeCC = nil

	local function updCP()
		cpPrev.BackgroundColor3 = Color3.fromHSV(cH, cS, cV)
		cpGrid.BackgroundColor3 = Color3.fromHSV(cH, 1, 1)
		cpCur.Position = UDim2.new(cS, -5, 1 - cV, -5)
		hueSlider.Position = UDim2.new(cH, -2, 0, -2)
	end

	_G.BearHub_canvasDrag = false
	_G.BearHub_hueDrag = false

	local cpGB = Instance.new("TextButton", cpGrid)
	cpGB.Size = UDim2.new(1,0,1,0)
	cpGB.BackgroundTransparency = 1
	cpGB.Text = ""
	cpGB.ZIndex = 106
	cpGB.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			_G.BearHub_canvasDrag = true
			local ap = cpGrid.AbsolutePosition
			local as = cpGrid.AbsoluteSize
			cS = math.clamp((i.Position.X - ap.X) / as.X, 0, 1)
			cV = 1 - math.clamp((i.Position.Y - ap.Y) / as.Y, 0, 1)
			updCP()
		end
	end)

	local hB = Instance.new("TextButton", hueBar)
	hB.Size = UDim2.new(1,0,1,0)
	hB.BackgroundTransparency = 1
	hB.Text = ""
	hB.ZIndex = 103
	hB.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			_G.BearHub_hueDrag = true
			local ap = hueBar.AbsolutePosition
			local as = hueBar.AbsoluteSize
			cH = math.clamp((i.Position.X - ap.X) / as.X, 0, 1)
			updCP()
		end
	end)

	cpApply.MouseButton1Click:Connect(function()
		playClick()
		if activeCC then activeCC(Color3.fromHSV(cH, cS, cV)) end
		colorPickerGui.Visible = false
	end)

	_G.BearHub_openCP = function(col, cb)
		local h, s, v = col:ToHSV()
		cH, cS, cV = h, s, v
		activeCC = cb
		updCP()
		colorPickerGui.Visible = true
	end

	_G.BearHub_updCPValues = function(x, y, kind)
		if kind == "canvas" then
			local ap = cpGrid.AbsolutePosition
			local as = cpGrid.AbsoluteSize
			cS = math.clamp((x - ap.X) / as.X, 0, 1)
			cV = 1 - math.clamp((y - ap.Y) / as.Y, 0, 1)
			updCP()
		elseif kind == "hue" then
			local ap = hueBar.AbsolutePosition
			local as = hueBar.AbsoluteSize
			cH = math.clamp((x - ap.X) / as.X, 0, 1)
			updCP()
		end
	end
end

openCP = _G.BearHub_openCP

--============================================================
-- BLOK 7: GUI HELPERS
--============================================================
_G.BearHub_allSliders = {}
_G.BearHub_tabPages = {}

local mkSection, mkCheck, mkCheckColor, mkSlider, mkDropdown, mkKeybind, mkButton, createPage

do
	local allSliders = _G.BearHub_allSliders

	mkSection = function(parent, text, order)
		local l = Instance.new("TextLabel", parent)
		l.Size = UDim2.new(1, 0, 0, 28)
		l.BackgroundTransparency = 1
		l.Text = text
		l.TextColor3 = Color3.fromRGB(160,160,170)
		l.Font = Enum.Font.GothamBold
		l.TextSize = 14
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.LayoutOrder = order or 0
	end

	mkCheck = function(parent, text, tbl, key, order)
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.new(1,0,0,30)
		h.BackgroundTransparency = 1
		h.LayoutOrder = order or 0
		local en = tbl[key] or false
		local box = Instance.new("TextButton", h)
		box.Size = UDim2.new(0,22,0,22)
		box.Position = UDim2.new(0,5,0.5,-11)
		box.BackgroundColor3 = en and PURPLE or GRAY
		box.Text = ""
		box.AutoButtonColor = false
		box.BorderSizePixel = 0
		Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)
		local check = Instance.new("ImageLabel", box)
		check.Size = UDim2.new(0.75, 0, 0.75, 0)
		check.Position = UDim2.new(0.125, 0, 0.125, 0)
		check.BackgroundTransparency = 1
		check.Image = CHECK_ICON
		check.ImageColor3 = Color3.new(1,1,1)
		check.Visible = en
		local lbl = Instance.new("TextLabel", h)
		lbl.Size = UDim2.new(1,-40,1,0)
		lbl.Position = UDim2.new(0,35,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = Color3.fromRGB(200,200,210)
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		box.MouseButton1Click:Connect(function()
			playClick()
			en = not en
			box.BackgroundColor3 = en and PURPLE or GRAY
			check.Visible = en
			tbl[key] = en
			if tbl == ESP then pcall(fullRefresh) end
		end)
	end

	mkCheckColor = function(parent, text, tbl, key, colorKey, order)
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.new(1,0,0,30)
		h.BackgroundTransparency = 1
		h.LayoutOrder = order or 0
		local isSubTable = (colorKey == nil)
		local en, colorRef
		if isSubTable then en = ESP[key].Enabled; colorRef = ESP[key].Color
		else en = tbl[key] or false; colorRef = tbl[colorKey] end
		local box = Instance.new("TextButton", h)
		box.Size = UDim2.new(0,22,0,22)
		box.Position = UDim2.new(0,5,0.5,-11)
		box.BackgroundColor3 = en and PURPLE or GRAY
		box.Text = ""
		box.AutoButtonColor = false
		box.BorderSizePixel = 0
		Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)
		local check = Instance.new("ImageLabel", box)
		check.Size = UDim2.new(0.75, 0, 0.75, 0)
		check.Position = UDim2.new(0.125, 0, 0.125, 0)
		check.BackgroundTransparency = 1
		check.Image = CHECK_ICON
		check.ImageColor3 = Color3.new(1,1,1)
		check.Visible = en
		local lbl = Instance.new("TextLabel", h)
		lbl.Size = UDim2.new(1,-80,1,0)
		lbl.Position = UDim2.new(0,35,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = Color3.fromRGB(200,200,210)
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		local circle = Instance.new("TextButton", h)
		circle.Size = UDim2.new(0,22,0,22)
		circle.Position = UDim2.new(1,-30,0.5,-11)
		circle.BackgroundColor3 = colorRef
		circle.Text = ""
		circle.AutoButtonColor = false
		circle.BorderSizePixel = 0
		Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
		local cs = Instance.new("UIStroke", circle)
		cs.Color = Color3.fromRGB(80,80,90)
		cs.Thickness = 2
		circle.MouseButton1Click:Connect(function()
			playClick()
			openCP(circle.BackgroundColor3, function(nc)
				circle.BackgroundColor3 = nc
				if isSubTable then ESP[key].Color = nc
				else tbl[colorKey] = nc end
			end)
		end)
		box.MouseButton1Click:Connect(function()
			playClick()
			en = not en
			box.BackgroundColor3 = en and PURPLE or GRAY
			check.Visible = en
			if isSubTable then ESP[key].Enabled = en
			else tbl[key] = en end
		end)
	end

	mkSlider = function(parent, text, minV, maxV, def, suf, tbl, key, order)
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.new(1,0,0,50)
		h.BackgroundTransparency = 1
		h.LayoutOrder = order or 0
		local val = def or minV
		local lbl = Instance.new("TextLabel", h)
		lbl.Size = UDim2.new(0.6,0,0,20)
		lbl.Position = UDim2.new(0,5,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = Color3.fromRGB(200,200,210)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		local vl = Instance.new("TextLabel", h)
		vl.Size = UDim2.new(0.4,-5,0,20)
		vl.Position = UDim2.new(0.6,0,0,0)
		vl.BackgroundTransparency = 1
		vl.Text = tostring(val) .. (suf or "")
		vl.TextColor3 = Color3.fromRGB(150,150,160)
		vl.Font = Enum.Font.Gotham
		vl.TextSize = 13
		vl.TextXAlignment = Enum.TextXAlignment.Right
		local bg = Instance.new("Frame", h)
		bg.Size = UDim2.new(1,-10,0,6)
		bg.Position = UDim2.new(0,5,0,30)
		bg.BackgroundColor3 = Color3.fromRGB(50,50,60)
		bg.BorderSizePixel = 0
		Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
		local pct = (val - minV) / (maxV - minV)
		local fill = Instance.new("Frame", bg)
		fill.Size = UDim2.new(pct,0,1,0)
		fill.BackgroundColor3 = PURPLE
		fill.BorderSizePixel = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
		local knob = Instance.new("Frame", bg)
		knob.Size = UDim2.new(0,16,0,16)
		knob.Position = UDim2.new(pct,-8,0.5,-8)
		knob.BackgroundColor3 = Color3.new(1,1,1)
		knob.BorderSizePixel = 0
		knob.ZIndex = 2
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
		local hit = Instance.new("TextButton", bg)
		hit.Size = UDim2.new(1,20,0,30)
		hit.Position = UDim2.new(0,-10,0.5,-15)
		hit.BackgroundTransparency = 1
		hit.Text = ""
		hit.ZIndex = 3
		local drag = false
		local lastSliderSoundTick = 0
		local lastSliderVal = val
		local function upd(x)
			local ap = bg.AbsolutePosition
			local as = bg.AbsoluteSize
			local rx = math.clamp((x - ap.X) / as.X, 0, 1)
			val = math.floor(minV + (maxV - minV) * rx)
			fill.Size = UDim2.new(rx,0,1,0)
			knob.Position = UDim2.new(rx,-8,0.5,-8)
			vl.Text = tostring(val) .. (suf or "")
			if tbl and key then tbl[key] = val end
			if val ~= lastSliderVal then
				local now = tick()
				if now - lastSliderSoundTick > 0.08 then
					lastSliderSoundTick = now
					playSlider()
				end
				lastSliderVal = val
			end
		end
		hit.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; upd(i.Position.X) end
		end)
		table.insert(allSliders, {isDragging = function() return drag end, update = upd, setDrag = function(v) drag = v end})
	end

	mkDropdown = function(parent, text, opts, tbl, key, order)
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.new(1,0,0,60)
		h.BackgroundTransparency = 1
		h.LayoutOrder = order or 0
		h.ClipsDescendants = false
		local lbl = Instance.new("TextLabel", h)
		lbl.Size = UDim2.new(1,0,0,20)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = Color3.fromRGB(200,200,210)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Position = UDim2.new(0,5,0,0)
		local btn = Instance.new("TextButton", h)
		btn.Size = UDim2.new(1,-10,0,30)
		btn.Position = UDim2.new(0,5,0,25)
		btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
		btn.BorderSizePixel = 0
		btn.Text = "  " .. tbl[key]
		btn.TextColor3 = Color3.fromRGB(200,200,210)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
		local dd = Instance.new("Frame", h)
		dd.Size = UDim2.new(1,-10,0,#opts*30)
		dd.Position = UDim2.new(0,5,0,58)
		dd.BackgroundColor3 = Color3.fromRGB(35,35,45)
		dd.BorderSizePixel = 0
		dd.Visible = false
		dd.ZIndex = 50
		Instance.new("UICorner", dd).CornerRadius = UDim.new(0,6)
		local ddl = Instance.new("UIListLayout", dd)
		ddl.Padding = UDim.new(0,0)
		for _, opt in ipairs(opts) do
			local ob = Instance.new("TextButton", dd)
			ob.Size = UDim2.new(1,0,0,30)
			ob.BackgroundColor3 = Color3.fromRGB(35,35,45)
			ob.Text = "  " .. opt
			ob.TextColor3 = Color3.fromRGB(180,180,190)
			ob.Font = Enum.Font.Gotham
			ob.TextSize = 13
			ob.TextXAlignment = Enum.TextXAlignment.Left
			ob.AutoButtonColor = false
			ob.ZIndex = 51
			ob.BorderSizePixel = 0
			ob.MouseEnter:Connect(function() ob.BackgroundColor3 = Color3.fromRGB(50,50,65) end)
			ob.MouseLeave:Connect(function() ob.BackgroundColor3 = Color3.fromRGB(35,35,45) end)
			ob.MouseButton1Click:Connect(function()
				playClick()
				tbl[key] = opt
				btn.Text = "  " .. opt
				dd.Visible = false
			end)
		end
		btn.MouseButton1Click:Connect(function() playClick(); dd.Visible = not dd.Visible end)
	end

	local BIND_OPTIONS = {
		{"LPM (MB1)", function() return mbHeld[1] end},
		{"PPM (MB2)", function() return mbHeld[2] end},
		{"Scroll (MB3)", function() return mbHeld[3] end},
		{"Side Back (MB4)", function() return mbHeld[4] end},
		{"Side Front (MB5)", function() return mbHeld[5] end},
	}

	local KB_KEYS = {
		Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.G, Enum.KeyCode.H,
		Enum.KeyCode.Q, Enum.KeyCode.R, Enum.KeyCode.T, Enum.KeyCode.X,
		Enum.KeyCode.Z, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.B,
		Enum.KeyCode.CapsLock, Enum.KeyCode.Tab,
		Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt,
		Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl,
		Enum.KeyCode.LeftShift,
		Enum.KeyCode.F1, Enum.KeyCode.F2, Enum.KeyCode.F3, Enum.KeyCode.F4,
		Enum.KeyCode.F5, Enum.KeyCode.F6, Enum.KeyCode.F7, Enum.KeyCode.F8,
	}

	for _, kc in ipairs(KB_KEYS) do
		local kcc = kc
		table.insert(BIND_OPTIONS, {kc.Name, function() return UIS:IsKeyDown(kcc) end})
	end

	mkKeybind = function(parent, text, tbl, order)
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.new(1,0,0,30)
		h.BackgroundTransparency = 1
		h.LayoutOrder = order or 0
		local en = tbl.Enabled
		local box = Instance.new("TextButton", h)
		box.Size = UDim2.new(0,22,0,22)
		box.Position = UDim2.new(0,5,0.5,-11)
		box.BackgroundColor3 = en and PURPLE or GRAY
		box.Text = ""
		box.AutoButtonColor = false
		box.BorderSizePixel = 0
		Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)
		local check = Instance.new("ImageLabel", box)
		check.Size = UDim2.new(0.75, 0, 0.75, 0)
		check.Position = UDim2.new(0.125, 0, 0.125, 0)
		check.BackgroundTransparency = 1
		check.Image = CHECK_ICON
		check.ImageColor3 = Color3.new(1,1,1)
		check.Visible = en
		local lbl = Instance.new("TextLabel", h)
		lbl.Size = UDim2.new(0,55,1,0)
		lbl.Position = UDim2.new(0,35,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = Color3.fromRGB(200,200,210)
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		local keyBtn = Instance.new("TextButton", h)
		keyBtn.Size = UDim2.new(0,110,0,24)
		keyBtn.Position = UDim2.new(1,-115,0.5,-12)
		keyBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
		keyBtn.BorderSizePixel = 0
		keyBtn.Text = tbl.KeybindName
		keyBtn.TextColor3 = Color3.fromRGB(180,180,190)
		keyBtn.Font = Enum.Font.GothamBold
		keyBtn.TextSize = 11
		keyBtn.AutoButtonColor = false
		Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0,5)
		local totalOpts = #BIND_OPTIONS + 1
		local ddFrame = Instance.new("Frame", h)
		ddFrame.Size = UDim2.new(0,170,0,math.min(totalOpts,8)*28)
		ddFrame.Position = UDim2.new(1,-175,1,2)
		ddFrame.BackgroundColor3 = Color3.fromRGB(30,30,38)
		ddFrame.BorderSizePixel = 0
		ddFrame.Visible = false
		ddFrame.ZIndex = 200
		ddFrame.ClipsDescendants = true
		Instance.new("UICorner", ddFrame).CornerRadius = UDim.new(0,6)
		local dds = Instance.new("UIStroke", ddFrame)
		dds.Color = PURPLE
		dds.Thickness = 1.5
		local ddScroll = Instance.new("ScrollingFrame", ddFrame)
		ddScroll.Size = UDim2.new(1,0,1,0)
		ddScroll.BackgroundTransparency = 1
		ddScroll.ScrollBarThickness = 3
		ddScroll.ScrollBarImageColor3 = PURPLE
		ddScroll.CanvasSize = UDim2.new(0,0,0,totalOpts*28)
		ddScroll.ZIndex = 201
		local ddll = Instance.new("UIListLayout", ddScroll)
		ddll.Padding = UDim.new(0,0)
		local noneBtn = Instance.new("TextButton", ddScroll)
		noneBtn.Size = UDim2.new(1,0,0,28)
		noneBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
		noneBtn.Text = "  NONE"
		noneBtn.TextColor3 = Color3.fromRGB(150,150,160)
		noneBtn.Font = Enum.Font.Gotham
		noneBtn.TextSize = 12
		noneBtn.TextXAlignment = Enum.TextXAlignment.Left
		noneBtn.AutoButtonColor = false
		noneBtn.ZIndex = 202
		noneBtn.BorderSizePixel = 0
		noneBtn.LayoutOrder = 0
		noneBtn.MouseEnter:Connect(function() noneBtn.BackgroundColor3 = Color3.fromRGB(50,50,65) end)
		noneBtn.MouseLeave:Connect(function() noneBtn.BackgroundColor3 = Color3.fromRGB(30,30,38) end)
		noneBtn.MouseButton1Click:Connect(function()
			playClick()
			tbl.KeybindName = "NONE"
			tbl.KeybindCheck = nil
			keyBtn.Text = "NONE"
			ddFrame.Visible = false
		end)
		for i, opt in ipairs(BIND_OPTIONS) do
			local name = opt[1]
			local checkFn = opt[2]
			local ob = Instance.new("TextButton", ddScroll)
			ob.Size = UDim2.new(1,0,0,28)
			ob.BackgroundColor3 = Color3.fromRGB(30,30,38)
			ob.Text = "  " .. name
			ob.TextColor3 = Color3.fromRGB(180,180,190)
			ob.Font = Enum.Font.Gotham
			ob.TextSize = 12
			ob.TextXAlignment = Enum.TextXAlignment.Left
			ob.AutoButtonColor = false
			ob.ZIndex = 202
			ob.BorderSizePixel = 0
			ob.LayoutOrder = i
			ob.MouseEnter:Connect(function() ob.BackgroundColor3 = Color3.fromRGB(50,50,65) end)
			ob.MouseLeave:Connect(function() ob.BackgroundColor3 = Color3.fromRGB(30,30,38) end)
			ob.MouseButton1Click:Connect(function()
				playClick()
				tbl.KeybindName = name
				tbl.KeybindCheck = checkFn
				keyBtn.Text = name
				ddFrame.Visible = false
			end)
		end
		local ddOpen = false
		keyBtn.MouseButton1Click:Connect(function()
			playClick()
			ddOpen = not ddOpen
			ddFrame.Visible = ddOpen
		end)
		box.MouseButton1Click:Connect(function()
			playClick()
			en = not en
			tbl.Enabled = en
			box.BackgroundColor3 = en and PURPLE or GRAY
			check.Visible = en
		end)
	end

	mkButton = function(parent, text, callback, order)
		local btn = Instance.new("TextButton", parent)
		btn.Size = UDim2.new(1,-10,0,36)
		btn.BackgroundColor3 = PURPLE
		btn.BorderSizePixel = 0
		btn.Text = text
		btn.TextColor3 = Color3.new(1,1,1)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 13
		btn.AutoButtonColor = false
		btn.LayoutOrder = order or 0
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
		btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(120, 90, 220) end)
		btn.MouseLeave:Connect(function() btn.BackgroundColor3 = PURPLE end)
		btn.MouseButton1Click:Connect(function()
			playClick()
			if callback then pcall(callback) end
		end)
		return btn
	end

	createPage = function(name)
		local p = Instance.new("ScrollingFrame", pagesFrame)
		p.Size = UDim2.new(1,0,1,0)
		p.BackgroundTransparency = 1
		p.ScrollBarThickness = 3
		p.ScrollBarImageColor3 = PURPLE
		p.Visible = false
		p.CanvasSize = UDim2.new(0,0,0,0)
		p.AutomaticCanvasSize = Enum.AutomaticSize.Y
		_G.BearHub_tabPages[name] = p
		return p
	end
end

--============================================================
-- BLOK 8: STRONY GUI (Visualization, AimAssistance)
--============================================================
do
	local vizPage = createPage("Visualization")

	local vL = Instance.new("Frame", vizPage)
	vL.Size = UDim2.new(0.48,0,0,260)
	vL.Position = UDim2.new(0,10,0,5)
	vL.BackgroundColor3 = DARK
	vL.BorderSizePixel = 0
	Instance.new("UICorner", vL).CornerRadius = UDim.new(0,8)
	local vll = Instance.new("UIListLayout", vL)
	vll.Padding = UDim.new(0,4)
	vll.SortOrder = Enum.SortOrder.LayoutOrder
	local vlp = Instance.new("UIPadding", vL)
	vlp.PaddingTop = UDim.new(0,8)
	vlp.PaddingLeft = UDim.new(0,5)
	vlp.PaddingRight = UDim.new(0,5)

	local vR = Instance.new("Frame", vizPage)
	vR.Size = UDim2.new(0.48,0,0,360)
	vR.Position = UDim2.new(0.5,5,0,5)
	vR.BackgroundColor3 = DARK
	vR.BorderSizePixel = 0
	Instance.new("UICorner", vR).CornerRadius = UDim.new(0,8)
	local vrl = Instance.new("UIListLayout", vR)
	vrl.Padding = UDim.new(0,4)
	vrl.SortOrder = Enum.SortOrder.LayoutOrder
	local vrp = Instance.new("UIPadding", vR)
	vrp.PaddingTop = UDim.new(0,8)
	vrp.PaddingLeft = UDim.new(0,5)
	vrp.PaddingRight = UDim.new(0,5)

	mkSection(vL, "Visualization", 1)
	mkCheck(vL, "Enable", ESP, "Enabled", 2)
	mkSlider(vL, "Max Distance", 0, 1000, 300, "m", ESP, "MaxDistance", 3)
	mkCheck(vL, "Show LocalPlayer", ESP, "ShowLocalPlayer", 4)
	mkCheck(vL, "Visible Only", ESP, "VisibleOnly", 5)

	mkSection(vR, "Options", 1)
	mkCheckColor(vR, "Box", nil, "Box", nil, 2)
	mkCheckColor(vR, "Skeleton", nil, "Skeleton", nil, 3)
	mkCheckColor(vR, "Name", nil, "Name", nil, 4)
	mkCheckColor(vR, "ID", nil, "ID", nil, 5)
	mkCheckColor(vR, "Health Bar", nil, "HealthBar", nil, 6)
	mkCheckColor(vR, "Distance", nil, "Distance", nil, 7)
	mkCheckColor(vR, "Snaplines", nil, "Snaplines", nil, 8)
	mkCheckColor(vR, "Inventory", nil, "Inventory", nil, 9)

	local aimPage = createPage("AimAssistance")

	local subBar = Instance.new("Frame", aimPage)
	subBar.Size = UDim2.new(1,-20,0,30)
	subBar.Position = UDim2.new(0,10,0,0)
	subBar.BackgroundTransparency = 1
	local sbl = Instance.new("UIListLayout", subBar)
	sbl.FillDirection = Enum.FillDirection.Horizontal
	sbl.Padding = UDim.new(0,15)

	local subPagesFrame = Instance.new("Frame", aimPage)
	subPagesFrame.Size = UDim2.new(1,0,1,-40)
	subPagesFrame.Position = UDim2.new(0,0,0,38)
	subPagesFrame.BackgroundTransparency = 1

	local tbPage = Instance.new("Frame", subPagesFrame)
	tbPage.Size = UDim2.new(1,0,1,0)
	tbPage.BackgroundTransparency = 1
	tbPage.Visible = true

	local tbL = Instance.new("Frame", tbPage)
	tbL.Size = UDim2.new(0.48,0,0,300)
	tbL.Position = UDim2.new(0,10,0,5)
	tbL.BackgroundColor3 = DARK
	tbL.BorderSizePixel = 0
	Instance.new("UICorner", tbL).CornerRadius = UDim.new(0,8)
	local tbll = Instance.new("UIListLayout", tbL)
	tbll.Padding = UDim.new(0,4)
	tbll.SortOrder = Enum.SortOrder.LayoutOrder
	local tblp = Instance.new("UIPadding", tbL)
	tblp.PaddingTop = UDim.new(0,8)
	tblp.PaddingLeft = UDim.new(0,5)
	tblp.PaddingRight = UDim.new(0,5)

	local tbR = Instance.new("Frame", tbPage)
	tbR.Size = UDim2.new(0.48,0,0,300)
	tbR.Position = UDim2.new(0.5,5,0,5)
	tbR.BackgroundColor3 = DARK
	tbR.BorderSizePixel = 0
	Instance.new("UICorner", tbR).CornerRadius = UDim.new(0,8)
	local tbrl = Instance.new("UIListLayout", tbR)
	tbrl.Padding = UDim.new(0,4)
	tbrl.SortOrder = Enum.SortOrder.LayoutOrder
	local tbrp = Instance.new("UIPadding", tbR)
	tbrp.PaddingTop = UDim.new(0,8)
	tbrp.PaddingLeft = UDim.new(0,5)
	tbrp.PaddingRight = UDim.new(0,5)

	mkSection(tbL, "TriggerBot", 1)
	mkKeybind(tbL, "Enable", TRIGGERBOT, 2)
	mkDropdown(tbL, "Type", {"First Person","Third Person"}, TRIGGERBOT, "Type", 3)
	mkCheckColor(tbL, "Show FOV", TRIGGERBOT, "ShowFOV", "FOVColor", 4)
	mkSlider(tbL, "Field of View", 1, 100, 30, "px", TRIGGERBOT, "FOV", 5)

	mkSection(tbR, "Options", 1)
	mkCheck(tbR, "Exclude Dead", TRIGGERBOT, "ExcludeDead", 2)
	mkCheck(tbR, "Visible Only", TRIGGERBOT, "VisibleOnly", 3)
	mkSlider(tbR, "Max Distance", 0, 500, 250, "m", TRIGGERBOT, "MaxDistance", 4)
	mkSlider(tbR, "Shot Delay", 0, 1000, 100, "ms", TRIGGERBOT, "ShotDelay", 5)

	local abPage = Instance.new("Frame", subPagesFrame)
	abPage.Size = UDim2.new(1,0,1,0)
	abPage.BackgroundTransparency = 1
	abPage.Visible = false

	local abL = Instance.new("Frame", abPage)
	abL.Size = UDim2.new(0.48,0,0,300)
	abL.Position = UDim2.new(0,10,0,5)
	abL.BackgroundColor3 = DARK
	abL.BorderSizePixel = 0
	Instance.new("UICorner", abL).CornerRadius = UDim.new(0,8)
	local abll = Instance.new("UIListLayout", abL)
	abll.Padding = UDim.new(0,4)
	abll.SortOrder = Enum.SortOrder.LayoutOrder
	local ablp = Instance.new("UIPadding", abL)
	ablp.PaddingTop = UDim.new(0,8)
	ablp.PaddingLeft = UDim.new(0,5)
	ablp.PaddingRight = UDim.new(0,5)

	local abR = Instance.new("Frame", abPage)
	abR.Size = UDim2.new(0.48,0,0,360)
	abR.Position = UDim2.new(0.5,5,0,5)
	abR.BackgroundColor3 = DARK
	abR.BorderSizePixel = 0
	Instance.new("UICorner", abR).CornerRadius = UDim.new(0,8)
	local abrl = Instance.new("UIListLayout", abR)
	abrl.Padding = UDim.new(0,4)
	abrl.SortOrder = Enum.SortOrder.LayoutOrder
	local abrp = Instance.new("UIPadding", abR)
	abrp.PaddingTop = UDim.new(0,8)
	abrp.PaddingLeft = UDim.new(0,5)
	abrp.PaddingRight = UDim.new(0,5)

	mkSection(abL, "Aimbot", 1)
	mkKeybind(abL, "Enable", AIMBOT, 2)
	mkCheckColor(abL, "Draw FOV", AIMBOT, "DrawFOV", "FOVColor", 3)
	mkCheck(abL, "Visible Check", AIMBOT, "VisibleCheck", 4)
	mkCheck(abL, "Exclude Dead", AIMBOT, "ExcludeDead", 5)

	mkSection(abR, "Options", 1)
	mkDropdown(abR, "Bones", {"Head","Torso","Legs"}, AIMBOT, "Bone", 2)
	mkSlider(abR, "Field of view", 1, 100, 10, "", AIMBOT, "FOV", 3)
	mkSlider(abR, "Max Distance", 0, 500, 250, "m", AIMBOT, "MaxDistance", 4)
	mkSlider(abR, "Smooth X", 1, 100, 80, "", AIMBOT, "SmoothX", 5)
	mkSlider(abR, "Smooth Y", 1, 100, 80, "", AIMBOT, "SmoothY", 6)

	local hbPage = Instance.new("Frame", subPagesFrame)
	hbPage.Size = UDim2.new(1,0,1,0)
	hbPage.BackgroundTransparency = 1
	hbPage.Visible = false

	local hbL = Instance.new("Frame", hbPage)
	hbL.Size = UDim2.new(0.48,0,0,250)
	hbL.Position = UDim2.new(0,10,0,5)
	hbL.BackgroundColor3 = DARK
	hbL.BorderSizePixel = 0
	Instance.new("UICorner", hbL).CornerRadius = UDim.new(0,8)
	local hbll = Instance.new("UIListLayout", hbL)
	hbll.Padding = UDim.new(0,4)
	hbll.SortOrder = Enum.SortOrder.LayoutOrder
	local hblp = Instance.new("UIPadding", hbL)
	hblp.PaddingTop = UDim.new(0,8)
	hblp.PaddingLeft = UDim.new(0,5)
	hblp.PaddingRight = UDim.new(0,5)

	mkSection(hbL, "Hitbox Expander", 1)
	mkCheck(hbL, "Enable", HITBOX, "Enabled", 2)
	mkDropdown(hbL, "Bones", {"Head","Torso","Legs"}, HITBOX, "Bone", 3)
	mkSlider(hbL, "Size", 0, 30, 0, "", HITBOX, "Size", 4)

	local selSub = nil

	local function switchSub(name)
		tbPage.Visible = (name == "TriggerBot")
		abPage.Visible = (name == "Aimbot")
		hbPage.Visible = (name == "Hitbox")
	end

	local function mkSB(name, order)
		local btn = Instance.new("TextButton", subBar)
		btn.Size = UDim2.new(0,100,1,0)
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0
		btn.Text = name
		btn.TextColor3 = Color3.fromRGB(120,120,130)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.AutoButtonColor = false
		btn.LayoutOrder = order
		local ul = Instance.new("Frame", btn)
		ul.Size = UDim2.new(1,0,0,2)
		ul.Position = UDim2.new(0,0,1,-2)
		ul.BackgroundColor3 = PURPLE
		ul.BorderSizePixel = 0
		ul.Visible = false
		btn.MouseButton1Click:Connect(function()
			playClick()
			if selSub then
				selSub.btn.TextColor3 = Color3.fromRGB(120,120,130)
				selSub.ul.Visible = false
			end
			selSub = {btn = btn, ul = ul}
			btn.TextColor3 = Color3.new(1,1,1)
			ul.Visible = true
			switchSub(name)
		end)
		return {btn = btn, ul = ul}
	end

	local s1 = mkSB("TriggerBot", 1)
	mkSB("Aimbot", 2)
	mkSB("Hitbox", 3)
	selSub = s1
	s1.btn.TextColor3 = Color3.new(1,1,1)
	s1.ul.Visible = true
end

--============================================================
-- BLOK 9: MISC PAGE + PLAYERS PAGE + SETTINGS
--============================================================
do
	local miscPage = createPage("Miscellaneous")

	local mL = Instance.new("Frame", miscPage)
	mL.Size = UDim2.new(0.48,0,0,700)
	mL.Position = UDim2.new(0,10,0,5)
	mL.BackgroundColor3 = DARK
	mL.BorderSizePixel = 0
	Instance.new("UICorner", mL).CornerRadius = UDim.new(0,8)
	local mll = Instance.new("UIListLayout", mL)
	mll.Padding = UDim.new(0,4)
	mll.SortOrder = Enum.SortOrder.LayoutOrder
	local mlp = Instance.new("UIPadding", mL)
	mlp.PaddingTop = UDim.new(0,8)
	mlp.PaddingLeft = UDim.new(0,5)
	mlp.PaddingRight = UDim.new(0,5)

	mkSection(mL, "Combat Cheats", 1)
	mkCheck(mL, "Semi God (Auto-Heal)", MISC, "SemiGod", 2)
	mkCheck(mL, "No Recoil", MISC, "NoRecoil", 3)
	mkCheck(mL, "No Spread", MISC, "NoSpread", 4)
	mkCheck(mL, "Infinity Ammo", MISC, "InfAmmo", 5)

	mkSection(mL, "Movement", 6)
	mkCheck(mL, "NoClip (Fly + No Collision)", MISC, "NoClip", 7)
	mkSlider(mL, "NoClip Fly Speed", 1, 100, 30, " m/s", MISC, "NoClipSpeed", 8)
	mkCheck(mL, "Walk Speed", MISC, "WalkSpeedEnabled", 9)
	mkSlider(mL, "Walk Speed Value", 0, 250, 16, " m/s", MISC, "WalkSpeed", 10)
	mkCheck(mL, "Jump Power", MISC, "JumpPowerEnabled", 11)
	mkSlider(mL, "Jump Power Value", 1, 500, 50, " m", MISC, "JumpPower", 12)

	mkSection(mL, "Super Punch (Fist)", 13)
	mkCheck(mL, "Enable Super Punch", MISC, "SuperPunch", 14)
	mkSlider(mL, "Punch Multiplier", 1, 200, 100, "x", MISC, "PunchMultiplier", 15)

	mkSection(mL, "Rapid Fire", 16)
	mkCheck(mL, "Enable Rapid Fire", MISC, "RapidFire", 17)
	mkSlider(mL, "Fire Speed", 0, 20, 20, "", MISC, "RapidFireLevel", 18)

	local mR = Instance.new("Frame", miscPage)
	mR.Size = UDim2.new(0.48,0,0,150)
	mR.Position = UDim2.new(0.5,5,0,5)
	mR.BackgroundColor3 = DARK
	mR.BorderSizePixel = 0
	Instance.new("UICorner", mR).CornerRadius = UDim.new(0,8)
	local mrl = Instance.new("UIListLayout", mR)
	mrl.Padding = UDim.new(0,6)
	mrl.SortOrder = Enum.SortOrder.LayoutOrder
	local mrp = Instance.new("UIPadding", mR)
	mrp.PaddingTop = UDim.new(0,8)
	mrp.PaddingLeft = UDim.new(0,5)
	mrp.PaddingRight = UDim.new(0,5)

	mkSection(mR, "Options", 1)
	mkButton(mR, "Heal", healPlayer, 2)

	local playersPage = createPage("Players")

	local plListFrame = Instance.new("Frame", playersPage)
	plListFrame.Size = UDim2.new(0.42,0,1,-10)
	plListFrame.Position = UDim2.new(0,10,0,5)
	plListFrame.BackgroundColor3 = DARK
	plListFrame.BorderSizePixel = 0
	Instance.new("UICorner", plListFrame).CornerRadius = UDim.new(0,8)

	local plListTitle = Instance.new("TextLabel", plListFrame)
	plListTitle.Size = UDim2.new(1,-100,0,25)
	plListTitle.Position = UDim2.new(0,10,0,5)
	plListTitle.BackgroundTransparency = 1
	plListTitle.Text = "Players in Server"
	plListTitle.TextColor3 = Color3.fromRGB(160,160,170)
	plListTitle.Font = Enum.Font.GothamBold
	plListTitle.TextSize = 14
	plListTitle.TextXAlignment = Enum.TextXAlignment.Left

	local plCountLbl = Instance.new("TextLabel", plListFrame)
	plCountLbl.Size = UDim2.new(0,85,0,25)
	plCountLbl.Position = UDim2.new(1,-90,0,5)
	plCountLbl.BackgroundTransparency = 1
	plCountLbl.Text = "0 players"
	plCountLbl.TextColor3 = Color3.fromRGB(150,150,160)
	plCountLbl.Font = Enum.Font.Gotham
	plCountLbl.TextSize = 12
	plCountLbl.TextXAlignment = Enum.TextXAlignment.Right

	local plScroll = Instance.new("ScrollingFrame", plListFrame)
	plScroll.Size = UDim2.new(1,-10,1,-40)
	plScroll.Position = UDim2.new(0,5,0,32)
	plScroll.BackgroundTransparency = 1
	plScroll.ScrollBarThickness = 3
	plScroll.ScrollBarImageColor3 = PURPLE
	plScroll.CanvasSize = UDim2.new(0,0,0,0)
	plScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	plScroll.BorderSizePixel = 0

	local plScrollLayout = Instance.new("UIListLayout", plScroll)
	plScrollLayout.Padding = UDim.new(0,4)
	plScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local plInfoFrame = Instance.new("Frame", playersPage)
	plInfoFrame.Size = UDim2.new(0.55,0,1,-10)
	plInfoFrame.Position = UDim2.new(0.44,5,0,5)
	plInfoFrame.BackgroundColor3 = DARK
	plInfoFrame.BorderSizePixel = 0
	Instance.new("UICorner", plInfoFrame).CornerRadius = UDim.new(0,8)

	local plInfoTitle = Instance.new("TextLabel", plInfoFrame)
	plInfoTitle.Size = UDim2.new(1,-20,0,22)
	plInfoTitle.Position = UDim2.new(0,10,0,8)
	plInfoTitle.BackgroundTransparency = 1
	plInfoTitle.Text = "Selected Player"
	plInfoTitle.TextColor3 = Color3.fromRGB(160,160,170)
	plInfoTitle.Font = Enum.Font.GothamBold
	plInfoTitle.TextSize = 14
	plInfoTitle.TextXAlignment = Enum.TextXAlignment.Left

	local plAvatarFrame = Instance.new("Frame", plInfoFrame)
	plAvatarFrame.Size = UDim2.new(0,60,0,60)
	plAvatarFrame.Position = UDim2.new(0.5,-30,0,35)
	plAvatarFrame.BackgroundColor3 = Color3.fromRGB(50,50,60)
	plAvatarFrame.BorderSizePixel = 0
	Instance.new("UICorner", plAvatarFrame).CornerRadius = UDim.new(1,0)

	local plAvatar = Instance.new("ImageLabel", plAvatarFrame)
	plAvatar.Size = UDim2.new(1,0,1,0)
	plAvatar.BackgroundTransparency = 1
	plAvatar.Image = ""
	plAvatar.ScaleType = Enum.ScaleType.Crop
	Instance.new("UICorner", plAvatar).CornerRadius = UDim.new(1,0)

	local plNameLbl = Instance.new("TextLabel", plInfoFrame)
	plNameLbl.Size = UDim2.new(1,-20,0,18)
	plNameLbl.Position = UDim2.new(0,10,0,100)
	plNameLbl.BackgroundTransparency = 1
	plNameLbl.Text = "No player selected"
	plNameLbl.TextColor3 = Color3.new(1,1,1)
	plNameLbl.Font = Enum.Font.GothamBold
	plNameLbl.TextSize = 14
	plNameLbl.TextXAlignment = Enum.TextXAlignment.Center

	local plUsernameLbl = Instance.new("TextLabel", plInfoFrame)
	plUsernameLbl.Size = UDim2.new(1,-20,0,15)
	plUsernameLbl.Position = UDim2.new(0,10,0,119)
	plUsernameLbl.BackgroundTransparency = 1
	plUsernameLbl.Text = ""
	plUsernameLbl.TextColor3 = Color3.fromRGB(150,150,160)
	plUsernameLbl.Font = Enum.Font.Gotham
	plUsernameLbl.TextSize = 11
	plUsernameLbl.TextXAlignment = Enum.TextXAlignment.Center

	local plIdLbl = Instance.new("TextLabel", plInfoFrame)
	plIdLbl.Size = UDim2.new(0.5,-15,0,15)
	plIdLbl.Position = UDim2.new(0,10,0,136)
	plIdLbl.BackgroundTransparency = 1
	plIdLbl.Text = ""
	plIdLbl.TextColor3 = Color3.fromRGB(150,150,160)
	plIdLbl.Font = Enum.Font.Gotham
	plIdLbl.TextSize = 11
	plIdLbl.TextXAlignment = Enum.TextXAlignment.Center

	local plDistLbl = Instance.new("TextLabel", plInfoFrame)
	plDistLbl.Size = UDim2.new(0.5,-15,0,15)
	plDistLbl.Position = UDim2.new(0.5,5,0,136)
	plDistLbl.BackgroundTransparency = 1
	plDistLbl.Text = ""
	plDistLbl.TextColor3 = Color3.fromRGB(100, 200, 255)
	plDistLbl.Font = Enum.Font.GothamBold
	plDistLbl.TextSize = 11
	plDistLbl.TextXAlignment = Enum.TextXAlignment.Center

	local row1 = Instance.new("Frame", plInfoFrame)
	row1.Size = UDim2.new(1,-20,0,28)
	row1.Position = UDim2.new(0,10,0,160)
	row1.BackgroundTransparency = 1

	local plSpectateBtn = Instance.new("TextButton", row1)
	plSpectateBtn.Size = UDim2.new(0.5,-3,1,0)
	plSpectateBtn.Position = UDim2.new(0,0,0,0)
	plSpectateBtn.BackgroundColor3 = PURPLE
	plSpectateBtn.BorderSizePixel = 0
	plSpectateBtn.Text = "Spectate"
	plSpectateBtn.TextColor3 = Color3.new(1,1,1)
	plSpectateBtn.Font = Enum.Font.GothamBold
	plSpectateBtn.TextSize = 13
	plSpectateBtn.AutoButtonColor = false
	Instance.new("UICorner", plSpectateBtn).CornerRadius = UDim.new(0,6)

	local plUnspectateBtn = Instance.new("TextButton", row1)
	plUnspectateBtn.Size = UDim2.new(0.5,-3,1,0)
	plUnspectateBtn.Position = UDim2.new(0.5,3,0,0)
	plUnspectateBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	plUnspectateBtn.BorderSizePixel = 0
	plUnspectateBtn.Text = "Unspectate"
	plUnspectateBtn.TextColor3 = Color3.new(1,1,1)
	plUnspectateBtn.Font = Enum.Font.GothamBold
	plUnspectateBtn.TextSize = 13
	plUnspectateBtn.AutoButtonColor = false
	Instance.new("UICorner", plUnspectateBtn).CornerRadius = UDim.new(0,6)

	local row2 = Instance.new("Frame", plInfoFrame)
	row2.Size = UDim2.new(1,-20,0,28)
	row2.Position = UDim2.new(0,10,0,193)
	row2.BackgroundTransparency = 1

	local plTeleportBtn = Instance.new("TextButton", row2)
	plTeleportBtn.Size = UDim2.new(0.5,-3,1,0)
	plTeleportBtn.Position = UDim2.new(0,0,0,0)
	plTeleportBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
	plTeleportBtn.BorderSizePixel = 0
	plTeleportBtn.Text = "Teleport"
	plTeleportBtn.TextColor3 = Color3.new(1,1,1)
	plTeleportBtn.Font = Enum.Font.GothamBold
	plTeleportBtn.TextSize = 13
	plTeleportBtn.AutoButtonColor = false
	Instance.new("UICorner", plTeleportBtn).CornerRadius = UDim.new(0,6)

	local plBringBtn = Instance.new("TextButton", row2)
	plBringBtn.Size = UDim2.new(0.5,-3,1,0)
	plBringBtn.Position = UDim2.new(0.5,3,0,0)
	plBringBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 100)
	plBringBtn.BorderSizePixel = 0
	plBringBtn.Text = "Bring"
	plBringBtn.TextColor3 = Color3.new(1,1,1)
	plBringBtn.Font = Enum.Font.GothamBold
	plBringBtn.TextSize = 13
	plBringBtn.AutoButtonColor = false
	Instance.new("UICorner", plBringBtn).CornerRadius = UDim.new(0,6)

	local plSwitchBtn = Instance.new("TextButton", plInfoFrame)
	plSwitchBtn.Size = UDim2.new(1,-20,0,28)
	plSwitchBtn.Position = UDim2.new(0,10,0,226)
	plSwitchBtn.BackgroundColor3 = Color3.fromRGB(220, 150, 50)
	plSwitchBtn.BorderSizePixel = 0
	plSwitchBtn.Text = "Switch Places"
	plSwitchBtn.TextColor3 = Color3.new(1,1,1)
	plSwitchBtn.Font = Enum.Font.GothamBold
	plSwitchBtn.TextSize = 13
	plSwitchBtn.AutoButtonColor = false
	Instance.new("UICorner", plSwitchBtn).CornerRadius = UDim.new(0,6)

	local plStatusLbl = Instance.new("TextLabel", plInfoFrame)
	plStatusLbl.Size = UDim2.new(1,-20,0,20)
	plStatusLbl.Position = UDim2.new(0,10,1,-28)
	plStatusLbl.BackgroundTransparency = 1
	plStatusLbl.Text = ""
	plStatusLbl.TextColor3 = Color3.fromRGB(100, 200, 100)
	plStatusLbl.Font = Enum.Font.GothamBold
	plStatusLbl.TextSize = 12
	plStatusLbl.TextXAlignment = Enum.TextXAlignment.Center

	local selectedPlayer = nil
	local playerButtons = {}

	local function showStatus(text, color, duration)
		plStatusLbl.Text = text
		plStatusLbl.TextColor3 = color or Color3.fromRGB(100, 200, 100)
		if duration then
			task.spawn(function()
				task.wait(duration)
				if plStatusLbl.Text == text then
					plStatusLbl.Text = ""
				end
			end)
		end
	end

	local function getDistanceToPlayer(target)
		if not target or not target.Character then return nil end
		local myChar = player.Character
		if not myChar then return nil end
		local myRoot = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso")
		local targetRoot = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso")
		if not myRoot or not targetRoot then return nil end
		return math.floor((myRoot.Position - targetRoot.Position).Magnitude)
	end

	local function updateSelectedPlayerInfo()
		if selectedPlayer and selectedPlayer.Parent then
			plNameLbl.Text = selectedPlayer.DisplayName or selectedPlayer.Name
			plUsernameLbl.Text = "@" .. selectedPlayer.Name
			plIdLbl.Text = "ID: " .. selectedPlayer.UserId
			local dist = getDistanceToPlayer(selectedPlayer)
			if dist then
				plDistLbl.Text = "Distance: " .. dist .. "m"
			else
				plDistLbl.Text = "Distance: N/A"
			end
			pcall(function()
				local content = Players:GetUserThumbnailAsync(selectedPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
				plAvatar.Image = content
			end)
			if SPECTATE.Active and SPECTATE.Target == selectedPlayer then
				plStatusLbl.Text = "SPECTATING"
				plStatusLbl.TextColor3 = Color3.fromRGB(100, 200, 100)
			end
		else
			plNameLbl.Text = "No player selected"
			plUsernameLbl.Text = ""
			plIdLbl.Text = ""
			plDistLbl.Text = ""
			plAvatar.Image = ""
			plStatusLbl.Text = ""
		end
	end

	task.spawn(function()
		while true do
			task.wait(0.5)
			if selectedPlayer and selectedPlayer.Parent then
				local dist = getDistanceToPlayer(selectedPlayer)
				if dist then
					plDistLbl.Text = "Distance: " .. dist .. "m"
				else
					plDistLbl.Text = "Distance: N/A"
				end
			end
		end
	end)

	local function selectPlayer(plr)
		selectedPlayer = plr
		for p, data in pairs(playerButtons) do
			if p == plr then
				data.btn.BackgroundColor3 = Color3.fromRGB(70, 50, 140)
			else
				data.btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
			end
		end
		updateSelectedPlayerInfo()
	end

	local function createPlayerButton(plr)
		if playerButtons[plr] then return end
		local btn = Instance.new("TextButton", plScroll)
		btn.Size = UDim2.new(1,-6,0,42)
		btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.LayoutOrder = plr.UserId
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

		local avatarFrame = Instance.new("Frame", btn)
		avatarFrame.Size = UDim2.new(0,32,0,32)
		avatarFrame.Position = UDim2.new(0,5,0.5,-16)
		avatarFrame.BackgroundColor3 = Color3.fromRGB(50,50,60)
		avatarFrame.BorderSizePixel = 0
		Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1,0)

		local avatar = Instance.new("ImageLabel", avatarFrame)
		avatar.Size = UDim2.new(1,0,1,0)
		avatar.BackgroundTransparency = 1
		avatar.Image = ""
		avatar.ScaleType = Enum.ScaleType.Crop
		Instance.new("UICorner", avatar).CornerRadius = UDim.new(1,0)

		task.spawn(function()
			pcall(function()
				local content = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				if avatar and avatar.Parent then
					avatar.Image = content
				end
			end)
		end)

		local nameLbl = Instance.new("TextLabel", btn)
		nameLbl.Size = UDim2.new(1,-45,0,18)
		nameLbl.Position = UDim2.new(0,42,0,3)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = plr.DisplayName or plr.Name
		nameLbl.TextColor3 = Color3.new(1,1,1)
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextSize = 13
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

		local userLbl = Instance.new("TextLabel", btn)
		userLbl.Size = UDim2.new(1,-45,0,16)
		userLbl.Position = UDim2.new(0,42,0,21)
		userLbl.BackgroundTransparency = 1
		userLbl.Text = "@" .. plr.Name
		userLbl.TextColor3 = Color3.fromRGB(150,150,160)
		userLbl.Font = Enum.Font.Gotham
		userLbl.TextSize = 11
		userLbl.TextXAlignment = Enum.TextXAlignment.Left
		userLbl.TextTruncate = Enum.TextTruncate.AtEnd

		btn.MouseEnter:Connect(function()
			if selectedPlayer ~= plr then
				btn.BackgroundColor3 = Color3.fromRGB(50,50,65)
			end
		end)
		btn.MouseLeave:Connect(function()
			if selectedPlayer ~= plr then
				btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
			end
		end)

		btn.MouseButton1Click:Connect(function()
			playClick()
			selectPlayer(plr)
		end)

		playerButtons[plr] = {btn = btn}
	end

	local function removePlayerButton(plr)
		if playerButtons[plr] then
			pcall(function() playerButtons[plr].btn:Destroy() end)
			playerButtons[plr] = nil
		end
		if selectedPlayer == plr then
			selectedPlayer = nil
			updateSelectedPlayerInfo()
		end
	end

	local function refreshPlayerList()
		local toRemove = {}
		for plr in pairs(playerButtons) do
			if not plr or not plr.Parent then
				table.insert(toRemove, plr)
			end
		end
		for _, plr in ipairs(toRemove) do
			removePlayerButton(plr)
		end
		local count = 0
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				if not playerButtons[plr] then
					createPlayerButton(plr)
				end
				count = count + 1
			end
		end
		plCountLbl.Text = count .. " player" .. (count == 1 and "" or "s")
	end

	_G.BearHub_refreshPlayerList = refreshPlayerList

	Players.PlayerAdded:Connect(function(plr)
		task.wait(0.5)
		if plr ~= player and plr.Parent then
			pcall(refreshPlayerList)
		end
	end)

	Players.PlayerRemoving:Connect(function(plr)
		removePlayerButton(plr)
		task.wait(0.1)
		pcall(refreshPlayerList)
	end)

	task.spawn(function()
		task.wait(1)
		pcall(refreshPlayerList)
	end)

	task.spawn(function()
		while true do
			task.wait(3)
			pcall(refreshPlayerList)
		end
	end)

	plSpectateBtn.MouseEnter:Connect(function()
		plSpectateBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 220)
	end)
	plSpectateBtn.MouseLeave:Connect(function()
		plSpectateBtn.BackgroundColor3 = PURPLE
	end)
	plSpectateBtn.MouseButton1Click:Connect(function()
		playClick()
		if selectedPlayer and selectedPlayer.Parent then
			startSpectate(selectedPlayer)
			showStatus("SPECTATING", Color3.fromRGB(100, 200, 100))
		else
			showStatus("Select a player first!", Color3.fromRGB(255, 100, 100), 2)
		end
	end)

	plUnspectateBtn.MouseEnter:Connect(function()
		plUnspectateBtn.BackgroundColor3 = Color3.fromRGB(210, 80, 80)
	end)
	plUnspectateBtn.MouseLeave:Connect(function()
		plUnspectateBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	end)
	plUnspectateBtn.MouseButton1Click:Connect(function()
		playClick()
		stopSpectate()
		showStatus("Stopped spectating", Color3.fromRGB(150, 150, 160), 1.5)
	end)

	plTeleportBtn.MouseEnter:Connect(function()
		plTeleportBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 240)
	end)
	plTeleportBtn.MouseLeave:Connect(function()
		plTeleportBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
	end)
	plTeleportBtn.MouseButton1Click:Connect(function()
		playClick()
		if selectedPlayer and selectedPlayer.Parent then
			local ok, msg = teleportTo(selectedPlayer)
			if ok then
				showStatus(msg, Color3.fromRGB(100, 200, 255), 2)
			else
				showStatus(msg or "Teleport failed", Color3.fromRGB(255, 100, 100), 2)
			end
		else
			showStatus("Select a player first!", Color3.fromRGB(255, 100, 100), 2)
		end
	end)

	plBringBtn.MouseEnter:Connect(function()
		plBringBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 120)
	end)
	plBringBtn.MouseLeave:Connect(function()
		plBringBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 100)
	end)
	plBringBtn.MouseButton1Click:Connect(function()
		playClick()
		if selectedPlayer and selectedPlayer.Parent then
			local ok, msg = bringPlayer(selectedPlayer)
			if ok then
				showStatus(msg, Color3.fromRGB(120, 220, 130), 2)
			else
				showStatus(msg or "Bring failed", Color3.fromRGB(255, 100, 100), 2)
			end
		else
			showStatus("Select a player first!", Color3.fromRGB(255, 100, 100), 2)
		end
	end)

	plSwitchBtn.MouseEnter:Connect(function()
		plSwitchBtn.BackgroundColor3 = Color3.fromRGB(240, 170, 70)
	end)
	plSwitchBtn.MouseLeave:Connect(function()
		plSwitchBtn.BackgroundColor3 = Color3.fromRGB(220, 150, 50)
	end)
	plSwitchBtn.MouseButton1Click:Connect(function()
		playClick()
		if selectedPlayer and selectedPlayer.Parent then
			local ok, msg = switchPlaces(selectedPlayer)
			if ok then
				showStatus(msg, Color3.fromRGB(255, 180, 80), 2)
			else
				showStatus(msg or "Switch failed", Color3.fromRGB(255, 100, 100), 2)
			end
		else
			showStatus("Select a player first!", Color3.fromRGB(255, 100, 100), 2)
		end
	end)

	local settingsPage = createPage("Settings")
	local sLbl = Instance.new("TextLabel", settingsPage)
	sLbl.Size = UDim2.new(1,-20,0,40)
	sLbl.Position = UDim2.new(0,10,0,10)
	sLbl.BackgroundTransparency = 1
	sLbl.Text = "Settings - Coming Soon"
	sLbl.TextColor3 = Color3.fromRGB(100,100,110)
	sLbl.Font = Enum.Font.Gotham
	sLbl.TextSize = 16
end

--============================================================
-- BLOK 10: TABS + MINIMIZE/DRAG
--============================================================
local tabsFrame = sidebar:FindFirstChild("TabsFrame")
local tabsData = {{"AimAssistance"},{"Visualization"},{"Miscellaneous"},{"Players"},{"Settings"}}
local selTab = nil

local function switchPage(name)
	for n, p in pairs(_G.BearHub_tabPages) do p.Visible = (n == name) end
	contentTitle.Text = name
	if name == "Players" and _G.BearHub_refreshPlayerList then
		task.spawn(function() pcall(_G.BearHub_refreshPlayerList) end)
	end
end

local function makeTabBtn(name, order)
	local btn = Instance.new("TextButton", tabsFrame)
	btn.Size = UDim2.new(1,0,0,36)
	btn.BackgroundTransparency = 1
	btn.Text = "   " .. name
	btn.TextColor3 = Color3.fromRGB(150,150,160)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.AutoButtonColor = false
	btn.LayoutOrder = order
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
	btn.MouseEnter:Connect(function()
		if selTab ~= btn then btn.BackgroundTransparency = 0.7 end
	end)
	btn.MouseLeave:Connect(function()
		if selTab ~= btn then btn.BackgroundTransparency = 1 end
	end)
	btn.MouseButton1Click:Connect(function()
		playClick()
		if selTab then
			selTab.BackgroundTransparency = 1
			selTab.TextColor3 = Color3.fromRGB(150,150,160)
		end
		selTab = btn
		btn.BackgroundTransparency = 0.5
		btn.TextColor3 = Color3.new(1,1,1)
		switchPage(name)
	end)
	return btn
end

for i, tab in ipairs(tabsData) do
	local b = makeTabBtn(tab[1], i)
	if i == 1 then
		selTab = b
		b.BackgroundTransparency = 0.5
		b.TextColor3 = Color3.new(1,1,1)
		switchPage(tab[1])
	end
end

local ORIGINAL_SIZE = UDim2.new(0, 700, 0, 450)
local BALL_SIZE = UDim2.new(0, 60, 0, 60)

local miniBall = Instance.new("ImageButton", gui)
miniBall.Size = UDim2.new(0,0,0,0)
miniBall.Position = UDim2.new(0,40,0.5,-30)
miniBall.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
miniBall.BorderSizePixel = 0
miniBall.Image = BEAR_ICON
miniBall.ImageColor3 = Color3.new(1, 1, 1)
miniBall.ScaleType = Enum.ScaleType.Fit
miniBall.AutoButtonColor = false
miniBall.Visible = false
miniBall.ClipsDescendants = true
Instance.new("UICorner", miniBall).CornerRadius = UDim.new(1, 0)

local minimized = false
local animating = false
local TW = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function minimize()
	if animating or minimized then return end
	animating = true
	minimized = true
	playClick()
	local ap = main.AbsolutePosition
	local as = main.AbsoluteSize
	local cx = ap.X + as.X/2
	local cy = ap.Y + as.Y/2
	local t = TweenService:Create(main, TW, {
		Size = UDim2.new(0,0,0,0),
		Position = UDim2.new(0, cx, 0, cy),
		BackgroundTransparency = 1,
	})
	t:Play()
	miniBall.Position = UDim2.new(0, cx-30, 0, cy-30)
	miniBall.Size = UDim2.new(0,0,0,0)
	miniBall.Visible = true
	TweenService:Create(miniBall, TW, {Size = BALL_SIZE}):Play()
	t.Completed:Connect(function()
		main.Visible = false
		main.BackgroundTransparency = 0
		animating = false
	end)
end

local function restore()
	if animating or not minimized then return end
	animating = true
	minimized = false
	playClick()
	local ap = miniBall.AbsolutePosition
	local as = miniBall.AbsoluteSize
	local cx = ap.X + as.X/2
	local cy = ap.Y + as.Y/2
	main.Size = UDim2.new(0,0,0,0)
	main.Position = UDim2.new(0, cx, 0, cy)
	main.BackgroundTransparency = 1
	main.Visible = true
	TweenService:Create(main, TW, {
		Size = ORIGINAL_SIZE,
		Position = UDim2.new(0, cx-350, 0, cy-225),
		BackgroundTransparency = 0,
	}):Play()
	local t2 = TweenService:Create(miniBall, TW, {Size = UDim2.new(0,0,0,0)})
	t2:Play()
	t2.Completed:Connect(function()
		miniBall.Visible = false
		miniBall.Size = BALL_SIZE
		animating = false
	end)
end

UIS.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.RightShift then
		if minimized then restore() else minimize() end
	end
end)

local dragging = false
local dragStart = nil
local startPos = nil
local mainDragMoved = false

sidebar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mainDragMoved = false
		dragStart = i.Position
		startPos = main.Position
	end
end)

local ballDrag = false
local ballStart = nil
local ballPos = nil
local ballMoved = false
local lastClickTime = 0

miniBall.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		ballDrag = true
		ballMoved = false
		ballStart = i.Position
		ballPos = miniBall.Position
	end
end)

UIS.InputChanged:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseMovement then
		if dragging and dragStart and startPos then
			local d = inp.Position - dragStart
			if d.Magnitude > 3 then
				if not mainDragMoved then
					mainDragMoved = true
					startDragSound()
				end
			end
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
		if ballDrag and ballStart and ballPos then
			local d = inp.Position - ballStart
			if d.Magnitude > 3 then
				if not ballMoved then
					ballMoved = true
					startDragSound()
				end
			end
			miniBall.Position = UDim2.new(ballPos.X.Scale, ballPos.X.Offset + d.X, ballPos.Y.Scale, ballPos.Y.Offset + d.Y)
		end
		if _G.BearHub_canvasDrag then
			_G.BearHub_updCPValues(inp.Position.X, inp.Position.Y, "canvas")
		end
		if _G.BearHub_hueDrag then
			_G.BearHub_updCPValues(inp.Position.X, inp.Position.Y, "hue")
		end
		for _, s in ipairs(_G.BearHub_allSliders) do
			if s.isDragging() then s.update(inp.Position.X) end
		end
	end
end)

UIS.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		if dragging and mainDragMoved then stopDragSound() end
		dragging = false
		mainDragMoved = false
		_G.BearHub_canvasDrag = false
		_G.BearHub_hueDrag = false
		for _, s in ipairs(_G.BearHub_allSliders) do s.setDrag(false) end
		if ballDrag then
			if ballMoved then stopDragSound() end
			ballDrag = false
			if not ballMoved then
				local now = tick()
				if now - lastClickTime < 0.35 then
					restore()
					lastClickTime = 0
				else
					lastClickTime = now
				end
			end
		end
	end
end)
