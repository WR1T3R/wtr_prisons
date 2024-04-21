local Config = require("shared.config")
local QBCore = exports["qb-core"]:GetCoreObject()
local Utils = require("shared.utils")
local playerJob = {}
local Data = {
	checkupPed = nil,
	prisonZones = nil
}


-- # CALLBACK


lib.callback.register("wtr_prisons:client:unjailPlayer", function()
	exitPrison(true)
end)

lib.callback.register("wtr_prisons:client:enterPrison", function()
	local randomCoords = Config.spawnsCoords[math.random(1, #Config.spawnsCoords)]

	DoScreenFadeOut(1000)
	while not IsScreenFadedOut() do Wait(10) end
	SetEntityCoords(cache.ped, randomCoords)
	SetEntityHeading(cache.ped, randomCoords.w)
	DoScreenFadeIn(2500)
	Wait(500)
end)

lib.callback.register("wtr_prisons:client:openJailMenu", function()
	local playersTable = {}
	local players = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 2.0, Config.includePlayerForSendJail)

	if #players == 0 then Utils.notify(locale("error.noplayers"), "error") return end

	for i = 1, #players do
		local serverId = GetPlayerServerId(players[i].id)
		local playerData = lib.callback.await("wtr_prisons:server:getPlayerData", false, serverId)
		local name = string.format("%s %s", playerData.charinfo.firstname, playerData.charinfo.lastname)

		playersTable[#playersTable + 1] = {value = tostring(serverId), label = (locale("menu.formatplayer")):format(name, serverId)}
	end

	local input = lib.inputDialog(locale("header.jailplayer"), {  
		{type = 'select', label = locale("menu.inputplayer"), options = playersTable, description = locale("menu.descriptioninputplayer"), required = true, clearable = true},
		{type = "number", label = locale("menu.inputtime"), description = locale("menu.inputdescriptiontime"), min = 1, max = Config.maxTimeInPrison.seconds, required = true},
		{type = 'select', label = locale("menu.inputunittime"), options = {{value = 1, label = Utils.firstToUpper(locale("misc.seconds"))}, {value = 60, label = Utils.firstToUpper(locale("misc.minutes"))}, {value = 3600, label = Utils.firstToUpper(locale("misc.hours"))}}, description = locale("menu.inputdescriptionunittime"), required = true, clearable = true}
	})

	local configTime = {
		[1] = {type = "seconds", label = locale("misc.seconds")},
		[60] = {type = "minutes", label = locale("misc.minutes")},
		[3600] = {type = "hours", label = locale("misc.hours")}
	}
	
	if not input then return end

	local maxTime = Config.maxTimeInPrison[configTime[input[3]].type]
	local label = configTime[input[3]].label

	if input[2] > maxTime then
		Utils.notify((locale("error.canputthistime")):format(maxTime, maxTime > 1 and label.."s" or label), "error")
		return
	else
		return input
	end
end)


-- # FUNCTIONS


function initPrisonData()
	Data.checkupPed = Utils.createEntity(Config.checkupPed.model, Config.checkupPed.coords)
	Data.prisonZones = lib.zones.poly({
		points = Config.prisonZones,
		thickness = 19,
		debug = Config.debug,
		onExit = function()
			local info, time = lib.callback.await("wtr_prisons:server:getPlayerJailInfo", false, cache.serverId)

			if info and not jailbreakData.started then
				local randomCoords = Config.spawnsCoords[math.random(1, #Config.spawnsCoords)]

				SetEntityCoords(cache.ped, randomCoords)
				SetEntityHeading(cache.ped, randomCoords.w)
				Utils.notify(locale("primary.cantescape"), "info")
			end
		end
	})

	local options = {
		{
			label = locale("menu.checktime"),
			icon = "fas fa-clock",
			onSelect = function()
				initCheckPrisonTime()
			end
		}
	}
	Config.checkupJailPlayers.options = {
		{
			label = locale("menu.activeprisoner"),
			icon = "fas fa-clipboard",
			onSelect = function()
				initJailPlayersMenu()
			end
		}
	}
	exports.ox_target:addBoxZone(Config.checkupJailPlayers)
	exports.ox_target:addLocalEntity(Data.checkupPed, options)
end

function initCheckPrisonTime()
	local info, time = lib.callback.await("wtr_prisons:server:getPlayerJailInfo", false, cache.serverId)
	local options = {}

	if info then
		if not info.canQuit then
			options[#options + 1] = {
				title = (locale("menu.remainingtime")):format(info.canQuit and locale("misc.finishTime") or time),
				progress = info.time ~= 0 and (100 - math.floor((info.time * 100) / info.originalTime)) or nil,
				colorScheme = info.time ~= 0 and "#FFFFFF" or nil,
				readOnly = true,
				icon = "fas fa-clock"

			}
		end
		if info.canQuit then
			options[#options + 1] = {
				title = locale("menu.release"),
				description = locale("menu.releasedescription"),
				icon = "fas fa-circle-check",
				onSelect = function()
					exitPrison(false)
				end
			}
		end
		if not info.canQuit then
			options[#options + 1] = {
				title = locale("menu.refresh"),
				icon = "fas fa-rotate-left",
				onSelect = function()
					initCheckPrisonTime()
				end
			}
		end
	else
		options[#options + 1] = {
			title = locale("menu.notdatafound"),
			icon = "fas fa-circle-xmark",
			readOnly = true
		}
	end

	lib.registerContext({
		id = "wtr_prisons:checkTimeMenu",
		title = locale("header.jail"),
		options = options
	})
	lib.showContext("wtr_prisons:checkTimeMenu")
end

function exitPrison(unjail)
	DoScreenFadeOut(1000)
	while not IsScreenFadedOut() do Wait(10) end
	SetEntityCoords(cache.ped, Config.getOutCoords)
	SetEntityHeading(cache.ped, Config.getOutCoords.w)
	DoScreenFadeIn(2500)
	Utils.notify(locale("success.release"), "success")
	lib.callback.await("wtr_prisons:server:exitPrison", false, cache.serverId, unjail)
end

function initJailPlayersMenu()
	local info = lib.callback.await("wtr_prisons:server:getJailTable", false)
	local amount = 0
	local options = {}

	for k, v in pairs(info) do
		if k then
			local playerData = lib.callback.await("wtr_prisons:server:getPlayerData", false, tostring(k))
			local name = ("%s %s"):format(playerData.charinfo.firstname, playerData.charinfo.lastname)

			options[#options + 1] = {
				title = name,
				icon = "fas fa-clipboard",
				arrow = isCops(),
				description = (locale("menu.descriptionremainingtime")):format(Utils.getFormatTime(info[k].originalTime), info[k].canQuit and locale("misc.finishTime") or Utils.getFormatTime(info[k].time)),
				readOnly = not isCops(),
				onSelect = function()
					initPlayersJailFinalMenu(playerData)
				end
			}
			amount += 1
		end
	end

	if amount == 0 then
		options[#options + 1] = {
			title = locale("menu.noprisoner"),
			icon = "fas fa-circle-xmark",
			readOnly = true
		}
	end

	if isCops() then
		options[#options + 1] = {
			title = locale("menu.jailplayer"),
			icon = "fas fa-person",
			onSelect = function()
				jailMenu()
			end
		}
	end	

	lib.registerContext({
		id = "wtr_prisons:jailPlayersMenu",
		title = locale("header.activeprisoner"),
		options = options
	})
	lib.showContext("wtr_prisons:jailPlayersMenu")
end

function initPlayersJailFinalMenu(data)

	local options = {
		{
			title = locale("menu.unjail"),
			icon = "fas fa-door-open",
			description = locale("menu.descriptionunjail"),
			readOnly = not (data.source ~= nil),
			onSelect = function()
				local isCops = isCops()

				if not isCops then Utils.notify(locale("error.notcops"), "error") return end
				if not data.source then Utils.notify(locale("error.playernotconnected"), "error") return end

				unjail(data.source)
			end
		},
		{
			title = locale("menu.editsentence"),
			icon = "fas fa-clipboard",
			description = locale("menu.descriptioneditsentence"),
			onSelect = function()
				local isCops = isCops()
				local info, time = lib.callback.await("wtr_prisons:server:getPlayerJailInfo", false, tostring(data.citizenid))

				if not isCops then Utils.notify(locale("error.notcops"), "error") return end

				local input = lib.inputDialog(locale("menu.editsentence"), {  
					{type = "number", label = locale("menu.inputtime"), description = locale("menu.inputdescriptiontime"), min = 1, max = Config.maxTimeInPrison.seconds, required = true},
					{type = 'select', label = locale("menu.inputunittime"), options = {{value = 1, label = Utils.firstToUpper(locale("misc.seconds"))}, {value = 60, label = Utils.firstToUpper(locale("misc.minutes"))}, {value = 3600, label = Utils.firstToUpper(locale("misc.hours"))}}, description = locale("menu.inputdescriptionunittime"), required = true, clearable = true}
				})

				local configTime = {
					[1] = {type = "seconds", label = locale("misc.seconds")},
					[60] = {type = "minutes", label = locale("misc.minutes")},
					[3600] = {type = "hours", label = locale("misc.hours")}
				}

				if not input then initPlayersJailFinalMenu(data) return end
			
				local maxTime = Config.maxTimeInPrison["seconds"]
				local personnalTime = (info.time + (input[1] * input[2]))
				if personnalTime > maxTime then	Utils.notify((locale("error.editsentencetoomuchtime")):format(Utils.getFormatTime(maxTime - info.time)), "error") initPlayersJailFinalMenu(data) return end

				lib.callback.await("wtr_prisons:server:updateJailPlayersTime", false, data.citizenid, (input[1] * input[2]))
			end
		},
		{
			title = locale("menu.return"),
			icon = "fas fa-rotate-left",
			onSelect = function()
				initJailPlayersMenu()
			end
		}
	}
	lib.registerContext({
		id = "wtr_prisons:finalPlayersJailMenu",
		title = data.charinfo.firstname.." "..data.charinfo.lastname,
		options = options
	})
	lib.showContext("wtr_prisons:finalPlayersJailMenu")
end

function isCops()
	for k, v in pairs(Config.policeJob) do
		if playerJob.name == v then return true end
	end

	return false
end


-- # EXPORTS HANDLERS


function checkTime()
	local time, formattime = lib.callback.await("wtr_prisons:server:checkTime", false)

	return time, formattime
end
exports("CheckTime", checkTime)

function isJailed()
	local isInPrison = lib.callback.await("wtr_prisons:server:isJailed", false)

	return isInPrison
end
exports("IsJailed", isJailed)

function jailMenu()
	return lib.callback.await("wtr_prisons:server:jailMenu", false)
end
exports("JailMenu", jailMenu)

function unjail(target)
	return lib.callback.await("wtr_prisons:server:unjail", false, target)
end
exports("Unjail", unjail)


-- # HANDLERS


CreateThread(function()
	while not LocalPlayer.state.isLoggedIn do Wait(3000) end
	playerJob = QBCore.Functions.GetPlayerData().job
	local blips = Config.prisonBlip.active and Utils.createBlip(Config.prisonBlip.coords, Config.prisonBlip.sprite, Config.prisonBlip.scale, Config.prisonBlip.colour, locale("blips.prison")) or nil

	initActivities()
	initPrisonData()
	initLoottables()
	initDealer()
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
	updateActivitiesCallback()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    playerJob = JobInfo
end)

AddEventHandler("onResourceStop", function(resource)
	if (GetCurrentResourceName() ~= resource) then return end

	DeleteEntity(Data.checkupPed)
end)