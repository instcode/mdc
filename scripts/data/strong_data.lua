-- *********************************
-- ************ 变强 ***************
-- *********************************


local strongHopeFile = 'strong_hope.dat'
local strongPriceFile = 'strongprice.dat'
local strongFile = 'strong.dat'

function getStrongHopeData( level )
	local conf = GameData:getArrayData(strongHopeFile)
	local data
	table.foreach(conf , function (_, v)
		if tonumber(v['Level']) == tonumber(level) then
			data = v
		end
	end)
	return data
end

function getPropretyPriceData( level )
	local conf = GameData:getArrayData(strongPriceFile)
	local data
	table.foreach(conf , function (_, v)
		if tonumber(v['Level']) == tonumber(level) then
			data = v
		end
	end)
	return data
end

function getStrongData( id )
	local conf = GameData:getArrayData(strongFile)
	local data
	table.foreach(conf , function (_, v)
		if tonumber(v['Id']) == tonumber(id) then
			data = v
		end
	end)
	return data
end