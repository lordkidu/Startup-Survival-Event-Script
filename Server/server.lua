if Config.UseOldEsx then
    ESX = nil
    
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    
        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end
    
        ESX.PlayerData = ESX.GetPlayerData()
    end)
else
    ESX = exports["es_extended"]:getSharedObject()
end


RegisterServerEvent('Startup_Caseopening')
AddEventHandler('Startup_Caseopening', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then
        for _, item in pairs(Config.ItemsOXCase) do
            if item.item ~= "money" and item.item ~= "bank" then
                xPlayer.addInventoryItem(item.item, item.amount)
            end
        end
    end
end)


RegisterServerEvent('Startup_StartPurge')
AddEventHandler('Startup_StartPurge', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then

        for _, item in pairs(Config.ItemsOXStartPurge) do
            if item.item ~= "money" and item.item ~= "bank" then
                xPlayer.addInventoryItem(item.item, item.amount)
            end
        end
    end
end)

RegisterNetEvent('purge:PreStart')
AddEventHandler('purge:PreStart', function()
    local announcementMessage = Config.NotificationMessages.purgeStarted
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0 },  
        multiline = true,
        args = { "[Purge]", announcementMessage }
    })
end)

RegisterNetEvent('purge:Start')
AddEventHandler('purge:Start', function()
    local announcementMessage = Config.NotificationMessages.purgeStarted2
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0 },  
        multiline = true,
        args = { "[Purge]", announcementMessage }
    })
end)

RegisterNetEvent("myevent:soundStatus")
AddEventHandler("myevent:soundStatus", function(type, musicId, data)
    TriggerClientEvent("myevent:soundStatus", -1, type, musicId, data)
end)

local isPurgeActiveServer = false

RegisterCommand("purge", function(source, args, rawCommand)
    print("[DEBUG] purge command triggered")  
    if IsPlayerAceAllowed(source, "purge") then
        print("[DEBUG] Permission granted for purge")  
        if not isPurgeActiveServer then
            isPurgeActiveServer = true
            TriggerClientEvent("Purge:PurgeCommand", -1)  
            print("[DEBUG] Purge command activated")
        else
            TriggerClientEvent("chatMessage", source, "^1Purge is already active.")
        end
    else
        print("[DEBUG] Insufficient permissions for purge command")
        TriggerClientEvent("chatMessage", source, "^1Insufficient Permissions.")
    end
end)
RegisterCommand("startpurge", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "purge") then
        print("[DEBUG] startpurge command received on server")  
        TriggerClientEvent("Purge:StartCommand", -1)  
        TriggerClientEvent("Purge:Drop", -1)
    else
        print("[DEBUG] Insufficient permissions for startpurge command")
        TriggerClientEvent("chatMessage", source, "^1Insufficient Permissions.")
    end
end)

RegisterCommand("endpurge", function(source, args, rawCommand)
    print("[DEBUG] endpurge command triggered")  
    if IsPlayerAceAllowed(source, "purge") then
        print("[DEBUG] Permission granted for endpurge")  
        if isPurgeActiveServer then
            isPurgeActiveServer = false
            TriggerClientEvent("Purge:EndCommand", -1)
            TriggerClientEvent("Purge:StopDropClient", -1)
    for _, playerId in ipairs(GetPlayers()) do
        for _, weapon in ipairs(Config.WeaponsToRemove) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                local weaponCount = xPlayer.getInventoryItem(weapon).count
                if weaponCount > 0 then
                    xPlayer.removeInventoryItem(weapon, weaponCount)
                end
            end
        end
    end
            print("[DEBUG] Purge has ended")
        else
            TriggerClientEvent("chatMessage", source, "^1No active purge to end.")
        end
    else
        print("[DEBUG] Insufficient permissions for endpurge")
        TriggerClientEvent("chatMessage", source, "^1Insufficient Permissions.")
    end
end)

local crateActive = false

RegisterNetEvent('crate:spawnCrate', function(position)
    if not crateActive then
        crateActive = true
        TriggerClientEvent('crate:createCrate', -1, position) 
    end
end)

RegisterNetEvent('crate:deleteCrate', function()
    crateActive = false
    TriggerClientEvent('crate:deleteCrate', -1) 
end)

RegisterServerEvent('Purge:PlayerKilledReward')
AddEventHandler('Purge:PlayerKilledReward', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then
        for _, item in pairs(Config.Itemskill) do
            if item.item ~= "money" and item.item ~= "bank" then
                xPlayer.addInventoryItem(item.item, item.amount)
            end
        end
    end
end)

RegisterNetEvent('purge:playerKilled')
AddEventHandler('purge:playerKilled', function(killerId, victimId, weaponHash, distance)
    local killerName = GetPlayerName(killerId)
    local victimName = GetPlayerName(victimId)

    local weaponName = "inconnue"
    if weaponHash then
        weaponName = GetWeaponDisplayNameFromHash(weaponHash)
    end

    local message = Config.KillLogMessage
        :gsub("{killerName}", killerName or "Inconnu")
        :gsub("{victimName}", victimName or "Inconnu")
        :gsub("{weapon}", weaponName or "Inconnue")
        :gsub("{distance}", string.format("%.2f", distance or 0))

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) 
        if err ~= 200 then
            print("Error Webhook : ", err)
        end
    end, "POST", json.encode({
        username = "Purge Kill Log",
        embeds = {
            {
                title = "Kill Log",
                description = message,
                color = 16711680
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end)

function GetWeaponDisplayNameFromHash(hash)
    local weaponNames = {
        [`weapon_heavypistol`] = "PISTOL",
        [`weapon_smg_mk2`] = "SMG",
    }
    return weaponNames[hash] or "Unknown weapon"
end

RegisterServerEvent('purge:removeWeaponFromInventory')
AddEventHandler('purge:removeWeaponFromInventory', function(weapon)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if xPlayer then
        local weaponCount = xPlayer.getInventoryItem(weapon).count
        if weaponCount > 0 then
            xPlayer.removeInventoryItem(weapon, weaponCount)
        end
    end
end)
