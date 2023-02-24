local cacheTimers = {}


for veh in EnumerateVehicles() do
    DeleteEntity(veh)
end


local player = {ped = nil, coords = nil, areaId = nil}

Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        player.ped = PlayerPedId()
        player.coords = GetEntityCoords(player.ped)
        
        for id, area in pairs(Config.AuctionAreas) do
            if #(player.coords - area.coords) <= area.radius then
                player.areaId = id
            end
        end 

        Citizen.Wait(sleep)
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)

    if onScreen then
        SetTextScale(0.50, 0.50)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

Citizen.CreateThread(function()
    while not player.ped or not player.coords do Citizen.Wait(1000) end

    while true do
        local sleep = 1000

        for id, area in pairs(Config.AuctionAreas) do
            local dst = #(player.coords - area.coords)

            if dst <= area.radius then
                sleep = 2

                DrawMarker(27, area.coords.x, area.coords.y, area.coords.z, 0.0,
                           0.0, 0.0, 0, 0.0, 0.0, area.radius * 2.0,
                           area.radius * 2.0, area.radius * 2.0, player.areaId == id and 0 or 255, player.areaId == id and 255, player.areaId == id and 0,
                           100, false, true, 2, false, false, false, false)

                if area.beingUsed then
                    DrawText3D(area.coords.x, area.coords.y, area.coords.z + 2, string.format("~b~Title:~w~ %s <br>~b~Value:~w~ %s€ <br> ~b~Time Left:~w~ %s", area.data.data.title, area.data.bid.value, cacheTimers[id] and cacheTimers[id] or "0"))

                    if IsControlJustReleased(0, 38) then
                        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(),
                                         'choose_bid', {
                            title = 'Make a bid'
                        }, function(bidData, bidMenu)

                            local bid = tonumber(bidData.value)

                            if bid == nil then
                                notification("info", "Info", "Invalid amount")
                            else
                                TriggerServerEvent("auction:bid", id, bid)
                                bidMenu.close()
                            end

                        end, function(bidData, bidMenu)
                            bidMenu.close()
                        end)

                    end
                else
                    DrawText3D(area.coords.x, area.coords.y, area.coords.z + 2, "Click ~b~[E]~w~ to start an auction")
                   
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent("auction:isAreaFree", id)
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

local tempSpawnedCars = {}
Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        for id, area in pairs(Config.AuctionAreas) do
            if area.beingUsed then
                local dst = #(area.coords - player.coords)

                if dst < 100 and not tempSpawnedCars[id] then
                    tempSpawnedCars[id] = true

                    ESX.Game.SpawnLocalVehicle(area.data.data.props.model,
                                               area.coords, area.heading, function(veh)
                        ESX.Game.SetVehicleProperties(veh, area.data.data.props)

                        FreezeEntityPosition(veh, true)
                        tempSpawnedCars[id] = veh
                    end)
                elseif dst > 100 and tempSpawnedCars[id] then
                    DeleteEntity(tempSpawnedCars[id])
                    tempSpawnedCars[id] = nil
                end
            elseif not area.beingUsed and tempSpawnedCars[id] then
                DeleteEntity(tempSpawnedCars[id])
                tempSpawnedCars[id] = nil
            end
        end

        Citizen.Wait(sleep)
    end
end)

function openVehicleList(areaId, list)
    ESX.UI.Menu.CloseAll()

    local elements = {}
    for id, veh in pairs(list) do
        elements[#elements + 1] = {
            label = GetDisplayNameFromVehicleModel(veh.props.model) .. "[ " .. veh.props.plate .. " ]",
            value = id
        }
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_list', {
        title = 'Pick a vehicle',
        align = 'right',
        elements = elements
    }, function(data, menu)
        menu.close()

        local chosenVehicle = data.current.value

        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'choose_title',
                         {title = 'Pick a title for the vehicle'},
                         function(titleData, titleMenu)
            if not titleData.value or #titleData.value <= 2 then
                notification("info", "Info", "That title is too small")
            else
                titleMenu.close()
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(),
                                 'choose_initialValue', {
                    title = 'Pick a initial value for the vehicle'
                }, function(initialValueData, initialValueMenu)

                    local initialValue = tonumber(initialValueData.value)

                    if initialValue == nil then
                        notification("info", "Info", "Invalid amount")
                    else
                        TriggerServerEvent("auction:claimArea", areaId,
                                           titleData.value, initialValue,
                                           list[chosenVehicle])
                        initialValueMenu.close()
                    end

                end, function(initialValueData, initialValueMenu)
                    initialValueMenu.close()
                end)
            end

        end, function(titleData, titleMenu) titleMenu.close() end)

    end, function(data, menu) menu.close() end)
end

RegisterNetEvent("auction:openVehicleList")
AddEventHandler("auction:openVehicleList", openVehicleList)

RegisterNetEvent("auction:syncAreas")
AddEventHandler("auction:syncAreas", function(AuctionAreas)
    Config.AuctionAreas = AuctionAreas
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 200
        
        if player.areaId and tempSpawnedCars[player.areaId] then
            local veh = tempSpawnedCars[player.areaId]
            
            SetEntityHeading(veh, GetEntityHeading(veh) + 0.5)
        end

        Citizen.Wait(sleep)
    end
end)



function startTimer(id, seconds)
    cacheTimers[id] = seconds
end

RegisterNetEvent("auction:timer")
AddEventHandler("auction:timer", startTimer)


Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        for id, value in pairs(cacheTimers) do
            if not Config.AuctionAreas[id] then
                table.remove(cacheTimers, id)
            else
                if (value-1) > 0 then
                    cacheTimers[id] = cacheTimers[id] - 1
                else
                    cacheTimers[id] = 0
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- Create Map Blips
Citizen.CreateThread(function()
    for id, data in pairs(Config.MapBlips) do
		local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        
        SetBlipSprite (blip, data.sprite)
        SetBlipDisplay(blip, 2)
        SetBlipScale  (blip, 1.0)
        SetBlipColour (blip, data.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end
end)