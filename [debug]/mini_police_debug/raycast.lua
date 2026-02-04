-- raycast.lua
-- Raycast Funktionen + visuelle Darstellung

Raycast = {}

function Raycast.getDirection()
    local rot = GetGameplayCamRot(2)
    local x = -math.sin(math.rad(rot.z)) * math.abs(math.cos(math.rad(rot.x)))
    local y = math.cos(math.rad(rot.z)) * math.abs(math.cos(math.rad(rot.x)))
    local z = math.sin(math.rad(rot.x))
    return vector3(x, y, z)
end

function Raycast.getHit(distance)
    local camPos = GetGameplayCamCoord()
    local dir = Raycast.getDirection()
    local dest = camPos + (dir * distance)

    local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, PlayerPedId(), 0)
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(ray)

    return hit, endCoords, entityHit, surfaceNormal
end

function Raycast.drawVisual(hit, coords)
    if not hit then return end

    -- Nur noch Marker am Treffpunkt (keine Linie mehr)
    DrawMarker(
        28,
        coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0.12, 0.12, 0.12,
        0, 170, 255, 180,
        false, false, 2,
        nil, nil, false
    )
end