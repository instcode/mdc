
--[[
 		*************************************
 		*************************************
 		*************************************
 		utility for loading battledrop.dat
 		*************************************
 		*************************************
]]

local TargetDataFile = 'battledrop.dat'


function loadBattledropProfileInt(id, key)
	id = tostring(id)
	local values = GameData:getMapData(TargetDataFile)
	local rv = tonumber(values[id][key])
	if not rv then
		print(key .. ' does not exist')
	end
	return rv or 0
end

function loadBattledropProfileString(id, key)
	key =tostring(key)
	local conf = GameData:getArrayData(TargetDataFile)
	local tab = {}
	table.foreach(conf , function (k , v)
		if tonumber(v.Id) == tonumber(id) then
			table.insert(tab , v)
		end
	end)
	local str = ''
	table.foreach(tab , function (k , v)
		if v[key] and v[key] ~= ''  then
			str = v[key]
		end
	end)
	return str

end

function getBattleDropDataByIndex( id , index )
	local conf = GameData:getArrayData('battledrop.dat')
	local tab = {}
	table.foreach(conf , function (_, v)
		if tonumber(v['Id']) == tonumber(id) then
			table.insert(tab , v)
		end
	end)
	local str = ''
	table.foreach(tab , function (_, v)
		if tonumber(v['Index']) == tonumber(index)  then
			str = v['Award1']
		end
	end)
	return str
end

local function genBattledropItemCounter()
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
getBattledropItemCount = genBattledropItemCounter()
print('battledrop reloaded')