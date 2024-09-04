local webhookURL = Config.WebhookURL

-- Function to send log messages to Discord webhook
function sendDiscordLog(message)
    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
        content = message
    }), { ['Content-Type'] = 'application/json' })
end

-- Event handler for player disconnection
AddEventHandler('playerDropped', function(reason)
    local source = source
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    local identifiers = GetPlayerIdentifiers(source)
    local discord, steamHex
    local playerName = GetPlayerName(source)

    for _, id in ipairs(identifiers) do
        if string.find(id, "discord:") then
            discord = id
        elseif string.find(id, "steam:") then
            steamHex = id
        end
    end

    local formattedReason
    if string.find(reason, "crashed") then
        formattedReason = "Crashed"
    elseif string.find(reason, "kicked") then
        formattedReason = "Kicked"
    else
        formattedReason = "Quit"
    end

    if discord and steamHex then
        TriggerClientEvent('elk:showLeaveMarker', -1, coords, discord, steamHex, playerName, formattedReason)
        local logMessage = string.format("Player %s has left the server at coordinates (%.2f, %.2f, %.2f) with reason: %s",
                                         playerName, coords.x, coords.y, coords.z, formattedReason)
        sendDiscordLog(logMessage)
    else
        print("Discord or Steam ID not found for player " .. playerName)
    end
end)
