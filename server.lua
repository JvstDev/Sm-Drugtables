
CreateThread(function()
    for name, _ in pairs(Config) do 
        ESX.RegisterUsableItem(name, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                xPlayer.removeInventoryItem(name, 1)
                TriggerClientEvent('sm:spawntable', source, name)
            end
        end)
    end
end)

RegisterServerEvent("sm:makedrugs", function(index)
    local data <const> = Config[index]

    if not data then return false end 

    local player <const> = ESX.GetPlayerFromId(source)

    if not player then return false end 

    for _, v in ipairs(data.requiredItems) do player.removeInventoryItem(v.name, v.count) end
    
    player.addInventoryItem(data.producedItem, data.producedItemCount)
    
    return true
end)