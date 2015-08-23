local fileName = 'godoffset.dat'


-- 根据id获取实体化模型坐标偏移量
function getGodOffset( flip , id )
	local conf = GameData:getArrayData(fileName)

	local offsetX = 0
	local offsetY = 0
	
	for _, v in pairs ( conf ) do
		if tonumber(v.Id) == tonumber(id) then
			local str = flip and v.Right or v.Left
			local tab = string.split(str , '|')
			if tab and #tab == 2 then
				offsetX = tonumber(tab[1])
				offsetY = tonumber(tab[2])
			end
		end
	end
	-- cclog('offsetX = ' .. offsetX .. ' , offsetY = ' .. offsetY)
	return offsetX .. '|' .. offsetY
end

function getSoldierScale( godLv , rid )
	local conf = GameData:getArrayData(fileName)

	local scale = 0.9
	for _, v in pairs ( conf ) do
		if tonumber(godLv) > 0 and tonumber(v.Id) == tonumber(rid) then
			scale = tonumber(v.Scale)
		end
	end

	return scale
end