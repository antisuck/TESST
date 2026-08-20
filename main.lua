--==============================================================
-- TESST
-- main.lua
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

    LoadingSubtitle = "Loading modules...",

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

local LoadedModules = {}


local function LoadModule(fileName)

    local success, result =
        pcall(function()

            local source =
                game:HttpGet(
                    BASE .. fileName
                )


            local func =
                loadstring(source)


            if not func then

                error(
                    "loadstring failed"
                )

            end


            return func()

        end)


    if not success then

        warn(
            "[TESST] Failed to load " ..
            fileName
        )

        warn(result)


        Rayfield:Notify({

            Title =
                "Module Error",

            Content =
                fileName ..
                " не загрузился.",

            Duration =
                4

        })


        return nil

    end


    print(
        "[TESST] Loaded: " ..
        fileName
    )


    LoadedModules[fileName] =
        result


    return result

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
-- INIT ESP
--==============================================================

if ESP
    and type(ESP.Init) == "function" then

    local success, errorMessage =
        pcall(function()

            ESP:Init(
                VisualsTab
            )

        end)


    if not success then

        warn(
            "[TESST] ESP Init Error:",
            errorMessage
        )

    end

end


--==============================================================
-- INIT COMBAT
--==============================================================

if Combat
    and type(Combat.Init) == "function" then

    local success, errorMessage =
        pcall(function()

            Combat:Init(
                CombatTab
            )

        end)


    if not success then

        warn(
            "[TESST] Combat Init Error:",
            errorMessage
        )

    end

end


--==============================================================
-- INIT MISC
--==============================================================

if Misc
    and type(Misc.Init) == "function" then

    local success, errorMessage =
        pcall(function()

            Misc:Init(
                MiscTab
            )

        end)


    if not success then

        warn(
            "[TESST] Misc Init Error:",
            errorMessage

        )

    end

end


--==============================================================
-- INIT CURSOR
--==============================================================

if Cursor
    and type(Cursor.Init) == "function" then

    local success, errorMessage =
        pcall(function()

            Cursor:Init(

                CursorTab,

                SavedCursorTab,

                Rayfield

            )

        end)


    if not success then

        warn(
            "[TESST] Cursor Init Error:",
            errorMessage
        )

    end

end


--==============================================================
-- SETTINGS
--==============================================================

local Settings = {

    ESP = {

        BoxEnabled = false,

        NameEnabled = true,

        TracersEnabled = false,

        Color = {
            r = 1,
            g = 0.27,
            b = 0.27
        }

    },


    Combat = {

        KillAuraEnabled = false,

        KillAuraRange = 24,

        AttackDelay = 0.35,

        FOVEnabled = false,

        FOVSize = 80,

        FOVColor = {
            r = 1,
            g = 1,
            b = 1
        },

        NoFallDamage = false

    },


    Misc = {

        FlyEnabled = false,

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
-- APPLY SETTINGS
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


    --==========================================================
    -- APPLY ESP
    --==========================================================

    if ESP
        and type(ESP.SetSettings) == "function" then

        pcall(function()

            ESP:SetSettings(
                Settings.ESP
            )

        end)

    end


    --==========================================================
    -- APPLY COMBAT
    --==========================================================

    if Combat
        and type(Combat.SetSettings) == "function" then

        pcall(function()

            Combat:SetSettings(
                Settings.Combat
            )

        end)

    end


    --==========================================================
    -- APPLY MISC
    --==========================================================

    if Misc
        and type(Misc.SetSettings) == "function" then

        pcall(function()

            Misc:SetSettings(
                Settings.Misc
            )

        end)

    end


    --==========================================================
    -- APPLY CURSOR
    --==========================================================

    if Cursor
        and type(Cursor.SetSettings) == "function" then

        pcall(function()

            Cursor:SetSettings(
                Settings.Cursor
            )

        end)

    end

end


--==============================================================
-- INIT CONFIG
--==============================================================

if Config
    and type(Config.Init) == "function" then

    local success, errorMessage =
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
            "[TESST] Config Init Error:",
            errorMessage
        )

    end

end


--==============================================================
-- CONFIG INFO
--==============================================================

ConfigTab:CreateParagraph({

    Title =
        "TESST Config",

    Content =
        "Настройки сохраняются локально.\n\n" ..
        "ESP, Combat, Misc и Cursor используют " ..
        "отдельные модули."

})


--==============================================================
-- STATUS
--==============================================================

local loadedCount = 0


for _, module in pairs(
    LoadedModules
) do

    if module then
        loadedCount += 1
    end

end


--==============================================================
-- NOTIFICATION
--==============================================================

Rayfield:Notify({

    Title =
        "TESST",

    Content =
        "Загружено модулей: "
        .. tostring(loadedCount)
        .. "/5",

    Duration =
        4

})


print(
    "========================================"
)

print(
    "[TESST] Main loaded"
)

print(
    "[TESST] Modules loaded: "
    .. tostring(loadedCount)
    .. "/5"
)

print(
    "========================================"
)