-- vehicles.lua
-- Fahrzeug-Spawner – Version 1.1
-- Nutzung des vorhandenen Raycast-Systems + Lösch-Feedback

local menuJustOpened = 0
local vehiclesMenuOpen = false
local deleteMessageTimer = 0

local groupIndex = 1
local vehicleIndex = 1
local focus = "group" -- group / vehicle

local vehicleGroups = {
    {
        name = "LSPD",
        models = { "police", "police2", "police3", "police4", "policeb", "policet" }
    },
    {
        name = "Sheriff",
        models = { "sheriff", "sheriff2" }
    },
    {
        name = "State / Highway",
        models = { "pranger", "riot", "riot2" }
    },
    {
        name = "FBI / Spezial",
        models = { "fbi", "fbi2" }
    },
    {
        name = "Helikopter",
        models = { "polmav" }
    }
}

local function drawText(text, x, y, scale, r, g, b)
    SetTextFont(4)
    SetTextScale(scale or 0.36, scale or 0.36)
    SetTextColour(r or 255, g or 255, b or 255, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function getNameFromList(list, index)
    if not list or #list == 0 then
        return "Keine Einträge"
    end

    return list[index] or "-"
end

local function drawSlider(title, list, index, y, isFocused)
    local name = getNameFromList(list, index)
    local prefix = isFocused and "> " or "  "

    drawText(title, 0.05, y, 0.32, 255, 215, 0)
    drawText(prefix .. "[ " .. name .. " ]", 0.05, y + 0.025, 0.36, 255, 255, 255)
end

local function spawnVehicle(model, coords, heading)
    local hash = GetHashKey(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)

    if model == "polmav" then
        SetVehicleLivery(vehicle, 2)
    end

    SetModelAsNoLongerNeeded(hash)
end

CreateThread(function()
    while true do
        Wait(0)

        if not vehiclesMenuOpen then
            goto continue
        end

        local groups = vehicleGroups
        local currentGroup = groups[groupIndex]
        local models = currentGroup.models

        if IsControlJustPressed(0, 172) then
            focus = "group"
        end

        if IsControlJustPressed(0, 173) then
            focus = "vehicle"
        end

        if IsControlJustPressed(0, 174) then
            if focus == "group" then
                groupIndex = groupIndex - 1
                if groupIndex < 1 then groupIndex = #groups end
                vehicleIndex = 1
            else
                vehicleIndex = vehicleIndex - 1
                if vehicleIndex < 1 then vehicleIndex = #models end
            end
        end

        if IsControlJustPressed(0, 175) then
            if focus == "group" then
                groupIndex = groupIndex + 1
                if groupIndex > #groups then groupIndex = 1 end
                vehicleIndex = 1
            else
                vehicleIndex = vehicleIndex + 1
                if vehicleIndex > #models then vehicleIndex = 1 end
            end
        end

        local hit, coords = Raycast.getHit(150.0)
        Raycast.drawVisual(hit, coords)

        if IsControlJustPressed(0, 38) and GetGameTimer() > menuJustOpened then
            if hit then
                local model = models[vehicleIndex]
                local heading = GetEntityHeading(PlayerPedId())

                spawnVehicle(model, coords, heading)
            end
        end

        if IsControlJustPressed(0, 178) then
            local entity = Raycast.getHitEntity(150.0)

            if entity and DoesEntityExist(entity) then
                DeleteEntity(entity)
                deleteMessageTimer = GetGameTimer() + 1500
            end
        end

        -- Menü schließen mit BACKSPACE oder F9
        if IsControlJustPressed(0, 194) or IsControlJustPressed(0, 56) then
            vehiclesMenuOpen = false
        end

        drawText("Fahrzeug-Spawner", 0.05, 0.10, 0.40, 0, 191, 255)

        drawSlider("FAHRZEUG-GRUPPE:", (function()
            local names = {}
            for i,g in ipairs(groups) do
                names[i] = g.name
            end
            return names
        end)(), groupIndex, 0.18, focus == "group")

        drawSlider("FAHRZEUGE:", models, vehicleIndex, 0.26, focus == "vehicle")

        drawText("[ENTF] Fahrzeug löschen", 0.05, 0.32, 0.34, 255, 50, 50)

        if deleteMessageTimer > GetGameTimer() then
            drawText("Fahrzeug gelöscht", 0.05, 0.36, 0.36, 255, 50, 50)
        end

        ::continue::
    end
end)

function OpenVehicleMenu()
    vehiclesMenuOpen = true
    focus = "group"
    menuJustOpened = GetGameTimer() + 300
end
-- Globale Zugriffsfunktionen für client.lua
function IsVehicleMenuOpen()
    return vehiclesMenuOpen
end

function CloseVehicleMenu()
    vehiclesMenuOpen = false
end