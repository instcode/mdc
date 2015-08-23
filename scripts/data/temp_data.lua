local tempData = {}

function getTempValue(key)
	local value = tempData[tostring(key)] or 0
	return value
end

function setTempValue(key, value)
	print('key = ' .. key)
	print('value = ' .. value)
	tempData[tostring(key)] = value
end