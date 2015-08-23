PawnGoods = {
	id = 0
}

function PawnGoods:findById(id)
	local pawnObj = PlayerCoreData.getPawnById(id)
	if not pawnObj then
		return nil
	end

	o = {}
	setmetatable(o, self)
	self.__index = self
	self.id = id
	return o
end

--获取数量
function PawnGoods:getCount()
	return PlayerCoreData.getPawnById(self.id):GetCount()
end

--获取资源路径
function PawnGoods:getResource()
	return PlayerCoreData.getPawnById(self.id):GetResource()
end

--添加数量
function PawnGoods:add(num)
	PlayerCoreData.getPawnById(self.id):Add(num)
end

--减少数量
function PawnGoods:dec(num)
	PlayerCoreData.getPawnById(self.id):Dec(num)
end

--设置数量
function PawnGoods:setCount(num)
	PlayerCoreData.getPawnById(self.id):SetCount(num)
end