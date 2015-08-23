AwakeLuoShen = {}

function AwakeLuoShen:playAwake(ishome, role)
	tolua.cast(role, 'CLegion')
	--local alivePosStr = BattleMan:GetInst():getAliveIndexSetJson(ishome)
	local posStr = role:getAwakeInfluencePos()
	if RoleAwake:isInValidStr(posStr) then
		--cclog('all roles are dead ........ ')
		return 0,0
	end
	-- 复用红颜天女散花技能效果 
	local hitConfJson = EffectDatabase:sharedDb():GetEffectSelfJson(5, 3)
	if RoleAwake:isInValidStr(hitConfJson) then
		--cclog( 'hitConfJson is nil ... ' )
		return 0,0
	end
	local effectName = EffectDatabase:sharedDb():GetText(5 ,3)
	if RoleAwake:isInValidStr(effectName) then
		--cclog( 'effectName is nil ... ' )
		return 0,0
	end

	local hitConf = json.decode(hitConfJson)
	--local alivePosArr = json.decode(alivePosStr)
	local influencePosArr = json.decode(posStr)
	for pos, v in pairs (influencePosArr) do
		pos = tonumber(pos)
		if not v then
			pos = pos - 9
		end
		local parent = tolua.cast(BattleMan:GetInst():getLegionByPos(ishome, pos), 'CLegion')
		local posii = tolua.cast(BattleMan:GetInst():GetPositionByPos(ishome, pos), 'CCPoint')
		local posi = ccp(posii.x, posii.y)
		local atkEffect = CSkillEffect:create()
		atkEffect:show(hitConf['getSkinName'], 0)
		atkEffect:setAnchorPoint(ccp(0.5, 0.5))
		atkEffect:setZOrder(parent:getZOrder() + RoleAwake.EFFECT_ZORDER)
		atkEffect:setPosition(ccp(posi.x, posi.y + 150))
		RoleAwake:addEffect(atkEffect, false, parent)

		local nameEffect = CSkillEffect:create()
		nameEffect:show(effectName, 0)
		nameEffect:setZOrder((pos % 3 + 1) * 100 + RoleAwake.EFFECT_ZORDER)
		nameEffect:setPosition(ccp(posi.x, posi.y))
		RoleAwake:addEffect(nameEffect, true , parent)

		local actArr = CCArray:create()
		actArr:addObject(CCMoveBy:create(0.6 ,ccp(0,120)))
		nameEffect:runAction(CCSequence:create(actArr))

		parent:runAction(
			CCCallFunc:create(function ()
				parent:playHurtByAwake(AWAKE_SKILL_ID.LUOSHEN)
		end))
	end

	local awakeDelay = GetBattlePlaySpeedMode() == 0 and 0.7 or 0.35
	return awakeDelay, 0
end