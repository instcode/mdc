genWorldBossBattlePanel = function()
	--ui
	local sceneObj
	local root
	local timeCDTx
	local reviveTimeCDTx
	-- data
	local curInsprieTimes		-- 当前鼓舞次数
	local killed = 0
	local needUpdate = false
	local isAuto = false
	local isTimeEnd = true
	local hurt = 0
	local isHurtUpfate = false

	local function getMonsterDataById( monsterid )
		local conf = GameData:getArrayData('monster.dat')
		for k , v in pairs( conf ) do
			if tonumber(monsterid) == tonumber(v.Id) then
				return v
			end
		end
		return nil
	end

	local function getChild( parent , name , ttype )
		return tolua.cast(parent:getChildByName(name) , ttype) 
	end

	local function initBoss()
		local background = getChild(root , 'king_bg_img' , 'UIImageView')

		local bossData = getMonsterDataById( tonumber(wBossData:getData().boss.id) )

		local legion = CLegion:create(true)
		legion:updateRoleId( tonumber(wBossData:getData().boss.id) )
		legion:updateInitStatus( tonumber(bossData['Health']) , 0)
		legion:SetSoliderType( tonumber(bossData['Soldier']) )
		legion:SetGodType( tonumber(bossData['God']) )
		legion:InitSoldiers( tonumber(bossData['SoldierLevel']) , false )
		legion:setPosition(background:getContentSize().width / 2 , background:getContentSize().height / 2 - 100)
		legion:setScale( 1.5 )
		
		background:getValidNode():addChild(legion)
	end

	local function updateHeadPanel()
		local headImg = getChild(root , 'head_img' , 'UIImageView')
		local bossPic = getChild(headImg , 'photo_img' , 'UIImageView')
		local nameTx = getChild(headImg , 'name_tx' , 'UILabel')
		local healthBar = getChild(headImg , 'health_bar' , 'UILoadingBar')
		local healthTx = getChild(healthBar , 'health_tx' , 'UILabel')
		local cdLabel = getChild(headImg , 'time_desc_tx' , 'UILabel')
		local cdTimeTx = getChild(headImg , 'cdtime_tx' , 'UILabel')

		local bossData = getMonsterDataById( tonumber( wBossData:getData().boss.id ) )
		nameTx:setText(GetTextForCfg(bossData['Name']))
		local url = string.gsub('uires/ui_2nd/image/' .. bossData['URL'] , '_big' , '_icon' )
		bossPic:setTexture( url )
		local percent = tonumber(wBossData:getData().boss.health) / tonumber(wBossData:getData().boss.blood) * 100
		healthBar:setPercent( percent )
		local perStr = '0.00'
		if percent > 0 then
			perStr = string.format( '%0.2f' , percent)
			if tonumber(perStr) < 0.01 then
				perStr = '0.01'
			end
		end

		healthTx:setColor(percent >= 20 and COLOR_TYPE.WHITE or COLOR_TYPE.RED)

		healthTx:setText( perStr .. '%')
	end

	local function updateInspirePanel()
		local inspriePl = getChild(root ,'guwu_pl' , 'UIPanel')
		local cashTx = getChild(inspriePl , 'cash_tx' , 'UILabel')
		local goldTx = getChild(inspriePl , 'gold_tx' , 'UILabel')

		local gInspireTimes = tonumber(wBossData:getData().inspire.gold)
		local cInsprieTimes = tonumber(wBossData:getData().inspire.cash)
		local goldCost = wBossData:getBuyCostByKeyAndTimes('GoldWorldBossInspire' , gInspireTimes)
		local cashCost = wBossData:getBuyCostByKeyAndTimes('CashWorldBossInspire' , cInsprieTimes)

		cashTx:setText( tostring(cashCost) )
		goldTx:setText( tostring(goldCost) )
	end

	local function updateInfoPanel()
		local infoPl = getChild(root , 'info_pl' , 'UIPanel')
		local rankTx = getChild(infoPl , 'rank_number_tx' , 'UILabel')
		local attackTimesTx = getChild(infoPl , 'attack_number_tx' , 'UILabel')
		local attackAddTx = getChild(infoPl , 'hurt_number_1_tx' , 'UILabel')
		local hurtTx = getChild(infoPl , 'hurt_number_2_tx' , 'UILabel')
		local hurtPercentTx = getChild(infoPl , 'hurt_number_3_tx' , 'UILabel')
		local arrow = getChild(infoPl , 'arrow_ico' , 'UIImageView')

		hurt = tonumber(wBossData:getData().battle_info.hurt) or 0
		rankTx:setText( tostring(wBossData:getData().battle_info.rank) )
		attackTimesTx:setText( tostring(wBossData:getData().battle_info.attacks) )
		attackAddTx:setText( tostring(wBossData:getData().battle_info.inspire_add) .. '%' )
		hurtTx:setText( tostring(toWordsNumber(wBossData:getData().battle_info.hurt)) )
		arrow:setVisible(tonumber(wBossData:getData().battle_info.inspire_add) > 0)

		local percent = tonumber(wBossData:getData().battle_info.hurt) / tonumber(wBossData:getData().boss.blood) * 100
		local perStr = '0.00'
		if percent > 0 then
			perStr = string.format( '%0.2f' , percent)
			if tonumber(perStr) < 0.01 then
				perStr = '0.01'
			end
		end
		
		hurtPercentTx:setText( perStr .. '%' )
	end

	local function updateBtnPanel()
		local btnPl = getChild(root , 'attack_pl' , 'UIPanel')
		local challengeBtn = getChild(btnPl , 'challenge_tbtn' , 'UITextButton')
		local reviveBtn = getChild(btnPl , 'again_tbtn' , 'UITextButton')
		local reviveTx = getChild(btnPl , 'revive_desc_tx' , 'UILabel')

		local reviveTime = tonumber(wBossData:getData().death_time) + getGlobalIntegerValue('WorldBossReviveColdTime')
		if reviveTime > UserData:getServerTime() then
			challengeBtn:setVisible(false)
			reviveBtn:setVisible(true)
			reviveTx:setVisible(true)
			reviveTimeCDTx:setTime( reviveTime - UserData:getServerTime() + 1)
			isTimeEnd = false
		else
			challengeBtn:setVisible(true)
			reviveBtn:setVisible(false)
			reviveTx:setVisible(false)
		end
	end

	local function updateAll()
		updateHeadPanel()
		updateInspirePanel()
		updateInfoPanel()
		updateBtnPanel()
	end

	local function checkBossIsDie( data )
		if data['is_die'] then
			GameController.showMessageBox(getLocalString('E_STR_WORLD_BOSS_KILLED'), MESSAGE_BOX_TYPE.OK, function ()
				CUIManager:GetInstance():HideObject(sceneObj, ELF_SHOW.NORMAL)
				worldboss.enter()
			end)
			return true
		end
		return false
	end


	local function doUpdate()
		Message.sendPost('get','worldboss','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']
			if data.battle_info and data.battle_info.hurt and isHurtUpfate == true then
				GameController.showPrompts( string.format(getLocalString('E_STR_WORLD_BOSS_HURT'),tonumber(data.battle_info.hurt) - hurt or 0), COLOR_TYPE.GREEN)
				hurt = tonumber(data.battle_info.hurt)
			end
			wBossData:updateData(data)

			if data.boss then
				needUpdate = false

				updateAll()
			else
				checkBossIsDie({is_die = 1})
			end
		end)
	end

	local function doAttack()
		Message.sendPost('fight','worldboss','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				isTimeEnd = false
				return
			end

			local data = jsonDic['data']

			if checkBossIsDie( data ) then
				return
			end

			needUpdate = true

			if data['battle'] and data['boss_blood'] then
				GameController.clearAwardView()
				data['battle']['boss_blood'] = data['boss_blood']
				if isAuto ~= true then
					GameController.playBattle(json.encode(data['battle']) , 3 , 5)
				else
					if killed == 1 then
						killed = 0
						needUpdate = false
						checkBossIsDie({is_die = 1})
					else
						if needUpdate then
							cclog('is doUpdate')
							isHurtUpfate = true
							doUpdate()
						end
					end
				end
			end

			killed = data['killed'] or 0

		end)
	end

	local function doRevive()
		local times = tonumber(wBossData:getData().revive_times)
		local cost , leftTimes = wBossData:getBuyCostByKeyAndTimes( 'CashWorldBossRevive' , times )
		local str = string.format( getLocalString('E_STR_WORLD_BOSS_REVIVE') , tostring(cost) )

		if leftTimes <= 0 then
			GameController.showPrompts( getLocalString('REVIVE_BUY_TIMES_OVER') , COLOR_TYPE.RED)
			return
		end

		GameController.showMessageBox(str, MESSAGE_BOX_TYPE.OK_CANCEL, function ()
			if cost > PlayerCoreData.getCashValue() then
				GameController.showPrompts( getLocalString('E_STR_CASH_NOT_ENOUGH') , COLOR_TYPE.RED)
				return
			end

			Message.sendPost('revive','worldboss','{}',function (jsonData)
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic['code'] ~= 0 then
					cclog('request error : ' .. jsonDic['desc'])
					return
				end

				local data = jsonDic['data']

				if checkBossIsDie( data ) then
					return
				end

				if data['cash'] then
					PlayerCoreData.addCashDelta( tonumber(data['cash']) )
				end

				wBossData:getData().death_time = 0
				wBossData:getData().revive_times = wBossData:getData().revive_times + 1

				isTimeEnd = true
				if isAuto == true then
					doAttack()
				else
					updateBtnPanel()
				end
			end)
		end)
	end

	local function doInsprite( ttype )
		local curInspireAdd = tonumber(wBossData:getData().battle_info.inspire_add)
		if curInspireAdd >= getGlobalIntegerValue('WorldBossInspireMaxLimit') then
			GameController.showPrompts( getLocalString('E_STR_INSPIRE_MAX_LIMIT') , COLOR_TYPE.RED)
			return 
		end

		local gInspireTimes = tonumber(wBossData:getData().inspire.gold)
		local cInsprieTimes = tonumber(wBossData:getData().inspire.cash)
		local goldCost , goldLeftTimes = wBossData:getBuyCostByKeyAndTimes('GoldWorldBossInspire' , gInspireTimes)
		local cashCost , cashLeftTimes = wBossData:getBuyCostByKeyAndTimes('CashWorldBossInspire' , cInsprieTimes)

		local str = ''
		local hasNum = 0
		local needNum = 0
		if ttype == 'gold' then
			hasNum = PlayerCoreData.getGoldValue()
			needNum = goldCost
			str = string.format(getLocalString('E_STR_COST_GOLD_INSPIRE_MORALE') , tostring(goldCost) , tostring(getGlobalIntegerValue('WorldBossInspireAttackAdd')) .. '%')
		elseif ttype == 'cash' then
			hasNum = PlayerCoreData.getCashValue()
			needNum = cashCost
			str = string.format(getLocalString('E_STR_COST_CASH_INSPIRE_MORALE') , tostring(cashCost) , tostring(getGlobalIntegerValue('WorldBossInspireAttackAdd')) .. '%')
		end

		if ttype == 'gold' and goldLeftTimes <= 0 then
			GameController.showPrompts( getLocalString('GOLD_INSPIRE_TIMES_OVER') , COLOR_TYPE.RED)
			return
		end

		if ttype == 'cash' and cashLeftTimes <= 0 then
			GameController.showPrompts( getLocalString('CASH_INSPIRE_TIMES_OVER') , COLOR_TYPE.RED)
			return
		end

		GameController.showMessageBox(str, MESSAGE_BOX_TYPE.OK_CANCEL, function ()
			if hasNum < needNum then
				GameController.showPrompts( getLocalString( ttype == 'gold' and 'E_STR_NOT_ENOUGH_GOLD' or 'E_STR_CASH_NOT_ENOUGH') , COLOR_TYPE.RED)
				return 
			end

			local args = {type = ttype}
			Message.sendPost('inspire','worldboss', json.encode(args),function (jsonData)
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic['code'] ~= 0 then
					cclog('request error : ' .. jsonDic['desc'])
					return
				end

				local data = jsonDic['data']

				if checkBossIsDie( data ) then
					return
				end

				if data['cash'] then
					wBossData:getData().inspire.cash = wBossData:getData().inspire.cash + 1
					PlayerCoreData.addCashDelta( tonumber(data['cash']) )
				end
				if data['gold'] then
					wBossData:getData().inspire.gold = wBossData:getData().inspire.gold + 1
					PlayerCoreData.addGoldDelta( tonumber(data['gold']) )
				end

				local oldadd = tonumber(wBossData:getData().battle_info.inspire_add)
				wBossData:getData().battle_info.inspire_add = oldadd + getGlobalIntegerValue('WorldBossInspireAttackAdd')

				updateInspirePanel()
				updateInfoPanel()

				GameController.showPrompts( getLocalString('E_STR_SUCCESS_INSPIRE') , COLOR_TYPE.GREEN )
			end)
		end)
	end

	local function panelAdapting()
		local winSize = CCDirector:sharedDirector():getWinSize()

		local background = getChild(root , 'king_bg_img' , 'UIImageView')
		background:setPosition( ccp(winSize.width / 2 , winSize.height / 2) )

		local headIco = getChild(root , 'head_img' , 'UIImageView')
		headIco:setPosition( ccp(winSize.width / 2 , winSize.height) )

		local closeBtn = getChild(root ,'close_btn' , 'UIButton')
		closeBtn:setPosition( ccp(winSize.width , winSize.height) )

		local helpBtn = getChild(root ,'help_btn' , 'UIButton')
		helpBtn:setPosition( ccp(15 , winSize.height - 15) )

		local leftPanel = getChild(root ,'guwu_pl' , 'UIPanel')
		leftPanel:setPosition( ccp(0 , winSize.height / 2 - leftPanel:getContentSize().height / 2) )

		local rightPanel = getChild(root ,'info_pl' , 'UIPanel')
		rightPanel:setPosition( ccp(winSize.width - rightPanel:getContentSize().width , winSize.height / 2 - rightPanel:getContentSize().height / 2) )

		local attackPanel = getChild(root , 'attack_pl' , 'UIPanel')
		attackPanelSize  = attackPanel:getContentSize()
		attackPanel:setPosition( ccp((winSize.width - attackPanel:getContentSize().width ) / 2.5 , attackPanelSize.height/3) )
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/boss_battle_panel.json' , 'worldboss-battle-in-lua')
		local panel = sceneObj:getPanelObj()

		panel:registerInitHandler(function ()

			root = panel:GetRawPanel()

			panelAdapting()

			local closeBtn = getChild(root ,'close_btn' , 'UIButton')
			closeBtn:registerScriptTapHandler(function()
				-- UiMan.genCloseHandler(sceneObj)
				if isAuto == true then
					GameController.showPrompts(getLocalString('E_STR_WORLD_BOSS_AUTOEND'), COLOR_TYPE.RED)
				end
				UiMan.hide(sceneObj)
			end)
				
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			local helpBtn = getChild(root ,'help_btn' , 'UIButton')
			helpBtn:registerScriptTapHandler(function ()
				genWorldBossRewardHelpPanel()
			end)
			GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			
			local buzhenBtn = getChild(root ,'buzhen_btn' , 'UIButton')
			local winSize = CCDirector:sharedDirector():getWinSize()
			local buzhenBtnSize = buzhenBtn:getContentSize()
			buzhenBtn:setPosition(ccp(buzhenBtnSize.width / 2 + 40, buzhenBtnSize.height / 2 + 30))
			buzhenBtn:registerScriptTapHandler(function ()
				OpenEmbattleUi()
			end)

			local bg = getChild(root ,'king_bg_img' , 'UIImageView')
			local headtitle = getChild(root ,'head_img' , 'UIImageView')
			local insprie_pl = getChild(root ,'guwu_pl' , 'UIPanel')
			local info_pl = getChild(root ,'info_pl' , 'UIPanel')
			local attack_pl = getChild(root ,'attack_pl' , 'UIPanel')

			info_pl:setTouchEnable(true)
			info_pl:registerScriptTapHandler( function ()
				genWorldBossRankPanel()
			end)

			local goldInsprieBtn = getChild(insprie_pl , 'gold_tbtn' , 'UITextButton')
			local cashInsprieBtn = getChild(insprie_pl , 'cash_tbtn' , 'UITextButton')
			local autoBtn = getChild(insprie_pl , 'auto_battle_btn' , 'UITextButton')
			goldInsprieBtn:registerScriptTapHandler(function ()
				doInsprite( 'gold' )
			end)
			cashInsprieBtn:registerScriptTapHandler(function ()
				doInsprite( 'cash' )
			end)
			autoBtn:registerScriptTapHandler(function ()
				if isAuto == true then
					autoBtn:setText(getLocalString('E_STR_BOSS_ISAUTO'))
					isAuto = false
				else
					autoBtn:setText(getLocalString('E_STR_BOSS_NOTAUTO'))
					isAuto = true
				end
				if isTimeEnd == true and isAuto == true then
					doAttack()
				end
			end)
			GameController.addButtonSound(goldInsprieBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			GameController.addButtonSound(cashInsprieBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			GameController.addButtonSound(autoBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			local challengeBtn = getChild(attack_pl , 'challenge_tbtn' , 'UITextButton')
			local reviveBtn = getChild(attack_pl , 'again_tbtn' , 'UITextButton')
			local killRewardBtn = getChild(info_pl , 'kill_award_btn' , 'UITextButton')
			local updateBtn = getChild(attack_pl , 'update_tbtn' , 'UITextButton')
			challengeBtn:registerScriptTapHandler(function ()
				doAttack()
			end)
			reviveBtn:registerScriptTapHandler(function ()
				doRevive()
			end)
			killRewardBtn:registerScriptTapHandler(function ()
				CUIManager:GetInstance():HideObject(sceneObj, ELF_SHOW.NORMAL)
				genBossHurtRewardPanel('battle')
			end)
			updateBtn:registerScriptTapHandler(function ()
				isHurtUpfate = false
				doUpdate()
			end)

			GameController.addButtonSound(challengeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			GameController.addButtonSound(reviveBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			GameController.addButtonSound(killRewardBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			GameController.addButtonSound(updateBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			local timeDescTx = getChild(headtitle ,'time_desc_tx' , 'UILabel')
			local cdTx = getChild(timeDescTx ,'cdtime_tx' , 'UILabel')
			timeCDTx = UICDLabel:create()
			timeCDTx:setFontSize(25)
			timeCDTx:setAnchorPoint(ccp(1,0.5))
			timeCDTx:setPosition(ccp(-0,0))
			timeCDTx:setFontColor(COLOR_TYPE.WHITE)
			cdTx:addChild(timeCDTx)
			timeCDTx:registerTimeoutHandler(function ()
				local progress, leftTime = wBossData:getProgress()
				if progress == wBossData.WARING then
					cclog('world boss war start ....')
					challengeBtn:setNormalButtonGray(false)
					challengeBtn:setTouchEnable(true)
					autoBtn:setNormalButtonGray(false)
					autoBtn:setTouchEnable(true)
					timeCDTx:setTime(leftTime)
				elseif progress == wBossData.AFTER_WAR then
					cclog('world boss war end ....')
					GameController.showMessageBox(getLocalString('E_STR_WORLD_BOSS_END'), MESSAGE_BOX_TYPE.OK, function ()
						CUIManager:GetInstance():HideObject(sceneObj, ELF_SHOW.NORMAL)
						worldboss.enter()
					end)
				end
			end)
			
			local progress, leftTime = wBossData:getProgress()
			if progress == wBossData.BEFORE_WAR or progress == wBossData.AFTER_WAR then
				challengeBtn:setNormalButtonGray(true)
				challengeBtn:setTouchEnable(false)
				autoBtn:setNormalButtonGray(true)
				autoBtn:setTouchEnable(false)
			else
				challengeBtn:setNormalButtonGray(false)
				challengeBtn:setTouchEnable(true)
				autoBtn:setNormalButtonGray(false)
				autoBtn:setTouchEnable(true)
			end
			timeCDTx:setTime(leftTime + 1) --和服务器存在同步问题

			-- 复活倒计时
			local reviveDescTx = getChild(attack_pl ,'revive_desc_tx' , 'UILabel')
			local reviveCdTx = getChild(reviveDescTx ,'cd_tx' , 'UILabel')
			reviveTimeCDTx = UICDLabel:create()
			reviveTimeCDTx:setFontSize(28)
			reviveTimeCDTx:setAnchorPoint(ccp(0,0.5))
			reviveTimeCDTx:setPosition(ccp(0,0))
			reviveTimeCDTx:setFontColor(COLOR_TYPE.WHITE)
			reviveCdTx:addChild(reviveTimeCDTx)
			reviveTimeCDTx:registerTimeoutHandler(function ()
				isTimeEnd = true
				if isAuto == true then
					doAttack()
				else
					updateBtnPanel()
				end
			end)

			updateAll()
			initBoss()
		end)

		panel:registerOnShowHandler(function ()
			if killed == 1 then
				killed = 0
				needUpdate = false
				checkBossIsDie({is_die = 1})
			else
				if needUpdate then
					cclog('is doUpdate')
					isHurtUpfate = false
					doUpdate()
				end
			end
		end)

		UiMan.show(sceneObj)
	end

	local function getDataRequest()
		createPanel()
	end

	-- 入口
	getDataRequest()
end