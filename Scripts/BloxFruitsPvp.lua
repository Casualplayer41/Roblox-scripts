-- == Loadstrings == --
local WindUi = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUi:CreateWindow({
    Title = "Blox fruits pvp helper",
    Icon = "door-open",
    Author = "by kitty",
    Folder = "CosScripts",
    
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = true,

    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("Hi, your user is ".. print(game:GetService("Players").LocalPlayer.DisplayName))
        end,
    },
    
    KeySystem = { 
        Key = { "1234", "5678" },
        Note = "Join the discord",
        
        Thumbnail = {
            Image = "rbxassetid://42010954",
            Title = "Hi I guess",
        },
        
        URL = "https://discord.gg/gmCQERq2ej",
        SaveKey = false,
    },
})
