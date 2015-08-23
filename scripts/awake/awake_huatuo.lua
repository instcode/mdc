AwakeHuaTuo = {}

function AwakeHuaTuo:playAwake(ishome, role)
	tolua.cast(role, 'CLegion')
	local posStr = role:getAwakeInfluencePos()
	if RoleAwake:isInValidStr(posStr) then
		return 0,0
	end
	local influencePosArr = json.decode(posStr)
	for pos, v in pairs (influencePosArr) do
		pos = tonumber(pos)
		if not v then
			pos = pos - 9
		end
		local parent = tolua.cast(BattleMan:GetInst():getLegionByPos(ishome, pos), 'CLegion')
		local posi = tolua.cast(BattleMan:GetInst():GetPositionByPos(ishome, pos), 'CCPoint')
		parent:runAction(
			CCCallFunc:create(function ()
				local atkEffect = CSkillEffect:create()
				atkEffect:show('1007_self', 0)
				atkEffect:setAnchorPoint(ccp(0.5, 0))
				atkEffect:setZOrder(1000)
				atkEffect:setPosition(ccpAdd(posi, ccp(0, -20)))
				atkEffect:setScale(0.8)
				RoleAwake:addEffect(atkEffect, false, parent)
				parent:reviveByAwake(AWAKE_SKILL_ID.HUATUO)
		end))
	end
	local awakeDelay = GetBattlePlaySpeedMode() == 0 and 0.7 or 0.35
	return awakeDelay, 0
end