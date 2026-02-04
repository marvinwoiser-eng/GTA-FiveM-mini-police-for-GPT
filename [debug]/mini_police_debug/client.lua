-- client.lua
-- Debug System – Version 1 (korrigierte Version)

local debugActive = false
local lastValidCoords = nil
local copyMessageTimer = 0

-- Taste F10 toggelt Debug an/aus
CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, 57) then -- F10
            debugActive = not debugActive
        end
    end
end)

local function drawText(text, x, y)
    SetTextFont(4)
    SetTextScale(0.38, 0.38)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function getEntityTypeName(entity)
    if not entity or not DoesEntityExist(entity) then
        return "Keine"
    end

    if IsEntityAVehicle(entity) then
        return "Vehicle"
    elseif IsEntityAPed(entity) then
        return "Ped"
    elseif IsEntityAnObject(entity) then
        return "Object"
    else
        return "Unbekannt"
    end
end

-- Haupt Debug Thread
CreateThread(function()
    while true do
        Wait(0)

        if debugActive then
            local hit, coords, entity = Raycast.getHit(150.0)

            Raycast.drawVisual(hit, coords)

            local entityType = "Keine"
            local modelName = "Unbekannt"
            local distanceText = "-"
            local coordText = "-"

            if hit and entity and DoesEntityExist(entity) then

                entityType = getEntityTypeName(entity)

                local success, model = pcall(GetEntityModel, entity)

                if success and model then
                    modelName = tostring(model)
                end

                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - coords)

                distanceText = string.format("%.2fm", distance)

                coordText = string.format(
                    "X: %.2f  Y: %.2f  Z: %.2f",
                    coords.x, coords.y, coords.z
                )

                lastValidCoords = coords
            end

            drawText("Typ: " .. entityType, 0.02, 0.02)
            drawText("Model: " .. modelName, 0.02, 0.05)
            drawText("Distanz: " .. distanceText, 0.02, 0.08)
            drawText("Koordinaten: " .. coordText, 0.02, 0.11)

            -- Kopier-Bestätigung anzeigen
            if copyMessageTimer > GetGameTimer() then
                SetTextFont(4)
                SetTextScale(0.45, 0.45)
                SetTextColour(0, 255, 0, 255)
                SetTextEntry("STRING")
                AddTextComponentString("Koordinaten kopiert")
                DrawText(0.02, 0.14)
            end
        end
    end
end)

-- STRG + C Thread zum Kopieren der Koordinaten
CreateThread(function()
    while true do
        Wait(0)

        if debugActive then
            if IsControlPressed(0, 36) and IsControlJustPressed(0, 26) then -- STRG + C
                if lastValidCoords then

                    local text = string.format(
                        "vector3(%.2f, %.2f, %.2f)",
                        lastValidCoords.x,
                        lastValidCoords.y,
                        lastValidCoords.z
                    )

                    SendNUIMessage({
                        action = "copy",
                        text = text
                    })

                    copyMessageTimer = GetGameTimer() + 2000
                end
            end
        end
    end
end)