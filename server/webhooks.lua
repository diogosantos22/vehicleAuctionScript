-- 

local WebHooks = {
    ["startedAuction"] = '',
    ["finishedAuction"] = '',
    ["bid"] = '',
    ["cheaters"] = '',
}

colors = {
    green 	= 56108,
    grey 	= 8421504,
    red 	= 16711680,
    orange 	= 16744192,
    blue 	= 2061822,
    purple 	= 6965387,
    pink     = 11750815,
    yellow   = 16449301,
    white    = 16777215,
    black    = 0,
    bluetweet = 4436965,
}

function sendLog(name, embed, isNormalMessage)
	if WebHooks[name] ~= nil and WebHooks[name] ~= '' then
        if isNormalMessage then
            PerformHttpRequest(WebHooks[name], function(err, text, headers) end, 'POST', json.encode({content = embed}), { ['Content-Type'] = 'application/json' })
        else
            PerformHttpRequest(WebHooks[name], function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
        end
	end
end


logs = {
    cheater = function(src)
        embeds = {
            {
                ["title"]= "Cheater (using events with a menu)",
                ["type"]= "rich",
                ["color"] = colors.red,
                ['fields']= {
                    {
                        ['name'] = "***Player***",
                        ['value'] = string.format([[ %s [ %s ] ]], GetPlayerName(src), GetPlayerIdentifier(src))
                    },
                },
                ["footer"]=  {
                    ["text"]= os.date('%A, %B %d %Y at %I:%M:%S %p'),
                },
            }
        }
    
        sendLog('cheaters', embeds)
    end,

    startedAuction = function(src, title, text, initialValue, plate)
        embeds = {
            {
                ["title"]= "Auction",
                ["type"]= "rich",
                ["color"] = colors.green,
                ['fields']= {
                    {
                        ['name'] = "***Player***",
                        ['value'] = string.format([[ %s [ %s ] ]], GetPlayerName(src), GetPlayerIdentifier(src))
                    },
                    {
                        ['name'] = "***Title***",
                        ['value'] = title
                    },
                    {
                        ['name'] = "***Initial Value***",
                        ['value'] = initialValue
                    },
                    {
                        ['name'] = "***Plate***",
                        ['value'] = plate
                    },
                },
                ["footer"]=  {
                    ["text"]= os.date('%A, %B %d %Y at %I:%M:%S %p'),
                },
            }
        }
    
        sendLog('startedAuction', embeds)
    end,

    noBid = function(src, plate)
        embeds = {
            {
                ["title"]= "Auction no bid",
                ["type"]= "rich",
                ["color"] = colors.red,
                ['fields']= {
                    {
                        ['name'] = "***Player***",
                        ['value'] = string.format([[ %s [ %s ] ]], GetPlayerName(src), GetPlayerIdentifier(src))
                    },
                    {
                        ['name'] = "***Plate***",
                        ['value'] = plate
                    },
                },
                ["footer"]=  {
                    ["text"]= os.date('%A, %B %d %Y at %I:%M:%S %p'),
                },
            }
        }
    
        sendLog('finishedAuction', embeds)
    end,

    wonBid = function(src, plate, money)
        embeds = {
            {
                ["title"]= "Auction Won bid",
                ["type"]= "rich",
                ["color"] = colors.green,
                ['fields']= {
                    {
                        ['name'] = "***Player***",
                        ['value'] = string.format([[ %s [ %s ] ]], GetPlayerName(src), GetPlayerIdentifier(src))
                    },
                    {
                        ['name'] = "***Plate***",
                        ['value'] = plate
                    },
                    {
                        ['name'] = "***Final Price***",
                        ['value'] = money
                    },
                },
                ["footer"]=  {
                    ["text"]= os.date('%A, %B %d %Y at %I:%M:%S %p'),
                },
            }
        }
    
        sendLog('finishedAuction', embeds)
    end,

    bid = function(src, plate, money)
        embeds = {
            {
                ["title"]= "Auction bid",
                ["type"]= "rich",
                ["color"] = colors.green,
                ['fields']= {
                    {
                        ['name'] = "***Player***",
                        ['value'] = string.format([[ %s [ %s ] ]], GetPlayerName(src), GetPlayerIdentifier(src))
                    },
                    {
                        ['name'] = "***Plate***",
                        ['value'] = plate
                    },
                    {
                        ['name'] = "***Money***",
                        ['value'] = money
                    },
                },
                ["footer"]=  {
                    ["text"]= os.date('%A, %B %d %Y at %I:%M:%S %p'),
                },
            }
        }
    
        sendLog('bid', embeds)
    end,
}