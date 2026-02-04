Raycast = {}

function Raycast.getHit(distance)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()

    local direction = vector3(
        -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
        math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
        math.sin(math.rad(camRot.x))
    )

    local dest = camPos + direction * distance

    local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z,
        dest.x, dest.y, dest.z, -1, PlayerPedId(), 0)

    local _, hit, coords = GetShapeTestResult(ray)

    return hit == 1, coords
end

function Raycast.drawVisual(hit, coords)
    if hit then
        DrawMarker(
            28,
            coords.x, coords.y, coords.z + 0.02,
            0, 0, 0,
            0, 0, 0,
            0.15, 0.15, 0.15,
            0, 150, 255, 200,
            false, false, 2, false, nil, nil, false
        )
    end
end

function Raycast.getHitEntity(distance)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()

    local direction = vector3(
        -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
        math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
        math.sin(math.rad(camRot.x))
    )

    local dest = camPos + direction * distance

    local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z,
        dest.x, dest.y, dest.z, -1, PlayerPedId(), 0)

    local _, hit, _, _, entity = GetShapeTestResult(ray)

    if hit == 1 then
        return entity
    end

    return 0
end