
function SafeSafeDeleteEntity(ent)
    if not DoesEntityExist(ent) then return end

    NetworkRequestControlOfEntity(ent)
    local timeout = 0

    while not NetworkHasControlOfEntity(ent) and timeout < 1000 do
        Citizen.Wait(10)
        timeout = timeout + 10
        NetworkRequestControlOfEntity(ent)
    end

    SetEntityAsMissionEntity(ent, true, true)
    SafeDeleteEntity(ent)
    DeleteObject(ent)
    DeleteVehicle(ent)
end

-- client.lua (mini_police_spawner)
-- Version 8.1 – Syntaxfix + stabiles F9 Handling

local menuOpen = false

local mainIndex = 1
local focusMenu = "main" -- main / spawnpoints

local defaultIndex = 1
local customIndex = 1
local focus = "create"

local customSpawns = {}
local saveMessageTimer = 0
local deleteMessageTimer = 0

local defaultSpawnpoints = {
    { name = "Mission Row Police Station - Front", coords = vector3(425.1, -979.5, 30.7) },
    { name = "Mission Row Police Station - Garage", coords = vector3(454.0, -1020.0, 28.4) },
    { name = "Vespucci Police Station", coords = vector3(-1093.5, -809.9, 19.3) },
    { name = "Vespucci Helipad", coords = vector3(-1108.0, -833.8, 37.7) },
    { name = "Davis Police Station", coords = vector3(377.75, -1564.97, 28.39) },
    { name = "Sandy Shores Sheriff Station", coords = vector3(1853.2, 3687.1, 34.2) },
    { name = "Paleto Bay Sheriff Station", coords = vector3(-446.0, 6012.6, 31.7) }
}

RegisterNetEvent("police_tools:updateSpawns")
AddEventHandler("police_tools:updateSpawns", function(data)
    customSpawns = data or {}
    if customIndex > #customSpawns then
        customIndex = math.max(1, #customSpawns)
    end
end)

CreateThread(function()
    TriggerServerEvent("police_tools:requestSpawns")
end)

local function drawText(text, x, y, scale, r, g, b)
    SetTextFont(4)
    SetTextScale(scale or 0.36, scale or 0.36)
    SetTextColour(r or 255, g or 255, b or 255, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function teleport(coords)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
end

local function getNameFromList(list, index)
    if not list or #list == 0 then
        return "Keine Einträge"
    end
    if list[index] and list[index].name then
        return list[index].name
    end
    return "-"
end

local function drawSlider(title, list, index, y, isFocused)
    local name = getNameFromList(list, index)
    local prefix = isFocused and "> " or "  "

    drawText(title, 0.05, y, 0.32, 255, 215, 0)
    drawText(prefix .. "[ " .. name .. " ]", 0.05, y + 0.025, 0.36, 255, 255, 255)
end

CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, 56) then -- F9
            if IsVehicleMenuOpen and IsVehicleMenuOpen() then
                CloseVehicleMenu()
                goto continue
            end
            if IsObjectMenuOpen and IsObjectMenuOpen() then
                CloseObjectMenu()
                goto continue
            end
            if IsPedMenuOpen and IsPedMenuOpen() then
                ClosePedMenu()
                goto continue
            end

            menuOpen = not menuOpen
            focusMenu = "main"
        end

        if not menuOpen then goto continue end

        if focusMenu == "main" then

            if IsControlJustPressed(0, 172) then
                mainIndex = mainIndex - 1
                if mainIndex < 1 then mainIndex = 4 end
            end

            if IsControlJustPressed(0, 173) then
                mainIndex = mainIndex + 1
                if mainIndex > 4 then mainIndex = 1 end
            end

            if IsControlJustPressed(0, 38) then
                if mainIndex == 1 then
                    focusMenu = "spawnpoints"
                elseif mainIndex == 2 then
                    OpenVehicleMenu()
                    menuOpen = false
                elseif mainIndex == 3 then
                    OpenObjectMenu()
                    menuOpen = false
                else
                    OpenPedMenu()
                    menuOpen = false
                end
            end

            if IsControlJustPressed(0, 194) then
                menuOpen = false
            end

            drawText("HAUPTMENÜ", 0.05, 0.10, 0.40, 0, 191, 255)

            local prefix1 = (mainIndex == 1) and "> " or "  "
            local prefix2 = (mainIndex == 2) and "> " or "  "
            local prefix3 = (mainIndex == 3) and "> " or "  "
            local prefix4 = (mainIndex == 4) and "> " or "  "

            drawText(prefix1 .. "Spawnpoints", 0.05, 0.18, 0.36, 255, 255, 255)
            drawText(prefix2 .. "Fahrzeug-Spawner", 0.05, 0.23, 0.36, 255, 255, 255)
            drawText(prefix3 .. "Objekt-Spawner", 0.05, 0.28, 0.36, 255, 255, 255)
            drawText(prefix4 .. "Menschen/Tiere", 0.05, 0.33, 0.36, 255, 255, 255)

            goto continue
        end

        if IsControlJustPressed(0, 172) then
            if focus == "custom" then
                focus = "default"
            elseif focus == "default" then
                focus = "create"
            end
        end

        if IsControlJustPressed(0, 173) then
            if focus == "create" then
                focus = "default"
            elseif focus == "default" then
                focus = "custom"
            end
        end

        if IsControlJustPressed(0, 174) then
            if focus == "default" then
                defaultIndex = defaultIndex - 1
                if defaultIndex < 1 then
                    defaultIndex = #defaultSpawnpoints
                end
            elseif focus == "custom" then
                if #customSpawns > 0 then
                    customIndex = customIndex - 1
                    if customIndex < 1 then
                        customIndex = #customSpawns
                    end
                end
            end
        end

        if IsControlJustPressed(0, 175) then
            if focus == "default" then
                defaultIndex = defaultIndex + 1
                if defaultIndex > #defaultSpawnpoints then
                    defaultIndex = 1
                end
            elseif focus == "custom" then
                if #customSpawns > 0 then
                    customIndex = customIndex + 1
                    if customIndex > #customSpawns then
                        customIndex = 1
                    end
                end
            end
        end

        if IsControlJustPressed(0, 38) then
            if focus == "create" then
                local c = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("police_tools:saveSpawn", c.x, c.y, c.z)
                saveMessageTimer = GetGameTimer() + 1500

            elseif focus == "default" then
                teleport(defaultSpawnpoints[defaultIndex].coords)

            elseif focus == "custom" then
                if #customSpawns > 0 then
                    local sp = customSpawns[customIndex]
                    teleport(vector3(sp.x, sp.y, sp.z))
                end
            end
        end

        if IsControlJustPressed(0, 194) then
            if focus == "custom" and #customSpawns > 0 then
                TriggerServerEvent("police_tools:deleteSpawn", customIndex)
                deleteMessageTimer = GetGameTimer() + 1500
            else
                focusMenu = "main"
            end
        end

        drawText("Spawnpoints - Carousel Menu", 0.05, 0.10, 0.40, 0, 191, 255)

        local prefix = (focus == "create") and "> " or "  "
        drawText(prefix .. "Create Custom Spawn (Press E)", 0.05, 0.15, 0.36, 255, 255, 255)

        drawSlider("DEFAULT LOCATIONS:", defaultSpawnpoints, defaultIndex, 0.20, focus == "default")
        drawSlider("CUSTOM LOCATIONS:", customSpawns, customIndex, 0.28, focus == "custom")

        if saveMessageTimer > GetGameTimer() then
            drawText("Custom Spawn gespeichert", 0.05, 0.34, 0.36, 0, 255, 0)
        end

        if deleteMessageTimer > GetGameTimer() then
            drawText("Custom Spawn gelöscht", 0.05, 0.38, 0.36, 255, 50, 50)
        end

        ::continue::
    end
end)