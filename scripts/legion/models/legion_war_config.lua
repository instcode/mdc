LegionWarConfig = {
	
}

function LegionWarConfig:load()
	-- Load legionwarfieldcity.dat
	self.fieldCity = {}
	local arr = GameData:getArrayData('legionwarfieldcity.dat')
	table.foreach(arr, function ( i, v )
		v.Id = tonumber(v.Id)
		v.Time = tonumber(v.Time)
		v.ScoreBoss = tonumber(v.ScoreBoss)

		if type(v.City) == 'string' then
			local cities = string.split(v.City, '.')
			v.City = {}
			for _, id in pairs(cities) do
				table.insert(v.City, tonumber(id))
			end
		end

		if type(v.Path) == 'string' then
			local paths = string.split(v.Path, '.')
			v.Path = {}
			for _, id in pairs(paths) do
				table.insert(v.Path, tonumber(id))
			end
		end

		table.insert(self.fieldCity, v)
	end)

	-- Load legionwarschedule.dat
	self.legionwarschedule = GameData:getArrayData('legionwarschedule.dat')
end

function LegionWarConfig:getFieldCityByID( cityID )
	return self.fieldCity[cityID]
end

function LegionWarConfig:getWarScheduleByProgress( progressID )
	for i, v in pairs(self.legionwarschedule) do
		if v.Progress == tostring(progressID) then
			return v
		end
	end

	print('---- No progressID in legionwarschedule.dat ---')
	return nil
end

-- cityId 洛阳boss传1 主城boss传2 
function LegionWarConfig:getLegionBattleBoss(cityId, bossId)
	cityId = tonumber(cityId)
	bossId = tonumber(bossId)
	local t = GameData:getArrayData('legionwarboss.dat')
	table.foreach(t, function ( _, v )
		if bossId == tonumber(v.Days) and cityId == tonumber(v.Type) then
			data = v
		end
	end)
	return data
end

function LegionWarConfig:getPriceByTimes(times, thing)
	times = tonumber(times)
	times = times + 1
	local price = 0
	local t = GameData:getArrayData('buy.dat')
	if t[times][thing] ~= nil and t[times][thing] ~= '' then
		price = tonumber(t[times][thing])
	end
	return price
end

function LegionWarConfig:getRewardData( warfield , rank )
	local conf = GameData:getArrayData('legionwarreward.dat')
	local data
	for _, v in pairs(conf) do
		if tonumber(v.WarField) == tonumber(warfield) and tonumber(v.Rank) == tonumber(rank) then
			data = v
		end
	end
	
	return data
end

-- 1 = 皇帝  2 = 将军  3 = 丞相
function LegionWarConfig:getBuffData( id )
	local conf = GameData:getArrayData('legionwarreward.dat')
	local data
	for _, v in pairs(conf) do
		if tonumber(id) == tonumber(v.Id) then
			data = v
		end
	end
	return data
end