local function GetService(serviceName)
    if cloneref ~= nil then
        return cloneref(game:GetService(serviceName))
    else
        return game:GetService(serviceName)
    end
end

-- Variables / Tables / Caches
local PlayersCache = {}
local AllieCache = {}

local Tracers = {}

local EnableTracersEnabled = false
local EnableBoxesEnabled = false
VersionTwoTracerEnabled = true

local EnableEspEnabled = false
local AliveCheckEnabled = true
local TeamCheckEnabled = false -- No clue why you would use this, I guess if you are marine?
local AllieCheckEnabled = false

local DisplayNamesEnabled = true
local DisplayDistanceEnabled = true
local OffsetSliderValue = 20

local TracersThicknessValue = 2
local TracersTransparencyValue = 1
local TracersColorColor = Color3.fromRGB(20, 200, 20)
local BoxesThicknessValue = 2
local BoxesTransparencyValue = 1
local BoxesColorColor = Color3.fromRGB(20, 200, 20)



local ShouldIDrawOffScreenEnabled = true
local DrawToAlliesEnabled = false



-- Services
local Players = GetService("Players")
local RunService = GetService("RunService");
local Workspace = GetService("Workspace");
local CoreGui = GetService("CoreGui")

local Camera; Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() Camera = Workspace.CurrentCamera end); Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

-- Paths?
local AlliesFrame = (function(p) local ok,f=pcall(function() return p and p:FindFirstChild("Main") and p.Main:FindFirstChild("Allies") and p.Main.Allies:FindFirstChild("Container") and p.Main.Allies.Container:FindFirstChild("Allies") and p.Main.Allies.Container.Allies:FindFirstChild("ScrollingFrame") and p.Main.Allies.Container.Allies.ScrollingFrame:FindFirstChild("Frame") end) return ok and f or nil end)(LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"))


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

local function WorldToScreen(player)
    if not player then return nil end
    local Character = player.Character; if not Character then return nil end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart"); if not HumanoidRootPart then return nil end

    local Pos, OnScreen = Camera:WorldToViewportPoint(HumanoidRootPart.Position); if not OnScreen and not ShouldIDrawOffScreenEnabled then return nil end

    -- Clamp to screen edges if off-screen drawing is enabled
    local X = math.clamp(Pos.X, 0, Camera.ViewportSize.X)
    local Y = math.clamp(Pos.Y, 0, Camera.ViewportSize.Y)

    return Vector2.new(X, Y)
end



-- == Tracers functions == --
local function CreateTracer(player)
    local Line = Drawing.new("Line")
    Tracers[player] = Line
    Line.Color = TracersColorColor
    Line.Thickness = TracersThicknessValue
    Line.Transparency = TracersTransparencyValue
    Line.Visible = false
end

local function RemoveTracer(player)
    if Tracers[player] then
        Tracers[player]:Remove()
        Tracers[player] = nil
    end
end

local function UpdateTracer(player)
    local Line  = Tracers[player]; if not Line then return nil end
    local PlayerCharacter =  player.Character; if not PlayerCharacter then return nil end
    local PlayerHrp = PlayerCharacter:FindFirstChild("HumanoidRootPart"); if not PlayerHrp then return nil end
  

    Line.Thickness = TracersThicknessValue
    Line.Transparency = TracersTransparencyValue
    Line.Color = TracersColorColor

    if VersionTwoTracerEnabled then
        local MyCharacter = LocalPlayer.Character
        local MyHrp = MyCharacter and MyCharacter:FindFirstChild("HumanoidRootPart"); if not MyHrp then return end

        local pos, onScreen = Camera:WorldToViewportPoint(MyHrp.Position)
        local From = Vector2.new( math.clamp(pos.X, 0, Camera.ViewportSize.X), math.clamp(pos.Y, 0, Camera.ViewportSize.Y))
        local To = WorldToScreen(player)
    else
        local From = Vector2.new( Camera.ViewportSize.X / 2, Camera.ViewportSize.Y )
        local To = WorldToScreen(player)
    end


    if not From or not To then Line.Visible = false return nil end
    Line.From = From; Line.To = To; Line.Visible = true
end

local function HideTracer(player)
    local line = Tracers[player]
    if line then
        line.Visible = false
    end
end

-- == Usefull Functions == --
local function OnPlayerJoin(player)
    PlayersCache[player] = true
    CreateTracer(player)
end

local function OnPlayerLeave(player)
    PlayersCache[player] = nil
    RemoveTracer(player)
end

for _, p in ipairs(Players:GetPlayers()) do OnPlayerJoin(p) end

Players.PlayerAdded:Connect(OnPlayerJoin)
Players.PlayerRemoving:Connect(OnPlayerLeave)

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

    Background = "rbxassetid://135508568238221",

    User = {
        Enabled = true,
        Anonymous = false
    },
})
ProtectGui(Window)
Window:Tag({ Title = "v1.0.0", Icon = "github", Color = Color3.fromRGB(33, 35, 37), Radius = 10, })


-- Esp Tab
local EspTab = Window:Tab({
    Title = "Esp Settings",
    Icon = "settings", -- todo: Change to settings icon
})

local EnableTracers = EspTab:Toggle({
    Title = "Enable tracers",
    Desc = "Enables tracers to players.",
    Icon = "line-chart",
    Type = "Checkbox",
    Value = false,
    Callback = function(state) 
        EnableTracersEnabled = state
    end
})

local EnableBoxes = EspTab:Toggle({
    Title = "Enable boxes",
    Desc = "Enables boxes around players.",
    Icon = "square",
    Type = "Checkbox",
    Value = false,
    Callback = function(state) 
        EnableBoxesEnabled = state
    end
})

EspTab:Divider()
EspTab:Space()

local EnableEsp = EspTab:Toggle({
    Title = "Toggle esp",
    Desc = "Enables all of the coming features.",
    Icon = "check",
    Type = "Checkbox",
    Value = false,
    Callback = function(state) 
        EnableEspEnabled = state
    end
})

local VersionTwoTracer  = EspTab:Toggle({
    Title = "Enable version 2 of tracers",
    Icon = "arrows-expand",
    Type = "Checkbox",
    Value = true,
    Callback = function(state) 
        VersionTwoTracerEnabled = state
    end
})

local AliveCheck = EspTab:Toggle({
    Title = "Alive check",
    Desc = "Only shows esp for alive players.",
    Icon = "heart-pulse",
    Type = "Checkbox",
    Value = true,
    Callback = function(state) 
        AliveCheckEnabled = state
    end
})

local TeamCheck = EspTab:Toggle({
    Title = "Team check",
    Desc = "Only shows esp for enemies.",
    Icon = "users",
    Type = "Checkbox",
    Value = false,
    Callback = function(state) 
        TeamCheckEnabled = state
    end
})

local AllieCheck = EspTab:Toggle({
    Title = "Team check",
    Desc = "Only shows esp for enemies.",
    Icon = "users",
    Type = "Checkbox",
    Value = false,
    Callback = function(state) 
        AllieCheckEnabled = state
    end
})


EspTab:Divider()
EspTab:Space()

local DisplayNames = EspTab:Toggle({
    Title = "Display names",
    Desc = "Displays the names of the players.",
    Icon = "id-badge",
    Type = "Checkbox",
    Value = true,
    Callback = function(state) 
        DisplayNamesEnabled = state
    end
})

local DisplayDistance = EspTab:Toggle({
    Title = "Display distance",
    Desc = "Displays the distance to the players.",
    Icon = "arrows-expand",
    Type = "Checkbox",
    Value = false,
    Callback = function(state) 
        DisplayDistanceEnabled = state
    end
})

local OffsetSlider = EspTab:Slider({
    Title = "Offset",
    Desc = "Offset for above",
    Step = 1,
    Value = { Min = -30, Max = 30, Default = 20, },
    Callback = function(value)
        OffsetSliderValue = value
    end
})

EspTab:Divider()
EspTab:Space()

local TracersTransparency = EspTab:Slider({
    Title = "Tracers transparency",
    Desc = "Changes the transparency of the tracers.",
    Step = 0.1,
    Value = { Min = 0, Max = 1, Default = 0, },
    Callback = function(value)
        TracersTransparencyValue = value
    end
})

local TracersThickness = EspTab:Slider({
    Title = "Tracers thickness",
    Desc = "Changes the thickness of the tracers.",
    Step = 1,
    Value = { Min = 1, Max = 5, Default = 2, },
    Callback = function(value)
        TracersThicknessValue = value
    end
})
local TracersColor = EspTab:Colorpicker({
    Title = "Colorpicker",
    Desc = "Colorpicker Description",
    Default = Color3.fromRGB(20, 220, 20),
    Transparency = 0,
    Locked = false,
    Callback = function(color) 
        TracersColorColor = color
    end
})

local BoxesThicknes = EspTab:Slider({
    Title = "Boxes thickness",
    Desc = "Changes the thickness of the boxes.",
    Step = 1,
    Value = { Min = 1, Max = 5, Default = 2, },
    Callback = function(value)
        BoxesThicknessValue = value
    end
})

local BoxesTransparency = EspTab:Slider({
    Title = "Boxes transparency",
    Desc = "Changes the transparency of the boxes.",
    Step = 0.1,
    Value = { Min = 0, Max = 1, Default = 0, },
    Callback = function(value)
        BoxesTransparencyValue = value
    end
})

local BoxesColor = EspTab:Colorpicker({
    Title = "Colorpicker",
    Desc = "Colorpicker Description",
    Default = Color3.fromRGB(20, 220, 20),
    Transparency = 0,
    Locked = false,
    Callback = function(color) 
        BoxesColorColor = color
    end
})


RunService.RenderStepped:Connect(function()
    if not EnableEspEnabled then
        for player, _ in pairs(Tracers) do
            HideTracer(player)
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local shouldDraw = true

        if player == LocalPlayer then
            shouldDraw = false
        end

        local char = shouldDraw and player.Character
        local humanoid = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not (char and humanoid and hrp) then
            shouldDraw = false
        end

        if shouldDraw and AliveCheckEnabled and humanoid.Health <= 0 then
            shouldDraw = false
        end

        if shouldDraw and TeamCheckEnabled and player.Team == LocalPlayer.Team then
            shouldDraw = false
        end

        if shouldDraw and AllieCheckEnabled and AllieCache[player] then
            shouldDraw = false
        end

        if shouldDraw and EnableTracersEnabled then
            if not Tracers[player] then
                CreateTracer(player)
            end
            UpdateTracer(player)
        else
            HideTracer(player)
        end
    end
end)
