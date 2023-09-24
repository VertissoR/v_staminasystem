V_Stam = {}

V_Stam.debug = false -- [default: false] if true, will show debug info on screen

--[[Stamina settings]]--
V_Stam.MaxStamina = 100.0 -- [default: 100.0] ranges from 0 to 100
V_Stam.StaminaSpeedUsage = 50 -- [default GTA: 25] ranges from 0 to 100 (more = longer endurance [100 = infinite])

--[[Clipset Settings]]--
V_Stam.EnableClipSet = true -- [default: true] if true, will play the tired animation when stamina reaches the threshold
V_Stam.TiredClipSet = 'move_m@depressed@a' -- [default: 'move_m@depressed@a'] The tired animation to play when the threshold is reached
V_Stam.StartClipSetThreshold = 0 -- [default: 0] At how much stamina to start the tired animation
V_Stam.ResetClipSetThreshold = 25 -- [default: 25]

--[[Tired Effects]]--
V_Stam.TiredEffects = true -- [default: true] The effect around the screen
V_Stam.TiredEffectsThreshold = 25 -- [default: 25]

V_Stam.TiredShakeEffect = true -- [default: true] Shake effect when StartClipSetThreshold is reached
V_Stam.TiredShakeIntensity = 0.05 -- [default: 0.05] Shake intensity

--[[Other nice features]]--
V_Stam.DisableJumping = true -- [default: true] if true, player will not be able to jump when stamina reaches the threshold (affects climbing too)
V_Stam.DisableJumpingThreshold = 10 -- [default: 10] set to -1 to disable jumping until the clipset stops playing

V_Stam.DrainStamOnJumping = true -- [default: true] If true, stamina will drain when jumping (which doesn't happen in default GTA and seems like a good feature to me to prevent the jump + X bug)
V_Stam.DrainStamOnJumpingMultiplier = 0.5 -- [default: 0.5] This seems optimal to me, adjust to your liking. (Value of 1.0 drains about 30% of the stamina every jump.)

V_Stam.DrainStamOnClimbing = true -- [default: true] If true, stamina will drain when climbing obstacles (also ladders)
V_Stam.DrainStamOnClimbingMultiplier = 0.2 -- [default: 0.2]

V_Stam.DrainStamOnMelee = true -- [default: true] If true, stamina will drain when melee attacking
V_Stam.DrainStamOnMeleeMultiplier = 0.1 -- [default: 0.1]
V_Stam.DisableMelee = true -- [default: true] if true, player will not be able to melee when stamina reaches the threshold
V_Stam.DisableMeleeThreshold = 5 -- [default: 5]

V_Stam.MeleeNotify = false -- [default: true] if true, will show a notification when player is too tired to fight and tries to
V_Stam.NotifyType = "STANDALONE" -- [default: 'STANDALONE'] Options: 'STANDALONE', 'ESX', 'MYTHIC', "CUSTOM", to add own notification, use "CUSTOM" and add it on line 171 in the cl_stam.lua
V_Stam.MeleeNotifyText = 'You are too tired to fight!' -- [default: 'You are too tired to fight!'] The text to show when player is too tired to fight,
-- if you're using "STANDALONE" Notify system and will change the text, be ready to play with it's coordinates in cl_stam/cl_stam.lua (line 225) since it's not the default fivem notification. and it may not be centered
