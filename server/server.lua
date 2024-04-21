local Config = require("shared.config")
local QBCore = exports["qb-core"]:GetCoreObject()
local Utils = require("shared.utils")
local looted = {}
local jailCached = {}


-- # CALLBACK

lib.callback.register("wtr_prisons:server:updateLoottables", function(source,id)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	local cid = player.PlayerData.citizenid

	if looted[cid] then
		looted[cid][#looted[cid] + 1] = {
			id
		}
	else
		looted[cid] = {{id}}
	end
end)

lib.callback.register("wtr_prisons:server:getLoottables", function(source)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	local cid = player.PlayerData.citizenid

	return looted[cid]
end)

lib.callback.register("wtr_prisons:server:setupItems", function(source, func, item, amount, meta, slot)
	local src = source

	if func == "give" then
		exports.ox_inventory:AddItem(src, item, amount, meta, slot)
	elseif func == "remove" then
		exports.ox_inventory:RemoveItem(src, item, amount, meta, slot)
	end
end)

lib.callback.register("wtr_prisons:server:getPlayerData", function(source, id)
	if type(id) == "string" then
		local onlinePlayer = QBCore.Functions.GetPlayerByCitizenId(id)
		local offlinePlayer = QBCore.Functions.GetOfflinePlayerByCitizenId(id)

		return onlinePlayer and onlinePlayer.PlayerData or offlinePlayer.PlayerData
	elseif type(id) == "number" then
		local player = QBCore.Functions.GetPlayer(id)

		return player.PlayerData
	end
end)

lib.callback.register("wtr_prisons:server:getJailTable", function(source)
	return jailCached
end)

lib.callback.register("wtr_prisons:server:getPlayerJailInfo", function(source, id)
	local cid
	if type(id) == "string" then
		local onlinePlayer = QBCore.Functions.GetPlayerByCitizenId(id)
		local offlinePlayer = QBCore.Functions.GetOfflinePlayerByCitizenId(id)

		cid = onlinePlayer and onlinePlayer.PlayerData.citizenid or offlinePlayer.PlayerData.citizenid
	elseif type(id) == "number" then
		local player = QBCore.Functions.GetPlayer(id)
		cid = player.PlayerData.citizenid
	end

	if not jailCached[cid] then return nil end

	return jailCached[cid], jailCached[cid].time and Utils.getFormatTime(jailCached[cid].time) or 0
end)

lib.callback.register("wtr_prisons:server:updateActivitiesTime", function(source, id, time)
	local player = QBCore.Functions.GetPlayer(id)
	local cid = player.PlayerData.citizenid

	if jailCached[cid] and jailCached[cid].time then
		if (jailCached[cid].time - time) > 0 then
			jailCached[cid].time -= time
			Utils.notify((locale("success.actcompletedreducetime")):format(Utils.getFormatTime(time)), "success", id)
		else
			jailCached[cid].time = 0
		end
	end
end)

lib.callback.register("wtr_prisons:server:updateJailPlayersTime", function(source, id, newTime)
	local src = source
	local player = QBCore.Functions.GetPlayerByCitizenId(id)
	local offPlayer = QBCore.Functions.GetOfflinePlayerByCitizenId(id)
	local name = player and ("%s %s"):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname) or ("%s %s"):format(offPlayer.PlayerData.charinfo.firstname, offPlayer.PlayerData.charinfo.lastname)
	if not jailCached[id] then return end

	jailCached[id].time += newTime
	jailCached[id].originalTime += newTime
	jailCached[id].canQuit = false
	Utils.notify((locale("success.addtimeforplayer")):format(Utils.getFormatTime(newTime), name), "success", src)
	if player then
		Utils.notify((locale("success.notifyplayersentence")):format(Utils.getFormatTime(newTime)), "success", src)
	end
end)

lib.callback.register("wtr_prisons:server:exitPrison", function(source, id, unjail)
	local player = QBCore.Functions.GetPlayer(id)
	local cid = player.PlayerData.citizenid

	if jailCached[cid] and (unjail or jailCached[cid].canQuit) then
		for _, v in pairs(jailCached[cid].itemsIn) do
			exports.ox_inventory:AddItem(id, v.name, v.count, v.metadata, v.slot)
		end
		jailCached[cid] = nil
		lib.callback.await("wtr_prisons:client:updateActivities", id)
	end
end)

lib.callback.register("wtr_prisons:server:jailbreakSuccess", function(source)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	local cid = player.PlayerData.citizenid

	if jailCached[cid] and Config.jailbreak.receivePlayerItemsWhenJailBreak then
		for _, v in pairs(jailCached[cid].itemsIn) do
			exports.ox_inventory:AddItem(src, v.name, v.count, v.metadata, v.slot)
		end
	end

	if not Config.jailbreak.keepJailBreakItemsWhenLeaving then
		for i = 1, #Config.jailbreak.itemsNeeded do
			for k, v in pairs(exports.ox_inventory:GetInventoryItems(src)) do
				if v.name == Config.jailbreak.itemsNeeded[i].item then
					exports.ox_inventory:RemoveItem(src, v.name, v.count)
				end
			end
		end
	end
	
	Utils.notify(locale("success.jailbreaksuccess"), "success", src)
	jailCached[cid] = nil
	lib.callback.await("wtr_prisons:client:updateActivities", src)
end)


-- # COMMANDS


lib.addCommand('jailmenu', {
    help = locale("command.jailmenu"),
    params = {},
    restricted = false
}, function(source, args, raw)
	jailMenu(source)
end)

lib.addCommand('jailstatus', {
    help = locale("command.jailstatus"),
    params = {},
    restricted = false
}, function(source, args, raw)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	local cid = player.PlayerData.citizenid

	if jailCached[cid] then
		if jailCached[cid].canQuit then
			Utils.notify(locale("primary.timefinish"), "info", src)
		else
			local time = Utils.getFormatTime(jailCached[cid].time)
			Utils.notify((locale("primary.remainingtime")):format(time), "info", src)
		end
	end
end)

lib.addCommand('unjail', {
    help = locale("command.unjail"),
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = locale("command.unjailhelp"),
        },
	},
    restricted = false
}, function(source, args, raw)
	unjailPlayer(source, args)
end)


-- # EXPORTS HANDLERS


lib.callback.register("wtr_prisons:server:jailMenu", function(source)
	return jailMenu(source)
end)

lib.callback.register("wtr_prisons:server:checkTime", function(soruce)
	return playerTimeInPrison(source)
end)

lib.callback.register("wtr_prisons:server:isJailed", function(source)
	return isInPrison(source)
end)

lib.callback.register("wtr_prisons:server:unjail", function(source, args)
	return unjailPlayer(source, args)
end)

function jailMenu(source)
	local src = source
	local copsPlayer = QBCore.Functions.GetPlayer(src)
	if copsPlayer and not isCops(copsPlayer) then Utils.notify(locale("error.notcops"), "error", src) return end

	local input = lib.callback.await("wtr_prisons:client:openJailMenu", src)
	if not input then return end

	if input[1] and input[2] and input[3] then
		local player = QBCore.Functions.GetPlayer(tonumber(input[1]))

		if player then
			local cid = player.PlayerData.citizenid

			if not jailCached[cid] then
				local invItems = getInventoryToStore(src, tonumber(input[1]))

				exports.ox_inventory:ClearInventory(tonumber(input[1]), Config.keepItems)
				jailCached[cid] = {time = tonumber(input[2]) * input[3], canQuit = false, itemsIn = invItems, originalTime = tonumber(input[2]) * input[3]}
				lib.callback.await("wtr_prisons:client:enterPrison", tonumber(input[1]))
				Utils.notify(locale("primary.playerarrived"), "info", src)
			else
				Utils.notify(locale("primary.playersalreadyinjail"), "info", src)
			end
		else
			Utils.notify(locale("error.notplayerfoundwithid"), "error", src)
		end
	else
		Utils.notify(locale("error.inputnotfully"), "error", src)
	end
end
exports("JailMenu", jailMenu)

function unjailPlayer(source, args)
	local playerId
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	if player and not isCops(player) then Utils.notify(locale("error.notcops"), "error", src) return end

	if type(args) == "table" then
		playerId = tostring(args.target)
	else
		playerId = tostring(args)
	end

	local targetPlayer = QBCore.Functions.GetPlayer(tonumber(playerId))
	if not targetPlayer then Utils.notify(locale("error.notplayerfoundwithid"), "error", src) return end

	local targetCID = targetPlayer.PlayerData.citizenid
	if not jailCached[targetCID] then Utils.notify(locale("error.playernotinjail"), "error", src) return end

	Utils.notify(locale("success.unjailplayer"), "success", src)
	lib.callback.await("wtr_prisons:client:unjailPlayer", targetPlayer.PlayerData.source)
end
exports("Unjail", unjailPlayer)

function isInPrison(source)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	local cid = player.PlayerData.citizenid

	return jailCached[cid] and true or false
end
exports("IsJailed", isInPrison)

function playerTimeInPrison(source)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	local cid = player.PlayerData.citizenid

	if jailCached[cid] then
		return jailCached[cid].time, Utils.getFormatTime(jailCached[cid].time)
	end

	return 0, 0
end
exports("CheckTime", playerTimeInPrison)

function isInActivities(source)
	return lib.callback.await("wtr_prisons:client:isInActivities", source)
end
exports("IsInActivities", isInActivities)

function isInJailbreak(source)
	return lib.callback.await("wtr_prisons:client:isInJailbreak", source)
end
exports("IsInJailbreak", isInJailbreak)


-- # FUNCTIONS

function isCops(player)
	for k, v in pairs(Config.policeJob) do
		if player.PlayerData.job.name == v then return true end
	end
	return false
end

function getInventoryToStore(source, id)
	local inv = exports.ox_inventory:GetInventoryItems(id)
	local store = {}

	for k, v in pairs(inv) do
		local isKeepItem = isAnItemInKeep(v.name)
		if not isKeepItem then
			store[#store + 1] = v
		end
	end

	return store
end

function isAnItemInKeep(item)
	for k, v in pairs(Config.keepItems) do
		local chance = math.random(1, 100)

		if v.item == item then
			if chance <= v.chance then
				return true
			end
		end
	end

	return false
end


-- # LOOP

function updateLooted()
	SetTimeout((Config.refreshLootedTime * 60000), updateLooted)

	looted = {}
end

function checkTime()
	for citizenid, value in pairs(jailCached) do
		local player = QBCore.Functions.GetPlayerByCitizenId(citizenid)

		if player then
			if jailCached[citizenid].time ~= 0 then
				jailCached[citizenid].time -= 1
			end

			if jailCached[citizenid].time == 0 and not jailCached[citizenid].canQuit then
				jailCached[citizenid].time = 0
				jailCached[citizenid].canQuit = true
				Utils.notify(locale("primary.timefinish"), "info", player.PlayerData.source)
			end
		end
	end

	SetTimeout(1000, checkTime)
end

CreateThread(function()
	checkTime()
	updateLooted()
end)


-- # HANDLERS


AddEventHandler("onResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then return end
	local saveData = LoadResourceFile(GetCurrentResourceName(), Config.directory)
	jailCached = json.decode(saveData) ~= "null" and json.decode(saveData) or {}
end)

AddEventHandler("onResourceStop", function(resource)
	if resource ~= GetCurrentResourceName() then return end
	SaveResourceFile(GetCurrentResourceName(), Config.directory, json.encode(jailCached))
end)