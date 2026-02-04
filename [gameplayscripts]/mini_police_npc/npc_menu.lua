-- npc_menu.lua

local menuOpen = false
local index = 1

local options = {
    "Auswahl: Folgen",
    "Team: Sammeln",
    "Auswahl: Bleib hier",
    "Team: Bleib hier",
    "Rekrutiere NPC in Nähe"
}

local NAME_SCREEN_X_OFFSET = 0.004
local NAME_HEAD_Z_OFFSET = 0.28

local function drawText2D(x, y, text, scale, rgba, center)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(rgba[1], rgba[2], rgba[3], rgba[4])
    SetTextOutline()
    if center then SetTextCentre(true) end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
    if center then SetTextCentre(false) end
end

local function drawNameAtHead(ped, name)
    local hx, hy, hz = table.unpack(GetPedBoneCoords(ped, 0x796E, 0.0, 0.0, 0.0))
    hz = hz + NAME_HEAD_Z_OFFSET
    local onScreen, sx, sy = World3dToScreen2d(hx, hy, hz)
    if not onScreen then return end
    sx = sx + NAME_SCREEN_X_OFFSET
    drawText2D(sx, sy, name, 0.30, {255,255,255,255}, true)
end

local function performRaycast()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local dir = RotationToDirection(camRot)

    local dest = vector3(
        camCoords.x + dir.x * 15.0,
        camCoords.y + dir.y * 15.0,
        camCoords.z + dir.z * 15.0
    )

    local ray = StartShapeTestRay(
        camCoords.x, camCoords.y, camCoords.z,
        dest.x, dest.y, dest.z,
        12, PlayerPedId(), 0
    )

    local _, hit, endCoords, _, entity = GetShapeTestResult(ray)
    return (hit == 1 and entity or nil), camCoords, endCoords
end

Coords, _, entity = GetShapeTestResult(ray)
    return hit == 1 and entity
end

function DrawNpcMarkers()
        drawRaycastVisual()
    for _, entry in ipairs(GetMyCops()) do
        local ped = entry.ped
        local name = entry.name

        if DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)

            local r,g,b = 0,170,255
            if IsCopSelected(ped) then
                r,g,b = 0,255,0
            end

            DrawMarker(0,
                coords.x, coords.y, coords.z + 1.2,
                0.0,0.0,0.0,
                0.0,0.0,0.0,
                0.25,0.25,0.25,
                r,g,b,180,
                false,true,2,false,nil,nil,false)

            drawNameAtHead(ped, name or "Cop")
        end
    end
end

local function drawMenu()
    SetTextFont(4)
    SetTextScale(0.42,0.42)
    SetTextColour(0,170,255,255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString("NPC Befehle")
    DrawText(0.012,0.012)

    for i,opt in ipairs(options) do
        local prefix = (i==index) and "> " or "  "
        SetTextFont(4)
        SetTextScale(0.42,0.42)
        SetTextColour(255,255,255,255)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(prefix..opt)
        DrawText(0.012,0.065+(i*0.050))
    end
end

CreateThread(function()
    while true do
        Wait(0)

        DrawNpcMarkers()
        drawRaycastVisual()

        if IsControlPressed(0, 19) and IsControlJustPressed(0, 38) then
            local ped = performRaycast()
            if ped and IsMyCop(ped) then
                if ToggleSelectCop then
                    ToggleSelectCop(ped)
                else
                    SetActiveCop(ped)
                end
            end
        end
        end

        if IsControlJustPressed(0,29) then
            menuOpen = not menuOpen
        end

        if menuOpen then
            if IsControlJustPressed(0,173) then index=index+1 end
            if IsControlJustPressed(0,172) then index=index-1 end
            if index < 1 then index = #options end
            if index > #options then index = 1 end

            if IsControlJustPressed(0,38) then
                ExecuteOption(index)
            end

            drawMenu()
        end
    end
end)

function ExecuteOption(i)
    if i == 1 then
        FollowPlayer()
    elseif i == 2 then
        GatherTeam()
    elseif i == 3 then
        StopSelectedCops()
    elseif i == 4 then
        StopAllCops()
    elseif i == 5 then
        TryRecruitTarget()
    end
end
