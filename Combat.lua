--==============================================================
-- Combat.lua
-- Combat Module
--
-- Features:
--   • Kill Aura
--   • Kill Aura Range
--   • Attack Delay
--   • Kill Aura FOV
--   • FOV Circle
--   • No Fall Damage
--   • No Drown Damage
--==============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Module = {}

--==============================================================
-- SETTINGS
--==============================================================

local KillAuraEnabled = false
local KillAuraRange = 24
local AttackDelay = 0.35

local FOVEnabled = false
local FOVSize = 80
local FOVColor = Color3.fromRGB(255, 255, 255)

local NoFallDamage = false
local NoDrownDamage = false


--==============================================================
-- REMOTES
--==============================================================

local Systems =
    ReplicatedStorage:WaitForChild("Systems")

local CombatNetwork =
    Systems
        :WaitForChild("CombatSystem")
        :WaitForChild("Network")

local FallRemote =
    CombatNetwork:WaitForChild("FallDamage")

local DrownRemote =
    CombatNetwork:WaitForChild("DrownDamage")

local AttackRemote =
    Systems
        :WaitForChild("ActionsSystem")
        :WaitForChild("Network")
        :WaitForChild("Attack")


--==============================================================
-- FOV CIRCLE
--==============================================================

local FOVCircle

if type(Drawing) == "table"
    and type(Drawing.new) == "function" then

    FOVCircle = Drawing.new("Circle")

    FOVCircle.Visible = false
    FOVCircle.Radius = FOVSize
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Color = FOVColor

end


--==============================================================
-- FOV UPDATE
--==============================================================

RunService.RenderStepped:Connect(function()

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return
    end

    if FOVCircle then

        FOVCircle.Position =
            Camera.ViewportSize / 2

        FOVCircle.Radius =
            FOVSize

        FOVCircle.Color =
            FOVColor

        FOVCircle.Visible =
            FOVEnabled

    end

end)


--==============================================================
-- CHARACTER
--==============================================================

local function getRoot(character)

    if not character then
        return nil
    end

    return character:FindFirstChild(
        "HumanoidRootPart"
    )
    or character.PrimaryPart

end


--==============================================================
-- FOV CHECK
--==============================================================

local function isInsideFOV(position)

    if not FOVEnabled then
        return true
    end

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return false
    end

    local screenPosition,
        visible =
        Camera:WorldToViewportPoint(
            position
        )

    if not visible then
        return false
    end

    local center =
        Camera.ViewportSize / 2

    local point =
        Vector2.new(
            screenPosition.X,
            screenPosition.Y
        )

    return (
        point - center
    ).Magnitude <= FOVSize

end


--==============================================================
-- FIND TARGET
--==============================================================

local function getNearestTarget()

    local myCharacter =
        LocalPlayer.Character

    local myRoot =
        getRoot(myCharacter)

    if not myRoot then
        return nil
    end

    local nearestTarget = nil
    local nearestDistance =
        KillAuraRange


    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if player ~= LocalPlayer then

            local character =
                player.Character

            local root =
                getRoot(character)

            local humanoid =
                character
                and character:FindFirstChildOfClass(
                    "Humanoid"
                )


            if root
                and humanoid
                and humanoid.Health > 0 then

                local distance =
                    (
                        root.Position
                        - myRoot.Position
                    ).Magnitude


                if distance <= nearestDistance
                    and isInsideFOV(
                        root.Position
                    ) then

                    nearestTarget =
                        character

                    nearestDistance =
                        distance

                end

            end

        end

    end


    return nearestTarget

end


--==============================================================
-- ATTACK
--==============================================================

local function attack(target)

    local character =
        LocalPlayer.Character

    if not character then
        return
    end

    if not target then
        return
    end


    local slot =
        character:GetAttribute(
            "ReplicatedHotbarSlot"
        )

    if slot == nil then
        return
    end


    local success, result =
        pcall(function()

            return AttackRemote:InvokeServer(
                target,
                tostring(slot)
            )

        end)


    if not success then

        warn(
            "[Combat] Attack error:",
            result
        )

    end

end


--==============================================================
-- KILL AURA LOOP
--==============================================================

task.spawn(function()

    while true do

        if KillAuraEnabled then

            local target =
                getNearestTarget()

            if target then
                attack(target)
            end

        end

        task.wait(
            AttackDelay
        )

    end

end)


--==============================================================
-- UI
--==============================================================

function Module:Init(Tab)

    --==========================================================
    -- KILL AURA
    --==========================================================

    Tab:CreateToggle({

        Name = "Kill Aura",

        CurrentValue = false,

        Callback = function(Value)

            KillAuraEnabled =
                Value

        end

    })


    --==========================================================
    -- RANGE
    --==========================================================

    Tab:CreateSlider({

        Name = "Kill Aura Range",

        Range = {
            5,
            100
        },

        Increment = 1,

        Suffix = " studs",

        CurrentValue = 24,

        Callback = function(Value)

            KillAuraRange =
                Value

        end

    })


    --==========================================================
    -- ATTACK DELAY
    --==========================================================

    Tab:CreateSlider({

        Name = "Attack Delay",

        Range = {
            0.05,
            2
        },

        Increment = 0.05,

        Suffix = " sec",

        CurrentValue = 0.35,

        Callback = function(Value)

            AttackDelay =
                Value

        end

    })


    --==========================================================
    -- FOV
    --==========================================================

    Tab:CreateToggle({

        Name = "Kill Aura FOV",

        CurrentValue = false,

        Callback = function(Value)

            FOVEnabled =
                Value

        end

    })


    Tab:CreateSlider({

        Name = "FOV",

        Range = {
            20,
            500
        },

        Increment = 5,

        Suffix = " px",

        CurrentValue = 80,

        Callback = function(Value)

            FOVSize =
                Value

        end

    })


    --==========================================================
    -- FOV COLOR
    --==========================================================

    Tab:CreateColorPicker({

        Name = "FOV Color",

        Color = FOVColor,

        Callback = function(Value)

            FOVColor =
                Value

        end

    })


    --==========================================================
    -- NO FALL DAMAGE
    --==========================================================

    Tab:CreateToggle({

        Name = "No Fall Damage",

        CurrentValue = false,

        Callback = function(Value)

            NoFallDamage =
                Value

        end

    })


    --==========================================================
    -- NO DROWN DAMAGE
    --==========================================================

    Tab:CreateToggle({

        Name = "No Drown Damage",

        CurrentValue = false,

        Callback = function(Value)

            NoDrownDamage =
                Value

        end

    })


    --==========================================================
    -- INFO
    --==========================================================

    Tab:CreateParagraph({

        Title = "Combat",

        Content =
            "Kill Aura выбирает ближайшую живую цель " ..
            "в пределах Range. При включённом FOV цель " ..
            "также должна находиться внутри круга."

    })

end


return Module
