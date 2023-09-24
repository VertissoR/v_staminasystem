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
        local iscombat = IsPedInMeleeCombat(playerPed)
        local getmove = GetPedCombatMovement(playerPed)
        local getrange = GetPedCombatRange(playerPed)
        local meleeact = IsPedPerformingMeleeAction(playerPed)
        local isrunningmelee = IsPedRunningMeleeTask(playerPed)
        local str = 'false'
        local iscmb = 'false'
        local isml = 'false'
        local isrunm = 'false'
        if isrunningmelee then
            isrunm = 'true'
        end
        if meleeact then
            isml = 'true'
        end
        if iscombat then
            iscmb = 'true'
        end
        if getclip == GetHashKey(V_Stam.TiredClipSet) then
            str = 'true'
        end
        if stam == 100 then
            stamd = '100'
        end
        DrawTxt(floatValues.x, floatValues.y, floatValues.width, floatValues.height, floatValues.scale, '[~r~DEBUG~s~] Stamina: ~b~' .. stamd .. '%~s~ | ClipSet: ~b~' .. getclip .. '~s~ | Clip Enabled: ~b~' .. str, floatValues.r, floatValues.g, floatValues.b, floatValues.a)
        DrawTxt(floatValues.x, 0.6, floatValues.width, floatValues.height, floatValues.scale, 'isincombat: ' .. iscmb .. ' getmeleeact: ' .. isml .. ' isrunningm: ' .. isrunm, floatValues.r, floatValues.g, floatValues.b, floatValues.a)
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
        local IsMeleeAttack = IsPedPerformingMeleeAction(playerPed)
        local meleeact = IsPedPerformingMeleeAction(playerPed)
        local iscombat = IsPedInMeleeCombat(playerPed)
        --[[CLIPSET]]--
        if V_Stam.EnableClipSet then
            if getstam == V_Stam.StartClipSetThreshold then
                loadAnimSet(set)
                SetPedMovementClipset(playerPed, set, 1000)
            end
            if getstam >= V_Stam.ResetClipSetThreshold and getclip == GetHashKey(V_Stam.TiredClipSet)  then
                ResetPedMovementClipset(playerPed, 1000)
            end
        end
        --[[screen effects]]--
        if V_Stam.TiredEffects then
            if getstam <= V_Stam.TiredEffectsThreshold and not IsPedDeadOrDying(playerPed, true) then 
                SendNUIMessage({
                    action = 'start_effect'
                })
            elseif IsPedDeadOrDying(playerPed, true) then
                SendNUIMessage({
                    action = 'stop_effect'
                })
            end
            if getstam >= V_Stam.TiredEffectsThreshold and getstam <= V_Stam.TiredEffectsThreshold + 1 then 
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
        
        --[[Melee]]--
        if V_Stam.DrainStamOnMelee and IsMeleeAttack then
                SetPlayerStamina(player, getstam - V_Stam.DrainStamOnMeleeMultiplier)
        end
        
        if V_Stam.DisableMelee and getstam <= V_Stam.DisableMeleeThreshold then
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
        end

        local MeleeNotify = false
        if V_Stam.MeleeNotify then
            if getstam <= V_Stam.DisableMeleeThreshold and not MeleeNotify then
                if IsDisabledControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 25) or IsDisabledControlJustPressed(0, 140) or IsDisabledControlJustPressed(0, 141) or IsDisabledControlJustPressed(0, 142) then
                if V_Stam.NotifyType == "STANDALONE" and not MeleeNotify then
                ShowNotification(V_Stam.MeleeNotifyText) -- trigger notification
                MeleeNotify = true
                elseif V_Stam.NotifyType == "ESX" and not MeleeNotify then
                ESX = exports['es_extended']:getSharedObject()
                ESX.ShowNotification(V_Stam.MeleeNotifyText)
                MeleeNotify = true
                elseif V_Stam.NotifyType == "MYTHIC" then
                    if GetResourceState('mythic_notify') == 'started' and not MeleeNotify then
                            exports['mythic_notify']:DoHudText('error', V_Stam.MeleeNotifyText)
                            MeleeNotify = true
                    else
                        ShowNotification("Mythic Notify Not Found!")
                    end
                elseif V_Stam.NotifyType == "CUSTOM" and not MeleeNotify then
                    -- add your own notification system here
                end
                end
            elseif getstam > V_Stam.DisableMeleeThreshold and MeleeNotify then
                MeleeNotify = false
            end
        end

    end
end)

Citizen.CreateThread(function()
    while true do
            StatSetInt(`MP0_STAMINA`, V_Stam.StaminaSpeedUsage, true)
        Citizen.Wait(100)
    end
end)

function loadAnimSet(Animset)
	while (not HasAnimSetLoaded(Animset)) do
		RequestAnimSet(Animset)
		Citizen.Wait(5)
	end
end

local isNotificationVisible = false
local notificationText = ""
local notificationStartTime = 0
local notificationDuration = 1000


function ShowNotification(text)
    isNotificationVisible = true
    notificationText = text
    notificationStartTime = GetGameTimer()
end


Citizen.CreateThread(function()
    while V_Stam.MeleeNotify do
        Citizen.Wait(0)

        if isNotificationVisible then
            local currentTime = GetGameTimer()
            local elapsedTime = currentTime - notificationStartTime
            local getstam = GetPlayerStamina(player)
            
            local screenX, screenY = 0.5, 0.95
            local width, height = 0.2, 0.06
            local opacity = 200
            local color = {255, 0, 0}

            DrawRect(screenX, screenY, width, height, color[1], color[2], color[3], opacity)

            
            local textX, textY = 0.43, 0.93 -- adjust here to center the text in the notification if you changed it.
            local textColor = {255, 255, 255}
            local textScale = 0.4

            SetTextFont(0)
            SetTextProportional(true)
            SetTextScale(textScale, textScale)
            SetTextColour(textColor[1], textColor[2], textColor[3], opacity)
            SetTextOutline()

            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(notificationText)
            EndTextCommandDisplayText(textX, textY)

            
            if elapsedTime >= notificationDuration or getstam >= V_Stam.DisableMeleeThreshold then
                isNotificationVisible = false
            end
        end
    end
end)
