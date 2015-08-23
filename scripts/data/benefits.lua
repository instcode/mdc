
-------    
local TargetDataFile = 'vipbenefits.dat'

local function genLevelMaxHit()
	local values = GameData:getMapData(TargetDataFile)
	local maxHit = {}

	local function interProcess(level, time)
		local award = string.format('Award%d', level)
		if not maxHit[level] then
			local t, broke = 1, false
			repeat
				local tk = tostring(t)
				if not values[tk] then
					broke = true
				elseif not values[tk][award] or string.len(values[tk][award]) < 3 then
					broke = true
				else
					t = t + 1
				end
			until broke
			t = t - 1
			maxHit[level] = t
		end

		-- access
		if time <= 0 then 
			time = 1
		end
		if time > maxHit[level] then
			time = maxHit[level]
		end
		return tostring(time)
	end

	return function(level, time)
		local award = string.format('Award%d', level)
		local cash  = string.format('CashPrice%d', level)
		time = interProcess(level, time)
		print('time is ' .. time)
		return values[time][award], values[time][cash]
	end,
	function(level, time)
		local title = string.format('Title%d', level)
		local description = string.format('Description%d', level)
		time = interProcess(level, time)
		return GetTextForCfg(values[time][title]), GetTextForCfg(values[time][description])
	end
end

-- Exporting 
getMaterialForTime, getMatDescriptionForTime = genLevelMaxHit()
print('benefits reloaded')