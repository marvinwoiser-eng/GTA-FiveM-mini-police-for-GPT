-- npc_core.lua
local myCops = {}
local selectedCops = {}

local currentCommand = nil

local names = {
    "Müller","Schmidt","Becker","Wagner","Schulz","Hoffmann",
    "Krüger","Bauer","Richter","Klein","Wolf","Schröder","Holm",
    "Ruder","Schreiner","Schneider","Fischer","Schäfer",
    "Neumann","Hartmann","Huber","Walter","Patschi","Biene"
}

local function GetRandomName()
    return names[math.random(#names)]
end

function RegisterCop(ped)
    if not DoesEntityExist(ped) then return end
    myCops[ped] = { name = GetRandomName() }
end

function IsMyCop(ped)
    return myCops[ped] ~= nil
end

function GetCopName(ped)
    local d = myCops[ped]
    return d and d.name or nil
end

function ToggleSelectCop(ped)
    if not IsMyCop(ped) then return end

    if selectedCops[ped] then
        selectedCops[ped] = nil
    else
        selectedCops[ped] = true
    end
end

function IsCopSelected(ped)
    return selectedCops[ped] ~= nil
end

function GetSelectedCops()
    local list = {}
    for ped,_ in pairs(selectedCops) do
        if DoesEntityExist(ped) then
            table.insert(list, ped)
        else
            selectedCops[ped] = nil
        end
    end
    return list
end

function SetCommand(cmd)
    currentCommand = cmd
end

function GetCommand()
    return currentCommand
end

function GetMyCops()
    local list = {}
    for ped, data in pairs(myCops) do
        if DoesEntityExist(ped) then
            table.insert(list, { ped = ped, name = data.name })
        else
            myCops[ped] = nil
            selectedCops[ped] = nil
        end
    end
    return list
end

function TryRecruitTarget()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)

    for ped in EnumeratePeds() do
        if not IsMyCop(ped) and IsPedHuman(ped) and not IsPedAPlayer(ped) then
            local dist = #(coords - GetEntityCoords(ped))
            if dist < 3.0 then
                RegisterCop(ped)
                SetEntityAsMissionEntity(ped, true, true)
                return ped
            end
        end
    end
    return nil
end

function EnumeratePeds()
    return coroutine.wrap(function()
        local handle, ped = FindFirstPed()
        local success
        repeat
            coroutine.yield(ped)
            success, ped = FindNextPed(handle)
        until not success
        EndFindPed(handle)
    end)
end
