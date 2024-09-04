local markers = {}

-- Load config values
local distanceThreshold = Config.DistanceThreshold
local markerDuration = Config.MarkerDuration
local webhookURL = Config.WebhookURL

-- Function to send log messages to Discord webhook
function sendDiscordLog(message)
    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
        content = message
    }), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent('elk:showLeaveMarker')
AddEventHandler('elk:showLeaveMarker', function(coords, discord, steamHex, playerName, reason)
    if coords and discord and steamHex and playerName then
        table.insert(markers, {
            coords = coords,
            discord = discord,
            steamHex = steamHex,
            playerName = playerName,
            reason = reason,
            timestamp = GetGameTimer()
        })
        local logMessage = string.format("Marker placed for %s at coordinates (%.2f, %.2f, %.2f)", 
                                         playerName, coords.x, coords.y, coords.z)
        sendDiscordLog(logMessage)
    else
        print("Error: Missing required data for marker.")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local currentTime = GetGameTimer()

        for i = #markers, 1, -1 do
            local marker = markers[i]
            local markerDistance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, marker.coords.x, marker.coords.y, marker.coords.z)

            if currentTime - marker.timestamp > markerDuration or markerDistance > distanceThreshold then
                table.remove(markers, i)
                lib.hideTextUI()
            else
                DrawMarker(Config.MarkerType, marker.coords.x, marker.coords.y, marker.coords.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, false, true, 2, nil, nil, false)

                if markerDistance <= 2.0 then
                    lib.showTextUI("[E] - Copy Info", {
                        position = 'right-center'
                    })

                    if IsControlJustReleased(0, 38) then
                        local info = "Player Name: " .. marker.playerName .. " | \n" ..
                                     "Player Discord: " .. marker.discord .. " | \n" ..
                                     "Player Steam: " .. marker.steamHex .. " | \n" ..
                                     "Reason: " .. marker.reason
                        CopyToClipboard(info)
                        lib.notify({
                            title = "Success",
                            description = "Player info copied to clipboard!",
                            type = "success",
                            position = 'top-center'
                        })
                        lib.hideTextUI()
                    end
                else
                    lib.hideTextUI()
                end
            end
        end
    end
end)

function CopyToClipboard(text)
    SendNUIMessage({
        action = 'copy',
        text = text
    })
end
