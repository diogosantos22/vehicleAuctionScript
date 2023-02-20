
if IsDuplicityVersion() then
    -- server
    local chosenOne = Config.Notifications

    local notifList = {
        ["okokNotify"] = function(src, type, title, text)
            TriggerClientEvent('okokNotify:Alert', src, title, text, 5000, type)
        end,

        ["renzu_notify"] = function(src, type, title, text)
            TriggerClientEvent('renzu_notify:Notify', src, type, title, text)
        end,

        ["mythic_notify"] = function(src, type, title, text)
            TriggerClientEvent("mythic_notify:client:SendAlert", src, {
                type = type,
                text = text,
                length = 5000,
            })
        end,

        ["esx"] = function(src, type, title, text)
            TriggerClientEvent("auction:notification", src, type, title, text)
        end,
    }

    function notification(src, type, title, text)

        if not notifList[chosenOne] then
            print("invalid notification config, check Config.Notifications!")
            return
        end

        notifList[chosenOne](src, type, title, text)
    end

else
    -- client

    local chosenOne = Config.Notifications

    local notifList = {
        ["okokNotify"] = function(type, title, text)
            exports['okokNotify']:Alert(title, text, 5000, type)
        end,

        ["renzu_notify"] = function(type, title, text)
            TriggerEvent('renzu_notify:Notify', type, title, text)
        end,

        ["mythic_notify"] = function(type, title, text)
            exports['mythic_notify']:SendAlert(type, text, 5000)
        end,

        ["esx"] = function(type, title, text)
            ESX.ShowNotification(text, false, false)
        end,
    }

    function notification(type, title, text)

        if not notifList[chosenOne] then
            print("invalid notification config, check Config.Notifications!")
            return
        end

        notifList[chosenOne](type, title, text)
    end

    RegisterNetEvent("auction:notification")
    AddEventHandler("auction:notification", function(type, title, text)
        notification(chosenOne)(type, title, text)
    end)
end