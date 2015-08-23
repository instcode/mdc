Role = {
	id = 0
}

-- 通过rid查询武将
function Role:findById( rid )
	local role = PlayerCore:getRoleObjectByID(rid)
	if not role then
		return nil
	end

	o = {}
	o.id = rid
	o.role = role
	setmetatable(o, self)
	self.__index = self
	return o
end

function Role:getLevel()
	return self.role:GetRoleLevel()
end

function Role:SetLevel(level)
	return self.role:SetLevel(level)
end

-- 神将等级
function Role:getGodLevel()
	return self.role:GetGodLevel()
end

-- 神将等级
function Role:setGodLevel(level)
	return self.role:SetGodLevel(level)
end

-- 攻击
function Role:getAttack()
	return self.role:GetAttack()
end

-- 武防
function Role:getDefence()
	return self.role:GetDefence()
end

-- 魔防
function Role:getMDefense()
	return self.role:GetResist()
end

-- 士兵
function Role:getSoldierHealth()
	return self.role:GetHealth()
end

-- 暴击
function Role:getCritics()
	return self.role:GetCrit()
end

-- 刚毅
function Role:getFortitude()
	return self.role:GetFortitude()
end

-- 格挡
function Role:getBlock()
	return self.role:GetBlock()
end

-- 闪避
function Role:getMiss()
	return self.role:GetMiss()
end

-- Wreck
function Role:getWreck()
	return self.role:GetWreck()
end

-- 命中
function Role:getHit()
	return self.role:GetHit()
end

-- 士气
function Role:getMorale()
	return self.role:GetMorale()
end

function Role:getFightForce()
	return self.role:GetFightForce()
end

-- 获取武将资源路径，type = RESOURCE_TYPE
-- function Role:getResource( type )
-- 	return self.role:GetRoleIcon(type)
-- end

-- 获取武将名称
function Role:getName()
	return self.role:GetRoleName()
end

-- 获取武将颜色
function Role:getNameColor()
	return self.role:GetRoleNameColor()
end

-- 获取武将品质
function Role:getQuality()
	return self.role:GetRoleQuality()
end

-- 武将是否上阵
function Role:isAssigned()
	return self.role:IsAssigned()
end

-- 获取培养值
function Role:getGrowth()
	return self.role:GetGrowth()
end

-- 获取武将某个位置的装备，site = EQUIP_SITE
function Role:getEquipBySite( site )
	local equipObj = self.role:GetEquip(site)
	if not equipObj then
		return nil
	end

	equip = Equip:findById(equipObj:GetID())
	return equip
end

-- 获取武将经验
function Role:getExp()
	return self.role:GetCurrExp()
end

-- 获取武将当前级别总经验
function Role:GetCurSumExp()
	return self.role:GetCurSumExp()
end

-- 获取武将Max经验
function Role:GetMaxExp()
	return self.role:GetMaxExp()
end


-- 设置武将经验
function Role:setExp( exp )
	self.role:SetExp(exp)
end

-- 获取武将兵种
function Role:getSoldier()
	local role = self.role
	local stype = role:GetSoldierType()
	local level = role:GetRoleSoldierLevel()

	return Soldier:create{stype = stype, level = level}
end

-- 获取武将所有技能
function Role:getSkills()
	return self.role:getSkills()
end

-- 经验百分比
function Role:GetExpPercent()
	return self.role:GetExpPercent()
end

-- 获取当前激活的主动技能
function Role:getCurrActiveSkill()
	return self.role:GetCurrActiveSkill()
end

--  获取技能的等级
function Role:getCurSkillLevel( skillid )
	return self.role:GetCurrSkillLevel( skillid )
end

--  开启技能的等级
function Role:getSkillOpenLevel( skillid )
	return self.role:GetSkillOpenLevel( skillid )
end

function Role:getSoulLevel()
	return self.role:GetSoulLevel()
end

-- 获取武将表格数据
function Role:getData()
	return Role.getDataById(self.id)
end

function Role.getDataById( rid )
	local allData = GameData:getArrayData('role.dat')
	for _, v in pairs(allData) do
		if tonumber(v.Id) == tonumber(rid) then
			return v
		end
	end

	return nil
end

function Role.getResourceByIdAndResType( rid, resType )
	local data = Role.getDataById(rid)
	if data then
		local url = data.Url
		local name = string.gsub(url, 'hero/', '')
		name = string.gsub(name, '_big.png$', '')

		if resType == RESOURCE_TYPE.BIG or resType == RESOURCE_TYPE.NORMAL then
			return string.format("uires/ui_2nd/image/hero/%s_big.png", name)
		elseif resType == RESOURCE_TYPE.ICON then
			return string.format("uires/ui_2nd/image/hero/%s_icon.png", name)
		elseif resType == RESOURCE_TYPE.WEAPON_ICON_SMALL then
			if tonumber(data.Soldier) < 4 then
				return 'uires/ui_2nd/com/panel/common/attack_icon.png'
			else
				return 'uires/ui_2nd/com/panel/common/magic_icon.png'
			end
		end
	end	

	return ''
end

function Role:getResource( resType )
	return Role.getResourceByIdAndResType(self.id, resType)
end

function Role.GetRoleIcoBgImg( quality )
	if quality == ROLE_QUALITY.WHITE then
		return 'uires/ui_2nd/com/panel/common/frame.png'
	elseif quality == ROLE_QUALITY.BLUE then
		return 'uires/ui_2nd/com/panel/common/frame.png'
	elseif quality == ROLE_QUALITY.PURPLE then
		return 'uires/ui_2nd/com/panel/common/frame_purple.png'
	elseif quality == ROLE_QUALITY.ORANGE then
		return 'uires/ui_2nd/com/panel/common/frame_yellow.png'
	elseif quality == ROLE_QUALITY.ARED then
		return 'uires/ui_2nd/com/panel/common/frame_red.png'
	elseif quality == ROLE_QUALITY.SRED then
		return 'uires/ui_2nd/com/panel/common/frame_sred.png'
	else
		return 'uires/ui_2nd/com/panel/common/frame_yellow.png'
	end
end

function Role.GetRoleAttrIco(attr)
	if attr == ROLE_ATTR.ATTACK then
		return 'uires/ui_2nd/com/panel/common/attack_icon.png'
	elseif attr == ROLE_ATTR.MAGIC then
		return 'uires/ui_2nd/com/panel/common/magic_icon.png'
	elseif attr == ROLE_ATTR.DEFENCE then
		return 'uires/ui_2nd/com/panel/common/defense_icon.png'
	elseif attr == ROLE_ATTR.MDEFENCE then
		return 'uires/ui_2nd/com/panel/common/magic_defense_icon.png'
	elseif attr == ROLE_ATTR.HEALTH then
		return 'uires/ui_2nd/com/panel/common/soldier_icon.png'
	elseif attr == ROLE_ATTR.FORTITUDE then
		return 'uires/ui_2nd/com/panel/common/fortitude_icon.png'
	elseif attr == ROLE_ATTR.HIT then
		return 'uires/ui_2nd/com/panel/common/hit_icon.png'
	elseif attr == ROLE_ATTR.UNBLOCK then
		return 'uires/ui_2nd/com/panel/common/unblock_icon.png'
	elseif attr == ROLE_ATTR.BLOCK then
		return 'uires/ui_2nd/com/panel/common/block_icon.png'
	elseif attr == ROLE_ATTR.CRITDAMAGE then
		return 'uires/ui_2nd/com/panel/common/critdamage_icon.png'
	elseif attr == ROLE_ATTR.MISS then
		return 'uires/ui_2nd/com/panel/common/miss_icon.png'
	end
end

function getAwakeAddAttrByTypeAndRid( attrtype  ,  rid )
	local roleObj = Role:findById( rid )

	if roleObj == nil then
		return 0
	end

	local godLv = roleObj:getGodLevel()
	if godLv <= 0 then
		return 0
	end	

	local conf = GameData:getArrayData('roleawake.dat')
	local data = nil
	for k , v in pairs ( conf ) do
		if tonumber(v.Id) == tonumber(rid) then
			data = v
		end
	end

	if data == nil then
		return 0
	end

	local attrs = {}

	for i = 1 , 4 do
		local attrStr = data['Attribute' .. i]
		local attrName = tostring(string.split( attrStr , ':')[1])
		local attrValue = tonumber(string.split( attrStr , ':')[2])
		attrs[attrName] = attrValue
	end

	return attrs[attrtype] or 0
end
