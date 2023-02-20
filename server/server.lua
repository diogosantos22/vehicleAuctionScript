ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent("auction:isAreaFree")
AddEventHandler("auction:isAreaFree", function(id)
    local src = source

    if not Config.AuctionAreas[id] then
        logs.cheater(src)
        return
    end

    local area = Config.AuctionAreas[id]

    if area.beingUsed then
        notification(src, "info", "Info", "Area is being used")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll(
        "SELECT * FROM owned_vehicles WHERE owner = @identifier",
        {["@identifier"] = xPlayer.identifier}, function(result)
            if #result > 0 then
                local list = {}

                for vehId, veh in pairs(result) do
                    list[#list + 1] = {
                        props = json.decode(veh.vehicle),
                        name = veh.vehiclename,
                        plate = veh.plate
                    }
                end

                TriggerClientEvent("auction:openVehicleList", src, id, list)
            else
                notification(src, "info", "Information", "You dont have any cars")
            end
        end)
end)

RegisterServerEvent("auction:claimArea")
AddEventHandler("auction:claimArea", function(id, title, initialValue, data)
    local src = source

    if not Config.AuctionAreas[id] then
        logs.cheater(src)
        return
    end

    local area = Config.AuctionAreas[id]

    if area.beingUsed then
        notification(src, "error", "Error", "Area is already being")
        return
    end

    area.beingUsed = true
    area.data = {}
    area.data.player = src

    area.data.bid = {}
    area.data.bid.player = src
    area.data.bid.value = initialValue
    area.data.bid.oldPlayers = {}
    area.data.bid.uniquePlayers = {
        [src] = true,
    }

    area.data.data = {title = title, props = data.props}

    TriggerClientEvent("auction:timer", -1, id, Config.AuctionDuration)
    TriggerClientEvent("auction:syncAreas", src, Config.AuctionAreas)

    SetTimeout(Config.AuctionDuration * 1000, function()
        local area = Config.AuctionAreas[id]

        if area.data.player == area.data.bid.player then
            notification(area.data.player, "info", "Information", "No one bid")
            logs.noBid(src, area.data.data.props.plate)

            area.beingUsed = false

            area.data.player = nil

            area.data.bid.player = nil
            area.data.bid.value = nil
            area.data.bid.oldPlayers = {}
            area.data.bid.uniquePlayers = {}

            area.data.data = nil

            TriggerClientEvent("auction:syncAreas", src, Config.AuctionAreas)
            return
        end

        local oldOwner = ESX.GetPlayerFromId(area.data.player)
        local newOwner = ESX.GetPlayerFromId(area.data.bid.player)

        if newOwner.getAccount("bank").money < area.data.bid.value then
            for tid, data in pairs(area.data.bid.uniquePlayers) do
                notification(tid, "info", "Info", "The highest bidder didn't have the money in the bank")
            end
           
            return
        end

        newOwner.removeAccountMoney("bank", area.data.bid.value)
        oldOwner.addAccountMoney("bank", area.data.bid.value)

        MySQL.Async.fetchAll(
            "UPDATE owned_vehicles SET owner = @owner WHERE plate = @plate", {
                ["@owner"] = newOwner.identifier,
                ["@plate"] = area.data.data.props.plate
            }, function(result) end)

       
        local text = string.format("Someone bought %s for %s€", area.data.data.title, area.data.bid.value)
        for tid, data in pairs(area.data.bid.uniquePlayers) do
            notification(tid, "info", "Info", text)
        end

        logs.wonBid(src, area.data.data.props.plate, area.data.bid.value)

        area.beingUsed = false
        area.data.player = nil
        area.data.bid.player = nil
        area.data.bid.value = nil
        area.data.bid.oldPlayers = {}
        area.data.bid.uniquePlayers = {}

        area.data.data = nil
        

        TriggerClientEvent("auction:syncAreas", src, Config.AuctionAreas)
    end)
end)

RegisterServerEvent("auction:bid")
AddEventHandler("auction:bid", function(id, money)
    local src = source

    if not Config.AuctionAreas[id] then
        logs.cheater(src)
        return
    end

    local area = Config.AuctionAreas[id]

    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.getAccount("bank").money < money then
        notification(src, "error", "No money", "You dont have that amount of money")
        return
    end

    if area.data.bid.value < money then
        area.data.bid.oldPlayers[#area.data.bid.oldPlayers + 1] = {
            id = area.data.bid.player,
            value = area.data.bid.value
        }

        area.data.bid.value = money
        area.data.bid.player = src

        TriggerClientEvent("auction:syncAreas", -1, Config.AuctionAreas)

        for tid, data in pairs(area.data.bid.uniquePlayers) do
            notification(tid, "info", "Info", "Someone just bid " .. money .. "€")
        end

        area.data.bid.uniquePlayers[src] = true
        logs.bid(src, area.data.data.props.plate, money)
    else
        notification(src, "error", "Invalid Value", "That value is to low")
    end
end)
