Equip = {
	id = 0
}
function Equip:findById( id )
	local equipObj = PlayerCoreData.getEquipById(id)
	if not equipObj then
		return nil
	end

	o = {}
	setmetatable(o, self)
	self.__index = self
	self.id = id
	self.equip = equipObj
	return o
end

-- 获取装备名称
function Equip:getName()
	return self.equip:GetEquipName()
end

function Equip:getGemsID()
	local str = self.equip:GetGemsIDJson()
	return json.decode(str)
end
-- 强化等级
function Equip:getStrengthLevel()
	return self.equip:GetStrengthLevel()
end
-- 打造等级
function Equip:getLevel()
	return self.equip:GetLevel()
end

-- 获取颜色
function Equip.getColor( strengthLevel )
	if strengthLevel < 10 then
		return COLOR_TYPE.WHITE
	elseif strengthLevel < 20 then
		return COLOR_TYPE.GREEN
	elseif strengthLevel < 40 then
		return COLOR_TYPE.BLUE
	elseif strengthLevel < 60 then
		return COLOR_TYPE.PURPLE
	else
		return COLOR_TYPE.ORANGE
	end
end
function Equip:GetBuildMaterial( buildtype )
	return self.equip.GetBuildMaterial(buildtype)
end