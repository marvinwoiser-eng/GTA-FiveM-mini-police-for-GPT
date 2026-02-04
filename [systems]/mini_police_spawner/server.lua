local saveFile = "custom_spawnpoints.json"

local function load()
    local file = LoadResourceFile(GetCurrentResourceName(), saveFile)
    if file then
        return json.decode(file) or {}
    end
    return {}
end

local function save(data)
    SaveResourceFile(GetCurrentResourceName(), saveFile, json.encode(data), -1)
end

local customSpawns = load()

RegisterNetEvent("police_tools:deleteSpawn", function(index)
    local src = source

    if customSpawns[index] then
        table.remove(customSpawns, index)
        save(customSpawns)

        TriggerClientEvent("police_tools:updateSpawns", -1, customSpawns)
    end
end)

RegisterNetEvent("police_tools:saveSpawn", function(x, y, z)
    local src = source

    table.insert(customSpawns, {
        name = "Custom Spawn " .. (#customSpawns + 1),
        x = x,
        y = y,
        z = z
    })

    save(customSpawns)

    TriggerClientEvent("police_tools:updateSpawns", -1, customSpawns)
end)

RegisterNetEvent("police_tools:requestSpawns", function()
    local src = source
    TriggerClientEvent("police_tools:updateSpawns", src, customSpawns)
end)
