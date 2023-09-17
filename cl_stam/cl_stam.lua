local playerPed = PlayerPedId()
local player = PlayerId()
local set = V_Stam.TiredClipSet
local IsTired = false

CreateThread(function()
    while true do
        Wait(500)
        playerPed = PlayerPedId()
        player = PlayerId()
    end
end)


--[[DEBUG]]--
function DrawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

local floatValues = {
    x = 0.5,
    y = 0.5,
    width = 0.5,
    height = 0.5,
    scale = 0.5,
    r = 255,
    g = 255,
    b = 255,
    a = 255
}
Citizen.CreateThread(function()
    while V_Stam.debug do 
        local stam = GetPlayerStamina(PlayerId())
        local stamd = string.sub(stam, 1, 2)
        local getclip = GetPedMovementClipset(playerPed)
        local str = 'false'
        if getclip == GetHashKey(V_Stam.TiredClipSet) then
            str = 'true'
        end
        if stam == 100 then
            stamd = '100'
        end
        DrawTxt(floatValues.x, floatValues.y, floatValues.width, floatValues.height, floatValues.scale, '[~r~DEBUG~s~] Stamina: ~b~' .. stamd .. '%~s~ | ClipSet: ~b~' .. getclip .. '~s~ | Clip Enabled: ~b~' .. str, floatValues.r, floatValues.g, floatValues.b, floatValues.a)
        Wait(1)
    end
end)
--[[DEBUG END]]--


SetPlayerMaxStamina(player, V_Stam.MaxStamina) -- Set max stamina

--[[FEATURES]]--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local getstam = GetPlayerStamina(player)
        local getclip = GetPedMovementClipset(playerPed)
        local IsJumping = IsPedJumping(playerPed)

        --[[CLIPSET]]--
        if V_Stam.EnableClipSet then
            if getstam == V_Stam.StartClipSetThreshold then
                SetPedMovementClipset(playerPed, set, 1000)
            end
            if getstam >= V_Stam.ResetClipSetThreshold and getclip == GetHashKey(V_Stam.TiredClipSet)  then
                ResetPedMovementClipset(playerPed, 1000)
            end
        end
        --[[screen effects]]--
        if V_Stam.TiredEffects then
            if getstam <= V_Stam.TiredEffectsThreshold then 
                SendNUIMessage({
                    action = 'start_effect'
                })
            end
            if getstam >= V_Stam.TiredEffectsThreshold and getstam <= V_Stam.TiredEffectsThreshold + 1 then 
                SendNUIMessage({
                    action = 'stop_effect'
                })
            elseif IsPedDeadOrDying(playerPed, true) then -- if player dies with the effect, stop it.
                SendNUIMessage({
                    action = 'stop_effect'
                })
            end
        end

        if V_Stam.TiredShakeEffect and getstam == V_Stam.StartClipSetThreshold then
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', V_Stam.TiredShakeIntensity)
        end

        --[[Jumping etc.]]--
        if V_Stam.DisableJumping then
                if getstam <= V_Stam.DisableJumpingThreshold and V_Stam.DisableJumpingThreshold ~= -1 then
                    DisableControlAction(0, 22, true)
                elseif V_Stam.DisableJumpingThreshold == -1 and getclip == GetHashKey(V_Stam.TiredClipSet) then
                    DisableControlAction(0, 22, true)
                end
        end

        if V_Stam.DrainStamOnJumping and IsJumping then
            SetPlayerStamina(player, getstam - V_Stam.DrainStamOnJumpingMultiplier)
        end

        --[[Climbing]]--
        if V_Stam.DrainStamOnClimbing and IsPlayerClimbing(player) then
            SetPlayerStamina(player, getstam - V_Stam.DrainStamOnClimbingMultiplier)
        end

        if getstam < 0 then
            SetPlayerStamina(player, 0)
        end

    end
end)

Citizen.CreateThread(function()
    while true do
            StatSetInt(`MP0_STAMINA`, V_Stam.StaminaSpeedUsage, true)
        Citizen.Wait(100)
    end
end)