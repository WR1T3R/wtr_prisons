local Config = require("shared.config")
local Utils = require("shared.utils")

local dealerData = {
	peds = {}
}
function initDealer()
	for i = 1, #Config.dealer.ped do
		dealerData.peds[i] = Utils.createEntity(Config.dealer.ped[i].model, Config.dealer.ped[i].coords)

		if Config.dealer.ped[i].blips.active then
			local blips = Utils.createBlip(Config.dealer.ped[i].coords, Config.dealer.ped[i].blips.sprite, Config.dealer.ped[i].blips.scale, Config.dealer.ped[i].blips.colour, locale("blips.dealer"))
		end

		local options = {
			{
				label = locale("target.dealer"),
				icon = "fas fa-person",
				onSelect = function()
					initDealerMenu()
				end
			}
		}
		exports.ox_target:addLocalEntity(dealerData.peds[i], options)
	end
end

function initDealerMenu()
	local options = {}

	for i = 1, #Config.dealer.crafts do
		options[#options + 1] = {
			title = exports.ox_inventory:Items(Config.dealer.crafts[i].item).label,
			description = Utils.getLabelDescription(Config.dealer.crafts[i].requirements),
			icon = exports.ox_inventory:Items(Config.dealer.crafts[i].item).client.image,
			onSelect = function()
				local canCraft = Utils.canCraft(Config.dealer.crafts[i].requirements)
				if not canCraft then Utils.notify(locale("error.noitemsdealer"), "error") return end

				for k = 1, #Config.dealer.crafts[i].requirements do
					local requirements = Config.dealer.crafts[i].requirements[k]

					lib.callback.await("wtr_prisons:server:setupItems", false, "remove", requirements.item, requirements.amount, nil, nil)
				end

				lib.callback.await("wtr_prisons:server:setupItems", false, "give", Config.dealer.crafts[i].item, Config.dealer.crafts[i].amount, nil, nil)
			end
		} 
	end
	lib.registerContext({
		id = "wtr_prisons:dealerMenu",
		title = locale("header.dealer"),
		options = options
	})
	lib.showContext("wtr_prisons:dealerMenu")
end

AddEventHandler("onResourceStop", function(resource)
	if GetCurrentResourceName() == resource then
		for _,v in pairs(dealerData.peds) do
			if v then
				DeleteEntity(v)
			end
		end
	end
end)
