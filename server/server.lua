local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem(Config.ItemName , function(source, item)
    TriggerClientEvent('qw-darkmarket:client:openTablet', source)
end)

RegisterNetEvent('qw-darkmarket:server:buyItem', function(item, price)

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not Config.Items[item] then
        DropPlayer(src, 'Attempted Exploit Abuse (DarkMarket)')
    end

    if Config.Items[item].price ~= price then 
        DropPlayer(src, 'Attempted Exploit Abuse (DarkMarket)')
    end

    if not Player.Functions.RemoveMoney("cash", price, "darkmarket-buy-item") then
        return TriggerClientEvent('QBCore:Notify', src, 'You do not have enough cash to purchase this item', 'error')
    end

    if not Player.Functions.AddItem(item, 1, nil, {}) then return end
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
end)