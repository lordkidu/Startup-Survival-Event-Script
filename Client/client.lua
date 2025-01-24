
local isPurgeActive = false
local playersInPurge = {}
local redZoneBlip = nil  
local isPurgeActive2 = false


function LoadCutscene(cut, flag1, flag2)
    if (not flag1) then
      RequestCutscene(cut, 8)
    else
      RequestCutsceneEx(cut, flag1, flag2)
    end
    while (not HasThisCutsceneLoaded(cut)) do Wait(0) end
    return
  end
  
  local function BeginCutsceneWithPlayer()
    local plyrId = PlayerPedId()
    local playerClone = ClonePed_2(plyrId, 0.0, false, true, 1)
  
    SetBlockingOfNonTemporaryEvents(playerClone, true)
    SetEntityVisible(playerClone, false, false)
    SetEntityInvincible(playerClone, true)
    SetEntityCollision(playerClone, false, false)
    FreezeEntityPosition(playerClone, true)
    SetPedHelmet(playerClone, false)
    RemovePedHelmet(playerClone, true)
  
    SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
    RegisterEntityForCutscene(plyrId, 'MP_1', 0, GetEntityModel(plyrId), 64)
  
    Wait(10)
    StartCutscene(0)
    Wait(10)
    ClonePedToTarget(playerClone, plyrId)
    Wait(10)
    DeleteEntity(playerClone)
    Wait(50)
    DoScreenFadeIn(250)
  
    return playerClone
  end
  
  local function Finish(timer)
    local tripped = false
  
    repeat
      Wait(0)
      if (timer and (GetCutsceneTime() > timer))then
        DoScreenFadeOut(250)
        tripped = true
      end
  
      if (GetCutsceneTotalDuration() - GetCutsceneTime() <= 250) then
        DoScreenFadeOut(250)
        tripped = true
      end
    until not IsCutscenePlaying()
    if (not tripped) then
      DoScreenFadeOut(100)
      Wait(150)
    end
    return
  end
  
  local landAnim = {1, 2, 4}
  local timings = {
    [1] = 9100,
    [2] = 17500,
    [4] = 25400
  }
  
  function BeginLeaving(isIsland)
    if (isIsland) then
      RequestCollisionAtCoord(-2392.838, -2427.619, 43.1663)
  
      LoadCutscene('hs4_nimb_isd_lsa', 8, 24)
      BeginCutsceneWithPlayer()
      Finish()
      RemoveCutscene()
    else
      RequestCollisionAtCoord(-1652.79, -3117.5, 13.98)
  
      LoadCutscene('hs4_lsa_take_nimb2')
      BeginCutsceneWithPlayer()
  
      Finish()
      RemoveCutscene()
  
      
      end
  end
  
  function BeginLanding(isIsland)
    if (isIsland) then
      RequestCollisionAtCoord(-1652.79, -3117.5, 13.98)
      local flag = landAnim[ math.random( #landAnim ) ]
      LoadCutscene('hs4_lsa_land_nimb', flag, 24)
      BeginCutsceneWithPlayer()
      Finish(timings[flag])
      RemoveCutscene()
    else
      LoadCutscene('hs4_nimb_lsa_isd_repeat')
  
      RequestCollisionAtCoord(-2392.838, -2427.619, 43.1663)
      BeginCutsceneWithPlayer()
  
      Finish()
      RemoveCutscene()
    end
  end


local function sendNotification(message, type)
    if Config.NotificationType == "ESX" then
        SetNotificationTextEntry("STRING")
        AddTextComponentString(message)
        DrawNotification(false, true)
    elseif Config.NotificationType == "okokNotify" then
        exports['okokNotify']:Alert("Purge", message, 5000, 'info')
    end
end

local currentCrate = nil  
local crateOpened = false  
local isCrateDropActive = false  
local crateBlips = {} 

function draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local distance = Vdist(camCoords.x, camCoords.y, camCoords.z, x, y, z)
    local scale = (1 / distance) * 2

    if onScreen then
SetTextFont(4) 
SetTextProportional(1)
SetTextScale(0.0, 0.6) 
SetTextColour(255, 255, 255, 255) 
SetTextOutline() 
SetTextDropshadow(2, 0, 0, 0, 255) 
SetTextCentre(true) 
SetTextEntry("STRING")
AddTextComponentString(text)
DrawText(_x, _y)
    end
end


local function createCrate(crateModel, position)
    RequestModel(crateModel)
    while not HasModelLoaded(crateModel) do
        Wait(500)
    end


    local crate = CreateObject(GetHashKey(crateModel), position.x, position.y, position.z, true, true, true)
    FreezeEntityPosition(crate, true)
    SetEntityHeading(crate, position.w) 
    SetEntityCoordsNoOffset(crate, position.x, position.y, position.z, true, true, true)

    return crate
end


RegisterNetEvent('crate:createCrate', function(position)
    if currentCrate then
        return 
    end

    local crateModel = "prop_box_wood05a"
    currentCrate = createCrate(crateModel, position)

    local crateBlip = AddBlipForEntity(currentCrate)
    SetBlipSprite(crateBlip, 478)
    SetBlipColour(crateBlip, 46)
    SetBlipScale(crateBlip, 1.0)
    SetBlipAsShortRange(crateBlip, false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Crate")
    EndTextCommandSetBlipName(crateBlip)

    table.insert(crateBlips, crateBlip)

    Citizen.CreateThread(function()
        while currentCrate do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local crateCoords = GetEntityCoords(currentCrate)

            if Vdist(playerCoords, crateCoords) < 2.0 then
                DrawMarker(0, crateCoords.x, crateCoords.y, crateCoords.z + 0.5, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 0, 0, 255, false, true, 2, false, nil, nil, false, false, false, false, false)
                draw3DText(crateCoords.x, crateCoords.y, crateCoords.z + 1.0, Config.NotificationMessages.openCrate)

if IsControlJustReleased(1, 38) and not crateOpened then
    crateOpened = true 

    local playerPed = PlayerPedId()
    local crateCoords = GetEntityCoords(currentCrate)
    local playerCoords = GetEntityCoords(playerPed)

    local heading = GetHeadingFromVector_2d(crateCoords.x - playerCoords.x, crateCoords.y - playerCoords.y)

    SetEntityHeading(playerPed, heading)
    FreezeEntityPosition(playerPed, true)

    local function loadAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            RequestAnimDict(dict)
            Citizen.Wait(100)
        end
    end

    loadAnimDict("missexile3")
    TaskPlayAnim(playerPed, "missexile3", "ex03_dingy_search_case_a_michael", 8.0, -8.0, -1, 49, 0, false, false, false)

    Citizen.Wait(3000) 

    
    ClearPedTasks(playerPed)
    FreezeEntityPosition(playerPed, false) 

                    TriggerServerEvent('Startup_Caseopening')

                    TriggerServerEvent('crate:deleteCrate')
                end
            end
        end
    end)
end)

RegisterNetEvent('crate:deleteCrate', function()
    if currentCrate then
        for _, blip in ipairs(crateBlips) do
            RemoveBlip(blip)
        end
        crateBlips = {}
        DeleteEntity(currentCrate)
        currentCrate = nil
        crateOpened = false
    end
end)

local function startDropTimer()
    Citizen.CreateThread(function()
        Citizen.Wait(Config.CrateSpawnDelay * 1000) 
        while isCrateDropActive do
            local randomIndex = math.random(1, #Config.DropPositions)
            local randomPosition = Config.DropPositions[randomIndex]
            TriggerServerEvent('crate:spawnCrate', randomPosition)
            Citizen.Wait(Config.DropInterval * 1000)
        end
    end)
end



local function createRedZone()
    local cayoPericoZone = {
        center = vector3(5082.0, -5758.5, 0.0),
        radius = 2000.0
    }
    local zoneBlip = AddBlipForRadius(cayoPericoZone.center.x, cayoPericoZone.center.y, cayoPericoZone.center.z, cayoPericoZone.radius)
    SetBlipColour(zoneBlip, 1)
    SetBlipAlpha(zoneBlip, 128)
    SetBlipAsShortRange(zoneBlip, true)

    return zoneBlip
end

local joinCooldown = {} 

RegisterNetEvent("Purge:PurgeCommand")
AddEventHandler("Purge:PurgeCommand", function()
    if not isPurgeActive then
        isPurgeActive = true 
        Citizen.CreateThread(function()
            redZoneBlip = createRedZone()
            NetworkSetFriendlyFireOption(false)

            while isPurgeActive do
                local playerPed = PlayerPedId()
                SetCanAttackFriendly(playerPed, false, false)
                
                Citizen.Wait(1000)
            end
        end)
        TriggerServerEvent('purge:PreStart')
    else
        sendNotification(Config.NotificationMessages.purgeAlreadyActive, "error")
    end
end)


RegisterCommand('joinpurge', function()
    local playerId = PlayerId()

    if not isPurgeActive then
        sendNotification(Config.NotificationMessages.purgeNotStarted, "error")
        return
    end

    if playersInPurge[playerId] then
        sendNotification(Config.NotificationMessages.alreadyinPurge, "error")
        return
    end

    local currentTime = GetGameTimer()
    if joinCooldown[playerId] and (currentTime - joinCooldown[playerId]) < 5000 then
        local remainingTime = 5 - math.floor((currentTime - joinCooldown[playerId]) / 1000)
        sendNotification(string.format(Config.NotificationMessages.joinCooldownMessage, remainingTime), "error")
        return
    end

    local waypointBlip = GetFirstBlipInfoId(8)
    if not DoesBlipExist(waypointBlip) then
        sendNotification(Config.NotificationMessages.Setblipsmap, "error")
        return
    end

    local coord = GetBlipInfoIdCoord(waypointBlip)

    local redZoneCenter = vector3(5034.5703, -5200.0967, 2.6010) 
    local redZoneRadius = 2000.0

    local function isInRedZone(coord, center, radius)
        return Vdist(coord.x, coord.y, coord.z, center.x, center.y, center.z) <= radius
    end

    if not isInRedZone(coord, redZoneCenter, redZoneRadius) then
        sendNotification(Config.NotificationMessages.markerInRedZone, "error")
        return
    end

    playersInPurge[playerId] = true
    joinCooldown[playerId] = currentTime 
    sendNotification(Config.NotificationMessages.joinPurge, "info")

    function TeleportPlayerWithTransition(playerId, x, y, z)
        local playerPed = GetPlayerPed(playerId) 

        DoScreenFadeOut(1000) 
        while not IsScreenFadedOut() do
            Citizen.Wait(0) 
        end

        SetEntityCoords(playerPed, x, y, z, false, false, false, true)

        DoScreenFadeIn(1000) 
        while not IsScreenFadedIn() do
            Citizen.Wait(0) 
        end
    end

    if (Config.Cutscenes.enabled) then 
        BeginLeaving(IsOnIsland) 
    else 
        TeleportPlayerWithTransition(PlayerId(), 4531.9810, -4488.2256, 4.0591) 
    end

    if (Config.Cutscenes.enabled) then 
SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
        BeginLanding(IsOnIsland) 
    end

    local start = GetGameTimer()
    while IsPlayerTeleportActive() do
        if GetGameTimer() - start > 20000 then
            if IsScreenFadedOut() then
                DoScreenFadeIn(0)
            end
            return
        end
        Wait(500)
    end

    SetGameplayCamRelativePitch(0.0, 1.0)
    SetGameplayCamRelativeHeading(0.0)


    local vehicleModel = GetHashKey("winky")  
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(0)
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local vehicle = CreateVehicle(vehicleModel, playerCoords.x, playerCoords.y, playerCoords.z, GetEntityHeading(playerPed), true, false)

    local driverModel = GetHashKey("g_m_m_cartelguards_01")
    RequestModel(driverModel)
    while not HasModelLoaded(driverModel) do
        Wait(0)
    end

    local driver = CreatePed(4, driverModel, 0.0, 0.0, 0.0, GetEntityHeading(playerPed), true, false) 
    TaskWarpPedIntoVehicle(driver, vehicle, -1)


    SetEntityInvincible(driver, true)
    SetBlockingOfNonTemporaryEvents(driver, true) 

    SetEntityCoords(vehicle, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false, true)

    TaskWarpPedIntoVehicle(playerPed, vehicle, 0)

    SetDriverAbility(driver, 1.0)
    SetDriverAggressiveness(driver, 1.0)
    SetDriveTaskMaxCruiseSpeed(driver, 150.0)  
    
    if IsScreenFadedOut() then
        DoScreenFadeIn(1000)
        while not IsScreenFadedIn() do
            Wait(50)
        end
    end

    Citizen.Wait(1000) 

    TaskVehicleDriveToCoord(driver, vehicle, coord.x, coord.y, coord.z, 15.0, 0, GetEntityModel(vehicle), 786603, 1.0, true)
    sendNotification(Config.NotificationMessages.driverBringYou, "info")

    local soundUrl = "https://youtu.be/5RolNQMiE2E" 
    local soundVolume = 0.4
    exports["xsound"]:PlayUrl("PurgeDriver", soundUrl, soundVolume, false, {})

    while true do
        local driverCoords = GetEntityCoords(driver)
        local distance = Vdist(driverCoords.x, driverCoords.y, driverCoords.z, coord.x, coord.y, coord.z)

        if distance < 5.0 then 
            break
        end

        Wait(500) 
    end


while IsPedInVehicle(playerPed, vehicle, false) do
    Citizen.Wait(100) 
end


TaskVehicleDriveWander(driver, vehicle, 10.0, 786603) 

Citizen.Wait(15000)

DeleteEntity(driver)
DeleteEntity(vehicle)
end)

RegisterNetEvent("Purge:StartCommand")
AddEventHandler("Purge:StartCommand", function()
    if isPurgeActive2 then
        return
  end

    if isPurgeActive then
        isCrateDropActive = true
        isPurgeActive2 = true

        if next(playersInPurge) == nil then
            sendNotification(Config.NotificationMessages.noPlayersInPurge, "error")
            return
        end

        sendNotification(Config.NotificationMessages.purgeStarted2, "info")

local musicId = "music_id_purge"  
local link = "https://www.youtube.com/watch?v=us_0aLWOa8E&t=34s"


TriggerServerEvent("myevent:soundStatus", "play", musicId, { position = vector3(0, 0, 0), link = link })  

Citizen.CreateThread(function()
    while isPurgeActive do
        Citizen.Wait(100) 
        local pos = GetEntityCoords(PlayerPedId())
        TriggerServerEvent("myevent:soundStatus", "position", musicId, { position = pos })
    end
end)


        NetworkSetFriendlyFireOption(true)

        SetCanAttackFriendly(PlayerPedId(), true, false)

        SetWeatherTypeNow('HALLOWEEN')
        SetOverrideWeather('HALLOWEEN')
        SetWeatherTypePersist('HALLOWEEN')
        SetWeatherTypeNowPersist('HALLOWEEN')
        SetArtificialLightsState(true)
        SetArtificialLightsStateAffectsVehicles(true)
        PauseClock(true)

          AddEventHandler("gameEventTriggered", function(eventName, data)
            if not isPurgeActive then return end 

            if eventName == "CEventNetworkEntityDamage" then
                local attacker = data[1]
                local victim = data[2]

                if IsEntityAPed(attacker) and IsEntityAPed(victim) then
                    if IsPedAPlayer(attacker) and IsPedAPlayer(victim) then
                        local killerId = NetworkGetPlayerIndexFromPed(attacker)
                        local victimId = NetworkGetPlayerIndexFromPed(victim)

                        if killerId and victimId and killerId ~= victimId then
                            TriggerServerEvent("Purge:PlayerKilled", killerId, victimId) 
                        end
                    end
                end
            end
        end)
        local function GiveReward2()
            for playerId in pairs(playersInPurge) do
                local playerPed = GetPlayerPed(playerId)
                local rewardItems = Config.PurgeStart.item
                local rewardQuantitys = Config.PurgeStart.quantity
                local rewardMessages = string.format(Config.PurgeStart.message, rewardItems)

                if not Config.UseOxInventory then
                    GiveWeaponToPed(playerPed, GetHashKey(rewardItems), 100, false, true)
                else
                    TriggerServerEvent('Startup_StartPurge') 
                end

                sendNotification(rewardMessages, "info")
            end
        end

        GiveReward2() 
        startDropTimer()
    else
        sendNotification(Config.NotificationMessages.purgeNotActive, "error")
    end
end) 
local crates = {} 

RegisterNetEvent("Purge:EndCommand")
AddEventHandler("Purge:EndCommand", function()
    if isPurgeActive then
        isPurgeActive = false
        isPurgeActive2 = false
        isCrateDropActive = false
        

        if crates then
            for _, crate in ipairs(crates) do
                if DoesEntityExist(crate) then
                    DeleteEntity(crate)
                end
            end
        end
        crates = {}


        if redZoneBlip then
            RemoveBlip(redZoneBlip)
            redZoneBlip = nil
        end

        for _, blip in ipairs(crateBlips) do
            RemoveBlip(blip)
        end
        crateBlips = {}

        ClearOverrideWeather()
        SetWeatherTypeNow("EXTRASUNNY")
        PauseClock(false)
        NetworkOverrideClockTime(12, 0, 0)
        SetArtificialLightsState(false)
        SetClockTime(12, 0, 0)

        local musicId = "music_id_purge"
        TriggerServerEvent("myevent:soundStatus", "stop", musicId)  

        local musicId = "music_id_purge"
        local link = "https://www.youtube.com/watch?v=sDwnJiKzr48"

        TriggerServerEvent("myevent:soundStatus", "play", musicId, { position = vector3(0, 0, 0), link = link })

        sendNotification(Config.NotificationMessages.purgeEnded, "info")
        playersInPurge = {}
    else
        sendNotification(Config.NotificationMessages.purgeNotActive, "error")
    end
end)

xSound = exports.xsound

local musicId
local playing = false

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    musicId = "music_id_" .. PlayerPedId()  

    while true do
        Citizen.Wait(100)
        if xSound:soundExists(musicId) and playing then
            if xSound:isPlaying(musicId) then
                local pos = GetEntityCoords(PlayerPedId())  
                TriggerServerEvent("myevent:soundStatus", "position", musicId, { position = pos })
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)


RegisterNetEvent("myevent:soundStatus")
AddEventHandler("myevent:soundStatus", function(type, musicId, data)
    if type == "position" then
        if xSound:soundExists(musicId) then
            xSound:Position(musicId, data.position)
        end
    elseif type == "play" then
        xSound:PlayUrlPos(musicId, data.link, 0.5, data.position)
        xSound:Distance(musicId, 9999)  
    end
end)

RegisterNetEvent("no-perms")
AddEventHandler("no-perms", function()
    TriggerEvent("chatMessage", "[Error]", {255,0,0}, "Sorry, but you don't have permission to do this" )
end)

RegisterNetEvent("Purge:StopDropClient")
AddEventHandler("Purge:StopDropClient", function()
    isCrateDropActive = false  
end)

    RegisterNetEvent("Purge:Drop")
    AddEventHandler("Purge:Drop", function()
    isCrateDropActive = true
    startDropTimer()  
 end)

AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName == "CEventNetworkEntityDamage" and isPurgeActive then
        local victimPed = args[1] 
        local attackerPed = args[2] 

        if isPurgeActive and IsPedAPlayer(victimPed) and IsPedAPlayer(attackerPed) then
            TriggerServerEvent('Purge:PlayerKilled', GetPlayerServerId(NetworkGetPlayerIndexFromPed(attackerPed)), GetPlayerServerId(NetworkGetPlayerIndexFromPed(victimPed)))
            TriggerServerEvent('Purge:PlayerKilledReward')
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)  
        
        if not isPurgeActive then
            local playerPed = PlayerPedId()

            for _, weapon in ipairs(Config.WeaponsToRemove) do
                if HasPedGotWeapon(playerPed, GetHashKey(weapon), false) then

                    RemoveWeaponFromPed(playerPed, GetHashKey(weapon))
                    
                    TriggerServerEvent('purge:removeWeaponFromInventory', weapon)
                end
            end
        end
    end
end)

