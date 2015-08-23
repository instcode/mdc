

local dataFileName = 'girlskill.dat'
local cache = {}
local ids   = {}

local function debugPrt()
	for k,_ in pairs(cache) do
		print(k)
	end
end

local function initCache()
	-- print('site 100')
	local data = GameData:getArrayData(dataFileName)
	ids = {}
	for _,v in ipairs(data) do
		-- Format new key
		local newKey = v.Id .. ':' .. v.Skill
		cache[newKey] = v
		ids[#ids+1] = v.Id
	end
	debugPrt()
	-- print('site 200')
end

function getDivinityIndexOffset(id)
	local rv = 0
	id = tonumber(id)
	for i=1,#ids do
		if tonumber(ids[i]) == id then
			rv = i
		end
	end
	return rv
end

function getDivinityConfig(girlID, skillID)
	skillID = skillID or 1
	local key = tostring(girlID) .. ':' .. tostring(skillID)
	if not cache[key] then 
		print('error retrieving girl config for ' .. key)
	end
	return cache[key]
end

function getDivinityField(girlID, skillID, field)
	if not field then
		error('no field for me')
	end

	skillID = skillID or 1
	local key = tostring(girlID) .. ':' .. tostring(skillID)
	if not cache[key] then
		error('no such key')
	end
	return cache[key][field]
end

function getBeautyIDS()
	return ids
end

-- starts up
initCache()
print('init beauty cache again (20000)')