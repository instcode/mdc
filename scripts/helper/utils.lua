function formatStringForMsg(str)
	local content = ''
	local arr = string.split(str,'|')
	local num = #arr
	if num < 2 then
		return str
	else
		arr[1] = string.gsub(arr[1], "[%*]", '%%s')
		if num == 2 then
			content = string.format(GetTextForCfg(arr[1]),GetTextForCfg(arr[2]))
		elseif num == 3 then
			content = string.format(GetTextForCfg(arr[1]),GetTextForCfg(arr[2]),GetTextForCfg(arr[3]))
		elseif num == 4 then
			content = string.format(GetTextForCfg(arr[1]),GetTextForCfg(arr[2]),GetTextForCfg(arr[3]),GetTextForCfg(arr[4]))
		end
	end
	cclog('===========' .. content .. '================')
	return content
end