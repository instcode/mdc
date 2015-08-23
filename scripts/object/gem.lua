Gem = {
	id = 0
}

function Gem:findById( id )
	local gemObj = PlayerCoreData.getGemById(id)
	if not gemObj then
		return nil
	end

	o = {}
	setmetatable(o, self)
	self.__index = self
	self.id = id
	return o
end

--获取宝石数量
function Gem:getCount()
	return PlayerCoreData.getGemById(self.id):GetCount()
end

--增加宝石数量
function Gem:add(num)
	PlayerCoreData.getGemById(self.id):Add(num)
end

--减少宝石数量
function Gem:dec(num)
	PlayerCoreData.getGemById(self.id):Dec(num)
end

-- 获取宝石名称
function Gem:getName()
	return PlayerCoreData.getGemById(self.id):GetGemName()
end

-- 获取宝石名称颜色
function Gem:getNameColor()
	return PlayerCoreData.getGemById(self.id):GetNameColor()
end

--获取宝石资源路径
function Gem:getResource()
	return PlayerCoreData.getGemById(self.id):GetResource()
end

--获取宝石加成的属性名称
function Gem:getAttrName()
	return PlayerCoreData.getGemById(self.id):GetAttrName()
end

--获取宝石加成属性的数值
function Gem:getAttrValue()
	return PlayerCoreData.getGemById(self.id):GetAttrValue()
end

--获取宝石quality等级
function Gem:getQuality()
	return PlayerCoreData.getGemById(self.id):GetQualityLevel()
end

--获取宝石描述
function Gem:getDesc()
	return PlayerCoreData.getGemById(self.id):GetDesc()
end

--获取宝石类型
function Gem:getType()
	return PlayerCoreData.getGemById(self.id):GetGEM_TYPE()
end

--获取宝石等级
function Gem:getLevel()
	return PlayerCoreData.getGemById(self.id):GetGemLevel()
end

--获取宝石出售价格
function Gem:getPrice()
	return PlayerCoreData.getGemById(self.id):GetSellPrice()
end

--获取宝石名字资源
function Gem:GetAttrNameRes()
	return PlayerCoreData.getGemById(self.id):GetAttrNameRes()
end

--宝石是否满级
function Gem:isMax()
	return PlayerCoreData.getGemById(self.id):IsMax()
end

-- 获取属性中文名
function Gem.getAttributeViewName( attr )
	local s = nil
	if attr == 'attack' then
		s = 'E_STR_ATTR_ATTACK_NAME'
	elseif attr == 'defence' then
		s = 'E_STR_ATTR_DEFENSE_NAME'
	elseif attr == 'mdefence' then
		s = 'E_STR_ATTR_MAGIC_DEFENSE_NAME'
	elseif attr == 'magic' then
		s = 'E_STR_ATTR_MAGIC_NAME'
	elseif attr == 'health' then
		s = 'E_STR_ATTR_SOLDIER_NAME'
	elseif attr == 'critdamage' then
		s = 'E_STR_ATTR_CRITICAL_NAME'
	elseif attr == 'fortitude' then
		s = 'E_STR_ATTR_FORTITUDE_NAME'
	elseif attr == 'block' then
		s = 'E_STR_ATTR_BLOCK_NAME'
	elseif attr == 'power' then
		s = 'E_STR_ATTR_MORALE_NAME'
	end

	if s == nil then
		error('attr get view name err!attr == ' .. attr)
	end

	return getLocalStringValue(s)
end
