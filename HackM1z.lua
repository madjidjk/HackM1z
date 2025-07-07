

local Players, RS, UIS, TS, Lighting = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TeleportService"), game:GetService("Lighting")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local backpack = lp:WaitForChild("Backpack")

local flySpeed, flying, noclip = 60, false, false
local control = {F=0, B=0, L=0, R=0, U=0, D=0}
local bv, bg

-- Tool Clone Scan
local containers = {
	game:GetService("Workspace"),
	game:GetService("ReplicatedStorage"),
	game:GetService("Lighting"),
	game:GetService("ReplicatedFirst"),
	game:GetService("StarterPack"),
}

local function cloneAllTools()
	print("🔍 Scanning for Tools...")
	local count = 0
	for _, container in ipairs(containers) do
		for _, obj in ipairs(container:GetDescendants()) do
			if obj:IsA("Tool") then
				local success, tool = pcall(function()
					local c = obj:Clone()
					c.Parent = backpack
					return c
				end)
				if success and tool then
					print("✅ Cloned:", tool:GetFullName())
					count += 1
				end
			end
		end
	end
	print("📦 Total tools cloned:", count)
end

-- Remote Exploit Tester
local function testRemotes()
	print("🛰️ Testing RemoteEvents & Functions")
	for _, obj in pairs(game:GetDescendants()) do
		if obj:IsA("RemoteEvent") then
			pcall(function()
				obj:FireServer("Test", math.random())
				warn("❗ RemoteEvent unsecured:", obj:GetFullName())
			end)
		elseif obj:IsA("RemoteFunction") then
			local success, result = pcall(function()
				return obj:InvokeServer("TestInvoke")
			end)
			if success then
				warn("❗ RemoteFunction may be exposed:", obj:GetFullName())
			end
		end
	end
end

-- Filtering Check
if not workspace.FilteringEnabled then
	warn("🚨 FilteringEnabled is OFF! Game is not protected.")
end

-- Fly
UIS.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.F then
		if flying then
			flying = false
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
		else
			flying = true
			bv = Instance.new("BodyVelocity", hrp)
			bv.MaxForce = Vector3.new(1e5,1e5,1e5)
			bv.P = 1250
			bg = Instance.new("BodyGyro", hrp)
			bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
			bg.P = 3000
			bg.CFrame = hrp.CFrame
		end
	elseif i.KeyCode == Enum.KeyCode.N then
		noclip = not noclip
		print("Noclip:", noclip)
	elseif i.KeyCode == Enum.KeyCode.W then control.F = 1
	elseif i.KeyCode == Enum.KeyCode.S then control.B = -1
	elseif i.KeyCode == Enum.KeyCode.A then control.L = -1
	elseif i.KeyCode == Enum.KeyCode.D then control.R = 1
	elseif i.KeyCode == Enum.KeyCode.Space then control.U = 1
	elseif i.KeyCode == Enum.KeyCode.LeftShift then control.D = -1
end end)

UIS.InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.W then control.F = 0
	elseif i.KeyCode == Enum.KeyCode.S then control.B = 0
	elseif i.KeyCode == Enum.KeyCode.A then control.L = 0
	elseif i.KeyCode == Enum.KeyCode.D then control.R = 0
	elseif i.KeyCode == Enum.KeyCode.Space then control.U = 0
	elseif i.KeyCode == Enum.KeyCode.LeftShift then control.D = 0
end end)

RS.RenderStepped:Connect(function()
	if flying and bv and bg then
		local cf = cam.CFrame
		local move = (cf.LookVector * (control.F + control.B) + cf.RightVector * (control.R + control.L) + cf.UpVector * (control.U + control.D)) * flySpeed
		bv.Velocity = move
		bg.CFrame = CFrame.new(hrp.Position, hrp.Position + cf.LookVector)
	end
end)

RS.Stepped:Connect(function()
	if noclip then
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end
end)

-- Run all tests
cloneAllTools()
testRemotes()
print("✅ Security test complete. Press F for Fly, N for Noclip")
