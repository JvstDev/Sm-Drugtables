
local target <const> = exports.ox_target
local inventory <const> = exports.ox_inventory
local objects = {}

local function pickupTable(data)
    local dict = lib.requestAnimDict("anim@gangops@facility@servers@bodysearch@")
    TaskPlayAnim(cache.ped, dict, "player_search", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
    
    local success = lib.progressBar({ duration = 2000, label = 'Picking up tabel...' })
    if not success then return end
    
    ClearPedTasks(cache.ped)

    target:removeLocalEntity(data.entity)
    DeleteObject(data.entity)
    objects[data.entity] = nil
end

local progressBar <const> = {
    duration = 4000,
    label = 'Placing table...',
    useWhileDead = false,
    canCancel = false,
    disable = { car = true, move = true },
    anim = { dict = 'weapon@w_sp_jerrycan', clip = 'discard_crouch' }
}

local targetElements <const> = {
    { label = 'Use table', icon = 'fa-solid fa-flask-vial', onSelect = function(); lib.showContext("drugsmenu") end },
    { label = 'Pickup', icon = 'fa-solid fa-flask-vial', onSelect = pickupTable }
}

local drugsContext <const> = {
    id = 'drugsmenu',
    title = 'Drug lab',
    options = { { title = 'Drug table', icon = 'fa-solid fa-flask-vial' } }
}

local function makeDrugs(index)
    local data <const> = Config[index]
    local items = {}

    for _, v in pairs(data.requiredItems) do table.insert(items, inventory:Search('count', v.name) >= v.count and {} or nil) end
    
    if #items < #data.requiredItems then return ESX.ShowNotification("Insufficient required items") end

    local weight = inventory:GetPlayerWeight()
    
    for _, v in pairs(data.requiredItems) do weight -= (inventory:Items(v.name).weight * v.count) / 1000 end

    weight += inventory:Items(data.producedItem)?.weight * data.producedItemCount
    
    if weight >= inventory:GetPlayerMaxWeight() then return ESX.ShowNotification("No inventory space for produced item") end
    
    local progress = table.clone(progressBar)
    progress.label = 'Making Drugs'
    local success = lib.progressBar(progress)
    
    if success then TriggerServerEvent("sm:makedrugs", index) end
end

AddEventHandler("onResourceStop", function(resource)
    if cache.resource == resource then 
        for obj, _ in pairs(objects) do 
            if DoesEntityExist(obj) then
                DeleteObject(obj)
            end
            objects[obj] = nil
        end
    end
end)

RegisterNetEvent('sm:spawntable', function(index)
    local data <const> = Config[index]
    if not data then return end

    local success <const> = lib.progressBar(progressBar)
    if not success then return end

    local model <const> = lib.requestModel(data.tableProp)
    local offset <const> = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.0)

    local obj <const> = CreateObject(model, offset, true) 
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    objects[obj] = true
    
    local context <const> = table.clone(drugsContext)
    context.options[1].description = data.contextDescription
    context.options[1].onSelect = function(); makeDrugs(index) end
    lib.registerContext(context)

    target:addLocalEntity(obj, targetElements)
end)