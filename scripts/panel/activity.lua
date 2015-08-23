Activity = {}

-- TODO: 检查活跃度任务是否可用
function Activity.isActive()
	local dailyConf = GameData:getMapData('dailytask.dat')
	local dailyData = UserData:getDailyTaskData()
	playerScore = 0
	totalScore = 0
	table.foreach(dailyConf , function(key , value)
		local score = 0
		if dailyData[tostring(key)] then
			score = dailyData[tostring(key)]
		end
		if score >= tonumber(value['Target']) then
			playerScore = playerScore + value['Score']
		end
		totalScore = totalScore + value['Score']
	end)
	return playerScore < totalScore
end

function Activity.canGetBox()
	local flag = false
	local dailyConf = GameData:getMapData('dailytask.dat')
	local lastGotScore  = UserData:getMarkData()['daily_task']
	local dailyTaskMap = UserData:getDailyTaskData()
	local playerScore = 0
	table.foreach(dailyConf , function(key , value)
		local score = 0
		if dailyTaskMap[tostring(key)] then
			score = dailyTaskMap[tostring(key)]
		end
		if score >= tonumber(value['Target']) then
			playerScore = playerScore + value['Score']
		end
	end)

	for i = 1 , 4 do
		if playerScore >= 30 * i then
			if 30 * i  - lastGotScore  == 30 then
				--30*i奖励可领取--
				flag = true
				break
			end
		end
	end
	return flag
end

function Activity.enter()

	local Limit = readOnly{
		MAX_BOX_NUM = 4
	}

	-- ui --
	local tipsPanel
	local leftPanel
	local rightSv						--滑动列表--
	local expBar						--进度条--
	local titleTx
	local boxTab = {}					--宝箱--

	-- data --
	local playerScore = 0				--玩家当前活跃度--
	local dailyData = {}				--玩家活跃度完成数据--
	local longPressed = false

	local dailyConfTab = GameData:getArrayData('dailytask.dat')		--dailytask conf data--
	local taskRewardConfTab = GameData:getArrayData('taskreward.dat')  --taskreward conf data--

	local function getDailyConfDataByKey( key )
		for k , v in pairs (dailyConfTab) do
			if v['Id'] == tostring(key) then
				return v
			end
		end
		return nil
	end

	local function getAwardConfDataByKey( key )
		for k , v in pairs (taskRewardConfTab) do
			if v['Score'] == tostring(key) then
				return v
			end
		end
		return nil
	end

	local function updateTitleInfo()
		local needScore = 0	
		for key , value in pairs(taskRewardConfTab) do
			if(tonumber(value.Score) > playerScore) then
				needScore = value.Score - playerScore
				break
			end
		end

		if(needScore <= 0) then
			titleTx:setText(getLocalStringValue('E_STR_ACTIVE_FULL'))
		else
			local s = string.format(getLocalStringValue("E_STR_ACTIVE_INFO") , playerScore , needScore)
			titleTx:setText(s)
		end
	end

	local function updateLeftPanel()

		local lastGotScore  = UserData:getMarkData()['daily_task']
		local tempstr = 'uires/ui_2nd/com/panel/active/'
		for i = 1 , Limit.MAX_BOX_NUM do
			if boxTab[i] then
				
				local boxItem = boxTab[i]['box']
				local numItem = boxTab[i]['num']
				
				if playerScore >= 30 * i then
					if lastGotScore >= 30 * i then	
						--设置30*i奖励已领取--	
						boxItem:setTexture(tempstr .. 'box_2.png')
						boxItem:setNormal()
						boxItem:setTouchEnable(true)
						numItem:setTexture(tempstr .. 'qipao_1.png')
					elseif 30 * i  - lastGotScore  == 30 then
						--设置30*i奖励可领取--
						boxItem:setTexture(tempstr .. 'box_1.png')
						boxItem:setNormal()
						boxItem:setTouchEnable(true)
						numItem:setTexture(tempstr .. 'qipao_1.png')
					else
						boxItem:setTexture(tempstr .. 'box_1.png')
						boxItem:setGray()
						boxItem:setTouchEnable(true)
						numItem:setTexture(tempstr .. 'qipao_1.png')
					end
				else
					boxItem:setTexture(tempstr .. 'box_1.png')
					boxItem:setGray()
					boxItem:setTouchEnable(true)
					numItem:setTexture(tempstr .. 'qipao_2.png')
				end
				boxItem:setAnchorPoint(ccp(0,0))
				numItem:setAnchorPoint(ccp(0,0))
			end
		end

		local percent = playerScore * 100 / 120
		expBar:setPercent(percent)
	end

	local function ShowForwardPanel( tid )
		local map = GameData:getMapData('dailytask.dat')

		local data = map[tostring(tid)]

		if not data then return end

		local targetLv = tonumber(data.Level)
		if PlayerCoreData.getPlayerLevel() < targetLv then
			local s = string.format(getLocalStringValue('E_STR_GOTO_LIMIT') , targetLv)
			GameController.showMessageBox(s, MESSAGE_BOX_TYPE.OK)
			return
		end

		CUIManager:GetInstance():HideAllObjects()

		if data['Action'] == 'HarvestCastle' then
			-- 征收金币
			UiMgr:MoveToTargetBy(484,1041,1.4,1.2,3)
		elseif data['Action'] == 'HarvestFarm' then
			-- 征收粮草
			UiMgr:MoveToTargetBy(1435,956,1.5,1.2,3)
		elseif data['Action'] == 'PVE' then
			-- 征战关卡
			CCopySceneMgr:getInst():showWarMap(-1)
		elseif data['Action'] == 'EnrollRole' then
			-- 招募武将
			CTavernMgr:GetInst():ShowGoldTavern()
		elseif data['Action'] == 'ChallengeHero' then
			-- 挑战英雄祭坛
			local battleId = CBattleAPI:canEnterAltar()
			if battleId <= 0 then
				GameController.showMessageBox(getLocalString('hero_altar_no_open'), MESSAGE_BOX_TYPE.OK)
				return
			end
			CCopySceneMgr:getInst():showWarMap(1)
			CCopySceneMgr:getInst():showAltar(battleId)
		elseif data['Action'] == 'ChallengeHonor' then
			-- 挑战精英士兵
			local honorChapterId = 3
			local battleId = CBattleAPI:getFirstEliteSoldierId(honorChapterId)
			if CBattleAPI:getBattleStatusByID(battleId) <= 0 then
				GameController.showMessageBox(getLocalString('E_STR_NOT_OPEN_BOSS'), MESSAGE_BOX_TYPE.OK)
				return
			end
			CCopySceneMgr:getInst():showWarMap(honorChapterId)
			CCopySceneMgr:getInst():showAltar(battleId)
		elseif data['Action'] == 'ChallengeRank' then
			-- 擂台挑战
			CArenaMgr:getInst():sendGetMatchRankRequest()
		elseif data['Action'] == 'OccupyMine' then
			-- 占领金矿
			GoldMan2:GetInst():OpenSvPanel()
		elseif data['Action'] == 'ChallengeSoul' then
			-- 挑战精英武将
			local soulChapterId = 2
			local battleId = CBattleAPI:getFirstEliteHeroId(soulChapterId)
			if CBattleAPI:getBattleStatusByID(battleId) <= 0 then
				GameController.showMessageBox(getLocalString('E_STR_NOT_OPEN_BOSS'), MESSAGE_BOX_TYPE.OK)
				return
			end
			CCopySceneMgr:getInst():showWarMap(soulChapterId)
			CCopySceneMgr:getInst():showAltar(battleId)
		elseif data['Action'] == 'CombineSkillBook' then
			-- 抢夺技能残卷
			CRoleMgr:GetInst():DoGetSkillFragInfo()
			CRoleMgr:GetInst():showFragment()
		elseif data['Action'] == 'TrainRole' then
			-- 训练武将
			CTrainMgr:GetInst():ShowTrainPanel()
		elseif data['Action'] == 'ChallengeTower' then
			-- 勇闯重楼
			CThousandFloorMgr:GetInst():Show()
		elseif data['Action'] == 'Business' then
			-- 商社贸易
			if not CCopySceneMgr:getInst():isBusinessOpen() then
				return
			end
			CBusinessMgr:GetInst():setEnterIntoValue(1)
			CBusinessMgr:GetInst():ShowMainPanel()
		elseif data['Action'] == 'ProtectionEmperor' then
			-- 保护献帝
			Protection.enter()
		elseif data['Action'] == 'TechExercirs' then
			-- 军机处历练
			CTechnologyMgr:GetInst():ShowMainPanel()
		elseif data['Action'] == 'HeroSoul' then
			-- 武将炼魂
			CRoleMgr:GetInst():ShowMainPanel(3, false)
		end
	end

	--产生右边的滑动列表--
	local function genActivityCardItem()
		local index = 0
		table.foreach(dailyData , function(key , value)
			local pItem = createWidgetByName('panel/active_card_panel.json')
			if not pItem then
				cclog('failed to create active_card_panel!!')
			else
				local taskImage = tolua.cast(pItem:getChildByName('card_bg_img') , 'UIImageView')
				local checkIco = pItem:getChildByName('check_ico')
				local taskInfoTx = tolua.cast(pItem:getChildByName('info_tx') , 'UILabel')
				local numTx = tolua.cast(pItem:getChildByName('num_tx') , 'UILabel')
				local addTx = tolua.cast(pItem:getChildByName('active_add_tx') , 'UILabel')
				local goBtn = tolua.cast(pItem:getChildByName('go_btn') , 'UIButton')
				GameController.addButtonSound(goBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
				local data = getDailyConfDataByKey(value['id'])
				if data then
					local isFinish = value['isFinish']

					taskInfoTx:setText(GetTextForCfg(tostring(data['Desc'])))
					local s = string.format(getLocalStringValue('E_STR_ACIVE') , tostring(data['Score']))
					addTx:setText(s);

					goBtn:setVisible(not isFinish)
					
					if not isFinish then
						goBtn:registerScriptTapHandler( function ()
							local id = value['id']
							ShowForwardPanel(tonumber(id))
						end)
					end
					
					checkIco:setVisible(isFinish)
					local str = 'uires/ui_2nd/com/panel/common/'
					taskImage:setTexture(str .. ((isFinish and 'blue_bg_img.png') or 'nei_bg_img.png'))
					taskImage:setScale9Size(CCSizeMake(477,106))
					taskImage:setAnchorPoint( ccp(0,0) )

					goBtn:setScale9Enable(true)
					goBtn:setScale9Size(CCSizeMake(150,75))

					numTx:setText(tostring(value['score']) .. '/' .. tostring(data['Target']))

					taskInfoTx:setColor((isFinish and COLOR_TYPE.GREEN) or COLOR_TYPE.WHITE)
					addTx:setColor((isFinish and COLOR_TYPE.GREEN) or COLOR_TYPE.WHITE)
					numTx:setColor((isFinish and COLOR_TYPE.GREEN) or COLOR_TYPE.WHITE)

					pItem:setPosition(ccp(0 , 420 - index * 106))
					rightSv:addChild(pItem)
					index = index + 1
				else
					cclog("failed to addChild pItem!!!!!")
				end
			end
		end)
		rightSv:scrollToTop()
	end

	local function sortFn(a, b)
		local fina = a.isFinish and 1 or 0
		local finb = b.isFinish and 1 or 0
		return fina < finb
	end

	local function initData()
		local dailyTaskMap = UserData:getDailyTaskData()
		playerScore = 0
		dailyData = {}
		table.foreach(dailyConfTab , function(key , value)
			local score = 0
			local total = 0
			local isFinish = false
			if dailyTaskMap[tostring(key)] then
				score = dailyTaskMap[tostring(key)]
			end

			if score >= tonumber(value['Target']) then
				isFinish = true
				playerScore = playerScore + value['Score']
				score = tonumber(value['Target'])
			end

			local tempTab = {}
			tempTab['id'] = key
			tempTab['score'] = score
			tempTab['isFinish'] = isFinish

			table.insert(dailyData ,tempTab)
		end)
		table.sort(dailyData , sortFn)
	end

	local function updatePanel()

		local function hideAwardTips()
			tipsPanel:removeFromParentAndCleanup(true)
		end

		local function showRewardTips( id )
			local data = getAwardConfDataByKey(id * 30)
			if data == nil then
				return 
			end
			
			local inLegion = tonumber(MyLegion.lid) and tonumber(MyLegion.lid) > 0

			tipsPanel = UIImageView:create()
			tipsPanel:setTexture('uires/ui_2nd/com/panel/mainscene/zhan_tips.png')
			tipsPanel:setScale9Enable(true)
			tipsPanel:setAnchorPoint(ccp(0, 0))

			-- add award item
			local keyTab = {'Gold' , 'Award1' , 'Award2' , 'Award3' , 'LegionHonor' , 'LegionExp'}
			local defaultX = 110
			local finalX = 0
			local length = 0
			for _, v in pairs (keyTab) do
				if data[v] and data[v] ~= '' then
					local tab = {}
					local isadd = true
					if v == 'Gold' then
						tab = UserData:getAward( 'user.gold:' .. data[v] )
					elseif v == 'LegionHonor' then
						tab = UserData:getAward( 'user.legionHonor:' .. data[v] )
						isadd = inLegion
					elseif v == 'LegionExp' then
						tab = UserData:getAward( 'user.legionExp:' .. data[v] )
						isadd = inLegion
					else
						tab = UserData:getAward( data[v] )
					end

					if isadd then
						local item = GameController.createItem( tab )
						item:setPosition( ccp( defaultX + length * 140, 110) )
						finalX = defaultX + length * 140

						tipsPanel:addChild(item)

						length = length + 1
					end
				end
			end

			-- add title
			local titleTx = UILabel:create()
			titleTx:setAnchorPoint( ccp(0.5 , 0.5) )
			titleTx:setFontSize(26)
			titleTx:setFontName('微软雅黑')
			titleTx:setText( string.format(getLocalString("E_STR_ACTIVE_NAME") , id * 30) )
			titleTx:setPosition( ccp((finalX + defaultX) / 2, 170) )
			tipsPanel:addChild(titleTx)
			--
			tipsPanel:setScale9Size(CCSizeMake(finalX + defaultX , 210))

			tipsPanel:setPosition(ccp(160 , id * 100))
			tipsPanel:setWidgetZOrder(999)
			tipsPanel:setScale(0.7)
			leftPanel:addChild(tipsPanel)

			longPressed = true
		end

		local function onShowTips( id )
			showRewardTips( id )
		end

		local function getAwardResponse(jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']
			if not data then 
				return 
			end

			local markData = UserData:getMarkData()
			markData['daily_task'] = jsonDic['args']['score']
			local markStr = json.encode(markData)
			UserData:setMarkData(markStr)

			local gold = data['gold'] or 0
			local awards = data['awards']
			if gold > 0 then
				table.insert(awards , {'user' , 'gold' , gold})
			end
			local legionHonor = data['legion_honor'] or 0 
			if legionHonor > 0 then
				table.insert(awards , {'user' , 'legionHonor' , legionHonor} )
			end

			local legionExp = data['legion_exp'] or 0 
			if legionExp > 0 then
				table.insert(awards , {'user' , 'legionExp' , legionExp} )
			end

			local awardStr = json.encode(awards)
			UserData.parseAwardJson(awardStr)

			GameController.showAwardsFlowText( awards )

			UpdateMainCity()
			--更新Title--
			updateTitleInfo()
			--更新宝箱状态--
			updateLeftPanel()
		end

		local function doGetAward( score )
			if longPressed then 
				hideAwardTips()
				longPressed = false
				return
			end

			local lastGotScore  = UserData:getMarkData()['daily_task']
			if score - lastGotScore == 30 and playerScore >= score then
				local tab = {score = score}
				local jsonData = json.encode(tab)
				Message.sendPost('get_reward','task',jsonData , getAwardResponse)
			end
		end

		local act = SceneObjEx:createObj('panel/active_panel.json', 'act-in-lua')
	    local panel = act:getPanelObj()
	    panel:setAdaptInfo('active_bg_img', 'active_img')

	    panel:registerInitHandler(function()
				local root = panel:GetRawPanel()
				local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
				closeBtn:registerScriptTapHandler(function()
					CUIManager:GetInstance():HideObject(act, ELF_HIDE.SMART_HIDE)
				end)
				GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)

				leftPanel = tolua.cast(root:getChildByName('left_bg_img') , 'UIImageView')
				leftPanel:setWidgetZOrder(99)
				titleTx = tolua.cast(root:getChildByName('cur_info_tx') , 'UILabel')
				titleTx:setPreferredSize(630,1)

				rightSv = tolua.cast(root:getChildByName('right_sv') , 'UIScrollView')
				rightSv:removeAllChildrenAndCleanUp(true)
				rightSv:setClippingEnable(true)

				local pLeftImg = root:getChildByName('left_bg_img')
				local pExpBgIco = pLeftImg:getChildByName('exp_bg_img')
				expBar = tolua.cast(pExpBgIco:getChildByName('exp_bar') , 'UILoadingBar')

				boxTab = {}
				for i = 1 , Limit.MAX_BOX_NUM do
					local boxItem = tolua.cast(pLeftImg:getChildByName('box_' .. i ..'_ico') , 'UIImageView')
					boxItem:registerScriptTapHandler( function ()
						local boxId = i
						local gotScore = boxId * 30
						doGetAward(gotScore)
					end )
					boxItem:registerScriptLongPressHandler(function ()
						local boxId = i
						onShowTips( boxId )
					end)
					boxItem:registerScriptCancelHandler(function ()
						local boxId = i
						local gotScore = boxId * 30
						doGetAward(gotScore)
					end)
					local numItem = tolua.cast(pLeftImg:getChildByName('num_' .. i .. '_bg_ico') , 'UIImageView')
					local itemTab = {}
					itemTab['box'] = boxItem
					itemTab['num'] = numItem
					table.insert(boxTab , itemTab)
				end

				--初始化玩家数据--
				initData()
				--产生右边的滑动列表--
				genActivityCardItem()
				--更新Title--
				updateTitleInfo()
				--更新宝箱状态--
				updateLeftPanel()

				cclog('here on-init for activity-in')
			end)

	    -- Show now
	    CUIManager:GetInstance():ShowObject(act, ELF_SHOW.SMART)
	end

	local function getDailyTaskResponse(jsonData)
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end
		local data = jsonDic['data']
		local dailyTask = data['daily_task']
		if next(dailyTask) then
			local str = json.encode(dailyTask)
			UserData:setDailyTaskData(str)
		else
			UserData:setDailyTaskData('{}')
		end

		if data['got_score'] ~= nil then
			local markData = UserData:getMarkData()
			markData['daily_task'] = data['got_score']
			local markStr = json.encode(markData)
			UserData:setMarkData(markStr)
		end

		updatePanel()
	end

	local function getDailyTask()
		local openlv = getGlobalIntegerValue('VitilityOpenLevel')
		local playerLv = PlayerCoreData.getPlayerLevel()

		if playerLv < tonumber(openlv) then
			local s = string.format(getLocalStringValue('E_STR_TRAIN_LIMIT') , openlv)
			GameController.showMessageBox(s, MESSAGE_BOX_TYPE.OK)
			return
		end

		Message.sendPost('get_dailytask','task','{}',getDailyTaskResponse)
	end

	getDailyTask()
end