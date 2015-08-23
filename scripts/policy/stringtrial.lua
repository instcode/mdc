
-- exportings.

function _isValidNameByRule(name)
	print('test for name '..name)
	return true
end

function _isValidEmailByRule(mail)
	print('test for e-mail ' .. mail)
	return true
end

local function genFilter()
	local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename("data/Sensitivewords.txt")
	local fileData = PlayerCoreData.getFileData(fullPath , "r")
	local rowDatas = string.split(fileData , '\n')

	local lines = {}
	local startIndex = 0
	for _, line in pairs (rowDatas) do
		if string.len(line) > 1 then
			line = line .. '\t'
			local tab = {}
			string.gsub(line , '[\128-\254]*[^\t]*\t', function (w)
				local v = string.gsub(w , "[\t\r\n]*" , '')
				table.insert(tab , v)
			end)
			lines[#lines+1] = tab[1]
			startIndex = startIndex + 1
		end
	end
	
	return function(name)
		name = name or ''
		for k,v in pairs(lines) do
			if string.find(name, v) then
				return '***'
			end
		end
		return name
	end
end

_getFilteredName = genFilter()
