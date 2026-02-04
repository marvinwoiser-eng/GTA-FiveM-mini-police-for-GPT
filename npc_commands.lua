-- Anti-Aggro Sicherung: rekrutierte NPCs dürfen den Spieler nicht angreifen
local RECRUIT_REL_GROUP = nil
local PLAYER_REL_GROUP = GetHashKey("PLAYER")

local function EnsureRelationshipSetup()
    if RECRUIT_REL_GROUP then return end
    AddRelationshipGroup("MINI_POLICE_RECRUIT")
    RECRUIT_REL_GROUP = GetHashKey("MINI_POLICE_RECRUIT")

    -- 0 = Respect / Friendly
    SetRelationshipBetweenGroups(0, RECRUIT_REL_GROUP, PLAYER_REL_GROUP)
    SetRelationshipBetweenGroups(0, PLAYER_REL_GROUP, RECRUIT_REL_GROUP)
    SetRelationshipBetweenGroups(0, RECRUIT_REL_GROUP, RECRUIT_REL_GROUP)
end

local function ApplyRecruitSafety(ped)
    EnsureRelationshipSetup()
    SetPedRelationshipGroupHash(ped, RECRUIT_REL_GROUP)
    SetCanAttackFriendly(ped, false, false)
    SetPedCombatAttributes(ped, 46, true) -- always fight (nicht fliehen), aber nicht gegen Player wegen Relationship
    SetPedCombatAttributes(ped, 5, true)  -- can fight armed peds
    SetPedFleeAttributes(ped, 0, true)
    SetPedAsEnemy(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
end

CreateThread(function()
    while true do
        Wait(1500)
        for _, entry in ipairs(GetMyCops()) do
            local ped = type(entry) == "table" and entry.ped or entry
            if ped and DoesEntityExist(ped) then
                ApplyRecruitSafety(ped)
            end
        end
    end
end)

-- npc_commands.lua
local MIN_PLAYER_DISTANCE = 2.0
local SPRINT_START_DISTANCE = 12.0

local FOLLOW_RADIUS = 8.0
local SAFE_RADIUS = 3.0
local FOLLOW_STOP_DIST = 2.5
local UPDATE_MS = 250

local function DoFollow(ped, player, dist)
    -- No-Go Zone um den Spieler
    if dist < MIN_PLAYER_DISTANCE then
        ClearPedTasks(ped)
        return
    end

    if dist > SPRINT_START_DISTANCE then
        -- sehr weit weg -> sprinten
        TaskGoToEntity(ped, player, -1, FOLLOW_STOP_DIST, 3.9, 1073741824, 0)
    elseif dist > FOLLOW_RADIUS then
        -- mittlere Distanz -> joggen
        TaskGoToEntity(ped, player, -1, FOLLOW_STOP_DIST, 2.4, 1073741824, 0)
    else
        -- nah genug -> normal gehen
        TaskGoToEntity(ped, player, -1, FOLLOW_STOP_DIST, 1.2, 1073741824, 0)
    end
end

if dist > FOLLOW_RADIUS then
        TaskGoToEntity(ped, player, -1, FOLLOW_STOP_DIST, 3.9, 1073741824, 0)
    else
        TaskGoToEntity(ped, player, -1, FOLLOW_STOP_DIST, 1.2, 1073741824, 0)
    end
end

function FollowPlayer()
    SetCommand("follow")
end

function GatherTeam()
    SetCommand("gather")
end

function StopSelectedCops()
    for _, ped in ipairs(GetSelectedCops()) do
        if DoesEntityExist(ped) then
            ClearPedTasks(ped)
        end
    end
end

function StopAllCops()
    for _, entry in ipairs(GetMyCops()) do
        if DoesEntityExist(entry.ped) then
            ClearPedTasks(entry.ped)
        end
    end
end

CreateThread(function()
    while true do
        Wait(UPDATE_MS)

        local cmd = GetCommand()
        if not cmd then goto continue end

        local player = PlayerPedId()
        if not DoesEntityExist(player) then goto continue end

        local pCoords = GetEntityCoords(player)

        if cmd == "follow" then
            for _, ped in ipairs(GetSelectedCops()) do
                if DoesEntityExist(ped) then
                    local dist = #(pCoords - GetEntityCoords(ped))
                    DoFollow(ped, player, dist)
                end
            end

        elseif cmd == "gather" then
            for _, entry in ipairs(GetMyCops()) do
                local ped = entry.ped
                if not IsCopSelected(ped) and DoesEntityExist(ped) then
                    local dist = #(pCoords - GetEntityCoords(ped))
                    DoFollow(ped, player, dist)
                end
            end
        end

        ::continue::
    end
end)