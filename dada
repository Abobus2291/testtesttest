-- credits:
-- rang and nwer1qx

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
	Box = false,
	BoxOutline = true,
	BoxColor = Color3.fromRGB(255, 255, 255),
	BoxOutlineColor = Color3.fromRGB(0, 0, 0),
	HealthBar = true,
	HealthBarSide = "Left", -- Left, Bottom, Right
	Names = false,
	NamesOutline = true,
	NamesColor = Color3.fromRGB(255, 255, 255),
	NamesOutlineColor = Color3.fromRGB(0, 0, 0),
	NamesFont = 2, -- 0,1,2,3
	NamesSize = 13,
	StudsText = false,
	StudsOutline = true,
	StudsColor = Color3.fromRGB(255,255,255)
	StudsOutlineColor = Color3.fromRGB(255,255,255)
	ToolText = false,
	ToolOutline = true,
	ToolColor = Color3.fromRGB(255,255,255),
	ToolOutlineColor = Color3.fromRGB(255,255,255)
}

local function newText()
	local text = Drawing.new("Text")
	text.Center = true
	text.Outline = true
	text.OutlineColor = Color3.fromRGB(0, 0, 0)
	text.Font = 2
	text.Size = 13
	text.Visible = false
	return text
end

local function newBox(thickness, zindex, filled)
	local box = Drawing.new("Square")
	box.Thickness = thickness or 1
	box.ZIndex = zindex or 1
	box.Filled = filled or false
	box.Visible = false
	return box
end

local function RemoveDrawings(tbl)
	for _, v in pairs(tbl) do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		elseif typeof(v) == "Instance" then
			v:Destroy()
		elseif typeof(v) == "table" then
			RemoveDrawings(v)
		elseif typeof(v) == "userdata" and v.Remove then
			v:Remove()
		end
	end
end

local function CreateEsp(Player)
	local Box = newBox(1, 69)
	local BoxOutline = newBox(3, 1)
	local Name = newText()
	local HealthBar = newBox(1, 69, true)
	local HealthBarOutline = newBox(1, 1, true)
	local StudsText = newText()
	local ToolText = newText()

	local function Update()
		local char = Player.Character
		if not (char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head")) then
			Box.Visible = false
			BoxOutline.Visible = false
			Name.Visible = false
			HealthBar.Visible = false
			HealthBarOutline.Visible = false
			StudsText.Visible = false
			ToolText.Visible = false
			return
		end

		local humanoid = char.Humanoid
		if humanoid.Health <= 0 then
			Box.Visible = false
			BoxOutline.Visible = false
			Name.Visible = false
			HealthBar.Visible = false
			HealthBarOutline.Visible = false
			StudsText.Visible = false
			ToolText.Visible = false
			return
		end

		local root = char.HumanoidRootPart
		local head = char.Head
		local pos, onscreen = Camera:WorldToViewportPoint(root.Position)
		local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
		local width, height = math.floor(40 * scale), math.floor(60 * scale)
		local topLeft = Vector2.new(pos.X - width / 2, pos.Y - height / 2)

		-- Box
		if Config.Box then
			Box.Visible = onscreen
			Box.Color = Config.BoxColor
			Box.Size = Vector2.new(width, height)
			Box.Position = topLeft

			if Config.BoxOutline then
				BoxOutline.Visible = onscreen
				BoxOutline.Color = Config.BoxOutlineColor
				BoxOutline.Size = Box.Size
				BoxOutline.Position = Box.Position
			else
				BoxOutline.Visible = false
			end
		else
			Box.Visible = false
			BoxOutline.Visible = false
		end

		-- Name
		if Config.Names then
			Name.Visible = onscreen
			Name.Color = Config.NamesColor
			Name.Outline = Config.NamesOutline
			Name.OutlineColor = Config.NamesOutlineColor
			Name.Text = Player.Name .. " (" .. Player.DisplayName .. ")"
			Name.Font = Config.NamesFont
			Name.Size = Config.NamesSize
			Name.Position = Vector2.new(pos.X, topLeft.Y - 15)
		else
			Name.Visible = false
		end

		-- Health
		if Config.HealthBar then
			local hpRatio = humanoid.Health / humanoid.MaxHealth
			local barColor = Color3.fromRGB(255, 0, 0):lerp(Color3.fromRGB(0, 255, 0), hpRatio)
			HealthBar.Color = barColor
			HealthBar.Visible = onscreen
			HealthBarOutline.Visible = onscreen

			if Config.HealthBarSide == "Left" then
				HealthBarOutline.Size = Vector2.new(2, height)
				HealthBarOutline.Position = topLeft + Vector2.new(-6, 0)

				HealthBar.Size = Vector2.new(1, -(height - 2) * hpRatio)
				HealthBar.Position = HealthBarOutline.Position + Vector2.new(1, -1 + height)
			elseif Config.HealthBarSide == "Bottom" then
				HealthBarOutline.Size = Vector2.new(width, 3)
				HealthBarOutline.Position = topLeft + Vector2.new(0, height + 2)

				HealthBar.Size = Vector2.new((width - 2) * hpRatio, 1)
				HealthBar.Position = HealthBarOutline.Position + Vector2.new(1, -1 + HealthBarOutline.Size.Y)
			elseif Config.HealthBarSide == "Right" then
				HealthBarOutline.Size = Vector2.new(2, height)
				HealthBarOutline.Position = topLeft + Vector2.new(width + 1, 0)

				HealthBar.Size = Vector2.new(1, -(height - 2) * hpRatio)
				HealthBar.Position = HealthBarOutline.Position + Vector2.new(1, -1 + height)
			end
		else
			HealthBar.Visible = false
			HealthBarOutline.Visible = false
		end

		-- Studs
		if Config.StudsText then
			StudsText.Visible = onscreen
			local distance = (Camera.CFrame.Position - root.Position).Magnitude
			StudsText.Text = math.floor(distance) .. " Studs"
			StudsText.Position = Vector2.new(pos.X, pos.Y + height * 0.5 + 2)
			StudsText.Outline = Config.StudsOutline
			StudsText.OutlineColor = Config.StudsOutlineColor
			StudsText.Color = Config.StudsColor
			StudsText.Font = 2
			StudsText.Size = 13
		else
			StudsText.Visible = false
		end

		-- Tool
		if Config.ToolText then
			ToolText.Visible = onscreen
			local tool = nil
			for _, obj in ipairs(char:GetChildren()) do
				if obj:IsA("Tool") then
					tool = obj
					break
				end
			end
			ToolText.Text = tool and tool.Name or "None"
			ToolText.Position = Vector2.new(pos.X, pos.Y + height * 0.5 + 14)
			ToolText.Outline = Config.ToolOutline
			ToolText.OutlineColor = Config.ToolOutlineColor
			ToolText.Color = Config.ToolColor
			ToolText.Font = 2
			ToolText.Size = 13
		else
			ToolText.Visible = false
		end
	end

	local conn = RunService.RenderStepped:Connect(Update)
	Player.AncestryChanged:Connect(function(_, parent)
		if not parent then
			RemoveDrawings({Box, BoxOutline, Name, HealthBar, HealthBarOutline, StudsText, ToolText, conn})
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		CreateEsp(player)
		player.CharacterAdded:Connect(function() CreateEsp(player) end)
	end
end

Players.PlayerAdded:Connect(function(player)
	if player ~= LocalPlayer then
		CreateEsp(player)
		player.CharacterAdded:Connect(function() CreateEsp(player) end)
	end
end)

return Config
