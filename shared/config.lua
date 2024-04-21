return {
	directory = "./JSON/jailData.json",
	debug = false,
	includePlayerForSendJail = true,
	refreshLootedTime = 5, -- in minutes (Time before a looted zone can be looted again)
	maxTimeInPrison = {
		seconds = 7200,
		minutes = 120,
		hours = 2,
	},
	checkupPed = {model = "s_m_m_armoured_01", coords = vec4(1785.05, 2559.81, 45.67, 186.89)},
	activitiesPed = {model = "s_m_m_prisguard_01", coords= vec4(1752.12, 2480.39, 45.74, 304.45)},
	checkupJailPlayers = {coords = vec3(1840.35, 2578.5, 46.0), size = vec3(0.75, 0.6, 0.75), rotation = 2.25},
	getOutCoords = vec4(1837.29, 2589.73, 45.01, 183.71),
	prisonBlip = {active = true, coords = vec3(1845.67, 2585.85, 45.67), sprite = 188, scale = 0.7, colour = 9},
	policeJob = {
		"police"
	},
	policeAlerts = function()
		exports['ps-dispatch']:PrisonBreak()
	end,
	keepItems = {
		{item = "cola", chance = 100},
		{item = "fakeplates", chance = 30},
		{item = "phone", chance = 30},
	},
	
	activities = {
		electrician = {
			propsModel = "m23_1_prop_m31_electricbox_01a",
			drawOutlineOnProps = true,
			progress = {
				time = 4000, 
				animation = {
					dict = 'amb@prop_human_movie_bulb@idle_a', 
					clip = 'idle_b',
				},
			},
			blips = {active = true, sprite = 402, scale = 0.7, colour = 50},
			skillCheck = {active = true, difficulty = {'easy', 'easy', "easy", 'easy'}, inputs = {"e"}},
			reduceTimePerAct = 60, -- in seconds
			coords = {
				vec4(1725.058, 2497.650, 45.50, 301),
				vec4(1687.479, 2470.685, 45.500, 135),
				vec4(1684.853, 2473.312, 45.500, 134),
				vec4(1621.936, 2499.391, 45.500, 97),
				vec4(1603.159, 2544.584, 45.500, 137),
				vec4(1599.608, 2548.115, 45.500, 136),
				vec4(1625.736, 2573.471, 45.500, 269),
				vec4(1642.640, 2565.868, 45.500, 0),
				vec4(1662.566, 2568.627, 45.500, 46),
				vec4(1694.492, 2566.381, 45.500, 0),
				vec4(1725.522, 2564.074, 45.500, 0),
				vec4(1745.844, 2501.136, 45.500, 178),
				vec4(1750.461, 2564.670, 45.500, 45),
				vec4(1601.755, 2561.509, 45.500, 46)
			}
		}
	},

	jailbreak = {
		keepJailBreakItemsWhenLeaving = false,
		receivePlayerItemsWhenJailBreak = false,
		skillCheck = {active = true, difficulty = {'easy', 'easy', "easy", 'easy'}, inputs = {"e"}},
		itemsNeeded = {
			{item = "prison_shovel", amount = 1},
			{item = "prison_pickaxe", amount = 1},
		},
		leaveCoords = {
			firstPhase = vec4(-542.71, 1982.12, 126.07, 41.50),
			secondPhase = vec4(-595.98, 2088.10, 131.35, 14.68),
			thirdPhase = vec4(1727.97, 2829.29, 41.54, 301.35)
		},
		places = {
			{coords = vec3(1778.6, 2481.5, 46.2), size = vec3(3.5, 0.8, 2.9), rotation = 30.0},
		}
	},

	loottables = {
		chance = 100, -- in percentage
		places = {
			vec4(1768.88, 2489.98, 46.00, 39.55),
			vec4(1763.70, 2486.94, 46.00, 277.14),
			vec4(1759.00, 2484.33, 46.00, 120.37),
		},
		itemsLoottables = {
			"prison_shovelhead",
			"prison_shovelhandler",
			"prison_pickaxehandler",
			"prison_pickaxehead",
		}
	},

	dealer = {
		ped = {
			{model = "s_m_y_prismuscl_01", coords = vec4(1753.73, 2642.99, 53.02, 1.46), blips = {active = false, sprite = 403, scale = 0.7, colour = 35}}
		},
		crafts = {
			{
				item = "prison_shovel", 
				amount = 1,
				requirements = {
					{item = "prison_shovelhead", amount = 1, remove = true},
					{item = "prison_shovelhandler", amount = 1, remove = true}
				}
			},
			{
				item = "prison_pickaxe",
				amount = 1,
				requirements = {
					{item = "prison_pickaxehead", amount = 1, remove = true},
					{item = "prison_pickaxehandler", amount = 1, remove = true}
				}
			}
		}
	},

	prisonZones = {
		vec3(1851.3487548828, 2611.8994140625, 53.67),
		vec3(1851.4149169922, 2672.0583496094, 53.67),
		vec3(1858.1351318359, 2694.7734375, 53.67),
		vec3(1851.9486083984, 2713.3920898438, 53.67),
		vec3(1813.3078613281, 2746.9658203125, 53.67),
		vec3(1791.5513916016, 2764.8386230469, 53.67),
		vec3(1776.7678222656, 2770.5727539062, 53.67),
		vec3(1765.6551513672, 2772.5300292969, 53.67),
		vec3(1658.4617919922, 2767.7570800781, 53.67),
		vec3(1642.2275390625, 2763.7509765625, 53.67),
		vec3(1632.0548095703, 2758.2900390625, 53.67),
		vec3(1569.8442382812, 2695.4919433594, 53.67),
		vec3(1560.1398925781, 2682.7434082031, 53.67),
		vec3(1552.8251953125, 2670.3410644531, 53.67),
		vec3(1526.0355224609, 2591.8728027344, 53.67),
		vec3(1523.6662597656, 2583.0380859375, 53.67),
		vec3(1530.5052490234, 2464.2307128906, 53.67),
		vec3(1536.3665771484, 2454.9304199219, 53.67),
		vec3(1542.8283691406, 2448.54296875, 53.67),
		vec3(1643.1641845703, 2389.1000976562, 53.67),
		vec3(1660.8153076172, 2384.1481933594, 53.67),
		vec3(1761.6439208984, 2399.044921875, 53.67),
		vec3(1765.3656005859, 2400.5454101562, 53.67),
		vec3(1799.4705810547, 2425.7702636719, 53.67),
		vec3(1823.4135742188, 2451.5688476562, 53.67),
		vec3(1842.6923828125, 2479.970703125, 53.67),
		vec3(1853.9857177734, 2507.8000488281, 53.67),
		vec3(1856.9451904297, 2524.6594238281, 53.67),
		vec3(1851.3734130859, 2539.0932617188, 53.67)
	},

	spawnsCoords = {
		vec4(1767.07, 2498.49, 44.84, 299.67), -- Cell 1
		vec4(1763.95, 2496.63, 44.84, 299.67), -- Cell 2
		vec4(1760.8, 2494.82, 44.84, 299.67), -- Cell 3
		vec4(1754.55, 2491.2, 44.84, 299.67), -- Cell 4
		vec4(1751.38, 2489.34, 44.84, 299.67), -- Cell 5
		vec4(1748.22, 2487.55, 44.84, 299.67), -- Cell 6
		vec4(1767.07, 2498.49, 48.79, 299.67), -- Cell 7
		vec4(1763.95, 2496.63, 48.79, 299.67), -- Cell 8
		vec4(1760.8, 2494.82, 48.79, 299.67), -- Cell 9
		vec4(1757.66, 2493.0, 48.79, 299.67), -- Cell 10
		vec4(1754.55, 2491.2, 48.79, 299.67), -- Cell 11
		vec4(1751.38, 2489.34, 48.79, 299.67), -- Cell 12
		vec4(1748.22, 2487.55, 48.79, 299.67), -- Cell 13
		vec4(1758.76, 2474.95, 44.84, 119.67), -- Cell 14
		vec4(1761.95, 2476.74, 44.84, 119.67), -- Cell 15
		vec4(1765.09, 2478.56, 44.84, 119.67), -- Cell 16
		vec4(1768.21, 2480.42, 44.84, 119.67), -- Cell 17
		vec4(1771.38, 2482.2, 44.84, 119.67), -- Cell 18
		vec4(1774.54, 2483.99, 44.84, 119.67), -- Cell 19
		vec4(1777.72, 2485.75, 44.84, 119.67), -- Cell 20
		vec4(1758.76, 2474.95, 48.79, 119.67), -- Cell 21
		vec4(1761.95, 2476.74, 48.79, 119.67), -- Cell 22
		vec4(1765.09, 2478.56, 48.79, 119.67), -- Cell 23
		vec4(1768.21, 2480.42, 48.79, 119.67), -- Cell 24
		vec4(1771.38, 2482.2, 48.79, 119.67), -- Cell 25
		vec4(1774.54, 2483.99, 44.84, 119.67), -- Cell 26
		vec4(1777.72, 2485.75, 48.79, 119.67), -- Cell 27
	}
}