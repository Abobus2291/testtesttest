-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local EspCache = {}

-- // Config
local Config = {
	EnabledESP = false,
    Box = false,
    BoxOutline = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    FilledBox = false,
    HealthBar = false,
    Names = false,
    NamesOutline = true,
    NamesColor = Color3.fromRGB(255, 255, 255),
    NamesOutlineColor = Color3.fromRGB(0, 0, 0),
    NamesFont = 2,
    NamesSize = 13,
    StudsText = false,
    StudsOutline = true,
    StudsColor = Color3.fromRGB(255, 255, 255),
    StudsOutlineColor = Color3.fromRGB(0, 0, 0),
    ToolText = false,
    ToolOutline = true,
    ToolColor = Color3.fromRGB(255, 255, 255),
    ToolOutlineColor = Color3.fromRGB(0, 0, 0),
    Tracers = false,
    TracersColor = Color3.fromRGB(255, 255, 255),
    TracersFrom = "Mouse",
    Chams = false,
    ChamsColor = Color3.fromRGB(255, 0, 0),
    ChamsTransparency = 0.5
}

-- // Drawing helpers
local function newText()
    local t = Drawing.new("Text")
    t.Center = true
    t.Outline = true
    t.Font = 2
    t.Size = 13
    t.Visible = false
    return t
end

local function newBox(thickness, zindex, filled)
    local b = Drawing.new("Square")
    b.Thickness = thickness or 1
    b.ZIndex = zindex or 1
    b.Filled = filled or false
    b.Visible = false
    return b
end

local function newLine()
    local l = Drawing.new("Line")
    l.Thickness = 1
    l.Visible = false
    return l
end

--[[local function RemoveDrawings(tbl)
    for _, v in pairs(tbl) do
        if typeof(v) == "userdata" and v.Remove then
            pcall(function() v:Remove() end)
        elseif typeof(v) == "Instance" then
            pcall(function() v:Destroy() end)
        elseif typeof(v) == "table" then
            RemoveDrawings(v)
        end
    end
end]]

-- // ESP creation
local function CreateESP(player)
    if EspCache[player] then return end

    EspCache[player] = {
        Box = newBox(1, 2),
        BoxOutline = newBox(3, 1),
        Name = newText(),
        Studs = newText(),
        Tool = newText(),
        Health = newBox(1, 2, true),
        HealthOutline = newBox(1, 1, true),
        Tracer = newLine(),
        HealthText = newText(),
        Chams = (function()
            local cham = Instance.new("Highlight")
            cham.FillTransparency = Config.ChamsTransparency
            cham.OutlineTransparency = 1
            cham.Parent = CoreGui
            return cham
        end)()
    }
end

-- // ESP update
local function UpdateESP(player)
    local esp = EspCache[player]
    if not esp then return end
	if not Config.EnabledESP then return end

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local head = char and char:FindFirstChild("Head")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not (hrp and head and hum and hum.Health > 0) then
        for k, v in pairs(esp) do
            if typeof(v) == "Instance" and v:IsA("Highlight") then
                v.Enabled = false
            elseif typeof(v) == "userdata" then
                v.Visible = false
			else
				v.Visible = false
            end
        end
        return
    end

    local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
    if not visible then
        for k, v in pairs(esp) do
            if typeof(v) == "Instance" and v:IsA("Highlight") then
                v.Enabled = false
            elseif typeof(v) == "userdata" then
                v.Visible = false
			else
				v.Visible = false
            end
        end
        return
    end

    local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
    local width, height = math.floor(40 * scale), math.floor(60 * scale)
    local topLeft = Vector2.new(pos.X - width / 2, pos.Y - height / 2)

    -- Box
    esp.Box.Visible = Config.Box
    esp.Box.Position = topLeft
    esp.Box.Size = Vector2.new(width, height)
    esp.Box.Color = Config.BoxColor
    esp.Box.Filled = Config.FilledBox

    esp.BoxOutline.Visible = Config.BoxOutline
    esp.BoxOutline.Position = topLeft
    esp.BoxOutline.Size = Vector2.new(width, height)
    esp.BoxOutline.Color = Config.BoxOutlineColor

    -- Name
    esp.Name.Visible = Config.Names
    esp.Name.Text = player.Name
    esp.Name.Position = Vector2.new(pos.X, topLeft.Y - 18)
    esp.Name.Color = Config.NamesColor
    esp.Name.Outline = Config.NamesOutline
    esp.Name.OutlineColor = Config.NamesOutlineColor
    esp.Name.Font = Config.NamesFont
    esp.Name.Size = Config.NamesSize

    -- Health
    if Config.HealthBar then
        local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), hpPercent)

        esp.Health.Visible = true
        esp.HealthOutline.Visible = true
        esp.Health.Color = color

        local barX = topLeft.X - 6
        local barY = topLeft.Y

        esp.HealthOutline.Position = Vector2.new(barX, barY)
        esp.HealthOutline.Size = Vector2.new(2, height)
        esp.Health.Position = Vector2.new(barX + 1, barY + height * (1 - hpPercent))
        esp.Health.Size = Vector2.new(1, height * hpPercent)

        esp.HealthText.Visible = true
        esp.HealthText.Text = string.format("%d/%d", hum.Health, hum.MaxHealth)
        esp.HealthText.Position = Vector2.new(barX - 25, barY + height / 2 - 6)
        esp.HealthText.Color = Color3.new(1, 1, 1)
        esp.HealthText.Outline = true
        esp.HealthText.Size = 12
        esp.HealthText.Font = 2
    else
        esp.Health.Visible = false
        esp.HealthOutline.Visible = false
        esp.HealthText.Visible = false
    end

    -- Studs
    esp.Studs.Visible = Config.StudsText
    esp.Studs.Text = string.format("%d Studs", (Camera.CFrame.Position - hrp.Position).Magnitude)
    esp.Studs.Position = Vector2.new(pos.X, pos.Y + height / 2 + 2)
    esp.Studs.Color = Config.StudsColor
    esp.Studs.Outline = Config.StudsOutline
    esp.Studs.OutlineColor = Config.StudsOutlineColor

    -- Tool
    local held = nil
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then
            held = obj.Name
            break
        end
    end
    esp.Tool.Visible = Config.ToolText
    esp.Tool.Text = held or "None"
    esp.Tool.Position = Vector2.new(pos.X, pos.Y + height / 2 + 14)
    esp.Tool.Color = Config.ToolColor
    esp.Tool.Outline = Config.ToolOutline
    esp.Tool.OutlineColor = Config.ToolOutlineColor

    -- Tracer
    local fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    if Config.TracersFrom == "Center" then
        fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    elseif Config.TracersFrom == "Mouse" then
        fromPos = UserInputService:GetMouseLocation()
    end
    esp.Tracer.Visible = Config.Tracers
    esp.Tracer.From = fromPos
    esp.Tracer.To = Vector2.new(pos.X, pos.Y)
    esp.Tracer.Color = Config.TracersColor

    -- Chams
    esp.Chams.Enabled = Config.Chams
    esp.Chams.Adornee = char
    esp.Chams.FillColor = Config.ChamsColor
end

-- // Main
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
            UpdateESP(player)
        end
    end
end)

local function RemoveESP(player)
    local esp = EspCache[player]
    if esp then
        for k, v in pairs(esp) do
            if typeof(v) == "userdata" and v.Remove then
                pcall(function() v:Remove() end)
            elseif typeof(v) == "Instance" then
                pcall(function() v:Destroy() end)
			else
				pcall(function() v:Destroy() end)
            end
        end
        EspCache[player] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveESP)

return Config
