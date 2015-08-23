AwakeZhuGeLiang = {}

function AwakeZhuGeLiang:playAwake(ishome, role)
	local defPosStr = BattleMan:GetInst():getCurTurnDefPosJson()
	if RoleAwake:isInValidStr(defPosStr) then
		--cclog('no one be deffener ........ ')
		return 0,0
	end

	local hitConfJson = EffectDatabase:sharedDb():GetEffectSelfJson(AWAKE_SKILL_ID.ZHUGELIANG, 1)
	if RoleAwake:isInValidStr(hitConfJson) then
		--cclog( 'hitConfJson is nil ... ' )
		return 0,0
	end

	local hitConf = json.decode(hitConfJson)
	local defPos = json.decode(defPosStr)

	local eftDelay = GetBattlePlaySpeedMode() == 0 and 0.4 or 0.2
	for pos, isself in pairs (defPos) do
		if not isself then
			local away = not ishome
			local posi = tolua.cast(BattleMan:GetInst():GetPositionByPos(away, pos), 'CCPoint')
			local atkEffect = CSkillEffect:create()
			atkEffect:show(hitConf['getSkinName'], 0)
			atkEffect:setAnchorPoint(ccp(0.5, 0.5))
			atkEffect:setZOrder(500)
			atkEffect:setScale(0.9)
			atkEffect:setPosition(ccp(posi.x - 10, posi.y + 85))
			RoleAwake:addEffect(atkEffect, false, role)
		end
	end
	return 0,0
end