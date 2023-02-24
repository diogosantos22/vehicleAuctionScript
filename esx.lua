ESX = nil
local esxType = Config.ESX

if IsDuplicityVersion() then
    -- server


    if not esxType then
        print("invalid esx type, check Config.ESX!")
        return
    end

    if esxType == "legacy" then
        ESX = exports["es_extended"]:getSharedObject()
    else
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
else
    if esxType == "legacy" then
        ESX = exports["es_extended"]:getSharedObject()
    else
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
        end)
    end 
end