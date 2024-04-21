local Config = require("shared.config")
local Utils = require("shared.utils")

function initLoottables()
	for i = 1, #Config.loottables.places do

		local options = {
			coords = Config.loottables.places[i],
			radius = 0.6,
			options = {
				{
					label = locale("target.loottables"),
					icon = "fas fa-dumpster",
					onSelect = function()
						attemptSearchDumpster(i)
					end
				}
			}
		}
		exports.ox_target:addSphereZone(options)
	end
end

function attemptSearchDumpster(i)
	local isLooted = isPlaceLooted(i)

	if isLooted then Utils.notify(locale("error.alreadylooted"), "error") return end

	local chance = math.random(1, 10)
	
	if chance <= (Config.loottables.chance / 10) then
		local randomItem = Config.loottables.itemsLoottables[math.random(1, #Config.loottables.itemsLoottables)]

		lib.callback.await("wtr_prisons:server:updateLoottables", false, i)
		lib.callback.await("wtr_prisons:server:setupItems", false, "give", randomItem, 1, nil, nil)
	end
end

function isPlaceLooted(id)
	local isLooted = lib.callback.await("wtr_prisons:server:getLoottables", false)

	if not isLooted or #isLooted == 0 then return false end
	for _, val in pairs(isLooted) do
		for _, num in pairs(val) do
			if num == id then
				return true
			end
		end
	end

	return false
end