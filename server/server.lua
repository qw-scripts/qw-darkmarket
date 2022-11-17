local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem(Config.ItemName, function(source, item)
    TriggerClientEvent('qw-darkmarket:client:openMarket', source)
end)

QBCore.Functions.CreateCallback('qw-darkmarket:server:buyItem', function(source, cb, price) 

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not Player.Functions.RemoveMoney("cash", price, "darkmarket-buy-item") then
        return cb(false)
    else
        return cb(true)
    end

end)

RegisterNetEvent('qw-darkmarket:server:pickupItem', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not Player.Functions.AddItem(item, 1, nil, {}) then return end
    TriggerClientEvent('inventory:client:ItemBox', src,
                       QBCore.Shared.Items[item], 'add')
end)
