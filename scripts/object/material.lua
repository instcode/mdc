Material = {
	id = 0
}

function Material:findById(id)
	local materialObj = PlayerCoreData.getMaterialById(id)
	if not materialObj then
		return nil
	end

	o = {}
	o.id = id
	o.material = materialObj
	setmetatable(o, self)
	self.__index = self
	return o
end

function Material:getId()
	return self.material:GetID()
end

--获取合成总数
function Material:GetMergeNum()
	return self.material:GetMergeNum()
end

--合成物品
function Material:GetUseEffect()
	return self.material:GetUseEffect()
end

--获取数量
function Material:getCount()
	return self.material:GetCount()
end

-- 获取名称
function Material:getName()
	return self.material:GetMaterialName()
end

--名称颜色
function Material:getNameColor()
	return self.material:GetMaterialNameColor()
end

--获取资源路径
function Material:getResource()
	return self.material:GetResource()
end

--添加数量
function Material:add(num)
	self.material:Add(num)
end

--减少数量
function Material:dec(num)
	self.material:Dec(num)
end

--设置数量
function Material:setCount(num)
	self.material:SetCount(num)
end

--是否可以合成
function Material:isCombine()
	return self.material:IsCombine()
end

-- 是否在背包显示
function Material:showInBag()
	return self.material:showInBag()
end

-- 获取材料类型
function Material:category()
	return self.material:GetCategory()
end

-- 获取材料描述
function Material:getDesc()
	return self.material:GetDesc()
end

-- 出售价格
function Material:getSellPrice()
	return self.material:GetSellPrice()
end
