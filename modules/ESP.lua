--==============================================================
-- ESP.lua
-- Local Visuals Module
--
-- Features:
--   • Box ESP
--   • Name ESP
--   • Thin Tracers
--   • Aim Indicator
--   • Aim FOV
--   • ESP Color
--   • Aim Indicator Color
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

local AimIndicatorEnabled = false

local AimFOV = 80

local ESPColor =
    Color3.fromRGB(255, 70, 70)

local AimColor =
    Color3.fromRGB(255, 255, 255)


--==============================================================
-- STORAGE
--==============================================================

local Boxes = {}
local Names = {}
local Tracers = {}

local AimFolder =
    Instance.new("Folder")

AimFolder.Name = "LocalAimIndicator"
AimFolder.Parent = workspace


--==============================================================
-- BOX
--==============================================================

local function removeBox(player)

    local object = Boxes[player]

    if object then

        object:Destroy()

        Boxes[player] = nil

    end

end


local function createBox(player)

    if player == LocalPlayer then
        return
    end

    if Boxes[player] then
        return
    end

    local character =
        player.Character

    if not character then
        return
    end

    local highlight =
        Instance.new("Highlight")

    highlight.Name =
        "LocalBoxESP"

    highlight.Adornee =
        character

    highlight.FillColor =
        ESPColor

    highlight.OutlineColor =
        ESPColor

    highlight.FillTransparency =
        0.85

    highlight.OutlineTransparency =
        0

    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Parent =
        character

    Boxes[player] =
        highlight

end


--==============================================================
-- NAME
--==============================================================

local function removeName(player)

    local object = Names[player]

    if object then

        object:Destroy()

        Names[player] = nil

    end

end


local function createName(player)

    if player == LocalPlayer then
        return
    end

    if Names[player] then
        return
    end

    local character =
        player.Character

    if not character then
        return
    end

    local head =
        character:FindFirstChild("Head")

    if not head then
        return
    end


    local billboard =
        Instance.new("BillboardGui")

    billboard.Name =
        "LocalNameESP"

    billboard.Adornee =
        head

    billboard.Size =
        UDim2.fromOffset(
            220,
            35
        )

    billboard.StudsOffset =
        Vector3.new(
            0,
            2.8,
            0
        )

    billboard.AlwaysOnTop =
        true

    billboard.Parent =
        head


    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.fromScale(
            1,
            1
        )

    label.BackgroundTransparency =
        1

    label.Text =
        player.DisplayName ..
        "  @" ..
        player.Name

    label.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    label.TextStrokeTransparency =
        0.25

    label.TextScaled =
        true

    label.Font =
        Enum.Font.GothamBold

    label.Parent =
        billboard


    Names[player] =
        billboard

end


--==============================================================
-- TRACER
--==============================================================

local function removeTracer(player)

    local line =
        Tracers[player]

    if line then

        line:Remove()

        Tracers[player] =
            nil

    end

end


local function createTracer(player)

    if player == LocalPlayer then
        return
    end

    if Tracers[player] then
        return
    end

    -- Drawing is optional.
    if type(Drawing) ~= "table"
        or type(Drawing.new) ~= "function" then

        return

    end


    local line =
        Drawing.new("Line")

    line.Visible =
        false

    line.Thickness =
        1

    line.Transparency =
        1

    line.Color =
        ESPColor


    Tracers[player] =
        line

end


--==============================================================
-- AIM TARGET
--==============================================================

local function getAimTarget()

    local camera =
        workspace.CurrentCamera

    if not camera then
        return nil
    end


    local center =
        camera.ViewportSize / 2

    local target =
        nil

    local closest =
        AimFOV


    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if player ~= LocalPlayer then

            local character =
                player.Character

            local head =
                character
                and character:FindFirstChild(
                    "Head"
                )

            local humanoid =
                character
                and character:FindFirstChildOfClass(
                    "Humanoid"
                )


            if head
                and humanoid
                and humanoid.Health > 0 then

                local position,
                    visible =
                    camera:WorldToViewportPoint(
                        head.Position
                    )


                if visible then

                    local point =
                        Vector2.new(
                            position.X,
                            position.Y
                        )


                    local distance =
                        (
                            point - center
                        ).Magnitude


                    if distance <= closest then

                        closest =
                            distance

                        target =
                            player

                    end

                end

            end

        end

    end


    return target

end


--==============================================================
-- AIM INDICATOR
--==============================================================

local rotation = 0


local function clearAimIndicator()

    for _, object in ipairs(
        AimFolder:GetChildren()
    ) do

        object:Destroy()

    end

end


local function createIndicatorPart(
    position,
    size,
    cframe
)

    local part =
        Instance.new("Part")

    part.Anchored =
        true

    part.CanCollide =
        false

    part.CanTouch =
        false

    part.CanQuery =
        false

    part.Material =
        Enum.Material.Neon

    part.Color =
        AimColor

    part.Transparency =
        0.05

    part.Size =
        size

    part.CFrame =
        cframe

    part.Parent =
        AimFolder

end


local function updateAimIndicator()

    clearAimIndicator()


    if not AimIndicatorEnabled then
        return
    end


    local target =
        getAimTarget()

    if not target then
        return
    end


    local character =
        target.Character

    local root =
        character
        and character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return
    end


    rotation =
        rotation + 0.04


    local center =
        root.Position
        + Vector3.new(
            0,
            1.5,
            0
        )


    local radius =
        2.5

    local segments =
        8


    for i = 1, segments do

        local a1 =
            rotation
            + ((i - 1) / segments)
            * math.pi * 2

        local a2 =
            rotation
            + (i / segments)
            * math.pi * 2


        local p1 =
            center
            + Vector3.new(
                math.cos(a1) * radius,
                math.sin(a1) * 0.5,
                math.sin(a1) * radius
            )


        local p2 =
            center
            + Vector3.new(
                math.cos(a2) * radius,
                math.sin(a2) * 0.5,
                math.sin(a2) * radius
            )


        local direction =
            p2 - p1

        local length =
            direction.Magnitude


        if length > 0 then

            local middle =
                (p1 + p2) / 2


            createIndicatorPart(

                middle,

                Vector3.new(
                    0.06,
                    0.06,
                    length
                ),

                CFrame.lookAt(
                    middle,
                    p2
                )

            )

        end

    end

end


--==============================================================
-- RENDER LOOP
--==============================================================

RunService.RenderStepped:Connect(
    function()

        local camera =
            workspace.CurrentCamera

        if not camera then
            return
        end


        --======================================================
        -- TRACERS
        --======================================================

        for player, line in pairs(
            Tracers
        ) do

            if not TracersEnabled then

                line.Visible =
                    false

                continue

            end


            local character =
                player.Character

            local root =
                character
                and character:FindFirstChild(
                    "HumanoidRootPart"
                )


            if not root then

                line.Visible =
                    false

                continue

            end


            local position,
                visible =
                camera:WorldToViewportPoint(
                    root.Position
                )


            if visible then

                line.From =
                    Vector2.new(
                        camera.ViewportSize.X / 2,
                        camera.ViewportSize.Y
                    )

                line.To =
                    Vector2.new(
                        position.X,
                        position.Y
                    )

                line.Color =
                    ESPColor

                line.Thickness =
                    1

                line.Visible =
                    true

            else

                line.Visible =
                    false

            end

        end


        --======================================================
        -- AIM INDICATOR
        --======================================================

        updateAimIndicator()

    end
)


--==============================================================
-- PLAYER SETUP
--==============================================================

local function setupPlayer(player)

    if player == LocalPlayer then
        return
    end


    player.CharacterAdded:Connect(
        function()

            task.wait(0.5)


            if BoxEnabled then
                createBox(player)
            end


            if NameEnabled then
                createName(player)
            end


            if TracersEnabled then
                createTracer(player)
            end

        end
    )


    player.CharacterRemoving:Connect(
        function()

            removeBox(player)
            removeName(player)

        end
    )

end


for _, player in ipairs(
    Players:GetPlayers()
) do

    setupPlayer(player)

end


Players.PlayerAdded:Connect(
    setupPlayer
)


Players.PlayerRemoving:Connect(
    function(player)

        removeBox(player)
        removeName(player)
        removeTracer(player)

    end
)


--==============================================================
-- UI
--==============================================================

function Module:Init(Tab)

    --==========================================================
    -- BOX ESP
    --==========================================================

    Tab:CreateToggle({

        Name = "Box ESP",

        CurrentValue = false,

        Callback = function(Value)

            BoxEnabled =
                Value


            for _, player in ipairs(
                Players:GetPlayers()
            ) do

                if player ~= LocalPlayer then

                    if Value then
                        createBox(player)
                    else
                        removeBox(player)
                    end

                end

            end

        end

    })


    --==========================================================
    -- NAME ESP
    --==========================================================

    Tab:CreateToggle({

        Name = "Name ESP",

        CurrentValue = true,

        Callback = function(Value)

            NameEnabled =
                Value


            for _, player in ipairs(
                Players:GetPlayers()
            ) do

                if player ~= LocalPlayer then

                    if Value then
                        createName(player)
                    else
                        removeName(player)
                    end

                end

            end

        end

    })


    --==========================================================
    -- TRACERS
    --==========================================================

    Tab:CreateToggle({

        Name = "Tracers",

        CurrentValue = false,

        Callback = function(Value)

            TracersEnabled =
                Value


            for _, player in ipairs(
                Players:GetPlayers()
            ) do

                if player ~= LocalPlayer then

                    if Value then
                        createTracer(player)
                    else
                        removeTracer(player)
                    end

                end

            end

        end

    })


    --==========================================================
    -- ESP COLOR
    --==========================================================

    Tab:CreateColorPicker({

        Name = "ESP Color",

        Color = ESPColor,

        Callback = function(Value)

            ESPColor =
                Value


            for _, highlight in pairs(
                Boxes
            ) do

                highlight.FillColor =
                    Value

                highlight.OutlineColor =
                    Value

            end


            for _, line in pairs(
                Tracers
            ) do

                line.Color =
                    Value

            end

        end

    })


    --==========================================================
    -- AIM INDICATOR
    --==========================================================

    Tab:CreateToggle({

        Name = "Aim Indicator",

        CurrentValue = false,

        Callback = function(Value)

            AimIndicatorEnabled =
                Value

            if not Value then
                clearAimIndicator()
            end

        end

    })


    --==========================================================
    -- AIM FOV
    --==========================================================

    Tab:CreateSlider({

        Name = "Aim FOV",

        Range = {
            20,
            500
        },

        Increment = 5,

        Suffix = " px",

        CurrentValue = 80,

        Callback = function(Value)

            AimFOV =
                Value

        end

    })


    --==========================================================
    -- AIM COLOR
    --==========================================================

    Tab:CreateColorPicker({

        Name = "Aim Indicator Color",

        Color = AimColor,

        Callback = function(Value)

            AimColor =
                Value

        end

    })

end


return Module
