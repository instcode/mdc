
--[[
 		*************************************
 		*************************************
 		*************************************
 		utility for loading recharge.dat
 		*************************************
 		*************************************
]]

local TargetDataFile = 'recharge_vn.dat'

function loadRechargeProfileInt(id, key)
	id = tostring(id)
	local values = GameData:getMapData(TargetDataFile)
	local rv = tonumber(values[id][key])
	if not rv then
		print(key .. ' does not exist')
	end
	return rv or 0
end

function loadRechargeProfileString(id, key)
	-- print('loading recharge for ' .. tostring(id) .. ':' .. key)
	id = tostring(id)
	local values = GameData:getMapData(TargetDataFile)
	local rv = tostring(values[id][key])
	if not rv then
		print(key .. ' does not exist')
	end
	return rv or ''
end

local function genRechargeItemCounter()
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
getRechargeItemCount = genRechargeItemCounter()
print('recharge reloaded')