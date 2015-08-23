AwakeTongYuan = {}

function AwakeTongYuan:playAwake(ishome, role)
	tolua.cast(role, 'CLegion')
	local defPosStr = BattleMan:GetInst():getCurTurnDefPosJson()
	if RoleAwake:isInValidStr(defPosStr) then
		--cclog('no one be deffener ........ ')
		return 0,0
	end
	local defPos = json.decode(defPosStr)
	for pos, isself in pairs (defPos) do
		if not isself then
			local away = not ishome
			local pLegion = tolua.cast(BattleMan:GetInst():getLegionByPos(away, tonumber(pos)), 'CLegion')
			pLegion:runAction(
				CCCallFunc:create(function ()
					local atkEffect = CSkillEffect:create()
					atkEffect:show('1008_hit', 0)
					atkEffect:setAnchorPoint(ccp(0.5, 0))
					atkEffect:setZOrder(1000)
					atkEffect:setScale(0.8)
					if not ishome then
						atkEffect:setFlipX(true)
						atkEffect:setPosition(ccp(100, -50))
					else
						atkEffect:setPosition(ccp(-100, -50))
					end
					pLegion:addChild(atkEffect)
			end))
		end
	end
	return 0, 0
end