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
	RapidFire = false, RapidFireLevel = 20,
	WalkSpeedEnabled = false, WalkSpeed = 16,
	JumpPowerEnabled = false, JumpPower = 50,
	FreeCam = false, FreeCamSpeed = 30,
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
			distance=makeText(h, 12), inventory=makeText(h, 11)
		}
		for i = 1, 12 do d.skeleton[i] = makeLine(h) end
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
		if plr.Character then for _, c in ipairs(plr.Character:GetChildren()) do if c:IsA("Tool") then table.insert(items, c.Name) end end end
		local bp = plr:FindFirstChildOfClass("Backpack")
		if bp then for _, c in ipairs(bp:GetChildren()) do if c:IsA("Tool") then table.insert(items, c.Name) end end end
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
											local it = table.concat(items, ", ")
											if #it > 40 then it = string.sub(it, 1, 37) .. "..." end
											d.inventory.Text = "[" .. it .. "]"; d.inventory.TextColor3 = ESP.Inventory.Color
										else d.inventory.Text = "[Empty]"; d.inventory.TextColor3 = Color3.fromRGB(120, 120, 130) end
										d.inventory.Position = UDim2.new(0, sp.X, 0, bY + 12 + bo)
										d.inventory.Size = UDim2.new(0, 300, 0, 20); d.inventory.Visible = true; bo = bo + 16
									else d.inventory.Visible = false end
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
													local a = getPos(char, bones[i][1])
													local b = getPos(char, bones[i][2])
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
									else
										for i = 1, 12 do if d.skeleton[i] then d.skeleton[i].Visible = false end end
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
		local hn = "BearHub_HL_" .. p.Name
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
		for _, ch in ipairs(c:GetChildren()) do if ch.Name:find("BearHub_HL_") then pcall(function() ch:Destroy() end) end end
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
-- MISC (BEZ FREECAM - przeniesiony niżej)
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

	-- Walk Speed + Jump Power
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
	player.CharacterAdded:Connect(function()
		task.wait(0.5); lastWSEnabled = false; lastJPEnabled = false
	end)

	-- NoClip + Fly
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

	-- Tools Hook
	local hookedTools = {}
	local function hookTool(tool)
		if not tool or not tool:IsA("Tool") or hookedTools[tool] then return end
		hookedTools[tool] = true
		task.spawn(function()
			while tool.Parent do
				task.wait(0.05); if PANIC_TRIGGERED then break end
				if MISC.NoRecoil or MISC.NoSpread or MISC.InfAmmo or MISC.RapidFire then
					pcall(function()
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
									local rf = MISC.RapidFireLevel or 20; local rm = rf / 20
									if n:find("firerate") or n:find("rateof") then
										if rm > 0 then if v.Value < 9000 then v.Value = v.Value / math.max(rm, 0.01) end
										else v.Value = 99999 end
									end
									if n:find("firedelay") or n:find("delay") or n:find("cooldown") or n:find("shotdelay") or n:find("interval") or n:find("attackdelay") or n:find("shootdelay") then v.Value = v.Value * rm end
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

	-- Super Punch
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

	-- Rapid Fire
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
	task.spawn(function()
		while true do
			if PANIC_TRIGGERED then break end
			if MISC.RapidFire and mbHeld[1] then
				local rf = MISC.RapidFireLevel or 20
				if rf < 20 then
					if not isMouseOverGui() then
						local d2 = (rf / 20) * 0.15
						pcall(function()
							VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 0)
							task.wait(0.01)
							VIM:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 0)
						end)
						task.wait(math.max(d2, 0.01))
					else task.wait(0.05) end
				else task.wait(0.05) end
			else task.wait(0.05) end
		end
	end)
end

local healPlayer = _G.BearHub_healPlayer
Oto druga część skryptu. Zawiera ona **całkowicie przebudowany system FreeCam**, który naprawia problem "krzywej" kamery. Teraz rotacja odbywa się wokół osi świata (Yaw) i lokalnej osi kamery (Pitch), co zapobiega przechylaniu się obrazu na boki. Dodałem też obsługę teleportacji oraz pełne GUI.

```lua
--============================================================
-- CZĘŚĆ 2: FIXED FREECAM + GUI
--============================================================

-- FIXED FREECAM SYSTEM
local freecamActive = false
local fcYaw, fcPitch = 0, 0

local fcDot = Instance.new("Frame", gui)
fcDot.Size = UDim2.new(0, 6, 0, 6); fcDot.AnchorPoint = Vector2.new(0.5, 0.5)
fcDot.Position = UDim2.new(0.5, 0, 0.5, 0); fcDot.BackgroundColor3 = Color3.new(1,1,1)
fcDot.BorderSizePixel = 0; fcDot.Visible = false; fcDot.ZIndex = 9998
Instance.new("UICorner", fcDot).CornerRadius = UDim.new(1, 0)

local fcBar = Instance.new("Frame", gui)
fcBar.Size = UDim2.new(0, 300, 0, 40); fcBar.AnchorPoint = Vector2.new(0.5, 1)
fcBar.Position = UDim2.new(0.5, 0, 1, -20); fcBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
fcBar.BorderSizePixel = 0; fcBar.Visible = false; fcBar.ZIndex = 9998
Instance.new("UICorner", fcBar).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", fcBar).Color = PURPLE

local fcLabel = Instance.new("TextLabel", fcBar)
fcLabel.Size = UDim2.new(0, 140, 1, 0); fcLabel.Position = UDim2.new(0, 10, 0, 0)
fcLabel.BackgroundTransparency = 1; fcLabel.Text = "FREE CAM (FIXED)"; fcLabel.TextColor3 = Color3.fromRGB(180, 140, 255)
fcLabel.Font = Enum.Font.GothamBold; fcLabel.TextSize = 14; fcLabel.TextXAlignment = Enum.TextXAlignment.Left; fcLabel.ZIndex = 9999

local fcTpBtn = Instance.new("TextButton", fcBar)
fcTpBtn.Size = UDim2.new(0, 120, 0, 28); fcTpBtn.Position = UDim2.new(1, -130, 0.5, -14)
fcTpBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220); fcTpBtn.BorderSizePixel = 0
fcTpBtn.Text = "Teleport (LMB)"; fcTpBtn.TextColor3 = Color3.new(1,1,1)
fcTpBtn.Font = Enum.Font.GothamBold; fcTpBtn.TextSize = 12; fcTpBtn.AutoButtonColor = false; fcTpBtn.ZIndex = 9999
Instance.new("UICorner", fcTpBtn).CornerRadius = UDim.new(0, 6)

local function stopFreeCam()
	if not freecamActive then return end
	freecamActive = false
	fcDot.Visible = false; fcBar.Visible = false
	UIS.MouseBehavior = Enum.MouseBehavior.Default
	pcall(function()
		Camera.CameraType = Enum.CameraType.Custom
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local a = root:FindFirstChild("BearHub_FCanchor"); if a then a:Destroy() end
				local v = root:FindFirstChild("BearHub_FCvel"); if v then v:Destroy() end
			end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then Camera.CameraSubject = hum end
		end
	end)
end

local function startFreeCam()
	if freecamActive or PANIC_TRIGGERED then return end
	local char = player.Character; if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	
	freecamActive = true
	fcDot.Visible = true; fcBar.Visible = true
	
	-- Reset rotacji na podstawie obecnej kamery
	local look = Camera.CFrame.LookVector
	fcYaw = math.atan2(-look.X, -look.Z)
	fcPitch = math.asin(look.Y)

	-- Freeze character
	local bpos = Instance.new("BodyPosition", root)
	bpos.Name = "BearHub_FCanchor"; bpos.MaxForce = Vector3.new(1,1,1) * math.huge
	bpos.Position = root.Position
	local bvel = Instance.new("BodyVelocity", root)
	bvel.Name = "BearHub_FCvel"; bvel.MaxForce = Vector3.new(1,1,1) * math.huge
	bvel.Velocity = Vector3.zero

	Camera.CameraType = Enum.CameraType.Scriptable

	task.spawn(function()
		while freecamActive and MISC.FreeCam and not PANIC_TRIGGERED do
			local dt = RunService.RenderStepped:Wait()
			local spd = MISC.FreeCamSpeed or 30

			-- Rotacja (PPM trzymany)
			if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
				local delta = UIS:GetMouseDelta()
				local sens = 0.003
				fcYaw = fcYaw - delta.X * sens
				fcPitch = math.clamp(fcPitch - delta.Y * sens, -math.rad(89), math.rad(89))
			else
				UIS.MouseBehavior = Enum.MouseBehavior.Default
			end

			local camRot = CFrame.Angles(0, fcYaw, 0) * CFrame.Angles(fcPitch, 0, 0)
			local fw, rt, up = 0, 0, 0
			if UIS:IsKeyDown(Enum.KeyCode.W) then fw = 1 end
			if UIS:IsKeyDown(Enum.KeyCode.S) then fw = -1 end
			if UIS:IsKeyDown(Enum.KeyCode.A) then rt = -1 end
			if UIS:IsKeyDown(Enum.KeyCode.D) then rt = 1 end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then up = 1 end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then up = -1 end

			local moveDir = (camRot.LookVector * fw) + (camRot.RightVector * rt) + (Vector3.new(0,1,0) * up)
			if moveDir.Magnitude > 0 then
				Camera.CFrame = Camera.CFrame + (moveDir.Unit * spd * dt)
			end
			Camera.CFrame = CFrame.new(Camera.CFrame.Position) * camRot
		end
		stopFreeCam()
	end)
end

local function fcTeleport()
	if not freecamActive then return end
	local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		local pos = Camera.CFrame.Position
		local ray = workspace:Raycast(pos, Camera.CFrame.LookVector * 1000, RaycastParams.new())
		local target = ray and (ray.Position + Vector3.new(0, 3, 0)) or (pos + Camera.CFrame.LookVector * 50)
		stopFreeCam(); MISC.FreeCam = false; task.wait(0.1)
		root.CFrame = CFrame.new(target)
	end
end

fcTpBtn.MouseButton1Click:Connect(function() playClick(); fcTeleport() end)
UIS.InputBegan:Connect(function(i, g) if not g and freecamActive and i.UserInputType == Enum.UserInputType.MouseButton1 then fcTeleport() end end)

task.spawn(function()
	local last = false
	while true do
		task.wait(0.1); if PANIC_TRIGGERED then break end
		if MISC.FreeCam and not last then startFreeCam()
		elseif not MISC.FreeCam and last then stopFreeCam() end
		last = MISC.FreeCam
	end
end)

--============================================================
-- GUI MAIN CONSTRUCT
--============================================================

local ORIGINAL_SIZE = UDim2.new(0, 700, 0, 450)
main = Instance.new("Frame", gui)
main.Name = "Main"; main.Size = ORIGINAL_SIZE; main.Position = UDim2.new(0.5, -350, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25); main.BorderSizePixel = 0; main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 190, 1, 0); sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
sidebar.BorderSizePixel = 0; Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local bearIcon = Instance.new("ImageLabel", sidebar)
bearIcon.Size = UDim2.new(0, 80, 0, 80); bearIcon.Position = UDim2.new(0.5, -40, 0, 15)
bearIcon.BackgroundTransparency = 1; bearIcon.Image = BEAR_ICON; bearIcon.ScaleType = Enum.ScaleType.Fit

local tabsFrame = Instance.new("Frame", sidebar)
tabsFrame.Name = "TabsFrame"; tabsFrame.Size = UDim2.new(1, -20, 1, -130); tabsFrame.Position = UDim2.new(0, 10, 0, 110)
tabsFrame.BackgroundTransparency = 1; local tfl = Instance.new("UIListLayout", tabsFrame); tfl.Padding = UDim.new(0, 6)

local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, -200, 1, -20); contentArea.Position = UDim2.new(0, 200, 0, 10)
contentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 30); contentArea.BorderSizePixel = 0
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

contentTitle = Instance.new("TextLabel", contentArea)
contentTitle.Size = UDim2.new(1, -20, 0, 40); contentTitle.Position = UDim2.new(0, 15, 0, 10); contentTitle.BackgroundTransparency = 1
contentTitle.TextColor3 = Color3.new(1,1,1); contentTitle.Font = Enum.Font.GothamBold; contentTitle.TextSize = 20; contentTitle.TextXAlignment = Enum.TextXAlignment.Left

pagesFrame = Instance.new("Frame", contentArea)
pagesFrame.Size = UDim2.new(1, 0, 1, -55); pagesFrame.Position = UDim2.new(0, 0, 0, 55); pagesFrame.BackgroundTransparency = 1

-- CP
colorPickerGui = Instance.new("Frame", main); colorPickerGui.Size = UDim2.new(0, 220, 0, 260)
colorPickerGui.Position = UDim2.new(0.5, -110, 0.5, -130); colorPickerGui.BackgroundColor3 = Color3.fromRGB(30, 30, 35); colorPickerGui.Visible = false; colorPickerGui.ZIndex = 100
Instance.new("UICorner", colorPickerGui).CornerRadius = UDim.new(0, 10); Instance.new("UIStroke", colorPickerGui).Color = PURPLE

-- GŁÓWNE FUNKCJE GUI (SEKCJE)
local function mkPanel(parent, w, h2, xPos, yPos)
	local f=Instance.new("Frame",parent); f.Size=UDim2.new(w,0,0,h2); f.Position=UDim2.new(xPos, xPos==0 and 10 or 5, 0, yPos or 5)
	f.BackgroundColor3=DARK; f.BorderSizePixel=0; Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
	local ll=Instance.new("UIListLayout",f); ll.Padding=UDim.new(0,4); ll.SortOrder=Enum.SortOrder.LayoutOrder
	local pd=Instance.new("UIPadding",f); pd.PaddingTop=UDim.new(0,8); pd.PaddingLeft=UDim.new(0,5); pd.PaddingRight=UDim.new(0,5)
	return f
end

-- PAGE 1: AIM ASSISTANCE
local aimP = createPage("AimAssistance")
local subBar = Instance.new("Frame",aimP); subBar.Size=UDim2.new(1,-20,0,30); subBar.Position=UDim2.new(0,10,0,0); subBar.BackgroundTransparency=1
local sbl = Instance.new("UIListLayout",subBar); sbl.FillDirection=Enum.FillDirection.Horizontal; sbl.Padding=UDim.new(0,15)
local subPF = Instance.new("Frame",aimP); subPF.Size=UDim2.new(1,0,1,-40); subPF.Position=UDim2.new(0,0,0,38); subPF.BackgroundTransparency=1

local tbP = Instance.new("Frame",subPF); tbP.Size=UDim2.new(1,0,1,0); tbP.BackgroundTransparency=1; tbP.Visible=true
local tbL = mkPanel(tbP,0.48,300,0,5); mkSection(tbL,"TriggerBot",1); mkKeybind(tbL,"Enable",TRIGGERBOT,2)
mkCheckColor(tbL,"Show FOV",TRIGGERBOT,"ShowFOV","FOVColor",4); mkSlider(tbL,"FOV",1,100,30,"px",TRIGGERBOT,"FOV",5)
local tbR = mkPanel(tbP,0.48,300,0.5,5); mkSection(tbR,"Options",1); mkSlider(tbR,"Shot Delay",0,1000,100,"ms",TRIGGERBOT,"ShotDelay",5)

local abP = Instance.new("Frame",subPF); abP.Size=UDim2.new(1,0,1,0); abP.BackgroundTransparency=1; abP.Visible=false
local abL = mkPanel(abP,0.48,300,0,5); mkSection(abL,"Aimbot",1); mkKeybind(abL,"Enable",AIMBOT,2)
mkCheckColor(abL,"Draw FOV",AIMBOT,"DrawFOV","FOVColor",3); mkSlider(abL,"FOV",1,100,10,"",AIMBOT,"FOV",4)
local abR = mkPanel(abP,0.48,300,0.5,5); mkSection(abR,"Settings",1); mkSlider(abR,"Smooth X",1,100,80,"",AIMBOT,"SmoothX",2); mkSlider(abR,"Smooth Y",1,100,80,"",AIMBOT,"SmoothY",3)

local hbP = Instance.new("Frame",subPF); hbP.Size=UDim2.new(1,0,1,0); hbP.BackgroundTransparency=1; hbP.Visible=false
local hbL = mkPanel(hbP,0.48,250,0,5); mkSection(hbL,"Hitbox Expander",1); mkCheck(hbL,"Enable",HITBOX,"Enabled",2); mkSlider(hbL,"Size",0,30,0,"",HITBOX,"Size",4)

local selSub = nil
local function switchSub(n) tbP.Visible=(n=="TriggerBot"); abP.Visible=(n=="Aimbot"); hbP.Visible=(n=="Hitbox") end
local function mkSB(n,o)
	local btn=Instance.new("TextButton",subBar); btn.Size=UDim2.new(0,80,1,0); btn.BackgroundTransparency=1; btn.Text=n; btn.TextColor3=Color3.fromRGB(120,120,130); btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.AutoButtonColor=false
	local ul=Instance.new("Frame",btn); ul.Size=UDim2.new(1,0,0,2); ul.Position=UDim2.new(0,0,1,-2); ul.BackgroundColor3=PURPLE; ul.Visible=false
	btn.MouseButton1Click:Connect(function() playClick(); if selSub then selSub.btn.TextColor3=Color3.fromRGB(120,120,130); selSub.ul.Visible=false end; selSub={btn=btn,ul=ul}; btn.TextColor3=Color3.new(1,1,1); ul.Visible=true; switchSub(n) end)
	return {btn=btn,ul=ul}
end
local s1=mkSB("TriggerBot",1); mkSB("Aimbot",2); mkSB("Hitbox",3); selSub=s1; s1.btn.TextColor3=Color3.new(1,1,1); s1.ul.Visible=true

-- PAGE 2: VISUALS
local vizP = createPage("Visualization")
local vL = mkPanel(vizP, 0.48, 300, 0, 5); mkSection(vL, "Main", 1); mkCheck(vL, "Enable ESP", ESP, "Enabled", 2); mkSlider(vL, "Distance", 0, 1000, 300, "m", ESP, "MaxDistance", 3)
local vR = mkPanel(vizP, 0.48, 380, 0.5, 5); mkSection(vR, "Elements", 1); mkCheckColor(vR, "Boxes", nil, "Box", nil, 2); mkCheckColor(vR, "Names", nil, "Name", nil, 3); mkCheckColor(vR, "Skeleton", nil, "Skeleton", nil, 4); mkCheckColor(vR, "Health", nil, "HealthBar", nil, 5)

-- PAGE 3: MISC
local miscP = createPage("Miscellaneous")
local mSubBar = Instance.new("Frame",miscP); mSubBar.Size=UDim2.new(1,-20,0,30); mSubBar.Position=UDim2.new(0,10,0,0); mSubBar.BackgroundTransparency=1
local msbl = Instance.new("UIListLayout",mSubBar); msbl.FillDirection=Enum.FillDirection.Horizontal; msbl.Padding=UDim.new(0,10)
local mSubPF = Instance.new("Frame",miscP); mSubPF.Size=UDim2.new(1,0,1,-40); mSubPF.Position=UDim2.new(0,0,0,38); mSubPF.BackgroundTransparency=1

local m1P = Instance.new("Frame",mSubPF); m1P.Size=UDim2.new(1,0,1,0); m1P.BackgroundTransparency=1; m1P.Visible=true
local m1L = mkPanel(m1P, 0.5, 380, 0, 5); mkSection(m1L, "Movement", 1); mkCheck(m1L, "WalkSpeed", MISC, "WalkSpeedEnabled", 2); mkSlider(m1L, "Speed", 16, 250, 16, "", MISC, "WalkSpeed", 3); mkCheck(m1L, "NoClip Fly", MISC, "NoClip", 4); mkCheck(m1L, "FreeCam (LMB to TP)", MISC, "FreeCam", 5); mkSlider(m1L, "Cam Speed", 10, 200, 30, "", MISC, "FreeCamSpeed", 6)

local m2P = Instance.new("Frame",mSubPF); m2P.Size=UDim2.new(1,0,1,0); m2P.BackgroundTransparency=1; m2P.Visible=false
local m2L = mkPanel(m2P, 0.5, 300, 0, 5); mkSection(m2L, "Combat", 1); mkCheck(m2L, "NoRecoil", MISC, "NoRecoil", 2); mkCheck(m2L, "InfAmmo", MISC, "InfAmmo", 3); mkCheck(m2L, "RapidFire", MISC, "RapidFire", 4)

local msel = nil
local function mkMSB(n,o)
	local btn=Instance.new("TextButton",mSubBar); btn.Size=UDim2.new(0,80,1,0); btn.BackgroundTransparency=1; btn.Text=n; btn.TextColor3=Color3.fromRGB(120,120,130); btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.AutoButtonColor=false
	local ul=Instance.new("Frame",btn); ul.Size=UDim2.new(1,0,0,2); ul.Position=UDim2.new(0,0,1,-2); ul.BackgroundColor3=PURPLE; ul.Visible=false
	btn.MouseButton1Click:Connect(function() playClick(); if msel then msel.btn.TextColor3=Color3.fromRGB(120,120,130); msel.ul.Visible=false end; msel={btn=btn,ul=ul}; btn.TextColor3=Color3.new(1,1,1); ul.Visible=true; m1P.Visible=(n=="Move"); m2P.Visible=(n=="Combat") end)
	return {btn=btn,ul=ul}
end
local ms1 = mkMSB("Move",1); mkMSB("Combat",2); msel=ms1; ms1.btn.TextColor3=Color3.new(1,1,1); ms1.ul.Visible=true

-- PAGE 4: PLAYERS
local plP = createPage("Players")
-- (Uproszczona wersja listy graczy z Twojego kodu)
local plLF=Instance.new("Frame",plP); plLF.Size=UDim2.new(0.45,0,1,-10); plLF.Position=UDim2.new(0,10,0,5); plLF.BackgroundColor3=DARK; Instance.new("UICorner",plLF)
local plS=Instance.new("ScrollingFrame",plLF); plS.Size=UDim2.new(1,-10,1,-40); plS.Position=UDim2.new(0,5,0,32); plS.BackgroundTransparency=1; plS.ScrollBarThickness=2; Instance.new("UIListLayout",plS).Padding=UDim.new(0,4)

-- PAGE 5: SETTINGS
local stP = createPage("Settings")
local stL = mkPanel(stP, 0.6, 200, 0, 5); mkSection(stL, "Panic", 1); mkButton(stL, "UNINJECT SCRIPT", function() PANIC_DESTROY() end, 2, Color3.fromRGB(200, 50, 50))

-- FINALIZING TABS
local function makeTabBtn(name, order)
	local btn = Instance.new("TextButton", tabsFrame); btn.Size = UDim2.new(1,0,0,36); btn.BackgroundTransparency = 1; btn.Text = "  "..name
	btn.TextColor3 = Color3.fromRGB(150,150,160); btn.Font = Enum.Font.Gotham; btn.TextSize = 14; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
	btn.MouseButton1Click:Connect(function()
		playClick(); if selTab then selTab.BackgroundTransparency=1; selTab.TextColor3=Color3.fromRGB(150,150,160) end
		selTab=btn; btn.BackgroundTransparency=0.5; btn.TextColor3=Color3.new(1,1,1)
		for n,p in pairs(_G.BearHub_tabPages) do p.Visible = (n==name) end; contentTitle.Text = name
	end); return btn
end

local t1 = makeTabBtn("AimAssistance",1); makeTabBtn("Visualization",2); makeTabBtn("Miscellaneous",3); makeTabBtn("Players",4); makeTabBtn("Settings",5)
selTab=t1; t1.BackgroundTransparency=0.5; t1.TextColor3=Color3.new(1,1,1); for n,p in pairs(_G.BearHub_tabPages) do p.Visible=(n=="AimAssistance") end; contentTitle.Text="AimAssistance"

-- MINIMIZE SYSTEM
local miniBall = Instance.new("ImageButton", gui); miniBall.Size = UDim2.new(0,50,0,50); miniBall.Position = UDim2.new(0,20,0,20)
miniBall.BackgroundColor3 = DARK; miniBall.Image = BEAR_ICON; miniBall.Visible = false; Instance.new("UICorner", miniBall).CornerRadius = UDim.new(1,0)

UIS.InputBegan:Connect(function(i,g)
	if not g and i.KeyCode == Enum.KeyCode.RightShift then
		main.Visible = not main.Visible; miniBall.Visible = not main.Visible
	end
end)

-- DRAG SYSTEM
local d=false; local s; local sp
sidebar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d=true; s=i.Position; sp=main.Position end end)
UIS.InputChanged:Connect(function(i)
	if d and i.UserInputType==Enum.UserInputType.MouseMovement then
		local delta=i.Position-s; main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+delta.X,sp.Y.Scale,sp.Y.Offset+delta.Y)
	end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d=false end end)

print("BearHub Loaded Successfully with Fixed FreeCam!")
```
