local function GetService(serviceName)
    if cloneref ~= nil then
        return cloneref(game:GetService(serviceName))
    else
        return game:GetService(serviceName)
    end
end

local Tracers = {}


-- Services
local Players = GetService("Players")
local Teams = GetService("Teams")
local HttpService = GetService("HttpService")

local RunService = GetService("RunService"); local UserInputService = GetService("UserInputService"); local TeleportService = GetService("TeleportService")
local Workspace = GetService("Workspace"); local ReplicatedStorage = GetService("ReplicatedStorage"); local CoreGui = GetService("CoreGui")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- functions
local function Notify(title, content, duration, icon)
    WindUi:Notify({
        Title = title or "Notification Title",
        Content = content or "Notification Content example!",
        Duration = duration or 3,
        Icon = icon or "bird",
    })
end

local function ProtectGui(gui)
    if not gui then return end

    gui.Parent = CoreGui

    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
    end
end

local function GetMe()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChild("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    return Character, Humanoid, HumanoidRootPart
end

local function WorldToScreen(player)
    if not player then return nil end

    local Character = player.Character
    if not Character then return nil end

    local Hrp = Character:FindFirstChild("HumanoidRootPart")
    if not Hrp then return nil end

    local pos, onScreen = Camera:WorldToViewportPoint(Hrp.Position)
    if not onScreen then return nil end

    return Vector2.new(pos.X, pos.Y)
end

local function CreateTracer(player)
    local line = Drawing.new("Line")
    line.Color = ColarPickerForEspTracer
    line.Thickness = 2
    line.Transparency = 1
    line.Visible = false
    Tracers[player] = line
end

local function UpdateTracers()
    local from = WorldToScreen(LocalPlayer)
    if not from then return end

    for player, line in pairs(Tracers) do
        local to = WorldToScreen(player)
        if to then
            line.From = from
            line.To = to
            line.Visible = true
            line.Color = ColarPickerForEspTracer
        else
            line.Visible = false
        end
    end
end

local function RemoveTracer(player)
    local line = Tracers[player]
    if line then
        line:Remove()
        Tracers[player] = nil
    end
end

local function OnPlayerAdded(player)
    if player == LocalPlayer then return end
    PlayerCache[player] = true
end

local function OnPlayerRemoving(player)
    PlayerCache[player] = nil
end 

-- Loadstrings
local WindUi = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()


-- // Core Section: WindUi
local Window = WindUi:CreateWindow({
    Title = "Blox fruits PVP cheat",
    NewElements = true,
    Icon = "door-open",
    Author = "by kitty",
    Folder = "cos",

    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,

    User = {
        Enabled = true,
        Anonymous = false
    },
})

ProtectGui(Window)


Window:Tag({ Title = "v1.0.0", Icon = "github", Color = Color3.fromRGB(33, 35, 37), Radius = 10, })



-- // Section WindUi: Esp tab
local EspTab = Window:Tab({
    Title = "Esp",
    Icon = "scan-eye",
    Locked = false,
})

-- Tracer Lines
local TracerEspEnabled = false
local TracersEsp = EspTab:Toggle({
    Title = "Enable Tracers",
    Desc = "Will draw a line of the color you desire to every player not in your team.",
    Icon = "bird",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        TracerEspEnabled = state
    end
})

local Colorpicker = EspTab:Colorpicker({
    Title = "Color picker for tracers",
    Default = Color3.fromRGB(0, 255, 0),
    Transparency = 0,
    Locked = false,
    Callback = function(color)
        ColarPickerForEspTracer = color
    end
})

EspTab:Space()

-- 2D Boxes
local BoxesEspEnabled = false
local BoxesEsp = EspTab:Toggle({
    Title = "Enable Boxes",
    Desc = "Draws 2D boxes around players who are not on your team.",
    Icon = "square",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        BoxesEspEnabled = state
    end
})

local BoxesEspColor = Color3.fromRGB(255, 0, 0)
local BoxesColorpicker = EspTab:Colorpicker({
    Title = "Color picker for boxes",
    Default = Color3.fromRGB(255, 0, 0),
    Transparency = 0,
    Locked = false,
    Callback = function(color)
        BoxesEspColor = color
    end
})

EspTab:Space()

-- Chams (through-wall highlights)
local ChamsEspEnabled = false
local ChamsEsp = EspTab:Toggle({
    Title = "Enable Chams",
    Desc = "Applies colored highlights to players through walls.",
    Icon = "layers",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        ChamsEspEnabled = state
    end
})

local ChamsEspColor = Color3.fromRGB(0, 0, 255)
local ChamsColorpicker = EspTab:Colorpicker({
    Title = "Color picker for chams",
    Default = Color3.fromRGB(0, 0, 255),
    Transparency = 0,
    Locked = false,
    Callback = function(color)
        ChamsEspColor = color
    end
})

EspTab:Space()

-- Health Display
local HealthEspEnabled = false
local HealthEsp = EspTab:Toggle({
    Title = "Enable Health Display",
    Desc = "Shows the current health of players above their character.",
    Icon = "heart",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        HealthEspEnabled = state
    end
})

local HealthEspColor = Color3.fromRGB(0, 255, 0)
local HealthColorpicker = EspTab:Colorpicker({
    Title = "Color picker for health",
    Default = Color3.fromRGB(0, 255, 0),
    Transparency = 0,
    Locked = false,
    Callback = function(color)
        HealthEspColor = color
    end
})






-- // Core Section: WindUi code
-- // Section WindUi: Misc tab



--// Section WindUi: Esp Tab

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateTracer(player)
    end
end


Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateTracer(player)
    end
end)

Players.PlayerRemoving:Connect(RemoveTracer)


RunService.RenderStepped:Connect(function()
    if TracerEspEnabled then
        UpdateTracers()
    else
        for _, line in pairs(Tracers) do
            line.Visible = false
        end
    end
end)
