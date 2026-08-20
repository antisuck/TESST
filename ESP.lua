--==============================================================
-- ESP.lua
-- TESST Visuals Module
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Module = {}

--==============================================================
-- SETTINGS
--==============================================================

local BoxEnabled = false
local NameEnabled = true
local TracersEnabled = false

local ESPColor =
    Color3.fromRGB(255, 70, 70)

local ESPObjects = {}

local RenderConnection = nil


--==============================================================
-- CREATE ESP
--==============================================================

local function createESP(player)

    if player == LocalPlayer then
        return
    end

    if ESPObjects[player] then
        return
    end

    local data = {}

    --==========================================================
    -- BOX
    --==========================================================

    local box = Drawing.new("Square")

    box.Visible = false
    box.Filled = false
    box.Thickness = 1
    box.Color = ESPColor

    data.Box = box

    --==========================================================
    -- NAME
    --==========================================================

    local name = Drawing.new("Text")

    name.Visible = false
    name.Center = true
    name.Outline = true
    name.Size = 13
    name.Font = 2
    name.Color = ESPColor

    data.Name = name

    --==========================================================
    -- TRACER
    --==========================================================

    local tracer = Drawing.new("Line")

    tracer.Visible = false
    tracer.Thickness = 1
    tracer.Color = ESPColor

    data.Tracer = tracer

    ESPObjects[player] = data
end


--==============================================================
-- REMOVE ESP
--==============================================================

local function removeESP(player)

    local data = ESPObjects[player]

    if not data then
        return
    end

    for _, object in pairs(data) do

        pcall(function()
            object.Visible = false
            object:Remove()
        end)

    end

    ESPObjects[player] = nil
end


--==============================================================
-- UPDATE PLAYER
--==============================================================

local function updatePlayer(player, data)

    local character =
        player.Character

    if not character then
        data.Box.Visible = false
        data.Name.Visible = false
        data.Tracer.Visible = false
        return
    end

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not humanoid
        or humanoid.Health <= 0
        or not root then

        data.Box.Visible = false
        data.Name.Visible = false
        data.Tracer.Visible = false

        return
    end

    local camera =
        workspace.CurrentCamera

    if not camera then
        return
    end

    --==========================================================
    -- CHARACTER BOUNDS
    --==========================================================

    local cf, size =
        character:GetBoundingBox()

    local topWorld =
        cf.Position +
        Vector3.new(
            0,
            size.Y / 2,
            0
        )

    local bottomWorld =
        cf.Position -
        Vector3.new(
            0,
            size.Y / 2,
            0
        )

    local topScreen,
          topVisible =
        camera:WorldToViewportPoint(
            topWorld
        )

    local bottomScreen,
          bottomVisible =
        camera:WorldToViewportPoint(
            bottomWorld
        )

    local rootScreen,
          rootVisible =
        camera:WorldToViewportPoint(
            root.Position
        )

    if not topVisible
        and not bottomVisible
        and not rootVisible then

        data.Box.Visible = false
        data.Name.Visible = false
        data.Tracer.Visible = false

        return
    end

    --==========================================================
    -- BOX SIZE
    --==========================================================

    local height =
        math.abs(
            bottomScreen.Y -
            topScreen.Y
        )

    if height < 2 then

        data.Box.Visible = false
        data.Name.Visible = false
        data.Tracer.Visible = false

        return
    end

    local width =
        math.max(
            height * 0.55,
            2
        )

    local boxPosition =
        Vector2.new(
            rootScreen.X - width / 2,
            topScreen.Y
        )

    --==========================================================
    -- COLOR
    --==========================================================

    data.Box.Color =
        ESPColor

    data.Name.Color =
        ESPColor

    data.Tracer.Color =
        ESPColor

    --==========================================================
    -- BOX
    --==========================================================

    if BoxEnabled then

        data.Box.Position =
            boxPosition

        data.Box.Size =
            Vector2.new(
                width,
                height
            )

        data.Box.Visible =
            true

    else

        data.Box.Visible =
            false

    end

    --==========================================================
    -- NAME
    --==========================================================

    if NameEnabled then

        data.Name.Text =
            player.Name

        data.Name.Position =
            Vector2.new(
                rootScreen.X,
                topScreen.Y - 16
            )

        data.Name.Visible =
            true

    else

        data.Name.Visible =
            false

    end

    --==========================================================
    -- TRACER
    --==========================================================

    if TracersEnabled then

        local viewport =
            camera.ViewportSize

        data.Tracer.From =
            Vector2.new(
                viewport.X / 2,
                viewport.Y
            )

        data.Tracer.To =
            Vector2.new(
                rootScreen.X,
                bottomScreen.Y
            )

        data.Tracer.Visible =
            true

    else

        data.Tracer.Visible =
            false

    end
end


--==============================================================
-- RENDER LOOP
--==============================================================

local function startESP()

    if RenderConnection then
        return
    end

    RenderConnection =
        RunService.RenderStepped:Connect(
            function()

                for player, data in pairs(
                    ESPObjects
                ) do

                    if player.Parent then

                        updatePlayer(
                            player,
                            data
                        )

                    else

                        removeESP(
                            player
                        )

                    end

                end

            end
        )

end


--==============================================================
-- INIT
--==============================================================

function Module:Init(Tab)

    --==========================================================
    -- BOX
    --==========================================================

    Tab:CreateToggle({

        Name =
            "ESP Box",

        CurrentValue =
            false,

        Callback = function(Value)

            BoxEnabled =
                Value

        end

    })


    --==========================================================
    -- NAME
    --==========================================================

    Tab:CreateToggle({

        Name =
            "ESP Name",

        CurrentValue =
            true,

        Callback = function(Value)

            NameEnabled =
                Value

        end

    })


    --==========================================================
    -- TRACERS
    --==========================================================

    Tab:CreateToggle({

        Name =
            "Tracers",

        CurrentValue =
            false,

        Callback = function(Value)

            TracersEnabled =
                Value

        end

    })


    --==========================================================
    -- COLOR
    --==========================================================

    Tab:CreateColorPicker({

        Name =
            "ESP Color",

        Color =
            ESPColor,

        Callback = function(Value)

            ESPColor =
                Value

        end

    })


    --==========================================================
    -- INFO
    --==========================================================

    Tab:CreateParagraph({

        Title =
            "ESP",

        Content =
            "Box — рамка вокруг игрока.\n" ..
            "Name — ник игрока сверху.\n" ..
            "Tracers — тонкая линия от нижней части экрана."

    })


    --==========================================================
    -- PLAYERS
    --==========================================================

    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        createESP(player)

    end


    Players.PlayerAdded:Connect(
        function(player)

            createESP(player)

        end
    )


    Players.PlayerRemoving:Connect(
        function(player)

            removeESP(player)

        end
    )


    --==========================================================
    -- START
    --==========================================================

    startESP()

end


--==============================================================
-- DESTROY
--==============================================================

function Module:Destroy()

    if RenderConnection then

        RenderConnection:Disconnect()

        RenderConnection =
            nil

    end


    for player in pairs(
        ESPObjects
    ) do

        removeESP(player)

    end

end


return Module