RoleCard = {
	id = 0
}

function RoleCard:findById( id )
	local card = PlayerCoreData.getRoleCardById(id)
	if not card then
		return nil
	end

	o = {}
	o.id = id
	o.card = card
	setmetatable(o, self)
	self.__index = self
	return o
end

function RoleCard:getData()
	local data = GameData:getArrayData('role.dat')
	for _, v in pairs(data) do
		if tonumber(v.Id) == tonumber(self.id) then
			return v
		end
	end

	return nil
end

function RoleCard:getNameColor()
	return self.card:GetRoleNameColor()
end

function RoleCard:getCardIcoBgImg()
	return self.card:GetIconFrame()
end

function RoleCard:getName()
	return self.card:GetRoleName()
end

function RoleCard:getSoldierType()
	local data = self:getData()
	local soldier = tonumber(data.Soldier)
	if soldier == 1 then
		return 'uires/ui_2nd/com/panel/common/dao.png'
	elseif soldier == 2 then
		return 'uires/ui_2nd/com/panel/common/qiang.png'
	elseif soldier == 3 then
		return 'uires/ui_2nd/com/panel/common/qibing.png'
	elseif soldier == 4 then
		return 'uires/ui_2nd/com/panel/common/mou.png'
	elseif soldier == 5 then
		return 'uires/ui_2nd/com/panel/common/hong.png'
	end
end

function RoleCard:getQuantity()
	return self.card:GetRoleQuality()
end

function RoleCard:getRoleFrameImg(type)
	return self.card:GetRoleIcon(type)
end