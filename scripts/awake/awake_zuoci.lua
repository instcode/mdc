AwakeZuoCi = {}

function AwakeZuoCi:playAwake(ishome, role)
	tolua.cast(role, 'CLegion')
	local defPosStr = BattleMan:GetInst():getCurTurnDefPosJson()
	if RoleAwake:isInValidStr(defPosStr) then
		--cclog('no one be deffener ........ ')
		return 0,0
	end
	local defPos = json.decode(defPosStr)
	local eftDelay = GetBattlePlaySpeedMode() == 0 and 0.8 or 0.4
	local myPos = role:GetAtkPos()
	local myPosi = tolua.cast(BattleMan:GetInst():GetPositionByPos(ishome, myPos), 'CCPoint')
	local endPos = ccpAdd(myPosi, ccp(0,85))
	--把time返回的数值字串倒过来(低位变高位)再取高位6位。这样即使time变化很小但是因为低位变了高位,种子数值变化却很大，就可以使伪随机序列生成的更好一些
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local scheduleId = 0
	local effectArr = {}
	local streakArr = {}
	local streakBegin = false
	local interval = 0
	local totalNum = 0
	local lastPos = -1
	for pos, isself in pairs (defPos) do
		if not isself then
			local away = not ishome
			local pLegion = tolua.cast(BattleMan:GetInst():getLegionByPos(away, tonumber(pos)), 'CLegion')
			if pLegion ~= nil and pLegion:GetDefState() ~= DEFENDER_STATE.IMMUNE then -- 免疫
				lastPos = pos
				interval = interval + 0.1
				totalNum = totalNum + 1
				local posi = tolua.cast(BattleMan:GetInst():GetPositionByPos(away, tonumber(pos)), 'CCPoint')
				local atkEffect = CUIEffect:create()
				atkEffect:Show("zuoci_wave", eftDelay)
				atkEffect:setAnchorPoint(ccp(0.5, 0.5))
				atkEffect:setZOrder(400)
				atkEffect:setPosition(ccp(posi.x - 15, posi.y + 90))
				RoleAwake:addEffect(atkEffect, false, role)
				--球
				local atkEffect2 = CUIEffect:create()
				atkEffect2:Show("light_ball", eftDelay + 0.2)
				atkEffect2:setAnchorPoint(ccp(0.5, 0.5))
				atkEffect2:setZOrder(500)
				atkEffect2:setPosition(ccp(posi.x - 10, posi.y + 85))
				RoleAwake:addEffect(atkEffect2, false, role)
				effectArr[tostring(pos)] = atkEffect2
				--拖尾
				local streak = CCMotionStreak:create(0.2, 3, 20, ccc3(255,255,255), 'uires/ui_2nd/streak/streak01.png')
				streak:setAnchorPoint(ccp(0.5, 0.5))
				streak:setZOrder(300)
				RoleAwake:addEffect(streak, false, role)
				streakArr[tostring(pos)] = streak
				--球的起始坐标
				--local startPos = ccpAdd(posi, ccp(-10,120))
				local startPos = ccpAdd(posi, ccp(-10,85))
	    		local bezier = ccBezierConfig()
	    		-- tan30° ≈ 0.577
	    		-- tan10° ≈ 0.176
				-- 50%的概率走正弦曲线，50%的概率相反
				-- 不要纠结伪随机的问题。。。
	    		coefficient = math.random(176, 577)/1000
	    		flag = math.random() > 0.5 and true or false
	    		if ishome then
	    			if startPos.y >= endPos.y then
	    				if flag then
	    					local bezierx1 = startPos.x - 0.33*(math.abs(startPos.x - endPos.x)) - 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery1 = endPos.y + 0.67*(math.abs(endPos.y - startPos.y)) + 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_1 = ccp(bezierx1, beziery1)
							local bezierx2 = endPos.x + 0.33*(math.abs(startPos.x - endPos.x)) + 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery2 = startPos.y - 0.67*(math.abs(endPos.y - startPos.y)) - 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_2 = ccp(bezierx2, beziery2)
	    				else
							local bezierx1 = endPos.x + 0.67*(math.abs(startPos.x - endPos.x)) + 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery1 = startPos.y - 0.33*(math.abs(endPos.y - startPos.y)) - 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_1 = ccp(bezierx1, beziery1)
							local bezierx2 = startPos.x - 0.67*(math.abs(startPos.x - endPos.x)) - 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery2 = endPos.y + 0.33*(math.abs(endPos.y - startPos.y)) + 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_2 = ccp(bezierx2, beziery2)
	    				end
	    			else
	    				if flag then
	    					local bezierx1 = endPos.x + 0.67*(math.abs(startPos.x - endPos.x)) + 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery1 = startPos.y + 0.33*(math.abs(endPos.y - startPos.y)) + 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_1 = ccp(bezierx1, beziery1)
							local bezierx2 = startPos.x - 0.67*(math.abs(startPos.x - endPos.x)) - 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery2 = endPos.y - 0.33*(math.abs(endPos.y - startPos.y)) - 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_2 = ccp(bezierx2, beziery2)
	    				else
	    					local bezierx1 = startPos.x - 0.33*(math.abs(startPos.x - endPos.x)) - 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery1 = endPos.y - 0.67*(math.abs(endPos.y - startPos.y)) - 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_1 = ccp(bezierx1, beziery1)
	    					local bezierx2 = endPos.x + 0.33*(math.abs(startPos.x - endPos.x)) + 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery2 = startPos.y + 0.67*(math.abs(endPos.y - startPos.y)) + 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_2 = ccp(bezierx2, beziery2)
	    				end
	    			end
	    		else
	    			if startPos.y >= endPos.y then
	    				if flag then
		    				local bezierx1 = startPos.x + 0.33*(math.abs(startPos.x - endPos.x)) + 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery1 = endPos.y + 0.67*(math.abs(endPos.y - startPos.y)) + 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_1 = ccp(bezierx1, beziery1)
							local bezierx2 = endPos.x - 0.33*(math.abs(startPos.x - endPos.x)) - 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery2 = startPos.y - 0.67*(math.abs(endPos.y - startPos.y)) - 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_2 = ccp(bezierx2, beziery2)
						else
							local bezierx1 = endPos.x - 0.67*(math.abs(startPos.x - endPos.x)) - 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery1 = startPos.y - 0.33*(math.abs(endPos.y - startPos.y)) - 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_1 = ccp(bezierx1, beziery1)
							local bezierx2 = startPos.x + 0.67*(math.abs(startPos.x - endPos.x)) + 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery2 = endPos.y + 0.33*(math.abs(endPos.y - startPos.y)) + 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_2 = ccp(bezierx2, beziery2)
						end
	    			else
	    				if flag then
	    					local bezierx1 = endPos.x - 0.67*(math.abs(startPos.x - endPos.x)) - 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery1 = startPos.y + 0.33*(math.abs(endPos.y - startPos.y)) + 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_1 = ccp(bezierx1, beziery1)
							local bezierx2 = startPos.x + 0.67*(math.abs(startPos.x - endPos.x)) + 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery2 = endPos.y - 0.33*(math.abs(endPos.y - startPos.y)) - 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_2 = ccp(bezierx2, beziery2)
	    				else
	    					local bezierx1 = startPos.x + 0.33*(math.abs(startPos.x - endPos.x)) + 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery1 = endPos.y - 0.67*(math.abs(endPos.y - startPos.y)) - 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_1 = ccp(bezierx1, beziery1)
	    					local bezierx2 = endPos.x - 0.33*(math.abs(startPos.x - endPos.x)) - 0.33*coefficient*(math.abs(endPos.y - startPos.y))
							local beziery2 = startPos.y + 0.67*(math.abs(endPos.y - startPos.y)) + 0.33*coefficient*(math.abs(startPos.x - endPos.x))
							bezier.controlPoint_2 = ccp(bezierx2, beziery2)
	    				end
	    			end
	    		end
				bezier.endPosition = endPos
				local moveTo = CCBezierTo:create(eftDelay*2, bezier)
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(eftDelay + 0.4))
				local duration = GetBattlePlaySpeedMode() == 0 and 0.2 or 0.1
				--arr:addObject(CCMoveTo:create(duration, startPos))
				arr:addObject(CCCallFunc:create(function ()
				 	streakBegin = true
				end))
				arr:addObject(CCDelayTime:create(interval))
				arr:addObject(CCEaseIn:create(moveTo, 5))
				arr:addObject(CCCallFunc:create(function ()
					local atkEffect3 = CSkillEffect:create()
					atkEffect3:show('1006_self', 0)
					atkEffect3:setAnchorPoint(ccp(0.5, 0.5))
					atkEffect3:setZOrder(1000)
					atkEffect3:setScale(1)
					atkEffect3:setPosition(endPos)
					RoleAwake:addEffect(atkEffect3, false, role)

					Snd:playSound(0, '1006_self.mp3')

					local atkEffect4 = CSkillEffect:create()
					atkEffect4:show('5_1_text', 0)
					atkEffect4:setAnchorPoint(ccp(0.5, 0.5))
					atkEffect4:setZOrder(1000)
					atkEffect4:setScale(2)
					atkEffect4:setPosition(endPos)
					RoleAwake:addEffect(atkEffect4, false, role)
					atkEffect4:runAction(CCMoveTo:create(duration, ccpAdd(endPos,ccp(0, 50))))

					atkEffect2:removeFromParentAndCleanup(true)
					streak:removeFromParentAndCleanup(true)
					streakArr[tostring(pos)] = nil
					effectArr[tostring(pos)] = nil
				end))
				atkEffect2:runAction(CCSequence:create(arr))
			end
		end
	end

	local turnDelay = GetBattlePlaySpeedMode() == 0 and 2 or 1.2
	if totalNum > 0 then
		turnDelay = turnDelay + interval
		-- 多个球也只用一个计时器
		scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function ()
			if streakBegin then
				for k, v in pairs(streakArr) do
					if v ~= nil then
						v:setPosition(ccp(effectArr[tostring(k)]:getPositionX() - 5, effectArr[tostring(k)]:getPositionY() - 5))
					end
				end
			end
		end,0.001,false)

		-- 当最后一个球也飞到左慈身上后
		if tonumber(lastPos) >= 0 then
			effectArr[tostring(lastPos)]:registerScriptHandler(function (action)
				if action == 'cleanup' then
					if scheduleId ~= 0 then
						CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
						scheduleId = 0
					end
				end
			end)
		end

		-- 当攻击还没结束就退出战斗或者回放战斗
		role:registerScriptHandler(function (action)
			if action == 'cleanup' then
				for k, v in pairs(streakArr) do
					if v ~= nil then
						v:removeFromParentAndCleanup(true)
						effectArr[tostring(k)]:removeFromParentAndCleanup(true)
					end
				end
				if scheduleId ~= 0 then
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
					scheduleId = 0
				end
			end
		end)
	else
		turnDelay = 0
	end
	return 0,turnDelay
end