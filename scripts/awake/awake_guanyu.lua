AwakeGuanYu = {}

function AwakeGuanYu:playAwake(ishome, role)
	local hitConfJson = EffectDatabase:sharedDb():GetEffectSelfJson(AWAKE_SKILL_ID.GUANYU, 1)
	if RoleAwake:isInValidStr(hitConfJson) then
		--cclog( '1004 hitConfJson is nil ... ' )
		return 0,0
	end

	local hitConf = json.decode(hitConfJson)
	tolua.cast(role, 'CLegion')

	local atkEffect = CSkillEffect:create()
	atkEffect:show(hitConf['getSkinName'], 0)
	atkEffect:setAnchorPoint(ccp(0.5 , 0.5))
	atkEffect:setZOrder(500)
	atkEffect:setScale(1.2)
	atkEffect:setVisible(IsFightEffectOn())
	atkEffect:setTag(RoleAwake.BATTLE_EFFECT_TAG)
	if ishome then
		atkEffect:setFlipX(true)
		atkEffect:setPosition(ccp(60, 130))
	else
		atkEffect:setPosition(ccp(-60, 130))
	end
	role:addChild(atkEffect)

	local soundDelay = GetBattlePlaySpeedMode() == 0 and 0.3 or 0.2
	Snd:playSound(soundDelay, '1004_hit.mp3')

	local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(0.25))
		arr:addObject(CCCallFunc:create(function ()
			role:playHurtByAwake(AWAKE_SKILL_ID.GUANYU)
		end))
	role:runAction(CCSequence:create(arr))

	local awakeDelay = GetBattlePlaySpeedMode() == 0 and 0.7 or 0.35
	return awakeDelay, 0
end