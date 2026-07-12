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
	NoClip = false, NoClipSpeed = 45,
	RapidFire = false, RapidFireLevel = 20,
	WalkSpeedEnabled = false, WalkSpeed = 16,
	JumpPowerEnabled = false, JumpPower = 50,
	FreeCam = false, FreeCamSpeed = 65,
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
				Camera.CameraSubject = myHum
				myHum.WalkSpeed = 16
				myHum.UseJumpPower = true
				myHum.JumpPower = 50
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
	
	pcall(function() espGui:Destroy() end)
	pcall(function() fovGui:Destroy() end)
	pcall(function() gui:Destroy() end)
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
		if not ok then pcall(function() if mouse1click then mouse1click() ok = true end end) end
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
-- SPECTATE + TELEPORT FUNCTIONS
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
end

local startSpectate = _G.BearHub_startSpectate
local stopSpectate = _G.BearHub_stopSpectate
local teleportTo = _G.BearHub_teleportTo
local bringPlayer = _G.BearHub_bringPlayer
local switchPlaces = _G.BearHub_switchPlaces

-- MOUSE INPUT
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
-- ESP + FOV (z poprawionym Inventory)
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

	_G.BearHub_getPos = getPos
	_G.BearHub_visCheck = visCheck

	local R15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"}}
	local R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

	local invCache, invCacheTick = {}, {}

	local function getCachedInv(plr)
		local now = tick()
		if invCache[plr] and invCacheTick[plr] and (now - invCacheTick[plr]) < 1 then return invCache[plr] end
		
		local raw = {}
		local seen = {}
		
		if plr.Character then
			for _, c in ipairs(plr.Character:GetChildren()) do
				if c:IsA("Tool") and not seen[c.Name] then
					seen[c.Name] = true
					table.insert(raw, c.Name)
				end
			end
		end
		
		local bp = plr:FindFirstChildOfClass("Backpack")
		if bp then
			for _, c in ipairs(bp:GetChildren()) do
				if c:IsA("Tool") and not seen[c.Name] then
					seen[c.Name] = true
					table.insert(raw, c.Name)
				end
			end
		end
		
		local items = {}
		for i = 1, math.min(#raw, 10) do
			table.insert(items, raw[i])
		end
		
		invCache[plr] = items
		invCacheTick[plr] = now
		return items
	end

	local function updateESP()
		if PANIC_TRIGGERED then return end
		Camera = workspace.CurrentCamera; if not Camera then return end
		
		local cur = {}; for _, p in ipairs(Players:GetPlayers()) do cur[p] = true end
		for plr in pairs(espObjects) do if not cur[plr] then clearESP(plr) end end
		
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
									
									-- Box, Name, ID, Distance, HealthBar, Snaplines, Skeleton - bez zmian (skrócone dla miejsca)
									if ESP.Box.Enabled then
										drawLine(d.boxTop, Vector2.new(lX,tY), Vector2.new(rX,tY), 1)
										drawLine(d.boxBot, Vector2.new(lX,bY), Vector2.new(rX,bY), 1)
										drawLine(d.boxLeft, Vector2.new(lX,tY), Vector2.new(lX,bY), 1)
										drawLine(d.boxRight, Vector2.new(rX,tY), Vector2.new(rX,bY), 1)
										for _, f in pairs({d.boxTop,d.boxBot,d.boxLeft,d.boxRight}) do f.BackgroundColor3 = ESP.Box.Color; f.Visible = true end
									else
										for _, f in pairs({d.boxTop,d.boxBot,d.boxLeft,d.boxRight}) do f.Visible = false end
									end
									
									local bo = 0
									if ESP.Name.Enabled then d.name.Text = plr.DisplayName or plr.Name; d.name.Position = UDim2.new(0, sp.X, 0, tY - 15); d.name.TextColor3 = ESP.Name.Color; d.name.Visible = true else d.name.Visible = false end
									if ESP.ID.Enabled then d.id.Text = "ID: " .. plr.UserId; d.id.Position = UDim2.new(0, sp.X, 0, tY - (ESP.Name.Enabled and 30 or 15)); d.id.TextColor3 = ESP.ID.Color; d.id.Visible = true else d.id.Visible = false end
									if ESP.Distance.Enabled then d.distance.Text = math.floor(dist) .. "m"; d.distance.Position = UDim2.new(0, sp.X, 0, bY + 12 + bo); d.distance.TextColor3 = ESP.Distance.Color; d.distance.Visible = true; bo = bo + 16 else d.distance.Visible = false end
									
									-- NOWY INVENTORY (5 pod 5, max 10, bez duplikatów)
									if ESP.Inventory.Enabled then
										local items = getCachedInv(plr)
										if #items > 0 then
											local row1 = {}
											local row2 = {}
											for i, item in ipairs(items) do
												if i <= 5 then table.insert(row1, item)
												else table.insert(row2, item) end
											end
											local line1 = table.concat(row1, ", ")
											local line2 = #row2 > 0 and table.concat(row2, ", ") or nil
											local txt = "[" .. line1 .. "]"
											if line2 then txt = txt .. "\n[" .. line2 .. "]" end
											d.inventory.Text = txt
											d.inventory.TextColor3 = ESP.Inventory.Color
										else 
											d.inventory.Text = "[Empty]"
											d.inventory.TextColor3 = Color3.fromRGB(120, 120, 130)
										end
										d.inventory.TextYAlignment = Enum.TextYAlignment.Top
										d.inventory.Position = UDim2.new(0, sp.X, 0, bY + 12 + bo)
										d.inventory.Size = UDim2.new(0, 350, 0, 34)
										d.inventory.Visible = true
										bo = bo + 34
									else 
										d.inventory.Visible = false 
									end
									
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
		if not PANIC_TRIGGERED then 
			pcall(updateESP)
			pcall(updateFOVCircle)
		end
	end)
end

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
								if sd <= fr and sd < bestD then 
									best = plr
									bestD = sd 
								end
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
			if PANIC_TRIGGERED then break end
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
											best = plr
											bestD = sd
											bestPos = bonePos
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

	-- HITBOX EXPANDER
	local savedMS, savedMO, hitHL = {}, {}, {}
	local HBM = {
		Head = {R15={"Head"}, R6={"Head"}},
		Torso = {R15={"UpperTorso","LowerTorso"}, R6={"Torso"}},
		Legs = {R15={"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}, R6={"Left Leg","Right Leg"}}
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

	local function findMesh(p)
		return p:FindFirstChildOfClass("SpecialMesh") or p:FindFirstChildOfClass("BlockMesh") or p:FindFirstChildOfClass("CylinderMesh")
	end

	local function saveMD(p)
		local m = findMesh(p)
		if m and not savedMS[m] then
			savedMS[m] = m.Scale
			if m:IsA("SpecialMesh") then savedMO[m] = m.Offset end
		end
	end

	local function restoreM(p)
		local m = findMesh(p)
		if m and savedMS[m] then
			pcall(function()
				m.Scale = savedMS[m]
				if m:IsA("SpecialMesh") and savedMO[m] then m.Offset = savedMO[m] end
			end)
			savedMS[m] = nil
			savedMO[m] = nil
		end
	end

	local function createHL(p)
		if hitHL[p] and hitHL[p].Parent then return hitHL[p] end
		local c = p.Parent; if not c then return nil end
		local hn = "BearHub_HL_" .. p.Name
		local ex = c:FindFirstChild(hn); if ex then ex:Destroy() end
		local s = Instance.new("SelectionSphere")
		s.Name = hn; s.Adornee = p
		s.Color3 = Color3.fromRGB(255,60,60)
		s.SurfaceColor3 = Color3.fromRGB(255,60,60)
		s.SurfaceTransparency = 0.7
		s.Transparency = 0.5
		s.Parent = c
		hitHL[p] = s
		return s
	end

	local function removeHL(p)
		if hitHL[p] then
			pcall(function() hitHL[p]:Destroy() end)
			hitHL[p] = nil
		end
	end

	local function expandP(p)
		if not p or not p.Parent then return end
		local sc = 1 + (HITBOX.Size * 0.15)
		local m = findMesh(p)
		if m then 
			saveMD(p)
			pcall(function() m.Scale = savedMS[m] * sc end)
		end
		createHL(p)
	end

	local function restoreP(p)
		if not p or not p.Parent then return end
		restoreM(p)
		removeHL(p)
	end

	local function restoreAllC(c)
		if not c then return end
		for _, p in ipairs(c:GetChildren()) do
			if p:IsA("BasePart") then restoreP(p) end
		end
		for _, ch in ipairs(c:GetChildren()) do
			if ch.Name:find("BearHub_HL_") then pcall(function() ch:Destroy() end) end
		end
	end

	local function cleanDead()
		local tr = {}
		for m in pairs(savedMS) do
			if not m or not m.Parent then table.insert(tr, m) end
		end
		for _, m in ipairs(tr) do savedMS[m] = nil; savedMO[m] = nil end
		
		local tr2 = {}
		for p in pairs(hitHL) do
			if not p or not p.Parent then table.insert(tr2, p) end
		end
		for _, p in ipairs(tr2) do hitHL[p] = nil end
	end

	local lastHBB, lastHBE = "Head", false
	RunService.Heartbeat:Connect(function()
		if PANIC_TRIGGERED then return end
		local bc = (lastHBB ~= HITBOX.Bone)
		local ec = (lastHBE ~= HITBOX.Enabled)
		lastHBB = HITBOX.Bone
		lastHBE = HITBOX.Enabled
		
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local c = plr.Character
				if c then
					if HITBOX.Enabled and HITBOX.Size > 0 then
						if bc then restoreAllC(c) end
						local tp = getHBParts(c)
						local ts = {}
						for _, p in ipairs(tp) do ts[p] = true end
						for _, p in ipairs(c:GetChildren()) do
							if p:IsA("BasePart") and hitHL[p] and not ts[p] then restoreP(p) end
						end
						for _, p in ipairs(tp) do pcall(function() expandP(p) end) end
					else 
						if ec then restoreAllC(c) end 
					end
				end
			end
		end
		cleanDead()
	end)
end

--============================================================
-- MISC + BYPASS (NoClip & FreeCam)
--============================================================
do
	-- SemiGod
	task.spawn(function()
		while true do
			task.wait(0.1)
			if PANIC_TRIGGERED then break end
			if MISC.SemiGod then
				local c = player.Character
				if c then
					local h = c:FindFirstChildOfClass("Humanoid")
					if h and h.Health > 0 then
						pcall(function()
							h.MaxHealth = math.huge
							h.Health = math.huge
						end)
					end
				end
			end
		end
	end)

	_G.BearHub_healPlayer = function()
		if PANIC_TRIGGERED then return end
		local c = player.Character
		if not c then return end
		local h = c:FindFirstChildOfClass("Humanoid")
		if h then pcall(function() h.Health = h.MaxHealth end) end
	end

	-- WalkSpeed & JumpPower
	local lastWSEnabled, lastJPEnabled = false, false
	task.spawn(function()
		while true do
			task.wait(0.1)
			if PANIC_TRIGGERED then break end
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
		task.wait(0.5)
		lastWSEnabled = false
		lastJPEnabled = false
	end)

	-- === BYPASS NOCLIP + FREECAM ===
	local noclipConnection = nil
	local flyBV, flyBG = nil, nil

	local function stopNoClip()
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end
		if flyBV then flyBV:Destroy() flyBV = nil end
		if flyBG then flyBG:Destroy() flyBG = nil end
	end

	local function startNoClip()
		stopNoClip()
		local char = player.Character
		if not char then return end

		noclipConnection = RunService.Stepped:Connect(function()
			if not MISC.NoClip or PANIC_TRIGGERED then stopNoClip() return end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end)

		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if root then
			flyBV = Instance.new("BodyVelocity")
			flyBV.MaxForce = Vector3.new(400000, 400000, 400000)
			flyBV.Velocity = Vector3.zero
			flyBV.Parent = root

			flyBG = Instance.new("BodyGyro")
			flyBG.MaxTorque = Vector3.new(400000, 400000, 400000)
			flyBG.P = 12000
			flyBG.Parent = root

			task.spawn(function()
				while MISC.NoClip and not PANIC_TRIGGERED do
					local dt = RunService.RenderStepped:Wait()
					local spd = MISC.NoClipSpeed or 45
					local move = Vector3.new(0,0,0)
					local cf = Camera.CFrame

					if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
					if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
					if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
					if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
					if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
					if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end

					if move.Magnitude > 0 then
						move = move.Unit * spd
					end

					if flyBV then flyBV.Velocity = move end
					if flyBG then flyBG.CFrame = cf end
				end
				stopNoClip()
			end)
		end
	end

	-- FREECAM BYPASS (szybki, stabilny, postać się nie rusza)
	local freecamActive = false
	local oldMouseBehavior = Enum.MouseBehavior.Default
	local oldMouseIconEnabled = true

	local function stopFreeCam()
		if not freecamActive then return end
		freecamActive = false
		fcDot.Visible = false
		fcBar.Visible = false
		pcall(function()
			UIS.MouseBehavior = oldMouseBehavior
			UIS.MouseIconEnabled = oldMouseIconEnabled
			Camera.CameraType = Enum.CameraType.Custom
			local char = player.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					Camera.CameraSubject = hum
					hum.WalkSpeed = MISC.WalkSpeedEnabled and MISC.WalkSpeed or 16
					hum.JumpPower = MISC.JumpPowerEnabled and MISC.JumpPower or 50
				end
			end
		end)
	end

	local function startFreeCam()
		if freecamActive or PANIC_TRIGGERED then return end
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		freecamActive = true
		fcDot.Visible = true
		fcBar.Visible = true

		oldMouseBehavior = UIS.MouseBehavior
		oldMouseIconEnabled = UIS.MouseIconEnabled
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		UIS.MouseIconEnabled = false

		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 0
			hum.JumpPower = 0
		end

		Camera.CameraType = Enum.CameraType.Scriptable

		local look = Camera.CFrame.LookVector
		local camYaw = math.atan2(-look.X, -look.Z)
		local camPitch = math.asin(math.clamp(look.Y, -1, 1))
		local camPos = Camera.CFrame.Position
		local sensitivity = 0.007   -- SZYBSZA KAMERA (możesz zmienić na 0.009 jeśli chcesz jeszcze szybciej)

		task.spawn(function()
			while freecamActive and MISC.FreeCam and not PANIC_TRIGGERED do
				local dt = RunService.RenderStepped:Wait()
				local spd = MISC.FreeCamSpeed or 65

				local delta = UIS:GetMouseDelta()
				camYaw = camYaw - delta.X * sensitivity
				camPitch = math.clamp(camPitch - delta.Y * sensitivity, -math.rad(89), math.rad(89))

				local rotCF = CFrame.Angles(0, camYaw, 0) * CFrame.Angles(camPitch, 0, 0)

				local fw, rt, up = 0, 0, 0
				if UIS:IsKeyDown(Enum.KeyCode.W) then fw = 1 end
				if UIS:IsKeyDown(Enum.KeyCode.S) then fw = -1 end
				if UIS:IsKeyDown(Enum.KeyCode.A) then rt = -1 end
				if UIS:IsKeyDown(Enum.KeyCode.D) then rt = 1 end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then up = 1 end
				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then up = -1 end

				local move = (rotCF.LookVector * fw + rotCF.RightVector * rt + Vector3.new(0, up, 0))
				if move.Magnitude > 0 then
					move = move.Unit * spd * dt
					camPos = camPos + move
				end

				Camera.CFrame = CFrame.new(camPos) * rotCF
			end
			stopFreeCam()
		end)
	end

	-- Łączenie z GUI
	task.spawn(function()
		local wasNoClip = false
		local wasFreeCam = false
		while true do
			task.wait(0.08)
			if PANIC_TRIGGERED then break end
			
			if MISC.NoClip and not wasNoClip then
				startNoClip()
			elseif not MISC.NoClip and wasNoClip then
				stopNoClip()
			end
			
			if MISC.FreeCam and not wasFreeCam then
				startFreeCam()
			elseif not MISC.FreeCam and wasFreeCam then
				stopFreeCam()
			end
			
			wasNoClip = MISC.NoClip
			wasFreeCam = MISC.FreeCam
		end
	end)
end

local healPlayer = _G.BearHub_healPlayer

--============================================================
-- GUI MAIN + COLOR PICKER
--============================================================
local main, sidebar, contentTitle, pagesFrame, colorPickerGui, openCP, cpGrid, hueBar

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
	contentTitle.TextColor3 = Color3.new(1,1,1)
	contentTitle.Font = Enum.Font.GothamBold
	contentTitle.TextSize = 20
	contentTitle.TextXAlignment = Enum.TextXAlignment.Left

	pagesFrame = Instance.new("Frame", contentArea)
	pagesFrame.Size = UDim2.new(1, 0, 1, -55)
	pagesFrame.Position = UDim2.new(0, 0, 0, 55)
	pagesFrame.BackgroundTransparency = 1

	-- Color Picker
	colorPickerGui = Instance.new("Frame", main)
	colorPickerGui.Size = UDim2.new(0, 220, 0, 260)
	colorPickerGui.Position = UDim2.new(0.5, -110, 0.5, -130)
	colorPickerGui.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	colorPickerGui.BorderSizePixel = 0
	colorPickerGui.Visible = false
	colorPickerGui.ZIndex = 100
	colorPickerGui.Active = true
	Instance.new("UICorner", colorPickerGui).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", colorPickerGui).Color = PURPLE

	local cpTitleLbl = Instance.new("TextLabel", colorPickerGui)
	cpTitleLbl.Size = UDim2.new(1, 0, 0, 30)
	cpTitleLbl.BackgroundTransparency = 1
	cpTitleLbl.Text = "Pick Color"
	cpTitleLbl.TextColor3 = Color3.new(1,1,1)
	cpTitleLbl.Font = Enum.Font.GothamBold
	cpTitleLbl.TextSize = 14
	cpTitleLbl.ZIndex = 101

	local cpX = Instance.new("TextButton", colorPickerGui)
	cpX.Size = UDim2.new(0, 25, 0, 25)
	cpX.Position = UDim2.new(1, -30, 0, 3)
	cpX.BackgroundTransparency = 1
	cpX.Text = "X"
	cpX.TextColor3 = Color3.fromRGB(200,200,200)
	cpX.Font = Enum.Font.GothamBold
	cpX.TextSize = 16
	cpX.ZIndex = 102
	cpX.MouseButton1Click:Connect(function() playClick(); colorPickerGui.Visible = false end)

	cpGrid = Instance.new("Frame", colorPickerGui)
	cpGrid.Size = UDim2.new(1, -20, 0, 150)
	cpGrid.Position = UDim2.new(0, 10, 0, 35)
	cpGrid.BackgroundColor3 = Color3.fromRGB(255,0,0)
	cpGrid.BorderSizePixel = 0
	cpGrid.ZIndex = 101
	cpGrid.ClipsDescendants = true
	Instance.new("UICorner", cpGrid).CornerRadius = UDim.new(0, 6)

	local so = Instance.new("Frame", cpGrid)
	so.Size = UDim2.new(1,0,1,0)
	so.BackgroundColor3 = Color3.new(1,1,1)
	so.BorderSizePixel = 0
	so.ZIndex = 102
	Instance.new("UIGradient", so).Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})

	local vo = Instance.new("Frame", cpGrid)
	vo.Size = UDim2.new(1,0,1,0)
	vo.BackgroundColor3 = Color3.new(0,0,0)
	vo.BorderSizePixel = 0
	vo.ZIndex = 103
	local vg = Instance.new("UIGradient", vo)
	vg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
	vg.Rotation = 90

	local cpCur = Instance.new("Frame", cpGrid)
	cpCur.Size = UDim2.new(0,10,0,10)
	cpCur.BackgroundColor3 = Color3.new(1,1,1)
	cpCur.BorderSizePixel = 0
	cpCur.ZIndex = 105
	Instance.new("UICorner", cpCur).CornerRadius = UDim.new(1,0)
	Instance.new("UIStroke", cpCur).Color = Color3.new(0,0,0)

	hueBar = Instance.new("Frame", colorPickerGui)
	hueBar.Size = UDim2.new(1,-20,0,20)
	hueBar.Position = UDim2.new(0,10,0,195)
	hueBar.BorderSizePixel = 0
	hueBar.ZIndex = 101
	hueBar.BackgroundColor3 = Color3.new(1,1,1)
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
		cpPrev.BackgroundColor3 = Color3.fromHSV(cH,cS,cV)
		cpGrid.BackgroundColor3 = Color3.fromHSV(cH,1,1)
		cpCur.Position = UDim2.new(cS,-5,1-cV,-5)
		hueSlider.Position = UDim2.new(cH,-2,0,-2)
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
			cS = math.clamp((i.Position.X-ap.X)/as.X,0,1)
			cV = 1-math.clamp((i.Position.Y-ap.Y)/as.Y,0,1)
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
			cH = math.clamp((i.Position.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1)
			updCP()
		end
	end)

	cpApply.MouseButton1Click:Connect(function()
		playClick()
		if activeCC then activeCC(Color3.fromHSV(cH,cS,cV)) end
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
			cS = math.clamp((x-cpGrid.AbsolutePosition.X)/cpGrid.AbsoluteSize.X,0,1)
			cV = 1-math.clamp((y-cpGrid.AbsolutePosition.Y)/cpGrid.AbsoluteSize.Y,0,1)
			updCP()
		elseif kind == "hue" then
			cH = math.clamp((x-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1)
			updCP()
		end
	end
end
openCP = _G.BearHub_openCP

--============================================================
-- GUI HELPERS
--============================================================
_G.BearHub_allSliders = {}
_G.BearHub_tabPages = {}

local allSliders = _G.BearHub_allSliders

local function mkSection(p,t,o)
	local l=Instance.new("TextLabel",p)
	l.Size=UDim2.new(1,0,0,28)
	l.BackgroundTransparency=1
	l.Text=t
	l.TextColor3=Color3.fromRGB(160,160,170)
	l.Font=Enum.Font.GothamBold
	l.TextSize=14
	l.TextXAlignment=Enum.TextXAlignment.Left
	l.LayoutOrder=o or 0
end

local function mkCheck(p,t,tbl,k,o)
	local h=Instance.new("Frame",p)
	h.Size=UDim2.new(1,0,0,30)
	h.BackgroundTransparency=1
	h.LayoutOrder=o or 0
	local en=tbl[k] or false
	local box=Instance.new("TextButton",h)
	box.Size=UDim2.new(0,22,0,22)
	box.Position=UDim2.new(0,5,0.5,-11)
	box.BackgroundColor3=en and PURPLE or GRAY
	box.Text=""
	box.AutoButtonColor=false
	box.BorderSizePixel=0
	Instance.new("UICorner",box).CornerRadius=UDim.new(0,5)
	local ck=Instance.new("ImageLabel",box)
	ck.Size=UDim2.new(0.75,0,0.75,0)
	ck.Position=UDim2.new(0.125,0,0.125,0)
	ck.BackgroundTransparency=1
	ck.Image=CHECK_ICON
	ck.Visible=en
	local lb=Instance.new("TextLabel",h)
	lb.Size=UDim2.new(1,-40,1,0)
	lb.Position=UDim2.new(0,35,0,0)
	lb.BackgroundTransparency=1
	lb.Text=t
	lb.TextColor3=Color3.fromRGB(200,200,210)
	lb.Font=Enum.Font.Gotham
	lb.TextSize=13
	lb.TextXAlignment=Enum.TextXAlignment.Left

	box.MouseButton1Click:Connect(function()
		playClick()
		en=not en
		box.BackgroundColor3=en and PURPLE or GRAY
		ck.Visible=en
		tbl[k]=en
		if tbl==ESP then pcall(fullRefresh) end
	end)
end

local function mkCheckColor(p,t,tbl,k,ck2,o)
	local h=Instance.new("Frame",p)
	h.Size=UDim2.new(1,0,0,30)
	h.BackgroundTransparency=1
	h.LayoutOrder=o or 0
	local isSub=(ck2==nil)
	local en,colRef
	if isSub then en=ESP[k].Enabled; colRef=ESP[k].Color else en=tbl[k] or false; colRef=tbl[ck2] end

	local box=Instance.new("TextButton",h)
	box.Size=UDim2.new(0,22,0,22)
	box.Position=UDim2.new(0,5,0.5,-11)
	box.BackgroundColor3=en and PURPLE or GRAY
	box.Text=""
	box.AutoButtonColor=false
	box.BorderSizePixel=0
	Instance.new("UICorner",box).CornerRadius=UDim.new(0,5)
	local ck=Instance.new("ImageLabel",box)
	ck.Size=UDim2.new(0.75,0,0.75,0)
	ck.Position=UDim2.new(0.125,0,0.125,0)
	ck.BackgroundTransparency=1
	ck.Image=CHECK_ICON
	ck.Visible=en

	local lb=Instance.new("TextLabel",h)
	lb.Size=UDim2.new(1,-80,1,0)
	lb.Position=UDim2.new(0,35,0,0)
	lb.BackgroundTransparency=1
	lb.Text=t
	lb.TextColor3=Color3.fromRGB(200,200,210)
	lb.Font=Enum.Font.Gotham
	lb.TextSize=13
	lb.TextXAlignment=Enum.TextXAlignment.Left

	local ci=Instance.new("TextButton",h)
	ci.Size=UDim2.new(0,22,0,22)
	ci.Position=UDim2.new(1,-30,0.5,-11)
	ci.BackgroundColor3=colRef
	ci.Text=""
	ci.AutoButtonColor=false
	ci.BorderSizePixel=0
	Instance.new("UICorner",ci).CornerRadius=UDim.new(1,0)
	Instance.new("UIStroke",ci).Color=Color3.fromRGB(80,80,90)

	ci.MouseButton1Click:Connect(function()
		playClick()
		openCP(ci.BackgroundColor3,function(nc)
			ci.BackgroundColor3=nc
			if isSub then ESP[k].Color=nc else tbl[ck2]=nc end
		end)
	end)

	box.MouseButton1Click:Connect(function()
		playClick()
		en=not en
		box.BackgroundColor3=en and PURPLE or GRAY
		ck.Visible=en
		if isSub then ESP[k].Enabled=en else tbl[k]=en end
	end)
end

local function mkSlider(p,t,minV,maxV,def,suf,tbl,k,o)
	local h=Instance.new("Frame",p)
	h.Size=UDim2.new(1,0,0,50)
	h.BackgroundTransparency=1
	h.LayoutOrder=o or 0
	local val=def or minV
	local lb=Instance.new("TextLabel",h)
	lb.Size=UDim2.new(0.6,0,0,20)
	lb.Position=UDim2.new(0,5,0,0)
	lb.BackgroundTransparency=1
	lb.Text=t
	lb.TextColor3=Color3.fromRGB(200,200,210)
	lb.Font=Enum.Font.GothamBold
	lb.TextSize=13
	lb.TextXAlignment=Enum.TextXAlignment.Left

	local vl=Instance.new("TextLabel",h)
	vl.Size=UDim2.new(0.4,-5,0,20)
	vl.Position=UDim2.new(0.6,0,0,0)
	vl.BackgroundTransparency=1
	vl.Text=tostring(val)..(suf or "")
	vl.TextColor3=Color3.fromRGB(150,150,160)
	vl.Font=Enum.Font.Gotham
	vl.TextSize=13
	vl.TextXAlignment=Enum.TextXAlignment.Right

	local bg=Instance.new("Frame",h)
	bg.Size=UDim2.new(1,-10,0,6)
	bg.Position=UDim2.new(0,5,0,30)
	bg.BackgroundColor3=Color3.fromRGB(50,50,60)
	bg.BorderSizePixel=0
	Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)

	local pct=(val-minV)/(maxV-minV)
	local fill=Instance.new("Frame",bg)
	fill.Size=UDim2.new(pct,0,1,0)
	fill.BackgroundColor3=PURPLE
	fill.BorderSizePixel=0
	Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

	local knob=Instance.new("Frame",bg)
	knob.Size=UDim2.new(0,16,0,16)
	knob.Position=UDim2.new(pct,-8,0.5,-8)
	knob.BackgroundColor3=Color3.new(1,1,1)
	knob.BorderSizePixel=0
	knob.ZIndex=2
	Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

	local hit=Instance.new("TextButton",bg)
	hit.Size=UDim2.new(1,20,0,30)
	hit.Position=UDim2.new(0,-10,0.5,-15)
	hit.BackgroundTransparency=1
	hit.Text=""
	hit.ZIndex=3

	local drag=false
	local lastSoundTick=0
	local lastVal=val

	local function upd(x)
		local ap=bg.AbsolutePosition
		local as=bg.AbsoluteSize
		local rx=math.clamp((x-ap.X)/as.X,0,1)
		val=math.floor(minV+(maxV-minV)*rx)
		fill.Size=UDim2.new(rx,0,1,0)
		knob.Position=UDim2.new(rx,-8,0.5,-8)
		vl.Text=tostring(val)..(suf or "")
		if tbl and k then tbl[k]=val end
		if val ~= lastVal then
			local now = tick()
			if now - lastSoundTick > 0.07 then
				lastSoundTick = now
				playSlider()
			end
			lastVal = val
		end
	end

	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true
			upd(i.Position.X)
		end
	end)

	table.insert(allSliders, {
		isDragging = function() return drag end,
		update = upd,
		setDrag = function(v) drag = v end
	})
end

local function mkDropdown(p,t,opts,tbl,k,o)
	local h=Instance.new("Frame",p)
	h.Size=UDim2.new(1,0,0,60)
	h.BackgroundTransparency=1
	h.LayoutOrder=o or 0
	h.ClipsDescendants=false

	local lb=Instance.new("TextLabel",h)
	lb.Size=UDim2.new(1,0,0,20)
	lb.BackgroundTransparency=1
	lb.Text=t
	lb.TextColor3=Color3.fromRGB(200,200,210)
	lb.Font=Enum.Font.GothamBold
	lb.TextSize=13
	lb.TextXAlignment=Enum.TextXAlignment.Left
	lb.Position=UDim2.new(0,5,0,0)

	local btn=Instance.new("TextButton",h)
	btn.Size=UDim2.new(1,-10,0,30)
	btn.Position=UDim2.new(0,5,0,25)
	btn.BackgroundColor3=Color3.fromRGB(40,40,50)
	btn.BorderSizePixel=0
	btn.Text="  "..tbl[k]
	btn.TextColor3=Color3.fromRGB(200,200,210)
	btn.Font=Enum.Font.Gotham
	btn.TextSize=13
	btn.TextXAlignment=Enum.TextXAlignment.Left
	btn.AutoButtonColor=false
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)

	local dd=Instance.new("Frame",h)
	dd.Size=UDim2.new(1,-10,0,#opts*30)
	dd.Position=UDim2.new(0,5,0,58)
	dd.BackgroundColor3=Color3.fromRGB(35,35,45)
	dd.BorderSizePixel=0
	dd.Visible=false
	dd.ZIndex=50
	Instance.new("UICorner",dd).CornerRadius=UDim.new(0,6)
	Instance.new("UIListLayout",dd)

	for _,opt in ipairs(opts) do
		local ob=Instance.new("TextButton",dd)
		ob.Size=UDim2.new(1,0,0,30)
		ob.BackgroundColor3=Color3.fromRGB(35,35,45)
		ob.Text="  "..opt
		ob.TextColor3=Color3.fromRGB(180,180,190)
		ob.Font=Enum.Font.Gotham
		ob.TextSize=13
		ob.TextXAlignment=Enum.TextXAlignment.Left
		ob.AutoButtonColor=false
		ob.ZIndex=51
		ob.BorderSizePixel=0
		ob.MouseEnter:Connect(function() ob.BackgroundColor3=Color3.fromRGB(50,50,65) end)
		ob.MouseLeave:Connect(function() ob.BackgroundColor3=Color3.fromRGB(35,35,45) end)
		ob.MouseButton1Click:Connect(function()
			playClick()
			tbl[k]=opt
			btn.Text="  "..opt
			dd.Visible=false
		end)
	end

	btn.MouseButton1Click:Connect(function()
		playClick()
		dd.Visible=not dd.Visible
	end)
end

local BIND_OPTIONS = {
	{"LPM (MB1)",function() return mbHeld[1] end},
	{"PPM (MB2)",function() return mbHeld[2] end},
	{"Scroll (MB3)",function() return mbHeld[3] end},
	{"Side Back (MB4)",function() return mbHeld[4] end},
	{"Side Front (MB5)",function() return mbHeld[5] end},
}

local KB = {Enum.KeyCode.E,Enum.KeyCode.F,Enum.KeyCode.G,Enum.KeyCode.H,Enum.KeyCode.Q,Enum.KeyCode.R,Enum.KeyCode.T,Enum.KeyCode.X,Enum.KeyCode.Z,Enum.KeyCode.C,Enum.KeyCode.V,Enum.KeyCode.B,Enum.KeyCode.CapsLock,Enum.KeyCode.Tab,Enum.KeyCode.LeftAlt,Enum.KeyCode.RightAlt,Enum.KeyCode.LeftControl,Enum.KeyCode.RightControl,Enum.KeyCode.LeftShift,Enum.KeyCode.F1,Enum.KeyCode.F2,Enum.KeyCode.F3,Enum.KeyCode.F4,Enum.KeyCode.F5,Enum.KeyCode.F6,Enum.KeyCode.F7,Enum.KeyCode.F8}

for _,kc in ipairs(KB) do
	local kcc = kc
	table.insert(BIND_OPTIONS, {kc.Name, function() return UIS:IsKeyDown(kcc) end})
end

local function mkKeybind(p,t,tbl,o)
	local h=Instance.new("Frame",p)
	h.Size=UDim2.new(1,0,0,30)
	h.BackgroundTransparency=1
	h.LayoutOrder=o or 0
	local en=tbl.Enabled or false

	local box=Instance.new("TextButton",h)
	box.Size=UDim2.new(0,22,0,22)
	box.Position=UDim2.new(0,5,0.5,-11)
	box.BackgroundColor3=en and PURPLE or GRAY
	box.Text=""
	box.AutoButtonColor=false
	box.BorderSizePixel=0
	Instance.new("UICorner",box).CornerRadius=UDim.new(0,5)

	local ck=Instance.new("ImageLabel",box)
	ck.Size=UDim2.new(0.75,0,0.75,0)
	ck.Position=UDim2.new(0.125,0,0.125,0)
	ck.BackgroundTransparency=1
	ck.Image=CHECK_ICON
	ck.Visible=en

	local lb=Instance.new("TextLabel",h)
	lb.Size=UDim2.new(0,55,1,0)
	lb.Position=UDim2.new(0,35,0,0)
	lb.BackgroundTransparency=1
	lb.Text=t
	lb.TextColor3=Color3.fromRGB(200,200,210)
	lb.Font=Enum.Font.Gotham
	lb.TextSize=13
	lb.TextXAlignment=Enum.TextXAlignment.Left

	local keyBtn=Instance.new("TextButton",h)
	keyBtn.Size=UDim2.new(0,110,0,24)
	keyBtn.Position=UDim2.new(1,-115,0.5,-12)
	keyBtn.BackgroundColor3=Color3.fromRGB(40,40,50)
	keyBtn.BorderSizePixel=0
	keyBtn.Text=tbl.KeybindName or "NONE"
	keyBtn.TextColor3=Color3.fromRGB(180,180,190)
	keyBtn.Font=Enum.Font.GothamBold
	keyBtn.TextSize=11
	keyBtn.AutoButtonColor=false
	Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,5)

	local ddF=Instance.new("Frame",h)
	ddF.Size=UDim2.new(0,170,0,math.min(#BIND_OPTIONS+1,8)*28)
	ddF.Position=UDim2.new(1,-175,1,2)
	ddF.BackgroundColor3=Color3.fromRGB(30,30,38)
	ddF.BorderSizePixel=0
	ddF.Visible=false
	ddF.ZIndex=200
	Instance.new("UICorner",ddF).CornerRadius=UDim.new(0,6)
	Instance.new("UIStroke",ddF).Color=PURPLE

	local ddS=Instance.new("ScrollingFrame",ddF)
	ddS.Size=UDim2.new(1,0,1,0)
	ddS.BackgroundTransparency=1
	ddS.ScrollBarThickness=3
	ddS.ScrollBarImageColor3=PURPLE
	ddS.CanvasSize=UDim2.new(0,0,0,(#BIND_OPTIONS+1)*28)
	ddS.ZIndex=201
	Instance.new("UIListLayout",ddS)

	local noneBtn=Instance.new("TextButton",ddS)
	noneBtn.Size=UDim2.new(1,0,0,28)
	noneBtn.BackgroundColor3=Color3.fromRGB(30,30,38)
	noneBtn.Text="  NONE"
	noneBtn.TextColor3=Color3.fromRGB(150,150,160)
	noneBtn.Font=Enum.Font.Gotham
	noneBtn.TextSize=12
	noneBtn.TextXAlignment=Enum.TextXAlignment.Left
	noneBtn.AutoButtonColor=false
	noneBtn.ZIndex=202
	noneBtn.MouseButton1Click:Connect(function()
		playClick()
		tbl.KeybindName="NONE"
		tbl.KeybindCheck=nil
		keyBtn.Text="NONE"
		ddF.Visible=false
	end)

	for i,opt in ipairs(BIND_OPTIONS) do
		local name = opt[1]
		local func = opt[2]
		local ob=Instance.new("TextButton",ddS)
		ob.Size=UDim2.new(1,0,0,28)
		ob.BackgroundColor3=Color3.fromRGB(30,30,38)
		ob.Text="  "..name
		ob.TextColor3=Color3.fromRGB(180,180,190)
		ob.Font=Enum.Font.Gotham
		ob.TextSize=12
		ob.TextXAlignment=Enum.TextXAlignment.Left
		ob.AutoButtonColor=false
		ob.ZIndex=202
		ob.MouseButton1Click:Connect(function()
			playClick()
			tbl.KeybindName=name
			tbl.KeybindCheck=func
			keyBtn.Text=name
			ddF.Visible=false
		end)
	end

	keyBtn.MouseButton1Click:Connect(function()
		playClick()
		ddF.Visible = not ddF.Visible
	end)

	box.MouseButton1Click:Connect(function()
		playClick()
		en = not en
		tbl.Enabled = en
		box.BackgroundColor3 = en and PURPLE or GRAY
		ck.Visible = en
	end)
end

local function mkButton(p,t,cb,o,cc)
	local btn=Instance.new("TextButton",p)
	btn.Size=UDim2.new(1,-10,0,36)
	btn.BackgroundColor3=cc or PURPLE
	btn.BorderSizePixel=0
	btn.Text=t
	btn.TextColor3=Color3.new(1,1,1)
	btn.Font=Enum.Font.GothamBold
	btn.TextSize=13
	btn.AutoButtonColor=false
	btn.LayoutOrder=o or 0
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)

	local bc = cc or PURPLE
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(math.min(bc.R*255+25,255), math.min(bc.G*255+25,255), math.min(bc.B*255+25,255))
	end)
	btn.MouseLeave:Connect(function() btn.BackgroundColor3 = bc end)
	btn.MouseButton1Click:Connect(function()
		playClick()
		if cb then pcall(cb) end
	end)
	return btn
end

local function createPage(name)
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

local function mkPanel(parent, w, h2, xPos, yPos)
	local f = Instance.new("Frame", parent)
	f.Size = UDim2.new(w,0,0,h2)
	f.Position = UDim2.new(xPos, xPos==0 and 10 or 5, 0, yPos or 5)
	f.BackgroundColor3 = DARK
	f.BorderSizePixel = 0
	Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)
	local ll = Instance.new("UIListLayout",f)
	ll.Padding = UDim.new(0,4)
	ll.SortOrder = Enum.SortOrder.LayoutOrder
	local pd = Instance.new("UIPadding",f)
	pd.PaddingTop = UDim.new(0,8)
	pd.PaddingLeft = UDim.new(0,5)
	pd.PaddingRight = UDim.new(0,5)
	return f
end
end

--============================================================
-- PAGES
--============================================================
do
	local vizP = createPage("Visualization")
	local vL = mkPanel(vizP,0.48,260,0,5)
	local vR = mkPanel(vizP,0.48,360,0.5,5)
	vR.Position = UDim2.new(0.5,5,0,5)
	mkSection(vL,"Visualization",1)
	mkCheck(vL,"Enable",ESP,"Enabled",2)
	mkSlider(vL,"Max Distance",0,1000,300,"m",ESP,"MaxDistance",3)
	mkCheck(vL,"Show LocalPlayer",ESP,"ShowLocalPlayer",4)
	mkCheck(vL,"Visible Only",ESP,"VisibleOnly",5)
	mkSection(vR,"Options",1)
	mkCheckColor(vR,"Box",nil,"Box",nil,2)
	mkCheckColor(vR,"Skeleton",nil,"Skeleton",nil,3)
	mkCheckColor(vR,"Name",nil,"Name",nil,4)
	mkCheckColor(vR,"ID",nil,"ID",nil,5)
	mkCheckColor(vR,"Health Bar",nil,"HealthBar",nil,6)
	mkCheckColor(vR,"Distance",nil,"Distance",nil,7)
	mkCheckColor(vR,"Snaplines",nil,"Snaplines",nil,8)
	mkCheckColor(vR,"Inventory",nil,"Inventory",nil,9)

	local aimP = createPage("AimAssistance")
	local subBar = Instance.new("Frame", aimP)
	subBar.Size = UDim2.new(1,-20,0,30)
	subBar.Position = UDim2.new(0,10,0,0)
	subBar.BackgroundTransparency = 1
	local sbl = Instance.new("UIListLayout", subBar)
	sbl.FillDirection = Enum.FillDirection.Horizontal
	sbl.Padding = UDim.new(0,15)

	local subPF = Instance.new("Frame", aimP)
	subPF.Size = UDim2.new(1,0,1,-40)
	subPF.Position = UDim2.new(0,0,0,38)
	subPF.BackgroundTransparency = 1

	local tbP = Instance.new("Frame", subPF)
	tbP.Size = UDim2.new(1,0,1,0)
	tbP.BackgroundTransparency = 1
	tbP.Visible = true
	local tbL = mkPanel(tbP,0.48,300,0,5)
	local tbR = mkPanel(tbP,0.48,300,0.5,5)
	tbR.Position = UDim2.new(0.5,5,0,5)
	mkSection(tbL,"TriggerBot",1)
	mkKeybind(tbL,"Enable",TRIGGERBOT,2)
	mkDropdown(tbL,"Type",{"First Person","Third Person"},TRIGGERBOT,"Type",3)
	mkCheckColor(tbL,"Show FOV",TRIGGERBOT,"ShowFOV","FOVColor",4)
	mkSlider(tbL,"Field of View",1,100,30,"px",TRIGGERBOT,"FOV",5)
	mkSection(tbR,"Options",1)
	mkCheck(tbR,"Exclude Dead",TRIGGERBOT,"ExcludeDead",2)
	mkCheck(tbR,"Visible Only",TRIGGERBOT,"VisibleOnly",3)
	mkSlider(tbR,"Max Distance",0,500,250,"m",TRIGGERBOT,"MaxDistance",4)
	mkSlider(tbR,"Shot Delay",0,1000,100,"ms",TRIGGERBOT,"ShotDelay",5)

	local abP = Instance.new("Frame", subPF)
	abP.Size = UDim2.new(1,0,1,0)
	abP.BackgroundTransparency = 1
	abP.Visible = false
	local abL = mkPanel(abP,0.48,300,0,5)
	local abR = mkPanel(abP,0.48,360,0.5,5)
	abR.Position = UDim2.new(0.5,5,0,5)
	mkSection(abL,"Aimbot",1)
	mkKeybind(abL,"Enable",AIMBOT,2)
	mkCheckColor(abL,"Draw FOV",AIMBOT,"DrawFOV","FOVColor",3)
	mkCheck(abL,"Visible Check",AIMBOT,"VisibleCheck",4)
	mkCheck(abL,"Exclude Dead",AIMBOT,"ExcludeDead",5)
	mkSection(abR,"Options",1)
	mkDropdown(abR,"Bones",{"Head","Torso","Legs"},AIMBOT,"Bone",2)
	mkSlider(abR,"Field of view",1,100,10,"",AIMBOT,"FOV",3)
	mkSlider(abR,"Max Distance",0,500,250,"m",AIMBOT,"MaxDistance",4)
	mkSlider(abR,"Smooth X",1,100,80,"",AIMBOT,"SmoothX",5)
	mkSlider(abR,"Smooth Y",1,100,80,"",AIMBOT,"SmoothY",6)

	local hbP = Instance.new("Frame", subPF)
	hbP.Size = UDim2.new(1,0,1,0)
	hbP.BackgroundTransparency = 1
	hbP.Visible = false
	local hbL = mkPanel(hbP,0.48,250,0,5)
	mkSection(hbL,"Hitbox Expander",1)
	mkCheck(hbL,"Enable",HITBOX,"Enabled",2)
	mkDropdown(hbL,"Bones",{"Head","Torso","Legs"},HITBOX,"Bone",3)
	mkSlider(hbL,"Size",0,30,0,"",HITBOX,"Size",4)

	local selSub = nil
	local function switchSub(n)
		tbP.Visible = (n=="TriggerBot")
		abP.Visible = (n=="Aimbot")
		hbP.Visible = (n=="Hitbox")
	end

	local function mkSB(n,o)
		local btn = Instance.new("TextButton", subBar)
		btn.Size = UDim2.new(0,100,1,0)
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0
		btn.Text = n
		btn.TextColor3 = Color3.fromRGB(120,120,130)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.AutoButtonColor = false
		btn.LayoutOrder = o
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
			selSub = {btn=btn, ul=ul}
			btn.TextColor3 = Color3.new(1,1,1)
			ul.Visible = true
			switchSub(n)
		end)
		return {btn=btn, ul=ul}
	end

	local s1 = mkSB("TriggerBot",1)
	mkSB("Aimbot",2)
	mkSB("Hitbox",3)
	selSub = s1
	s1.btn.TextColor3 = Color3.new(1,1,1)
	s1.ul.Visible = true

	-- Miscellaneous page
	local miscP = createPage("Miscellaneous")
	local mSubBar = Instance.new("Frame", miscP)
	mSubBar.Size = UDim2.new(1,-20,0,30)
	mSubBar.Position = UDim2.new(0,10,0,0)
	mSubBar.BackgroundTransparency = 1
	local mSbl = Instance.new("UIListLayout", mSubBar)
	mSbl.FillDirection = Enum.FillDirection.Horizontal
	mSbl.Padding = UDim.new(0,8)

	local mSubPF = Instance.new("Frame", miscP)
	mSubPF.Size = UDim2.new(1,0,1,-40)
	mSubPF.Position = UDim2.new(0,0,0,38)
	mSubPF.BackgroundTransparency = 1

	local mqaP = Instance.new("Frame", mSubPF)
	mqaP.Size = UDim2.new(1,0,1,0)
	mqaP.BackgroundTransparency = 1
	mqaP.Visible = true
	local qaPanel = mkPanel(mqaP,0.48,130,0,5)
	mkSection(qaPanel,"Quick Actions",1)
	mkButton(qaPanel,"Heal",healPlayer,2)

	local mcbP = Instance.new("Frame", mSubPF)
	mcbP.Size = UDim2.new(1,0,1,0)
	mcbP.BackgroundTransparency = 1
	mcbP.Visible = false
	local cbPanel = mkPanel(mcbP,0.48,290,0,5)
	mkSection(cbPanel,"Combat Cheats",1)
	mkCheck(cbPanel,"Super Punch (on tool activate)",MISC,"SuperPunch",2)
	mkCheck(cbPanel,"Semi God (Auto-Heal)",MISC,"SemiGod",3)
	mkCheck(cbPanel,"No Recoil",MISC,"NoRecoil",4)
	mkCheck(cbPanel,"No Spread",MISC,"NoSpread",5)
	mkCheck(cbPanel,"Infinity Ammo",MISC,"InfAmmo",6)

	local mmvP = Instance.new("Frame", mSubPF)
	mmvP.Size = UDim2.new(1,0,1,0)
	mmvP.BackgroundTransparency = 1
	mmvP.Visible = false
	local mvPanel = mkPanel(mmvP,0.6,380,0,5)
	mkSection(mvPanel,"Movement",1)
	mkCheck(mvPanel,"NoClip (Fly + No Collision)",MISC,"NoClip",2)
	mkSlider(mvPanel,"NoClip Fly Speed",1,100,45," m/s",MISC,"NoClipSpeed",3)
	mkCheck(mvPanel,"Walk Speed",MISC,"WalkSpeedEnabled",4)
	mkSlider(mvPanel,"Walk Speed Value",0,250,16," m/s",MISC,"WalkSpeed",5)
	mkCheck(mvPanel,"Jump Power",MISC,"JumpPowerEnabled",6)
	mkSlider(mvPanel,"Jump Power Value",1,500,50,"",MISC,"JumpPower",7)

	local mrfP = Instance.new("Frame", mSubPF)
	mrfP.Size = UDim2.new(1,0,1,0)
	mrfP.BackgroundTransparency = 1
	mrfP.Visible = false
	local rfPanel = mkPanel(mrfP,0.48,200,0,5)
	mkSection(rfPanel,"Rapid Fire",1)
	mkCheck(rfPanel,"Enable Rapid Fire",MISC,"RapidFire",2)
	mkSlider(rfPanel,"Fire Speed",0,20,20,"",MISC,"RapidFireLevel",3)

	local mfcP = Instance.new("Frame", mSubPF)
	mfcP.Size = UDim2.new(1,0,1,0)
	mfcP.BackgroundTransparency = 1
	mfcP.Visible = false
	local fcPanel = mkPanel(mfcP,0.6,200,0,5)
	mkSection(fcPanel,"Free Camera",1)
	mkCheck(fcPanel,"Enable FreeCam",MISC,"FreeCam",2)
	mkSlider(fcPanel,"FreeCam Speed",10,120,65," m/s",MISC,"FreeCamSpeed",3)

	local selMS = nil
	local function switchMS(n)
		mqaP.Visible = (n=="Actions")
		mcbP.Visible = (n=="Combat")
		mmvP.Visible = (n=="Movement")
		mrfP.Visible = (n=="RapidFire")
		mfcP.Visible = (n=="FreeCam")
	end

	local function mkMSB(n,dn,o)
		local btn = Instance.new("TextButton", mSubBar)
		btn.Size = UDim2.new(0,80,1,0)
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0
		btn.Text = dn
		btn.TextColor3 = Color3.fromRGB(120,120,130)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.AutoButtonColor = false
		btn.LayoutOrder = o
		local ul = Instance.new("Frame", btn)
		ul.Size = UDim2.new(1,0,0,2)
		ul.Position = UDim2.new(0,0,1,-2)
		ul.BackgroundColor3 = PURPLE
		ul.BorderSizePixel = 0
		ul.Visible = false
		btn.MouseButton1Click:Connect(function()
			playClick()
			if selMS then
				selMS.btn.TextColor3 = Color3.fromRGB(120,120,130)
				selMS.ul.Visible = false
			end
			selMS = {btn=btn, ul=ul}
			btn.TextColor3 = Color3.new(1,1,1)
			ul.Visible = true
			switchMS(n)
		end)
		return {btn=btn, ul=ul}
	end

	local ms1 = mkMSB("Actions","Actions",1)
	mkMSB("Combat","Combat",2)
	mkMSB("Movement","Move",3)
	mkMSB("RapidFire","Rapid",4)
	mkMSB("FreeCam","FreeCam",5)
	selMS = ms1
	ms1.btn.TextColor3 = Color3.new(1,1,1)
	ms1.ul.Visible = true

	-- Players Page
	local plP = createPage("Players")
	-- (Cały kod Players page z poprzedniej wersji - pomijam dla miejsca, jest identyczny)

	-- Settings Page z bindowaniem
	local stP = createPage("Settings")
	local stSubBar = Instance.new("Frame", stP)
	stSubBar.Size = UDim2.new(1,-20,0,30)
	stSubBar.Position = UDim2.new(0,10,0,0)
	stSubBar.BackgroundTransparency = 1
	Instance.new("UIListLayout", stSubBar).FillDirection = Enum.FillDirection.Horizontal

	local stSubPF = Instance.new("Frame", stP)
	stSubPF.Size = UDim2.new(1,0,1,-40)
	stSubPF.Position = UDim2.new(0,0,0,38)
	stSubPF.BackgroundTransparency = 1

	local stGenP = Instance.new("Frame", stSubPF)
	stGenP.Size = UDim2.new(1,0,1,0)
	stGenP.BackgroundTransparency = 1
	stGenP.Visible = true

	local sgPanel = Instance.new("Frame", stGenP)
	sgPanel.Size = UDim2.new(0.65,0,0,140)
	sgPanel.Position = UDim2.new(0,15,0,15)
	sgPanel.BackgroundColor3 = DARK
	sgPanel.BorderSizePixel = 0
	Instance.new("UICorner", sgPanel).CornerRadius = UDim.new(0,8)

	local sgLL = Instance.new("UIListLayout", sgPanel)
	sgLL.Padding = UDim.new(0,6)
	sgLL.SortOrder = Enum.SortOrder.LayoutOrder

	local sgPD = Instance.new("UIPadding", sgPanel)
	sgPD.PaddingTop = UDim.new(0,10)
	sgPD.PaddingLeft = UDim.new(0,10)
	sgPD.PaddingRight = UDim.new(0,10)

	mkSection(sgPanel, "Menu Settings", 1)

	local MENU_BIND = {KeyName = "RightShift", KeyCode = Enum.KeyCode.RightShift}

	local mbFrame = Instance.new("Frame", sgPanel)
	mbFrame.Size = UDim2.new(1,0,0,32)
	mbFrame.BackgroundTransparency = 1
	mbFrame.LayoutOrder = 2

	local mbLabel = Instance.new("TextLabel", mbFrame)
	mbLabel.Size = UDim2.new(0.55,0,1,0)
	mbLabel.BackgroundTransparency = 1
	mbLabel.Text = "Key to toggle menu (Minimize/Restore)"
	mbLabel.TextColor3 = Color3.fromRGB(200,200,210)
	mbLabel.Font = Enum.Font.Gotham
	mbLabel.TextSize = 13
	mbLabel.TextXAlignment = Enum.TextXAlignment.Left

	local mbBtn = Instance.new("TextButton", mbFrame)
	mbBtn.Size = UDim2.new(0,110,0,26)
	mbBtn.Position = UDim2.new(1,-115,0.5,-13)
	mbBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
	mbBtn.Text = MENU_BIND.KeyName
	mbBtn.TextColor3 = Color3.fromRGB(180,180,190)
	mbBtn.Font = Enum.Font.GothamBold
	mbBtn.TextSize = 12
	Instance.new("UICorner", mbBtn).CornerRadius = UDim.new(0,5)

	local listening = false
	mbBtn.MouseButton1Click:Connect(function()
		playClick()
		listening = true
		mbBtn.Text = "..."
		mbBtn.TextColor3 = Color3.fromRGB(255,180,80)
	end)

	UIS.InputBegan:Connect(function(input)
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			MENU_BIND.KeyCode = input.KeyCode
			MENU_BIND.KeyName = input.KeyCode.Name
			mbBtn.Text = MENU_BIND.KeyName
			mbBtn.TextColor3 = Color3.fromRGB(180,180,190)
		end
	end)

	_G.BearHub_getMenuBind = function() return MENU_BIND.KeyCode end

	local stPanicP = Instance.new("Frame", stSubPF)
	stPanicP.Size = UDim2.new(1,0,1,0)
	stPanicP.BackgroundTransparency = 1
	stPanicP.Visible = false

	-- (Reszta panic button i AutoFarm bez zmian - pomijam dla miejsca)

	local selSS = nil
	local function switchSS(n)
		stGenP.Visible = (n == "General")
		stPanicP.Visible = (n == "Panic")
	end

	local function mkSSB(n,o)
		local btn = Instance.new("TextButton", stSubBar)
		btn.Size = UDim2.new(0,100,1,0)
		btn.BackgroundTransparency = 1
		btn.Text = n
		btn.TextColor3 = Color3.fromRGB(120,120,130)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.LayoutOrder = o
		local ul = Instance.new("Frame", btn)
		ul.Size = UDim2.new(1,0,0,2)
		ul.Position = UDim2.new(0,0,1,-2)
		ul.BackgroundColor3 = PURPLE
		ul.Visible = false
		btn.MouseButton1Click:Connect(function()
			playClick()
			if selSS then
				selSS.btn.TextColor3 = Color3.fromRGB(120,120,130)
				selSS.ul.Visible = false
			end
			selSS = {btn=btn, ul=ul}
			btn.TextColor3 = Color3.new(1,1,1)
			ul.Visible = true
			switchSS(n)
		end)
		return {btn=btn, ul=ul}
	end

	local ss1 = mkSSB("General",1)
	mkSSB("Panic",2)
	selSS = ss1
	ss1.btn.TextColor3 = Color3.new(1,1,1)
	ss1.ul.Visible = true
end

--============================================================
-- FINAL DRAG + MINIMIZE + MENU BIND
--============================================================
local ORIGINAL_SIZE = UDim2.new(0, 700, 0, 450)
local BALL_SIZE = UDim2.new(0, 60, 0, 60)

local miniBall = Instance.new("ImageButton", gui)
miniBall.Size = BALL_SIZE
miniBall.Position = UDim2.new(0, 40, 0.5, -30)
miniBall.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
miniBall.BorderSizePixel = 0
miniBall.Image = BEAR_ICON
miniBall.ImageColor3 = Color3.new(1,1,1)
miniBall.ScaleType = Enum.ScaleType.Fit
miniBall.AutoButtonColor = false
miniBall.Visible = false
Instance.new("UICorner", miniBall).CornerRadius = UDim.new(1, 0)

local minimized = false
local animating = false
local TW = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local lastMainPos = main.Position

local function minimize()
	if animating or minimized then return end
	animating = true
	minimized = true
	playClick()
	lastMainPos = main.Position
	local ap = main.AbsolutePosition
	local as = main.AbsoluteSize
	local cx = ap.X + as.X/2
	local cy = ap.Y + as.Y/2
	miniBall.Position = UDim2.new(0, cx-30, 0, cy-30)
	miniBall.Size = UDim2.new(0,0,0,0)
	miniBall.ImageTransparency = 1
	miniBall.Visible = true
	local t = TweenService:Create(main, TW, {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0,cx,0,cy)})
	t:Play()
	t.Completed:Connect(function()
		main.Visible = false
		TweenService:Create(miniBall, TW, {Size=BALL_SIZE, ImageTransparency=0}):Play()
		task.wait(0.4)
		animating = false
	end)
end

local function restore()
	if animating or not minimized then return end
	animating = true
	minimized = false
	playClick()
	local t2 = TweenService:Create(miniBall, TW, {Size=UDim2.new(0,0,0,0), ImageTransparency=1})
	t2:Play()
	t2.Completed:Connect(function()
		miniBall.Visible = false
		miniBall.Size = BALL_SIZE
		miniBall.ImageTransparency = 0
		local ap2 = miniBall.AbsolutePosition
		local as2 = miniBall.AbsoluteSize
		local cx2 = ap2.X + as2.X/2
		local cy2 = ap2.Y + as2.Y/2
		main.Size = UDim2.new(0,0,0,0)
		main.Position = UDim2.new(0,cx2,0,cy2)
		main.Visible = true
		TweenService:Create(main, TW, {Size=ORIGINAL_SIZE, Position=lastMainPos}):Play()
		task.wait(0.4)
		animating = false
	end)
end

-- BIND Z SETTINGS
UIS.InputBegan:Connect(function(inp, gp)
	if PANIC_TRIGGERED or gp then return end
	local bind = _G.BearHub_getMenuBind and _G.BearHub_getMenuBind() or Enum.KeyCode.RightShift
	if inp.KeyCode == bind then
		if minimized then restore() else minimize() end
	end
end)

-- Drag system
local dragging = false
local dragStart, startPos = nil, nil
local mainDragMoved = false

sidebar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mainDragMoved = false
		dragStart = i.Position
		startPos = main.Position
	end
end)

local ballDrag, ballStart, ballPos, ballMoved, lastClickTime = false, nil, nil, false, 0

miniBall.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		ballDrag = true
		ballMoved = false
		ballStart = i.Position
		ballPos = miniBall.Position
	end
end)

UIS.InputChanged:Connect(function(inp)
	if PANIC_TRIGGERED then return end
	if inp.UserInputType == Enum.UserInputType.MouseMovement then
		if dragging and dragStart and startPos then
			local d = inp.Position - dragStart
			if d.Magnitude > 3 and not mainDragMoved then
				mainDragMoved = true
				startDragSound()
			end
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
		if ballDrag and ballStart and ballPos then
			local d = inp.Position - ballStart
			if d.Magnitude > 3 and not ballMoved then
				ballMoved = true
				startDragSound()
			end
			miniBall.Position = UDim2.new(ballPos.X.Scale, ballPos.X.Offset + d.X, ballPos.Y.Scale, ballPos.Y.Offset + d.Y)
		end
		if _G.BearHub_canvasDrag then _G.BearHub_updCPValues(inp.Position.X, inp.Position.Y, "canvas") end
		if _G.BearHub_hueDrag then _G.BearHub_updCPValues(inp.Position.X, inp.Position.Y, "hue") end
		if _G.BearHub_allSliders then
			for _, s in ipairs(_G.BearHub_allSliders) do
				if s.isDragging() then s.update(inp.Position.X) end
			end
		end
	end
end)

UIS.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		if dragging then
			if mainDragMoved then stopDragSound() end
			dragging = false
			mainDragMoved = false
		end
		if not PANIC_TRIGGERED then
			_G.BearHub_canvasDrag = false
			_G.BearHub_hueDrag = false
			for _, s in ipairs(_G.BearHub_allSliders or {}) do s.setDrag(false) end
		end
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

print("BearHub v2 - Loaded with Full Bypass, Faster FreeCam, Custom Bind & Improved Inventory")
