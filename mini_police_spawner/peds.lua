-- peds.lua – Gruppenbasierter Ped/Tier Spawner (komplett mit UI)

local pedMenuOpen = false
local menuJustOpened = 0
local deleteMessageTimer = 0
local spawnMessageTimer = 0

local groupIndex = 1
local itemIndex = 1
local focus = "group"

local pedGroups = {
    {
        name = "Polizei",
        items = {
            { name = "Polizist (m)", model = "s_m_y_cop_01" },
            { name = "Polizistin (w)", model = "s_f_y_cop_01" },
            { name = "Sheriff (m)", model = "s_m_y_sheriff_01" },
            { name = "Sheriff (w)", model = "s_f_y_sheriff_01" }
        }
    },
    {
        name = "Rettungsdienst",
        items = {
            { name = "Sanitäter", model = "s_m_m_paramedic_01" },
            { name = "Feuerwehrmann", model = "s_m_y_fireman_01" }
        }
    },
    {
        name = "Zivilisten",
        items = {
            { name = "Geschäftsmann", model = "a_m_m_business_01" },
            { name = "Strandbesucher", model = "a_f_m_beach_01" },
            { name = "Hipster", model = "a_m_y_hipster_01" },
            { name = "Touristin", model = "a_f_y_tourist_01" }
        }
    },
    {
        name = "Tiere",
        items = {
            { name = "Hund (Schäferhund)", model = "a_c_shepherd" },
            { name = "Katze", model = "a_c_cat_01" },
            { name = "Kuh", model = "a_c_cow" },
            { name = "Huhn", model = "a_c_hen" },
            { name = "Pudel", model = "a_c_poodle" }
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

local function spawnPed(model, coords)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z, 0.0, true, false)
    SetEntityAsMissionEntity(ped, true, true)

    SetModelAsNoLongerNeeded(hash)
end

CreateThread(function()
    while true do
        Wait(0)

        if not pedMenuOpen then goto continue end

        if IsControlJustPressed(0, 56) then -- F9
            pedMenuOpen = false
            Wait(50)
            goto continue
        end

        local groups = pedGroups
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

        local hit, coords = false, nil
        if Raycast and Raycast.getHit then
            hit, coords = Raycast.getHit(150.0)
            Raycast.drawVisual(hit, coords)
        end

        if IsControlJustPressed(0, 38) and GetGameTimer() > menuJustOpened then
            if hit and items[itemIndex] then
                spawnPed(items[itemIndex].model, coords)
                spawnMessageTimer = GetGameTimer() + 1200
            end
        end

        if IsControlJustPressed(0, 178) then -- ENTF
            if Raycast and Raycast.getHitEntity then
                local entity = Raycast.getHitEntity(150.0)
                if entity and DoesEntityExist(entity) then
                    DeleteEntity(entity)
                    deleteMessageTimer = GetGameTimer() + 1500
                end
            end
        end

        drawText("Menschen & Tiere", 0.05, 0.10, 0.40, 0, 191, 255)
        drawSlider("GRUPPE:", groups, groupIndex, 0.18, focus == "group")
        drawSlider("AUSWAHL:", items, itemIndex, 0.26, focus == "item")

        drawText("[E] Spawnen", 0.05, 0.32, 0.34, 255, 255, 255)
        drawText("[ENTF] Löschen", 0.05, 0.35, 0.34, 255, 50, 50)
        drawText("[F9] Schließen", 0.05, 0.38, 0.34, 255, 255, 255)

        if spawnMessageTimer > GetGameTimer() then
            drawText("Ped platziert", 0.05, 0.42, 0.36, 0, 255, 0)
        end

        if deleteMessageTimer > GetGameTimer() then
            drawText("Ped gelöscht", 0.05, 0.45, 0.36, 255, 50, 50)
        end

        ::continue::
    end
end)

function OpenPedMenu()
    pedMenuOpen = true
    focus = "group"
    menuJustOpened = GetGameTimer() + 300
end

function IsPedMenuOpen()
    return pedMenuOpen
end

function ClosePedMenu()
    pedMenuOpen = false
end
