function reloadLua(listStr)
	local fileList = string.split(listStr, ';')
	for k, v in pairs (fileList) do
		if v ~= '' then
			local index = string.find(v, '%.') - 1
			local file = string.sub(v, 1, index)
			if file ~= 'ceremony/launchers/startup' then
				if package.loaded[file] ~= nil then
					package.loaded[file] = nil
					require(file)
				end
			end
		end
	end
end