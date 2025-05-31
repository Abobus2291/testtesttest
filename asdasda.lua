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
    FilledBoxColor = Color3.fromRGB(50, 50, 50),
	FilledBoxTransparency = 0.5,
    HealthBar = false,
    HealthBarColor = nil,
    HealthBarColorHigh = Color3.new(0, 1, 0),
    HealthBarColorLow = Color3.new(1, 0, 0),
    HealthText = false,
    HealthTextColor = Color3.new(1, 1, 1),
    Names = false,
    NamesOutline = true,
    NamesColor = Color3.fromRGB(255, 255, 255),
    NamesOutlineColor = Color3.fromRGB(0, 0, 0),
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
    TracersFrom = "",
    Chams = false,
    ChamsColor = Color3.fromRGB(255, 0, 0),
    ChamsTransparency = 0.5,
    Skeleton = false,
    SkeletonColor = Color3.fromRGB(0, 255, 0),
    VisibleOnly = true,
    LimitDistance = 300
}

-- // Functions
local function newText()
    local t = Drawing.new("Text")
    t.Center = true
    t.Outline = false
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

local SkeletonJointsR15 = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"}
}

local SkeletonJointsR6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Left Arm", "Left Forearm"},
    {"Left Forearm", "Left Hand"},
    {"Torso", "Right Arm"},
    {"Right Arm", "Right Forearm"},
    {"Right Forearm", "Right Hand"},
    {"Torso", "Left Leg"},
    {"Left Leg", "Left Foot"},
    {"Torso", "Right Leg"},
    {"Right Leg", "Right Foot"}
}

local function CreateSkeleton(player)
    local esp = EspCache[player]
    if not esp or esp.SkeletonLines then
        return
    end

    esp.SkeletonLines = {}

    local char = player.Character
    if not char then
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local joints = {}
    if hum and hum.RigType == Enum.HumanoidRigType.R15 then
        joints = SkeletonJointsR15
    else
        joints = SkeletonJointsR6
    end

    for _, joint in pairs(joints) do
        local line = newLine()
        table.insert(esp.SkeletonLines, {Line = line, Parts = joint})
    end
end

local function UpdateSkeleton(player, pos, scale, width, height)
    local esp = EspCache[player]
    if not esp or not esp.SkeletonLines then
        return
    end

    local char = player.Character
    if not char then
        return
    end

    local visibleLines = false

    for _, tbl in pairs(esp.SkeletonLines) do
        local p0 = char:FindFirstChild(tbl.Parts[1])
        local p1 = char:FindFirstChild(tbl.Parts[2])
        if p0 and p1 then
            local p0pos, p0vis = Camera:WorldToViewportPoint(p0.Position)
            local p1pos, p1vis = Camera:WorldToViewportPoint(p1.Position)

            if p0vis and p1vis then
                tbl.Line.Visible = true
                tbl.Line.From = Vector2.new(p0pos.X, p0pos.Y)
                tbl.Line.To = Vector2.new(p1pos.X, p1pos.Y)
                tbl.Line.Color = Config.SkeletonColor
                visibleLines = true
            else
                tbl.Line.Visible = false
            end
        else
            tbl.Line.Visible = false
        end
    end

    if not visibleLines then
        RemoveSkeleton(player)
    end
end

local function RemoveSkeleton(player)
    local esp = EspCache[player]
    if esp and esp.SkeletonLines then
        for _, tbl in pairs(esp.SkeletonLines) do
            if type(tbl) == "table" and tbl.Line and tbl.Line.Remove then
                pcall(
                    function()
                        tbl.Line:Remove()
                    end
                )
            end
        end
        esp.SkeletonLines = nil
    end
end

local function CreateESP(player)
    if EspCache[player] then
        return
    end

    EspCache[player] = {
        Box = newBox(1, 2),
		FilledBox = newBox(1, 2),
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
    if Config.Skeleton then
        CreateSkeleton(player)
    end
end

local function UpdateESP(player)
    local esp = EspCache[player]
    if not esp then return end
    if not Config.EnabledESP then
        for _, v in pairs(esp) do
            if typeof(v) == "Instance" and v:IsA("Highlight") then
                v.Enabled = false
            elseif typeof(v) == "userdata" then
                v.Visible = false
            else
                v.Visible = false
            end
        end
        RemoveSkeleton(player)
        return
    end

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local head = char and char:FindFirstChild("Head")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not (hrp and head and hum and hum.Health > 0) then
        for _, v in pairs(esp) do
            if typeof(v) == "Instance" and v:IsA("Highlight") then
                v.Enabled = false
            elseif typeof(v) == "userdata" then
                v.Visible = false
            else
                v.Visible = false
            end
        end
        RemoveSkeleton(player)
        return
    end

    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    if Config.LimitDistance and dist > Config.LimitDistance then
        for _, v in pairs(esp) do
            if typeof(v) == "Instance" and v:IsA("Highlight") then
                v.Enabled = false
            elseif typeof(v) == "userdata" then
                v.Visible = false
            else
                v.Visible = false
            end
        end
        RemoveSkeleton(player)
        return
    end

    local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
    if Config.VisibleOnly and not visible then
        for _, v in pairs(esp) do
            if typeof(v) == "Instance" and v:IsA("Highlight") then
                v.Enabled = false
            elseif typeof(v) == "userdata" then
                v.Visible = false
            else
                v.Visible = false
            end
        end
        RemoveSkeleton(player)
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
    esp.Box.Filled = false
    esp.Box.Transparency = 1

    -- FilledBox
    esp.FilledBox.Visible = Config.FilledBox
    esp.FilledBox.Position = topLeft
    esp.FilledBox.Size = Vector2.new(width, height)
    esp.FilledBox.Color = Config.FilledBoxColor
    esp.FilledBox.Filled = true
    esp.FilledBox.Transparency = Config.FilledBoxTransparency

    -- BoxOutline (обводка, если нужна)
    esp.BoxOutline.Visible = Config.BoxOutline
    esp.BoxOutline.Position = topLeft
    esp.BoxOutline.Size = Vector2.new(width, height)
    esp.BoxOutline.Color = Config.BoxOutlineColor

    -- Name
    esp.Name.Visible = Config.Names
    esp.Name.Text = player.Name
    esp.Name.Position = Vector2.new(pos.X, topLeft.Y - 18)
    esp.Name.Color = Config.NamesColor
    esp.Name.Outline = false
    esp.Name.Font = 2
    esp.Name.Size = 12

    -- Health
    if Config.HealthBar then
        local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local color = Config.HealthBarColorLow:Lerp(Config.HealthBarColorHigh, hpPercent)

        esp.Health.Visible = true
        esp.HealthOutline.Visible = true
        esp.Health.Color = color

        local barX = topLeft.X - 6
        local barY = topLeft.Y

        esp.HealthOutline.Position = Vector2.new(barX, barY)
        esp.HealthOutline.Size = Vector2.new(2, height)
        esp.Health.Position = Vector2.new(barX + 1, barY + height * (1 - hpPercent))
        esp.Health.Size = Vector2.new(1, height * hpPercent)

        esp.HealthText.Visible = Config.HealthText
        esp.HealthText.Text = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
        esp.HealthText.Position = Vector2.new(barX - 25, barY + height / 2 - 6)
        esp.HealthText.Color = Config.HealthTextColor
        esp.HealthText.Outline = false
        esp.HealthText.Size = 12
        esp.HealthText.Font = 2
    else
        esp.Health.Visible = false
        esp.HealthOutline.Visible = false
        esp.HealthText.Visible = false
    end

    -- Studs
    esp.Studs.Visible = Config.StudsText
    esp.Studs.Text = string.format("%d Studs", dist)
    esp.Studs.Position = Vector2.new(pos.X, pos.Y + height / 2 + 2)
    esp.Studs.Color = Config.StudsColor
    esp.Studs.Outline = false

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
    esp.Tool.Outline = false

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

    -- Skeleton
    if Config.Skeleton then
        if not esp.SkeletonLines then
            CreateSkeleton(player)
        end
        UpdateSkeleton(player, pos, scale, width, height)
    else
        RemoveSkeleton(player)
    end
end

-- // Main
local accumulator = 0
RunService.RenderStepped:Connect(
    function(dt)
        accumulator = accumulator + dt
        local frameTime = 1 / Config.ESPRefreshRate
        if accumulator < frameTime then
            return
        end
        accumulator = accumulator - frameTime

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
                UpdateESP(player)
            end
        end
    end
)

local function RemoveESP(player)
    local esp = EspCache[player]
    if esp then
        RemoveSkeleton(player)
        for k, v in pairs(esp) do
            if typeof(v) == "userdata" and v.Remove then
                pcall(
                    function()
                        v:Remove()
                    end
                )
            elseif typeof(v) == "Instance" then
                pcall(
                    function()
                        v:Destroy()
                    end
                )
            else
                pcall(
                    function()
                        v:Destroy()
                    end
                )
            end
        end
        EspCache[player] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveESP)

ESP = ESP or {}
function ESP.skibidi()
    for player, _ in pairs(EspCache) do
        RemoveESP(player)
    end
end

return Config
