Config = {}

--[[
	All possible notification systems, choose the one you want:
		esx
		okokNotify
		renzu_notify
		mythic_notify
]]
Config.Notifications = "mythic_notify"

Config.AuctionDuration = 10 -- Duration In seconds

Config.MapBlips = {
	{
		coords = vector3(-45.9, -1093.82, 25.45),
		name = "Auction Area",
		sprite = 108,
		color = 2,
	}
}

Config.AuctionAreas = {
    {
        coords = vector3(-46.97, -1097.2, 25.45),
        radius = 7,
		heading = 66,
	},
}
