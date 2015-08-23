
Wheel = {}

function Wheel.isActive()
	return false
end

-- 命运之轮数据
local wheelData = {}

local arrowPosArr = readOnly{
	ccp(12, 32),
	ccp(26, 15),
	ccp(35, -14),
	ccp(12, -28),
	ccp(-14, -28),
	ccp(-37, -14),
	ccp(-28, 15),
	ccp(-14, 32)
}

local cardPosArr = readOnly{
	ccp(-342,168),
	ccp(-342,70),
	ccp(-342,-30),
	ccp(-342,-130),
	ccp(319,168),
	ccp(319,70),
	ccp(319,-30),
	ccp(319,-130)
}


local function genWheelPanel()
	-- function
	local beginTurnWheel

	-- UI
	local wheelImg
	local cashTx
	local awardBtn
	local turnBtn
	local resetBtn
	local arrowImg
	local turnCashIco
	local turnCashTx
	local resetTimeTx

	-- 常量
	local MAX_CARD_NUM = 8				-- 珠子数量
	local ARROW_ORIGIN = ccp(-1, 2)		-- 箭头原点位置

	local cardPanelArr = {} 	-- card panel数组
	local beadArr = {}			-- 珠子 img数组
	local turnBeadArr = {} 		-- 每轮转动的珠子的数组
	local activateBeadArr = {}  -- 已经获得的bead

	-- 配置文件
	local wheelConf
	local buyConf

	local freeTimes = 0     -- 免费次数
	local scheduleId = 0	-- scheduleScriptFunc id
	local millisecond = 0
	local speedByTime = nil	-- 箭头转动的速度
	local endRotation = 0	-- 最终转动的圈数
	local endRotate = 0		-- 最终转动的角度
	local beadPos = 0		-- 此次转到戳到的珠子位置
	local cardIndex = 0     -- 当前已经激活的奖励数
	local isPokeBead = true -- 这次转动是否能戳到珠子
	local resetTimes = 0	-- 重置次数
	local beadOriginPos
	local speed = nil
	-- 更新界面
	local function updatePanel()
		cashTx:setText(toWordsNumber(PlayerCoreData.getCashValue()))
		if tonumber(wheelData.got) == 0 then     -- 本轮奖励未领取
			if tonumber(wheelData.free) < tonumber(freeTimes) then
				turnCashIco:setVisible(false)
			else
				turnCashIco:setVisible(true)
				if tonumber(wheelData.cash) >= tonumber(wheelData.buy_max) then
					turnCashTx:setText(buyConf[tonumber(wheelData.buy_max)].CashTurnPointer)
				else
					turnCashTx:setText(buyConf[tonumber(wheelData.cash) + 1].CashTurnPointer)
				end
			end
			turnBtn:setVisible(true)
			if #activateBeadArr >= MAX_CARD_NUM then -- 如果所有珠子都戳完了
				turnBtn:setTouchEnable(false)
				turnBtn:setPressState(WidgetStateDisabled)
				turnCashIco:setVisible(false)
				awardBtn:setTouchEnable(true)
				awardBtn:setPressState(WidgetStateNormal)
			elseif #activateBeadArr == 0 then
				turnBtn:setTouchEnable(true)
				turnBtn:setPressState(WidgetStateNormal)
				awardBtn:setTouchEnable(false)
				awardBtn:setPressState(WidgetStateDisabled)
			else
				turnBtn:setTouchEnable(true)
				turnBtn:setPressState(WidgetStateNormal)
				awardBtn:setTouchEnable(true)
				awardBtn:setPressState(WidgetStateNormal)
			end
			resetBtn:setVisible(false)
		elseif tonumber(wheelData.got) == 1 then -- 本轮奖励已领取
			awardBtn:setTouchEnable(false)
			awardBtn:setPressState(WidgetStateDisabled)
			turnBtn:setVisible(false)
			resetBtn:setVisible(true)
			if tonumber(wheelData.reset) <  resetTimes then -- 如果今天还可以重置
				resetTimeTx:setText(tostring(resetTimes - tonumber(wheelData.reset)))
				turnCashIco:setVisible(true)
				turnCashTx:setText(buyConf[tonumber(wheelData.reset) + 1].CashWheel)
			else
				resetBtn:setTouchEnable(false)
				resetBtn:setPressState(WidgetStateDisabled)
				resetTimeTx:setText('0')
				turnCashIco:setVisible(false)
			end
		end
	end


	local function lockPanel()
		awardBtn:setTouchEnable(false)
		awardBtn:setPressState(WidgetStateDisabled)
		turnBtn:setTouchEnable(false)
		turnBtn:setPressState(WidgetStateDisabled)
	end

	local function unlockPanel()
		awardBtn:setTouchEnable(true)
		awardBtn:setPressState(WidgetStateNormal)
		turnBtn:setTouchEnable(true)
		turnBtn:setPressState(WidgetStateNormal)
	end

	-- 珠子飘到对应位置后
	local function beadMoveOver()
		beadArr[beadPos]:setVisible(false)
		beadArr[beadPos]:setOpacity(255)
		beadArr[beadPos]:setScale(1)
		beadArr[beadPos]:setPosition(beadOriginPos)
		beadArr[beadPos]:setWidgetZOrder(2)
		local ball = tolua.cast(cardPanelArr[cardIndex]:getChildByName('ball_ico'),'UIImageView')
		local cardBg = tolua.cast(cardPanelArr[cardIndex]:getChildByName('card_bg_ico'),'UIImageView')
		cardBg:setNormal()
		ball:setNormal()
		-- 继续转动戳下一个
		beginTurnWheel()
	end

	-- 珠子飘去对应的位置
	local function pokeOver()
		if isPokeBead then      -- 如果当前位置有珠子
			beadOriginPos =  beadArr[beadPos]:getPosition()
			beadArr[beadPos]:setWidgetZOrder(8)
			local scaleTo1 = CCScaleTo:create(0.1,1.2)
			local scaleTo2 = CCScaleTo:create(0.2,0.6)
			local scaleTo3 = CCScaleTo:create(0.5,1)
			local fadeOut = CCFadeOut:create(0.5)
			local spawn = CCSpawn:createWithTwoActions(scaleTo3, fadeOut);
			local moveTo1 = CCMoveTo:create(1.5,cardPosArr[cardIndex])
			local easeIn = CCEaseInOut:create(moveTo1, 4)
			local actionOver = CCCallFunc:create(beadMoveOver)
			local arr = CCArray:create()
			arr:addObject(scaleTo1)
			arr:addObject(easeIn)
			arr:addObject(scaleTo2)
			arr:addObject(spawn)
			arr:addObject(actionOver)
			local seq = CCSequence:create(arr)
			beadArr[beadPos]:runAction(seq)
		else 			  -- 当前位置已经没有珠子了
			updatePanel() -- 更新下界面
			isPokeBead = true
		end
	end

	-- 箭头转动结束
	local function turnOver()
		if scheduleId ~= 0 then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
			scheduleId = 0
		end
		arrowImg:stopAllActions()
		arrowImg:setRotation(arrowImg:getRotation()%360)
		local moveTo1 = CCMoveTo:create(0.3,arrowPosArr[beadPos])
		local moveTo2 = CCMoveTo:create(0.2,ARROW_ORIGIN)
		local easeIn = CCEaseExponentialIn:create(moveTo1)
		local actionMiddle = CCCallFunc:create(pokeOver)
		local arr = CCArray:create()
		arr:addObject(easeIn)
		arr:addObject(actionMiddle)
		arr:addObject(moveTo2)
		local seq = CCSequence:create(arr)
		arrowImg:runAction(seq)
	end

	-- 转过过程中改变速度
	local function turnWheel()
		local rotation = arrowImg:getRotation()
		rotation = rotation/360
		millisecond = millisecond + 0.1
		
		if rotation < 3 then
			speedByTime = millisecond*millisecond*0.3
		elseif rotation >= 3 and rotation < 8 then
			speedByTime = 2.5
		elseif rotation >= 8 and rotation < endRotate/360 then
			speedByTime = endRotation - rotation
		else
			speedByTime =nil
		end
		if speedByTime ~= nil and speed ~= nil then
			speed:setSpeed(speedByTime)
		end
		
		if rotation > endRotate/360 then
			turnOver()
		end
	end

	-- 开始转动
	local function turnWheelStepOne()
		lockPanel()
		endRotate = 3600 + 45 * beadPos - 22.5
		local rotate = CCRotateBy:create(8, endRotate)
		endRotation = endRotate/360 + 0.1
		local actionOver = CCCallFunc:create(turnOver)
  		local arr = CCArray:create()
		arr:addObject(rotate)
		arr:addObject(actionOver)
		local seq = CCSequence:create(arr)
		speed = CCSpeed:create(seq, 1)
		speed:setTag(100)
		arrowImg:runAction(speed)
		millisecond = 1
		scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(turnWheel,0.1,false)
		turnWheel()
	end


	-- 找一颗珠子然后开始转动
	beginTurnWheel = function()
		local length = #turnBeadArr
		if length > 0 then
			beadPos = table.remove(turnBeadArr, math.random(length))
			if #turnBeadArr == 0 then
				GameController.setStringForKey('wheelarrowpos',tostring(beadPos))
			end
			table.insert(activateBeadArr, beadPos)
			cardIndex = cardIndex + 1
			turnWheelStepOne()
		else
			if #activateBeadArr >= MAX_CARD_NUM then -- 如果所有珠子都戳完了
				awardBtn:setTouchEnable(true)
				awardBtn:setPressState(WidgetStateNormal)
				turnBtn:setTouchEnable(false)
				turnBtn:setPressState(WidgetStateDisabled)
				turnCashIco:setVisible(false)
				GameController.setStringForKey('wheelarrowpos',tostring(beadPos))
			else
				isPokeBead = false
				beadPos = activateBeadArr[math.random(#activateBeadArr)]
				GameController.setStringForKey('wheelarrowpos',tostring(beadPos))
				turnWheelStepOne()
			end		
		end
	end

	-- 点击转动按钮的回调
	local function doTurnResponse(jsonData)
		local response = json.decode(jsonData)
		local code = response.code
		if tonumber(code) == 0 then
			wheelData.cash = response.data.times
			wheelData.free = response.data.free
			PlayerCoreData.addCashDelta(tonumber(response.data.cash))
			cashTx:setText(toWordsNumber(PlayerCoreData.getCashValue()))
			local pos = 0
			turnBeadArr = {}
			local existBead = {}
			for k, v in pairs(response.data.star) do
				pos = pos + 1
				if tonumber(wheelData.star[k]) ~= tonumber(v) then
					table.insert(turnBeadArr, pos)
				end
				if tonumber(v) == 1 then
					table.insert(existBead, pos)
				end
			end
			beadPos = existBead[math.random(#existBead)]
			GameController.setStringForKey('wheelarrowpos',tostring(beadPos))
			wheelData.star = response.data.star
			beginTurnWheel()
		end
	end

	-- 点击开始转动
	local function clickTurnHandel()
		local needCash = 0
		if tonumber(wheelData.free) >= tonumber(freeTimes) then
			if tonumber(wheelData.cash) >= tonumber(wheelData.buy_max) then
				needCash = tonumber(buyConf[tonumber(wheelData.buy_max)].CashTurnPointer)
			else
				needCash = tonumber(buyConf[tonumber(wheelData.cash) + 1].CashTurnPointer)
			end
		end
		
		if needCash > PlayerCoreData.getCashValue() then
			GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
		else
			Message.sendPost('start_wheel', 'activity', '{}', doTurnResponse)
		end
	end

	-- 重置界面
	local function resetPanel()
		for i = 1, MAX_CARD_NUM do
			local ball = tolua.cast(cardPanelArr[i]:getChildByName('ball_ico'),'UIImageView')
			local cardBg = tolua.cast(cardPanelArr[i]:getChildByName('card_bg_ico'),'UIImageView')
			cardBg:setGray()
			ball:setGray()
			arrowImg:setRotation(0)
			beadArr[i]:setScale(1)
			beadArr[i]:setOpacity(255)
			beadArr[i]:setVisible(true)
		end
		activateBeadArr = {}
		cardIndex = 0
		updatePanel()
		GameController.showPrompts(getLocalStringValue('E_STR_RESET_SUCCEESS'), COLOR_TYPE.GREEN)
	end

	-- 重置回调
	local function doResetResponse(jsonData)
		local response = json.decode(jsonData)
		local code = response.code
		if tonumber(code) == 0 then
			PlayerCoreData.addCashDelta(tonumber(response.data.cash))
			wheelData.cash = response.data.wheel.cash
			wheelData.day = response.data.wheel.day
			wheelData.first = response.data.wheel.first
			wheelData.free = response.data.wheel.free
			wheelData.got = response.data.wheel.got
			wheelData.reset = response.data.wheel.reset
			wheelData.star = response.data.wheel.star
			resetPanel()
		end
	end

	-- 点击重置按钮
	local function clickResetHandel()
		if tonumber(buyConf[tonumber(wheelData.reset) + 1].CashWheel) > PlayerCoreData.getCashValue() then
			GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
		else
			Message.sendPost('reset_wheel', 'activity', '{}', doResetResponse)
		end
	end

	-- 领取奖励回调
	local function doGetAwardResponse(jsonData)
		local response = json.decode(jsonData)
		local code = response.code
		if tonumber(code) == 0 then
			local awards = response.data.awards
			local awardStr = json.encode(awards)
			UserData.parseAwardJson(awardStr)
			cashTx:setText(toWordsNumber(PlayerCoreData.getCashValue()))
			GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
			awardBtn:setTouchEnable(false)
			awardBtn:setPressState(WidgetStateDisabled)
			turnBtn:setVisible(false)
			resetBtn:setVisible(true)
			if tonumber(wheelData.reset) <  resetTimes then -- 如果今天还可以重置
				resetTimeTx:setText(tostring(resetTimes - tonumber(wheelData.reset)))
				turnCashIco:setVisible(true)
				turnCashTx:setText(buyConf[tonumber(wheelData.reset) + 1].CashWheel)
			else
				resetTimeTx:setText('0')
				resetBtn:setTouchEnable(false)
				resetBtn:setPressState(WidgetStateDisabled)
				turnCashIco:setVisible(false)
			end
		end
	end

	-- 点击领奖
	local function getAwardHandel()
		local awards = {}
		local onlyConfirm = false
		if #activateBeadArr >= MAX_CARD_NUM then -- 如果所有珠子都戳完了
			local extraAward = wheelConf[MAX_CARD_NUM].Award2
			table.insert(awards, extraAward)
			onlyConfirm = true
		end
		local func = function ()
			Message.sendPost('get_wheel_reward', 'activity', '{}', doGetAwardResponse)
		end
		for i = 1, cardIndex do
			local awardStr = wheelConf[cardIndex - i + 1].Award1
			table.insert(awards, awardStr)
		end
		genShowAwardsPanel(awards, getLocalStringValue('E_STR_CONFIRM_AWARD') , getLocalStringValue('E_STR_CONTINUE_TURN'), getLocalStringValue('E_STR_WHEEL_AWARD_REMIND') , onlyConfirm, func)
	end

	-- 创建奖励panel
	local function createAwardPanel()
		local grayNum = 1
		cardIndex = 0
		for i = 1, MAX_CARD_NUM do
			local cardPanel = createWidgetByName('panel/destiny_wheel_card_panel.json')
			local numTx = tolua.cast(cardPanel:getChildByName('number_tx'),'UILabel')
			local infoTx = tolua.cast(cardPanel:getChildByName('info_tx'),'UILabel')
			local ball = tolua.cast(cardPanel:getChildByName('ball_ico'),'UIImageView')
			local cardBg = tolua.cast(cardPanel:getChildByName('card_bg_ico'),'UIImageView')
			local awardNum = 'X' .. i
			numTx:setText(awardNum)
			local award = UserData:getAward(wheelConf[i].Award1)
			local awardInfo = award.name .. 'X' .. toWordsNumber(award.count)
			infoTx:setPreferredSize(200,1)
			infoTx:setText(awardInfo)
			infoTx:setColor(award.color)
			if i < 5 then
				cardPanel:setPosition(ccp(40,500 - 100*i))
			else
				cardPanel:setPosition(ccp(670,900 - 100*i))
			end
			wheelImg:addChild(cardPanel)
			table.insert(cardPanelArr, cardPanel)
			if tonumber(wheelData.star[i]) == 1 then
				grayNum = grayNum + 1
				cardIndex = cardIndex + 1
				beadArr[i]:setVisible(false)
				table.insert(activateBeadArr, i)
			end
		end
		for i = grayNum, MAX_CARD_NUM do
			local ball = tolua.cast(cardPanelArr[i]:getChildByName('ball_ico'),'UIImageView')
			local cardBg = tolua.cast(cardPanelArr[i]:getChildByName('card_bg_ico'),'UIImageView')
			cardBg:setGray()
			ball:setGray()
		end
	end

	local wheel = SceneObjEx:createObj('panel/destiny_wheel_panel.json', 'destiny-wheel-lua')
    local panel = wheel:getPanelObj()
    panel:setAdaptInfo('wheel_bg_img', 'wheel_img')

    -- init
    panel:registerInitHandler(function ()
    	wheelConf = GameData:getArrayData('luckywheel.dat')
		buyConf = GameData:getArrayData('buy.dat')
		freeTimes = GameData:getGlobalValue('TurnWheelForFreeTimes')

		local root = panel:GetRawPanel()
		local wheelBgImg = tolua.cast(root:getChildByName('wheel_bg_img'),'UIImageView')
		wheelImg = tolua.cast(wheelBgImg:getChildByName('wheel_img'),'UIImageView')
		local titleIco = tolua.cast(wheelImg:getChildByName('title_ico'),'UIImageView')
		local closeBtn = tolua.cast(titleIco:getChildByName('close_btn'),'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(wheel, ELF_HIDE.SMART_HIDE)
		end)
		cashTx = tolua.cast(titleIco:getChildByName('cash_num_tx'),'UILabel')
		cashTx:setText(toWordsNumber(PlayerCoreData.getCashValue()))

		local topInfo = tolua.cast(wheelImg:getChildByName('info_tx'),'UILabel')
		local award = UserData:getAward(wheelConf[MAX_CARD_NUM].Award2)
		local str = award.name .. 'X' .. award.count
		topInfo:setText(string.format(getLocalStringValue('E_STR_DESTINY_WHEEL_INFO'), str))

		-- 转动转轮所需的元宝
		turnCashIco = tolua.cast(wheelImg:getChildByName('turn_cash_ico'),'UIImageView')
		turnCashTx = tolua.cast(turnCashIco:getChildByName('cash_num_tx'),'UILabel')

		-- 领奖按钮
		awardBtn = tolua.cast(wheelImg:getChildByName('get_award_btn'),'UITextButton')
		GameController.addButtonSound(awardBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		awardBtn:registerScriptTapHandler(getAwardHandel)

		-- 开始转盘按钮
		turnBtn = tolua.cast(wheelImg:getChildByName('turn_btn'),'UITextButton')
		GameController.addButtonSound(turnBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		turnBtn:registerScriptTapHandler(clickTurnHandel)

		-- 重置按钮
		resetBtn = tolua.cast(wheelImg:getChildByName('reset_btn'),'UITextButton')
		GameController.addButtonSound(resetBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		resetBtn:registerScriptTapHandler(clickResetHandel)
		local resetTimeImg = tolua.cast(resetBtn:getChildByName('reset_time_img'),'UIImageView')
		resetTimeTx = tolua.cast(resetTimeImg:getChildByName('reset_time_tx'),'UILabel')

		-- 指针
		local discImg = tolua.cast(wheelBgImg:getChildByName('disc_img'),'UIImageView')
		arrowImg = tolua.cast(discImg:getChildByName('arrow_ico'),'UIImageView')

		-- 打开界面的时候这一轮是否已经开始
		local isStart = false
		for v, k in pairs(wheelData.star) do
			if tonumber(k) == 1 then
				isStart = true
				break
			end
		end

		if isStart then
			local wheelarrowpos = GameController.getStringForKey('wheelarrowpos')
			if wheelarrowpos ~= '' then
				beadPos = tonumber(wheelarrowpos)
				arrowImg:setRotation(45 * beadPos - 22.5)
			end
		end

		-- 珠子
		for i=1, MAX_CARD_NUM do
			local bead = tolua.cast(discImg:getChildByName('ball_' .. i .. '_ico'),'UIImageView')
			table.insert(beadArr, bead)
		end

		-- 数一下reset次数
		resetTimes = 1
		repeat
			if buyConf[resetTimes] ~= nil and buyConf[resetTimes].CashWheel ~= nil and buyConf[resetTimes].CashWheel ~= '' then
				resetTimes = resetTimes + 1
			else
				break
			end
		until true
		--创建8个奖励panel
		createAwardPanel()
		updatePanel()
    end)
	
	-- onShow
    panel:registerOnShowHandler(function ()
    end)

    -- onHide
    panel:registerOnHideHandler(function ()
    end)

    panel:registerOnDestroyHandler(function ()
    	if scheduleId ~= 0 then
    		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
    	end
    end)
    
    CUIManager:GetInstance():ShowObject(wheel, ELF_SHOW.SMART)
end

local function doGetWheelResponse(jsonData)
	local response = json.decode(jsonData)
	local code = response.code
	if tonumber(code) == 0 then
		wheelData.cash = response.data.wheel.cash
		wheelData.day = response.data.wheel.day
		wheelData.first = response.data.wheel.first
		wheelData.free = response.data.wheel.free
		wheelData.got = response.data.wheel.got
		wheelData.reset = response.data.wheel.reset
		wheelData.star = response.data.wheel.star
		wheelData.buy_max = response.data.buy_max
		genWheelPanel()
	end
end

function Wheel.enter()
	Message.sendPost('get_wheel', 'activity', '{}', doGetWheelResponse)
end

