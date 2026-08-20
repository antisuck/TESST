--==============================================================
-- Combat.lua
-- TESST Combat Module
--
-- Client-side test module for your own Roblox place
--
-- Features:
--   • Kill Aura toggle
--   • Kill Aura range
--   • Attack delay
--   • FOV circle
--   • FOV size
--   • FOV color
--   • No Fall Damage
--==============================================================

local Players = game:GetService("Players")
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
local FOVColor =
    Color3.fromRGB(255, 255, 255)

local NoFallDamageEnabled = false

local AttackRemote = nil

local FOVCircle = nil

local KillAuraConnection = nil
local FOVConnection = nil

local LastAttack = 0


--==============================================================
-- FIND ATTACK REMOTE
--==============================================================

local function findAttackRemote()

    local ReplicatedStorage =
        game:GetService("ReplicatedStorage")

    local systems =
        ReplicatedStorage:FindFirstChild(
            "Systems"
        )

    if not systems then
        return nil
    end


    local actions =
        systems:FindFirstChild(
            "ActionsSystem"
        )

    if not actions then
        return nil
    end


    local network =
        actions:FindFirstChild(
            "Network"
        )

    if not network then
        return nil
    end


    return network:FindFirstChild(
        "Attack"
    )

end


AttackRemote =
    findAttackRemote()


--==============================================================
-- CHARACTER
--==============================================================

local function getCharacter()

    return LocalPlayer.Character

end


local function getRoot(character)

    if not character then
        return nil
    end


    return character:FindFirstChild(
        "HumanoidRootPart"
    )

end


local function getHumanoid(character)

    if not character then
        return nil
    end


    return character:FindFirstChildOfClass(
        "Humanoid"
    )

end


--==============================================================
-- FIND NEAREST TARGET
--==============================================================

local function getNearestTarget()

    local character =
        getCharacter()


    local myRoot =
        getRoot(character)


    if not myRoot then
        return nil
    end


    local nearest =
        nil

    local nearestDistance =
        KillAuraRange


    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if player ~= LocalPlayer then

            local targetCharacter =
                player.Character


            local targetRoot =
                getRoot(
                    targetCharacter
                )


            local humanoid =
                getHumanoid(
                    targetCharacter
                )


            if targetRoot
                and humanoid
                and humanoid.Health > 0 then

                local distance =
                    (
                        targetRoot.Position
                        - myRoot.Position
                    ).Magnitude


                if distance <= nearestDistance then

                    nearest =
                        targetCharacter

                    nearestDistance =
                        distance

                end

            end

        end

    end


    return nearest

end


--==============================================================
-- ATTACK
--==============================================================

local function attack(target)

    if not target then
        return
    end


    if not AttackRemote then

        AttackRemote =
            findAttackRemote()

    end


    if not AttackRemote then
        return
    end


    local character =
        getCharacter()


    if not character then
        return
    end


    local slot =
        character:GetAttribute(
            "ReplicatedHotbarSlot"
        )


    if slot == nil then
        return
    end


    -- Для собственного place:
    -- используем обычный RemoteFunction,
    -- если твоя система действительно его предоставляет.

    if AttackRemote:IsA(
        "RemoteFunction"
    ) then

        local success, result =
            pcall(function()

                return AttackRemote:InvokeServer(
                    target,
                    tostring(slot)
                )

            end)


        if not success then

            warn(
                "[TESST] Attack error:",
                result
            )

        end

    end

end


--==============================================================
-- KILL AURA LOOP
--==============================================================

local function startKillAura()

    if KillAuraConnection then
        return
    end


    KillAuraConnection =
        RunService.Heartbeat:Connect(
            function()

                if not KillAuraEnabled then
                    return
                end


                local now =
                    os.clock()


                if now - LastAttack <
                    AttackDelay then

                    return

                end


                local target =
                    getNearestTarget()


                if target then

                    LastAttack =
                        now

                    attack(target)

                end

            end
        )

end


local function stopKillAura()

    if KillAuraConnection then

        KillAuraConnection:Disconnect()

        KillAuraConnection =
            nil

    end

end


--==============================================================
-- FOV CIRCLE
--==============================================================

local function createFOV()

    if FOVCircle then
        return
    end


    -- Drawing API используется только если
    -- он доступен в текущей среде.

    if typeof(Drawing) ~= "table"
        and typeof(Drawing) ~= "userdata" then

        return

    end


    local success, circle =
        pcall(function()

            return Drawing.new(
                "Circle"
            )

        end)


    if not success or not circle then
        return
    end


    FOVCircle =
        circle


    FOVCircle.Visible =
        FOVEnabled

    FOVCircle.Radius =
        FOVSize

    FOVCircle.Thickness =
        1

    FOVCircle.Filled =
        false

    FOVCircle.Color =
        FOVColor

    FOVCircle.NumSides =
        64

end


--==============================================================
-- UPDATE FOV
--==============================================================

local function updateFOV()

    if not FOVCircle then
        return
    end


    local camera =
        workspace.CurrentCamera


    if not camera then
        return
    end


    local viewport =
        camera.ViewportSize


    FOVCircle.Position =
        Vector2.new(
            viewport.X / 2,
            viewport.Y / 2
        )


    FOVCircle.Radius =
        FOVSize

    FOVCircle.Color =
        FOVColor

    FOVCircle.Visible =
        FOVEnabled

end


--==============================================================
-- FOV LOOP
--==============================================================

local function startFOV()

    if FOVConnection then
        return
    end


    createFOV()


    FOVConnection =
        RunService.RenderStepped:Connect(
            function()

                updateFOV()

            end
        )

end


--==============================================================
-- NO FALL DAMAGE
--==============================================================

local function setupNoFallProtection()

    local character =
        getCharacter()


    if not character then
        return
    end


    local humanoid =
        getHumanoid(character)


    if not humanoid then
        return
    end


    -- Важно:
    -- это не перехватывает RemoteEvent.
    -- Мы только предотвращаем некоторые
    -- локальные humanoid-состояния,
    -- которые могут использоваться твоей
    -- собственной системой падения.

    if NoFallDamageEnabled then

        if humanoid:GetState() ==
            Enum.HumanoidStateType.FallingDown then

            humanoid:ChangeState(
                Enum.HumanoidStateType.GettingUp
            )

        end

    end

end


--==============================================================
-- NO FALL LOOP
--==============================================================

local NoFallConnection = nil


local function startNoFall()

    if NoFallConnection then
        return
    end


    NoFallConnection =
        RunService.Heartbeat:Connect(
            function()

                if not NoFallDamageEnabled then
                    return
                end


                setupNoFallProtection()

            end
        )

end


local function stopNoFall()

    if NoFallConnection then

        NoFallConnection:Disconnect()

        NoFallConnection =
            nil

    end

end


--==============================================================
-- UI
--==============================================================

function Module:Init(Tab)

    --==========================================================
    -- KILL AURA
    --==========================================================

    Tab:CreateToggle({

        Name =
            "Kill Aura",

        CurrentValue =
            false,

        Callback = function(Value)

            KillAuraEnabled =
                Value


            if Value then

                startKillAura()

            else

                stopKillAura()

            end

        end

    })


    --==========================================================
    -- RANGE
    --==========================================================

    Tab:CreateSlider({

        Name =
            "Kill Aura Range",

        Range = {
            5,
            100
        },

        Increment =
            1,

        Suffix =
            " studs",

        CurrentValue =
            24,

        Callback = function(Value)

            KillAuraRange =
                Value

        end

    })


    --==========================================================
    -- ATTACK DELAY
    --==========================================================

    Tab:CreateSlider({

        Name =
            "Attack Delay",

        Range = {
            0.05,
            2
        },

        Increment =
            0.05,

        Suffix =
            " sec",

        CurrentValue =
            0.35,

        Callback = function(Value)

            AttackDelay =
                Value

        end

    })


    --==========================================================
    -- FOV
    --==========================================================

    Tab:CreateToggle({

        Name =
            "Kill Aura FOV",

        CurrentValue =
            false,

        Callback = function(Value)

            FOVEnabled =
                Value


            createFOV()

            updateFOV()

        end

    })


    --==========================================================
    -- FOV SIZE
    --==========================================================

    Tab:CreateSlider({

        Name =
            "FOV Size",

        Range = {
            20,
            300
        },

        Increment =
            1,

        Suffix =
            " px",

        CurrentValue =
            80,

        Callback = function(Value)

            FOVSize =
                Value


            updateFOV()

        end

    })


    --==========================================================
    -- FOV COLOR
    --==========================================================

    Tab:CreateColorPicker({

        Name =
            "FOV Color",

        Color =
            FOVColor,

        Callback = function(Value)

            FOVColor =
                Value


            updateFOV()

        end

    })


    --==========================================================
    -- NO FALL DAMAGE
    --==========================================================

    Tab:CreateToggle({

        Name =
            "No Fall Damage",

        CurrentValue =
            false,

        Callback = function(Value)

            NoFallDamageEnabled =
                Value


            if Value then

                startNoFall()

            else

                stopNoFall()

            end

        end

    })


    --==========================================================
    -- INFO
    --==========================================================

    Tab:CreateParagraph({

        Title =
            "Combat",

        Content =
            "Kill Aura автоматически выбирает " ..
            "ближайшую живую цель в заданном радиусе.\n\n" ..
            "FOV показывает круг в центре экрана."

    })


    --==========================================================
    -- CHARACTER RESPAWN
    --==========================================================

    LocalPlayer.CharacterAdded:Connect(
        function()

            task.wait(0.5)


            if NoFallDamageEnabled then
                startNoFall()
            end


            if KillAuraEnabled then
                startKillAura()
            end

        end
    )

end


--==============================================================
-- CLEANUP
--==============================================================

function Module:Destroy()

    stopKillAura()
    stopNoFall()


    if FOVConnection then

        FOVConnection:Disconnect()

        FOVConnection =
            nil

    end


    if FOVCircle then

        pcall(function()

            FOVCircle:Remove()

        end)


        FOVCircle =
            nil

    end

end


return Module