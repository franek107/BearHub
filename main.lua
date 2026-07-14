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
	InfiniteJump = false,
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
	MISC.SpinBot = false; MISC.RemoveJumpDelay = false; MISC.InfiniteJump = false
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
									if ESP.HeadDot.Enabled then
										local headPos, onScreen, depth = w2s(head.Position)
										if onScreen and headPos and depth > 0 then
											d.headDot.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
											d.headDot.BackgroundColor3 = ESP.HeadDot.Color
											d.headDot.Visible = true
										else d.headDot.Visible = false end
									else d.headDot.Visible = false end
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
-- TRIGGERBOT + AIMBOT + HITBOX
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

	local savedMS, savedMO, hitHL = {}, {}, {}
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
	local function findMesh(p) return p:FindFirstChildOfClass("SpecialMesh") or p:FindFirstChildOfClass("BlockMesh") or p:FindFirstChildOfClass("CylinderMesh") end
	local function saveMD(p) local m = findMesh(p); if m and not savedMS[m] then savedMS[m] = m.Scale; if m:IsA("SpecialMesh") then savedMO[m] = m.Offset end end end
	local function restoreM(p)
		local m = findMesh(p)
		if m and savedMS[m] then
			pcall(function() m.Scale = savedMS[m]; if m:IsA("SpecialMesh") and savedMO[m] then m.Offset = savedMO[m] end end)
			savedMS[m] = nil; savedMO[m] = nil
		end
	end
	local function createHL(p)
		if hitHL[p] and hitHL[p].Parent then return hitHL[p] end
		local c = p.Parent; if not c then return nil end
		local hn = "BearHub_HL" .. p.Name
		local ex = c:FindFirstChild(hn); if ex then ex:Destroy() end
		local s = Instance.new("SelectionSphere")
		s.Name = hn; s.Adornee = p
		s.Color3 = Color3.fromRGB(255,60,60); s.SurfaceColor3 = Color3.fromRGB(255,60,60)
		s.SurfaceTransparency = 0.7; s.Transparency = 0.5; s.Parent = c
		hitHL[p] = s; return s
	end
	local function removeHL(p) if hitHL[p] then pcall(function() hitHL[p]:Destroy() end); hitHL[p] = nil end end
	local function expandP(p)
		if not p or not p.Parent then return end
		local sc = 1 + (HITBOX.Size * 0.15)
		local m = findMesh(p)
		if m then saveMD(p); pcall(function() m.Scale = savedMS[m] * sc end) end
		createHL(p)
	end
	local function restoreP(p) if not p or not p.Parent then return end; restoreM(p); removeHL(p) end
	local function restoreAllC(c)
		if not c then return end
		for _, p in ipairs(c:GetChildren()) do if p:IsA("BasePart") then restoreP(p) end end
		for _, ch in ipairs(c:GetChildren()) do if ch.Name:find("BearHub_HL") then pcall(function() ch:Destroy() end) end end
	end
	local function cleanDead()
		local tr = {}; for m in pairs(savedMS) do if not m or not m.Parent then table.insert(tr, m) end end
		for _, m in ipairs(tr) do savedMS[m] = nil; savedMO[m] = nil end
		local tr2 = {}; for p in pairs(hitHL) do if not p or not p.Parent then table.insert(tr2, p) end end
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
						local tp = getHBParts(c); local ts = {}
						for _, p in ipairs(tp) do ts[p] = true end
						for _, p in ipairs(c:GetChildren()) do
							if p:IsA("BasePart") and hitHL[p] and not ts[p] then restoreP(p) end
						end
						for _, p in ipairs(tp) do pcall(function() expandP(p) end) end
					else if ec then restoreAllC(c) end end
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

	-- SpinBot
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

	-- 🔥 Remove Jump Delay + Infinite Jump (poprawione)
	task.spawn(function()
		while true do
			RunService.RenderStepped:Wait()
			if PANIC_TRIGGERED then break end
			if MISC.RemoveJumpDelay or MISC.InfiniteJump then
				local char = player.Character
				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
						if UIS:IsKeyDown(Enum.KeyCode.Space) then
							hum:ChangeState(Enum.HumanoidStateType.Jumping)
						end
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

	-- Rapid Fire Auto‑Clicker
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
	contentTitle.BackgroundTransparency = 1; contentTitle.Text = "Combat"
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
-- PAGES
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

	-- COMBAT PAGE (formerly AimAssistance)
	local aimP=createPage("Combat")
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

	-- MISC PAGE
	local miscP=createPage("Miscellaneous")
	local mSubBar=Instance.new("Frame",miscP); mSubBar.Size=UDim2.new(1,-20,0,30); mSubBar.Position=UDim2.new(0,10,0,0); mSubBar.BackgroundTransparency=1
	local mSbl=Instance.new("UIListLayout",mSubBar); mSbl.FillDirection=Enum.FillDirection.Horizontal; mSbl.Padding=UDim.new(0,8)
	local mSubPF=Instance.new("Frame",miscP); mSubPF.Size=UDim2.new(1,0,1,-40); mSubPF.Position=UDim2.new(0,0,0,38); mSubPF.BackgroundTransparency=1

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

	local mcbP=Instance.new("Frame",mSubPF); mcbP.Size=UDim2.new(1,0,1,0); mcbP.BackgroundTransparency=1; mcbP.Visible=false
	local cbPanel=mkPanel(mcbP,0.48,290,0,5)
	mkSection(cbPanel,"Combat Cheats",1)
	mkCheck(cbPanel,"Super Punch (on tool activate)",MISC,"SuperPunch",2)
	mkCheck(cbPanel,"Semi God (Auto-Heal)",MISC,"SemiGod",3)
	mkCheck(cbPanel,"No Recoil",MISC,"NoRecoil",4)
	mkCheck(cbPanel,"No Spread",MISC,"NoSpread",5)
	mkCheck(cbPanel,"Infinity Ammo",MISC,"InfAmmo",6)

	local mmvP=Instance.new("Frame",mSubPF); mmvP.Size=UDim2.new(1,0,1,0); mmvP.BackgroundTransparency=1; mmvP.Visible=false
	local mvPanel=mkPanel(mmvP,0.6,540,0,5)
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
	mkCheck(mvPanel,"Infinite Jump (hold Space)",MISC,"InfiniteJump",11)

	local mrfP=Instance.new("Frame",mSubPF); mrfP.Size=UDim2.new(1,0,1,0); mrfP.BackgroundTransparency=1; mrfP.Visible=false
	local rfPanel=mkPanel(mrfP,0.48,200,0,5)
	mkSection(rfPanel,"Rapid Fire",1)
	mkCheck(rfPanel,"Enable Rapid Fire",MISC,"RapidFire",2)
	mkSlider(rfPanel,"Multiplier",1,100,20,"x",MISC,"RapidFireMultiplier",3)

	local mfcP=Instance.new("Frame",mSubPF); mfcP.Size=UDim2.new(1,0,1,0); mfcP.BackgroundTransparency=1; mfcP.Visible=false
	local fcPanel=mkPanel(mfcP,0.6,200,0,5)
	mkSection(fcPanel,"Free Camera",1)
	mkCheck(fcPanel,"Enable FreeCam",MISC,"FreeCam",2)
	mkSlider(fcPanel,"FreeCam Speed",1,200,30," m/s",MISC,"FreeCamSpeed",3)

	-- FREECAM HUD
	local freecamActive = false
	local oldMouseBehavior = Enum.MouseBehavior.Default
	local oldMouseIconEnabled = true

	local fcDot = Instance.new("Frame", gui)
	fcDot.Size = UDim2.new(0, 6, 0, 6); fcDot.AnchorPoint = Vector2.new(0.5, 0.5)
	fcDot.Position = UDim2.new(0.5, 0, 0.5, 0); fcDot.BackgroundColor3 = Color3.new(1,1,1)
	fcDot.BorderSizePixel = 0; fcDot.Visible = false; fcDot.ZIndex = 9998
	Instance.new("UICorner", fcDot).CornerRadius = UDim.new(1, 0)

	local fcBar = Instance.new("Frame", gui)
	fcBar.Size = UDim2.new(0, 300, 0, 40); fcBar.AnchorPoint = Vector2.new(0.5, 1)
	fcBar.Position = UDim2.new(0.5, 0, 1, -80); fcBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	fcBar.BorderSizePixel = 0; fcBar.Visible = false; fcBar.ZIndex = 9998
	Instance.new("UICorner", fcBar).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", fcBar).Color = PURPLE

	local fcLabel = Instance.new("TextLabel", fcBar)
	fcLabel.Size = UDim2.new(0, 140, 1, 0); fcLabel.Position = UDim2.new(0, 10, 0, 0)
	fcLabel.BackgroundTransparency = 1; fcLabel.Text = "FREE CAM"
	fcLabel.TextColor3 = Color3.fromRGB(180, 140, 255); fcLabel.Font = Enum.Font.GothamBold
	fcLabel.TextSize = 14; fcLabel.TextXAlignment = Enum.TextXAlignment.Left; fcLabel.ZIndex = 9999

	local fcTpBtn = Instance.new("TextButton", fcBar)
	fcTpBtn.Size = UDim2.new(0, 120, 0, 28); fcTpBtn.Position = UDim2.new(1, -130, 0.5, -14)
	fcTpBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220); fcTpBtn.BorderSizePixel = 0
	fcTpBtn.Text = "Teleport (LMB)"; fcTpBtn.TextColor3 = Color3.new(1,1,1)
	fcTpBtn.Font = Enum.Font.GothamBold; fcTpBtn.TextSize = 12; fcTpBtn.AutoButtonColor = false; fcTpBtn.ZIndex = 9999
	Instance.new("UICorner", fcTpBtn).CornerRadius = UDim.new(0, 6)

	local function stopFreeCam()
		if not freecamActive then return end
		freecamActive = false; fcDot.Visible = false; fcBar.Visible = false
		pcall(function()
			UIS.MouseBehavior = oldMouseBehavior; UIS.MouseIconEnabled = oldMouseIconEnabled
			Camera.CameraType = Enum.CameraType.Custom
			local char = player.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				if root then
					local anchor = root:FindFirstChild("BearHub_FCanchor"); if anchor then anchor:Destroy() end
					local bv = root:FindFirstChild("BearHub_FCvel"); if bv then bv:Destroy() end
				end
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					Camera.CameraSubject = hum
					hum.WalkSpeed = MISC.WalkSpeedEnabled and MISC.WalkSpeed or 16
					hum.JumpPower = MISC.JumpPowerEnabled and MISC.JumpPower or 50
				end
			end
		end)
	end

	local function freecamTeleport()
		if not freecamActive or PANIC_TRIGGERED then return end
		local char = player.Character; if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
		local camPos = Camera.CFrame.Position; local camLook = Camera.CFrame.LookVector
		local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {char}; rayParams.FilterType = Enum.RaycastFilterType.Exclude
		local result = workspace:Raycast(camPos, camLook * 1000, rayParams)
		local targetPos = result and (result.Position + Vector3.new(0, 3, 0)) or (camPos + camLook * 50)
		local savedCF = CFrame.new(targetPos)
		stopFreeCam(); MISC.FreeCam = false
		task.wait(0.1)
		pcall(function()
			root.CFrame = savedCF; root.Velocity = Vector3.zero; root.AssemblyLinearVelocity = Vector3.zero
		end)
	end

	local function startFreeCam()
		if freecamActive or PANIC_TRIGGERED then return end
		local char = player.Character; if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
		freecamActive = true; fcDot.Visible = true; fcBar.Visible = true
		oldMouseBehavior = UIS.MouseBehavior; oldMouseIconEnabled = UIS.MouseIconEnabled
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter; UIS.MouseIconEnabled = false
		local bpos = Instance.new("BodyPosition"); bpos.Name = "BearHub_FCanchor"
		bpos.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bpos.D = 1000; bpos.P = 10000
		bpos.Position = root.Position; bpos.Parent = root
		local bvel = Instance.new("BodyVelocity"); bvel.Name = "BearHub_FCvel"
		bvel.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bvel.Velocity = Vector3.zero; bvel.Parent = root
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 0; hum.JumpPower = 0; hum.JumpHeight = 0 end
		Camera.CameraType = Enum.CameraType.Scriptable
		local look = Camera.CFrame.LookVector
		local camYaw = math.atan2(-look.X, -look.Z)
		local camPitch = math.asin(math.clamp(look.Y, -1, 1))
		local camPos2 = Camera.CFrame.Position
		local sensitivity = 0.006
		task.spawn(function()
			while freecamActive and MISC.FreeCam and not PANIC_TRIGGERED do
				local dt = RunService.RenderStepped:Wait()
				local spd = MISC.FreeCamSpeed or 30
				local mouseDelta = UIS:GetMouseDelta()
				camYaw = camYaw - mouseDelta.X * sensitivity
				camPitch = math.clamp(camPitch - mouseDelta.Y * sensitivity, -math.rad(89), math.rad(89))
				local rotCF = CFrame.Angles(0, camYaw, 0) * CFrame.Angles(camPitch, 0, 0)
				local fw, rt, up = 0, 0, 0
				if UIS:IsKeyDown(Enum.KeyCode.W) then fw = fw + 1 end
				if UIS:IsKeyDown(Enum.KeyCode.S) then fw = fw - 1 end
				if UIS:IsKeyDown(Enum.KeyCode.A) then rt = rt - 1 end
				if UIS:IsKeyDown(Enum.KeyCode.D) then rt = rt + 1 end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then up = up + 1 end
				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then up = up - 1 end
				if fw ~= 0 or rt ~= 0 or up ~= 0 then
					local mv = (rotCF.LookVector * fw + rotCF.RightVector * rt + Vector3.new(0, up, 0))
					if mv.Magnitude > 0 then mv = mv.Unit * spd * dt end
					camPos2 = camPos2 + mv
				end
				pcall(function() Camera.CFrame = CFrame.new(camPos2) * rotCF end)
			end
			stopFreeCam()
		end)
	end

	UIS.InputBegan:Connect(function(inp, gp)
		if PANIC_TRIGGERED or gp then return end
		if freecamActive and inp.UserInputType == Enum.UserInputType.MouseButton1 then freecamTeleport() end
	end)
	fcTpBtn.MouseButton1Click:Connect(function() playClick(); freecamTeleport() end)

	task.spawn(function()
		local wasOn = false
		while true do
			task.wait(0.1); if PANIC_TRIGGERED then break end
			if MISC.FreeCam and not wasOn then startFreeCam()
			elseif not MISC.FreeCam and wasOn then stopFreeCam() end
			wasOn = MISC.FreeCam
		end
	end)
	player.CharacterAdded:Connect(function()
		task.wait(0.5); if freecamActive then stopFreeCam(); MISC.FreeCam = false end
	end)

	local selMS=nil
	local function switchMS(n)
		mqaP.Visible=(n=="Actions"); mcbP.Visible=(n=="Combat")
		mmvP.Visible=(n=="Movement"); mrfP.Visible=(n=="RapidFire"); mfcP.Visible=(n=="FreeCam")
	end
	local function mkMSB(n,dn,o)
		local btn=Instance.new("TextButton",mSubBar); btn.Size=UDim2.new(0,80,1,0); btn.BackgroundTransparency=1; btn.BorderSizePixel=0
		btn.Text=dn; btn.TextColor3=Color3.fromRGB(120,120,130); btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.AutoButtonColor=false; btn.LayoutOrder=o
		local ul=Instance.new("Frame",btn); ul.Size=UDim2.new(1,0,0,2); ul.Position=UDim2.new(0,0,1,-2); ul.BackgroundColor3=PURPLE; ul.BorderSizePixel=0; ul.Visible=false
		btn.MouseButton1Click:Connect(function()
			playClick(); if selMS then selMS.btn.TextColor3=Color3.fromRGB(120,120,130); selMS.ul.Visible=false end
			selMS={btn=btn,ul=ul}; btn.TextColor3=Color3.new(1,1,1); ul.Visible=true; switchMS(n)
		end); return {btn=btn,ul=ul}
	end
	local ms1=mkMSB("Actions","Actions",1); mkMSB("Combat","Combat",2); mkMSB("Movement","Move",3); mkMSB("RapidFire","Rapid",4); mkMSB("FreeCam","FreeCam",5)
	selMS=ms1; ms1.btn.TextColor3=Color3.new(1,1,1); ms1.ul.Visible=true

	-- PLAYERS PAGE
	local plP=createPage("Players")
	local plLF=Instance.new("Frame",plP); plLF.Size=UDim2.new(0.42,0,1,-10); plLF.Position=UDim2.new(0,10,0,5); plLF.BackgroundColor3=DARK; plLF.BorderSizePixel=0; Instance.new("UICorner",plLF).CornerRadius=UDim.new(0,8)
	local plLT=Instance.new("TextLabel",plLF); plLT.Size=UDim2.new(1,-100,0,25); plLT.Position=UDim2.new(0,10,0,5); plLT.BackgroundTransparency=1; plLT.Text="Players in Server"; plLT.TextColor3=Color3.fromRGB(160,160,170); plLT.Font=Enum.Font.GothamBold; plLT.TextSize=14; plLT.TextXAlignment=Enum.TextXAlignment.Left
	local plCL=Instance.new("TextLabel",plLF); plCL.Size=UDim2.new(0,85,0,25); plCL.Position=UDim2.new(1,-90,0,5); plCL.BackgroundTransparency=1; plCL.Text="0 players"; plCL.TextColor3=Color3.fromRGB(150,150,160); plCL.Font=Enum.Font.Gotham; plCL.TextSize=12; plCL.TextXAlignment=Enum.TextXAlignment.Right
	local plS=Instance.new("ScrollingFrame",plLF); plS.Size=UDim2.new(1,-10,1,-40); plS.Position=UDim2.new(0,5,0,32); plS.BackgroundTransparency=1; plS.ScrollBarThickness=3; plS.ScrollBarImageColor3=PURPLE; plS.CanvasSize=UDim2.new(0,0,0,0); plS.AutomaticCanvasSize=Enum.AutomaticSize.Y; plS.BorderSizePixel=0; Instance.new("UIListLayout",plS).Padding=UDim.new(0,4)
	local plIF=Instance.new("Frame",plP); plIF.Size=UDim2.new(0.55,0,1,-10); plIF.Position=UDim2.new(0.44,5,0,5); plIF.BackgroundColor3=DARK; plIF.BorderSizePixel=0; Instance.new("UICorner",plIF).CornerRadius=UDim.new(0,8)
	local plIT=Instance.new("TextLabel",plIF); plIT.Size=UDim2.new(1,-20,0,22); plIT.Position=UDim2.new(0,10,0,8); plIT.BackgroundTransparency=1; plIT.Text="Selected Player"; plIT.TextColor3=Color3.fromRGB(160,160,170); plIT.Font=Enum.Font.GothamBold; plIT.TextSize=14; plIT.TextXAlignment=Enum.TextXAlignment.Left
	local plAF=Instance.new("Frame",plIF); plAF.Size=UDim2.new(0,60,0,60); plAF.Position=UDim2.new(0.5,-30,0,35); plAF.BackgroundColor3=Color3.fromRGB(50,50,60); plAF.BorderSizePixel=0; Instance.new("UICorner",plAF).CornerRadius=UDim.new(1,0)
	local plAv=Instance.new("ImageLabel",plAF); plAv.Size=UDim2.new(1,0,1,0); plAv.BackgroundTransparency=1; plAv.Image=""; plAv.ScaleType=Enum.ScaleType.Crop; Instance.new("UICorner",plAv).CornerRadius=UDim.new(1,0)
	local plNL=Instance.new("TextLabel",plIF); plNL.Size=UDim2.new(1,-20,0,18); plNL.Position=UDim2.new(0,10,0,100); plNL.BackgroundTransparency=1; plNL.Text="No player selected"; plNL.TextColor3=Color3.new(1,1,1); plNL.Font=Enum.Font.GothamBold; plNL.TextSize=14; plNL.TextXAlignment=Enum.TextXAlignment.Center
	local plUL=Instance.new("TextLabel",plIF); plUL.Size=UDim2.new(1,-20,0,15); plUL.Position=UDim2.new(0,10,0,119); plUL.BackgroundTransparency=1; plUL.Text=""; plUL.TextColor3=Color3.fromRGB(150,150,160); plUL.Font=Enum.Font.Gotham; plUL.TextSize=11; plUL.TextXAlignment=Enum.TextXAlignment.Center
	local plIL=Instance.new("TextLabel",plIF); plIL.Size=UDim2.new(0.5,-15,0,15); plIL.Position=UDim2.new(0,10,0,136); plIL.BackgroundTransparency=1; plIL.Text=""; plIL.TextColor3=Color3.fromRGB(150,150,160); plIL.Font=Enum.Font.Gotham; plIL.TextSize=11; plIL.TextXAlignment=Enum.TextXAlignment.Center
	local plDL=Instance.new("TextLabel",plIF); plDL.Size=UDim2.new(0.5,-15,0,15); plDL.Position=UDim2.new(0.5,5,0,136); plDL.BackgroundTransparency=1; plDL.Text=""; plDL.TextColor3=Color3.fromRGB(100,200,255); plDL.Font=Enum.Font.GothamBold; plDL.TextSize=11; plDL.TextXAlignment=Enum.TextXAlignment.Center
	local r1=Instance.new("Frame",plIF); r1.Size=UDim2.new(1,-20,0,28); r1.Position=UDim2.new(0,10,0,160); r1.BackgroundTransparency=1
	local plSB=Instance.new("TextButton",r1); plSB.Size=UDim2.new(0.5,-3,1,0); plSB.BackgroundColor3=PURPLE; plSB.BorderSizePixel=0; plSB.Text="Spectate"; plSB.TextColor3=Color3.new(1,1,1); plSB.Font=Enum.Font.GothamBold; plSB.TextSize=13; plSB.AutoButtonColor=false; Instance.new("UICorner",plSB).CornerRadius=UDim.new(0,6)
	local plUB=Instance.new("TextButton",r1); plUB.Size=UDim2.new(0.5,-3,1,0); plUB.Position=UDim2.new(0.5,3,0,0); plUB.BackgroundColor3=Color3.fromRGB(180,60,60); plUB.BorderSizePixel=0; plUB.Text="Unspectate"; plUB.TextColor3=Color3.new(1,1,1); plUB.Font=Enum.Font.GothamBold; plUB.TextSize=13; plUB.AutoButtonColor=false; Instance.new("UICorner",plUB).CornerRadius=UDim.new(0,6)
	local r2=Instance.new("Frame",plIF); r2.Size=UDim2.new(1,-20,0,28); r2.Position=UDim2.new(0,10,0,193); r2.BackgroundTransparency=1
	local plTB=Instance.new("TextButton",r2); plTB.Size=UDim2.new(0.5,-3,1,0); plTB.BackgroundColor3=Color3.fromRGB(60,140,220); plTB.BorderSizePixel=0; plTB.Text="Teleport"; plTB.TextColor3=Color3.new(1,1,1); plTB.Font=Enum.Font.GothamBold; plTB.TextSize=13; plTB.AutoButtonColor=false; Instance.new("UICorner",plTB).CornerRadius=UDim.new(0,6)
	local plBB=Instance.new("TextButton",r2); plBB.Size=UDim2.new(0.5,-3,1,0); plBB.Position=UDim2.new(0.5,3,0,0); plBB.BackgroundColor3=Color3.fromRGB(80,180,100); plBB.BorderSizePixel=0; plBB.Text="Bring"; plBB.TextColor3=Color3.new(1,1,1); plBB.Font=Enum.Font.GothamBold; plBB.TextSize=13; plBB.AutoButtonColor=false; Instance.new("UICorner",plBB).CornerRadius=UDim.new(0,6)
	local plSW=Instance.new("TextButton",plIF); plSW.Size=UDim2.new(1,-20,0,28); plSW.Position=UDim2.new(0,10,0,226); plSW.BackgroundColor3=Color3.fromRGB(220,150,50); plSW.BorderSizePixel=0; plSW.Text="Switch Places"; plSW.TextColor3=Color3.new(1,1,1); plSW.Font=Enum.Font.GothamBold; plSW.TextSize=13; plSW.AutoButtonColor=false; Instance.new("UICorner",plSW).CornerRadius=UDim.new(0,6)
	local plSL=Instance.new("TextLabel",plIF); plSL.Size=UDim2.new(1,-20,0,20); plSL.Position=UDim2.new(0,10,1,-28); plSL.BackgroundTransparency=1; plSL.Text=""; plSL.TextColor3=Color3.fromRGB(100,200,100); plSL.Font=Enum.Font.GothamBold; plSL.TextSize=12; plSL.TextXAlignment=Enum.TextXAlignment.Center

	local selPl, pBtns = nil, {}
	local function showSt(t,c,d) plSL.Text=t; plSL.TextColor3=c or Color3.fromRGB(100,200,100); if d then task.spawn(function() task.wait(d); if plSL.Text==t then plSL.Text="" end end) end end
	local function getDist(t) if not t or not t.Character then return nil end; local mc=player.Character; if not mc then return nil end; local mr=mc:FindFirstChild("HumanoidRootPart") or mc:FindFirstChild("Torso"); local tr=t.Character:FindFirstChild("HumanoidRootPart") or t.Character:FindFirstChild("Torso"); if not mr or not tr then return nil end; return math.floor((mr.Position-tr.Position).Magnitude) end
	local function updSelInfo() if selPl and selPl.Parent then plNL.Text=selPl.DisplayName or selPl.Name; plUL.Text="@"..selPl.Name; plIL.Text="ID: "..selPl.UserId; local d=getDist(selPl); plDL.Text=d and ("Distance: "..d.."m") or "Distance: N/A"; pcall(function() plAv.Image=Players:GetUserThumbnailAsync(selPl.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end) else plNL.Text="No player selected"; plUL.Text=""; plIL.Text=""; plDL.Text=""; plAv.Image=""; plSL.Text="" end end
	task.spawn(function() while true do task.wait(0.5); if PANIC_TRIGGERED then break end; if selPl and selPl.Parent then local d=getDist(selPl); plDL.Text=d and ("Distance: "..d.."m") or "Distance: N/A" end end end)
	local function selectPl(p) selPl=p; for pp,data in pairs(pBtns) do data.btn.BackgroundColor3=(pp==p) and Color3.fromRGB(70,50,140) or Color3.fromRGB(40,40,50) end; updSelInfo() end
	local function createPB(plr)
		if pBtns[plr] then return end
		local btn=Instance.new("TextButton",plS); btn.Size=UDim2.new(1,-6,0,42); btn.BackgroundColor3=Color3.fromRGB(40,40,50); btn.BorderSizePixel=0; btn.Text=""; btn.AutoButtonColor=false; btn.LayoutOrder=plr.UserId; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
		local af=Instance.new("Frame",btn); af.Size=UDim2.new(0,32,0,32); af.Position=UDim2.new(0,5,0.5,-16); af.BackgroundColor3=Color3.fromRGB(50,50,60); af.BorderSizePixel=0; Instance.new("UICorner",af).CornerRadius=UDim.new(1,0)
		local av=Instance.new("ImageLabel",af); av.Size=UDim2.new(1,0,1,0); av.BackgroundTransparency=1; av.Image=""; av.ScaleType=Enum.ScaleType.Crop; Instance.new("UICorner",av).CornerRadius=UDim.new(1,0)
		task.spawn(function() pcall(function() av.Image=Players:GetUserThumbnailAsync(plr.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) end) end)
		local nl=Instance.new("TextLabel",btn); nl.Size=UDim2.new(1,-45,0,18); nl.Position=UDim2.new(0,42,0,3); nl.BackgroundTransparency=1; nl.Text=plr.DisplayName or plr.Name; nl.TextColor3=Color3.new(1,1,1); nl.Font=Enum.Font.GothamBold; nl.TextSize=13; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.TextTruncate=Enum.TextTruncate.AtEnd
		local ul2=Instance.new("TextLabel",btn); ul2.Size=UDim2.new(1,-45,0,16); ul2.Position=UDim2.new(0,42,0,21); ul2.BackgroundTransparency=1; ul2.Text="@"..plr.Name; ul2.TextColor3=Color3.fromRGB(150,150,160); ul2.Font=Enum.Font.Gotham; ul2.TextSize=11; ul2.TextXAlignment=Enum.TextXAlignment.Left; ul2.TextTruncate=Enum.TextTruncate.AtEnd
		btn.MouseEnter:Connect(function() if selPl~=plr then btn.BackgroundColor3=Color3.fromRGB(50,50,65) end end)
		btn.MouseLeave:Connect(function() if selPl~=plr then btn.BackgroundColor3=Color3.fromRGB(40,40,50) end end)
		btn.MouseButton1Click:Connect(function() playClick(); selectPl(plr) end)
		pBtns[plr]={btn=btn}
	end
	local function removePB(plr) if pBtns[plr] then pcall(function() pBtns[plr].btn:Destroy() end); pBtns[plr]=nil end; if selPl==plr then selPl=nil; updSelInfo() end end
	local function refreshPL()
		local tr={}; for plr in pairs(pBtns) do if not plr or not plr.Parent then table.insert(tr,plr) end end
		for _,plr in ipairs(tr) do removePB(plr) end
		local cnt=0
		for _,plr in ipairs(Players:GetPlayers()) do if plr~=player then if not pBtns[plr] then createPB(plr) end; cnt=cnt+1 end end
		plCL.Text=cnt.." player"..(cnt==1 and "" or "s")
	end
	_G.BearHub_refreshPlayerList=refreshPL
	Players.PlayerAdded:Connect(function(plr) task.wait(0.5); if plr~=player and plr.Parent and not PANIC_TRIGGERED then pcall(refreshPL) end end)
	Players.PlayerRemoving:Connect(function(plr) removePB(plr); task.wait(0.1); pcall(refreshPL) end)
	task.spawn(function() task.wait(1); pcall(refreshPL) end)
	task.spawn(function() while true do task.wait(3); if PANIC_TRIGGERED then break end; pcall(refreshPL) end end)

	plSB.MouseEnter:Connect(function() plSB.BackgroundColor3=Color3.fromRGB(120,90,220) end); plSB.MouseLeave:Connect(function() plSB.BackgroundColor3=PURPLE end)
	plSB.MouseButton1Click:Connect(function() playClick(); if selPl and selPl.Parent then startSpectate(selPl); showSt("SPECTATING",Color3.fromRGB(100,200,100)) else showSt("Select a player first!",Color3.fromRGB(255,100,100),2) end end)
	plUB.MouseEnter:Connect(function() plUB.BackgroundColor3=Color3.fromRGB(210,80,80) end); plUB.MouseLeave:Connect(function() plUB.BackgroundColor3=Color3.fromRGB(180,60,60) end)
	plUB.MouseButton1Click:Connect(function() playClick(); stopSpectate(); showSt("Stopped",Color3.fromRGB(150,150,160),1.5) end)
	plTB.MouseEnter:Connect(function() plTB.BackgroundColor3=Color3.fromRGB(80,160,240) end); plTB.MouseLeave:Connect(function() plTB.BackgroundColor3=Color3.fromRGB(60,140,220) end)
	plTB.MouseButton1Click:Connect(function() playClick(); if selPl and selPl.Parent then local ok,msg=teleportTo(selPl); showSt(msg,ok and Color3.fromRGB(100,200,255) or Color3.fromRGB(255,100,100),2) else showSt("Select a player first!",Color3.fromRGB(255,100,100),2) end end)
	plBB.MouseEnter:Connect(function() plBB.BackgroundColor3=Color3.fromRGB(100,200,120) end); plBB.MouseLeave:Connect(function() plBB.BackgroundColor3=Color3.fromRGB(80,180,100) end)
	plBB.MouseButton1Click:Connect(function() playClick(); if selPl and selPl.Parent then local ok,msg=bringPlayer(selPl); showSt(msg,ok and Color3.fromRGB(120,220,130) or Color3.fromRGB(255,100,100),2) else showSt("Select a player first!",Color3.fromRGB(255,100,100),2) end end)
	plSW.MouseEnter:Connect(function() plSW.BackgroundColor3=Color3.fromRGB(240,170,70) end); plSW.MouseLeave:Connect(function() plSW.BackgroundColor3=Color3.fromRGB(220,150,50) end)
	plSW.MouseButton1Click:Connect(function() playClick(); if selPl and selPl.Parent then local ok,msg=switchPlaces(selPl); showSt(msg,ok and Color3.fromRGB(255,180,80) or Color3.fromRGB(255,100,100),2) else showSt("Select a player first!",Color3.fromRGB(255,100,100),2) end end)

	-- EXPLOITS PAGE
	local exP=createPage("Exploits")
	local exSubBar=Instance.new("Frame",exP); exSubBar.Size=UDim2.new(1,-20,0,30); exSubBar.Position=UDim2.new(0,10,0,0); exSubBar.BackgroundTransparency=1
	local exSbl=Instance.new("UIListLayout",exSubBar); exSbl.FillDirection=Enum.FillDirection.Horizontal; exSbl.Padding=UDim.new(0,15)
	local exSubPF=Instance.new("Frame",exP); exSubPF.Size=UDim2.new(1,0,1,-40); exSubPF.Position=UDim2.new(0,0,0,38); exSubPF.BackgroundTransparency=1

	local exTwP=Instance.new("Frame",exSubPF); exTwP.Size=UDim2.new(1,0,1,0); exTwP.BackgroundTransparency=1; exTwP.Visible=true
	local twPanel=mkPanel(exTwP,0.7,200,0,5)
	mkSection(twPanel,"Teleport Walk",1)

	local twInfoLbl=Instance.new("TextLabel",twPanel); twInfoLbl.Size=UDim2.new(1,-10,0,32); twInfoLbl.BackgroundTransparency=1
	twInfoLbl.TextWrapped=true; twInfoLbl.TextColor3=Color3.fromRGB(130,130,140)
	twInfoLbl.Text="Teleports you forward each frame instead of walking. Harder to detect than WalkSpeed. Use WASD to move."; twInfoLbl.Font=Enum.Font.Gotham; twInfoLbl.TextSize=11; twInfoLbl.TextXAlignment=Enum.TextXAlignment.Left; twInfoLbl.LayoutOrder=2

	mkCheck(twPanel,"Enable Teleport Walk",EXPLOITS,"TeleportWalk",3)
	mkSlider(twPanel,"Step Distance",1,300,5," m",EXPLOITS,"TeleportWalkDistance",4,nil,true)

	local exCtP=Instance.new("Frame",exSubPF); exCtP.Size=UDim2.new(1,0,1,0); exCtP.BackgroundTransparency=1; exCtP.Visible=false
	local ctPanel=mkPanel(exCtP,0.7,220,0,5)
	mkSection(ctPanel,"Click Teleport",1)

	local ctInfoLbl=Instance.new("TextLabel",ctPanel); ctInfoLbl.Size=UDim2.new(1,-10,0,32); ctInfoLbl.BackgroundTransparency=1
	ctInfoLbl.TextWrapped=true; ctInfoLbl.TextColor3=Color3.fromRGB(130,130,140)
	ctInfoLbl.Text="Hold your chosen key and click LMB anywhere to teleport there. Select a key from the dropdown below."; ctInfoLbl.Font=Enum.Font.Gotham; ctInfoLbl.TextSize=11; ctInfoLbl.TextXAlignment=Enum.TextXAlignment.Left; ctInfoLbl.LayoutOrder=2

	mkCheck(ctPanel,"Enable Click Teleport",EXPLOITS,"ClickTeleport",3)

	local ctKH=Instance.new("Frame",ctPanel); ctKH.Size=UDim2.new(1,0,0,30); ctKH.BackgroundTransparency=1; ctKH.LayoutOrder=4
	local ctKLbl=Instance.new("TextLabel",ctKH); ctKLbl.Size=UDim2.new(1,-130,1,0); ctKLbl.Position=UDim2.new(0,5,0,0)
	ctKLbl.BackgroundTransparency=1; ctKLbl.Text="Teleport Key (hold + LMB)"; ctKLbl.TextColor3=Color3.fromRGB(200,200,210)
	ctKLbl.Font=Enum.Font.Gotham; ctKLbl.TextSize=12; ctKLbl.TextXAlignment=Enum.TextXAlignment.Left

	local ctKeyBtn=Instance.new("TextButton",ctKH); ctKeyBtn.Size=UDim2.new(0,110,0,24); ctKeyBtn.Position=UDim2.new(1,-115,0.5,-12)
	ctKeyBtn.BackgroundColor3=Color3.fromRGB(40,40,50); ctKeyBtn.BorderSizePixel=0; ctKeyBtn.Text=EXPLOITS.ClickTeleportKeyName
	ctKeyBtn.TextColor3=Color3.fromRGB(180,180,190); ctKeyBtn.Font=Enum.Font.GothamBold; ctKeyBtn.TextSize=11
	ctKeyBtn.AutoButtonColor=false; Instance.new("UICorner",ctKeyBtn).CornerRadius=UDim.new(0,5)

	local BIND_OPTIONS_CT = {
    {"LPM (MB1)",function() return mbHeld[1] end},
    {"PPM (MB2)",function() return mbHeld[2] end},,
	}
	local KB2={Enum.KeyCode.E,Enum.KeyCode.F,Enum.KeyCode.G,Enum.KeyCode.H,Enum.KeyCode.Q,Enum.KeyCode.R,Enum.KeyCode.T,Enum.KeyCode.X,Enum.KeyCode.Z,Enum.KeyCode.C,Enum.KeyCode.V,Enum.KeyCode.B,Enum.KeyCode.CapsLock,Enum.KeyCode.LeftAlt,Enum.KeyCode.RightAlt,Enum.KeyCode.LeftControl,Enum.KeyCode.RightControl,Enum.KeyCode.LeftShift,Enum.KeyCode.F1,Enum.KeyCode.F2,Enum.KeyCode.F3,Enum.KeyCode.F4,Enum.KeyCode.F5,Enum.KeyCode.F6,Enum.KeyCode.F7,Enum.KeyCode.F8}
	for _,kc in ipairs(KB2) do local kcc=kc; table.insert(BIND_OPTIONS_CT,{kc.Name,function() return UIS:IsKeyDown(kcc) end}) end

	local ctTo=#BIND_OPTIONS_CT+1
	local ctDdF=Instance.new("Frame",ctKH); ctDdF.Size=UDim2.new(0,170,0,math.min(ctTo,8)*28); ctDdF.Position=UDim2.new(1,-175,1,2)
	ctDdF.BackgroundColor3=Color3.fromRGB(30,30,38); ctDdF.BorderSizePixel=0; ctDdF.Visible=false
	ctDdF.ZIndex=200; ctDdF.ClipsDescendants=true; Instance.new("UICorner",ctDdF).CornerRadius=UDim.new(0,6)
	Instance.new("UIStroke",ctDdF).Color=PURPLE
	local ctDdS=Instance.new("ScrollingFrame",ctDdF); ctDdS.Size=UDim2.new(1,0,1,0); ctDdS.BackgroundTransparency=1
	ctDdS.ScrollBarThickness=3; ctDdS.ScrollBarImageColor3=PURPLE; ctDdS.CanvasSize=UDim2.new(0,0,0,ctTo*28)
	ctDdS.ZIndex=201; Instance.new("UIListLayout",ctDdS)
	local ctNb=Instance.new("TextButton",ctDdS); ctNb.Size=UDim2.new(1,0,0,28); ctNb.BackgroundColor3=Color3.fromRGB(30,30,38)
	ctNb.Text=" NONE"; ctNb.TextColor3=Color3.fromRGB(150,150,160); ctNb.Font=Enum.Font.Gotham; ctNb.TextSize=12
	ctNb.TextXAlignment=Enum.TextXAlignment.Left; ctNb.AutoButtonColor=false; ctNb.ZIndex=202; ctNb.BorderSizePixel=0; ctNb.LayoutOrder=0
	ctNb.MouseEnter:Connect(function() ctNb.BackgroundColor3=Color3.fromRGB(50,50,65) end)
	ctNb.MouseLeave:Connect(function() ctNb.BackgroundColor3=Color3.fromRGB(30,30,38) end)
	ctNb.MouseButton1Click:Connect(function()
		playClick(); EXPLOITS.ClickTeleportKeyName="NONE"; EXPLOITS.ClickTeleportKeyCheck=nil; ctKeyBtn.Text="NONE"; ctDdF.Visible=false
	end)
	for i,opt in ipairs(BIND_OPTIONS_CT) do
		local name=opt[1]; local cfn=opt[2]
		local ob=Instance.new("TextButton",ctDdS); ob.Size=UDim2.new(1,0,0,28); ob.BackgroundColor3=Color3.fromRGB(30,30,38)
		ob.Text=" "..name; ob.TextColor3=Color3.fromRGB(180,180,190); ob.Font=Enum.Font.Gotham; ob.TextSize=12
		ob.TextXAlignment=Enum.TextXAlignment.Left; ob.AutoButtonColor=false; ob.ZIndex=202; ob.BorderSizePixel=0; ob.LayoutOrder=i
		ob.MouseEnter:Connect(function() ob.BackgroundColor3=Color3.fromRGB(50,50,65) end)
		ob.MouseLeave:Connect(function() ob.BackgroundColor3=Color3.fromRGB(30,30,38) end)
		ob.MouseButton1Click:Connect(function()
			playClick(); EXPLOITS.ClickTeleportKeyName=name; EXPLOITS.ClickTeleportKeyCheck=cfn; ctKeyBtn.Text=name; ctDdF.Visible=false
		end)
	end
	local ctDdO=false
	ctKeyBtn.MouseButton1Click:Connect(function() playClick(); ctDdO=not ctDdO; ctDdF.Visible=ctDdO end)

	local exAfkP=Instance.new("Frame",exSubPF); exAfkP.Size=UDim2.new(1,0,1,0); exAfkP.BackgroundTransparency=1; exAfkP.Visible=false
	local afkPanel=mkPanel(exAfkP,0.7,160,0,5)
	mkSection(afkPanel,"Anti-AFK",1)
	local afkInfoLbl=Instance.new("TextLabel",afkPanel); afkInfoLbl.Size=UDim2.new(1,-10,0,32); afkInfoLbl.BackgroundTransparency=1
	afkInfoLbl.TextWrapped=true; afkInfoLbl.TextColor3=Color3.fromRGB(130,130,140)
	afkInfoLbl.Text="Prevents the game from kicking you for being AFK. Sends a virtual keypress every 55 seconds."; afkInfoLbl.Font=Enum.Font.Gotham; afkInfoLbl.TextSize=11; afkInfoLbl.TextXAlignment=Enum.TextXAlignment.Left; afkInfoLbl.LayoutOrder=2
	mkCheck(afkPanel,"Enable Anti-AFK",EXPLOITS,"AntiAFK",3)

	local selEx=nil
	local function switchEx(n) exTwP.Visible=(n=="TpWalk"); exCtP.Visible=(n=="ClickTp"); exAfkP.Visible=(n=="AntiAFK") end
	local function mkExB(n,dn,o)
		local btn=Instance.new("TextButton",exSubBar); btn.Size=UDim2.new(0,100,1,0); btn.BackgroundTransparency=1; btn.BorderSizePixel=0
		btn.Text=dn; btn.TextColor3=Color3.fromRGB(120,120,130); btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.AutoButtonColor=false; btn.LayoutOrder=o
		local ul=Instance.new("Frame",btn); ul.Size=UDim2.new(1,0,0,2); ul.Position=UDim2.new(0,0,1,-2); ul.BackgroundColor3=PURPLE; ul.BorderSizePixel=0; ul.Visible=false
		btn.MouseButton1Click:Connect(function()
			playClick(); if selEx then selEx.btn.TextColor3=Color3.fromRGB(120,120,130); selEx.ul.Visible=false end
			selEx={btn=btn,ul=ul}; btn.TextColor3=Color3.new(1,1,1); ul.Visible=true; switchEx(n)
		end); return {btn=btn,ul=ul}
	end
	local ex1=mkExB("TpWalk","Tp Walk",1); mkExB("ClickTp","Click Tp",2); mkExB("AntiAFK","Anti-AFK",3)
	selEx=ex1; ex1.btn.TextColor3=Color3.new(1,1,1); ex1.ul.Visible=true

	-- SETTINGS PAGE
	local stP=createPage("Settings")
	local stSubBar=Instance.new("Frame",stP); stSubBar.Size=UDim2.new(1,-20,0,30); stSubBar.Position=UDim2.new(0,10,0,0); stSubBar.BackgroundTransparency=1
	local stSbl=Instance.new("UIListLayout",stSubBar); stSbl.FillDirection=Enum.FillDirection.Horizontal; stSbl.Padding=UDim.new(0,15)
	local stSubPF=Instance.new("Frame",stP); stSubPF.Size=UDim2.new(1,0,1,-40); stSubPF.Position=UDim2.new(0,0,0,38); stSubPF.BackgroundTransparency=1

	local stGenP=Instance.new("Frame",stSubPF); stGenP.Size=UDim2.new(1,0,1,0); stGenP.BackgroundTransparency=1; stGenP.Visible=true
	local sgPanel=Instance.new("Frame",stGenP); sgPanel.Size=UDim2.new(0.6,0,0,120); sgPanel.Position=UDim2.new(0,10,0,10); sgPanel.BackgroundColor3=DARK; sgPanel.BorderSizePixel=0
	Instance.new("UICorner",sgPanel).CornerRadius=UDim.new(0,8)
	local sgLL=Instance.new("UIListLayout",sgPanel); sgLL.Padding=UDim.new(0,4); sgLL.SortOrder=Enum.SortOrder.LayoutOrder
	local sgPD=Instance.new("UIPadding",sgPanel); sgPD.PaddingTop=UDim.new(0,8); sgPD.PaddingLeft=UDim.new(0,5); sgPD.PaddingRight=UDim.new(0,5)
	mkSection(sgPanel,"Menu Settings",1)

	local MENU_BIND = {KeyName = "RightShift", KeyCode = Enum.KeyCode.RightShift}
	local mbH=Instance.new("Frame",sgPanel); mbH.Size=UDim2.new(1,0,0,30); mbH.BackgroundTransparency=1; mbH.LayoutOrder=2
	local mbLbl=Instance.new("TextLabel",mbH); mbLbl.Size=UDim2.new(0.5,0,1,0); mbLbl.Position=UDim2.new(0,5,0,0)
	mbLbl.BackgroundTransparency=1; mbLbl.Text="Toggle Menu Key"; mbLbl.TextColor3=Color3.fromRGB(200,200,210)
	mbLbl.Font=Enum.Font.Gotham; mbLbl.TextSize=13; mbLbl.TextXAlignment=Enum.TextXAlignment.Left
	local mbBtn=Instance.new("TextButton",mbH); mbBtn.Size=UDim2.new(0,120,0,24); mbBtn.Position=UDim2.new(1,-125,0.5,-12)
	mbBtn.BackgroundColor3=Color3.fromRGB(40,40,50); mbBtn.BorderSizePixel=0; mbBtn.Text=MENU_BIND.KeyName
	mbBtn.TextColor3=Color3.fromRGB(180,180,190); mbBtn.Font=Enum.Font.GothamBold; mbBtn.TextSize=11
	mbBtn.AutoButtonColor=false; Instance.new("UICorner",mbBtn).CornerRadius=UDim.new(0,5)

	local mbListening = false
	mbBtn.MouseButton1Click:Connect(function()
		playClick(); if mbListening then return end
		mbListening = true; mbBtn.Text = "Press a key..."; mbBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
	end)
	UIS.InputBegan:Connect(function(inp, gp)
		if mbListening and inp.UserInputType == Enum.UserInputType.Keyboard then
			mbListening = false; MENU_BIND.KeyCode = inp.KeyCode; MENU_BIND.KeyName = inp.KeyCode.Name
			mbBtn.Text = MENU_BIND.KeyName; mbBtn.TextColor3 = Color3.fromRGB(180,180,190)
		end
	end)
	_G.BearHub_getMenuBind = function() return MENU_BIND.KeyCode end

	local stPanicP=Instance.new("Frame",stSubPF); stPanicP.Size=UDim2.new(1,0,1,0); stPanicP.BackgroundTransparency=1; stPanicP.Visible=false
	local panicC=Instance.new("Frame",stPanicP); panicC.Size=UDim2.new(0.7,0,0,300); panicC.Position=UDim2.new(0.15,0,0,20); panicC.BackgroundColor3=DARK; panicC.BorderSizePixel=0; Instance.new("UICorner",panicC).CornerRadius=UDim.new(0,10)
	local pI=Instance.new("TextLabel",panicC); pI.Size=UDim2.new(1,0,0,50); pI.Position=UDim2.new(0,0,0,20); pI.BackgroundTransparency=1; pI.Text="⚠️"; pI.TextColor3=Color3.fromRGB(255,60,60); pI.Font=Enum.Font.GothamBold; pI.TextSize=40
	local pT=Instance.new("TextLabel",panicC); pT.Size=UDim2.new(1,-20,0,25); pT.Position=UDim2.new(0,10,0,75); pT.BackgroundTransparency=1; pT.Text="PANIC BUTTON"; pT.TextColor3=Color3.fromRGB(255,80,80); pT.Font=Enum.Font.GothamBold; pT.TextSize=20
	local pD=Instance.new("TextLabel",panicC); pD.Size=UDim2.new(1,-30,0,60); pD.Position=UDim2.new(0,15,0,105); pD.BackgroundTransparency=1; pD.TextWrapped=true; pD.Text="Instantly destroys the entire script, removes all traces (ESP, hitbox, GUI, sounds). It will look like you never used any cheats."; pD.TextColor3=Color3.fromRGB(160,160,170); pD.Font=Enum.Font.Gotham; pD.TextSize=12
	local pBtn=Instance.new("TextButton",panicC); pBtn.Size=UDim2.new(0.6,0,0,60); pBtn.Position=UDim2.new(0.2,0,0,185); pBtn.BackgroundColor3=Color3.fromRGB(200,30,30); pBtn.BorderSizePixel=0; pBtn.Text="SPIERDALAJ"; pBtn.TextColor3=Color3.new(1,1,1); pBtn.Font=Enum.Font.GothamBold; pBtn.TextSize=24; pBtn.AutoButtonColor=false; Instance.new("UICorner",pBtn).CornerRadius=UDim.new(0,10)
	local pSt=Instance.new("UIStroke",pBtn); pSt.Color=Color3.fromRGB(255,60,60); pSt.Thickness=2
	pBtn.MouseEnter:Connect(function() pBtn.BackgroundColor3=Color3.fromRGB(255,40,40); pSt.Color=Color3.fromRGB(255,100,100) end)
	pBtn.MouseLeave:Connect(function() pBtn.BackgroundColor3=Color3.fromRGB(200,30,30); pSt.Color=Color3.fromRGB(255,60,60) end)
	pBtn.MouseButton1Click:Connect(function() PANIC_DESTROY() end)

	-- CONFIG PAGE
	local stConfigP = Instance.new("Frame", stSubPF)
	stConfigP.Size = UDim2.new(1,0,1,0); stConfigP.BackgroundTransparency = 1; stConfigP.Visible = false

	local cfgPanel = Instance.new("Frame", stConfigP)
	cfgPanel.Size = UDim2.new(0.8, 0, 0.7, 0)
	cfgPanel.Position = UDim2.new(0.1, 0, 0.15, 0)
	cfgPanel.BackgroundColor3 = DARK
	cfgPanel.BorderSizePixel = 0
	Instance.new("UICorner", cfgPanel).CornerRadius = UDim.new(0, 8)
	local cfgLL = Instance.new("UIListLayout", cfgPanel)
	cfgLL.Padding = UDim.new(0, 6); cfgLL.SortOrder = Enum.SortOrder.LayoutOrder
	local cfgPD = Instance.new("UIPadding", cfgPanel)
	cfgPD.PaddingTop = UDim.new(0, 10); cfgPD.PaddingLeft = UDim.new(0, 10); cfgPD.PaddingRight = UDim.new(0, 10)

	local cfgTitle = Instance.new("TextLabel", cfgPanel)
	cfgTitle.Size = UDim2.new(1, 0, 0, 24)
	cfgTitle.BackgroundTransparency = 1
	cfgTitle.Text = "Configuration Manager"
	cfgTitle.TextColor3 = Color3.fromRGB(200,200,210)
	cfgTitle.Font = Enum.Font.GothamBold
	cfgTitle.TextSize = 15
	cfgTitle.LayoutOrder = 1

	local nameFrame = Instance.new("Frame", cfgPanel)
	nameFrame.Size = UDim2.new(1, 0, 0, 36)
	nameFrame.BackgroundTransparency = 1
	nameFrame.LayoutOrder = 2

	local nameLabel = Instance.new("TextLabel", nameFrame)
	nameLabel.Size = UDim2.new(0, 80, 1, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "Config name:"
	nameLabel.TextColor3 = Color3.fromRGB(180,180,190)
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left

	local nameBox = Instance.new("TextBox", nameFrame)
	nameBox.Size = UDim2.new(1, -85, 1, 0)
	nameBox.Position = UDim2.new(0, 85, 0, 0)
	nameBox.BackgroundColor3 = Color3.fromRGB(40,40,50)
	nameBox.BorderSizePixel = 0
	nameBox.Text = "default"
	nameBox.TextColor3 = Color3.new(1,1,1)
	nameBox.Font = Enum.Font.Gotham
	nameBox.TextSize = 14
	nameBox.PlaceholderText = "Enter config name..."
	Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 5)

	local cfgList = Instance.new("ScrollingFrame", cfgPanel)
	cfgList.Size = UDim2.new(1, 0, 0, 100)
	cfgList.BackgroundColor3 = Color3.fromRGB(30,30,38)
	cfgList.BorderSizePixel = 0
	cfgList.ScrollBarThickness = 4
	cfgList.ScrollBarImageColor3 = PURPLE
	cfgList.CanvasSize = UDim2.new(0, 0, 0, 0)
	cfgList.LayoutOrder = 3
	Instance.new("UICorner", cfgList).CornerRadius = UDim.new(0, 6)
	local cfgListLayout = Instance.new("UIListLayout", cfgList)
	cfgListLayout.Padding = UDim.new(0, 4)
	cfgListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local btnFrameCfg = Instance.new("Frame", cfgPanel)
	btnFrameCfg.Size = UDim2.new(1, 0, 0, 40)
	btnFrameCfg.BackgroundTransparency = 1
	btnFrameCfg.LayoutOrder = 4

	local saveBtn = Instance.new("TextButton", btnFrameCfg)
	saveBtn.Size = UDim2.new(0, 100, 1, 0)
	saveBtn.Position = UDim2.new(0, 0, 0, 0)
	saveBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
	saveBtn.BorderSizePixel = 0
	saveBtn.Text = "Save"
	saveBtn.TextColor3 = Color3.new(1,1,1)
	saveBtn.Font = Enum.Font.GothamBold
	saveBtn.TextSize = 13
	saveBtn.AutoButtonColor = false
	Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

	local loadBtn = Instance.new("TextButton", btnFrameCfg)
	loadBtn.Size = UDim2.new(0, 100, 1, 0)
	loadBtn.Position = UDim2.new(0, 110, 0, 0)
	loadBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 100)
	loadBtn.BorderSizePixel = 0
	loadBtn.Text = "Load"
	loadBtn.TextColor3 = Color3.new(1,1,1)
	loadBtn.Font = Enum.Font.GothamBold
	loadBtn.TextSize = 13
	loadBtn.AutoButtonColor = false
	Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)

	local deleteBtn = Instance.new("TextButton", btnFrameCfg)
	deleteBtn.Size = UDim2.new(0, 100, 1, 0)
	deleteBtn.Position = UDim2.new(0, 220, 0, 0)
	deleteBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	deleteBtn.BorderSizePixel = 0
	deleteBtn.Text = "Delete"
	deleteBtn.TextColor3 = Color3.new(1,1,1)
	deleteBtn.Font = Enum.Font.GothamBold
	deleteBtn.TextSize = 13
	deleteBtn.AutoButtonColor = false
	Instance.new("UICorner", deleteBtn).CornerRadius = UDim.new(0, 6)

	local statusCfg = Instance.new("TextLabel", cfgPanel)
	statusCfg.Size = UDim2.new(1, 0, 0, 20)
	statusCfg.BackgroundTransparency = 1
	statusCfg.Text = ""
	statusCfg.TextColor3 = Color3.fromRGB(100,200,100)
	statusCfg.Font = Enum.Font.GothamBold
	statusCfg.TextSize = 12
	statusCfg.TextXAlignment = Enum.TextXAlignment.Center
	statusCfg.LayoutOrder = 5

	local function refreshCfgList()
    -- wyczyść starą listę
    for _, child in ipairs(cfgList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    -- pobierz listę plików (tylko .json)
    local files = {}
    pcall(function()
        local raw = listfiles("BearHub_Configs/")
        if raw then
            for _, f in ipairs(raw) do
                if f:match("%.json$") then
                    local name = f:match("([^/]+)%.json$")
                    if name then table.insert(files, name) end
                end
            end
        end
    end)   -- <--- WAŻNE: tutaj zamykamy pcall
    -- jeśli pusta lista
    if #files == 0 then
        local empty = Instance.new("TextLabel", cfgList)
        empty.Size = UDim2.new(1, -10, 0, 30)
        empty.BackgroundTransparency = 1
        empty.Text = "No configs found"
        empty.TextColor3 = Color3.fromRGB(150,150,160)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 13
        empty.TextXAlignment = Enum.TextXAlignment.Center
        empty.LayoutOrder = 1
    else
        -- sortuj alfabetycznie
        table.sort(files)
        for i, name in ipairs(files) do
            local btn = Instance.new("TextButton", cfgList)
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
            btn.BorderSizePixel = 0
            btn.Text = name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.AutoButtonColor = false
            btn.LayoutOrder = i
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60,60,75) end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(40,40,50) end)
            btn.MouseButton1Click:Connect(function()
                playClick()
                nameBox.Text = name
            end)
        end
    end
    cfgList.CanvasSize = UDim2.new(0, 0, 0, #files * 34 + 10)
end

	local function saveConfig(name)
		local data = {
			ESP = ESP,
			TRIGGERBOT = TRIGGERBOT,
			AIMBOT = AIMBOT,
			HITBOX = HITBOX,
			MISC = MISC,
			EXPLOITS = EXPLOITS,
		}
		local json = game:GetService("HttpService"):JSONEncode(data)
		local path = "BearHub_Configs/" .. name .. ".json"
		local ok, err = pcall(function() writefile(path, json) end)
		if ok then
			statusCfg.Text = "Config saved: " .. name
			statusCfg.TextColor3 = Color3.fromRGB(100,200,100)
			refreshCfgList()
		else
			statusCfg.Text = "Save failed: " .. tostring(err)
			statusCfg.TextColor3 = Color3.fromRGB(255,100,100)
		end
	end

	local function loadConfig(name)
		local path = "BearHub_Configs/" .. name .. ".json"
		local ok, content = pcall(function() return readfile(path) end)
		if not ok or not content then
			statusCfg.Text = "Config not found: " .. name
			statusCfg.TextColor3 = Color3.fromRGB(255,100,100)
			return
		end
		local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(content) end)
		if not ok2 then
			statusCfg.Text = "Invalid config file"
			statusCfg.TextColor3 = Color3.fromRGB(255,100,100)
			return
		end
		if data.ESP then for k,v in pairs(data.ESP) do ESP[k]=v end end
		if data.TRIGGERBOT then for k,v in pairs(data.TRIGGERBOT) do TRIGGERBOT[k]=v end end
		if data.AIMBOT then for k,v in pairs(data.AIMBOT) do AIMBOT[k]=v end end
		if data.HITBOX then for k,v in pairs(data.HITBOX) do HITBOX[k]=v end end
		if data.MISC then for k,v in pairs(data.MISC) do MISC[k]=v end end
		if data.EXPLOITS then for k,v in pairs(data.EXPLOITS) do EXPLOITS[k]=v end end
		statusCfg.Text = "Config loaded: " .. name
		statusCfg.TextColor3 = Color3.fromRGB(100,200,100)
		fullRefresh()
	end

	local function deleteConfig(name)
		local path = "BearHub_Configs/" .. name .. ".json"
		local ok, err = pcall(function() delfile(path) end)
		if ok then
			statusCfg.Text = "Config deleted: " .. name
			statusCfg.TextColor3 = Color3.fromRGB(100,200,100)
			refreshCfgList()
		else
			statusCfg.Text = "Delete failed: " .. tostring(err)
			statusCfg.TextColor3 = Color3.fromRGB(255,100,100)
		end
	end

	saveBtn.MouseButton1Click:Connect(function()
		playClick()
		local name = nameBox.Text:match("^%s*(.-)%s*$")
		if name == "" then
			statusCfg.Text = "Enter a config name"
			statusCfg.TextColor3 = Color3.fromRGB(255,100,100)
			return
		end
		saveConfig(name)
	end)

	loadBtn.MouseButton1Click:Connect(function()
		playClick()
		local name = nameBox.Text:match("^%s*(.-)%s*$")
		if name == "" then
			statusCfg.Text = "Enter a config name"
			statusCfg.TextColor3 = Color3.fromRGB(255,100,100)
			return
		end
		loadConfig(name)
	end)

	deleteBtn.MouseButton1Click:Connect(function()
		playClick()
		local name = nameBox.Text:match("^%s*(.-)%s*$")
		if name == "" then
			statusCfg.Text = "Enter a config name"
			statusCfg.TextColor3 = Color3.fromRGB(255,100,100)
			return
		end
		deleteConfig(name)
	end)

	refreshCfgList()

	local selSS=nil
	local function switchSS(n)
		stGenP.Visible = (n=="General")
		stPanicP.Visible = (n=="Panic")
		stConfigP.Visible = (n=="Config")
	end
	local function mkSSB(n,o)
		local btn=Instance.new("TextButton",stSubBar); btn.Size=UDim2.new(0,100,1,0); btn.BackgroundTransparency=1; btn.BorderSizePixel=0; btn.Text=n; btn.TextColor3=Color3.fromRGB(120,120,130); btn.Font=Enum.Font.GothamBold; btn.TextSize=14; btn.AutoButtonColor=false; btn.LayoutOrder=o
		local ul=Instance.new("Frame",btn); ul.Size=UDim2.new(1,0,0,2); ul.Position=UDim2.new(0,0,1,-2); ul.BackgroundColor3=PURPLE; ul.BorderSizePixel=0; ul.Visible=false
		btn.MouseButton1Click:Connect(function() playClick(); if selSS then selSS.btn.TextColor3=Color3.fromRGB(120,120,130); selSS.ul.Visible=false end; selSS={btn=btn,ul=ul}; btn.TextColor3=Color3.new(1,1,1); ul.Visible=true; switchSS(n) end)
		return {btn=btn,ul=ul}
	end
	local ss1=mkSSB("General",1); mkSSB("Panic",2); mkSSB("Config",3)
	selSS=ss1; ss1.btn.TextColor3=Color3.new(1,1,1); ss1.ul.Visible=true

	-- EXECUTOR PAGE
	local exeP = createPage("Executor")

	local exePanel = Instance.new("Frame", exeP)
	exePanel.Size = UDim2.new(1, -20, 1, -20)
	exePanel.Position = UDim2.new(0, 10, 0, 10)
	exePanel.BackgroundColor3 = DARK
	exePanel.BorderSizePixel = 0
	Instance.new("UICorner", exePanel).CornerRadius = UDim.new(0, 8)

	local exeTitle = Instance.new("TextLabel", exePanel)
	exeTitle.Size = UDim2.new(1, -20, 0, 30)
	exeTitle.Position = UDim2.new(0, 10, 0, 8)
	exeTitle.BackgroundTransparency = 1
	exeTitle.Text = "Lua Executor"
	exeTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
	exeTitle.Font = Enum.Font.GothamBold
	exeTitle.TextSize = 16
	exeTitle.TextXAlignment = Enum.TextXAlignment.Left

	local codeScroll = Instance.new("ScrollingFrame", exePanel)
	codeScroll.Size = UDim2.new(1, -20, 1, -110)
	codeScroll.Position = UDim2.new(0, 10, 0, 45)
	codeScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	codeScroll.BorderSizePixel = 0
	codeScroll.ScrollBarThickness = 5
	codeScroll.ScrollBarImageColor3 = PURPLE
	codeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	Instance.new("UICorner", codeScroll).CornerRadius = UDim.new(0, 6)

	local canvasFrame = Instance.new("Frame", codeScroll)
	canvasFrame.Size = UDim2.new(1, 0, 0, 0)
	canvasFrame.BackgroundTransparency = 1

	local lineNums = Instance.new("TextLabel", canvasFrame)
	lineNums.Size = UDim2.new(0, 45, 1, 0)
	lineNums.Position = UDim2.new(0, 0, 0, 0)
	lineNums.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	lineNums.BorderSizePixel = 0
	lineNums.Font = Enum.Font.Code
	lineNums.TextSize = 14
	lineNums.TextColor3 = Color3.fromRGB(120, 120, 130)
	lineNums.TextXAlignment = Enum.TextXAlignment.Right
	lineNums.TextYAlignment = Enum.TextYAlignment.Top
	lineNums.Text = "1"
	lineNums.RichText = false
	Instance.new("UICorner", lineNums).CornerRadius = UDim.new(0, 4)

	local codeBox = Instance.new("TextBox", canvasFrame)
	codeBox.Size = UDim2.new(1, -50, 1, 0)
	codeBox.Position = UDim2.new(0, 50, 0, 0)
	codeBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	codeBox.BorderSizePixel = 0
	codeBox.Font = Enum.Font.Code
	codeBox.TextSize = 14
	codeBox.TextColor3 = Color3.new(1, 1, 1)
	codeBox.TextXAlignment = Enum.TextXAlignment.Left
	codeBox.TextYAlignment = Enum.TextYAlignment.Top
	codeBox.ClearTextOnFocus = false
	codeBox.MultiLine = true
	codeBox.TextWrapped = false
	codeBox.Text = ""
	codeBox.RichText = false
	Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0, 4)

	local function updateLineNumbers()
		local text = codeBox.Text
		local lineCount = 1
		if text ~= "" then
			lineCount = select(2, text:gsub("\n", "\n")) + 1
		end
		local nums = {}
		for i = 1, lineCount do
			nums[i] = tostring(i)
		end
		lineNums.Text = table.concat(nums, "\n")
		local digits = #tostring(lineCount)
		local numWidth = math.max(35, digits * 10 + 10)
		lineNums.Size = UDim2.new(0, numWidth, 1, 0)
		codeBox.Position = UDim2.new(0, numWidth + 5, 0, 0)
		codeBox.Size = UDim2.new(1, -(numWidth + 10), 1, 0)
		local lineHeight = 22
		local totalHeight = math.max(lineCount * lineHeight + 20, 100)
		canvasFrame.Size = UDim2.new(1, 0, 0, totalHeight)
		codeScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
	end

	codeBox:GetPropertyChangedSignal("Text"):Connect(updateLineNumbers)
	updateLineNumbers()

	local btnFrameExe = Instance.new("Frame", exePanel)
	btnFrameExe.Size = UDim2.new(1, -20, 0, 36)
	btnFrameExe.Position = UDim2.new(0, 10, 1, -45)
	btnFrameExe.BackgroundTransparency = 1

	local executeBtn = Instance.new("TextButton", btnFrameExe)
	executeBtn.Size = UDim2.new(0, 100, 1, 0)
	executeBtn.Position = UDim2.new(1, -220, 0, 0)
	executeBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
	executeBtn.BorderSizePixel = 0
	executeBtn.Text = "Execute"
	executeBtn.TextColor3 = Color3.new(1, 1, 1)
	executeBtn.Font = Enum.Font.GothamBold
	executeBtn.TextSize = 13
	executeBtn.AutoButtonColor = false
	Instance.new("UICorner", executeBtn).CornerRadius = UDim.new(0, 6)

	local clearBtn = Instance.new("TextButton", btnFrameExe)
	clearBtn.Size = UDim2.new(0, 100, 1, 0)
	clearBtn.Position = UDim2.new(1, -110, 0, 0)
	clearBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	clearBtn.BorderSizePixel = 0
	clearBtn.Text = "Clear"
	clearBtn.TextColor3 = Color3.new(1, 1, 1)
	clearBtn.Font = Enum.Font.GothamBold
	clearBtn.TextSize = 13
	clearBtn.AutoButtonColor = false
	Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)

	local statusExe = Instance.new("TextLabel", btnFrameExe)
	statusExe.Size = UDim2.new(1, -250, 1, 0)
	statusExe.Position = UDim2.new(0, 5, 0, 0)
	statusExe.BackgroundTransparency = 1
	statusExe.Text = ""
	statusExe.TextColor3 = Color3.fromRGB(100, 200, 100)
	statusExe.Font = Enum.Font.GothamBold
	statusExe.TextSize = 12
	statusExe.TextXAlignment = Enum.TextXAlignment.Left

	executeBtn.MouseEnter:Connect(function() executeBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 240) end)
	executeBtn.MouseLeave:Connect(function() executeBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220) end)
	executeBtn.MouseButton1Click:Connect(function()
		playClick()
		local code = codeBox.Text
		if code:match("^%s*$") then
			statusExe.Text = "No code to execute"
			statusExe.TextColor3 = Color3.fromRGB(255, 100, 100)
			return
		end
		local fn, err = loadstring(code)
		if not fn then
			statusExe.Text = "Error: " .. tostring(err)
			statusExe.TextColor3 = Color3.fromRGB(255, 100, 100)
			return
		end
		local success, result = pcall(fn)
		if success then
			statusExe.Text = "Executed successfully" .. (result ~= nil and " | Output: " .. tostring(result) or "")
			statusExe.TextColor3 = Color3.fromRGB(100, 200, 100)
		else
			statusExe.Text = "Error: " .. tostring(result)
			statusExe.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
	end)

	clearBtn.MouseEnter:Connect(function() clearBtn.BackgroundColor3 = Color3.fromRGB(230, 80, 80) end)
	clearBtn.MouseLeave:Connect(function() clearBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60) end)
	clearBtn.MouseButton1Click:Connect(function()
		playClick()
		codeBox.Text = ""
		statusExe.Text = ""
	end)

	-- AUTOFARM PAGE
	local afP = createPage("AutoFarm")
	local afL = Instance.new("TextLabel", afP)
	afL.Size = UDim2.new(1, -20, 0, 40)
	afL.Position = UDim2.new(0, 10, 0, 10)
	afL.BackgroundTransparency = 1
	afL.Text = "AutoFarm - Coming Soon"
	afL.TextColor3 = Color3.fromRGB(100, 100, 110)
	afL.Font = Enum.Font.Gotham
	afL.TextSize = 16
end

--============================================================
-- TABS + DRAG
--============================================================
local tabsFrame = sidebar:FindFirstChild("TabsFrame")
local tabsData = {{"Combat"},{"Visualization"},{"Miscellaneous"},{"Exploits"},{"Players"},{"Settings"},{"AutoFarm"},{"Executor"}}
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

local ORIGINAL_SIZE = UDim2.new(0, 780, 0, 530)
local BALL_SIZE = UDim2.new(0, 60, 0, 60)

local miniBall = Instance.new("ImageButton", gui)
miniBall.Size = BALL_SIZE; miniBall.Position = UDim2.new(0, 40, 0.5, -30)
miniBall.BackgroundColor3 = Color3.fromRGB(30, 25, 30); miniBall.BorderSizePixel = 0
miniBall.Image = BEAR_ICON; miniBall.ImageColor3 = Color3.new(1,1,1)
miniBall.ScaleType = Enum.ScaleType.Fit; miniBall.AutoButtonColor = false
miniBall.Visible = false; miniBall.ClipsDescendants = true
Instance.new("UICorner", miniBall).CornerRadius = UDim.new(1, 0)

local minimized = false; local animating = false
local TW = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local lastMainPos = main.Position

local function minimize()
	if animating or minimized then return end
	animating = true; minimized = true; playClick()
	lastMainPos = main.Position
	local ap = main.AbsolutePosition; local as = main.AbsoluteSize
	local cx = ap.X + as.X/2; local cy = ap.Y + as.Y/2
	miniBall.Position = UDim2.new(0, cx-30, 0, cy-30)
	miniBall.Size = UDim2.new(0,0,0,0); miniBall.ImageTransparency = 1; miniBall.Visible = true
	local t = TweenService:Create(main, TW, {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0,cx,0,cy)})
	t:Play()
	t.Completed:Connect(function()
		main.Visible = false
		TweenService:Create(miniBall, TW, {Size=BALL_SIZE, ImageTransparency=0}):Play()
		task.wait(0.4); animating = false
	end)
end

local function restore()
	if animating or not minimized then return end
	animating = true; minimized = false; playClick()
	local t2 = TweenService:Create(miniBall, TW, {Size=UDim2.new(0,0,0,0), ImageTransparency=1})
	t2:Play()
	t2.Completed:Connect(function()
		miniBall.Visible = false; miniBall.Size = BALL_SIZE; miniBall.ImageTransparency = 0
		local ap2 = miniBall.AbsolutePosition; local as2 = miniBall.AbsoluteSize
		local cx2 = ap2.X + as2.X/2; local cy2 = ap2.Y + as2.Y/2
		main.Size = UDim2.new(0,0,0,0); main.Position = UDim2.new(0,cx2,0,cy2); main.Visible = true
		TweenService:Create(main, TW, {Size=ORIGINAL_SIZE, Position=lastMainPos}):Play()
		task.wait(0.4); animating = false
	end)
end

UIS.InputBegan:Connect(function(inp, gp)
	if PANIC_TRIGGERED or gp then return end
	local bindKey = _G.BearHub_getMenuBind and _G.BearHub_getMenuBind() or Enum.KeyCode.RightShift
	if inp.KeyCode == bindKey then
		if minimized then restore() else minimize() end
	end
end)

local dragging, dragStart, startPos, mainDragMoved = false, nil, nil, false
sidebar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; mainDragMoved = false; dragStart = i.Position; startPos = main.Position
	end
end)

local ballDrag, ballStart, ballPos, ballMoved, lastClickTime = false, nil, nil, false, 0
miniBall.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		ballDrag = true; ballMoved = false; ballStart = i.Position; ballPos = miniBall.Position
	end
end)

UIS.InputChanged:Connect(function(inp)
	if PANIC_TRIGGERED then return end
	if inp.UserInputType == Enum.UserInputType.MouseMovement then
		if dragging and dragStart and startPos then
			local d = inp.Position - dragStart
			if d.Magnitude > 3 and not mainDragMoved then mainDragMoved = true; startDragSound() end
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
		end
		if ballDrag and ballStart and ballPos then
			local d = inp.Position - ballStart
			if d.Magnitude > 3 and not ballMoved then ballMoved = true; startDragSound() end
			miniBall.Position = UDim2.new(ballPos.X.Scale, ballPos.X.Offset+d.X, ballPos.Y.Scale, ballPos.Y.Offset+d.Y)
		end
		if _G.BearHub_canvasDrag then _G.BearHub_updCPValues(inp.Position.X, inp.Position.Y, "canvas") end
		if _G.BearHub_hueDrag then _G.BearHub_updCPValues(inp.Position.X, inp.Position.Y, "hue") end
		if _G.BearHub_allSliders then
			for _, s in ipairs(_G.BearHub_allSliders) do if s.isDragging() then s.update(inp.Position.X) end end
		end
	end
end)

UIS.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		if dragging then
			if mainDragMoved then stopDragSound(); lastMainPos = main.Position end
			dragging = false; mainDragMoved = false
		end
		if not PANIC_TRIGGERED then
			_G.BearHub_canvasDrag = false; _G.BearHub_hueDrag = false
			if _G.BearHub_allSliders then
				for _, s in ipairs(_G.BearHub_allSliders) do s.setDrag(false) end
			end
		end
		if ballDrag then
			if ballMoved then stopDragSound() end
			ballDrag = false
			if not ballMoved then
				local now = tick()
				if now - lastClickTime < 0.35 then restore(); lastClickTime = 0 else lastClickTime = now end
			end
		end
	end
end)
