--==============================================================
-- Misc.lua
-- Mobile Misc Module
--
-- Features:
--   • Fly
--   • Fly Speed
--   • Jump Power
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Module = {}

--==============================================================
-- SETTINGS
--==============================================================

local FlyEnabled = false
local FlySpeed = 50
local JumpPower = 50

local FlyConnection = nil


--==============================================================
-- CHARACTER HELPERS
--==============================================================

local function getCharacter()

    return LocalPlayer.Character

end


local function getHumanoid()

    local character = getCharacter()

    if not character then
        return nil
    end

    return character:FindFirstChildOfClass(
        "Humanoid"
    )

end


local function getRoot()

    local character = getCharacter()

    if not character then
        return nil
    end

    return character:FindFirstChild(
        "HumanoidRootPart"
    )

end


--==============================================================
-- STOP FLY
--==============================================================

local function stopFly()

    if FlyConnection then

        FlyConnection:Disconnect()

        FlyConnection = nil

    end


    local root = getRoot()

    if root then

        root.AssemblyLinearVelocity =
            Vector3.zero

    end

end


--==============================================================
-- START FLY
--==============================================================

local function startFly()

    stopFly()


    FlyConnection =
        RunService.RenderStepped:Connect(
            function()

                local humanoid =
                    getHumanoid()

                local root =
                    getRoot()

                local camera =
                    workspace.CurrentCamera


                if not humanoid
                    or not root
                    or not camera then

                    return

                end


                --================================================
                -- MOBILE JOYSTICK
                --================================================

                local move =
                    humanoid.MoveDirection


                --================================================
                -- VERTICAL MOVEMENT
                --================================================

                local vertical = 0


                -- Мобильная кнопка Jump
                if humanoid.Jump then

                    vertical = 1

                end


                --================================================
                -- FINAL DIRECTION
                --================================================

                local direction =
                    Vector3.new(
                        move.X,
                        vertical,
                        move.Z
                    )


                if direction.Magnitude > 1 then

                    direction =
                        direction.Unit

                end


                root.AssemblyLinearVelocity =
                    direction * FlySpeed

            end
        )

end


--==============================================================
-- APPLY JUMP POWER
--==============================================================

local function applyJumpPower()

    local humanoid =
        getHumanoid()

    if not humanoid then
        return
    end


    humanoid.UseJumpPower =
        true

    humanoid.JumpPower =
        JumpPower

end


--==============================================================
-- UI
--==============================================================

function Module:Init(Tab)

    --==========================================================
    -- FLY
    --==========================================================

    Tab:CreateToggle({

        Name = "Fly",

        CurrentValue = false,

        Callback = function(Value)

            FlyEnabled =
                Value


            if FlyEnabled then

                startFly()

            else

                stopFly()

            end

        end

    })


    --==========================================================
    -- FLY SPEED
    --==========================================================

    Tab:CreateSlider({

        Name = "Fly Speed",

        Range = {
            10,
            200
        },

        Increment = 5,

        Suffix = " studs/s",

        CurrentValue = 50,

        Callback = function(Value)

            FlySpeed =
                Value

        end

    })


    --==========================================================
    -- JUMP POWER
    --==========================================================

    Tab:CreateSlider({

        Name = "Jump Power",

        Range = {
            10,
            150
        },

        Increment = 5,

        Suffix = " power",

        CurrentValue = 50,

        Callback = function(Value)

            JumpPower =
                Value

            applyJumpPower()

        end

    })


    --==========================================================
    -- RESPAWN
    --==========================================================

    LocalPlayer.CharacterAdded:Connect(
        function()

            task.wait(0.5)

            applyJumpPower()


            if FlyEnabled then

                startFly()

            end

        end
    )


    --==========================================================
    -- INFO
    --==========================================================

    Tab:CreateParagraph({

        Title = "Mobile Fly",

        Content =
            "Используй мобильный джойстик для " ..
            "горизонтального движения. Кнопка Jump " ..
            "используется для подъёма."

    })

end


--==============================================================
-- CLEANUP
--==============================================================

function Module:Destroy()

    stopFly()

end


return Module
