
LuckyCard = {}

-- 幸运卡牌数据
local luckyCardData = {}

function LuckyCard.isActive()
	return false
end

-- 活动是否超时
function LuckyCard.isOverTime()
	local actConf = GameData:getMapData('activities.dat')
	local time = UserData:getServerTime()
	local startTime = UserData:convertTime(1,actConf['luckycard'].StartTime)
	local endTime = UserData:convertTime(1,actConf['luckycard'].EndTime)
	if time > startTime and time < endTime then
		return false
	else
		return true
	end
end

-- 打开幸运卡牌帮助界面
local function genLuckyCardHelpPanel()
	local luckyCardHelp = SceneObjEx:createObj('panel/lucky_card_help_panel.json', 'lucky-card-help-lua')
    local panel = luckyCardHelp:getPanelObj()
    panel:setAdaptInfo('lucky_card_help_bg_img', 'lucky_card_help_img')

	panel:registerInitHandler(function()
    	root = panel:GetRawPanel()
		local luckyCardHelpBgImg = tolua.cast(root:getChildByName('lucky_card_help_bg_img'),'UIImageView')
		local luckyCardHelpImg = tolua.cast(luckyCardHelpBgImg:getChildByName('lucky_card_help_img'),'UIImageView')
		local titleImg = tolua.cast(luckyCardHelpImg:getChildByName('title_img'),'UIImageView')
		local closeBtn = tolua.cast(luckyCardHelpImg:getChildByName('close_btn'),'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(luckyCardHelp, ELF_HIDE.SMART_HIDE)
		end)
		local knowBtn = tolua.cast(luckyCardHelpImg:getChildByName('know_btn'),'UITextButton')
		GameController.addButtonSound(knowBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		knowBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(luckyCardHelp, ELF_HIDE.SMART_HIDE)
		end)
		local infoTx1 = tolua.cast(luckyCardHelpImg:getChildByName('info_1_tx'), 'UILabel')
		infoTx1:setText(getLocalStringValue('HELP_LUCKYCARD_1'))
		infoTx1:setPreferredSize(610,1)
		local infoTx2 = tolua.cast(luckyCardHelpImg:getChildByName('info_2_tx'), 'UILabel')
		infoTx2:setText(getLocalStringValue('HELP_LUCKYCARD_2'))
		infoTx2:setPreferredSize(610,1)
		local infoTx3 = tolua.cast(luckyCardHelpImg:getChildByName('info_3_tx'), 'UILabel')
		infoTx3:setText(getLocalStringValue('HELP_LUCKYCARD_3'))
		infoTx3:setPreferredSize(610,1)
		local infoTx4 = tolua.cast(luckyCardHelpImg:getChildByName('info_4_tx'), 'UILabel')
		infoTx4:setText(getLocalStringValue('HELP_LUCKYCARD_4'))
		infoTx4:setPreferredSize(610,1)	
		local infoTx5 = tolua.cast(luckyCardHelpImg:getChildByName('info_5_tx'), 'UILabel')
		infoTx5:setText(getLocalStringValue('HELP_LUCKYCARD_5'))
		infoTx5:setPreferredSize(610,1)
		local infoTx6 = tolua.cast(luckyCardHelpImg:getChildByName('info_6_tx'), 'UILabel')
		infoTx6:setText(getLocalStringValue('HELP_LUCKYCARD_6'))
		infoTx6:setPreferredSize(610,1)	
    end)

    panel:registerOnShowHandler(function ()
    end)

    panel:registerOnHideHandler(function ()
    end)
    
    CUIManager:GetInstance():ShowObject(luckyCardHelp, ELF_SHOW.SMART)
end

-- 幸运卡牌主界面
local function genLuckyCardPanel()
	-- UI
	local luckyCard
	local panel
	local closeBtn
	local helpBtn
	local refreshBtn
	local startBtn
	local awardBtn
	local turnBtn
	local rechargeBtn
	local timeOverTx
	local integralNumTx
	local selectedNumTx
	local timeInfoTx2
	-- array
	local cardArr = {}
	local cardBgArr = {}
	local tipsArr = {}
	local lightArr = {}
	-- 配置文件
	local luckyCardCostConf

	-- 常量
	local CARD_MAX_COUNT = 12

	local turnCardNum = 0
	local maxRefreshScore = 0
	local maxOpenScore = 0
	local jf = 0
	local jfCost = 0
	local cardPos = 0

	local CDTime

	local function lockPanle()
		closeBtn:setTouchEnable(false)
		helpBtn:setTouchEnable(false)
		refreshBtn:setTouchEnable(false)
		refreshBtn:setPressState(WidgetStateDisabled)
		startBtn:setTouchEnable(false)
		startBtn:setPressState(WidgetStateDisabled)
		awardBtn:setTouchEnable(false)
		awardBtn:setPressState(WidgetStateDisabled)
		turnBtn:setTouchEnable(false)
		turnBtn:setPressState(WidgetStateDisabled)
		rechargeBtn:setTouchEnable(false)
		for i = 1, CARD_MAX_COUNT do
			cardArr[i]:setTouchEnable(false)
			cardBgArr[i]:setTouchEnable(false)
		end
	end

	local function unlockPanel()
		closeBtn:setTouchEnable(true)
		helpBtn:setTouchEnable(true)
		refreshBtn:setTouchEnable(true)
		refreshBtn:setPressState(WidgetStateNormal)
		startBtn:setTouchEnable(true)
		startBtn:setPressState(WidgetStateNormal)
		awardBtn:setTouchEnable(true)
		awardBtn:setPressState(WidgetStateNormal)
		turnBtn:setTouchEnable(true)
		turnBtn:setPressState(WidgetStateNormal)
		rechargeBtn:setTouchEnable(true)
		for i = 1, CARD_MAX_COUNT do
			cardArr[i]:setTouchEnable(true)
			cardBgArr[i]:setTouchEnable(true)
		end
	end

	-- 设置卡牌的显示
	local function setAward(index, index2)
		local awardIco = tolua.cast(cardBgArr[index]:getChildByName('award_ico'),'UIImageView')
		local awardName = tolua.cast(cardBgArr[index]:getChildByName('name_tx'),'UILabel')
		local awardNum =  tolua.cast(cardBgArr[index]:getChildByName('num_tx'),'UILabel')
		awardName:setPreferredSize(125,1)
		local vStr
		if index2 ~= nil then
			vStr = luckyCardData.cards[index2][1] .. '.' .. luckyCardData.cards[index2][2] .. ':' .. luckyCardData.cards[index2][3]
		else
			vStr = luckyCardData.cards[index][1] .. '.' .. luckyCardData.cards[index][2] .. ':' .. luckyCardData.cards[index][3]
		end
		lightArr[index]:setVisible(false)
        local award = UserData:getAward(vStr)
        if award.quality == AWARD_QUALITY.WHITE then
        	cardBgArr[index]:setTexture('uires/ui_2nd/com/panel/lucky_card/card_blue.png')
        elseif award.quality == AWARD_QUALITY.GREEN then
        	cardBgArr[index]:setTexture('uires/ui_2nd/com/panel/lucky_card/card_blue.png')
        elseif award.quality == AWARD_QUALITY.BLUE then
        	cardBgArr[index]:setTexture('uires/ui_2nd/com/panel/lucky_card/card_blue.png')
        elseif award.quality == AWARD_QUALITY.PURPLE then
        	cardBgArr[index]:setTexture('uires/ui_2nd/com/panel/lucky_card/card_purple.png')
        elseif award.quality == AWARD_QUALITY.ORANGE then
        	cardBgArr[index]:setTexture('uires/ui_2nd/com/panel/lucky_card/card_orange.png')
        elseif award.quality == AWARD_QUALITY.RED then
        	cardBgArr[index]:setTexture('uires/ui_2nd/com/panel/lucky_card/card_red.png')
        elseif award.quality == AWARD_QUALITY.ARED then
        	cardBgArr[index]:setTexture('uires/ui_2nd/com/panel/lucky_card/card_red.png')
        elseif award.quality == AWARD_QUALITY.SRED then
        	lightArr[index]:setVisible(true)
        	cardBgArr[index]:setTexture('uires/ui_2nd/com/panel/lucky_card/card_red.png')
        end
		awardIco:setTexture(award.icon)
		awardName:setText(award.name)
		awardName:setColor(award.color)
		awardNum:setText(toWordsNumber(tonumber(award.count)))
		tipsArr[index] = vStr
	end

	-- 更新积分和按钮显示
	local function updateJfAndButton()
		-- 积分
		integralNumTx:setText(toWordsNumber(jf))
		if #luckyCardData.cards > 0 then -- 已经刷新出奖励了
			local openNum = #luckyCardData.open
			if openNum > 0 then -- 已经有翻开的牌了
				local selectedNumStr = openNum .. '/' .. GameData:getGlobalValue('LuckyCardMaxNum')
				selectedNumTx:setText(selectedNumStr)
				if openNum < maxOpenScore then
					openNum = tostring(luckyCardCostConf[openNum+1].OpenScore)
				else
					openNum = tostring(luckyCardCostConf[maxOpenScore].OpenScore)
				end
				timeInfoTx2:setText(openNum)
				refreshBtn:setVisible(false)
				startBtn:setVisible(false)
				awardBtn:setVisible(true)
				turnBtn:setVisible(false)
			else
				local selectedNumStr = '0/' .. GameData:getGlobalValue('LuckyCardMaxNum')
				selectedNumTx:setText(selectedNumStr)
				jfCost = 0
				if tonumber(luckyCardData.refresh) < maxRefreshScore then
					jfCost = tonumber(luckyCardCostConf[tonumber(luckyCardData.refresh)+1].RefreshScore)
				else
					jfCost = tonumber(luckyCardCostConf[maxRefreshScore].RefreshScore)
				end
				timeInfoTx2:setText(tostring(jfCost))
				awardBtn:setVisible(false)
				startBtn:setVisible(false)
				refreshBtn:setVisible(true)
				turnBtn:setVisible(true)
			end
		else -- 还没开始
			local selectedNumStr = '0/' .. GameData:getGlobalValue('LuckyCardMaxNum')
			selectedNumTx:setText(selectedNumStr)
			timeInfoTx2:setText('0')
			awardBtn:setVisible(false)
			turnBtn:setVisible(false)
			refreshBtn:setVisible(false)
			startBtn:setVisible(true)
		end
	end

	-- 更新界面
	local function updatePanel()
		updateJfAndButton()-- 更新积分和按钮显示
		-- 更新card以及按钮状态
		if #luckyCardData.cards > 0 then -- 已经刷新出奖励了
			local openNum = #luckyCardData.open
			if openNum > 0 then -- 已经有翻开的牌了
				for k, v in pairs(luckyCardData.open) do
					for k2, v2 in pairs(v) do
						cardArr[tonumber(k2)]:setVisible(false)
						cardBgArr[tonumber(k2)]:setVisible(true)
						setAward(tonumber(k2), tonumber(v2) + 1)
					end
				end
			else -- 没有翻开的牌
				for i=1, CARD_MAX_COUNT do
					setAward(i)
					cardArr[i]:setVisible(false)
					cardBgArr[i]:setVisible(true)
				end
			end
		else -- 还没开始
			for i = 1, CARD_MAX_COUNT do
				cardArr[i]:setTouchEnable(false)
			end
		end
	end

	-- 活动结束
	local function activityOver()
		refreshBtn:setTouchEnable(false)
		refreshBtn:setPressState(WidgetStateDisabled)
		startBtn:setTouchEnable(false)
		startBtn:setPressState(WidgetStateDisabled)
		turnBtn:setTouchEnable(false)
		turnBtn:setPressState(WidgetStateDisabled)
		for i = 1, CARD_MAX_COUNT do
			cardArr[i]:setTouchEnable(false)
		end
	end

	-- 所有卡牌翻转过来后把界面解锁
	local function startAndTurnCallBack(func)
		turnCardNum = turnCardNum + 1
		if turnCardNum >= CARD_MAX_COUNT then
			turnCardNum = 0
			unlockPanel()
			if func then
				func()
			end
		end
	end

	-- 刷新奖励回调
	local function doRefreshLuckyCardResponse(jsonData)
		print(jsonData)
		local response = json.decode(jsonData)
		local code = tonumber(response.code)
		if code == 0 then
			luckyCardData.cards = response.data.cards
			luckyCardData.refresh = response.data.refresh
			jf = tonumber(response.data.score)
			lockPanle()
			turnCardNum = 0
			tipsArr = {}
			for i=1, CARD_MAX_COUNT do
				local arr = CCArray:create()
		        arr:addObject(CCOrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0))
		        arr:addObject(CCCallFunc:create(function()
		      		cardArr[i]:setVisible(true)
					cardBgArr[i]:setVisible(false)
		        	local arr2 = CCArray:create()
		        	arr2:addObject(CCOrbitCamera:create(0.2, 1, 0, 270, 90, 0, 0))
		        	arr2:addObject(CCCallFunc:create(function ()
		        		setAward(i)
		        		local arr3 = CCArray:create()
		        		arr3:addObject(CCOrbitCamera:create(0.2, 1, 0, 0, -90, 0, 0))
		        		arr3:addObject(CCCallFunc:create(function()
		        			cardArr[i]:setVisible(false)
							cardBgArr[i]:setVisible(true)
		        			local arr4 = CCArray:create()
			        		arr4:addObject(CCOrbitCamera:create(0.2, 1, 0, 90, -90, 0, 0))
			        		arr4:addObject(CCCallFunc:create(function()
			        			-- 刷新动画结束后解锁button和更新积分
			        			startAndTurnCallBack(updateJfAndButton)
			        		end))
			        		local seq4 = CCSequence:create(arr4)
			        		cardBgArr[i]:runAction(seq4)
		        		end))
		        		local seq3 = CCSequence:create(arr3)
		        		cardArr[i]:runAction(seq3)
		        	end))
		        	local seq2 = CCSequence:create(arr2)
		        	cardArr[i]:runAction(seq2)
		        end))
		        local seq = CCSequence:create(arr)
		        cardBgArr[i]:runAction(seq)
			end
		end
	end

	-- 点击刷新奖励
	local function onClickRefreshHandle()
		if jfCost > jf then
			GameController.showPrompts(getLocalStringValue("E_STR_CARD_MASTER_NOT_ENOUGH_SCORE") , COLOR_TYPE.RED)
		else
			Message.sendPost('lucky_card_refresh', 'activity', '{}', doRefreshLuckyCardResponse)
		end
	end

	-- 洗牌结束
	local function shuffleOver()
		turnCardNum = turnCardNum + 1
		if turnCardNum >= CARD_MAX_COUNT then
			turnCardNum = 0
			tipsArr = {}
			unlockPanel()
			refreshBtn:setVisible(false)
			startBtn:setVisible(false)
			awardBtn:setVisible(true)
			turnBtn:setVisible(false)
			awardBtn:setTouchEnable(false)
			awardBtn:setPressState(WidgetStateDisabled)
			jfCost = tonumber(luckyCardCostConf[1].OpenScore)
			timeInfoTx2:setText(tostring(jfCost))
		end
	end

	-- 洗牌
	local function shuffle()
		turnCardNum = turnCardNum + 1
		if turnCardNum >= CARD_MAX_COUNT then
			turnCardNum = 0
			for k, v in pairs(cardArr) do
				local pos = v:getPosition()
				local washMove1 = CCMoveTo:create(0.25, ccp(20*k-130,0))
				local washMove2 = CCMoveTo:create(0.25, ccp(130 - 20*k,0))
				local washMove3 = CCMoveTo:create(0.25, pos)
				local arr = CCArray:create()
	            arr:addObject(washMove1)
	            arr:addObject(CCDelayTime:create(0.3))
	            arr:addObject(washMove2)
	            arr:addObject(washMove1)
	            arr:addObject(washMove2)
	            arr:addObject(washMove1)
	            arr:addObject(washMove2)
	            arr:addObject(washMove1)
	            arr:addObject(CCDelayTime:create(0.3))
	            arr:addObject(washMove3)
	            arr:addObject(CCCallFunc:create(shuffleOver))
				local seq = CCSequence:create(arr)
		        v:runAction(seq)
			end
		end
	end

	-- 洗牌
	local function turnAndshuffle()
		turnCardNum = 0
		for i=1, CARD_MAX_COUNT do
			local arr = CCArray:create()
	        arr:addObject(CCOrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0))
	        arr:addObject(CCCallFunc:create(function()
	      		cardArr[i]:setVisible(true)
				cardBgArr[i]:setVisible(false)
	        	local arr2 = CCArray:create()
	        	arr2:addObject(CCOrbitCamera:create(0.2, 1, 0, 270, 90, 0, 0))
	        	arr2:addObject(CCCallFunc:create(function ()
	        		shuffle()
	        	end))
	        	local seq2 = CCSequence:create(arr2)
	        	cardArr[i]:runAction(seq2)
	        end))
	        local seq = CCSequence:create(arr)
	        cardBgArr[i]:runAction(seq)
		end
	end

	-- 开始游戏的回调
	local function doStartLuckyCardResponse(jsonData)
		print(jsonData)
		local response = json.decode(jsonData)
		local code = tonumber(response.code)
		if code == 0 then
			luckyCardData.cards = response.data.cards
			lockPanle()
			turnCardNum = 0
			-- 翻转card，显示奖励
			for i=1, CARD_MAX_COUNT do
				local arr = CCArray:create()
		        arr:addObject(CCOrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0))
		        arr:addObject(CCCallFunc:create(function()
		        	setAward(i)
		        	cardArr[i]:setVisible(false)
					cardBgArr[i]:setVisible(true)
		        	local arr2 = CCArray:create()
		        	arr2:addObject(CCOrbitCamera:create(0.2, 1, 0, 270, 90, 0, 0))
		        	arr2:addObject(CCCallFunc:create(startAndTurnCallBack))
		        	local seq2 = CCSequence:create(arr2)
		        	cardBgArr[i]:runAction(seq2)
		        end))
		        local seq = CCSequence:create(arr)
		        cardArr[i]:runAction(seq)
			end
			updateJfAndButton()
		end
	end

	-- 点击开始
	local function onClickStartHandle()
		Message.sendPost('lucky_card_start', 'activity', '{}', doStartLuckyCardResponse)
	end

	-- 领取奖励回调
	local function doGetAwardResponse(jsonData)
		print(jsonData)
		local response = json.decode(jsonData)
		local code = tonumber(response.code)
		if code == 0 then
			lockPanle()
			turnCardNum = CARD_MAX_COUNT - #luckyCardData.open
			local lockCard = function()
				for i=1, CARD_MAX_COUNT do
					cardArr[i]:setTouchEnable(false)
					cardBgArr[i]:setTouchEnable(false)
				end
			end
			for k, v in pairs(luckyCardData.open) do
				for k2, v2 in pairs(v) do
					local arr = CCArray:create()
			        arr:addObject(CCOrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0))
			        arr:addObject(CCCallFunc:create(function()
			        	cardBgArr[tonumber(k2)]:setVisible(false)
			        	cardArr[tonumber(k2)]:setVisible(true)
			        	local arr2 = CCArray:create()
			        	arr2:addObject(CCOrbitCamera:create(0.2, 1, 0, 270, 90, 0, 0))
			        	arr2:addObject(CCCallFunc:create(function ()
			        		startAndTurnCallBack(lockCard)
			        	end))
			        	local seq2 = CCSequence:create(arr2)
			        	cardArr[tonumber(k2)]:runAction(seq2)
			        end))
			        local seq = CCSequence:create(arr)
			        cardBgArr[tonumber(k2)]:runAction(seq)
				end
			end
			local awards = response.data.awards
			luckyCardData = response.data.lucky_card
			tipsArr = {}
			UserData.parseAwardJson(json.encode(awards))
			GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
			updatePanel()
		end
	end

	-- 领取奖励
	local function onClickAwardCallBack()
		Message.sendPost('lucky_card_got', 'activity', '{}', doGetAwardResponse)
	end

	-- 点击领取奖励
	local function onClickAwardHandle()
		local awardsArr = {}
		for k, v in pairs(tipsArr) do
			table.insert(awardsArr, v)
		end
		if #awardsArr == getGlobalIntegerValue('LuckyCardMaxNum') then
			genShowAwardsPanel(awardsArr, getLocalStringValue('E_STR_CONFIRM_AWARD'), getLocalStringValue('E_STR_LUCKY_CARD_CONTINUE_TURN'), getLocalStringValue('E_STR_WHEEL_AWARD_REMIND'), true, onClickAwardCallBack)
		else
			genShowAwardsPanel(awardsArr, getLocalStringValue('E_STR_CONFIRM_AWARD'), getLocalStringValue('E_STR_LUCKY_CARD_CONTINUE_TURN'), getLocalStringValue('E_STR_WHEEL_AWARD_REMIND'), false, onClickAwardCallBack)
		end
	end

	-- 点击开始翻牌
	local function onClickTurnHandle()
		lockPanle()
		turnAndshuffle()
	end

	-- 翻一张牌
	local function doOpenCardResponse(jsonData)
		print(jsonData)
		local response = json.decode(jsonData)
		local code = tonumber(response.code)
		if code == 0 then
			lockPanle()
			turnCardNum = 0
			jf = tonumber(response.data.score)
			local card_index = tonumber(response.data.card_index) + 1
			local obj = {}
			obj[tostring(cardPos)] = card_index
			table.insert(luckyCardData.open, obj)
			updateJfAndButton()

			local arr = CCArray:create()
	        arr:addObject(CCOrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0))
	        arr:addObject(CCCallFunc:create(function()
	        	setAward(cardPos, card_index)
	        	cardBgArr[cardPos]:setVisible(true)
	        	cardArr[cardPos]:setVisible(false)
	        	local arr2 = CCArray:create()
	        	arr2:addObject(CCOrbitCamera:create(0.2, 1, 0, 270, 90, 0, 0))
	        	arr2:addObject(CCCallFunc:create(unlockPanel))
	        	local seq2 = CCSequence:create(arr2)
	        	cardBgArr[cardPos]:runAction(seq2)
	        end))
	        local seq = CCSequence:create(arr)
	        cardArr[cardPos]:runAction(seq)
		end
	end

	-- 倒计时结束回调
	local function overCountDown()
		CDTime:setVisible(false)
		timeOverTx:setVisible(true)
		activityOver()
	end

	local function init()
		luckyCardCostConf = GameData:getArrayData('avluckycard_cost.dat')
		maxRefreshScore = #luckyCardCostConf
		for k, v in pairs(luckyCardCostConf) do
			if v.OpenScore ~= nil and v.OpenScore ~= '' then
				maxOpenScore = maxOpenScore + 1
			else
				break
			end
		end
		root = panel:GetRawPanel()
		local luckyCardBgImg = tolua.cast(root:getChildByName('lucky_card_bg_img'),'UIImageView')
		local luckyCardImg = tolua.cast(luckyCardBgImg:getChildByName('lucky_card_img'),'UIImageView')
		local titleIco = tolua.cast(luckyCardImg:getChildByName('title_ico'),'UIImageView')
		closeBtn = tolua.cast(titleIco:getChildByName('close_btn'),'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(luckyCard, ELF_HIDE.SMART_HIDE)
		end)

		helpBtn = tolua.cast(titleIco:getChildByName('help_btn'),'UIButton')
		GameController.addButtonSound(helpBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		helpBtn:registerScriptTapHandler(function ()
			genLuckyCardHelpPanel()
		end)

		refreshBtn = tolua.cast(luckyCardImg:getChildByName('refresh_btn'),'UIButton')
		GameController.addButtonSound(refreshBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		refreshBtn:registerScriptTapHandler(onClickRefreshHandle)

		startBtn = tolua.cast(luckyCardImg:getChildByName('start_btn'),'UIButton')
		GameController.addButtonSound(startBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		startBtn:registerScriptTapHandler(onClickStartHandle)

		awardBtn = tolua.cast(luckyCardImg:getChildByName('award_btn'),'UIButton')
		GameController.addButtonSound(awardBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		awardBtn:registerScriptTapHandler(onClickAwardHandle)

		turnBtn = tolua.cast(luckyCardImg:getChildByName('turn_btn'),'UIButton')
		GameController.addButtonSound(turnBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		turnBtn:registerScriptTapHandler(onClickTurnHandle)

		rechargeBtn = tolua.cast(luckyCardImg:getChildByName('recharge_btn'),'UIButton')
		GameController.addButtonSound(rechargeBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		rechargeBtn:registerScriptTapHandler(genCashBoard)

		-- 看不见奖励的背面card
		local cardBg = tolua.cast(luckyCardImg:getChildByName('card_bg'),'UIImageView')
		for i = 1, CARD_MAX_COUNT do
			local cardIcoName = 'card_' .. i .. '_ico'
			local cardIco = tolua.cast(cardBg:getChildByName(cardIcoName),'UIImageView')
			cardIco:registerScriptTapHandler(function ()
				jfCost = #luckyCardData.open
				if jfCost < maxOpenScore then
					jfCost = tonumber(luckyCardCostConf[jfCost+1].OpenScore)
				else
					jfCost = tonumber(luckyCardCostConf[maxOpenScore].OpenScore)
				end
				if jfCost > jf then
					GameController.showPrompts(getLocalStringValue("E_STR_CARD_MASTER_NOT_ENOUGH_SCORE") , COLOR_TYPE.RED)
				else
					local openNum = #luckyCardData.open
					if openNum >= getGlobalIntegerValue('LuckyCardMaxNum',6) then
						GameController.showPrompts(getLocalStringValue("E_STR_TURN_CARD_NUM_ARRIVE_MAX") , COLOR_TYPE.RED)
					else
						local pJson = {
						    pos = i
						}
						cardPos = i
						Message.sendPost('lucky_card_open', 'activity', json.encode(pJson), doOpenCardResponse)
					end
				end
			end)
			table.insert(cardArr,cardIco)
		end

		-- 看得见奖励的正面card
		for i = 1, CARD_MAX_COUNT do
			local cardIcoName = 'card_bg_' .. i .. '_ico'
			local cardIco = tolua.cast(cardBg:getChildByName(cardIcoName),'UIImageView')
			cardIco:registerScriptTapHandler(function()
				UISvr:showTipsForAward(tipsArr[i])
			end)
			cardIco:setVisible(false)
			table.insert(cardBgArr,cardIco)
			local light = CUIEffect:create()
			light:Show("yellow_light", 0)
			light:setScale(0.8)
			light:setPosition( ccp(0, 0))
			light:setAnchorPoint(ccp(0.5, 0.5))
			cardIco:getContainerNode():addChild(light)
			light:setZOrder(100)
			light:setVisible(false)
			table.insert(lightArr, light)
		end

		-- 积分
		integralNumTx = tolua.cast(titleIco:getChildByName('integral_num1_tx'),'UILabel')
		-- 已选牌数
		selectedNumTx = tolua.cast(luckyCardImg:getChildByName('selected_num_tx'),'UILabel')
		-- 消耗积分的tx
		timeInfoTx2 = tolua.cast(luckyCardImg:getChildByName('integral_num_tx'),'UILabel')

		jf = tonumber(luckyCardData.score)
		updatePanel() -- 根据data更新下界面

		-- 判断活动是否过期
		timeOverTx = tolua.cast(luckyCardImg:getChildByName('time_over_tx'),'UILabel')
		timeOverTx:setColor(COLOR_TYPE.RED)
		local timeInfoTx1 = tolua.cast(luckyCardImg:getChildByName('time_info_tx_1'),'UILabel')
		CDTime = UICDLabel:create()
		CDTime:setFontSize(24)
		CDTime:setPosition(ccp(-70,-30))
		CDTime:setFontColor(COLOR_TYPE.WHITE)
		CDTime:registerTimeoutHandler(overCountDown)
		local actConf = GameData:getMapData('activities.dat')
		local actyStartTime
        local actyEndTime
        if actConf['luckycard'].StartTime ~= nil and actConf['luckycard'].StartTime ~= '' then
            actyStartTime = UserData:convertTime(1, actConf['luckycard'].StartTime)
            actyEndTime = UserData:convertTime(1, actConf['luckycard'].EndTime)
        else
            local serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
            actyStartTime = serverOpenTime + (tonumber(actConf['luckycard'].OpenDay) - 1)*86400
            actyEndTime = serverOpenTime + (tonumber(actConf['luckycard'].OpenDay) + tonumber(actConf['luckycard'].Duration) - 1)*86400
        end
        local activitiyOverTime = actyEndTime - UserData:getServerTime()
		if activitiyOverTime > 0 then
			timeInfoTx1:addChild(CDTime)
			CDTime:setTime(activitiyOverTime)
			timeOverTx:setVisible(false)
		else
			activityOver()
		end
	end

	luckyCard = SceneObjEx:createObj('panel/Lucky_card_panel.json', 'lucky-card-lua')
    panel = luckyCard:getPanelObj()
    panel:setAdaptInfo('lucky_card_bg_img', 'lucky_card_img')

    panel:registerInitHandler(init)

    panel:registerOnShowHandler(function ()
    end)

    panel:registerOnHideHandler(function ()
    end)
    
    CUIManager:GetInstance():ShowObject(luckyCard, ELF_SHOW.SMART)
end

local function doGetLuckyCardResponse(jsonData)
	print(jsonData)
	local response = json.decode(jsonData)
	local code = tonumber(response.code)
	if code == 0 then
		luckyCardData = response.data.lucky_card
		genLuckyCardPanel()
	end
end

function LuckyCard.enter()
	Message.sendPost('lucky_card_get', 'activity', '{}', doGetLuckyCardResponse)
end
