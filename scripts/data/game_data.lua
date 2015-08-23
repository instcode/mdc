GameData = {
	data = {}
}


local function readGameDataFile(filename)
	local relatePath = 'data/' .. filename
	local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(relatePath)

	local chunk = PlayerCoreData.getFileData(fullPath , "r")
 	if not chunk then
 		error("*** Failed to read data file: " .. fullPath)
 	end

 	chunk = string.gsub(chunk, "[\r]*", '')
 	local rowDatas = string.split(chunk , '\n')
	local lineIndex = 0 			-- 配置文件行号
	local valueIndex = 0
	local keyTable = {} 			-- 存储第二行keys的table
	local valueTable = {} 			-- 存储数据的table

	local validReg = "[\t\n\r]*" 				-- 数据格式匹配样式
	local keyReg = "%a*%d*\t" 					-- key格式匹配
	local valReg = '[\128-\254]*[^\t]*\t' 		-- value格式匹配

	for _, line in pairs (rowDatas) do
		
		if string.len(line) > 1 then

			lineIndex = lineIndex + 1
		
			line = string.gsub(line, "[\r\n]*", '')

			repeat
				if line == '' then 
					break
				end

				line = line .. "\t" 	-- 在末尾添加\t适合以上匹配模式
				
				if lineIndex <= 1 then
					print('--- Ingore first line ---')
				elseif lineIndex == 2 then 	-- 第二行为keys，其他为数据
					string.gsub(line, keyReg, function(key)
						local keyName = string.gsub(key, validReg, '')
						table.insert(keyTable, keyName)
					end)
				else
					valueIndex = valueIndex + 1
					valueTable[valueIndex] = valueTable[valueIndex] or {}
					local keyIndex = 1
					string.gsub(line, valReg, function(val)
						local realKey = keyTable[keyIndex]
						if realKey then
							local realValue = string.gsub(val, validReg, '')
							valueTable[valueIndex][realKey] = realValue
							keyIndex = keyIndex + 1
						end
					end)
				end
			until true
		end		
	end -- end of for
	return keyTable, valueTable
end

function GameData:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function GameData:purge()
	if type(self.data) == 'table' then
		print('Some clean clean clean')
		self.data = {}
	end
end

function GameData:getArrayData(filename)
	if not self.data[filename] then
		local keys, values = readGameDataFile(filename)
		self.data[filename] = {}
		self.data[filename].keys = keys
		self.data[filename].values = values
	end

	return self.data[filename].values
end

function GameData:getMapData(filename)
	if not self.data[filename] then
		local keys, values = readGameDataFile(filename)
		self.data[filename] = {}
		self.data[filename].keys = keys
		self.data[filename].values = values
	end

	local result = {}
	for _, line in pairs(self.data[filename].values) do
		local mainKey = self.data[filename].keys[1] -- 使用第一列作为主键
		local mainKeyVal = line[mainKey]
		result[mainKeyVal] = line
	end

	return result
end

function GameData:getGlobalValue( k )
	if self.data['global'] == nil then
		local path
		local confData = {}
		local startIndex

		-- global.dat --
		path = CCFileUtils:sharedFileUtils():fullPathForFilename('data/' .. 'global.dat')
		local chunk = PlayerCoreData.getFileData(path , "r")
	 	if not chunk then
	 		error("*** Failed to read data file: " .. fullPath)
	 	end

	 	local rowDatas = string.split(chunk, '\n')
		-- file  = assert(io.open(path , 'r') , 'failed to read global.dat')
		startIndex = 0

		for _, line in pairs (rowDatas) do
			if string.len(line) > 1 then
				if startIndex > 1 then				--从第二行开始读取--
					line = line .. '\t'
					local tab = {}
					string.gsub(line , '[\128-\254]*[^\t]*\t', function (w)
						local v = string.gsub(w , "[\t\r\n]*" , '')
						table.insert(tab , v)
					end)
					confData[tab[2]] = tab[3]
				end
				startIndex = startIndex + 1
			end
		end
		-- file:close()

		-- globalserver.dat --
		path = CCFileUtils:sharedFileUtils():fullPathForFilename('data/' .. 'globalserver.dat')
		local chunk = PlayerCoreData.getFileData(path , "r")
	 	if not chunk then
	 		error("*** Failed to read data file: " .. fullPath)
	 	end
	 	rowDatas = string.split(chunk , '\n')
		-- file  = assert(io.open(path , 'r') , 'failed to read globalserver.dat')
		startIndex = 0
		for _, line in pairs (rowDatas) do
			if string.len(line) > 1 then
				if startIndex > 1 then				--从第二行开始读取--
					line = line .. '\t'
					local tab = {}
					string.gsub(line , '[\128-\254]*[^\t]*\t', function (w)
						local v = string.gsub(w , "[\t\r\n]*" , '')
						table.insert(tab , v)
					end)
					confData[tab[2]] = tab[3]
				end
				startIndex = startIndex + 1
			end
		end
		-- file:close()

		self.data['global'] = confData
	end

	return self.data['global'][k]
end

-- One word is enough
-- Fuck off the long verbose singleton access
-- 
function getGlobalIntegerValue(k, defaultVal)
	-- Zero is not logically false.
	defaultVal = defaultVal or 0
	return tonumber(GameData:getGlobalValue(k)) or defaultVal
end

function GetTextForCfg(key)
	local v = LD_TOOLS:GetTextForCfg(key)
	return v
end