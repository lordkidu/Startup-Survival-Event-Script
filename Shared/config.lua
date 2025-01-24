Config = {}

-- Discord Webhook for Kill Logs
Config.DiscordWebhook = "https://discord.com/api/webhooks/1135001918469582939/q2ThZ1g3Ourru3AZ3Xwbb3Kh_K19lGcJPXL_7RTtuGOdEgi0q7ALpTmS6RE_Vg5565SS"
Config.KillLogMessage = "**{killerName}** eliminated **{victimName}** using **{weapon}** from a distance of {distance} meters."

-- Notification System Configuration
Config.NotificationType = "okokNotify"  -- Choose between "ESX" or "okokNotify"

-- Drop Positions for Crates
Config.DropPositions = {
    vector4(5430.5732, -5450.2642, 39.86197, 215.433),
    vector4(4504.536, -4554.686, 3.162988, 14.17322),
    vector4(4436.848, -4445.816, 3.331568, 198.4252),
    vector4(4986.83, -5877.468, 19.54105, 34.01574),
    vector4(5265.324, -5420.782, 64.59743, 238.1102),
    vector4(4924.312, -5244.146, 1.528588, 34.01574),
    vector4(5062.43, -4590.566, 1.865625, 257.9528),
    vector4(4890.198, -4926.000, 2.371118, 294.08032)
}

-- Cutscene Configuration
Config.Cutscenes = {
    enabled = true
}

-- Timing Configuration
Config.CrateSpawnDelay = 10  -- Delay in seconds before crates spawn
Config.DropInterval = 30     -- Interval in seconds between crate drops

-- Inventory Settings (OX Inventory)
Config.UseOxInventory = true

-- Rewards for OX Inventory
Config.ItemsOXCase = { 
    {item = "weapon_smg_mk2", amount = 1},
    {item = "ammo-9", amount = 200}
}

Config.ItemsOXStartPurge = { 
    {item = "weapon_heavypistol", amount = 1},
    {item = "ammo-45", amount = 100}
}

Config.Itemskill = { 
    {item = "money", amount = 100}
}

-- Rewards for Non-OX Inventory
Config.reward = {
    item = "weapon_heavypistol",       -- Replace with desired item name
    quantity = 1,                 -- Quantity of the item
    message = "You have received your rewards!"  -- Notification message
}

Config.PurgeStart = {
    item = "weapon_smg_mk2",       -- Replace with desired item name
    quantity = 1,                 -- Quantity of the item
    message = "You have received your rewards!"  -- Notification message
}

-- Weapons to Remove After Purge
Config.WeaponsToRemove = {
    "weapon_heavypistol",
    "ammo-9",
    "ammo-45",
    "weapon_smg_mk2"
}

-- Notification Messages
Config.NotificationMessages = {
    joinPurge = "You have joined the purge!",
    alreadyinPurge = "You are already in the purge!",
    noPlayersInPurge = "No one has joined the purge.",
    purgeNotActive = "No purge is active.",
    purgeAlreadyActive = "The purge is already active.",
    purgeStarted2 = "The purge starts now!",
    purgeEnded = "The purge has ended.",
    purgeNotStarted = "The purge hasn't started yet.",
    purgeStarted = "The purge is about to start! Use /joinpurge to participate.",
    openCrate = "[E] Open The Crate",
    Setblipsmap = "Please set a point on the map.",
    joinCooldownMessage = "Please wait %d seconds before joining the purge.",
    markerInRedZone = "The selected point must be inside the red zone.",
    driverBringYou = "The driver is taking you to the selected point."
}
