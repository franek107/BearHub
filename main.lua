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
	Enabled = true, MaxDistance = 300, ShowLocalPlayer = false, VisibleOnly = false,
	Box = {Enabled=false, Color=Color3.fromRGB(255,255,255)},
	Skeleton = {Enabled=true, Color=Color3.fromRGB(255,255,255)},
	Name = {Enabled=true, Color=Color3.fromRGB(255,255,255)},
	ID = {Enabled=false, Color=Color3.fromRGB(255,255,255)},
	HealthBar = {Enabled=false, Color=Color3.fromRGB(0,255,0)},
	Distance = {Enabled=false, Color=Color3.fromRGB(255,255,255)},
	Snaplines = {Enabled=false, Color=Color3.fromRGB(100,70,200)},
	Inventory = {Enabled=false, Color=Color3.fromRGB(255,200,100)},
	HeadDot = {Enabled=false, Color=Color3.fromRGB(255,0,0)},
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
	SuperPunch = false,
	NoClip = false, NoClipSpeed = 30,
	RapidFire = false, RapidFireMultiplier = 20,
	WalkSpeedEnabled = false, WalkSpeed = 16,
	JumpPowerEnabled = false, JumpPower = 50,
	FreeCam = false, FreeCamSpeed = 30,
	SpinBot = false, SpinBotSpeed = 50,
	RemoveJumpDelay = false,
}

local EXPLOITS = {
	TeleportWalk = false, TeleportWalkDistance = 5,
	ClickTeleport = false, ClickTeleportKeyName = "NONE", ClickTeleportKeyCheck = nil,
	AntiAFK = false,
}

local SPECTATE = {Target = nil, Active = false}
local PANIC_TRIGGERED = false
local mbHeld = {[1]=false,[2]=false,[3]=false,[4]=false,[5]=false}

pcall(function()
	for _, g in ipairs(playerGui:GetChildren()) do
		if g.Name == "BearHub" or g.Name == "BearHub_ESP" or g.Name == "BearHub_FOV" then
			g:Destroy()
		end
	end
end)

local espGui = Instance.new("ScreenGui")
espGui.Name = "BearHub_ESP"; espGui.ResetOnSpawn = false; espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 100; espGui.Parent = playerGui

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "BearHub_FOV"; fovGui.ResetOnSpawn = false; fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 99; fovGui.Parent = playerGui

local gui = Instance.new("ScreenGui")
gui.Name = "BearHub"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999; gui.Parent = playerGui

--============================================================
-- PANIC
--============================================================
local function PANIC_DESTROY()
	if PANIC_TRIGGERED then return end
	PANIC_TRIGGERED = true
	ESP.Enabled = false; TRIGGERBOT.Enabled = false; AIMBOT.Enabled = false
	HITBOX.Enabled = false; HITBOX.Size = 0
	MISC.SemiGod = false; MISC.NoRecoil = false; MISC.NoSpread = false; MISC.InfAmmo = false
	MISC.NoClip = false; MISC.RapidFire = false; MISC.SuperPunch = false
	MISC.WalkSpeedEnabled = false; MISC.JumpPowerEnabled = false; MISC.FreeCam = false
	MISC.SpinBot = false; MISC.RemoveJumpDelay = false
	EXPLOITS.TeleportWalk = false; EXPLOITS.ClickTeleport = false; EXPLOITS.AntiAFK = false
	SPECTATE.Active = false; SPECTATE.Target = nil
	pcall(function()
		local myChar = player.Character
		if myChar then
			local myHum = myChar:FindFirstChildOfClass("Humanoid")
			if myHum then
				Camera.CameraSubject = myHum; myHum.WalkSpeed = 16
				myHum.UseJumpPower = true; myHum.JumpPower = 50
			end
			Camera.CameraType = Enum.CameraType.Custom
			local root = myChar:FindFirstChild("HumanoidRootPart")
			if root then
				for _, v in ipairs(root:GetChildren()) do
					if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyPosition") then v:Destroy() end
				end
			end
			for _, part in ipairs(myChar:GetDescendants()) do
				if part:IsA("BasePart") then pcall(function() part.CanCollide = true end) end
			end
		end
	end)
	pcall(function()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				for _, child in ipairs(plr.Character:GetChildren()) do
					if child.Name:find("BearHub_HL") then child:Destroy() end
				end
			end
		end
	end)
	pcall(function()
		for k in pairs(_G) do
			if type(k) == "string" and k:find("BearHub") then _G[k] = nil end
		end
	end)
	pcall(function() espGui:Destroy() end)
	pcall(function() fovGui:Destroy() end)
	pcall(function() gui:Destroy() end)
	pcall(function()
		for _, g in ipairs(playerGui:GetChildren()) do
			if g.Name == "BearHub" or g.Name == "BearHub_ESP" or g.Name == "BearHub_FOV" then g:Destroy() end
		end
	end)
	pcall(function()
		for _, s in ipairs(SoundService:GetChildren()) do
			if s:IsA("Sound") then s:Stop(); s:Destroy() end
		end
	end)
end

--============================================================
-- HELPERS
--============================================================
do
	local function playSound(id, volume, pitch)
		if PANIC_TRIGGERED then return end
		local s = Instance.new("Sound")
		s.SoundId = id; s.Volume = volume or 0.3; s.PlaybackSpeed = pitch or 1
		s.Parent = SoundService; s:Play()
		s.Ended:Connect(function() s:Destroy() end)
		return s
	end
	_G.BearHub_playClick = function() if not PANIC_TRIGGERED then playSound(CLICK_SOUND_ID, 0.25, 1.2) end end
	_G.BearHub_playSlider = function() if not PANIC_TRIGGERED then playSound(SLIDER_SOUND_ID, 0.15, 1.5) end end
	_G.BearHub_doClick = function()
		if PANIC_TRIGGERED then return false end
		local ok = false
		pcall(function()
			VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
			task.wait()
			VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
			ok = true
		end)
		if not ok then pcall(function() if mouse1click then mouse1click(); ok = true end end) end
		if not ok then pcall(function() if mouse1press and mouse1release then mouse1press(); task.wait(0.02); mouse1release(); ok = true end end) end
		return ok
	end
	local dragSoundObj, dragSoundPlaying = nil, false
	_G.BearHub_startDragSound = function()
		if PANIC_TRIGGERED or dragSoundPlaying then return end
		dragSoundPlaying = true
		dragSoundObj = Instance.new("Sound")
		dragSoundObj.SoundId = DRAG_SOUND_ID; dragSoundObj.Volume = 0.12
		dragSoundObj.PlaybackSpeed = 0.8; dragSoundObj.Looped = true
		dragSoundObj.Parent = SoundService; dragSoundObj:Play()
	end
	_G.BearHub_stopDragSound = function()
		if not dragSoundPlaying then return end
		dragSoundPlaying = false
		if dragSoundObj then dragSoundObj:Stop(); dragSoundObj:Destroy(); dragSoundObj = nil end
	end
end

local playClick = _G.BearHub_playClick
local playSlider = _G.BearHub_playSlider
local doClick = _G.BearHub_doClick
local startDragSound = _G.BearHub_startDragSound
local stopDragSound = _G.BearHub_stopDragSound

--============================================================
-- SPECTATE + TELEPORT/BRING/SWITCH
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
					p.Velocity = Vector3.zero
					p.AssemblyLinearVelocity = Vector3.zero
					p.AssemblyAngularVelocity = Vector3.zero
				end)
			end
		end
	end
	local function startSpectate(target)
		if PANIC_TRIGGERED or not target or not target.Character then return end
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
		SPECTATE.Target = nil; SPECTATE.Active = false
		local myChar = player.Character
		if myChar then
			local myHum = myChar:FindFirstChildOfClass("Humanoid")
			if myHum then pcall(function() Camera.CameraSubject = myHum end) end
		end
	end
	_G.BearHub_startSpectate = startSpectate
	_G.BearHub_stopSpectate = stopSpectate

	_G.BearHub_teleportTo = function(target)
		if PANIC_TRIGGERED then return false, "Disabled" end
		if not target or not target.Character then return false, "Player has no character" end
		local myChar = player.Character; if not myChar then return false, "You have no character" end
		local myRoot = getRoot(myChar); if not myRoot then return false, "You have no root part" end
		local targetRoot = getRoot(target.Character); if not targetRoot then return false, "Target has no root part" end
		task.spawn(function()
			local startTime = tick()
			while tick() - startTime < 0.5 do
				if PANIC_TRIGGERED or not myChar.Parent or not myRoot.Parent or not target.Character then break end
				local currentTargetRoot = getRoot(target.Character)
				if currentTargetRoot then
					pcall(function()
						myRoot.CFrame = currentTargetRoot.CFrame + Vector3.new(0, 3, 0)
						zeroVelocity(myChar)
					end)
				end
				RunService.Heartbeat:Wait()
			end
		end)
		return true, "Teleported to " .. (target.DisplayName or target.Name)
	end

	_G.BearHub_bringPlayer = function(target)
		if PANIC_TRIGGERED then return false, "Disabled" end
		if not target or not target.Character then return false, "Player has no character" end
		local myChar = player.Character; if not myChar then return false, "You have no character" end
		local myRoot = getRoot(myChar); if not myRoot then return false, "You have no root part" end
		task.spawn(function()
			for i = 1, 5 do
				if PANIC_TRIGGERED or not target.Character then break end
				local currentRoot = getRoot(target.Character)
				local myCurrentRoot = getRoot(myChar)
				if currentRoot and myCurrentRoot then
					pcall(function()
						local dest = myCurrentRoot.CFrame * CFrame.new(0, 0, -3) + Vector3.new(0, 2, 0)
						currentRoot.CFrame = dest
						zeroVelocity(target.Character)
					end)
				end
				task.wait(0.05)
			end
		end)
		return true, "Brought " .. (target.DisplayName or target.Name)
	end

	_G.BearHub_switchPlaces = function(target)
		if PANIC_TRIGGERED then return false, "Disabled" end
		if not target or not target.Character then return false, "Player has no character" end
		local myChar = player.Character; if not myChar then return false, "You have no character" end
		local myRoot = getRoot(myChar); if not myRoot then return false, "You have no root part" end
		local targetRoot = getRoot(target.Character); if not targetRoot then return false, "Target has no root part" end
		task.spawn(function()
			local myOrig = myRoot.CFrame; local targetOrig = targetRoot.CFrame
			local startTime = tick()
			while tick() - startTime < 0.5 do
				if PANIC_TRIGGERED or not myChar.Parent or not target.Character then break end
				local ctr = getRoot(target.Character)
				if ctr then
					pcall(function()
						myRoot.CFrame = targetOrig + Vector3.new(0, 2, 0)
						zeroVelocity(myChar)
						ctr.CFrame = myOrig + Vector3.new(0, 2, 0)
						zeroVelocity(target.Character)
					end)
				end
				RunService.Heartbeat:Wait()
			end
		end)
		return true, "Switched with " .. (target.DisplayName or target.Name)
	end

	task.spawn(function()
		while true do
			task.wait(0.5); if PANIC_TRIGGERED then break end
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
	Players.PlayerRemoving:Connect(function(p) if SPECTATE.Target == p then stopSpectate() end end)
end

local startSpectate = _G.BearHub_startSpectate
local stopSpectate = _G.BearHub_stopSpectate
local teleportTo = _G.BearHub_teleportTo
local bringPlayer = _G.BearHub_bringPlayer
local switchPlaces = _G.BearHub_switchPlaces

--============================================================
-- MOUSE INPUT
--============================================================
UIS.InputBegan:Connect(function(inp, gameProcessed)
	if PANIC_TRIGGERED or gameProcessed then return end
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
-- ESP + FOV
--============================================================
do
	local fovCircle = Instance.new("Frame")
	fovCircle.BackgroundTransparency = 1; fovCircle.BorderSizePixel = 0
	fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Visible = false; fovCircle.Parent = fovGui
	local fovStroke = Instance.new("UIStroke", fovCircle)
	fovStroke.Color = PURPLE; fovStroke.Thickness = 1.5; fovStroke.Transparency = 0.3
	Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

	local fovCircleAim = Instance.new("Frame")
	fovCircleAim.BackgroundTransparency = 1; fovCircleAim.BorderSizePixel = 0
	fovCircleAim.AnchorPoint = Vector2.new(0.5, 0.5); fovCircleAim.Visible = false; fovCircleAim.Parent = fovGui
	local fovStrokeAim = Instance.new("UIStroke", fovCircleAim)
	fovStrokeAim.Color = PURPLE; fovStrokeAim.Thickness = 1.5; fovStrokeAim.Transparency = 0.3
	Instance.new("UICorner", fovCircleAim).CornerRadius = UDim.new(1, 0)

	local function updateFOVCircle()
		if PANIC_TRIGGERED then return end
		if TRIGGERBOT.ShowFOV and TRIGGERBOT.Enabled then
			local r = TRIGGERBOT.FOV * FOV_SCALE_TRIGGER
			fovCircle.Size = UDim2.new(0, r*2, 0, r*2)
			fovCircle.Position = UDim2.new(0, Camera.ViewportSize.X/2, 0, Camera.ViewportSize.Y/2)
			fovStroke.Color = TRIGGERBOT.FOVColor; fovCircle.Visible = true
		else fovCircle.Visible = false end
		if AIMBOT.DrawFOV and AIMBOT.Enabled then
			local r = AIMBOT.FOV * FOV_SCALE_AIMBOT
			fovCircleAim.Size = UDim2.new(0, r*2, 0, r*2)
			fovCircleAim.Position = UDim2.new(0, Camera.ViewportSize.X/2, 0, Camera.ViewportSize.Y/2)
			fovStrokeAim.Color = AIMBOT.FOVColor; fovCircleAim.Visible = true
		else fovCircleAim.Visible = false end
	end

	local espObjects = {}

	local function makeLine(parent)
		local f = Instance.new("Frame", parent)
		f.BackgroundColor3 = Color3.new(1,1,1); f.BorderSizePixel = 0
		f.AnchorPoint = Vector2.new(0.5, 0.5); f.Visible = false; return f
	end
	local function makeText(parent, sz)
		local t = Instance.new("TextLabel", parent)
		t.BackgroundTransparency = 1; t.Font = Enum.Font.GothamBold; t.TextSize = sz or 14
		t.TextColor3 = Color3.new(1,1,1); t.TextStrokeTransparency = 0
		t.TextStrokeColor3 = Color3.new(0,0,0); t.AnchorPoint = Vector2.new(0.5, 0.5)
		t.Size = UDim2.new(0, 200, 0, 20); t.Visible = false; return t
	end
	local function drawLine(f, p1, p2, th)
		local dx = p2.X - p1.X; local dy = p2.Y - p1.Y
		local len = math.sqrt(dx*dx + dy*dy)
		f.Position = UDim2.new(0, (p1.X+p2.X)/2, 0, (p1.Y+p2.Y)/2)
		f.Size = UDim2.new(0, len, 0, th or 1)
		f.Rotation = math.deg(math.atan2(dy, dx))
	end

	local function createESPData(plr)
		local h = Instance.new("Folder", espGui); h.Name = plr.Name
		local d = {
			holder=h, boxTop=makeLine(h), boxBot=makeLine(h),
			boxLeft=makeLine(h), boxRight=makeLine(h), skeleton={},
			snapline=makeLine(h), healthBg=makeLine(h), healthFill=makeLine(h),
			name=makeText(h, 14), id=makeText(h, 12),
			distance=makeText(h, 12), inventory=makeText(h, 11),
			inventory2=makeText(h, 11)
		}
		for i = 1, 12 do d.skeleton[i] = makeLine(h) end

		-- HEAD DOT
		local headDot = Instance.new("Frame", h)
		headDot.Size = UDim2.new(0, 8, 0, 8)
		headDot.AnchorPoint = Vector2.new(0.5, 0.5)
		headDot.BackgroundColor3 = ESP.HeadDot.Color
		headDot.BorderSizePixel = 0
		headDot.Visible = false
		Instance.new("UICorner", headDot).CornerRadius = UDim.new(1, 0)
		headDot.ZIndex = 5
		d.headDot = headDot

		espObjects[plr] = d; return d
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
	local function fullRefresh() for plr in pairs(espObjects) do clearESP(plr) end end
	_G.BearHub_fullRefresh = fullRefresh

	local function w2s(pos)
		local ok, v = pcall(function() return Camera:WorldToViewportPoint(pos) end)
		if ok and v then return Vector2.new(v.X, v.Y), v.Z > 0, v.Z end
		return Vector2.new(0,0), false, -1
	end
	local function getPos(char, name)
		local p = char:FindFirstChild(name)
		if p and p:IsA("BasePart") then return p.Position end; return nil
	end
	local function visCheck(tp, tc)
		local mc = player.Character; if not mc then return false end
		local mh = mc:FindFirstChild("Head") or mc:FindFirstChild("HumanoidRootPart"); if not mh then return false end
		local par = RaycastParams.new()
		par.FilterDescendantsInstances = {mc, tc}; par.FilterType = Enum.RaycastFilterType.Exclude
		local ok, r = pcall(function() return workspace:Raycast(mh.Position, tp - mh.Position, par) end)
		return ok and r == nil
	end
	_G.BearHub_getPos = getPos; _G.BearHub_visCheck = visCheck

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
	local invCache, invCacheTick = {}, {}
	local function getCachedInv(plr)
		local now = tick()
		if invCache[plr] and invCacheTick[plr] and (now - invCacheTick[plr]) < 1 then return invCache[plr] end
		local items = {}
		local seen = {}
		if plr.Character then
			for _, c in ipairs(plr.Character:GetChildren()) do
				if c:IsA("Tool") and not seen[c.Name] then
					seen[c.Name] = true
					table.insert(items, c.Name)
				end
			end
		end
		local bp = plr:FindFirstChildOfClass("Backpack")
		if bp then
			for _, c in ipairs(bp:GetChildren()) do
				if c:IsA("Tool") and not seen[c.Name] then
					seen[c.Name] = true
					table.insert(items, c.Name)
				end
			end
		end
		invCache[plr] = items; invCacheTick[plr] = now; return items
	end

	local function updateESP()
		if PANIC_TRIGGERED then return end
		Camera = workspace.CurrentCamera; if not Camera then return end
		local cur = {}; for _, p in ipairs(Players:GetPlayers()) do cur[p] = true end
		for plr in pairs(espObjects) do if not cur[plr] then clearESP(plr) end end
		for plr in pairs(invCache) do if not cur[plr] then invCache[plr] = nil; invCacheTick[plr] = nil end end
		if not ESP.Enabled then for _, d in pairs(espObjects) do hideAll(d) end; return end
		for _, plr in ipairs(Players:GetPlayers()) do
			local d = espObjects[plr]; local skip = false
			if plr == player and not ESP.ShowLocalPlayer then if d then hideAll(d) end; skip = true end
			if not skip then
				local char = plr.Character
				if not char or not char.Parent then if d then hideAll(d) end; skip = true end
				if not skip then
					local hum = char:FindFirstChildOfClass("Humanoid")
					local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
					local head = char:FindFirstChild("Head")
					if not hum or not root or not head or hum.Health <= 0 then if d then hideAll(d) end; skip = true end
					if not skip then
						local myChar = player.Character
						local mr = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
						local dist = mr and (mr.Position - root.Position).Magnitude or (Camera.CFrame.Position - root.Position).Magnitude
						if dist > ESP.MaxDistance then if d then hideAll(d) end; skip = true end
						if not skip then
							local sp, on, dep = w2s(root.Position)
							if not on or dep <= 0 then if d then hideAll(d) end; skip = true end
							if not skip then
								if ESP.VisibleOnly and plr ~= player then
									if not visCheck(root.Position, char) then if d then hideAll(d) end; skip = true end
								end
								if not skip then
									if not d then d = createESPData(plr) end
									local hp2 = w2s(head.Position + Vector3.new(0, 0.5, 0))
									local lp = w2s(root.Position - Vector3.new(0, 3, 0))
									local bH = math.clamp(math.abs(lp.Y - hp2.Y), 20, 800)
									local bW = bH * 0.55
									local tY, bY = hp2.Y, lp.Y
									local lX, rX = sp.X - bW/2, sp.X + bW/2
									if ESP.Box.Enabled then
										drawLine(d.boxTop, Vector2.new(lX,tY), Vector2.new(rX,tY), 1)
										drawLine(d.boxBot, Vector2.new(lX,bY), Vector2.new(rX,bY), 1)
										drawLine(d.boxLeft, Vector2.new(lX,tY), Vector2.new(lX,bY), 1)
										drawLine(d.boxRight, Vector2.new(rX,tY), Vector2.new(rX,bY), 1)
										for _, f in pairs({d.boxTop,d.boxBot,d.boxLeft,d.boxRight}) do
											f.BackgroundColor3 = ESP.Box.Color; f.Visible = true
										end
									else
										for _, f in pairs({d.boxTop,d.boxBot,d.boxLeft,d.boxRight}) do f.Visible = false end
									end
									local bo = 0
									if ESP.Name.Enabled then d.name.Text = plr.DisplayName or plr.Name; d.name.Position = UDim2.new(0, sp.X, 0, tY - 15); d.name.TextColor3 = ESP.Name.Color; d.name.Visible = true else d.name.Visible = false end
									if ESP.ID.Enabled then d.id.Text = "ID: " .. plr.UserId; d.id.Position = UDim2.new(0, sp.X, 0, tY - (ESP.Name.Enabled and 30 or 15)); d.id.TextColor3 = ESP.ID.Color; d.id.Visible = true else d.id.Visible = false end
									if ESP.Distance.Enabled then d.distance.Text = math.floor(dist) .. "m"; d.distance.Position = UDim2.new(0, sp.X, 0, bY + 12 + bo); d.distance.TextColor3 = ESP.Distance.Color; d.distance.Visible = true; bo = bo + 16 else d.distance.Visible = false end
									if ESP.Inventory.Enabled then
										local items = getCachedInv(plr)
										if #items > 0 then
											local row1 = {}
											local row2 = {}
											for i, name in ipairs(items) do
												if i > 10 then break end
												if i <= 5 then table.insert(row1, name) else table.insert(row2, name) end
											end
											local t1 = "[" .. table.concat(row1, ", ") .. "]"
											d.inventory.Text = t1; d.inventory.TextColor3 = ESP.Inventory.Color
											d.inventory.Position = UDim2.new(0, sp.X, 0, bY + 12 + bo)
											d.inventory.Size = UDim2.new(0, 400, 0, 20); d.inventory.Visible = true; bo = bo + 16
											if #row2 > 0 then
												local t2 = "[" .. table.concat(row2, ", ") .. "]"
												d.inventory2.Text = t2; d.inventory2.TextColor3 = ESP.Inventory.Color
												d.inventory2.Position = UDim2.new(0, sp.X, 0, bY + 12 + bo)
												d.inventory2.Size = UDim2.new(0, 400, 0, 20); d.inventory2.Visible = true; bo = bo + 16
											else d.inventory2.Visible = false end
										else
											d.inventory.Text = "[Empty]"; d.inventory.TextColor3 = Color3.fromRGB(120, 120, 130)
											d.inventory.Position = UDim2.new(0, sp.X, 0, bY + 12 + bo)
											d.inventory.Size = UDim2.new(0, 300, 0, 20); d.inventory.Visible = true
											d.inventory2.Visible = false; bo = bo + 16
										end
									else d.inventory.Visible = false; d.inventory2.Visible = false end
									if ESP.HealthBar.Enabled then
										local bx = lX - 6
										local hp3 = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
										local ft = bY - (bY - tY) * hp3
										drawLine(d.healthBg, Vector2.new(bx,tY), Vector2.new(bx,bY), 4)
										d.healthBg.BackgroundColor3 = Color3.fromRGB(40,40,40); d.healthBg.Visible = true
										drawLine(d.healthFill, Vector2.new(bx,ft), Vector2.new(bx,bY), 3)
										d.healthFill.BackgroundColor3 = Color3.fromRGB(math.floor(255*(1-hp3)), math.floor(255*hp3), 0)
										d.healthFill.Visible = true
									else d.healthBg.Visible = false; d.healthFill.Visible = false end
									if ESP.Snaplines.Enabled then
										drawLine(d.snapline, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y), Vector2.new(sp.X, bY), 1)
										d.snapline.BackgroundColor3 = ESP.Snaplines.Color; d.snapline.Visible = true
									else d.snapline.Visible = false end
									if ESP.Skeleton.Enabled then
										local bones = char:FindFirstChild("UpperTorso") and R15 or R6
										for i = 1, 12 do
											if d.skeleton[i] then
												if i <= #bones then
													local a = getPos(char, bones[i][1]); local b = getPos(char, bones[i][2])
													if a and b then
														local s1, o1, d1 = w2s(a); local s2, o2, d2 = w2s(b)
														if o1 and o2 and d1 > 0 and d2 > 0 then
															drawLine(d.skeleton[i], s1, s2, 2)
															d.skeleton[i].BackgroundColor3 = ESP.Skeleton.Color
															d.skeleton[i].Visible = true
														else d.skeleton[i].Visible = false end
													else d.skeleton[i].Visible = false end
												else d.skeleton[i].Visible = false end
											end
										end
									else for i = 1, 12 do if d.skeleton[i] then d.skeleton[i].Visible = false end end end

									-- HEAD DOT
									if ESP.HeadDot.Enabled then
										local headPos, onScreen, depth = w2s(head.Position)
										if onScreen and headPos and depth > 0 then
											d.headDot.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
											d.headDot.BackgroundColor3 = ESP.HeadDot.Color
											d.headDot.Visible = true
										else
											d.headDot.Visible = false
										end
									else
										d.headDot.Visible = false
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
		if PANIC_TRIGGERED then return end; pcall(updateESP); pcall(updateFOVCircle)
	end)
	task.spawn(function() while true do task.wait(5); if PANIC_TRIGGERED then break end; pcall(fullRefresh) end end)
	player.CharacterAdded:Connect(function() task.wait(0.5); if not PANIC_TRIGGERED then pcall(fullRefresh) end end)
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		Camera = workspace.CurrentCamera; if not PANIC_TRIGGERED then pcall(fullRefresh) end
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
-- TRIGGERBOT + AIMBOT + HITBOX (NAPRAWIONY)
--============================================================
do
	local lastShot = 0
	local function getTriggerTarget()
		if not TRIGGERBOT.Enabled or PANIC_TRIGGERED then return nil end
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
						local dc = true
						if TRIGGERBOT.ExcludeDead and hum.Health <= 0 then dc = false end
						if dc then
							local mc = player.Character
							local mr = mc and (mc:FindFirstChild("HumanoidRootPart") or mc:FindFirstChild("Torso"))
							if mr and (mr.Position - root.Position).Magnitude > TRIGGERBOT.MaxDistance then dc = false end
						end
						if dc and TRIGGERBOT.VisibleOnly then
							if not visCheck(root.Position, char) then dc = false end
						end
						if dc then
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
			task.wait(0.05); if PANIC_TRIGGERED then break end
			if TRIGGERBOT.Enabled and TRIGGERBOT.KeybindCheck and TRIGGERBOT.KeybindCheck() then
				local now = tick()
				if now - lastShot >= (TRIGGERBOT.ShotDelay / 1000 + 0.05) then
					local t = getTriggerTarget()
					if t then lastShot = now; pcall(doClick) end
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
		if not AIMBOT.Enabled or PANIC_TRIGGERED then return nil end
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
						local dc = true
						if AIMBOT.ExcludeDead and hum.Health <= 0 then dc = false end
						if dc then
							local mc = player.Character
							local mr = mc and (mc:FindFirstChild("HumanoidRootPart") or mc:FindFirstChild("Torso"))
							if mr and (mr.Position - root.Position).Magnitude > AIMBOT.MaxDistance then dc = false end
						end
						if dc then
							local bonePos = getBonePosition(char, AIMBOT.Bone)
							if bonePos then
								if AIMBOT.VisibleCheck and not visCheck(bonePos, char) then dc = false end
								if dc then
									local ok, sp, on, d2 = pcall(function()
										local vec = Camera:WorldToViewportPoint(bonePos)
										return Vector2.new(vec.X, vec.Y), vec.Z > 0, vec.Z
									end)
									if ok and on and d2 and d2 > 0 then
										local sd = (sp - vc).Magnitude
										if sd <= fr and sd < bestD then
											best = plr; bestD = sd; bestPos = bonePos
										end
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
		if PANIC_TRIGGERED then return end
		if AIMBOT.Enabled and AIMBOT.KeybindCheck and AIMBOT.KeybindCheck() then
			local target, targetPos = getAimbotTarget()
			if target and targetPos then
				pcall(function()
					local camPos = Camera.CFrame.Position
					local cl = Camera.CFrame.LookVector
					local dl = (targetPos - camPos).Unit
					local ax = math.clamp(AIMBOT.SmoothX, 1, 100) / 100
					local ay = math.clamp(AIMBOT.SmoothY, 1, 100) / 100
					local nl = Vector3.new(
						cl.X + (dl.X - cl.X) * ax,
						cl.Y + (dl.Y - cl.Y) * ay,
						cl.Z + (dl.Z - cl.Z) * ax
					).Unit
					Camera.CFrame = CFrame.new(camPos, camPos + nl)
				end)
			end
		end
	end)

	-- 🔥 Nowy, naprawiony system powiększania hitboxów
	local originalSizes = {}   -- tabela [part] = {Size/Scale, ...}
	local hitHL = {}

	local HBM = {
		Head={R15={"Head"},R6={"Head"}},
		Torso={R15={"UpperTorso","LowerTorso"},R6={"Torso"}},
		Legs={R15={"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"},R6={"Left Leg","Right Leg"}}
	}
	local function getHBParts(c)
		local is15 = c:FindFirstChild("UpperTorso") ~= nil
		local rig = is15 and "R15" or "R6"
		local names = HBM[HITBOX.Bone] and HBM[HITBOX.Bone][rig] or {"Head"}
		local parts = {}
		for _, n in ipairs(names) do
			local p = c:FindFirstChild(n)
			if p and p:IsA("BasePart") then table.insert(parts, p) end
		end
		return parts
	end

	local function saveOriginal(p)
		if not originalSizes[p] then
			if p:IsA("MeshPart") then
				originalSizes[p] = {type="MeshPart", scale=p.Scale}
			else
				originalSizes[p] = {type="Part", size=p.Size}
			end
		end
	end

	local function restoreOriginal(p)
		local data = originalSizes[p]
		if not data then return end
		pcall(function()
			if data.type == "MeshPart" then
				p.Scale = data.scale
			else
				p.Size = data.size
			end
		end)
		originalSizes[p] = nil
	end

	local function expandP(p)
		if not p or not p.Parent then return end
		local sc = 1 + (HITBOX.Size * 0.15)
		saveOriginal(p)
		if p:IsA("MeshPart") then
			pcall(function()
				local original = originalSizes[p].scale
				p.Scale = original * sc
			end)
		else
			pcall(function()
				local original = originalSizes[p].size
				p.Size = original * sc
			end)
		end
		-- znacznik wizualny (kula)
		if not hitHL[p] or not hitHL[p].Parent then
			local c = p.Parent
			if c then
				local hn = "BearHub_HL" .. p.Name
				local ex = c:FindFirstChild(hn); if ex then ex:Destroy() end
				local s = Instance.new("SelectionSphere")
				s.Name = hn; s.Adornee = p
				s.Color3 = Color3.fromRGB(255,60,60); s.SurfaceColor3 = Color3.fromRGB(255,60,60)
				s.SurfaceTransparency = 0.7; s.Transparency = 0.5; s.Parent = c
				hitHL[p] = s
			end
		end
	end

	local function restoreP(p)
		restoreOriginal(p)
		if hitHL[p] then
			pcall(function() hitHL[p]:Destroy() end)
			hitHL[p] = nil
		end
	end

	local function restoreAllC(c)
		if not c then return end
		for _, p in ipairs(c:GetChildren()) do
			if p:IsA("BasePart") then restoreP(p) end
		end
		for _, ch in ipairs(c:GetChildren()) do
			if ch.Name:find("BearHub_HL") then pcall(function() ch:Destroy() end) end
		end
	end

	local function cleanDead()
		local tr = {}
		for p in pairs(originalSizes) do
			if not p or not p.Parent then table.insert(tr, p) end
		end
		for _, p in ipairs(tr) do originalSizes[p] = nil end
		local tr2 = {}
		for p in pairs(hitHL) do
			if not p or not p.Parent then table.insert(tr2, p) end
		end
		for _, p in ipairs(tr2) do hitHL[p] = nil end
	end

	local lastHBB, lastHBE = "Head", false
	RunService.Heartbeat:Connect(function()
		if PANIC_TRIGGERED then return end
		local bc = (lastHBB ~= HITBOX.Bone); local ec = (lastHBE ~= HITBOX.Enabled)
		lastHBB = HITBOX.Bone; lastHBE = HITBOX.Enabled
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local c = plr.Character
				if c then
					if HITBOX.Enabled and HITBOX.Size > 0 then
						if bc then restoreAllC(c) end
						local tp = getHBParts(c)
						local ts = {}
						for _, p in ipairs(tp) do ts[p] = true end
						-- przywracaj te, które nie powinny być powiększone
						for _, p in ipairs(c:GetChildren()) do
							if p:IsA("BasePart") and originalSizes[p] and not ts[p] then
								restoreP(p)
							end
						end
						-- powiększ potrzebne
						for _, p in ipairs(tp) do pcall(function() expandP(p) end) end
					else
						if ec then restoreAllC(c) end
					end
				end
			end
		end
		cleanDead()
	end)

	Players.PlayerAdded:Connect(function(p)
		p.CharacterAdded:Connect(function() task.wait(1); cleanDead() end)
		p.CharacterRemoving:Connect(function() if p.Character then restoreAllC(p.Character) end end)
	end)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			p.CharacterAdded:Connect(function() task.wait(1); cleanDead() end)
			p.CharacterRemoving:Connect(function() if p.Character then restoreAllC(p.Character) end end)
		end
	end
end

--============================================================
-- MISC
--============================================================
do
	task.spawn(function()
		while true do
			task.wait(0.1); if PANIC_TRIGGERED then break end
			if MISC.SemiGod then
				local c = player.Character
				if c then
					local h = c:FindFirstChildOfClass("Humanoid")
					if h and h.Health > 0 then pcall(function() h.MaxHealth = math.huge; h.Health = math.huge end) end
				end
			end
		end
	end)
	local function hookHum(c)
		if not c then return end
		local h = c:FindFirstChildOfClass("Humanoid"); if not h then return end
		h.HealthChanged:Connect(function()
			if MISC.SemiGod and not PANIC_TRIGGERED then
				pcall(function() h.MaxHealth = math.huge; h.Health = math.huge end)
			end
		end)
	end
	if player.Character then hookHum(player.Character) end
	player.CharacterAdded:Connect(function(c) task.wait(0.5); hookHum(c) end)

	_G.BearHub_healPlayer = function()
		if PANIC_TRIGGERED then return end
		local c = player.Character; if not c then return end
		local h = c:FindFirstChildOfClass("Humanoid")
		if h then pcall(function() h.Health = h.MaxHealth end) end
	end

	_G.BearHub_copyItem = function()
		if PANIC_TRIGGERED then return false, "Disabled" end
		local char = player.Character
		if not char then return false, "No character" end
		local equippedTool = nil
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Tool") then equippedTool = child; break end
		end
		if not equippedTool then return false, "No tool equipped" end
		local success, err = pcall(function()
			local clone = equippedTool:Clone()
			if clone then
				local backpack = player:FindFirstChildOfClass("Backpack")
				if backpack then clone.Parent = backpack else clone.Parent = char end
			end
		end)
		if success then return true, "Copied: " .. equippedTool.Name
		else return false, "Failed to copy: " .. tostring(err) end
	end

	local lastWSEnabled, lastJPEnabled = false, false
	task.spawn(function()
		while true do
			task.wait(0.1); if PANIC_TRIGGERED then break end
			local c = player.Character
			if c then
				local h = c:FindFirstChildOfClass("Humanoid")
				if h then
					if MISC.WalkSpeedEnabled then
						pcall(function() h.WalkSpeed = MISC.WalkSpeed end)
					elseif lastWSEnabled then
						pcall(function() h.WalkSpeed = 16 end)
					end
					lastWSEnabled = MISC.WalkSpeedEnabled
					if MISC.JumpPowerEnabled then
						pcall(function() h.UseJumpPower = true; h.JumpPower = MISC.JumpPower end)
					elseif lastJPEnabled then
						pcall(function() h.UseJumpPower = true; h.JumpPower = 50 end)
					end
					lastJPEnabled = MISC.JumpPowerEnabled
				end
			end
		end
	end)
	player.CharacterAdded:Connect(function() task.wait(0.5); lastWSEnabled = false; lastJPEnabled = false end)

	-- 🌀 SpinBot
	task.spawn(function()
		while true do
			RunService.RenderStepped:Wait()
			if PANIC_TRIGGERED then break end
			if MISC.SpinBot then
				local char = player.Character
				if char then
					local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
					if root then
						local speed = MISC.SpinBotSpeed or 50
						root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(speed * 0.5), 0)
					end
				end
			end
		end
	end)

	-- 🔥 Remove Jump Delay
	task.spawn(function()
		while true do
			RunService.RenderStepped:Wait()
			if PANIC_TRIGGERED then break end
			if MISC.RemoveJumpDelay then
				local char = player.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum and UIS:IsKeyDown(Enum.KeyCode.Space) then
						hum.Jump = true
					end
				end
			end
		end
	end)

	local flyBV, flyBG, flying = nil, nil, false
	local function stopFly()
		flying = false
		if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
		if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
	end
	local function startFly()
		local c = player.Character; if not c then return end
		local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"); if not r then return end
		stopFly(); flying = true
		flyBV = Instance.new("BodyVelocity")
		flyBV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		flyBV.Velocity = Vector3.zero; flyBV.Parent = r
		flyBG = Instance.new("BodyGyro")
		flyBG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
		flyBG.P = 9000; flyBG.D = 500; flyBG.Parent = r
		task.spawn(function()
			while flying and MISC.NoClip and not PANIC_TRIGGERED do
				RunService.RenderStepped:Wait()
				if not c.Parent then break end
				local cr = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"); if not cr then break end
				local spd = MISC.NoClipSpeed or 30
				local fw, rt, up = 0, 0, 0
				if UIS:IsKeyDown(Enum.KeyCode.W) then fw = fw + 1 end
				if UIS:IsKeyDown(Enum.KeyCode.S) then fw = fw - 1 end
				if UIS:IsKeyDown(Enum.KeyCode.A) then rt = rt - 1 end
				if UIS:IsKeyDown(Enum.KeyCode.D) then rt = rt + 1 end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then up = up + 1 end
				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then up = up - 1 end
				local cc = Camera.CFrame
				local mv = (cc.LookVector * fw + cc.RightVector * rt + Vector3.new(0, up, 0))
				if mv.Magnitude > 0 then mv = mv.Unit * spd end
				pcall(function()
					if flyBV and flyBV.Parent then flyBV.Velocity = mv end
					if flyBG and flyBG.Parent then flyBG.CFrame = cc end
				end)
			end
			stopFly()
		end)
	end
	RunService.Stepped:Connect(function()
		if PANIC_TRIGGERED then return end
		if MISC.NoClip then
			local c = player.Character
			if c then
				for _, p in ipairs(c:GetDescendants()) do
					if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
				end
				if not flying then startFly() end
			end
		else
			if flying then
				stopFly()
				local c = player.Character
				if c then
					for _, p in ipairs(c:GetDescendants()) do
						if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
							pcall(function() p.CanCollide = true end)
						end
					end
				end
			end
		end
	end)
	player.CharacterAdded:Connect(function() task.wait(0.5); stopFly() end)

	-- 🔥 NAPRAWIONY Rapid Fire (przytrzymanie LMB = automatyczne strzały)
	local hookedTools = {}
	local function hookTool(tool)
		if not tool or not tool:IsA("Tool") or hookedTools[tool] then return end
		hookedTools[tool] = true
		task.spawn(function()
			while tool.Parent do
				task.wait(0.05); if PANIC_TRIGGERED then break end
				if MISC.NoRecoil or MISC.NoSpread or MISC.InfAmmo or MISC.RapidFire then
					pcall(function()
						local mult = (MISC.RapidFireMultiplier or 20) / 20
						for _, v in ipairs(tool:GetDescendants()) do
							if v:IsA("NumberValue") or v:IsA("IntValue") then
								local n = v.Name:lower()
								if MISC.NoRecoil and (n:find("recoil") or n:find("kick") or n:find("shake")) then v.Value = 0 end
								if MISC.NoSpread then
									if n:find("spread") or n:find("bulletspread") then v.Value = 0 end
									if n:find("accuracy") then v.Value = 1 end
								end
								if MISC.InfAmmo and (n == "ammo" or n == "currentammo" or n == "bullets" or n:find("magazine") or n:find("clip") or n == "maxammo" or n == "reserveammo") then v.Value = 999 end
								if MISC.RapidFire then
									if n:find("firerate") or n:find("rateof") then
										if mult > 0 then if v.Value < 9000 then v.Value = v.Value / math.max(mult, 0.01) end
										else v.Value = 99999 end
									end
									if n:find("firedelay") or n:find("delay") or n:find("cooldown") or n:find("shotdelay") or n:find("interval") or n:find("attackdelay") or n:find("shootdelay") then
										v.Value = v.Value * mult
									end
								end
							end
							if v:IsA("BoolValue") then
								local n = v.Name:lower()
								if MISC.InfAmmo and (n:find("reloading") or n:find("isreloading")) then v.Value = false end
								if MISC.RapidFire then
									if n:find("canfire") or n:find("canshoot") or n:find("ready") then v.Value = true end
									if n:find("cooling") or n:find("oncooldown") then v.Value = false end
								end
							end
						end
					end)
				end
			end
			hookedTools[tool] = nil
		end)
	end
	local function scanTools(c)
		if not c then return end
		for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then hookTool(t) end end
		c.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then hookTool(ch) end end)
	end
	local function scanBP()
		local bp = player:FindFirstChildOfClass("Backpack"); if not bp then return end
		for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then hookTool(t) end end
		bp.ChildAdded:Connect(function(c) if c:IsA("Tool") then hookTool(c) end end)
	end
	if player.Character then scanTools(player.Character) end
	player.CharacterAdded:Connect(function(c) task.wait(0.3); scanTools(c) end)
	task.spawn(function() task.wait(1); pcall(scanBP) end)
	task.spawn(function()
		while true do
			task.wait(3); if PANIC_TRIGGERED then break end
			if player.Character then pcall(function() scanTools(player.Character) end) end
			pcall(scanBP)
		end
	end)

	-- Rapid Fire Auto‑Clicker (przytrzymanie LMB -> automatyczne strzały)
	task.spawn(function()
		while true do
			if PANIC_TRIGGERED then break end
			if MISC.RapidFire and mbHeld[1] then
				local mult = MISC.RapidFireMultiplier or 20
				local delay = math.max(0.001, 0.05 * (1 - mult/100))
				if not isMouseOverGui() then
					pcall(function()
						VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
						task.wait(0.01)
						VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
					end)
					task.wait(delay)
				else task.wait(0.05) end
			else task.wait(0.05) end
		end
	end)

	local punchedTools = {}
	local function doSuperPunch()
		if PANIC_TRIGGERED or not MISC.SuperPunch then return end
		local myChar = player.Character; if not myChar then return end
		local myRoot = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"); if not myRoot then return end
		local best, bestDist = nil, 20
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				local tRoot = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")
				if hum and hum.Health > 0 and tRoot then
					local dist = (myRoot.Position - tRoot.Position).Magnitude
					if dist <= bestDist then
						local dir = (tRoot.Position - myRoot.Position).Unit
						if dir:Dot(myRoot.CFrame.LookVector) > 0 then best = plr; bestDist = dist end
					end
				end
			end
		end
		if not best or not best.Character then return end
		local targetHum = best.Character:FindFirstChildOfClass("Humanoid"); if not targetHum then return end
		local remotes = {}
		local function scanR(parent, depth)
			if depth > 5 then return end
			pcall(function()
				for _, v in ipairs(parent:GetChildren()) do
					if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
						local n = v.Name:lower()
						if n:find("damage") or n:find("hit") or n:find("punch") or n:find("attack") or n:find("melee") or n:find("combat") or n:find("strike") or n:find("fist") or n:find("dmg") or n:find("hurt") then
							table.insert(remotes, v)
						end
					end
					if v:IsA("Folder") or v:IsA("Model") or v:IsA("Configuration") then scanR(v, depth + 1) end
				end
			end)
		end
		scanR(ReplicatedStorage, 0); scanR(workspace, 0)
		local equippedTool = myChar:FindFirstChildOfClass("Tool")
		task.spawn(function()
			for i = 1, 100 do
				if PANIC_TRIGGERED or not MISC.SuperPunch or not best.Parent then break end
				local tH = best.Character and best.Character:FindFirstChildOfClass("Humanoid")
				if not tH or tH.Health <= 0 then break end
				if equippedTool then pcall(function() equippedTool:Activate() end) end
				pcall(function()
					VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
					VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
				end)
				for _, remote in ipairs(remotes) do
					pcall(function()
						if remote:IsA("RemoteEvent") then
							remote:FireServer(best); remote:FireServer(best, targetHum); remote:FireServer(targetHum)
						end
					end)
				end
				task.wait(0.02)
			end
		end)
	end
	local function hookToolSP(tool)
		if not tool or not tool:IsA("Tool") then return end
		if punchedTools[tool] then return end; punchedTools[tool] = true
		local conn; conn = tool.Activated:Connect(function()
			if MISC.SuperPunch and not PANIC_TRIGGERED then doSuperPunch() end
		end)
		tool.AncestryChanged:Connect(function()
			if not tool.Parent then punchedTools[tool] = nil; if conn then conn:Disconnect() end end
		end)
	end
	local function scanSP()
		local c = player.Character
		if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then hookToolSP(t) end end end
		local bp = player:FindFirstChildOfClass("Backpack")
		if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then hookToolSP(t) end end end
	end
	scanSP()
	if player.Character then player.Character.ChildAdded:Connect(function(c) if c:IsA("Tool") then hookToolSP(c) end end) end
	player.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		c.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then hookToolSP(ch) end end)
		scanSP()
	end)
	local bp2 = player:FindFirstChildOfClass("Backpack")
	if bp2 then bp2.ChildAdded:Connect(function(c) if c:IsA("Tool") then hookToolSP(c) end end) end
	task.spawn(function() while true do task.wait(2); if PANIC_TRIGGERED then break end; pcall(scanSP) end end)

	local function isMouseOverGui()
		local mp = UIS:GetMouseLocation()
		local go = playerGui:GetGuiObjectsAtPosition(mp.X, mp.Y)
		for _, o in ipairs(go) do
			local cur = o
			while cur do
				if cur == gui or cur.Name == "BearHub" then return true end
				cur = cur.Parent
			end
		end
		return false
	end
end

local healPlayer = _G.BearHub_healPlayer
local copyItem = _G.BearHub_copyItem

--============================================================
-- EXPLOITS LOGIC
--============================================================
do
	-- TELEPORT WALK
	RunService.RenderStepped:Connect(function()
		if PANIC_TRIGGERED or not EXPLOITS.TeleportWalk then return end
		local char = player.Character; if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return end
		local moveDir = hum.MoveDirection
		if moveDir.Magnitude > 0 then
			local dist = math.clamp(EXPLOITS.TeleportWalkDistance, 0.1, 300)
			local newPos = root.Position + (moveDir.Unit * dist * 0.12)
			pcall(function()
				root.CFrame = CFrame.new(newPos) * (root.CFrame - root.CFrame.Position)
			end)
		end
	end)

	-- CLICK TELEPORT
	local ctCooldown = false
	local function doClickTeleport()
		if PANIC_TRIGGERED or not EXPLOITS.ClickTeleport then return end
		if ctCooldown then return end
		local char = player.Character; if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
		local mouse = player:GetMouse()
		if mouse then
			local targetPos = mouse.Hit.Position + Vector3.new(0, 3, 0)
			ctCooldown = true
			pcall(function()
				root.CFrame = CFrame.new(targetPos)
				for _, p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then
						pcall(function()
							p.Velocity = Vector3.zero
							p.AssemblyLinearVelocity = Vector3.zero
						end)
					end
				end
			end)
			task.wait(0.15)
			ctCooldown = false
		end
	end

	UIS.InputBegan:Connect(function(inp, gp)
		if PANIC_TRIGGERED or gp then return end
		if not EXPLOITS.ClickTeleport then return end
		if not EXPLOITS.ClickTeleportKeyCheck then return end
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			if EXPLOITS.ClickTeleportKeyCheck() then
				doClickTeleport()
			end
		end
		if inp.UserInputType == Enum.UserInputType.Keyboard then
			if EXPLOITS.ClickTeleportKeyCheck and EXPLOITS.ClickTeleportKeyName ~= "NONE" then
				local kn = inp.KeyCode.Name
				if kn == EXPLOITS.ClickTeleportKeyName then
					doClickTeleport()
				end
			end
		end
	end)

	-- ANTI-AFK
	task.spawn(function()
		while true do
			task.wait(55)
			if PANIC_TRIGGERED then break end
			if EXPLOITS.AntiAFK then
				pcall(function()
					VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
					task.wait(0.05)
					VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
				end)
			end
		end
	end)
	pcall(function()
		player.Idled:Connect(function()
			if EXPLOITS.AntiAFK and not PANIC_TRIGGERED then
				pcall(function()
					VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
					task.wait(0.05)
					VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
				end)
			end
		end)
	end)
end

--============================================================
-- GUI MAIN + COLOR PICKER
--============================================================
local main, sidebar, contentTitle, pagesFrame, colorPickerGui, openCP, cpGrid, hueBar

do
	local ORIGINAL_SIZE = UDim2.new(0, 780, 0, 530)
	main = Instance.new("Frame", gui)
	main.Name = "Main"; main.Size = ORIGINAL_SIZE
	main.Position = UDim2.new(0.5, -390, 0.5, -265)
	main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	main.BorderSizePixel = 0; main.ClipsDescendants = true; main.Active = true
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

	sidebar = Instance.new("Frame", main)
	sidebar.Size = UDim2.new(0, 190, 1, 0)
	sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	sidebar.BorderSizePixel = 0; sidebar.Active = true
	Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

	local bearIcon = Instance.new("ImageLabel", sidebar)
	bearIcon.Size = UDim2.new(0, 80, 0, 80); bearIcon.Position = UDim2.new(0.5, -40, 0, 15)
	bearIcon.BackgroundTransparency = 1; bearIcon.Image = BEAR_ICON; bearIcon.ScaleType = Enum.ScaleType.Fit

	local tabsFrame = Instance.new("Frame", sidebar)
	tabsFrame.Name = "TabsFrame"
	tabsFrame.Size = UDim2.new(1, -20, 1, -130)
	tabsFrame.Position = UDim2.new(0, 10, 0, 110)
	tabsFrame.BackgroundTransparency = 1
	local tfl = Instance.new("UIListLayout", tabsFrame)
	tfl.Padding = UDim.new(0, 6); tfl.SortOrder = Enum.SortOrder.LayoutOrder

	local contentArea = Instance.new("Frame", main)
	contentArea.Size = UDim2.new(1, -200, 1, -20)
	contentArea.Position = UDim2.new(0, 200, 0, 10)
	contentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	contentArea.BorderSizePixel = 0; contentArea.ClipsDescendants = true
	Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

	contentTitle = Instance.new("TextLabel", contentArea)
	contentTitle.Size = UDim2.new(1, -20, 0, 40); contentTitle.Position = UDim2.new(0, 15, 0, 10)
	contentTitle.BackgroundTransparency = 1; contentTitle.Text = "AimAssistance"
	contentTitle.TextColor3 = Color3.new(1,1,1); contentTitle.Font = Enum.Font.GothamBold
	contentTitle.TextSize = 20; contentTitle.TextXAlignment = Enum.TextXAlignment.Left

	pagesFrame = Instance.new("Frame", contentArea)
	pagesFrame.Size = UDim2.new(1, 0, 1, -55); pagesFrame.Position = UDim2.new(0, 0, 0, 55)
	pagesFrame.BackgroundTransparency = 1

	colorPickerGui = Instance.new("Frame", main)
	colorPickerGui.Size = UDim2.new(0, 220, 0, 260)
	colorPickerGui.Position = UDim2.new(0.5, -110, 0.5, -130)
	colorPickerGui.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	colorPickerGui.BorderSizePixel = 0; colorPickerGui.Visible = false
	colorPickerGui.ZIndex = 100; colorPickerGui.Active = true
	Instance.new("UICorner", colorPickerGui).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", colorPickerGui).Color = PURPLE

	local cpTitleLbl = Instance.new("TextLabel", colorPickerGui)
	cpTitleLbl.Size = UDim2.new(1, 0, 0, 30); cpTitleLbl.BackgroundTransparency = 1
	cpTitleLbl.Text = "Pick Color"; cpTitleLbl.TextColor3 = Color3.new(1,1,1)
	cpTitleLbl.Font = Enum.Font.GothamBold; cpTitleLbl.TextSize = 14; cpTitleLbl.ZIndex = 101

	local cpX = Instance.new("TextButton", colorPickerGui)
	cpX.Size = UDim2.new(0, 25, 0, 25); cpX.Position = UDim2.new(1, -30, 0, 3)
	cpX.BackgroundTransparency = 1; cpX.Text = "X"
	cpX.TextColor3 = Color3.fromRGB(200,200,200); cpX.Font = Enum.Font.GothamBold
	cpX.TextSize = 16; cpX.ZIndex = 102
	cpX.MouseButton1Click:Connect(function() playClick(); colorPickerGui.Visible = false end)

	cpGrid = Instance.new("Frame", colorPickerGui)
	cpGrid.Size = UDim2.new(1, -20, 0, 150); cpGrid.Position = UDim2.new(0, 10, 0, 35)
	cpGrid.BackgroundColor3 = Color3.fromRGB(255,0,0); cpGrid.BorderSizePixel = 0
	cpGrid.ZIndex = 101; cpGrid.ClipsDescendants = true
	Instance.new("UICorner", cpGrid).CornerRadius = UDim.new(0, 6)
	local so = Instance.new("Frame", cpGrid); so.Size = UDim2.new(1,0,1,0); so.BackgroundColor3 = Color3.new(1,1,1); so.BorderSizePixel = 0; so.ZIndex = 102
	Instance.new("UIGradient", so).Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
	local vo = Instance.new("Frame", cpGrid); vo.Size = UDim2.new(1,0,1,0); vo.BackgroundColor3 = Color3.new(0,0,0); vo.BorderSizePixel = 0; vo.ZIndex = 103
	local vg = Instance.new("UIGradient", vo); vg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}); vg.Rotation = 90
	local cpCur = Instance.new("Frame", cpGrid); cpCur.Size = UDim2.new(0,10,0,10); cpCur.BackgroundColor3 = Color3.new(1,1,1); cpCur.BorderSizePixel = 0; cpCur.ZIndex = 105
	Instance.new("UICorner", cpCur).CornerRadius = UDim.new(1,0); Instance.new("UIStroke", cpCur).Color = Color3.new(0,0,0)

	hueBar = Instance.new("Frame", colorPickerGui)
	hueBar.Size = UDim2.new(1,-20,0,20); hueBar.Position = UDim2.new(0,10,0,195)
	hueBar.BorderSizePixel = 0; hueBar.ZIndex = 101; hueBar.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0,6)
	Instance.new("UIGradient", hueBar).Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
		ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
		ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
		ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
	})
	local hueSlider = Instance.new("Frame", hueBar); hueSlider.Size = UDim2.new(0,4,1,4); hueSlider.Position = UDim2.new(0,-2,0,-2); hueSlider.BackgroundColor3 = Color3.new(1,1,1); hueSlider.BorderSizePixel = 0; hueSlider.ZIndex = 102
	Instance.new("UICorner", hueSlider).CornerRadius = UDim.new(0,2)
	local cpPrev = Instance.new("Frame", colorPickerGui); cpPrev.Size = UDim2.new(0,40,0,30); cpPrev.Position = UDim2.new(0,10,0,222); cpPrev.BackgroundColor3 = Color3.fromRGB(255,0,0); cpPrev.BorderSizePixel = 0; cpPrev.ZIndex = 101
	Instance.new("UICorner", cpPrev).CornerRadius = UDim.new(0,6)
	local cpApply = Instance.new("TextButton", colorPickerGui); cpApply.Size = UDim2.new(0,80,0,28); cpApply.Position = UDim2.new(1,-95,0,223); cpApply.BackgroundColor3 = PURPLE; cpApply.Text = "Apply"; cpApply.TextColor3 = Color3.new(1,1,1); cpApply.Font = Enum.Font.GothamBold; cpApply.TextSize = 13; cpApply.ZIndex = 102; cpApply.AutoButtonColor = false
	Instance.new("UICorner", cpApply).CornerRadius = UDim.new(0,6)

	local cH, cS, cV = 0, 1, 1; local activeCC = nil
	local function updCP()
		cpPrev.BackgroundColor3 = Color3.fromHSV(cH,cS,cV)
		cpGrid.BackgroundColor3 = Color3.fromHSV(cH,1,1)
		cpCur.Position = UDim2.new(cS,-5,1-cV,-5)
		hueSlider.Position = UDim2.new(cH,-2,0,-2)
	end
	_G.BearHub_canvasDrag = false; _G.BearHub_hueDrag = false
	local cpGB = Instance.new("TextButton", cpGrid); cpGB.Size = UDim2.new(1,0,1,0); cpGB.BackgroundTransparency = 1; cpGB.Text = ""; cpGB.ZIndex = 106
	cpGB.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			_G.BearHub_canvasDrag = true
			local ap = cpGrid.AbsolutePosition; local as = cpGrid.AbsoluteSize
			cS = math.clamp((i.Position.X-ap.X)/as.X,0,1); cV = 1-math.clamp((i.Position.Y-ap.Y)/as.Y,0,1); updCP()
		end
	end)
	local hB = Instance.new("TextButton", hueBar); hB.Size = UDim2.new(1,0,1,0); hB.BackgroundTransparency = 1; hB.Text = ""; hB.ZIndex = 103
	hB.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			_G.BearHub_hueDrag = true
			cH = math.clamp((i.Position.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1); updCP()
		end
	end)
	cpApply.MouseButton1Click:Connect(function() playClick(); if activeCC then activeCC(Color3.fromHSV(cH,cS,cV)) end; colorPickerGui.Visible = false end)
	_G.BearHub_openCP = function(col, cb) local h, s, v = col:ToHSV(); cH, cS, cV = h, s, v; activeCC = cb; updCP(); colorPickerGui.Visible = true end
	_G.BearHub_updCPValues = function(x, y, kind)
		if kind == "canvas" then
			cS = math.clamp((x-cpGrid.AbsolutePosition.X)/cpGrid.AbsoluteSize.X,0,1)
			cV = 1-math.clamp((y-cpGrid.AbsolutePosition.Y)/cpGrid.AbsoluteSize.Y,0,1); updCP()
		elseif kind == "hue" then
			cH = math.clamp((x-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1); updCP()
		end
	end
end
openCP = _G.BearHub_openCP

--============================================================
-- GUI HELPERS
--============================================================
_G.BearHub_allSliders = {}; _G.BearHub_tabPages = {}
local mkSection, mkCheck, mkCheckColor, mkSlider, mkDropdown, mkKeybind, mkButton, createPage
do
	local allSliders = _G.BearHub_allSliders

	mkSection = function(p,t,o)
		local l=Instance.new("TextLabel",p); l.Size=UDim2.new(1,0,0,28); l.BackgroundTransparency=1
		l.Text=t; l.TextColor3=Color3.fromRGB(160,160,170); l.Font=Enum.Font.GothamBold
		l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.LayoutOrder=o or 0
	end

	mkCheck = function(p,t,tbl,k,o)
		local h=Instance.new("Frame",p); h.Size=UDim2.new(1,0,0,30); h.BackgroundTransparency=1; h.LayoutOrder=o or 0
		local en=tbl[k] or false
		local box=Instance.new("TextButton",h); box.Size=UDim2.new(0,22,0,22); box.Position=UDim2.new(0,5,0.5,-11)
		box.BackgroundColor3=en and PURPLE or GRAY; box.Text=""; box.AutoButtonColor=false; box.BorderSizePixel=0
		Instance.new("UICorner",box).CornerRadius=UDim.new(0,5)
		local ck=Instance.new("ImageLabel",box); ck.Size=UDim2.new(0.75,0,0.75,0); ck.Position=UDim2.new(0.125,0,0.125,0)
		ck.BackgroundTransparency=1; ck.Image=CHECK_ICON; ck.Visible=en
		local lb=Instance.new("TextLabel",h); lb.Size=UDim2.new(1,-40,1,0); lb.Position=UDim2.new(0,35,0,0)
		lb.BackgroundTransparency=1; lb.Text=t; lb.TextColor3=Color3.fromRGB(200,200,210)
		lb.Font=Enum.Font.Gotham; lb.TextSize=13; lb.TextXAlignment=Enum.TextXAlignment.Left
		box.MouseButton1Click:Connect(function()
			playClick(); en=not en; box.BackgroundColor3=en and PURPLE or GRAY; ck.Visible=en; tbl[k]=en
			if tbl==ESP then pcall(fullRefresh) end
		end)
	end

	mkCheckColor = function(p,t,tbl,k,ck2,o)
		local h=Instance.new("Frame",p); h.Size=UDim2.new(1,0,0,30); h.BackgroundTransparency=1; h.LayoutOrder=o or 0
		local isSub=(ck2==nil); local en,colRef
		if isSub then en=ESP[k].Enabled; colRef=ESP[k].Color else en=tbl[k] or false; colRef=tbl[ck2] end
		local box=Instance.new("TextButton",h); box.Size=UDim2.new(0,22,0,22); box.Position=UDim2.new(0,5,0.5,-11)
		box.BackgroundColor3=en and PURPLE or GRAY; box.Text=""; box.AutoButtonColor=false; box.BorderSizePixel=0
		Instance.new("UICorner",box).CornerRadius=UDim.new(0,5)
		local ck=Instance.new("ImageLabel",box); ck.Size=UDim2.new(0.75,0,0.75,0); ck.Position=UDim2.new(0.125,0,0.125,0)
		ck.BackgroundTransparency=1; ck.Image=CHECK_ICON; ck.Visible=en
		local lb=Instance.new("TextLabel",h); lb.Size=UDim2.new(1,-80,1,0); lb.Position=UDim2.new(0,35,0,0)
		lb.BackgroundTransparency=1; lb.Text=t; lb.TextColor3=Color3.fromRGB(200,200,210)
		lb.Font=Enum.Font.Gotham; lb.TextSize=13; lb.TextXAlignment=Enum.TextXAlignment.Left
		local ci=Instance.new("TextButton",h); ci.Size=UDim2.new(0,22,0,22); ci.Position=UDim2.new(1,-30,0.5,-11)
		ci.BackgroundColor3=colRef; ci.Text=""; ci.AutoButtonColor=false; ci.BorderSizePixel=0
		Instance.new("UICorner",ci).CornerRadius=UDim.new(1,0); Instance.new("UIStroke",ci).Color=Color3.fromRGB(80,80,90)
		ci.MouseButton1Click:Connect(function()
			playClick(); openCP(ci.BackgroundColor3,function(nc)
				ci.BackgroundColor3=nc
				if isSub then ESP[k].Color=nc else tbl[ck2]=nc end
			end)
		end)
		box.MouseButton1Click:Connect(function()
			playClick(); en=not en; box.BackgroundColor3=en and PURPLE or GRAY; ck.Visible=en
			if isSub then ESP[k].Enabled=en else tbl[k]=en end
		end)
	end

	mkSlider = function(p,t,minV,maxV,def,suf,tbl,k,o,isFloat)
		local h=Instance.new("Frame",p); h.Size=UDim2.new(1,0,0,50); h.BackgroundTransparency=1; h.LayoutOrder=o or 0
		local val=def or minV
		local lb=Instance.new("TextLabel",h); lb.Size=UDim2.new(0.6,0,0,20); lb.Position=UDim2.new(0,5,0,0)
		lb.BackgroundTransparency=1; lb.Text=t; lb.TextColor3=Color3.fromRGB(200,200,210)
		lb.Font=Enum.Font.GothamBold; lb.TextSize=13; lb.TextXAlignment=Enum.TextXAlignment.Left
		local vl=Instance.new("TextLabel",h); vl.Size=UDim2.new(0.4,-5,0,20); vl.Position=UDim2.new(0.6,0,0,0)
		vl.BackgroundTransparency=1
		local function fmtVal(v)
			if isFloat then return string.format("%.1f", v)..(suf or "")
			else return tostring(math.floor(v))..(suf or "") end
		end
		vl.Text=fmtVal(val); vl.TextColor3=Color3.fromRGB(150,150,160)
		vl.Font=Enum.Font.Gotham; vl.TextSize=13; vl.TextXAlignment=Enum.TextXAlignment.Right
		local bg=Instance.new("Frame",h); bg.Size=UDim2.new(1,-10,0,6); bg.Position=UDim2.new(0,5,0,30)
		bg.BackgroundColor3=Color3.fromRGB(50,50,60); bg.BorderSizePixel=0
		Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
		local pct=(val-minV)/(maxV-minV)
		local fill=Instance.new("Frame",bg); fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=PURPLE; fill.BorderSizePixel=0
		Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
		local knob=Instance.new("Frame",bg); knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(pct,-8,0.5,-8)
		knob.BackgroundColor3=Color3.new(1,1,1); knob.BorderSizePixel=0; knob.ZIndex=2
		Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
		local hit=Instance.new("TextButton",bg); hit.Size=UDim2.new(1,20,0,30); hit.Position=UDim2.new(0,-10,0.5,-15)
		hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=3
		local drag=false; local lsst=0; local lsv=val
		local function upd(x)
			local ap=bg.AbsolutePosition; local as=bg.AbsoluteSize
			local rx=math.clamp((x-ap.X)/as.X,0,1)
			if isFloat then val=math.floor((minV+(maxV-minV)*rx)*10)/10
			else val=math.floor(minV+(maxV-minV)*rx) end
			fill.Size=UDim2.new(rx,0,1,0); knob.Position=UDim2.new(rx,-8,0.5,-8)
			vl.Text=fmtVal(val); if tbl and k then tbl[k]=val end
			if val~=lsv then local now=tick(); if now-lsst>0.08 then lsst=now; playSlider() end; lsv=val end
		end
		hit.InputBegan:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; upd(i.Position.X) end
		end)
		table.insert(allSliders,{isDragging=function() return drag end, update=upd, setDrag=function(v) drag=v end})
	end

	mkDropdown = function(p,t,opts,tbl,k,o)
		local h=Instance.new("Frame",p); h.Size=UDim2.new(1,0,0,60); h.BackgroundTransparency=1
		h.LayoutOrder=o or 0; h.ClipsDescendants=false
		local lb=Instance.new("TextLabel",h); lb.Size=UDim2.new(1,0,0,20); lb.BackgroundTransparency=1
		lb.Text=t; lb.TextColor3=Color3.fromRGB(200,200,210); lb.Font=Enum.Font.GothamBold
		lb.TextSize=13; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Position=UDim2.new(0,5,0,0)
		local btn=Instance.new("TextButton",h); btn.Size=UDim2.new(1,-10,0,30); btn.Position=UDim2.new(0,5,0,25)
		btn.BackgroundColor3=Color3.fromRGB(40,40,50); btn.BorderSizePixel=0; btn.Text=" "..tbl[k]
		btn.TextColor3=Color3.fromRGB(200,200,210); btn.Font=Enum.Font.Gotham; btn.TextSize=13
		btn.TextXAlignment=Enum.TextXAlignment.Left; btn.AutoButtonColor=false
		Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
		local dd=Instance.new("Frame",h); dd.Size=UDim2.new(1,-10,0,#opts*30); dd.Position=UDim2.new(0,5,0,58)
		dd.BackgroundColor3=Color3.fromRGB(35,35,45); dd.BorderSizePixel=0; dd.Visible=false; dd.ZIndex=50
		Instance.new("UICorner",dd).CornerRadius=UDim.new(0,6); Instance.new("UIListLayout",dd)
		for _,opt in ipairs(opts) do
			local ob=Instance.new("TextButton",dd); ob.Size=UDim2.new(1,0,0,30)
			ob.BackgroundColor3=Color3.fromRGB(35,35,45); ob.Text=" "..opt
			ob.TextColor3=Color3.fromRGB(180,180,190); ob.Font=Enum.Font.Gotham; ob.TextSize=13
			ob.TextXAlignment=Enum.TextXAlignment.Left; ob.AutoButtonColor=false; ob.ZIndex=51; ob.BorderSizePixel=0
			ob.MouseEnter:Connect(function() ob.BackgroundColor3=Color3.fromRGB(50,50,65) end)
			ob.MouseLeave:Connect(function() ob.BackgroundColor3=Color3.fromRGB(35,35,45) end)
			ob.MouseButton1Click:Connect(function() playClick(); tbl[k]=opt; btn.Text=" "..opt; dd.Visible=false end)
		end
		btn.MouseButton1Click:Connect(function() playClick(); dd.Visible=not dd.Visible end)
	end

	local BIND_OPTIONS = {
		{"LPM (MB1)",function() return mbHeld[1] end},
		{"PPM (MB2)",function() return mbHeld[2] end},
		{"Scroll (MB3)",function() return mbHeld[3] end},
		{"Side Back (MB4)",function() return mbHeld[4] end},
		{"Side Front (MB5)",function() return mbHeld[5] end},
	}
	local KB={Enum.KeyCode.E,Enum.KeyCode.F,Enum.KeyCode.G,Enum.KeyCode.H,Enum.KeyCode.Q,Enum.KeyCode.R,Enum.KeyCode.T,Enum.KeyCode.X,Enum.KeyCode.Z,Enum.KeyCode.C,Enum.KeyCode.V,Enum.KeyCode.B,Enum.KeyCode.CapsLock,Enum.KeyCode.Tab,Enum.KeyCode.LeftAlt,Enum.KeyCode.RightAlt,Enum.KeyCode.LeftControl,Enum.KeyCode.RightControl,Enum.KeyCode.LeftShift,Enum.KeyCode.F1,Enum.KeyCode.F2,Enum.KeyCode.F3,Enum.KeyCode.F4,Enum.KeyCode.F5,Enum.KeyCode.F6,Enum.KeyCode.F7,Enum.KeyCode.F8}
	for _,kc in ipairs(KB) do local kcc=kc; table.insert(BIND_OPTIONS,{kc.Name,function() return UIS:IsKeyDown(kcc) end}) end

	mkKeybind = function(p,t,tbl,o)
		local h=Instance.new("Frame",p); h.Size=UDim2.new(1,0,0,30); h.BackgroundTransparency=1; h.LayoutOrder=o or 0
		local en=tbl.Enabled
		local box=Instance.new("TextButton",h); box.Size=UDim2.new(0,22,0,22); box.Position=UDim2.new(0,5,0.5,-11)
		box.BackgroundColor3=en and PURPLE or GRAY; box.Text=""; box.AutoButtonColor=false; box.BorderSizePixel=0
		Instance.new("UICorner",box).CornerRadius=UDim.new(0,5)
		local ck=Instance.new("ImageLabel",box); ck.Size=UDim2.new(0.75,0,0.75,0); ck.Position=UDim2.new(0.125,0,0.125,0)
		ck.BackgroundTransparency=1; ck.Image=CHECK_ICON; ck.Visible=en
		local lb=Instance.new("TextLabel",h); lb.Size=UDim2.new(0,55,1,0); lb.Position=UDim2.new(0,35,0,0)
		lb.BackgroundTransparency=1; lb.Text=t; lb.TextColor3=Color3.fromRGB(200,200,210)
		lb.Font=Enum.Font.Gotham; lb.TextSize=13; lb.TextXAlignment=Enum.TextXAlignment.Left
		local keyBtn=Instance.new("TextButton",h); keyBtn.Size=UDim2.new(0,110,0,24); keyBtn.Position=UDim2.new(1,-115,0.5,-12)
		keyBtn.BackgroundColor3=Color3.fromRGB(40,40,50); keyBtn.BorderSizePixel=0; keyBtn.Text=tbl.KeybindName
		keyBtn.TextColor3=Color3.fromRGB(180,180,190); keyBtn.Font=Enum.Font.GothamBold; keyBtn.TextSize=11
		keyBtn.AutoButtonColor=false; Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,5)
		local to=#BIND_OPTIONS+1
		local ddF=Instance.new("Frame",h); ddF.Size=UDim2.new(0,170,0,math.min(to,8)*28); ddF.Position=UDim2.new(1,-175,1,2)
		ddF.BackgroundColor3=Color3.fromRGB(30,30,38); ddF.BorderSizePixel=0; ddF.Visible=false
		ddF.ZIndex=200; ddF.ClipsDescendants=true; Instance.new("UICorner",ddF).CornerRadius=UDim.new(0,6)
		Instance.new("UIStroke",ddF).Color=PURPLE
		local ddS=Instance.new("ScrollingFrame",ddF); ddS.Size=UDim2.new(1,0,1,0); ddS.BackgroundTransparency=1
		ddS.ScrollBarThickness=3; ddS.ScrollBarImageColor3=PURPLE; ddS.CanvasSize=UDim2.new(0,0,0,to*28)
		ddS.ZIndex=201; Instance.new("UIListLayout",ddS)
		local nb=Instance.new("TextButton",ddS); nb.Size=UDim2.new(1,0,0,28); nb.BackgroundColor3=Color3.fromRGB(30,30,38)
		nb.Text=" NONE"; nb.TextColor3=Color3.fromRGB(150,150,160); nb.Font=Enum.Font.Gotham; nb.TextSize=12
		nb.TextXAlignment=Enum.TextXAlignment.Left; nb.AutoButtonColor=false; nb.ZIndex=202; nb.BorderSizePixel=0; nb.LayoutOrder=0
		nb.MouseEnter:Connect(function() nb.BackgroundColor3=Color3.fromRGB(50,50,65) end)
		nb.MouseLeave:Connect(function() nb.BackgroundColor3=Color3.fromRGB(30,30,38) end)
		nb.MouseButton1Click:Connect(function() playClick(); tbl.KeybindName="NONE"; tbl.KeybindCheck=nil; keyBtn.Text="NONE"; ddF.Visible=false end)
		for i,opt in ipairs(BIND_OPTIONS) do
			local name=opt[1]; local cfn=opt[2]
			local ob=Instance.new("TextButton",ddS); ob.Size=UDim2.new(1,0,0,28); ob.BackgroundColor3=Color3.fromRGB(30,30,38)
			ob.Text=" "..name; ob.TextColor3=Color3.fromRGB(180,180,190); ob.Font=Enum.Font.Gotham; ob.TextSize=12
			ob.TextXAlignment=Enum.TextXAlignment.Left; ob.AutoButtonColor=false; ob.ZIndex=202; ob.BorderSizePixel=0; ob.LayoutOrder=i
			ob.MouseEnter:Connect(function() ob.BackgroundColor3=Color3.fromRGB(50,50,65) end)
			ob.MouseLeave:Connect(function() ob.BackgroundColor3=Color3.fromRGB(30,30,38) end)
			ob.MouseButton1Click:Connect(function() playClick(); tbl.KeybindName=name; tbl.KeybindCheck=cfn; keyBtn.Text=name; ddF.Visible=false end)
		end
		local ddO=false
		keyBtn.MouseButton1Click:Connect(function() playClick(); ddO=not ddO; ddF.Visible=ddO end)
		box.MouseButton1Click:Connect(function()
			playClick(); en=not en; tbl.Enabled=en; box.BackgroundColor3=en and PURPLE or GRAY; ck.Visible=en
		end)
	end

	mkButton = function(p,t,cb,o,cc)
		local btn=Instance.new("TextButton",p); btn.Size=UDim2.new(1,-10,0,36)
		btn.BackgroundColor3=cc or PURPLE; btn.BorderSizePixel=0; btn.Text=t
		btn.TextColor3=Color3.new(1,1,1); btn.Font=Enum.Font.GothamBold; btn.TextSize=13
		btn.AutoButtonColor=false; btn.LayoutOrder=o or 0
		Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
		local bc=cc or PURPLE
		btn.MouseEnter:Connect(function() btn.BackgroundColor3=Color3.fromRGB(math.min(bc.R*255+20,255),math.min(bc.G*255+20,255),math.min(bc.B*255+20,255)) end)
		btn.MouseLeave:Connect(function() btn.BackgroundColor3=bc end)
		btn.MouseButton1Click:Connect(function() playClick(); if cb then pcall(cb) end end)
		return btn
	end

	createPage = function(name)
		local p=Instance.new("ScrollingFrame",pagesFrame); p.Size=UDim2.new(1,0,1,0)
		p.BackgroundTransparency=1; p.ScrollBarThickness=3; p.ScrollBarImageColor3=PURPLE
		p.Visible=false; p.CanvasSize=UDim2.new(0,0,0,0); p.AutomaticCanvasSize=Enum.AutomaticSize.Y
		_G.BearHub_tabPages[name]=p; return p
	end
end

--============================================================
-- PAGES (wszystkie zakładki)
--============================================================
do
	local function mkPanel(parent, w, h2, xPos, yPos)
		local f=Instance.new("Frame",parent)
		f.Size=UDim2.new(w,0,0,h2)
		f.Position=UDim2.new(xPos, xPos==0 and 10 or 5, 0, yPos or 5)
		f.BackgroundColor3=DARK; f.BorderSizePixel=0
		Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
		local ll=Instance.new("UIListLayout",f); ll.Padding=UDim.new(0,4); ll.SortOrder=Enum.SortOrder.LayoutOrder
		local pd=Instance.new("UIPadding",f); pd.PaddingTop=UDim.new(0,8); pd.PaddingLeft=UDim.new(0,5); pd.PaddingRight=UDim.new(0,5)
		return f
	end

	-- VISUALIZATION PAGE
	local vizP=createPage("Visualization")
	local vL=mkPanel(vizP,0.48,260,0,5); local vR=mkPanel(vizP,0.48,400,0.5,5); vR.Position=UDim2.new(0.5,5,0,5)
	mkSection(vL,"Visualization",1); mkCheck(vL,"Enable",ESP,"Enabled",2)
	mkSlider(vL,"Max Distance",0,1000,300,"m",ESP,"MaxDistance",3)
	mkCheck(vL,"Show LocalPlayer",ESP,"ShowLocalPlayer",4); mkCheck(vL,"Visible Only",ESP,"VisibleOnly",5)
	mkSection(vR,"Options",1); mkCheckColor(vR,"Box",nil,"Box",nil,2); mkCheckColor(vR,"Skeleton",nil,"Skeleton",nil,3)
	mkCheckColor(vR,"Name",nil,"Name",nil,4); mkCheckColor(vR,"ID",nil,"ID",nil,5)
	mkCheckColor(vR,"Health Bar",nil,"HealthBar",nil,6); mkCheckColor(vR,"Distance",nil,"Distance",nil,7)
	mkCheckColor(vR,"Snaplines",nil,"Snaplines",nil,8); mkCheckColor(vR,"Inventory",nil,"Inventory",nil,9)
	mkCheckColor(vR,"Head Dot",nil,"HeadDot",nil,10)

	-- AIM PAGE
	local aimP=createPage("AimAssistance")
	local subBar=Instance.new("Frame",aimP); subBar.Size=UDim2.new(1,-20,0,30); subBar.Position=UDim2.new(0,10,0,0); subBar.BackgroundTransparency=1
	local sbl=Instance.new("UIListLayout",subBar); sbl.FillDirection=Enum.FillDirection.Horizontal; sbl.Padding=UDim.new(0,15)
	local subPF=Instance.new("Frame",aimP); subPF.Size=UDim2.new(1,0,1,-40); subPF.Position=UDim2.new(0,0,0,38); subPF.BackgroundTransparency=1

	local tbP=Instance.new("Frame",subPF); tbP.Size=UDim2.new(1,0,1,0); tbP.BackgroundTransparency=1; tbP.Visible=true
	local tbL=mkPanel(tbP,0.48,300,0,5); local tbR=mkPanel(tbP,0.48,300,0.5,5); tbR.Position=UDim2.new(0.5,5,0,5)
	mkSection(tbL,"TriggerBot",1); mkKeybind(tbL,"Enable",TRIGGERBOT,2)
	mkDropdown(tbL,"Type",{"First Person","Third Person"},TRIGGERBOT,"Type",3)
	mkCheckColor(tbL,"Show FOV",TRIGGERBOT,"ShowFOV","FOVColor",4); mkSlider(tbL,"Field of View",1,100,30,"px",TRIGGERBOT,"FOV",5)
	mkSection(tbR,"Options",1); mkCheck(tbR,"Exclude Dead",TRIGGERBOT,"ExcludeDead",2)
	mkCheck(tbR,"Visible Only",TRIGGERBOT,"VisibleOnly",3); mkSlider(tbR,"Max Distance",0,500,250,"m",TRIGGERBOT,"MaxDistance",4)
	mkSlider(tbR,"Shot Delay",0,1000,100,"ms",TRIGGERBOT,"ShotDelay",5)

	local abP=Instance.new("Frame",subPF); abP.Size=UDim2.new(1,0,1,0); abP.BackgroundTransparency=1; abP.Visible=false
	local abL=mkPanel(abP,0.48,300,0,5); local abR=mkPanel(abP,0.48,360,0.5,5); abR.Position=UDim2.new(0.5,5,0,5)
	mkSection(abL,"Aimbot",1); mkKeybind(abL,"Enable",AIMBOT,2)
	mkCheckColor(abL,"Draw FOV",AIMBOT,"DrawFOV","FOVColor",3); mkCheck(abL,"Visible Check",AIMBOT,"VisibleCheck",4); mkCheck(abL,"Exclude Dead",AIMBOT,"ExcludeDead",5)
	mkSection(abR,"Options",1); mkDropdown(abR,"Bones",{"Head","Torso","Legs"},AIMBOT,"Bone",2)
	mkSlider(abR,"Field of view",1,100,10,"",AIMBOT,"FOV",3); mkSlider(abR,"Max Distance",0,500,250,"m",AIMBOT,"MaxDistance",4)
	mkSlider(abR,"Smooth X",1,100,80,"",AIMBOT,"SmoothX",5); mkSlider(abR,"Smooth Y",1,100,80,"",AIMBOT,"SmoothY",6)

	local hbP=Instance.new("Frame",subPF); hbP.Size=UDim2.new(1,0,1,0); hbP.BackgroundTransparency=1; hbP.Visible=false
	local hbL=mkPanel(hbP,0.48,250,0,5)
	mkSection(hbL,"Hitbox Expander",1); mkCheck(hbL,"Enable",HITBOX,"Enabled",2)
	mkDropdown(hbL,"Bones",{"Head","Torso","Legs"},HITBOX,"Bone",3); mkSlider(hbL,"Size",0,30,0,"",HITBOX,"Size",4)

	local selSub=nil
	local function switchSub(n) tbP.Visible=(n=="TriggerBot"); abP.Visible=(n=="Aimbot"); hbP.Visible=(n=="Hitbox") end
	local function mkSB(n,o)
		local btn=Instance.new("TextButton",subBar); btn.Size=UDim2.new(0,100,1,0); btn.BackgroundTransparency=1; btn.BorderSizePixel=0
		btn.Text=n; btn.TextColor3=Color3.fromRGB(120,120,130); btn.Font=Enum.Font.GothamBold; btn.TextSize=14; btn.AutoButtonColor=false; btn.LayoutOrder=o
		local ul=Instance.new("Frame",btn); ul.Size=UDim2.new(1,0,0,2); ul.Position=UDim2.new(0,0,1,-2); ul.BackgroundColor3=PURPLE; ul.BorderSizePixel=0; ul.Visible=false
		btn.MouseButton1Click:Connect(function()
			playClick(); if selSub then selSub.btn.TextColor3=Color3.fromRGB(120,120,130); selSub.ul.Visible=false end
			selSub={btn=btn,ul=ul}; btn.TextColor3=Color3.new(1,1,1); ul.Visible=true; switchSub(n)
		end); return {btn=btn,ul=ul}
	end
	local s1=mkSB("TriggerBot",1); mkSB("Aimbot",2); mkSB("Hitbox",3); selSub=s1; s1.btn.TextColor3=Color3.new(1,1,1); s1.ul.Visible=true

	-- MISC PAGE
	local miscP=createPage("Miscellaneous")
	local mSubBar=Instance.new("Frame",miscP); mSubBar.Size=UDim2.new(1,-20,0,30); mSubBar.Position=UDim2.new(0,10,0,0); mSubBar.BackgroundTransparency=1
	local mSbl=Instance.new("UIListLayout",mSubBar); mSbl.FillDirection=Enum.FillDirection.Horizontal; mSbl.Padding=UDim.new(0,8)
	local mSubPF=Instance.new("Frame",miscP); mSubPF.Size=UDim2.new(1,0,1,-40); mSubPF.Position=UDim2.new(0,0,0,38); mSubPF.BackgroundTransparency=1

	-- Actions sub-page
	local mqaP=Instance.new("Frame",mSubPF); mqaP.Size=UDim2.new(1,0,1,0); mqaP.BackgroundTransparency=1; mqaP.Visible=true
	local qaPanel=mkPanel(mqaP,0.48,200,0,5)
	mkSection(qaPanel,"Quick Actions",1)
	mkButton(qaPanel,"Heal",healPlayer,2)

	local copyStatusLabel=Instance.new("TextLabel",qaPanel); copyStatusLabel.Size=UDim2.new(1,-10,0,18); copyStatusLabel.BackgroundTransparency=1
	copyStatusLabel.Text=""; copyStatusLabel.TextColor3=Color3.fromRGB(100,200,100); copyStatusLabel.Font=Enum.Font.GothamBold
	copyStatusLabel.TextSize=11; copyStatusLabel.TextXAlignment=Enum.TextXAlignment.Center; copyStatusLabel.LayoutOrder=4

	mkButton(qaPanel,"Copy Item (in hand)",function()
		local ok,msg=copyItem()
		copyStatusLabel.Text=msg; copyStatusLabel.TextColor3=ok and Color3.fromRGB(100,200,100) or Color3.fromRGB(255,100,100)
		task.spawn(function() task.wait(2.5); if copyStatusLabel.Text==msg then copyStatusLabel.Text="" end end)
	end,3,Color3.fromRGB(60,140,220))

	-- Combat sub-page
	local mcbP=Instance.new("Frame",mSubPF); mcbP.Size=UDim2.new(1,0,1,0); mcbP.BackgroundTransparency=1; mcbP.Visible=false
	local cbPanel=mkPanel(mcbP,0.48,290,0,5)
	mkSection(cbPanel,"Combat Cheats",1)
	mkCheck(cbPanel,"Super Punch (on tool activate)",MISC,"SuperPunch",2)
	mkCheck(cbPanel,"Semi God (Auto-Heal)",MISC,"SemiGod",3)
	mkCheck(cbPanel,"No Recoil",MISC,"NoRecoil",4)
	mkCheck(cbPanel,"No Spread",MISC,"NoSpread",5)
	mkCheck(cbPanel,"Infinity Ammo",MISC,"InfAmmo",6)

	-- Movement sub-page
	local mmvP=Instance.new("Frame",mSubPF); mmvP.Size=UDim2.new(1,0,1,0); mmvP.BackgroundTransparency=1; mmvP.Visible=false
	local mvPanel=mkPanel(mmvP,0.6,480,0,5)
	mkSection(mvPanel,"Movement",1)
	mkCheck(mvPanel,"NoClip (Fly + No Collision)",MISC,"NoClip",2)
	mkSlider(mvPanel,"NoClip Fly Speed",1,100,30," m/s",MISC,"NoClipSpeed",3)
	mkCheck(mvPanel,"Walk Speed",MISC,"WalkSpeedEnabled",4)
	mkSlider(mvPanel,"Walk Speed Value",0,250,16," m/s",MISC,"WalkSpeed",5)
	mkCheck(mvPanel,"Jump Power",MISC,"JumpPowerEnabled",6)
	mkSlider(mvPanel,"Jump Power Value",1,500,50," m",MISC,"JumpPower",7)
	mkCheck(mvPanel,"Enable SpinBot",MISC,"SpinBot",8)
	mkSlider(mvPanel,"Spin Speed",1,100,50,"",MISC,"SpinBotSpeed",9)
	mkCheck(mvPanel,"Remove Jump Delay",MISC,"RemoveJumpDelay",10)

	-- RapidFire sub-page
	local mrfP=Instance.new("Frame",mSubPF); mrfP.Size=UDim2.new(1,0,1,0); mrfP.BackgroundTransparency=1; mrfP.Visible=false
	local rfPanel=mkPanel(mrfP,0.48,200,0,5)
	mkSection(rfPanel,"Rapid Fire",1)
	mkCheck(rfPanel,"Enable Rapid Fire",MISC,"RapidFire",2)
	mkSlider(rfPanel,"Multiplier",1,100,20,"x",MISC,"RapidFireMultiplier",3)

	-- FreeCam sub-page
	local mfcP=Instance.new("Frame",mSubPF); mfcP.Size=UDim2.new(1,0,1,0); mfcP.BackgroundTransparency=1; mfcP.Visible=false
	local fcPanel=mkPanel(mfcP,0.6,200,0,5)
	mkSection(fcPanel,"Free Camera",1)
	mkCheck(fcPanel,"Enable FreeCam",MISC,"FreeCam",2)
	mkSlider(fcPanel,"FreeCam Speed",1,200,30," m/s",MISC,"FreeCamSpeed",3)

	-- FREECAM HUD (pozostaje bez zmian, pomijam w skrócie)

	-- ... (reszta kodu FreeCam, Players, Exploits, Settings, AutoFarm, jak w poprzedniej wersji, ale dla czytelności skrócę)
	-- (W rzeczywistym skrypcie należy wkleić całość, tutaj pokazuję tylko dodanie zakładki Executor)

	-- NOWA ZAKŁADKA: EXECUTOR
	local execP=createPage("Executor")
	local execPanel=mkPanel(execP,1,400,0,5)
	mkSection(execPanel,"Lua Executor",1)

	local scriptBox = Instance.new("TextBox", execPanel)
	scriptBox.Size = UDim2.new(1,-20,0,200); scriptBox.Position = UDim2.new(0,10,0,40)
	scriptBox.BackgroundColor3 = Color3.fromRGB(30,30,38); scriptBox.BorderSizePixel = 0
	scriptBox.Text = ""; scriptBox.TextColor3 = Color3.new(1,1,1)
	scriptBox.Font = Enum.Font.Code; scriptBox.TextSize = 14
	scriptBox.TextXAlignment = Enum.TextXAlignment.Left; scriptBox.TextYAlignment = Enum.TextYAlignment.Top
	scriptBox.ClearTextOnFocus = false; scriptBox.MultiLine = true
	Instance.new("UICorner", scriptBox).CornerRadius = UDim.new(0,6)
	scriptBox.LayoutOrder = 2

	local btnFrame = Instance.new("Frame", execPanel)
	btnFrame.Size = UDim2.new(1,-20,0,40); btnFrame.BackgroundTransparency = 1; btnFrame.LayoutOrder = 3
	local btnLayout = Instance.new("UIListLayout", btnFrame); btnLayout.FillDirection = Enum.FillDirection.Horizontal; btnLayout.Padding = UDim.new(0,10)

	local execBtn = Instance.new("TextButton", btnFrame)
	execBtn.Size = UDim2.new(0,120,0,36); execBtn.BackgroundColor3 = Color3.fromRGB(60,140,220); execBtn.BorderSizePixel = 0
	execBtn.Text = "Execute"; execBtn.TextColor3 = Color3.new(1,1,1); execBtn.Font = Enum.Font.GothamBold; execBtn.TextSize = 14
	execBtn.AutoButtonColor = false; Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0,6)

	local clearBtn = Instance.new("TextButton", btnFrame)
	clearBtn.Size = UDim2.new(0,100,0,36); clearBtn.BackgroundColor3 = Color3.fromRGB(180,60,60); clearBtn.BorderSizePixel = 0
	clearBtn.Text = "Clear"; clearBtn.TextColor3 = Color3.new(1,1,1); clearBtn.Font = Enum.Font.GothamBold; clearBtn.TextSize = 14
	clearBtn.AutoButtonColor = false; Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,6)

	local statusLabel = Instance.new("TextLabel", execPanel)
	statusLabel.Size = UDim2.new(1,-20,0,20); statusLabel.BackgroundTransparency = 1
	statusLabel.Text = ""; statusLabel.TextColor3 = Color3.new(1,1,1); statusLabel.Font = Enum.Font.Gotham; statusLabel.TextSize = 13; statusLabel.LayoutOrder = 4

	execBtn.MouseEnter:Connect(function() execBtn.BackgroundColor3 = Color3.fromRGB(80,160,240) end)
	execBtn.MouseLeave:Connect(function() execBtn.BackgroundColor3 = Color3.fromRGB(60,140,220) end)
	clearBtn.MouseEnter:Connect(function() clearBtn.BackgroundColor3 = Color3.fromRGB(210,80,80) end)
	clearBtn.MouseLeave:Connect(function() clearBtn.BackgroundColor3 = Color3.fromRGB(180,60,60) end)

	clearBtn.MouseButton1Click:Connect(function()
		playClick()
		scriptBox.Text = ""
		statusLabel.Text = ""
	end)

	execBtn.MouseButton1Click:Connect(function()
		playClick()
		local code = scriptBox.Text
		if code == "" then
			statusLabel.Text = "No script entered."
			statusLabel.TextColor3 = Color3.fromRGB(255,200,100)
			return
		end
		local success, err = pcall(function()
			local f, loadErr = loadstring(code)
			if not f then
				error("Compilation error: " .. tostring(loadErr))
			end
			f()
		end)
		if success then
			statusLabel.Text = "Script executed successfully."
			statusLabel.TextColor3 = Color3.fromRGB(100,200,100)
		else
			statusLabel.Text = "Error: " .. tostring(err)
			statusLabel.TextColor3 = Color3.fromRGB(255,100,100)
		end
		task.spawn(function()
			task.wait(5)
			if statusLabel.Text == "Script executed successfully." or statusLabel.Text:find("Error:") then
				statusLabel.Text = ""
			end
		end)
	end)

	-- ZAKOŃCZENIE PAGES
	-- (reszta kodu z Players, Exploits, Settings, AutoFarm i Tabs + Drag jest identyczna jak wcześniej, pomijam dla zwięzłości)
	-- Należy je dodać tak jak w poprzedniej pełnej wersji.

end

--============================================================
-- TABS + DRAG (dodajemy nową zakładkę)
--============================================================
local tabsFrame = sidebar:FindFirstChild("TabsFrame")
local tabsData = {{"AimAssistance"},{"Visualization"},{"Miscellaneous"},{"Exploits"},{"Players"},{"Settings"},{"AutoFarm"},{"Executor"}}  -- dodano Executor
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
	btn.Size = UDim2.new(1,0,0,36); btn.BackgroundTransparency = 1
	btn.Text = " "..name; btn.TextColor3 = Color3.fromRGB(150,150,160)
	btn.Font = Enum.Font.Gotham; btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left; btn.AutoButtonColor = false
	btn.LayoutOrder = order; Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
	btn.MouseEnter:Connect(function() if selTab~=btn then btn.BackgroundTransparency=0.7 end end)
	btn.MouseLeave:Connect(function() if selTab~=btn then btn.BackgroundTransparency=1 end end)
	btn.MouseButton1Click:Connect(function()
		playClick()
		if selTab then selTab.BackgroundTransparency=1; selTab.TextColor3=Color3.fromRGB(150,150,160) end
		selTab=btn; btn.BackgroundTransparency=0.5; btn.TextColor3=Color3.new(1,1,1); switchPage(name)
	end)
	return btn
end

for i, tab in ipairs(tabsData) do
	local b = makeTabBtn(tab[1], i)
	if i == 1 then selTab=b; b.BackgroundTransparency=0.5; b.TextColor3=Color3.new(1,1,1); switchPage(tab[1]) end
end

-- reszta kodu GUI (minimalizacja, drag) bez zmian...
