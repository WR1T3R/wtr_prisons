lib.locale()
local Utils = {}

function Utils.createEntity(model, coords)
	local model = joaat(model)
	local coords = coords

	lib.requestModel(model, 5000)

	local peds = CreatePed(0, model, coords.x, coords.y, coords.z - 1, coords.w, false, false, false)
	while not DoesEntityExist(peds) do Wait(2000) end

	FreezeEntityPosition(peds, true)
	SetEntityInvincible(peds, true)
	SetBlockingOfNonTemporaryEvents(peds, true)
	SetPedDefaultComponentVariation(peds)

	return peds
end

function Utils.getLabelDescription(items)
	a = 0
	label = ""

	for _, v in pairs(items) do
		if not exports.ox_inventory:Items(v.item) then error((locale("error.itemsdoesnotexist")):format(v.item)) return end
		label = string.format("%s%sx %s", label, v.amount, exports.ox_inventory:Items(v.item).label)
		if a ~= #items - 1 then label = ("%s\n"):format(label) end
		a = a + 1
	end

	return label
end

function Utils.canCraft(item)
	local itemsIn = 0

	for i = 1, #item do
		local count = exports.ox_inventory:GetItemCount(item[i].item)

		if count >= item[i].amount then itemsIn += 1 end
	end

	return #item == itemsIn
end

function Utils.getColorScheme(number)
	if number <= 25 then return "#C92A2A"
	elseif number >= 25 and number < 50 then return "#E67700"
	elseif number >= 50 and number < 75 then return "#FFD43B"
	elseif number >= 75 and number < 100 then return "#51CF66"
	elseif number >= 100 then return "#2B8A3E" end

	return ""
end

function Utils.notify(text, type, source)
	if source then
		TriggerClientEvent("ox_lib:notify", source, {description = text, type = type})
	else
		TriggerEvent("ox_lib:notify", {description = text, type = type})
	end
end

function Utils.createProps(object, coords, placeonground)
	local model = joaat(object)
	lib.requestModel(model)

	local props = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)

	while not DoesEntityExist(props) do Wait(10) end
	SetEntityHeading(props, coords.w)

	if placeonground then
		PlaceObjectOnGroundProperly(props)
	end
	FreezeEntityPosition(props, true)

	return props
end

function Utils.getFormatTime(time)
	if (time > 60) and not (time > 3600) then
		local minutes, fraction = math.modf(time / 60)
		local seconds = time - (minutes * 60)
		local formatLast = (" %d %s%s"):format(seconds, locale("misc.seconds"), seconds > 1 and "s" or "")

		return ("%d %s%s%s"):format(minutes, locale("misc.minutes"), minutes > 1 and "s" or "", fraction > 0.0 and formatLast or "")
	elseif time > 3600 then
		local hours, fraction = math.modf(time / 3600)
		local minutes = math.modf((time - (hours * 3600)) / 60)
		local formatLast = (" %d %s%s"):format(minutes, locale("misc.minutes"), minutes > 1 and "s" or "")

		return ("%d %s%s%s"):format(hours, locale("misc.hours"), hours > 1 and "s" or "", fraction > 0.0 and formatLast or "")
	else
		return ("%d %s%s"):format(time, locale("misc.seconds"), time > 1 and "s" or "")
	end
end

function Utils.firstToUpper(label)
    return (label:gsub("^%l", string.upper))
end


function Utils.createBlip(coords, sprite, scale, colour, name)
	local blips = AddBlipForCoord(coords.x, coords.y, coords.z)

	SetBlipSprite(blips, sprite)
	SetBlipDisplay(blips, 4)
	SetBlipScale(blips, scale)
	SetBlipColour(blips, colour)
	SetBlipAsShortRange(blips, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(name)
	EndTextCommandSetBlipName(blips)

	return blips
end

return Utils