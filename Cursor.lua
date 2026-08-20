--==============================================================
-- Cursor.lua
-- Custom Cursor Module
--
-- Features:
--   • Custom Roblox Asset ID
--   • Cursor Enable / Disable
--   • Cursor Size
--   • Save Cursor
--   • Load Cursor
--   • Delete Cursor
--   • Refresh Saved Cursors
--   • JSON File Storage
--   • cursors.dev info
--==============================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Module = {}

--==============================================================
-- SETTINGS
--==============================================================

local FILE_FOLDER = "CursorCustomizer"
local FILE_NAME =
    FILE_FOLDER .. "/cursors.json"

local Enabled = true
local Size = 32

local ImageID = ""
local CursorName = ""

local SavedCursors = {}

local SelectedCursor = nil

local CursorDropdown = nil


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
-- LOAD FILE
--==============================================================

local function loadCursors()

    SavedCursors = {}


    if not hasFileSystem() then
        return
    end


    pcall(function()

        if not isfolder(FILE_FOLDER) then

            makefolder(
                FILE_FOLDER
            )

        end


        if not isfile(FILE_NAME) then

            writefile(
                FILE_NAME,
                "{}"
            )

            return

        end


        local content =
            readfile(FILE_NAME)


        if content == "" then
            return
        end


        local data =
            HttpService:JSONDecode(
                content
            )


        if type(data) == "table" then

            SavedCursors =
                data

        end

    end)

end


--==============================================================
-- SAVE FILE
--==============================================================

local function saveCursors()

    if not hasFileSystem() then
        return false
    end


    local success =
        pcall(function()

            if not isfolder(FILE_FOLDER) then

                makefolder(
                    FILE_FOLDER
                )

            end


            writefile(

                FILE_NAME,

                HttpService:JSONEncode(
                    SavedCursors
                )

            )

        end)


    return success

end


loadCursors()


--==============================================================
-- FIND CROSSHAIR
--==============================================================

local function getCrosshair()

    local CameraGui =
        PlayerGui:FindFirstChild(
            "CameraGui"
        )


    if not CameraGui then
        return nil
    end


    return CameraGui:FindFirstChild(
        "Crosshair"
    )

end


--==============================================================
-- FIND IMAGE OBJECT
--==============================================================

local function getImageObject()

    local Crosshair =
        getCrosshair()


    if not Crosshair then
        return nil
    end


    if Crosshair:IsA("ImageLabel")
        or Crosshair:IsA("ImageButton") then

        return Crosshair

    end


    local imageLabel =
        Crosshair:FindFirstChildWhichIsA(
            "ImageLabel",
            true
        )


    if imageLabel then
        return imageLabel
    end


    local imageButton =
        Crosshair:FindFirstChildWhichIsA(
            "ImageButton",
            true
        )


    if imageButton then
        return imageButton
    end


    return nil

end


--==============================================================
-- VISIBILITY
--==============================================================

local function setCursorVisible(value)

    Enabled = value


    local Crosshair =
        getCrosshair()


    if not Crosshair then
        return
    end


    local imageObject =
        getImageObject()


    if imageObject then

        imageObject.Visible =
            value

    else

        Crosshair.Visible =
            value

    end

end


--==============================================================
-- SIZE
--==============================================================

local function setCursorSize(value)

    Size =
        tonumber(value)
        or 32


    local Crosshair =
        getCrosshair()


    if not Crosshair then
        return
    end


    local imageObject =
        getImageObject()


    if not imageObject then
        return
    end


    local scale =
        Crosshair:FindFirstChildWhichIsA(
            "UIScale",
            true
        )


    if scale then

        scale.Scale =
            Size / 32

    else

        imageObject.Size =
            UDim2.fromOffset(
                Size,
                Size
            )

    end

end


--==============================================================
-- IMAGE
--==============================================================

local function setCursorImage(id)

    local imageObject =
        getImageObject()


    if not imageObject then
        return false
    end


    id =
        tostring(id or "")


    id =
        id:gsub(
            "^%s+",
            ""
        )


    id =
        id:gsub(
            "%s+$",
            ""
        )


    if id == "" then
        return false
    end


    if id:match(
        "^rbxassetid://"
    ) then

        imageObject.Image =
            id

    else

        imageObject.Image =
            "rbxassetid://" .. id

    end


    return true

end


--==============================================================
-- APPLY
--==============================================================

local function applyCursor(Rayfield)

    if ImageID == "" then

        Rayfield:Notify({

            Title = "Cursor",

            Content =
                "Сначала введи Roblox Asset ID.",

            Duration = 3

        })

        return

    end


    local success =
        setCursorImage(
            ImageID
        )


    if not success then

        Rayfield:Notify({

            Title = "Cursor",

            Content =
                "Crosshair ImageLabel/ImageButton не найден.",

            Duration = 4

        })

        return

    end


    setCursorVisible(
        Enabled
    )

    setCursorSize(
        Size
    )


    Rayfield:Notify({

        Title = "Cursor",

        Content =
            "Курсор применён.",

        Duration = 2

    })

end


--==============================================================
-- GET NAMES
--==============================================================

local function getCursorNames()

    local names = {}


    for name, data in pairs(
        SavedCursors
    ) do

        if type(data) == "table"
            and data.id then

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
-- LOAD SAVED CURSOR
--==============================================================

local function loadSavedCursor(
    name,
    Rayfield
)

    local data =
        SavedCursors[name]


    if not data then
        return
    end


    ImageID =
        tostring(
            data.id or ""
        )


    Size =
        tonumber(
            data.size
        )
        or 32


    Enabled =
        data.enabled ~= false


    setCursorImage(
        ImageID
    )

    setCursorVisible(
        Enabled
    )

    setCursorSize(
        Size
    )


    Rayfield:Notify({

        Title = "Cursor Loaded",

        Content =
            "Загружен: " .. name,

        Duration = 2

    })

end


--==============================================================
-- REFRESH DROPDOWN
--==============================================================

local function refreshList()

    loadCursors()


    if CursorDropdown then

        CursorDropdown:Refresh(
            getCursorNames()
        )

    end

end


--==============================================================
-- INIT
--==============================================================

function Module:Init(
    CursorTab,
    SavedTab,
    Rayfield
)

    --==========================================================
    -- INFO
    --==========================================================

    CursorTab:CreateParagraph({

        Title =
            "Roblox Asset ID",

        Content =
            "Для поиска курсора используй cursors.dev.\n\n" ..
            "Скопируй Roblox Asset ID изображения " ..
            "и вставь его ниже."

    })


    --==========================================================
    -- ENABLE
    --==========================================================

    CursorTab:CreateToggle({

        Name =
            "Enable Cursor",

        CurrentValue =
            Enabled,

        Callback = function(Value)

            setCursorVisible(
                Value
            )

        end

    })


    --==========================================================
    -- ASSET ID
    --==========================================================

    CursorTab:CreateInput({

        Name =
            "Cursor Asset ID",

        PlaceholderText =
            "Например: 1234567890",

        RemoveTextAfterFocusLost =
            false,

        Callback = function(Text)

            ImageID =
                tostring(Text)

        end

    })


    --==========================================================
    -- SIZE
    --==========================================================

    CursorTab:CreateSlider({

        Name =
            "Cursor Size",

        Range = {
            8,
            200
        },

        Increment =
            1,

        Suffix =
            " px",

        CurrentValue =
            32,

        Callback = function(Value)

            setCursorSize(
                Value
            )

        end

    })


    --==========================================================
    -- APPLY
    --==========================================================

    CursorTab:CreateButton({

        Name =
            "Apply Cursor",

        Callback = function()

            applyCursor(
                Rayfield
            )

        end

    })


    --==========================================================
    -- RESET
    --==========================================================

    CursorTab:CreateButton({

        Name =
            "Reset Size",

        Callback = function()

            setCursorSize(
                32
            )


            Rayfield:Notify({

                Title =
                    "Cursor",

                Content =
                    "Размер установлен на 32 px.",

                Duration =
                    2

            })

        end

    })


    --==========================================================
    -- NAME
    --==========================================================

    CursorTab:CreateInput({

        Name =
            "Cursor Name",

        PlaceholderText =
            "Например: Minecraft",

        RemoveTextAfterFocusLost =
            false,

        Callback = function(Text)

            CursorName =
                tostring(Text)

        end

    })


    --==========================================================
    -- SAVE
    --==========================================================

    CursorTab:CreateButton({

        Name =
            "Save Cursor",

        Callback = function()

            local name =
                CursorName:gsub(
                    "^%s+",
                    ""
                ):gsub(
                    "%s+$",
                    ""
                )


            local id =
                ImageID:gsub(
                    "^%s+",
                    ""
                ):gsub(
                    "%s+$",
                    ""
                )


            if name == "" then

                Rayfield:Notify({

                    Title =
                        "Cursor",

                    Content =
                        "Введи название курсора.",

                    Duration =
                        3

                })

                return

            end


            if id == "" then

                Rayfield:Notify({

                    Title =
                        "Cursor",

                    Content =
                        "Введи Asset ID.",

                    Duration =
                        3

                })

                return

            end


            SavedCursors[name] = {

                id =
                    id,

                size =
                    Size,

                enabled =
                    Enabled

            }


            if saveCursors() then

                refreshList()


                Rayfield:Notify({

                    Title =
                        "Cursor Saved",

                    Content =
                        "Сохранён: " .. name,

                    Duration =
                        3

                })

            else

                Rayfield:Notify({

                    Title =
                        "Cursor",

                    Content =
                        "Не удалось сохранить файл.",

                    Duration =
                        4

                })

            end

        end

    })


    --==========================================================
    -- SAVED CURSORS
    --==========================================================

    CursorDropdown =
        SavedTab:CreateDropdown({

            Name =
                "Saved Cursors",

            Options =
                getCursorNames(),

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


                if not name then
                    return
                end


                SelectedCursor =
                    name


                loadSavedCursor(
                    name,
                    Rayfield
                )

            end

        })


    --==========================================================
    -- REFRESH
    --==========================================================

    SavedTab:CreateButton({

        Name =
            "Refresh List",

        Callback = function()

            refreshList()


            Rayfield:Notify({

                Title =
                    "Saved Cursors",

                Content =
                    "Список обновлён.",

                Duration =
                    2

            })

        end

    })


    --==========================================================
    -- DELETE
    --==========================================================

    SavedTab:CreateButton({

        Name =
            "Delete Selected",

        Callback = function()

            if not SelectedCursor then

                Rayfield:Notify({

                    Title =
                        "Saved Cursors",

                    Content =
                        "Сначала выбери курсор.",

                    Duration =
                        3

                })

                return

            end


            local name =
                SelectedCursor


            if SavedCursors[name] then

                SavedCursors[name] =
                    nil


                saveCursors()


                SelectedCursor =
                    nil


                refreshList()


                Rayfield:Notify({

                    Title =
                        "Cursor Deleted",

                    Content =
                        "Удалён: " .. name,

                    Duration =
                        2

                })

            end

        end

    })


    --==========================================================
    -- FILE INFO
    --==========================================================

    SavedTab:CreateParagraph({

        Title =
            "Saved Cursors",

        Content =
            "Выбери курсор из списка, чтобы " ..
            "сразу применить его.\n\n" ..
            "Файл: " ..
            FILE_NAME

    })


    --==========================================================
    -- START
    --==========================================================

    Rayfield:Notify({

        Title =
            "Custom Cursor",

        Content =
            "Загружено курсоров: " ..
            tostring(
                #getCursorNames()
            ),

        Duration =
            3

    })

end


return Module
