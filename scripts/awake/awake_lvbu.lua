AwakeLvBu = {}

function AwakeLvBu:playAwake(ishome, role)
	local isdead = BattleMan:GetInst():isRoleDeadByRid(ishome, AWAKE_ROLE_ID.LVBU)
	if isdead then
		--cclog('lvbu already dead ....')
		return 0,0
	end
	-- 复用美人技能伤害提升的效果
	local buffName = EffectDatabase:sharedDb():GetBuffActivator(1002001, 1)
	local buffPosOffset = tolua.cast(EffectDatabase:sharedDb():GetBuffActivatorOffset(1002001, 1) , 'CCPoint')
	local spine = ElfSpine:create(buffName, 0)
	local pLegion = tolua.cast(BattleMan:GetInst():getLegionByRid(ishome, AWAKE_ROLE_ID.LVBU), 'CLegion')
	pLegion:addChild(spine, 1001)
	spine:setPosition(buffPosOffset)
	spine:setVisible(IsFightEffectOn())

	local awakeDelay = GetBattlePlaySpeedMode() == 0 and 0.5 or 0.25
	return awakeDelay, 0
end