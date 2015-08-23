genWbossMainPanel = function()
	-- ui 
	local sceneObj
	local root
	local timeCDTx
	local ballTimeCDTx
	local tipsPanel
	-- data 
	local longPressed = false

	local function getChild( parent , name , ttype )
		return tolua.cast(parent:getChildByName(name) , ttype)
	end

	local function updateLeftPanel()
		local leftPl = getChild(root , 'left_img' , 'UIImageView')
		-- kill reward --
		local getKillAwardBtn = getChild(leftPl , 'kill_award_btn' , 'UITextButton')
		local killInfoTx = getChild(leftPl , 'kill_info_tx' , 'UILabel')
		local joinInfoTx = getChild(leftPl , 'box_info_tx' , 'UILabel')
		local item_1 = getChild(leftPl , 'photo_1_ico' , 'UIImageView')
		local item_2 = getChild(leftPl , 'photo_2_ico' , 'UIImageView')
		local ico_1 = getChild(item_1 , 'award_ico' , 'UIImageView')
		local ico_2 = getChild(item_2 , 'award_ico' , 'UIImageView')
		local num_tx_1 = getChild(item_1 , 'number_tx' , 'UILabel')
		local num_tx_2 = getChild(item_2 , 'number_tx' , 'UILabel')

		local killData = wBossData:getConfData('kill')
		local awardObj_1 = UserData:getAward(killData['Award1'])
		local awardObj_2 = UserData:getAward(killData['Award2'])
		killInfoTx:setPreferredSize(230,1)
		joinInfoTx:setPreferredSize(230,1)

		item_1:setTouchEnable(true)
		item_2:setTouchEnable(true)
		item_1:registerScriptTapHandler(function ()
			UISvr:showTipsForAward(killData['Award1'])
		end)
		item_2:registerScriptTapHandler(function ()
			UISvr:showTipsForAward(killData['Award2'])
		end)

		ico_1:setTexture(awardObj_1.icon)
		ico_2:setTexture(awardObj_2.icon)
		num_tx_1:setText(toWordsNumber(awardObj_1.count))
		num_tx_2:setText(toWordsNumber(awardObj_2.count))

		if wBossData:getData().killer.name then
			killInfoTx:setText( string.format(getLocalString('E_STR_FINAL_KILL_BOSS_NAME') , wBossData:getData().killer.name) )
		else
			killInfoTx:setText( getLocalString('E_STR_FINAL_KILL_BOSS_GAIN') )
		end

		if tonumber(wBossData:getData().last_rank) > 0 then
			joinInfoTx:setText( string.format(getLocalString('E_STR_LAST_WORLDBOSS_RANK') , tostring(wBossData:getData().last_rank)) )
		else
			joinInfoTx:setText( getLocalString('E_STR_CLICK_BOX_LOOK_INFO') )
		end

		-- 非战期间
		local isNoWar = wBossData:getProgress() ~= wBossData.WARING
		cclog('is in waring ...')
		-- 击杀奖励
		local kill = wBossData:getData().rewards.kill or 0
		local uid = wBossData:getData().killer.uid or 0
		local isShowBtn = uid == PlayerCoreData.getUID() and kill == 0

		getKillAwardBtn:setVisible(isShowBtn)
		item_1:setVisible(not isShowBtn)
		item_2:setVisible(not isShowBtn)

		-- 参与奖励
		local boxBtn = getChild(leftPl ,'joinwar_box_btn' , 'UIImageView')
		local joinAwardBtn = getChild(leftPl ,'join_award_btn' , 'UITextButton')

		local join = wBossData:getData().rewards.join or 0
		isShowBtn = tonumber(wBossData:getData().last_rank) > 0 and join == 0

		joinAwardBtn:setVisible(isShowBtn)
		boxBtn:setVisible(not isShowBtn)

	end

	local function updateRightPanel()
		local rightPl = getChild(root ,'right_img' , 'UIImageView')
		for i = 1 , 5 do
			local itemTx = getChild(rightPl , 'name_' .. i .. '_tx' , 'UILabel')
			itemTx:setText(wBossData:getData().last_top5[i] or getLocalString('E_STR_NO_PERSON_ON_RANK'))
		end
	end

	local function updateDragonBallPanel()
		local background = getChild(root, 'boss_bg_img', 'UIImageView')
		local dragonBox = getChild(background ,'box_ico' , 'UIImageView')
		
		for i = 1 , 7 do
			local ballBg = getChild(background , 'zhu_bg_' .. i .. '_ico' , 'UIImageView')
			local ballBtn = getChild(ballBg , 'ball_btn' , 'UIButton')
			local num_tx = getChild(ballBg , 'num_tx' , 'UILabel')
			local circle = getChild(ballBg , 'zhu_quan_ico' , 'UIImageView')
			local num = tonumber(wBossData:getData().dragon_balls[tostring(i)]) or 0
			num_tx:setText( tostring(num) )
			local array = CCArray:create()
			array:addObject(CCRotateBy:create(3 , 360))
			local action = CCRepeatForever:create(CCSequence:create(array))
			circle:stopAllActions()

			if num > 0 then
				ballBtn:setColor( ccc3(255,255,255) ) 
				circle:setVisible(true)
				circle:runAction(action)
			else
				ballBtn:setColor( ccc3(144,148,112) ) 
				circle:setVisible(false)
			end
		end

		if wBossData:isHaveDragonBoxReward() then
			dragonBox:setTexture('uires/ui_2nd/com/panel/boss/box_open.png')
		else
			dragonBox:setTexture('uires/ui_2nd/com/panel/boss/box_lock.png')
		end
	end

	local function updateTimePanel()
		local timePl = getChild(root ,'title_ico' , 'UIImageView')
		local descTx = getChild(timePl ,'war_time_tx' , 'UILabel')

		local progress , leftTime = wBossData:getProgress()

		timeCDTx:setTime(leftTime)

		if progress == wBossData.BEFORE_WAR or progress == wBossData.AFTER_WAR then
			timeCDTx:registerTimeoutHandler(function ()
				cclog('wboss war starting ...')
				CUIManager:GetInstance():HideObject(sceneObj, ELF_SHOW.NORMAL)
				worldboss.enter()
			end)
			descTx:setText( getLocalString('E_STR_WORLD_BOSS_START_DESC') )
		elseif progress == wBossData.WARING then
			timeCDTx:registerTimeoutHandler(function ()
				cclog('wboss war ending ...')
				updateTimePanel()
			end)
			descTx:setText( getLocalString('E_STR_WORLD_BOSS_WARING_DESC') )
		else
			cclog('failed to find progress ... ')
		end

		leftTime = wBossData:getData().next_ball_clear - UserData:getServerTime()
		if leftTime > 0 then
			ballTimeCDTx:setTime(leftTime)
		else
			cclog('error to setballtime ...')
		end
	end

	local function update()
		updateLeftPanel()
		updateRightPanel()
		updateDragonBallPanel()
		updateTimePanel()
	end

	-- 点击购买龙珠
	local function onClickDragonBall( id )
		local cost , times = wBossData:getBuyCostByKeyAndTimes('CashWorldBossDragonBall' , wBossData:getData().buy_times)

		if times <= 0 then
			GameController.showPrompts(getLocalStringValue('BALL_BUY_TIMES_OVER'), COLOR_TYPE.RED)
			return
		end
	
		GameController.showMessageBox(string.format(getLocalString('E_STR_WORLD_BOSS_DRAGON_BALL_BUY'), tostring(cost)), MESSAGE_BOX_TYPE.OK_CANCEL, function ()	
			if PlayerCoreData.getCashValue() < cost then
				GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
				return
			end

			local args = {star = id}

			Message.sendPost('buy_dragon_ball','worldboss',json.encode(args),function (jsonData)
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic['code'] ~= 0 then
					cclog('request error : ' .. jsonDic['desc'])
					return
				end

				local data = jsonDic['data']
				if data['cash'] then
					PlayerCoreData.addCashDelta( tonumber(data['cash']) )
				end

				local beforeStatus = wBossData:isHaveDragonBoxReward()

				wBossData:getData().buy_times = wBossData:getData().buy_times + 1

				local oldNum = wBossData:getData().dragon_balls[tostring(id)]
				wBossData:getData().dragon_balls[tostring(id)] = oldNum + 1

				local afterStatus = wBossData:isHaveDragonBoxReward()

				if beforeStatus ~= afterStatus then
					local background = getChild(root, 'boss_bg_img', 'UIImageView')
					local dragonBox = getChild(background ,'box_ico' , 'UIImageView')

					local particle1 = CCParticleSystemQuad:create("particles/advanced_boom1.plist")
					particle1:setPosition( ccp(85,50) )
					particle1:setAutoRemoveOnFinish(true)
					particle1:setSpeedVar(0.5)
					particle1:setScale(1.5)
					dragonBox:getValidNode():addChild(particle1, 200)

					local particle2 = CCParticleSystemQuad:create("particles/advanced_boom2.plist")
					particle2:setPosition( ccp(85,50) )
					particle2:setAutoRemoveOnFinish(true)
					particle1:setSpeedVar(0.5)
					particle2:setScale(1.5)
					dragonBox:getValidNode():addChild(particle2, 201)
				end

				updateDragonBallPanel()
			end)
		end)
	end

	local function getRewardRequest( ttype )
		local args = {type = ttype}

		Message.sendPost('get_rewards','worldboss',json.encode(args),function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']
			if data['awards'] then
				local tab = {}
				for k , v in pairs ( data['awards'] ) do
					local awardStr = v[1] .. '.' .. v[2] .. ':' .. v[3]
					table.insert(tab , awardStr)
				end

				local notice = ''
				if ttype == 'kill' then
					notice = getLocalString('E_STR_KILL_REWARD')
				elseif ttype == 'join' then
					notice = getLocalString('E_STR_JOIN_REWARD')
				elseif ttype == 'box' then
					notice = getLocalString('E_STR_DRAGONBALL_REWARD')
				elseif ttype == 'hurt' then
					notice = getLocalString('E_STR_HURT_REWARD')
				end

				genShowTotalAwardsPanel(tab , notice)
				UserData.parseAwardJson(json.encode(data['awards']))
			end

			if ttype == 'join' or ttype == 'kill' or ttype == 'hurt' then
				wBossData:getData().rewards[ttype] = 1
			elseif ttype == 'box' then
				for i = 1 , 7 do
					if wBossData:getData().dragon_balls[tostring(i)] then
						local oldNum = wBossData:getData().dragon_balls[tostring(i)]
						wBossData:getData().dragon_balls[tostring(i)] = oldNum - 1  
					end
				end
			end

			update()
		end)
	end

	local function panelAdapting( root )
		local winSize = CCDirector:sharedDirector():getWinSize()

		local background = tolua.cast(root:getChildByName('boss_bg_img'), 'UIImageView')
		background:setPosition( ccp(winSize.width / 2 , winSize.height / 2) )

		local titleLeftIco = tolua.cast(root:getChildByName('title_left_ico') , 'UIImageView')
		titleLeftIco:setPosition( ccp(0 , winSize.height) )

		local titleRightIco = tolua.cast(root:getChildByName('title_right_ico') , 'UIImageView')
		titleRightIco:setPosition( ccp(winSize.width , winSize.height) )

		local titleIco = tolua.cast(root:getChildByName('title_ico') , 'UIImageView')
		titleIco:setPosition( ccp(winSize.width / 2 , winSize.height) )
		titleIco:setScale9Size( CCSizeMake(winSize.width - 220 , 65) )

		local leftPanel = tolua.cast(root:getChildByName('left_img') , 'UIImageView')
		leftPanel:setPosition( ccp(0 , winSize.height / 2 - leftPanel:getContentSize().height / 2) )

		local rightPanel = tolua.cast(root:getChildByName('right_img') , 'UIImageView')
		rightPanel:setPosition( ccp(winSize.width , winSize.height / 2 - rightPanel:getContentSize().height / 2) )

		local helpBtn = getChild(root ,'help_btn' , 'UIButton')
		helpBtn:setPosition( ccp(0 , winSize.height) )

		local closeBtn = getChild(root ,'close_btn' , 'UIButton')
		closeBtn:setPosition( ccp(winSize.width + 16 , winSize.height + 16) )
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/boss_main_panel.json' , 'boss_main_panel-in-lua')
		local panel = sceneObj:getPanelObj()

		panel:registerInitHandler(function ()
			root = panel:GetRawPanel()

			panelAdapting(root)
			
			local closeBtn = getChild(root ,'close_btn' , 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			local helpBtn = getChild(root ,'help_btn' , 'UIButton')
			helpBtn:registerScriptTapHandler(function ()
				genWorldBossChallengeHelpPanel()
			end)
			GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			-- right panel -- 
			local rightPl = getChild(root ,'right_img' , 'UIImageView')
			rightPl:setTouchEnable(true)
			rightPl:registerScriptTapHandler(function()
				genWorldBossRankPanel()
			end)

			local totalHurtBtn = getChild(rightPl ,'total_hurt_btn' , 'UIButton')
			totalHurtBtn:registerScriptTapHandler(function()
				CUIManager:GetInstance():HideObject(sceneObj, ELF_SHOW.NORMAL)
				genBossHurtRewardPanel('main')
			end)
			GameController.addButtonSound(totalHurtBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			--left panel --
			local leftpl = getChild(root ,'left_img' , 'UIImageView')
			local boxBtn = getChild(leftpl ,'joinwar_box_btn' , 'UIImageView')
			boxBtn:registerScriptTapHandler(function()
				genWorldBossAwardTips()
			end)

			local killAwardBtn = getChild(leftpl ,'kill_award_btn' , 'UITextButton')
			killAwardBtn:registerScriptTapHandler(function()
				getRewardRequest('kill')
			end)

			local joinAwardBtn = getChild(leftpl ,'join_award_btn' , 'UITextButton')
			joinAwardBtn:registerScriptTapHandler(function()
				getRewardRequest('join')
			end)

			GameController.addButtonSound(killAwardBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			GameController.addButtonSound(joinAwardBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			local background = getChild(root, 'boss_bg_img', 'UIImageView')
			local dragonBox = getChild(background ,'box_ico' , 'UIImageView')

			local function hideAwardTips()
				if longPressed then 
					tipsPanel:removeFromParentAndCleanup(true)
					longPressed = false
					return
				end
			end

			local function onShowTips()
				local data = wBossData:getConfData('dragonbox')
				if data == nil then
					return 
				end

				tipsPanel = UIImageView:create()
				tipsPanel:setTexture('uires/ui_2nd/com/panel/mainscene/zhan_tips.png')
				tipsPanel:setScale9Enable(true)
				tipsPanel:setAnchorPoint(ccp(0, 0))

				-- add award item
				local keyTab = {'Award1' , 'Award2' , 'Award3' , 'Award4'}
				local defaultX = 110
				local finalX = 0
				local length = 0
				for _, v in pairs (keyTab) do
					if data[v] and data[v] ~= '' then
						local tab = UserData:getAward( data[v] )

						local item = GameController.createItem( tab )
						item:setPosition( ccp( defaultX + length * 140 , 100) )
						finalX = defaultX + length * 140

						tipsPanel:addChild(item)

						length = length + 1
					end
				end

				tipsPanel:setScale9Size(CCSizeMake(finalX + defaultX , 160))

				local winSize = CCDirector:sharedDirector():getWinSize()
				tipsPanel:setPosition( ccp((winSize.width - (finalX + defaultX)) / 2 , winSize.height / 2 + 60) )
				tipsPanel:setWidgetZOrder(999)
				root:addChild(tipsPanel)

				longPressed = true
			end

			-- dragon ball panel --
			-- for i = 1 , 7 do
			-- 	local ballBg = getChild(background , 'zhu_bg_' .. i .. '_ico' , 'UIImageView')
			-- 	local ballBtn = getChild(ballBg , 'ball_btn' , 'UIButton')

			-- 	ballBtn:setTouchEnable(true)
			-- 	ballBtn:registerScriptTapHandler( function ()
			-- 		onClickDragonBall( i )
			-- 	end)
			-- end
			-- dragon box --
			dragonBox:setTouchEnable(true)
			dragonBox:registerScriptLongPressHandler(function ()
				onShowTips()
			end)
			dragonBox:registerScriptTapHandler( function ()
				if longPressed then 
					hideAwardTips()
					longPressed = false
					return
				end

				if wBossData:isHaveDragonBoxReward() then
					getRewardRequest('box')
				end
			end)
			dragonBox:registerScriptCancelHandler(function ()
				hideAwardTips()
			end)

			-- start war time panel --
			local timePl = getChild(root ,'title_ico' , 'UIImageView')
			local cdTx = getChild(timePl ,'cd_time_tx' , 'UILabel')
			timeCDTx = UICDLabel:create()
			timeCDTx:setFontSize(28)
			timeCDTx:setPosition(ccp(80,0))
			timeCDTx:setFontColor(COLOR_TYPE.WHITE)
			cdTx:addChild(timeCDTx)

			-- ball update time panel --
			timePl = getChild(background ,'time_bg_ico' , 'UIImageView')
			cdTx = getChild(timePl ,'cd_time_tx' , 'UILabel')
			ballTimeCDTx = UICDLabel:create()
			ballTimeCDTx:setFontSize(28)
			ballTimeCDTx:setPosition(ccp(40,0))
			ballTimeCDTx:setFontColor(COLOR_TYPE.WHITE)
			cdTx:addChild(ballTimeCDTx)
			ballTimeCDTx:registerTimeoutHandler( function ()
				for i = 1 , 7 do
					if wBossData:getData().dragon_balls[tostring(i)] then
						wBossData:getData().dragon_balls[tostring(i)] = 0 
					end
				end
				updateDragonBallPanel()
			end)

			update()
		end)

		panel:registerOnShowHandler(function ()
			updateDragonBallPanel()
		end)

		UiMan.show(sceneObj)
	end

	createPanel()
end
