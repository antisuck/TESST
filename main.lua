--==============================================================
-- TESST
-- Main Loader
--==============================================================

local BASE =
    "https://raw.githubusercontent.com/antisuck/TESST/main/"

--==============================================================
-- RAYFIELD
--==============================================================

local Rayfield = loadstring(
    game:HttpGet(
        "https://sirius.menu/rayfield"
    )
)()

--==============================================================
-- WINDOW
--==============================================================

local Window = Rayfield:CreateWindow({

    Name = "TESST",

    LoadingTitle = "TESST",

    LoadingSubtitle = "Loading...",

    ConfigurationSaving = {
        Enabled = false
    },

    Discord = {
        Enabled = false
    },

    KeySystem = false

})

--==============================================================
-- TABS
--==============================================================

local CombatTab =
    Window:CreateTab("Combat")

local VisualsTab =
    Window:CreateTab("Visuals")

local MiscTab =
    Window:CreateTab("Misc")

local CursorTab =
    Window:CreateTab("Custom Cursor")

local SavedCursorTab =
    Window:CreateTab("Saved Cursors")

local ConfigTab =
    Window:CreateTab("Config")

--==============================================================
-- MODULE LOADER
--==============================================================

local function LoadModule(fileName)

    local success, module = pcall(function()

        local source = game:HttpGet(
            BASE .. fileName
        )

        local loader = loadstring(source)

        if not loader then
            error("loadstring failed")
        end

        return loader()

    end)

    if not success then

        warn(
            "[TESST] Failed to load " ..
            fileName .. ": " ..
            tostring(module)
        )

        Rayfield:Notify({

            Title = "Module Error",

            Content =
                fileName ..
                " не удалось загрузить.",

            Duration = 4

        })

        return nil

    end

    print(
        "[TESST] Loaded: " ..
        fileName
    )

    return module

end

--==============================================================
-- LOAD MODULES
--==============================================================

local ESP =
    LoadModule("ESP.lua")

local Combat =
    LoadModule("Combat.lua")

local Misc =
    LoadModule("Misc.lua")

local Cursor =
    LoadModule("Cursor.lua")

local Config =
    LoadModule("Config.lua")

--==============================================================
-- SETTINGS
--==============================================================

local Settings = {

    ESP = {

        Enabled = false,

        Box = false,

        Name = true,

        Tracers = false,

        Color = {
            r = 1,
            g = 0,
            b = 0
        }

    },

    Combat = {

        KillAura = false,

        KillAuraRange = 24,

        AttackDelay = 0.35,

        FOV = false,

        FOVSize = 80,

        FOVColor = {
            r = 1,
            g = 1,
            b = 1
        },

        NoFallDamage = false,

        NoDrownDamage = false

    },

    Misc = {

        Fly = false,

        FlySpeed = 50,

        JumpPower = 50

    },

    Cursor = {

        Enabled = true,

        Size = 32,

        ImageID = ""

    }

}

--==============================================================
-- APPLY CONFIG
--==============================================================

local function ApplySettings(data)

    if type(data) ~= "table" then
        return
    end

    for category, values in pairs(data) do

        if type(values) == "table"
            and type(Settings[category]) == "table" then

            for key, value in pairs(values) do

                Settings[category][key] =
                    value

            end

        end

    end

end

--==============================================================
-- INIT ESP
--==============================================================

if ESP and ESP.Init then

    local success, err =
        pcall(function()

            ESP:Init(
                VisualsTab
            )

        end)

    if not success then

        warn(
            "[TESST] ESP error:",
            err
        )

    end

end

--==============================================================
-- INIT COMBAT
--==============================================================

if Combat and Combat.Init then

    local success, err =
        pcall(function()

            Combat:Init(
                CombatTab
            )

        end)

    if not success then

        warn(
            "[TESST] Combat error:",
            err
        )

    end

end

--==============================================================
-- INIT MISC
--==============================================================

if Misc and Misc.Init then

    local success, err =
        pcall(function()

            Misc:Init(
                MiscTab
            )

        end)

    if not success then

        warn(
            "[TESST] Misc error:",
            err
        )

    end

end

--==============================================================
-- INIT CURSOR
--==============================================================

if Cursor and Cursor.Init then

    local success, err =
        pcall(function()

            Cursor:Init(

                CursorTab,

                SavedCursorTab,

                Rayfield

            )

        end)

    if not success then

        warn(
            "[TESST] Cursor error:",
            err
        )

    end

end

--==============================================================
-- INIT CONFIG
--==============================================================

if Config and Config.Init then

    local success, err =
        pcall(function()

            Config:Init(

                ConfigTab,

                Settings,

                ApplySettings,

                Rayfield

            )

        end)

    if not success then

        warn(
            "[TESST] Config error:",
            err
        )

    end

end

--==============================================================
-- INFO
--==============================================================

ConfigTab:CreateParagraph({

    Title = "TESST",

    Content =
        "Модули загружены из GitHub.\n\n" ..
        "Configs сохраняются локально в JSON."

})

--==============================================================
-- READY
--==============================================================

Rayfield:Notify({

    Title = "TESST",

    Content = "Меню успешно загружено.",

    Duration = 3

})

print(
    "[TESST] Loaded successfully."
)
