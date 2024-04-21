local Config = require("shared.config")
local QBCore = exports["qb-core"]:GetCoreObject()
local Utils = require("shared.utils")

jailbreakData = {
	started = false,
	zone = nil
}


-- # Functions


function initJailbreak()
	for i = 1, #Config.jailbreak.places do
		local places = Config.jailbreak.places

		places[i].options = {
			{
				label = locale("target.jailbreakstart"),
				debug = Config.debug,
				icon = "fas fa-paper-plane",
				onSelect = function()
					initBreakout()
				end,
				canInteract = function()
					local info, time = lib.callback.await("wtr_prisons:server:getPlayerJailInfo", false, cache.serverId)
			
					return info and not info.canQuit
				end
			}
		}
		exports.ox_target:addBoxZone(places[i])
	end
end

function initBreakout()
	local itemNeed = #Config.jailbreak.itemsNeeded
	local itemsHad = 0
	local props = nil
	local success
	for i = 1, #Config.jailbreak.itemsNeeded do
		local data = Config.jailbreak.itemsNeeded

		if exports.ox_inventory:GetItemCount(data[i].item) >= data[i].amount then
			itemsHad += 1
		end
	end
	if itemNeed ~= itemsHad then Utils.notify(locale("error.noitemsjailbreak"), "error") return end


	if Config.jailbreak.skillCheck.active then
		success = lib.skillCheck(Config.jailbreak.skillCheck.difficulty, Config.jailbreak.skillCheck.inputs)
	else
		success = true
	end
	if not success then return end
	
	local coords = GetEntityCoords(cache.ped)
	lib.requestModel(joaat("prop_tool_pickaxe"))

	props = CreateObject(joaat("prop_tool_pickaxe"), coords.x, coords.y, coords.z,  true,  true, true)
	AttachEntityToEntity(props, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.09, -0.53, -0.22, 252.0, 180.0, 0.0, true, true, false, true, 1, true)

	Config.policeAlerts()
	if lib.progressCircle({
		duration = 5000,
		label = locale("progressbar.jailbreak"),
		useWhileDead = false,
		canCancel = true,
		disable = {
			move = true,
			car = true,
			mouse = false,
			combat = true,
		},
		anim = {
			dict = "amb@world_human_hammering@male@base",
			clip = "base"
		}
	}) 
	then 
		jailbreakData.started = true
		DeleteEntity(props) 
		props = nil
		DoScreenFadeOut(300)
		Wait(1000)
		SetEntityCoords(cache.ped, Config.jailbreak.leaveCoords.firstPhase, false, false, false, true)
		SetEntityHeading(cache.ped, Config.jailbreak.leaveCoords.firstPhase.w)
		Wait(500)
		DoScreenFadeIn(3000)

		jailbreakData.zone = exports.ox_target:addSphereZone({
			coords = Config.jailbreak.leaveCoords.secondPhase,
			radius = 0.8,
			options = {
				{
					label = locale("target.jailbreakout"),
					icon = "fas fa-circle-check",
					onSelect = function()
						initFinalPhase()
					end
				}
			}
		})
	else
		DeleteEntity(props) 
		props = nil
	end
end 

function initFinalPhase()
	SetEntityCoords(cache.ped, Config.jailbreak.leaveCoords.thirdPhase, false, false, false, true)
	SetEntityHeading(cache.ped, Config.jailbreak.leaveCoords.thirdPhase.w)
	exports.ox_target:removeZone(jailbreakData.zone)
	lib.callback.await("wtr_prisons:server:jailbreakSuccess", false)

	jailbreakData.started = false
	jailbreakData.zone = nil
end

-- # Callback


-- # Exports handlers


lib.callback.register("wtr_prisons:client:isInJailbreak", function()
	return jailbreakData.started
end)

function isInJailbreak()
	return jailbreakData.started
end
exports("IsInJailbreak", isInJailbreak)


-- # Handlers


CreateThread(function()
	while not LocalPlayer.state.isLoggedIn do Wait(3000) end

	initJailbreak()
end)