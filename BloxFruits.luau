-- To finish

local function GetService(serviceName)
    if cloneref ~= nil then
        return cloneref(game:GetService(serviceName))
    else
        return game:GetService(serviceName)
    end
end

-- Variables / Tables / Caches
ShouldIDrawOffScreenEnabled = true
ShouldNotDrawToAlliesEnabled = true
DrawOnlyToSpecificPlayerEnabled = false

local SelectedPlayersForEsp = {}

local TracerEspEnabled = false
local BoxEspEnabled = false

local ChooseWhoToEsp

local ColarPickerForEspTracer = Color3.fromRGB(0, 255, 0)
local BoxesEspColor = Color3.fromRGB(255, 0, 0)

local Tracers = {}

local PlayerCache = {}
local AllyCache = {}

-- Services
local Players = GetService("Players")
local RunService = GetService("RunService");
local Workspace = GetService("Workspace");
local CoreGui = GetService("CoreGui")

local Camera; Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Camera = Workspace.CurrentCamera end); Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

-- Paths?
local AlliesFrame = PlayerGui:FindFirstChild("Main"):FindFirstChild("Allies"):FindFirstChild("Container"):FindFirstChild("Allies"):FindFirstChild("ScrollingFrame"):FindFirstChild("Frame")


-- Core Section: functions
local function Notify(title, content, duration, icon)
    WindUi:Notify({
        Title = title or "Notification Title",
        Content = content or "Notification Content example!",
        Duration = duration or 3,
        Icon = icon or "bird",
    })
end

local function ProtectGui(gui: Instance?)
    if not gui then return end

    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)

    else gui.Parent = CoreGui
    end
end

local function GetMe()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChild("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    return Character, Humanoid, HumanoidRootPart
end

local function RebuildAllyCache()
    table.clear(AllyCache)
    
    for _, obj in ipairs(AlliesFrame:GetChildren()) do
        if obj:IsA("ImageButton") then
            local player = Players:FindFirstChild(obj.Name)
            if player then
                AllyCache[player.UserId] = true
            end
        end
    end
end

local function OnPlayerJoin(player)
   PlayerCache[player.UserId] = { Player = player }
end

local function OnPlayerLeave(player)
    PlayerCache[player.UserId] = nil
end

-- Esp related functions
local function WorldToScreen(player)
    if not player then return nil end
    local character = player.Character
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if pos.Z < 0 then
        if ShouldIDrawOffScreenEnabled then
            pos = Vector2.new(
                math.clamp(pos.X, 0, Camera.ViewportSize.X),
                math.clamp(pos.Y, 0, Camera.ViewportSize.Y)
            )
        else
            return nil
        end
    elseif not onScreen and not ShouldIDrawOffScreenEnabled then
        return nil
    end

    return Vector2.new(pos.X, pos.Y)
end


-- == Tracers == --
local function CreateTracer(player)
    local line = Drawing.new("Line")
    line.Color = ColarPickerForEspTracer
    line.Thickness = 2
    line.Transparency = 1
    line.Visible = false
    Tracers[player] = line
end

local function UpdateTracer(player)
    local line = Tracers[player]
    if not line then return end

    local from = WorldToScreen(LocalPlayer)
    local to = WorldToScreen(player)

    if not from or not to then
        line.Visible = false
        return
    end

    line.From = from
    line.To = to
    line.Color = ColarPickerForEspTracer
    line.Visible = true
end

local function RemoveTracer(player)
    local line = Tracers[player]
    if line then
        line:Remove()
        Tracers[player] = nil
    end
end



-- Loadstrings
local WindUi = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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
local DrawOnlyToSpecificPlayer = EspTab:Toggle({
    Title = "Draw to specific player (below)",
    Icon = "bird",
    Type = "Checkbox",
    Value = true,
    Callback = function(state)
        DrawOnlyToSpecificPlayerEnabled = state
    end
})

local ShouldIDrawOffScreen = EspTab:Toggle({
    Title = "Should draw off-screen?",
    Icon = "bird",
    Type = "Checkbox",
    Value = true,
    Callback = function(state)
        ShouldIDrawOffScreenEnabled = state
    end
})

local ShouldNotDrawToAllies = EspTab:Toggle({
    Title = "Should only draw to non-allies?",
    Icon = "bird",
    Type = "Checkbox",
    Value = true,
    Callback = function(state)
        ShouldNotDrawToAlliesEnabled = state
    end
})

EspTab:Space()
-- == Tracers == --
local TracersEsp = EspTab:Toggle({
    Title = "Enable Tracers",
    Desc = "Will draw a line of the color you desire to every player",
    Icon = "bird",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        TracerEspEnabled = state
    end
})
local TracersColorPicker = EspTab:Colorpicker({
    Title = "Color picker for tracers",
    Default = Color3.fromRGB(0, 255, 0),
    Transparency = 0,
    Locked = false,
    Callback = function(color)
        ColarPickerForEspTracer = color
    end
})
EspTab:Space()

-- == Boxes == --
local BoxesEsp = EspTab:Toggle({
    Title = "Enable Boxes",
    Desc = "Will draw boxes to the desired players",
    Icon = "bird",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        BoxEspEnabled = state
    end
})
local BoxesColorPicker = EspTab:Colorpicker({
    Title = "Color picker for boxes",
    Default = Color3.fromRGB(20, 250, 20),
    Transparency = 0,
    Locked = false,
    Callback = function(color)
        BoxesEspColor = color
    end
})

RunService.RenderStepped:Connect(function()

    -- ===== TRACERS =====
    if TracerEspEnabled then
        if DrawOnlyToSpecificPlayerEnabled then
            for _, player in pairs(SelectedPlayersForEsp) do
                if not Tracers[player] then
                    CreateTracer(player)
                end
                UpdateTracer(player)
            end
        else
            for player in pairs(PlayerCache) do
                if not Tracers[player] then
                    CreateTracer(player)
                end

                if ShouldNotDrawToAlliesEnabled and AllyCache[player.UserId] then
                    Tracers[player].Visible = false
                else
                    UpdateTracer(player)
                end
            end
        end
    else
        for _, line in pairs(Tracers) do
            line.Visible = false
        end
    end
end)



-- Code
-- Esp logic
RunService.RenderStepped:Connect(function(()
    if TracerEspEnabled then
        if DrawOnlyToSpecificPlayerEnabled then
            if ShouldIDrawOffScreenEnabled then
                i, player in pairs(AllyCache) do
            end
        end
    end
end)









-- Initialize
-- == Tracers == -- 

for i, player in pairs(Players:GetPlayers()) do
    CreateTracer(player)
    line.Visible = false
end
