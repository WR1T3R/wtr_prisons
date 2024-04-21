# Prison system

## Items


### [1] Put images in your inventory images folder 
### [2] Installation

```lua
	["prison_shovel"] = {
		label = "Pelle",
		weight = 500,
		stack = true,
		close = true,
		description = "",
		client = {
			image = "prison_shovel.png",
		}
	},
	["prison_pickaxe"] = {
		label = "Pioche",
		weight = 500,
		stack = true,
		close = true,
		description = "",
		client = {
			image = "prison_pickaxe.png",
		}
	},
	["prison_pickaxehead"] = {
		label = "Tête de pioche",
		weight = 500,
		stack = true,
		close = true,
		description = "",
		client = {
			image = "prison_pickaxehead.png",
		}
	},
	["prison_pickaxehandler"] = {
		label = "Manche de pioche",
		weight = 500,
		stack = true,
		close = true,
		description = "",
		client = {
			image = "prison_pickaxehandler.png",
		}
	},
	["prison_shovelhead"] = {
		label = "Tête de pelle",
		weight = 500,
		stack = true,
		close = true,
		description = "",
		client = {
			image = "prison_shovelhead.png",
		}
	},
	["prison_shovelhandler"] = {
		label = "Manche de pelle",
		weight = 500,
		stack = true,
		close = true,
		description = "",
		client = {
			image = "prison_shovelhandler.png",
		}
	},
```

## Exports

### Client exports

```lua
	exports.wtr_prisons:CheckTime() | --Check player's time in prison (return: time, formatTime)
	exports.wtr_prisons:IsJailed() | --Check if player is in prison (return: boolean)
	exports.wtr_prisons:JailMenu() | --Open the jail menu
	exports.wtr_prisons:Unjail(target) | --Unjail Someone
	exports.wtr_prisons:IsInActivities() | --Check if players is in an activities (return: boolean)
	exports.wtr_prisons:IsInJailbreak() | --Check if players is in a jail break (return: boolean)
```

### Server exports

```lua
	exports.wtr_prisons:JailMenu(source) | --Open the jail menu
	exports.wtr_prisons:IsJailed(source) | --Check if player is in prison (return: boolean)
	exports.wtr_prisons:CheckTime(source) | --Check player's time in prison (return: time, formatTime)
	exports.wtr_prisons:Unjail(source, target) | --Unjail Someone
	exports.wtr_prisons:IsInActivities(source) | --Check if players is in an activities (return: boolean)
	exports.wtr_prisons:IsInJailbreak(source) | --Check if players is in a jail break (return: boolean)
```