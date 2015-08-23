
--[[
 		*************************************
 		*************************************
 		*************************************
 		utility for loading vip.dat
 		*************************************
 		*************************************
]]

local TargetDataFile = 'vip.dat'

local function clampLevel(lv)
	if lv < 0 then lv = 0 end
	local mx = VipProfile:getMaxVipLevel()
	if lv > mx then lv = mx end
	return lv
end

function loadVipProfileInt(level, key)
	level = tostring(level)
	-- print('querying for ' .. key)
	local values = GameData:getMapData(TargetDataFile)
	local rv = tonumber(values[level][key])
	if not rv then
		print(key .. ' does not exist')
	end
	return rv or 0
end

function loadVipProfileString(level, key)
	level = tostring(level)
	-- print('querying for ' .. key)
	local values = GameData:getMapData(TargetDataFile)
	local rv = tostring(values[level][key])
	if not rv then
		print(key .. ' does not exist')
	end
	return rv or ''
end

function getCashToLevel(levelNow)
	local pre_v = loadVipProfileInt(clampLevel(levelNow-1), 'Cash')
	local this_v= loadVipProfileInt(clampLevel(levelNow), 'Cash')

	local rv = this_v - pre_v
	if rv < 0 then rv = 0 end
	return rv
end

function getCashAccForLevel(level)
	return loadVipProfileInt(clampLevel(level), 'Cash')
end

print('vip_profile reloaded')