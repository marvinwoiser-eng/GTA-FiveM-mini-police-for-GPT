-- objects.lua (korrigiert – stabile Version)
local objectsMenuOpen = false
local menuJustOpened = 0
local deleteMessageTimer = 0
local spawnMessageTimer = 0

local groupIndex = 1
local itemIndex = 1
local focus = "group"

local objectGroups = {
    {
        name = "Absperrungen & Verkehr",
        items = {
            { name = "Absperrgitter (Work 05)", model = "prop_barrier_work05" },
            { name = "Absperrgitter (Work 06A)", model = "prop_barrier_work06a" },
            { name = "Absperrgitter (Work 06B)", model = "prop_barrier_work06b" },
            { name = "Pylone (Standard)", model = "prop_roadcone02a" },
            { name = "Pylone (Groß)", model = "prop_roadcone01a" }
        }
    },
    {
        name = "Polizei-Equipment",
        items = {
            { name = "Beweiskoffer", model = "prop_ld_case_01" },
            { name = "Klapp-Tisch", model = "prop_table_04" },
            { name = "Klapp-Stuhl", model = "prop_chair_04a" }
        }
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

local function drawSlider(title, list, index, y, isFocused)
    local prefix = isFocused and "> " or "  "
    drawText(title, 0.05, y, 0.32, 255, 215, 0)
    drawText(prefix .. "[ " .. list[index].name .. " ]", 0.05, y + 0.025, 0.36, 255, 255, 255)
end

local function spawnObject(model, coords, heading)
    local hash = GetHashKey(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    local obj = CreateObject(hash, coords.x, coords.y, coords.z, true, false, true)
    SetEntityHeading(obj, heading)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)

    SetModelAsNoLongerNeeded(hash)
end

CreateThread(function()
    while true do
        Wait(0)

        if not objectsMenuOpen then
            goto continue
        end

        if IsControlJustPressed(0, 56) then -- F9
            objectsMenuOpen = false
            Wait(50)
            goto continue
        end

        local groups = objectGroups
        local currentGroup = groups[groupIndex]
        local items = currentGroup.items

        if IsControlJustPressed(0, 172) then focus = "group" end
        if IsControlJustPressed(0, 173) then focus = "item" end

        if IsControlJustPressed(0, 174) then
            if focus == "group" then
                groupIndex = groupIndex - 1
                if groupIndex < 1 then groupIndex = #groups end
                itemIndex = 1
            else
                itemIndex = itemIndex - 1
                if itemIndex < 1 then itemIndex = #items end
            end
        end

        if IsControlJustPressed(0, 175) then
            if focus == "group" then
                groupIndex = groupIndex + 1
                if groupIndex > #groups then groupIndex = 1 end
                itemIndex = 1
            else
                itemIndex = itemIndex + 1
                if itemIndex > #items then itemIndex = 1 end
            end
        end

        local hit = false
        local coords = nil

        if Raycast and Raycast.getHit then
            hit, coords = Raycast.getHit(150.0)
            Raycast.drawVisual(hit, coords)
        end

        if IsControlJustPressed(0, 38) and GetGameTimer() > menuJustOpened then
            if hit and items[itemIndex] then
                local heading = GetEntityHeading(PlayerPedId())
                spawnObject(items[itemIndex].model, coords, heading)
                spawnMessageTimer = GetGameTimer() + 1200
            end
        end

        if IsControlJustPressed(0, 178) then
            local entity = Raycast.getHitEntity(150.0)
            if entity and DoesEntityExist(entity) then
                DeleteEntity(entity)
                deleteMessageTimer = GetGameTimer() + 1500
            end
        end

        drawText("Objekt-Spawner", 0.05, 0.10, 0.40, 0, 191, 255)
        drawSlider("OBJEKT-GRUPPE:", groups, groupIndex, 0.18, focus == "group")
        drawSlider("OBJEKTE:", items, itemIndex, 0.26, focus == "item")

        ::continue::
    end
end)

function OpenObjectMenu()
    objectsMenuOpen = true
    focus = "group"
    menuJustOpened = GetGameTimer() + 300
end

function IsObjectMenuOpen()
    return objectsMenuOpen
end

function CloseObjectMenu()
    objectsMenuOpen = false
end