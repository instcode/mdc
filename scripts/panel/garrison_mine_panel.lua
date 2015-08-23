GarrisonMinePanel = {}
function genGarrisonMinePanel(isWin,getDate,mineId)
 	-- body
 	-- minepanel ui
	local mineScene
	local minePanel 
	local mineRoot
	local mineTitle
	local mineCloseBtn
	local mineHelpBtn
	local leftBgImg
	local nameBgImg
	local zhanBgImg
	local blackFrameImg
	local addImg
	local minePic 
	local roleCard
	local garrisonRoleImg 
	local roleType 
	local roleName 
	local roleForce 
	local buzhenBtn 
	local mineMine 
	local garrisonBtn
	local rightCard 
	local zhenxingPl
	local zhenxingInfo
	local zhenxingImg
	local placeArray = {}
	local howPlayPl
	local howPlayTx
	local howPlayInfoTx
	local noneGarrisonTx
	local awardBgImg
	local viewBtn
	local challengeBtn
	local awardSv
	local winToGetTx
	local zhuShouRewardTx
	local getRewardBtn
	local challengeAwardSv
	local stoneAwardPl
	local garrisonCDTime
	local getAwardCDTimeTx
	local roleNameColor

	local roleTypeRes
	local soldierTypeRes
	local isShowEmBattle = false

	local howPlaySv
	local patrolSv
	local eventSv
	local MineLight

	--上阵武将信息
	local userInfoData = {}

	--res
	local RES_DAO = 'uires/ui_2nd/com/panel/common/dao.png'
	local RES_QIANG = 'uires/ui_2nd/com/panel/common/qiang.png'
	local RES_QI = 'uires/ui_2nd/com/panel/common/qibing.png'
	local RES_MOU = 'uires/ui_2nd/com/panel/common/mou.png'
	local RES_HONG = 'uires/ui_2nd/com/panel/common/hong.png'

	local DAO_ICON = 'uires/ui_2nd/com/panel/pass/dao.png'
	local QIANG_ICON = 'uires/ui_2nd/com/panel/pass/qiang.png'
	local QI_ICON = 'uires/ui_2nd/com/panel/pass/qi.png'
	local HONG_ICON = 'uires/ui_2nd/com/panel/pass/red.png'
	local MOU_ICON = 'uires/ui_2nd/com/panel/pass/meng.png'

	local CHALLENGE_ICON = 'uires/ui_2nd/com/panel/garrison/can_challenge.png'
	local EMPTY_ICON = 'uires/ui_2nd/com/panel/garrison/empty.png'
	local REWARD_ICON = 'uires/ui_2nd/com/panel/garrison/award.png'

	--读表
	local patrolBattleConf = GameData:getArrayData('patrolbattle.dat')
	local patrolEventConf = GameData:getArrayData('patrolevent.dat')
	local patrolIntervalConf = GameData:getArrayData('patrolinterval.dat')
	local patrolTypeConf = GameData:getArrayData('patroltype.dat')
	local monsterConf = GameData:getArrayData('monster.dat')
	local materialConf = GameData:getArrayData('material.dat')
	local roleConf = GameData:getArrayData('role.dat')
	local roleCCPCfg = GameData:getArrayData('patrolccp.dat')

	local defalutCCP = ccp(15,40)
	roleIdTab = {}

	--读取坐标
	local function getCCPFromTab()
		-- body
		for i , v in pairs(roleCCPCfg) do 
			local roleId = tonumber(v.RoleId)
			local ccpx = tonumber(v.CCPX)
			local ccpy = tonumber(v.CCPY)
			roleIdTab[roleId] = ccp(ccpx,ccpy)
		end
	end


local function jump(pTarget, jumpInterval ,jumpHigh )
	-- body
	local jumpInterval = jumpInterval or 1.4
	local jumpHigh = jumpHigh or 15

	if not pTarget then
		return
	end
	pTarget:stopAllActions()
	local bottomPosition = pTarget:getPosition()
	local topPosition = ccp(bottomPosition.x, bottomPosition.y + jumpHigh)
	local bottomPosition2 = ccp(bottomPosition.x, bottomPosition.y - jumpHigh)

	local pMove2Top = CCMoveTo:create(jumpInterval / 2, topPosition)
	local pMove2Bottom = CCMoveTo:create(jumpInterval / 2, bottomPosition2)
	local array = CCArray:create()
	array:addObject(pMove2Top)
	array:addObject(pMove2Bottom)
	local pSeq = CCSequence:create(array)
	local pRepeat = CCRepeatForever:create(pSeq)
	pTarget:runAction(pRepeat)

end 

	local function initShuoMing(Sv , type)
		-- body
		Sv:setClippingEnable(true)
		Sv:scrollToTop()
		Sv:setVisible(true)
		if type == 1 then 
			local howPlayInfoPl = tolua.cast(Sv:getChildByName('info_panel'),'UIPanel')
			for i = 1 ,4 do 
				local infoTx = tolua.cast(howPlayInfoPl:getChildByName('info_' .. i .. '_tx'),'UILabel')
				infoTx:setPreferredSize(310,1)
				infoTx:setText(getLocalStringValue('E_STR_PATROL_INFO' .. i))
			end
		elseif type == 2 then
			local patrolPl = tolua.cast(Sv:getChildByName('patrol_pl'),'UIPanel')
			for i = 1 ,4 do 
				local infoTx = tolua.cast(patrolPl:getChildByName('info_' .. i .. '_tx'),'UILabel')
				infoTx:setPreferredSize(310,1)
				infoTx:setText(getLocalStringValue('E_STR_PATROL_EXPLANATION' .. i))
			end

		end
	end

	
	--创建挑战奖励
	local function createChallegeAwardPanel(challengeAwardSv,mineId)
		-- body
		challengeAwardSv:removeAllChildrenAndCleanUp(true)
		local str = ''
		local count = 0
		for i = 1,10 do 
			table.foreach(patrolBattleConf,function(_ ,v)
				if v['Id'] == tostring(mineId) then
					str = v['Award' .. i]
					if str ~= '' and str ~= nil then 
						count = count + 1
					end
				end
			end)
		end
		for i = 1,count do
			local awardPanel = createWidgetByName('panel/garrison_award_panel.json')
			awardPanel:setPosition(ccp(110 * (i - 1),0))
	    	challengeAwardSv:setClippingEnable(true)
	    	challengeAwardSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
			challengeAwardSv:addChildToRight(awardPanel)

			local awardFrame = tolua.cast(awardPanel:getChildByName('res_photo_ico'),'UIImageView')
			
			local awardIco = tolua.cast(awardFrame:getChildByName('res_ico'),'UIImageView')
			local awardNumTx = tolua.cast(awardFrame:getChildByName('res_num_tx'),'UILabel')
			local awardNameTx = tolua.cast(awardFrame:getChildByName('res_name_tx'),'UILabel')
			awardNameTx:setPreferredSize(130,1)
			local str = ''
			table.foreach(patrolBattleConf,function(_ ,v)
				if v['Id'] == tostring(mineId) then
					str = v['Award' .. i]
				end
			end)
			awardFrame:registerScriptTapHandler(function()
				UISvr:showTipsForAward(str)
			end)
			if str ~= '' and str ~= nil  then 
				local award = UserData:getAward(str)
				awardIco:setTexture(award.icon)
				awardIco:setAnchorPoint(ccp(0,0))
				awardNumTx:setText(toWordsNumber(award.count))
				awardNameTx:setText(award.name)
				awardNameTx:setColor(award.color)
			else
				awardFrame:setVisible(false)
				awardIco:setVisible(false)
				awardNumTx:setVisible(false)
				awardNameTx:setVisible(false)
			end
		end
	end

	--创建空闲状态奖励
	local function createStoneAwardPanel( stoneAwardPl )
		-- body
		stoneAwardPl:removeAllChildrenAndCleanUp(true)
		awardSv:setVisible(false)
		challengeAwardSv:setVisible(false)
		stoneAwardPl:setVisible(true)
		for i ,v in pairs(patrolEventConf) do
			if tonumber(v.Id) > 1 then
				local str = v.Award1
				local award = UserData:getAward(str)
				local awardPanel = createWidgetByName('panel/garrison_award_panel.json')
				awardPanel:setPosition(ccp(110 * (i - 2),0))
		    	stoneAwardPl:setClippingEnable(true)
		    	stoneAwardPl:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
				stoneAwardPl:addChildToRight(awardPanel)

				local awardFrame = tolua.cast(awardPanel:getChildByName('res_photo_ico'),'UIImageView')
				
				local awardIco = tolua.cast(awardFrame:getChildByName('res_ico'),'UIImageView')
				local awardNumTx = tolua.cast(awardFrame:getChildByName('res_num_tx'),'UILabel')
				local awardNameTx = tolua.cast(awardFrame:getChildByName('res_name_tx'),'UILabel')
				awardFrame:registerScriptTapHandler(function()
					UISvr:showTipsForAward(str)
				end)
				awardNameTx:setPreferredSize(130,1)
				awardIco:setTexture(award.icon)
				awardIco:setAnchorPoint(ccp(0,0))
				awardNameTx:setText(award.name)
				awardNumTx:setText(award.count)
				awardNameTx:setColor(award.color)
				getRewardBtn:setNormalButtonGray(true)
				getRewardBtn:setTouchEnable(false)
			end
		end
	end

	--创建id为1的日志
	local function createRecodeFor1( eventSv,id,mineId,i)
		-- body
		table.foreach(patrolEventConf,function(_ ,v)
			-- body
			if v['Id'] == tostring(id) then
				local event = tostring(GetTextForCfg(v['Content']))
				local str = ''

				local rid = getDate[tostring(mineId)].rid
				table.foreach(materialConf,function(_ , v)
					-- body
					if v['UseEffect'] == tostring(rid) then
						local mId = v['Id']
						str = 'material.' .. mId .. ':1'
					end
				end)
				local award = UserData:getAward(str)
				local awardStr = award.name .. 'x' .. award.count
				local mat = '<font color = "#%02x%02x%02x">%s</font>'

				local matStr = string.format(mat,award.color.r,award.color.g,award.color.b,awardStr)

				local name = '<font color = "#%02x%02x%02x">%s</font>'
				local nameStr = string.format(name,roleNameColor.r,roleNameColor.g,roleNameColor.b,GetTextForCfg(roleName:getStringValue()))

				local eventPanel = createWidgetByName('panel/garrison_event_cell.json')
				local infoTx = tolua.cast(eventPanel:getChildByName('event_tx'),'UILabel')
				infoTx:setPreferredSize(310,1)
				eventSv:addChildToBottom(eventPanel)
				infoTx:setText(i .. '.' .. string.format(event,nameStr,matStr))
			end
		end)

	end

	local function createRecodeForNot1(eventSv,id,i)
		-- body
		table.foreach(patrolEventConf,function(_ ,v)
			-- body
			if v['Id'] == tostring(id) then
				local event = tostring(GetTextForCfg(v['Content']))
				local str = v['Award1']
				local award = UserData:getAward(str)
				local awardStr = award.name .. 'x' .. award.count
				local mat = '<font color = "#%02x%02x%02x">%s</font>'

				local matStr = string.format(mat,award.color.r,award.color.g,award.color.b,awardStr)

				local name = '<font color = "#%02x%02x%02x">%s</font>'
				local nameStr = string.format(name,roleNameColor.r,roleNameColor.g,roleNameColor.b,GetTextForCfg(roleName:getStringValue()))

				local eventPanel = createWidgetByName('panel/garrison_event_cell.json')
				local infoTx = tolua.cast(eventPanel:getChildByName('event_tx'),'UILabel')
				infoTx:setPreferredSize(310,1)
				eventSv:addChildToBottom(eventPanel)
				infoTx:setText(i .. '.' .. string.format(event,nameStr,matStr))
			end
		end)
	end

	--矿场日志
	local function createRecode(eventSv)
		-- body
		eventSv:removeAllChildrenAndCleanUp(true)
		eventSv:setVisible(true)
		if howPlaySv then 
			howPlaySv:setVisible(false)
		end
		eventSv:setClippingEnable(true)

		for i = 1,GarrisonMine:countTable(mineData['award_ids']) do 
			if mineData['award_ids'][i] ~= 1 then 
				createRecodeForNot1(eventSv,mineData['award_ids'][i],i)
			else
				createRecodeFor1(eventSv,mineData['award_ids'][i],mineId,i)
			end

		end
		eventSv:scrollToBottom()
	end


	local function createPatrolAwardFor1(awardSv,idCount,mineId,i)
		-- body
		local rid = getDate[tostring(mineId)].rid
		table.foreach(materialConf,function(_ , v)
			-- body
			if v['UseEffect'] == tostring(rid) then
				local mId = v['Id']
				local str = 'material.' .. mId .. ':' .. 1
				local award = UserData:getAward(str)
				local awardPanel = createWidgetByName('panel/garrison_award_panel.json')
				awardPanel:setPosition(ccp(110 * (i - 1),0))
		    	awardSv:setClippingEnable(true)
		    	awardSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
				awardSv:addChildToRight(awardPanel)

				local awardFrame = tolua.cast(awardPanel:getChildByName('res_photo_ico'),'UIImageView')
				
				local awardIco = tolua.cast(awardFrame:getChildByName('res_ico'),'UIImageView')
				local awardNumTx = tolua.cast(awardFrame:getChildByName('res_num_tx'),'UILabel')
				local awardNameTx = tolua.cast(awardFrame:getChildByName('res_name_tx'),'UILabel')
				awardNameTx:setPreferredSize(130,1)
				awardFrame:registerScriptTapHandler(function()
					UISvr:showTipsForAward(str)
				end)

				awardFrame:registerScriptTapHandler(function()
					UISvr:showTipsForAward(str)
				end)
				awardIco:setTexture(award.icon)
				awardIco:setAnchorPoint(ccp(0,0))
				awardNumTx:setTextFromInt(tonumber(award.count) * idCount[1])
				awardNameTx:setText(award.name)
				awardNameTx:setColor(award.color)
				winToGetTx:setText(getLocalStringValue('E_STR_PATROL_REWARD_NOW'))

			end
		end)
	end

	local function createPatrolAwardForNot1(awardSv,idCount,ids,i)
		-- body
		table.foreach(patrolEventConf,function(_ , v)
		-- body
			if v['Id'] == tostring(ids[i]) then 
				local str = ''
				str = v['Award1']
				local award = UserData:getAward(str)
				local awardPanel = createWidgetByName('panel/garrison_award_panel.json')
				awardPanel:setPosition(ccp(110 * (i - 1),0))
		    	awardSv:setClippingEnable(true)
		    	awardSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
				awardSv:addChildToRight(awardPanel)

				local awardFrame = tolua.cast(awardPanel:getChildByName('res_photo_ico'),'UIImageView')
				
				local awardIco = tolua.cast(awardFrame:getChildByName('res_ico'),'UIImageView')
				local awardNumTx = tolua.cast(awardFrame:getChildByName('res_num_tx'),'UILabel')
				local awardNameTx = tolua.cast(awardFrame:getChildByName('res_name_tx'),'UILabel')
				awardNameTx:setPreferredSize(130,1)
				awardFrame:registerScriptTapHandler(function()
					UISvr:showTipsForAward(str)
				end)

				awardFrame:registerScriptTapHandler(function()
					UISvr:showTipsForAward(str)
				end)
				awardIco:setTexture(award.icon)
				awardIco:setAnchorPoint(ccp(0,0))
				awardNumTx:setTextFromInt(tonumber(award.count) * idCount[ids[i]])
				awardNameTx:setText(award.name)
				awardNameTx:setColor(award.color)
				winToGetTx:setText(getLocalStringValue('E_STR_PATROL_REWARD_NOW'))
			end
		end)
	end

	--创建驻守奖励
	local function createPatrolAward(awardSv,eventSv)
		-- body
		awardSv:removeAllChildrenAndCleanUp(true)
		createRecode(eventSv)
		local idCount = {}
		local ids = {}
		for i = 1,GarrisonMine:countTable(mineData['award_ids']) do 
			local awardId = tonumber(mineData['award_ids'][i])
			if idCount[awardId] == nil then
				idCount[awardId] = 1
				table.insert(ids,awardId)
			else
				idCount[awardId] = idCount[awardId] + 1
			end
		end
		for i = 1,GarrisonMine:countTable(idCount) do 
			if ids[i] == 1 then 
				createPatrolAwardFor1(awardSv,idCount,mineId,i)
			else
				createPatrolAwardForNot1(awardSv,idCount,ids,i)
			end
		end

	end

	local function updatePanelWithNPC(howPlayPl,zhenxingPl)
		-- body
		noneGarrisonTx:setVisible(false)
		garrisonRoleImg:setVisible(true)
		nameBgImg:setVisible(true)
		zhanBgImg:setVisible(true)

		howPlayTx:setTexture('uires/ui_2nd/com/panel/garrison/shuoming.png')
		initShuoMing(howPlaySv,1)
		local totalForce = 0
		--阵型设置
		for j = 1,9 do 
			table.foreach(patrolBattleConf,function(_ ,v)
				if v['Id'] == tostring(mineId) then
					if v['Pos' .. j-1] == tostring(0) then
						placeArray[j]:setVisible(false)
					end

					table.foreach(monsterConf,function(_ ,k)
						if v['Pos' .. j-1] ~= tostring(0) and k['Id'] == v['Pos' .. j-1] then 
							if k['Soldier'] == tostring(1) then
								roleTypeRes = RES_DAO
								soldierTypeRes = DAO_ICON
							elseif k['Soldier'] == tostring(2) then
								roleTypeRes = RES_QIANG
								soldierTypeRes = QIANG_ICON
							elseif k['Soldier'] == tostring(3) then
								roleTypeRes = RES_QI 
								soldierTypeRes = QI_ICON 
							elseif k['Soldier'] == tostring(4) then
								roleTypeRes = RES_MOU 
								soldierTypeRes = MOU_ICON 
							elseif k['Soldier'] == tostring(5) then
								roleTypeRes = RES_HONG 
								soldierTypeRes = HONG_ICON 
							end
							placeArray[j]:setTexture(soldierTypeRes)
							totalForce = totalForce + tonumber(k['FightForce'])
						elseif v['Boss'] == k['Id'] then

							local npcId = tonumber(v['RoleId'])
							for k,c in pairs(roleConf) do
								if tonumber(c.Id) == npcId then 
									if c['Soldier'] == tostring(1) then
										roleTypeRes = RES_DAO
										roleType:setTexture(RES_DAO)
									elseif c['Soldier'] == tostring(2) then
										roleTypeRes = RES_QIANG
										roleType:setTexture(RES_QIANG)
									elseif c['Soldier'] == tostring(3) then
										roleTypeRes = RES_QI 
										roleType:setTexture(RES_QI)
									elseif c['Soldier'] == tostring(4) then
										roleTypeRes = RES_MOU 
										roleType:setTexture(RES_MOU)
									elseif c['Soldier'] == tostring(5) then
										roleTypeRes = RES_HONG 
										roleType:setTexture(RES_HONG)
									end
									if c['Quantity'] == 'blue' then
										roleName:setColor(COLOR_TYPE.BLUE)
									elseif c['Quantity'] == 'purple'then 
										roleName:setColor(COLOR_TYPE.PURPLE)
									elseif c['Quantity'] == 'orange'then 
										roleName:setColor(COLOR_TYPE.ORANGE)
									elseif c['Quantity'] == 'ared'then 
										roleName:setColor(COLOR_TYPE.RED)
									elseif c['Quantity'] == 'sred'then 
										roleName:setColor(COLOR_TYPE.RED)
									end
								end
							end
							garrisonRoleImg:setTexture('uires/ui_2nd/image/' .. k['URL'])
							if roleIdTab[npcId] ~= nil then
								garrisonRoleImg:setPosition(roleIdTab[npcId])
							else
								garrisonRoleImg:setPosition(defalutCCP)
							end
							roleName:setText(GetTextForCfg(k['Name']))
							-- totalForce = totalForce + tonumber(k['FightForce'])
						end
						
					end)
			
				end
			end)
			
		end
		roleForce:setText(totalForce)
		challengeAwardSv:setVisible(true)
		awardSv:setVisible(false)
		stoneAwardPl:setVisible(false)
		getRewardBtn:setVisible(false)
		challengeBtn:setVisible(true)
		blackFrameImg:setTouchEnable(false)
		addImg:setVisible(false)

		createChallegeAwardPanel(challengeAwardSv,mineId)
		winToGetTx:setText(getLocalStringValue('E_STR_PATROL_WIN_GET'))
	end

	local function updateState1()
		-- body
		howPlayTx:setTexture('uires/ui_2nd/com/panel/garrison/shuoming.png')
		howPlaySv:setVisible(true)
		patrolSv:setVisible(false)
		if eventSv then 
			eventSv:setVisible(false)
		end
		MineLight:setVisible(false)
		initShuoMing(howPlaySv,1)
		garrisonRoleImg:setVisible(false)
		nameBgImg:setVisible(false)
		zhanBgImg:setVisible(false)
		blackFrameImg:setTouchEnable(true)
		addImg:setVisible(true)
		viewBtn:setVisible(false)
		zhuShouRewardTx:setVisible(true)
		getRewardBtn:setVisible(true)
		getRewardBtn:setNormalButtonGray(true)
		getRewardBtn:setTouchEnable(false)
		noneGarrisonTx:setVisible(true)
		garrisonCDTime:setVisible(false)
		createStoneAwardPanel( stoneAwardPl )
		winToGetTx:setText(getLocalStringValue('E_STR_PATROL_REWARD'))
		noneGarrisonTx:setText(getLocalStringValue('E_STR_PATROL_NONE_ROLE'))

		jump(addImg, jumpInterval ,jumpHigh )

	end

	local function updatePatrolRole(rid)
		-- body
		if Role:findById(tonumber(rid)) == nil then 
			table.foreach(roleConf,function(_ , v)
				-- body
				if v['Id'] == tostring(rid) then 
					garrisonRoleImg:setTexture('uires/ui_2nd/image/' .. v['Url'])
					if v['Soldier'] == tostring(1) then
						roleType:setTexture(RES_DAO)
					elseif v['Soldier'] == tostring(2) then
						roleType:setTexture(RES_QIANG)
					elseif v['Soldier'] == tostring(3) then
						roleType:setTexture(RES_QIANG)
					elseif v['Soldier'] == tostring(4) then
						roleType:setTexture(RES_QIANG)
					elseif v['Soldier'] == tostring(5) then
						roleType:setTexture(RES_QIANG)
					end

					roleName:setText(GetTextForCfg(v['Name']))
					if v['Quantity'] == 'blue' then
						roleName:setColor(COLOR_TYPE.BLUE)
						roleNameColor = COLOR_TYPE.BLUE
					elseif v['Quantity'] == 'purple'then 
						roleName:setColor(COLOR_TYPE.PURPLE)
						roleNameColor = COLOR_TYPE.PURPLE
					elseif v['Quantity'] == 'orange'then 
						roleName:setColor(COLOR_TYPE.ORANGE)
						roleNameColor = COLOR_TYPE.ORANGE
					elseif v['Quantity'] == 'ared'then 
						roleName:setColor(COLOR_TYPE.RED)
						roleNameColor = COLOR_TYPE.RED
					elseif v['Quantity'] == 'sred'then 
						roleName:setColor(COLOR_TYPE.RED)
						roleNameColor = COLOR_TYPE.RED
					end
					roleForce:setText(v['FightForce'])
				end
			end)
		else
			roleObj = tolua.cast(CLDObjectManager:GetInst():GetOrCreateObject(rid, E_OBJECT_TYPE.OBJECT_TYPE_ROLE),'CLDRoleObject')
			garrisonRoleImg:setTexture(roleObj:GetRoleIcon(RESOURCE_TYPE.BIG))
			garrisonRoleImg:setAnchorPoint(ccp(0.5, 0.5))
			roleType:setTexture(roleObj:GetSoldierType())
			roleName:setText(roleObj:GetRoleName())
			roleName:setColor(roleObj:GetRoleNameColor())
			roleNameColor = roleObj:GetRoleNameColor()
			roleForce:setText(roleObj:GetFightForce())
		end

		if roleIdTab[rid] ~= 0 and roleIdTab[rid] ~= nil then
			garrisonRoleImg:setPosition(roleIdTab[rid])
		else
			garrisonRoleImg:setPosition(defalutCCP)
		end

	end

	local function updateGarrisonTime(garrisonCDTime,mineId)
		-- body
		local duration
		table.foreach(patrolTypeConf,function(_ ,v)
			-- body
			if v['Id'] == tostring(getDate[tostring(mineId)].type) then
				duration = v['Duration']
			end
		end)
		local timeDiff = (tonumber(duration) * 3600) - (UserData:getServerTime() - tonumber(getDate[tostring(mineId)].time))
		garrisonCDTime:setTime(timeDiff)

	end

	local function updateGetAwardTime(noneGarrisonTx,getAwardCDTimeTx,mineId)
		-- body
		local durationTime 
		table.foreach(patrolIntervalConf,function(_ , v)
			-- body
			if v['Id'] == tostring(getDate[tostring(mineId)].interval) then
				durationTime = v['Interval']
			end
		end)

		local timeDiff2 = (tonumber(durationTime) * 60) - (UserData:getServerTime() - tonumber(getDate[tostring(mineId)].time))%(tonumber(durationTime) * 60)

		getAwardCDTimeTx:setTime(timeDiff2)
		getAwardCDTimeTx:setVisible(true)
		getAwardCDTimeTx:setPosition(ccp(115,-2))
		getAwardCDTimeTx:setAnchorPoint(ccp(0,0.5))
		noneGarrisonTx:addChild(getAwardCDTimeTx)

	end

	local function updateState2()
		-- body
		MineLight:setVisible(true)
		noneGarrisonTx:setVisible(true)
		zhuShouRewardTx:setVisible(false)
		getRewardBtn:setVisible(true)
		getRewardBtn:setNormalButtonGray(true)
		getRewardBtn:setTouchEnable(false)
		garrisonRoleImg:setVisible(true)
		nameBgImg:setVisible(true)
		zhanBgImg:setVisible(true)
		blackFrameImg:setTouchEnable(false)
		addImg:setVisible(false)
		challengeBtn:setVisible(false)
		viewBtn:setVisible(false)
		addImg:stopAllActions()
		winToGetTx:setText(getLocalStringValue('E_STR_PATROL_REWARD_NOW'))
		Message.sendPost('patrol_visit_mine','activity',json.encode({id = mineId}),function(jsonData)
			-- body
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error:' .. jsonDic['desc'])
				return
			end
			mineData = jsonDic.data
			local rid = getDate[tostring(mineId)].rid --驻守武将Id
			updatePatrolRole(rid)

			updateGarrisonTime(garrisonCDTime,mineId)

			if GarrisonMine:countTable(mineData['award_ids']) == 0 then 
				createStoneAwardPanel(stoneAwardPl)
				winToGetTx:setText(getLocalStringValue('E_STR_PATROL_REWARD'))
				howPlayTx:setTexture('uires/ui_2nd/com/panel/garrison/patrol.png')
				initShuoMing(patrolSv,2)
				howPlaySv:setVisible(false)
			else
				howPlayTx:setTexture('uires/ui_2nd/com/panel/garrison/rizhi.png')
				if howPlaySv then 
					howPlaySv:setVisible(false)
				end
				patrolSv:setVisible(false)
				winToGetTx:setText(getLocalStringValue('E_STR_PATROL_REWARD_NOW'))
				challengeAwardSv:setVisible(false)
				stoneAwardPl:setVisible(false)
				awardSv:setVisible(true)
				createPatrolAward(awardSv,eventSv)
			end
			noneGarrisonTx:setText(getLocalStringValue('E_STR_PATROL_REWARD_NEXT_TIME'))
			noneGarrisonTx:setPreferredSize(180,1)
			noneGarrisonTx:setPosition(ccp(105,-40))

			updateGetAwardTime(noneGarrisonTx,getAwardCDTimeTx,mineId)

		end)
	end

	local function updateState3()
		-- body
		howPlayTx:setTexture('uires/ui_2nd/com/panel/garrison/rizhi.png')
		MineLight:setVisible(true)
		noneGarrisonTx:setVisible(true)
		zhuShouRewardTx:setVisible(false)
		getRewardBtn:setVisible(true)
		getRewardBtn:setNormalButtonGray(false)
		getRewardBtn:setTouchEnable(true)
		Message.sendPost('patrol_visit_mine','activity',json.encode({id = mineId}),function(jsonData)
			-- body
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error:' .. jsonDic['desc'])
				return
			end
			mineData = jsonDic.data

			local rid = getDate[tostring(mineId)].rid --驻守武将Id
			updatePatrolRole(rid)
			
			garrisonRoleImg:setVisible(true)
			nameBgImg:setVisible(true)
			zhanBgImg:setVisible(true)
			blackFrameImg:setTouchEnable(false)
			addImg:setVisible(false)
			challengeBtn:setVisible(false)
			viewBtn:setVisible(false)
			
			createPatrolAward(awardSv,eventSv)
			challengeAwardSv:setVisible(false)
			stoneAwardPl:setVisible(false)
			addImg:stopAllActions()

			garrisonCDTime:setText(getLocalStringValue('E_STR_PATROL_END'))
			garrisonCDTime:setFontSize(18)
			garrisonCDTime:setPreferredSize(260,1)
			noneGarrisonTx:setText(getLocalStringValue('E_STR_PATROL_REWARD_LIMIT'))

		end)
	end

	--刷新金矿界面
	function GarrisonMinePanel:updateMinePanel()
		-- body
		if isWin then
			challengeBtn:setTouchEnable(false)
			-- initShuoMing(howPlaySv)
			buzhenBtn:setVisible(false)
			Message.sendPost('patrol_get','activity','{}',function(jsonData)
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic['code'] ~= 0 then
					cclog('request error : ' .. jsonDic['desc'])
					return
				end
				getDate = jsonDic.data.patrol

				local state  = getDate[tostring(mineId)].state
				if state == 1 then -- 空
					updateState1()
				elseif state == 2 then -- 正在驻守
					updateState2()
				elseif state == 3 then -- 等待领奖
					updateState3()
				end
			end)

			
		else
			updatePanelWithNPC(howPlayPl,zhenxingPl)
		end

		howPlayPl:setVisible(not isShowEmBattle)
		zhenxingPl:setVisible(isShowEmBattle)

	end

	--点击驻守按钮
	local function onClickGarrisonBtn()
		-- body
		local args = {
					id = tonumber(PlayerCoreData.getUID())
				}
		Message.sendPost('get_user', 'rank', json.encode(args), function( jsonData )
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			local code = jsonDic.code
			if code == 0 then
				userInfoData = jsonDic.data
				genSelectPanel(mineId,userInfoData,getDate)
			end
		end)
	end



	--点击布阵按钮
	local function onClickEmBattleBtn()
		OpenEmbattleUi()
	end

	--点击查看按钮
	local function onClickViewBtn()
		isShowEmBattle = not isShowEmBattle
		howPlayPl:setVisible(not isShowEmBattle)
		zhenxingPl:setVisible(isShowEmBattle)
		viewBtn:setText(isShowEmBattle and getLocalStringValue('E_STR_PATROL_VIEW1') or getLocalStringValue('E_STR_PATROL_VIEW2'))
	end


	local function mineHelpPanel()
		-- body
		local helpScene = SceneObjEx:createObj('panel/garrison_help_panel.json','garrison-help-in-lua')
		local helpPanel = helpScene:getPanelObj()
		helpPanel:setAdaptInfo('help_bg_img','help_img')
		helpPanel:registerInitHandler(function()
			local helpRoot = helpPanel:GetRawPanel()
			local closeBtn = tolua.cast(helpRoot:getChildByName('close_btn'),'UIButton')
			closeBtn:registerScriptTapHandler(function ()
				CUIManager:GetInstance():HideObject(helpScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
				GarrisonMinePanel:updateMinePanel()
			end)
			GameController.addButtonSound(closeBtn,BUTTON_SOUND_TYPE.CLOSE_EFFECT)
			local helpSv = tolua.cast(helpRoot:getChildByName('help_sv'),'UIScrollView')
			helpSv:setClippingEnable(true)
			helpSv:scrollToTop()
			for i = 1, 9 do 
				local info = tolua.cast(helpSv:getChildByName('info_' .. i .. '_tx'),'UILabel')
				info:setText(getLocalStringValue('E_STR_PATROL_HELP' .. i))
				info:setPreferredSize(700,1)
			end
			end)
		UiMan.show(helpScene)
	end

	local function onClickChallenge()
		-- body
		Message.sendPost('patrol_fight_npc','activity','{}',function(jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']

			if data['awards'] then
					rewardData = data['awards']	
				UserData.parseAwardJson(json.encode(data['awards']))
			end

			if data['battle'] then
				isWin = tonumber(data['battle']['success']) == 1
				GameController.updateAwardView(json.encode(data['awards']))
				GameController.playBattle(json.encode(data['battle']) , 5, 15)
			end

			GarrisonMinePanel:updateMinePanel()
		end)
	end

	local function onClickGetReward(mineId)
		-- body
		Message.sendPost('patrol_get_awards','activity',json.encode({id = mineId}),function(jsonData)
			-- body
			cclog(jsonData)
			local award 
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error:' .. jsonDic['desc'])
				return
			end
			local awardData = jsonDic.data
			local awards = {}
			local str = ''
			award = awardData['awards']
			if awardData['awards'] then
				rewardData = awardData['awards']	
				UserData.parseAwardJson(json.encode(awardData['awards']))
			end
			for i = 1, GarrisonMine:countTable(award) do 
				str = award[i][1] .. '.' .. award[i][2] .. ':' .. award[i][3]
				awards[i] = str
			end
			 
			genShowTotalAwardsPanel(awards,getLocalStringValue('E_STR_PATROL_GET_REWARD'))
			awardSv:removeAllChildrenAndCleanUp(true)
			GarrisonMinePanel:updateMinePanel()
			
		end)
	end


	--创建金矿界面并初始化
	local function createMinePanel()
		-- body
		mineScene = SceneObjEx:createObj('panel/garrison_mine_panel.json','garrison-mine-in-lua')
		minePanel = mineScene:getPanelObj()
		minePanel:setAdaptInfo('mine_bg_img','mine_img')
		minePanel:registerInitHandler(function()
		-- body
			mineRoot = minePanel:GetRawPanel()
			mineTitle = tolua.cast(mineRoot:getChildByName('title_img'),'UIImageView')
			mineCloseBtn = tolua.cast(mineTitle:getChildByName('close_btn'),'UIButton')
			mineCloseBtn:registerScriptTapHandler(function ()
				CUIManager:GetInstance():HideObject(mineScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
				GarrisonMine:updatePanel()
			end)
			GameController.addButtonSound(mineCloseBtn,BUTTON_SOUND_TYPE.CLOSE_EFFECT)
			mineHelpBtn = tolua.cast(mineTitle:getChildByName('help_btn'),'UIButton')
			mineHelpBtn:registerScriptTapHandler(function()
				-- body
				mineHelpPanel()
			end)
			GameController.addButtonSound(mineHelpBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)
			leftBgImg = tolua.cast(mineRoot:getChildByName('left_bg_img'),'UIImageView')
			minePic = tolua.cast(leftBgImg:getChildByName('mine_pic_img'),'UIImageView')
			MineLight = CUIEffect:create()
			MineLight:Show('goldmine_light',0)
			MineLight:setPosition(ccp(0,-75))
			MineLight:setScale(3.0)
			MineLight:setAnchorPoint(ccp(0.5,0.5))
			minePic:getContainerNode():addChild(MineLight)
			MineLight:setZOrder(100)
			MineLight:setVisible(false)
			garrisonRoleImg = tolua.cast(leftBgImg:getChildByName('role_img'),'UIImageView')
			blackFrameImg = tolua.cast(leftBgImg:getChildByName('black_frame_img'),'UIImageView')
			addImg = tolua.cast(blackFrameImg:getChildByName('add_img'),'UIImageView')
			addImg:setVisible(false)
			blackFrameImg:setTouchEnable(false)
			blackFrameImg:registerScriptTapHandler(function()
				-- body
				onClickGarrisonBtn()
			end)
			nameBgImg = tolua.cast(minePic:getChildByName('name_bg_img'),'UIImageView')
			roleType = tolua.cast(nameBgImg:getChildByName('role_type_img'),'UIImageView')
			roleName = tolua.cast(nameBgImg:getChildByName('role_name_tx'),'UILabel')
			zhanBgImg = tolua.cast(minePic:getChildByName('zhan_bg_img'),'UIImageView')
			roleForce = tolua.cast(zhanBgImg:getChildByName('role_force_tx'),'UILabel')

			buzhenBtn = tolua.cast(minePic:getChildByName('buzhen_btn'),'UIButton')
			buzhenBtn:registerScriptTapHandler(function()
				onClickEmBattleBtn()
			end)
			GameController.addButtonSound(buzhenBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)

			mineMine = tolua.cast(minePic:getChildByName('mine_img'),'UIImageView')
			rightCard = tolua.cast(mineRoot:getChildByName('right_card_img'),'UIImageView')
			zhenxingPl = tolua.cast(rightCard:getChildByName('zhenxing_pl'),'UIPanel')


			zhenxingInfo = tolua.cast(zhenxingPl:getChildByName('buzhen_txt_img'),'UIImageView')
			zhenxingImg = tolua.cast(zhenxingPl:getChildByName('zhenxing_img'),'UIImageView')
			for i = 1,9 do
				placeArray[i] = tolua.cast(zhenxingImg:getChildByName('place_' .. tostring(i) .. '_ico'),'UIImageView')
			end
			howPlayPl = tolua.cast(rightCard:getChildByName('how_to_play_pl'),'UIPanel')
			eventSv = tolua.cast(howPlayPl:getChildByName('event_sv'),'UIScrollView')
			howPlaySv = tolua.cast(howPlayPl:getChildByName('how_play_sv'),'UIScrollView')
			patrolSv = tolua.cast(howPlayPl:getChildByName('patrol_sv'),'UIScrollView')

			howPlayTx = tolua.cast(howPlayPl:getChildByName('how_play_img'),'UIImageView')
			

			howPlayInfoTx = tolua.cast(howPlayPl:getChildByName('info_tx'),'UILabel')
			noneGarrisonTx = tolua.cast(howPlayPl:getChildByName('none_garrison_tx'),'UILabel')
			awardBgImg = tolua.cast(rightCard:getChildByName('award_bg_pl'),'UIPanel')
			viewBtn = tolua.cast(awardBgImg:getChildByName('view_btn'),'UITextButton')


			viewBtn:registerScriptTapHandler(function()
				-- body
				onClickViewBtn()
			end)
			GameController.addButtonSound(viewBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)
			challengeBtn = tolua.cast(awardBgImg:getChildByName('challenge_btn'),'UITextButton')
			challengeBtn:registerScriptTapHandler(function()
				onClickChallenge()
			end)
			GameController.addButtonSound(challengeBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)
			getRewardBtn = tolua.cast(awardBgImg:getChildByName('got_reward_btn'),'UITextButton')
			awardSv = tolua.cast(awardBgImg:getChildByName('award_sv'),'UIScrollView')
			winToGetTx = tolua.cast(awardBgImg:getChildByName('win_to_get_tx'),'UILabel')
			zhuShouRewardTx = tolua.cast(awardBgImg:getChildByName('zhu_shou_reward_tx'),'UILabel')
			challengeAwardSv = tolua.cast(awardBgImg:getChildByName('challenge_reward_sv'),'UIScrollView')
			stoneAwardPl = tolua.cast(awardBgImg:getChildByName('stone_reward_sv'),'UIScrollView')
			zhuShouRewardTx:setPreferredSize(260,1)

			getRewardBtn:setVisible(false)
			getRewardBtn:registerScriptTapHandler(function()
				-- body
				onClickGetReward(mineId)
			end)
			GameController.addButtonSound(getRewardBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)

			zhuShouRewardTx:setVisible(false)
			challengeBtn:setVisible(false)


			garrisonCDTime = UICDLabel:create()
			garrisonCDTime:setFontSize(28)
			garrisonCDTime:setPosition(ccp(100,20))
			garrisonCDTime:setAnchorPoint(ccp(0.5,0.5))
			awardBgImg:addChild(garrisonCDTime)
			garrisonCDTime:registerTimeoutHandler(function()
				-- body
				GarrisonMinePanel:updateMinePanel()
			end)

			getAwardCDTimeTx = UICDLabel:create()
			getAwardCDTimeTx:setFontSize(22)
			getAwardCDTimeTx:registerTimeoutHandler(function()
				-- body
				GarrisonMinePanel:updateMinePanel()
			end)
			
			getCCPFromTab()
			GarrisonMinePanel:updateMinePanel()
		end)
		UiMan.show(mineScene)
	end

	createMinePanel()
end
