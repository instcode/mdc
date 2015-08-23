
--[[
 		*************************************
 		*************************************
 		*************************************
 		utility for loading monster.dat
 		*************************************
 		*************************************
]]

local TargetDataFile = 'monster.dat'

function loadMonsterProfileInt(id, key)
	id = tostring(id)
	local values = GameData:getMapData(TargetDataFile)
	local rv = tonumber(values[id][key])
	if not rv then
		print(key .. ' does not exist')
	end
	return rv or 0
end

function loadMonsterProfileString(id, key)
	--print('loading Monster for ' .. tostring(id) .. ':' .. key)
	id = tostring(id)
	local values = GameData:getMapData(TargetDataFile)
	local rv = tostring(values[id][key])
	if not rv then
		print(key .. ' does not exist')
	end
	return rv or ''
end

local function genMonsterItemCounter()
	local count
	return function()
		if not count then
			local values = GameData:getMapData(TargetDataFile)
			local num = 0
			for k,v in pairs(values) do
				num = num + 1
			end
			count = num
		end
		return count
	end
end

-- Exporting global
getMonsterItemCount = genMonsterItemCounter()
print('monster reloaded')