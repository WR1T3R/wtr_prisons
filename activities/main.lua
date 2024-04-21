local Config = require("shared.config")
local Utils = require("shared.utils")

activitiesData = {
	ped = nil,
	started = false,
	zonesCreated = {},
	completed = 0,
	toFinish = 0,
	dataInsert = {},
	firstStart = false,
	blips = {},
	entityCreated = {}
}


-- # FUNCTIONS


function initActivities()
	activitiesData.ped = Utils.createEntity(Config.activitiesPed.model, Config.activitiesPed.coords)

	local options = {
		{
			label = locale("target.activity"),
			icon = "fas fa-clipboard",
			onSelect = function()
				local info, time = lib.callback.await("wtr_prisons:server:getPlayerJailInfo", false, cache.serverId)
			
				if not info or info.canQuit then Utils.notify(locale("error.startactwithoutinjail")) return end
				if activitiesData.started then Utils.notify(locale("error.activityalreadystarted"), "error") return end

				initActivitiesMenu()
			end
		}
	}

	exports.ox_target:addLocalEntity(activitiesData.ped, options)
end

local activities = {
	[1] = {label = locale("header.electrician"), icon = "plug", func = initElectrician}
}

function initActivitiesMenu()
	local options = {}

	for i = 1, #activities do
		options[#options + 1] = {
			title = activities[i].label,
			icon = ("fas fa-%s"):format(activities[i].icon),
			onSelect = function()
				local start = initStartAct()
				if not start then return end

				activities[i].func()
				updateActivitiesTUI()
			end
		}
	end

	lib.registerContext({
		id = "wtr_prisons:activitiesMenu",
		title = locale("header.activity"),
		options = options
	})
	lib.showContext("wtr_prisons:activitiesMenu")
end

function initStartAct()
	local alert = lib.alertDialog({
		header = locale("header.activity"),
		content = locale("info.startact"),
		centered = true,
		cancel = true,
		labels = {
			cancel = locale("misc.cancel"),
			confirm = locale("misc.confirm")
		}
	})

	return alert == "confirm" and true or false
end

function updateActivitiesTUI()
	lib.showTextUI((locale("textui.actprogression")):format(activitiesData.completed, activitiesData.toFinish), {icon = "fas fa-thumbtack", iconColor = "#63959f", position = "left-center"})
end

function updateActivitiesCallback()
	for _, v in pairs(activitiesData.blips) do
		if v then 
			RemoveBlip(v)
		end
	end

	for _, v in pairs(activitiesData.zonesCreated) do
		if v then 
			exports.ox_target:removeZone(v)
		end
	end

	for _, v in pairs(activitiesData.entityCreated) do
		if v then 
			exports.ox_target:removeLocalEntity(v)
		end
	end

	if activitiesData.started then
		lib.hideTextUI()
		activitiesData.started = false
	end
	
	activitiesData.completed = 0
	activitiesData.toFinish = 0
	activitiesData.firstStart = false
	activitiesData.dataInsert = {}
	activitiesData.zonesCreated = {}
	return true
end

-- # CALLBACK

lib.callback.register("wtr_prisons:client:updateActivities", function()
	return updateActivitiesCallback()
end)

-- # EXPORTS HANDLERS


lib.callback.register("wtr_prisons:client:isInActivities", function()
	return activitiesData.started
end)

function isInActivities()
	return activitiesData.started
end
exports("IsInActivities", isInActivities)


-- # HANDLERS


AddEventHandler("onResourceStop", function(resource)
	if GetCurrentResourceName() == resource then
		if activitiesData.ped then
			DeleteEntity(activitiesData.ped)
		end

		for _, v in pairs(activitiesData.entityCreated) do
			if v then 
				DeleteEntity(v)
			end
		end

		if activitiesData.started then
			lib.hideTextUI()
		end
	end
end)