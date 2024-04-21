local Config = require("shared.config")
local Utils = require("shared.utils")

function initElectrician()
	if not activitiesData.firstStart then
		activitiesData.firstStart = true
		activitiesData.started = true
		activitiesData.toFinish = #Config.activities.electrician.coords
		activitiesData.dataInsert = lib.table.deepclone(Config.activities.electrician.coords)
	end

	local random = (#activitiesData.dataInsert == 1 and 1) or (math.random(1, #activitiesData.dataInsert))
	local coords = activitiesData.dataInsert[random]
	local blips = Config.activities.electrician.blips
	
	activitiesData.blips[random] = Config.activities.electrician.blips.active and Utils.createBlip(coords, blips.sprite, blips.scale, blips.colour, locale("blips.currentactivity")) or nil

	activitiesData.entityCreated[random] = Utils.createProps(Config.activities.electrician.propsModel, coords, false)

	if Config.activities.electrician.drawOutlineOnProps then
		SetEntityDrawOutline(activitiesData.entityCreated[random], true)
		SetEntityDrawOutlineColor(255, 255, 255, 1.0)
		SetEntityDrawOutlineShader(0)
	end
	
	local options = {
		{
			label = locale("target.electrician"),
			icon = "fas fa-ethernet",
			onSelect = function(data)
				updateElectrician(random)
			end
		}
	}

	activitiesData.zonesCreated[random] = exports.ox_target:addLocalEntity(activitiesData.entityCreated[random], options)
end

function updateElectrician(value)
	local success 

	if Config.activities.electrician.skillCheck.active then
		success = lib.skillCheck(Config.activities.electrician.skillCheck.difficulty, Config.activities.electrician.skillCheck.inputs)
	else
		success = true
	end

	if success then
		if lib.progressCircle({
			label = "Réparation en cours",
			duration = Config.activities.electrician.progress.time,
			position = 'bottom',
			useWhileDead = false,
			canCancel = false,
			disable = {
				move = true,
				car = true,
				combat = true,
			},
			anim = {
				dict = Config.activities.electrician.progress.animation.dict,
				clip = Config.activities.electrician.progress.animation.clip,
			}
		}) 
		then 
			SetEntityDrawOutline(activitiesData.entityCreated[value], false)
			exports.ox_target:removeLocalEntity(activitiesData.zonesCreated[value])
			DeleteEntity(activitiesData.entityCreated[value])
			activitiesData.completed += 1
			RemoveBlip(activitiesData.blips[value])
			updateActivitiesTUI()
	
			table.remove(activitiesData.dataInsert, value)
			table.wipe(activitiesData.zonesCreated)
			table.wipe(activitiesData.entityCreated)
			if activitiesData.completed == activitiesData.toFinish then
				Utils.notify(locale("success.activityfinished"), "success")
				lib.callback.await("wtr_prisons:server:updateActivitiesTime", false, cache.serverId, (Config.activities.electrician.reduceTimePerAct * activitiesData.completed))
				updateActivitiesCallback()
				lib.hideTextUI()
	
				return
			end
	
			initElectrician()
		end
	end
end