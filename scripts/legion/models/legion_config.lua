-- 军团基础相关配置的方法
LegionConfig = {
	
}

function LegionConfig:load()
	local t = GameData:getArrayData('legionconfig.dat')
	self.data = {}
	table.foreach(t, function ( k, v )
		self.data[v.Key] = tonumber(v.Value)
	end)
end

function LegionConfig:getLegionLocalText(key)
	local value = getLocalStringValue(key)
	return value
end

-- 获取legionconfig.dat表中的信息
function LegionConfig:getValueForKey( key )
	return self.data[key] or 0
end

-- 获取legionactivities.dat表中的信息
function LegionConfig:getactivitiesDataByKey(key)
	key = tonumber(key)
	local data = {}
	local activit = GameData:getArrayData('legionactivities.dat')
	self.legionactivitiesdata = {}
	table.foreach(activit, function ( _, v )
		if key == tonumber(v.Order) then
			data = v
		end
	end)
	return data
end

function LegionConfig:getActivitiesCount()
	local count
	if not count then
		local values = GameData:getMapData('legionactivities.dat')
		local num = 0
		for k,v in pairs(values) do
			num = num + 1
		end
		count = num
	end
	return count
end

-- 获取legiontech.dat表中的信息
function LegionConfig:getTechDataMaxID()
	local maxid =0
	local tech = GameData:getMapData('legiontech.dat')
	table.foreach(tech, function ( _, v )
		if   tonumber(v.Id) > tonumber(maxid) then
			maxid =v.Id
		end
	end)
	return maxid
end

function LegionConfig:getTechDataTechLv(id)
	local maxLv =0
	local tech = GameData:getMapData('legiontech.dat')
	table.foreach(tech, function ( _, v )
		if   tonumber(v.Id) == tonumber(id) then
			maxLv =v.Level
		end
	end)
	--cclog('tech max lv ==='  .. maxLv)
	return maxLv
end

function LegionConfig:getTechDataByKeyandLv(key,level)
	--cclog('get getTechDataByKeyandLv  ='.. key)
	level = tonumber(level) or 0
	key = tonumber(key)
	local data = {}
	local tech = GameData:getArrayData('legiontech.dat')
	self.legionactivitiesdata = {}
	table.foreach(tech, function ( _, v )
		if key == tonumber(v.Id) and level == tonumber(v.Level) then
			data = v
		end
	end)
	return data
end

function LegionConfig:getLegionLevelData( level )
	local conf = GameData:getArrayData('legionlevel.dat')
	local data
	local maxLv = 0

	for _, v in pairs(conf) do
		if tonumber(v.Level) == tonumber(level) then
			data = v
		end
		maxLv = maxLv + 1
	end

	return data, maxLv
end

function LegionConfig:getPrayData(key)
	key = tonumber(key)
	local data = {}
	local t = GameData:getArrayData('legionpray.dat')
	table.foreach(t, function ( _, v )
		if key == tonumber(v.Id) then
			data = v
		end
	end)
	return data
end