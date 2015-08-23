AwakeZhaoYun = {}

function AwakeZhaoYun:playAwake(ishome, role)
	tolua.cast(role, 'CLegion')
	local defPos = role:GetFirstDefPos()
	if defPos >= 0 then
		local defPosStr = BattleMan:GetInst():getCurTurnDefPosJson()
		if RoleAwake:isInValidStr(defPosStr) then
			--cclog('no one be deffener ........ ')
			return 0,0
		end
		local defPosObj = json.decode(defPosStr)

		local awakeAttackPos = defPos
		if defPosObj[tostring(defPos + 6)] ~= nil then
			awakeAttackPos = defPos + 6
		elseif defPosObj[tostring(defPos + 3)] ~= nil then
			awakeAttackPos = defPos + 3
		end

		local posi = tolua.cast(BattleMan:GetInst():GetPositionByPos(not ishome , awakeAttackPos) , 'CCPoint')
		local pLegion = tolua.cast(BattleMan:GetInst():getSimilarLegionById(AWAKE_ROLE_ID.ZHAOYUN, ishome), 'CLegion')
		local posx = ishome and 80 or -100
		local skillId = role:GetAtkSkill()
		pLegion:setPosition(role:getPosition())
		pLegion:setOpacity(150)
		pLegion:setVisible(true)
		pLegion:flipSoldiers(ishome)
		local duration = GetBattlePlaySpeedMode() == 0 and 0.2 or 0.1
		local arr = CCArray:create()
		arr:addObject(CCMoveTo:create(duration, ccpAdd(posi, ccp(posx, 0))))
		arr:addObject(CCCallFunc:create(function ()
			pLegion:doAction(skillId, ishome)
		end))
		pLegion:runAction(CCSequence:create(arr))
	end
	return 0,0
end