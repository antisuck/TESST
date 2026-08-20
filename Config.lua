--==============================================================
-- Config.lua
-- Universal Configuration Manager
--
-- Features:
--   • Multiple configs
--   • Save
--   • Load
--   • Delete
--   • Refresh
--   • JSON storage
--   • Shared settings table
--==============================================================

local HttpService = game:GetService("HttpService")

local Module = {}

--==============================================================
-- FILE SETTINGS
--==============================================================

local FOLDER_NAME = "MyMenu"

local CONFIG_FOLDER =
    FOLDER_NAME .. "/Configs"

local INDEX_FILE =
    FOLDER_NAME .. "/configs.json"


--==============================================================
-- SETTINGS
--==============================================================

local CurrentConfig = "Default"

local Configs = {}

local ConfigDropdown = nil


--==============================================================
-- FILE SYSTEM
--==============================================================

local function hasFileSystem()

    return type(isfile) == "function"
        and type(readfile) == "function"
        and type(writefile) == "function"
        and type(isfolder) == "function"
        and type(makefolder) == "function"

end


--==============================================================
-- CREATE FOLDERS
--==============================================================

local function ensureFolders()

    if not hasFileSystem() then
        return false
    end


    local success =
        pcall(function()

            if not isfolder(FOLDER_NAME) then

                makefolder(
                    FOLDER_NAME
                )

            end


            if not isfolder(CONFIG_FOLDER) then

                makefolder(
                    CONFIG_FOLDER
                )

            end

        end)


    return success

end


--==============================================================
-- SAFE CONFIG NAME
--==============================================================

local function sanitizeName(name)

    name =
        tostring(name or "")


    name =
        name:gsub(
            "[\\/:*%?\"<>|]",
            "_"
        )


    name =
        name:gsub(
            "^%s+",
            ""
        )


    name =
        name:gsub(
            "%s+$",
            ""
        )


    return name

end


--==============================================================
-- CONFIG PATH
--==============================================================

local function getConfigPath(name)

    return CONFIG_FOLDER ..
        "/" ..
        sanitizeName(name) ..
        ".json"

end


--==============================================================
-- SAVE INDEX
--==============================================================

local function saveIndex()

    if not ensureFolders() then
        return false
    end


    local success =
        pcall(function()

            writefile(

                INDEX_FILE,

                HttpService:JSONEncode(
                    Configs
                )

            )

        end)


    return success

end


--==============================================================
-- LOAD INDEX
--==============================================================

local function loadIndex()

    Configs = {}


    if not ensureFolders() then
        return
    end


    if not isfile(INDEX_FILE) then

        saveIndex()

        return

    end


    pcall(function()

        local content =
            readfile(
                INDEX_FILE
            )


        if content == "" then
            return
        end


        local data =
            HttpService:JSONDecode(
                content
            )


        if type(data) == "table" then

            Configs =
                data

        end

    end)

end


--==============================================================
-- GET CONFIG NAMES
--==============================================================

local function getConfigNames()

    local names = {}


    for name, value in pairs(
        Configs
    ) do

        if value then

            table.insert(
                names,
                name
            )

        end

    end


    table.sort(
        names
    )


    return names

end


--==============================================================
-- REFRESH DROPDOWN
--==============================================================

local function refreshDropdown()

    if not ConfigDropdown then
        return
    end


    ConfigDropdown:Refresh(
        getConfigNames()
    )

end


--==============================================================
-- SERIALIZE
--==============================================================

local function serialize(settings)

    local result = {}


    for key, value in pairs(
        settings
    ) do

        local valueType =
            typeof(value)


        if valueType == "Color3" then

            result[key] = {

                __type = "Color3",

                r = value.R,

                g = value.G,

                b = value.B

            }


        elseif valueType == "Vector3" then

            result[key] = {

                __type = "Vector3",

                x = value.X,

                y = value.Y,

                z = value.Z

            }


        elseif valueType == "UDim2" then

            result[key] = {

                __type = "UDim2",

                xs = value.X.Scale,

                xo = value.X.Offset,

                ys = value.Y.Scale,

                yo = value.Y.Offset

            }


        elseif type(value) == "table" then

            result[key] =
                serialize(value)


        elseif valueType == "boolean"
            or valueType == "number"
            or valueType == "string" then

            result[key] =
                value

        end

    end


    return result

end


--==============================================================
-- DESERIALIZE
--==============================================================

local function deserialize(data)

    if type(data) ~= "table" then
        return data
    end


    if data.__type == "Color3" then

        return Color3.new(
            data.r or 1,
            data.g or 1,
            data.b or 1
        )

    end


    if data.__type == "Vector3" then

        return Vector3.new(
            data.x or 0,
            data.y or 0,
            data.z or 0
        )

    end


    if data.__type == "UDim2" then

        return UDim2.new(

            data.xs or 0,
            data.xo or 0,

            data.ys or 0,
            data.yo or 0

        )

    end


    local result = {}


    for key, value in pairs(
        data
    ) do

        result[key] =
            deserialize(value)

    end


    return result

end


--==============================================================
-- SAVE CONFIG
--==============================================================

function Module:Save(
    name,
    settings,
    Rayfield
)

    name =
        sanitizeName(name)


    if name == "" then

        if Rayfield then

            Rayfield:Notify({

                Title =
                    "Config",

                Content =
                    "Введи название конфига.",

                Duration =
                    3

            })

        end

        return false

    end


    if not ensureFolders() then

        if Rayfield then

            Rayfield:Notify({

                Title =
                    "Config",

                Content =
                    "Filesystem недоступен.",

                Duration =
                    4

            })

        end

        return false

    end


    local success =
        pcall(function()

            local data =
                serialize(settings)


            writefile(

                getConfigPath(name),

                HttpService:JSONEncode(
                    data
                )

            )


            Configs[name] =
                true


            saveIndex()

        end)


    if success then

        CurrentConfig =
            name


        refreshDropdown()


        if Rayfield then

            Rayfield:Notify({

                Title =
                    "Config Saved",

                Content =
                    "Сохранён: " .. name,

                Duration =
                    3

            })

        end

    else

        if Rayfield then

            Rayfield:Notify({

                Title =
                    "Config",

                Content =
                    "Ошибка сохранения.",

                Duration =
                    4

            })

        end

    end


    return success

end


--==============================================================
-- LOAD CONFIG
--==============================================================

function Module:Load(
    name,
    settings,
    applySettings,
    Rayfield
)

    name =
        sanitizeName(name)


    if name == "" then
        return false
    end


    local path =
        getConfigPath(name)


    if not isfile(path) then

        if Rayfield then

            Rayfield:Notify({

                Title =
                    "Config",

                Content =
                    "Конфиг не найден.",

                Duration =
                    3

            })

        end

        return false

    end


    local success, data =
        pcall(function()

            local content =
                readfile(path)


            return HttpService:JSONDecode(
                content
            )

        end)


    if not success
        or type(data) ~= "table" then

        if Rayfield then

            Rayfield:Notify({

                Title =
                    "Config",

                Content =
                    "Не удалось прочитать конфиг.",

                Duration =
                    4

            })

        end

        return false

    end


    data =
        deserialize(data)


    if applySettings then

        local applied =
            pcall(
                applySettings,
                data
            )


        if not applied then

            if Rayfield then

                Rayfield:Notify({

                    Title =
                        "Config",

                    Content =
                        "Конфиг загружен, но некоторые настройки не применились.",

                    Duration =
                        4

                })

            end

        end

    end


    CurrentConfig =
        name


    if Rayfield then

        Rayfield:Notify({

            Title =
                "Config Loaded",

            Content =
                "Загружен: " .. name,

            Duration =
                3

        })

    end


    return true, data

end


--==============================================================
-- DELETE CONFIG
--==============================================================

function Module:Delete(
    name,
    Rayfield
)

    name =
        sanitizeName(name)


    if name == "" then
        return false
    end


    local path =
        getConfigPath(name)


    if not isfile(path) then

        return false

    end


    local success =
        pcall(function()

            delfile(path)

            Configs[name] =
                nil

            saveIndex()

        end)


    if success then

        if CurrentConfig == name then

            CurrentConfig =
                "Default"

        end


        refreshDropdown()


        if Rayfield then

            Rayfield:Notify({

                Title =
                    "Config Deleted",

                Content =
                    "Удалён: " .. name,

                Duration =
                    3

            })

        end

    end


    return success

end


--==============================================================
-- REFRESH
--==============================================================

function Module:Refresh()

    loadIndex()

    refreshDropdown()

end


--==============================================================
-- GET CURRENT
--==============================================================

function Module:GetCurrent()

    return CurrentConfig

end


--==============================================================
-- GET CONFIGS
--==============================================================

function Module:GetConfigs()

    return getConfigNames()

end


--==============================================================
-- INIT UI
--==============================================================

function Module:Init(
    ConfigTab,
    settings,
    applySettings,
    Rayfield
)

    loadIndex()


    local ConfigName =
        ""


    --==========================================================
    -- INFO
    --==========================================================

    ConfigTab:CreateParagraph({

        Title =
            "Configuration",

        Content =
            "Сохраняй настройки всего меню " ..
            "в отдельные JSON-конфиги.\n\n" ..
            "Настройки можно загружать между запусками."

    })


    --==========================================================
    -- NAME
    --==========================================================

    ConfigTab:CreateInput({

        Name =
            "Config Name",

        PlaceholderText =
            "Например: Legit",

        RemoveTextAfterFocusLost =
            false,

        Callback = function(Text)

            ConfigName =
                tostring(Text)

        end

    })


    --==========================================================
    -- SAVE
    --==========================================================

    ConfigTab:CreateButton({

        Name =
            "Save Config",

        Callback = function()

            Module:Save(

                ConfigName,

                settings,

                Rayfield

            )

        end

    })


    --==========================================================
    -- DROPDOWN
    --==========================================================

    ConfigDropdown =
        ConfigTab:CreateDropdown({

            Name =
                "Saved Configs",

            Options =
                getConfigNames(),

            CurrentOption =
                {},

            MultipleOptions =
                false,

            Callback = function(Options)

                if not Options then
                    return
                end


                local name =
                    Options[1]


                if name then

                    ConfigName =
                        name

                end

            end

        })


    --==========================================================
    -- LOAD
    --==========================================================

    ConfigTab:CreateButton({

        Name =
            "Load Selected",

        Callback = function()

            local name =
                ConfigName


            if name == "" then

                Rayfield:Notify({

                    Title =
                        "Config",

                    Content =
                        "Сначала выбери конфиг.",

                    Duration =
                        3

                })

                return

            end


            Module:Load(

                name,

                settings,

                applySettings,

                Rayfield

            )

        end

    })


    --==========================================================
    -- REFRESH
    --==========================================================

    ConfigTab:CreateButton({

        Name =
            "Refresh Configs",

        Callback = function()

            Module:Refresh()


            Rayfield:Notify({

                Title =
                    "Config",

                Content =
                    "Список конфигов обновлён.",

                Duration =
                    2

            })

        end

    })


    --==========================================================
    -- DELETE
    --==========================================================

    ConfigTab:CreateButton({

        Name =
            "Delete Selected",

        Callback = function()

            local name =
                ConfigName


            if name == "" then

                Rayfield:Notify({

                    Title =
                        "Config",

                    Content =
                        "Сначала выбери конфиг.",

                    Duration =
                        3

                })

                return

            end


            Module:Delete(

                name,

                Rayfield

            )

        end

    })


    --==========================================================
    -- FILE INFO
    --==========================================================

    ConfigTab:CreateParagraph({

        Title =
            "Storage",

        Content =
            "Папка: " ..
            CONFIG_FOLDER ..
            "\n\n" ..
            "Конфиги сохраняются в формате JSON."

    })

end


return Module
