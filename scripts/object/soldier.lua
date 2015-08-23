Soldier = {
	stype = 0,
	level = 0
}

function Soldier:create( o )
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	return o
end

-- 获取兵种的表格数据
-- 	local data = soldiler:getData()
-- 	print(data.SoldierName)
-- 	print(data.Desc)
-- 	...
function Soldier:getData()
	local data = GameData:getArrayData('soldier.dat')
	for _, v in pairs(data) do
		if tonumber(v.Soldier) == self.stype and tonumber(v.Level) == self.level then
			return v
		end
	end

	return nil
end

-- 获取兵种资源
function Soldier:getResource()
	local data = self:getData()
	return "uires/ui_2nd/image/" .. data.SoldierUrl
end