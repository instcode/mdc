LuckRunner ={}

local prayplbg 			
local prayleftnum_tx 			
local prayneedlghonor_tx 		
local praycurhavelghonor_tx	
local praymayaward 			
local prayArrow				
local praycloseBtn			
local prayplBtn				
local scheduleId 				
local millisecond 			
local speedByTime 			
local endRotation 			
local endRotate 				
local beadPos 				
local beadOriginPos			
local PRAY_AWARD_COUNT		
local awardStr                
local allawards				
local praytimes				
local times					
local speed   
local turnBtn 
local LuckRunnerData = {}
local RefreshData = {}
local TurnData = {}
local exchangeBtns = {}
local getAwardBtns = {}
local panPl
local cashTx
local jifen
local turncashTx
local turnjifenTx
local turn
local refresh
local turncolorTab = {}
local gotTab ={}
local refreshBtn
local fiftyBtn
local tenBtn
local getIntegralBtn
local dailyAwardBtn
local MainCloseBtn
local MainHelpBtn
local awardsTab = {}

local MatExchangeObj
-- left side
local nameTx
local itemIco
local hasTx
-- right side
local numEditBox
local leftBtn
local rightBtn
local confirmBtn
----------------------------------
--DATA
-----------------------------------
local shopId
local hasNum
local cardId
local awardsPanel
local awardsScene

local Limit = readOnly{
	MAX_COUNT = 99
}

local itemTab = GameData:getArrayData('avluckycircle_item.dat')
local turnTab = GameData:getArrayData('avluckycircle_cost.dat')
local scoreTab = GameData:getArrayData('avluckycircle_score.dat')
local dayTab = GameData:getArrayData('avluckycircle_award.dat')
local colorTab = GameData:getArrayData('avluckycircle.dat')
local conf = GameData:getArrayData('activities.dat')

function LuckRunner.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'lucky_circle' then
			conf = v
		end
	end)

	if conf == nil then
		return true
	end

	if tonumber(conf.Normalization) == 0 then -- 非常态活动

		local actyStartTime
        local actyEndTime
        if conf.StartTime ~= nil and conf.StartTime ~= '' then -- 优先判断StartTime字段
            actyStartTime = UserData:convertTime(1, conf.StartTime)
            actyEndTime   = UserData:convertTime(1, conf.EndTime) + (tonumber(conf.DelayDays))*86400 -- 加上奖励的领取延时1天 这两天充值元宝不计
        else
            local serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
            actyStartTime = serverOpenTime + (tonumber(conf.OpenDay) - 1)*86400
            actyEndTime = serverOpenTime + (tonumber(conf.OpenDay) + tonumber(conf.Duration) - 1)*86400
        end
        local nowTime = UserData:getServerTime()
        if nowTime < actyStartTime or nowTime > actyEndTime then
            return true
        end

    else    -- 常态活动
    	 if conf.StartTime ~= nil and conf.StartTime ~= '' then
            local time = UserData:getServerTime()
            local startTime = UserData:convertTime(1,conf.StartTime)
            local endTime = UserData:convertTime(1,conf.EndTime)

            if time < startTime or time > endTime then
                return true
            end
        end
    end

	return false
end

local function getItemConfDataByKey( key )
	for k , v in pairs (itemTab)   do                          
		if(v['Id'] == key) then 
			return v
		end
	end
	return nil
end

local function getTurnConfDataByKey( key )
	for k , v in pairs (turnTab)   do                          
		if(v['Id'] == key) then 
			return v
		end
	end
	return nil
end

local function getScoreConfDataByKey( key )
	for k , v in pairs (scoreTab)   do                          
		if(v['Id'] == key) then 
			return v
		end
	end
	return nil
end

local function getDayConfDataByKey( key )
	for k , v in pairs (dayTab)   do                          
		if(v['Id'] == key) then 
			return v
		end
	end
	return nil
end

local function getColorConfDataByKey( key )
	for k , v in pairs (colorTab)   do                          
		if(v['Id'] == key) then 
			return v
		end
	end
	return nil
end

local function getConf()
	local data = GameData:getArrayData('activities.dat')
	table.foreach(data , function (_ , v)
		if v['Key'] == 'lucky_circle' then
			conf = v
		end
	end)
end

local function SetJifen(val)
	jifen = jifen + val
end

local function GetJifen()
	jifen = LuckRunnerData.lucky_circle.score
	return jifen
end

local function SetRefresh(val)	
	refresh = refresh + val
	if refresh >= #turnTab then
		refresh = #turnTab
	end
end

local function GetRefresh()
	refresh = LuckRunnerData.lucky_circle.refresh + 1
	if refresh >= #turnTab then
		refresh = #turnTab
	end
	return refresh
end

local function SetTurn(val)
	turn = turn + val
	if turn >= #turnTab then
		turn = #turnTab
	end
end

local function ZeroTurn()
	turn = 1
end

local function GetTurn()
	turn = LuckRunnerData.lucky_circle.turn + 1
	if turn >= #turnTab then
		turn = #turnTab
	end
	return turn
end

local function updateTitle()
	cashTx:setText(toWordsNumber(PlayerCoreData:getCashValue()))
	jifenTx:setText(jifen)
end

local function doExchangeResponse(jsonData)
	cclog(jsonData)
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		UserData.parseAwardJson(json.encode(response.data.awards))
		SetJifen(response.data.score)
		updateTitle()
		GameController.showPrompts(getLocalStringValue('E_STR_EXCHANGE_SUCCEED'), COLOR_TYPE.GREEN)
	end
end

local function updateConfirmBtn()
	local num = numEditBox:getTextFromInt()
	if num < 1 then
		confirmBtn:disable()
	else
		confirmBtn:active()
	end
end

local function updateBtnStatus()
	local num = numEditBox:getTextFromInt()
	if num <= 1 then
		leftBtn:disable()
		if hasNum <= 1 then 
			rightBtn:disable() 
		end
	else
		leftBtn:active()
	end
	if num >= hasNum or num >= Limit.MAX_COUNT then
		rightBtn:disable()
	else
		rightBtn:active()
	end
end

local function updateNumbers()
	local ct = numEditBox:getTextFromInt()
	if ct < 0 then 
		return 
	end
	updateConfirmBtn()
end

local function onLongPressLeftBtn()
	CNumEditorAct:getInst():numDec(leftBtn,numEditBox,rightBtn,1)
	CNumEditorAct:getInst():registerScriptNumDecHandler( updateNumbers )
end

local function onLongPressRightBtn()
	local num = 0
	num = hasNum < Limit.MAX_COUNT and hasNum or Limit.MAX_COUNT
	CNumEditorAct:getInst():numAdd(leftBtn,numEditBox,rightBtn,num)
	CNumEditorAct:getInst():registerScriptNumAddHandler( updateNumbers )
end

local function onLongPressBtnCancelled()
	CNumEditorAct:getInst():stop()
end

local function onClickLeftBtn()
	CNumEditorAct:getInst():numDecOnce(leftBtn, numEditBox, rightBtn, 1)
	updateNumbers()
end

local function onClickRightBtn()
	local num = 0
	num = hasNum < Limit.MAX_COUNT and hasNum or Limit.MAX_COUNT
	CNumEditorAct:getInst():numAddOnce(leftBtn, numEditBox, rightBtn, num)
	updateNumbers()
end

local function onClickBuyBtn()
	local ct = numEditBox:getTextFromInt()
	print('ct======================' .. ct)
	print('shopId======================' .. shopId)
	GameController.showMessageBox(getLocalStringValue('E_STR_LUCK_RUNNER_INFO'), MESSAGE_BOX_TYPE.OK_CANCEL,function ()
		local args = { id = cardId,
		num = ct,}
			Message.sendPost('lucky_circle_exchange', 'activity', json.encode(args), doExchangeResponse)
	end)

	CUIManager:GetInstance():HideObject(MatExchangeObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
end

local function editBoxEventHandler( eventType )
	--if eventType == 'ended' then
		local num = numEditBox:getTextFromInt()
		if num <= 0 then
			num = 0
		else
			if num > Limit.MAX_COUNT then
				num = Limit.MAX_COUNT
			end
			if num > hasNum then
				num = hasNum
			end
		end
		numEditBox:setTextFromInt(num)
		updateNumbers()
		updateBtnStatus()
	--end
end

local function SetExchangePanel()
	numEditBox:setTextFromInt(1)
	nameTx:setText(PlayerCoreData.getMaterialName(shopId))
	nameTx:setColor(PlayerCoreData.getMaterialColor(shopId))
	itemIco:setTexture(PlayerCoreData.getMaterialIco(shopId))
	hasNum = PlayerCoreData.getMaterialCount(shopId)
	hasTx:setText(string.format(getLocalString('E_STR_BS_CONFIRM_HAS_NUM_STR') , toWordsNumber(hasNum)))
end

local function onOpenExchangePanel()
	MatExchangeObj = SceneObjEx:createObj('panel/confirm_exchange_panel.json', 'exchange-buy-lua')
	local panel = MatExchangeObj:getPanelObj()
	panel:setAdaptInfo('zhegai_bg_img', 'buy_bg_img')
    panel:registerInitHandler(function()
        local root = panel:GetRawPanel()
        local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
        closeBtn:registerScriptTapHandler(function ()
        	CUIManager:GetInstance():HideObject(MatExchangeObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
        end)
        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
        local background = tolua.cast(root:getChildByName('zhegai_bg_img'), 'UIImageView')
        background:registerScriptTapHandler(function ()
        	CUIManager:GetInstance():HideObject(MatExchangeObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
        end)

        --Init left side.
        local contentImg = root:getChildByName('buy_img')
        nameTx = tolua.cast(contentImg:getChildByName('name_tx') , 'UILabel')
        nameTx:setPreferredSize(320,1)
        local nameBgImg = tolua.cast(contentImg:getChildByName('name_bg_ico') , 'UIImageView')
        itemIco = tolua.cast(contentImg:getChildByName('material_ico') , 'UIImageView')
        hasTx = tolua.cast(contentImg:getChildByName('own_tx') , 'UILabel')
        --Init right side.
        local editBoxBg = tolua.cast(contentImg:getChildByName('number_bg_ico') , 'UIImageView')
        numEditBox = tolua.cast(UISvr:replaceUIImageViewByCCEditBox(editBoxBg) , 'CCEditBox')
		numEditBox:setHAlignment(kCCTextAlignmentCenter)
		numEditBox:setInputMode(kEditBoxInputModeDecimal)
		numEditBox:setFontSize(42)
		numEditBox:registerScriptEditBoxHandler( editBoxEventHandler )
		leftBtn = tolua.cast(contentImg:getChildByName('left_page_btn') , 'UITextButton')
		rightBtn = tolua.cast(contentImg:getChildByName('right_page_btn') , 'UITextButton')
		confirmBtn = tolua.cast(contentImg:getChildByName('buy_btn') , 'UITextButton')

		leftBtn:registerScriptTapHandler( onClickLeftBtn )
		leftBtn:registerScriptLongPressHandler( onLongPressLeftBtn )
		leftBtn:registerScriptLongPressEndHandler( onLongPressBtnCancelled )
		rightBtn:registerScriptTapHandler( onClickRightBtn )
		rightBtn:registerScriptLongPressHandler( onLongPressRightBtn )
		rightBtn:registerScriptLongPressEndHandler( onLongPressBtnCancelled )
		confirmBtn:registerScriptTapHandler( onClickBuyBtn )
		GameController.addButtonSound(leftBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		GameController.addButtonSound(rightBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		GameController.addButtonSound(confirmBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		SetExchangePanel()
    end)
    CUIManager:GetInstance():ShowObject(MatExchangeObj, ELF_SHOW.ZOOM_IN)
end

local function updateDayAward(i)
	if gotTab[i] == 1 then
		getAwardBtns[i]:disable()
		getAwardBtns[i]:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
	else
		getAwardBtns[i]:active()
	end
end

local function doDayResponse(jsonData, i)
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		UserData.parseAwardJson(json.encode(response.data.awards))
		gotTab[i] = 1
		updateDayAward(i)
		GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
	end
end

local function showAward()
	local key = LuckRunnerData.lucky_circle.items[TurnData.index]
	local Award = UserData:getAward(itemTab[tonumber(key)].Award1)
    local awardname = Award.name .. ' X' .. Award.count
    GameController.showPrompts(awardname , COLOR_TYPE.RED)
end

local function getPos(i)
	local x = 16 + 97 * ((i-1)%5)
	local y = 50 - ((i-1) - (i-1)%5)/5*95
	return ccp(x,y)
end

local function createCell(cardSv)
	for i,v in ipairs(awardsTab) do
		local awardStr = v[1]..'.'..v[2]..':'..v[3]
		local award = UserData:getAward(awardStr)
		local view = createWidgetByName('panel/luck_runner_award_cell.json')
		local awardImg = tolua.cast(view:getChildByName('award_img') , 'UIImageView')
		local numTx = tolua.cast(view:getChildByName('number_tx') , 'UILabel')
		awardImg:registerScriptTapHandler(function()
	    	UISvr:showTipsForAward(awardStr)
	    end)
		awardImg:setTexture(award.icon)
		numTx:setText(award.count)
		cardSv:addChildToBottom(view)
		view:setPosition(getPos(i))
	end
	cardSv:scrollToBottom()
end

local function initAwardPanel()
	root = awardsPanel:GetRawPanel()
    local awardImg = tolua.cast(root:getChildByName('award_img') , 'UIImageView')
    local cardImg = tolua.cast(root:getChildByName('card_img') , 'UIImageView')
    local cardSv = tolua.cast(root:getChildByName('award_sv') , 'UIScrollView')
    awardImg:registerScriptTapHandler(function()
    	CUIManager:GetInstance():HideObject(awardsScene, ELF_HIDE.SMART_HIDE)
    end)
    cardImg:registerScriptTapHandler(function()
    	CUIManager:GetInstance():HideObject(awardsScene, ELF_HIDE.SMART_HIDE)
    end)
	cardSv:setClippingEnable(true)
	createCell(cardSv)
end

local function showAward1()
	awardsScene = SceneObjEx:createObj('panel/luck_runner_award_panel.json','luck-runner-award-in-lua')
	awardsPanel = awardsScene:getPanelObj()
	awardsPanel:setAdaptInfo('award_img','card_img')
	awardsPanel:registerInitHandler(initAwardPanel)
	UiMan.show(awardsScene)
end

local function onClickExchange(i, id, count)
	if tonumber(PlayerCoreData.getMaterialCount(id)) >= tonumber(count) then
		shopId = id
		cardId = i
		onOpenExchangePanel()
	else
		 GameController.showPrompts(getLocalStringValue('E_STR_BAG_ITEM_NOT_ENOUGH'), COLOR_TYPE.RED)
	end
end

local function onClickGetAward(i ,curNum, needNum)
	if tonumber(curNum) >= tonumber(needNum) then
		local args = { id = i }
			Message.sendPost('lucky_circle_award', 'activity', json.encode(args), function (jsonData)
				doDayResponse(jsonData, i)
			end)
	else
		 GameController.showPrompts(getLocalStringValue('E_STR_ARENA_CONDITION_NOT_REACH'), COLOR_TYPE.RED)
	end
end

local function ShowExchange()
	exchange = SceneObjEx:createObj('panel/luck_runner_exchange_panel.json', 'luck-runner-exchange-panel-lua')
    local exchangeObj = exchange:getPanelObj()        --# This is a BasePanelEx object
    exchangeObj:setAdaptInfo('luck_exchange_bg_img', 'luck_exchange_img')

    exchangeObj:registerInitHandler(function()
        local root = exchangeObj:GetRawPanel()
        local exchangeBgImg = tolua.cast(root:getChildByName('luck_exchange_bg_img'), 'UIImageView')
        local exchangeImg = tolua.cast(exchangeBgImg:getChildByName('luck_exchange_img'), 'UIImageView')
        local titleBgImg = tolua.cast(exchangeImg:getChildByName('title_ico'), 'UIImageView')

		local closeBtn = tolua.cast(titleBgImg:getChildByName('close_btn'), 'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(exchange, ELF_HIDE.SMART_HIDE)
		end)		
		for i = 1, 6 do
			local frame = tolua.cast(exchangeImg:getChildByName('card_' .. i .. '_ico'), 'UIImageView')
			local awardBg = tolua.cast(frame:getChildByName('award_bg_ico'), 'UIImageView')
			local photo = tolua.cast(awardBg:getChildByName('photo_ico'), 'UIImageView')
			local Award = UserData:getAward(scoreTab[i].Award1)
			local awardIco = tolua.cast(photo:getChildByName('award_ico'), 'UIImageView')
			awardIco:setTexture(Award.icon)
			local awardNameTx = tolua.cast(photo:getChildByName('name_tx'), 'UILabel')
			awardNameTx:setPreferredSize(180,20)
			awardNameTx:setText(Award.name)
			local awardNumTx = tolua.cast(photo:getChildByName('number_tx'), 'UILabel')
			awardNumTx:setText(Award.count)
			local awardScoreTx = tolua.cast(frame:getChildByName('score_tx'), 'UILabel')
			awardScoreTx:setText(scoreTab[i].Score)
			photo:registerScriptTapHandler(function ()
				local awardStr = scoreTab[i].Award1
				UISvr:showTipsForAward(awardStr)
			end)
			local exchangeBtn = tolua.cast(frame:getChildByName('exchang_tbtn'), 'UITextButton')
			table.insert(exchangeBtns,i)
			exchangeBtns[i] = exchangeBtn
			exchangeBtn:registerScriptTapHandler(function()
				onClickExchange(i, Award.id, Award.count)
			end)
		end
    end)
        
	exchangeObj:registerOnShowHandler(function()
        end)
    exchangeObj:registerOnHideHandler(function()
            cclog('here on-hide for pawn-shop')
        end)
    CUIManager:GetInstance():ShowObject(exchange, ELF_SHOW.SMART)
end

local function ShowDayAward()
	dayAward = SceneObjEx:createObj('panel/luck_runner_dayaward.json', 'luck-runner-day-award-panel-lua')
    local dayAwardObj = dayAward:getPanelObj()        --# This is a BasePanelEx object
    dayAwardObj:setAdaptInfo('tips_bg_img', 'tips_img')

    dayAwardObj:registerInitHandler(function()
        local root = dayAwardObj:GetRawPanel()
        local dayAwardBgImg = tolua.cast(root:getChildByName('tips_bg_img'), 'UIImageView')
        local dayAwardImg = tolua.cast(dayAwardBgImg:getChildByName('tips_img'), 'UIImageView')
        local closeBtn = tolua.cast(dayAwardImg:getChildByName('close_btn'), 'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(dayAward, ELF_HIDE.SMART_HIDE)
		end)	
		local infoTx = tolua.cast(root:getChildByName('info_tx'),'UILabel')
		infoTx:setPreferredSize(620,1)
		for i = 1, 4 do
			local frame = tolua.cast(dayAwardImg:getChildByName('card_' .. i .. '_img'), 'UIImageView')
			local photo = tolua.cast(frame:getChildByName('photo_ico'), 'UIImageView')
			local Award = UserData:getAward(dayTab[i].Award1)
			local awardIco = tolua.cast(photo:getChildByName('award_ico'), 'UIImageView')
			awardIco:setTexture(Award.icon)
			local awardNameTx = tolua.cast(photo:getChildByName('name_tx'), 'UILabel')
			awardNameTx:setPreferredSize(120,1)
			awardNameTx:setText(Award.name)
			local awardNumTx = tolua.cast(photo:getChildByName('number_tx'), 'UILabel')
			awardNumTx:setText(Award.count)
			local colorNumTx = tolua.cast(frame:getChildByName('color_number_tx'), 'UILabel')
			local str 
			if tonumber(turncolorTab[i]) >=  tonumber(dayTab[i].Count) then 
				str = dayTab[i].Count .. '/' .. dayTab[i].Count
			else
			 	str = turncolorTab[i] .. '/' .. dayTab[i].Count
			end
			colorNumTx:setText(str)
			photo:registerScriptTapHandler(function ()
				local awardStr = dayTab[i].Award1
				UISvr:showTipsForAward(awardStr)
			end)
			local getAwardBtn = tolua.cast(frame:getChildByName('get_award_tbtn'), 'UITextButton')
			table.insert(getAwardBtns,i)
			getAwardBtns[i] = getAwardBtn
			updateDayAward(i)
			getAwardBtn:registerScriptTapHandler(function()
				onClickGetAward(i, turncolorTab[i], dayTab[i].Count)
			end)
		end
    end)
        
	dayAwardObj:registerOnShowHandler(function()
        end)
    dayAwardObj:registerOnHideHandler(function()
            cclog('here on-hide for pawn-shop')
        end)
    CUIManager:GetInstance():ShowObject(dayAward, ELF_SHOW.SMART)
end

local function LockBtn()
	prayArrow:setTouchEnable(false)
	prayArrow:setPressState(WidgetStateNormal)
	MainCloseBtn:setTouchEnable(false)
	refreshBtn:setTouchEnable(false)
	getIntegralBtn:setTouchEnable(false)
	dailyAwardBtn:setTouchEnable(false)
	fiftyBtn:setTouchEnable(false)
	tenBtn:setTouchEnable(false)
end

local function OpenBtn()
	prayArrow:setTouchEnable(true)
	prayArrow:setPressState(WidgetStateNormal)
	MainCloseBtn:setTouchEnable(true)
	refreshBtn:setTouchEnable(true)
	getIntegralBtn:setTouchEnable(true)
	dailyAwardBtn:setTouchEnable(true)
	fiftyBtn:setTouchEnable(true)
	tenBtn:setTouchEnable(true)
end      

local function ActionEnd(stype)
	if scheduleId ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
		scheduleId = nil
	end
	prayArrow:stopAllActions()
	local actionOver = CCCallFunc:create(showAward)
	local actionOver1 = CCCallFunc:create(showAward1)
	local openbtn =  CCCallFunc:create(OpenBtn)
	local arr = CCArray:create()
	if stype == 1 then
		arr:addObject(actionOver)
	else
		arr:addObject(actionOver1)
	end
	arr:addObject(openbtn)
	local seq = CCSequence:create(arr)
	prayArrow:runAction(seq)
end

local function turnWheel(stype)
	local rotation = prayArrow:getRotation()
	rotation = rotation/360
	millisecond = millisecond + 0.1
	if rotation < 3 then
		speedByTime = millisecond*millisecond*0.3
	elseif rotation >= 3 and rotation < 8 then
		speedByTime = 2.5
	elseif rotation >= 8 and rotation < endRotate/360 then
		speedByTime = endRotation - rotation
	end
	speed = prayArrow:getActionByTag(100)
	if speedByTime ~= nil then
		speed:setSpeed(speedByTime)
	end
	if rotation > endRotate/360 then
		ActionEnd(stype)
	end
end

local function actionend(stype)
 	ActionEnd(stype)
end

local function turnwl(stype)
	turnWheel(stype)
end

local function updateTurnCash()
	turncashTx:setText(turnTab[turn].Cash)
	turnjifenTx:setText(turnTab[turn].Score)
end

local function doTurnBtn(jsonData)
	print(jsonData)
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		TurnData = response.data
		if colorTab[TurnData.index].Color == 'green' then
			turncolorTab[1] = turncolorTab[1] + 1
		elseif colorTab[TurnData.index].Color == 'orange' then
			turncolorTab[2] = turncolorTab[2] + 1
		elseif colorTab[TurnData.index].Color == 'purple' then
			turncolorTab[3] = turncolorTab[3] + 1
		elseif colorTab[TurnData.index].Color == 'blue' then
			turncolorTab[4] = turncolorTab[4] + 1
		end
		LockBtn()
		SetJifen(response.data.score)
		SetTurn(1)
		PlayerCoreData.addCashDelta(response.data.cash)
		UserData.parseAwardJson(json.encode(response.data.awards))
		updateTitle()
		updateTurnCash()
		prayArrow:setRotation(0)
		endRotate = 3600 + 30 * (response.data.index - 1) + 15
		local rotate = CCRotateBy:create(12, endRotate)
		endRotation = endRotate/360 + 0.1
		local actionOver = CCCallFunc:create(function()
			actionend(1)
		end)
		local arr = CCArray:create()
		arr:addObject(rotate)
		arr:addObject(actionOver)
		local seq = CCSequence:create(arr)
		speed = CCSpeed:create(seq, 1)
		speed:setTag(100)
		prayArrow:runAction(speed)
		millisecond = 1
		scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(turnwl,0.1,false)
		turnwl(1)
	end
end

local function doTurnMoreBtn(jsonData)
	print(jsonData)
	awardsTab = {}
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		TurnData = response.data
		if colorTab[TurnData.index].Color == 'green' then
			turncolorTab[1] = turncolorTab[1] + 1
		elseif colorTab[TurnData.index].Color == 'orange' then
			turncolorTab[2] = turncolorTab[2] + 1
		elseif colorTab[TurnData.index].Color == 'purple' then
			turncolorTab[3] = turncolorTab[3] + 1
		elseif colorTab[TurnData.index].Color == 'blue' then
			turncolorTab[4] = turncolorTab[4] + 1
		end
		LockBtn()
		SetJifen(response.data.score)
		SetTurn(1)
		PlayerCoreData.addCashDelta(response.data.cash)
		UserData.parseAwardJson(json.encode(response.data.awards))
		awardsTab = response.data.awards
		updateTitle()
		updateTurnCash()
		prayArrow:setRotation(0)
		endRotate = 3600 + 30 * (response.data.index - 1) + 15
		local rotate = CCRotateBy:create(12, endRotate)
		endRotation = endRotate/360 + 0.1
		local actionOver = CCCallFunc:create(actionend)
		local arr = CCArray:create()
		arr:addObject(rotate)
		arr:addObject(actionOver)
		local seq = CCSequence:create(arr)
		speed = CCSpeed:create(seq, 1)
		speed:setTag(100)
		prayArrow:runAction(speed)
		millisecond = 1
		scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(turnwl,0.1,false)
		turnwl(0)
	end
end

local function ClickMoreBtn(stype)
	args = {
		type = stype
	}
	if tonumber(PlayerCoreData:getCashValue())< tonumber(turnTab[turn].Cash)*stype then
		GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH') , COLOR_TYPE.RED)
	elseif tonumber(jifen) < tonumber(turnTab[turn].Score)*stype then
		GameController.showPrompts(getLocalStringValue('E_STR_CARD_MASTER_NOT_ENOUGH_SCORE') , COLOR_TYPE.RED)
	else	
		Message.sendPost('lucky_circle_turn', 'activity', json.encode(args), doTurnMoreBtn)
	end
end

local function ClickTurnBtn()
	args = {
		type = 1
	}
	if tonumber(PlayerCoreData:getCashValue())< tonumber(turnTab[turn].Cash) then
		GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH') , COLOR_TYPE.RED)
	elseif tonumber(jifen) < tonumber(turnTab[turn].Score) then
		GameController.showPrompts(getLocalStringValue('E_STR_CARD_MASTER_NOT_ENOUGH_SCORE') , COLOR_TYPE.RED)
	else	
		Message.sendPost('lucky_circle_turn', 'activity', json.encode(args), doTurnBtn)
	end
end

local function update(data)
	for i = 1, #data.items do
		local frame = tolua.cast(panPl:getChildByName('photo_' .. i .. '_ico'), 'UIImageView')
		local awardIco = tolua.cast(frame:getChildByName('thing_ico'), 'UIImageView') 
		local key = data.items[i]
		local exchangeAward = UserData:getAward(itemTab[tonumber(key)].Award1)
		awardIco:setTexture(exchangeAward.icon)
		local numberTx = tolua.cast(frame:getChildByName('number_tx'), 'UILabel')
		numberTx:setText(exchangeAward.count)
		frame:registerScriptTapHandler(function ()
			local awardStr = itemTab[tonumber(key)].Award1
			UISvr:showTipsForAward(awardStr)
		end)
	end
end

local function doRefreshResponse(jsonData)
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		RefreshData = response.data
		LuckRunnerData.lucky_circle.items = RefreshData.items
		ZeroTurn()
		SetRefresh(1)
		PlayerCoreData.addCashDelta(RefreshData.cash)
		update(LuckRunnerData.lucky_circle)
		updateTitle()
		updateTurnCash()
	end
end

local function ClickRefreshBtn()
	if tonumber(PlayerCoreData:getCashValue()) < tonumber(turnTab[refresh].RefreshCash) then
		GameController.showMessageBox(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), MESSAGE_BOX_TYPE.OK)	
	else
		local cash = turnTab[refresh].RefreshCash
		local strbuff = string.format(getLocalString('E_STR_LUCK_RUNNER_CASH'), cash)
		GameController.showMessageBox(strbuff, MESSAGE_BOX_TYPE.OK_CANCEL,function ()
				Message.sendPost('lucky_circle_refresh', 'activity', '{}', doRefreshResponse)
		end)			
	end		
end

local function ClickGetIntegralBtn()
	ShowExchange()
end

local function ClickDailyAwardBtn()
	ShowDayAward()
end

local function helpPanelInit()
	local  root = helpPanel:GetRawPanel()
	local closeBtn = tolua.cast(root:getChildByName('close_btn'),'UIButton')
	closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(helpObj))
	GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

	local knowBtn = tolua.cast(root:getChildByName('know_btn'),'UITextButton')
	knowBtn:registerScriptTapHandler(UiMan.genCloseHandler(helpObj))
	GameController.addButtonSound(knowBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
end

local function onOpenHelpPanel()
	helpObj = SceneObjEx:createObj('panel/luck_runner_help_panel.json','luck-runner-help-lua')
	helpPanel = helpObj:getPanelObj()
	helpPanel:setAdaptInfo('tomb_help_bg_img','tomb_help_img')
	helpPanel:registerInitHandler(helpPanelInit)
	UiMan.show(helpObj)
end

local function genViewUpdater(panel, luckrunner)
	return function() 
		getConf()
		GetJifen()
       	GetTurn()
       	GetRefresh()
		local root = panel:GetRawPanel()
        local luckBgImg = tolua.cast(root:getChildByName('luck_runner_bg_img'), 'UIImageView')
        local luckImg = tolua.cast(luckBgImg:getChildByName('luck_runner_img'), 'UIImageView')
       	local titleBgImg = tolua.cast(luckImg:getChildByName('title_img'), 'UIImageView')
       	cashTx = tolua.cast(titleBgImg:getChildByName('cash_num_tx'), 'UILabel')
       	cashTx:setText(toWordsNumber(PlayerCoreData:getCashValue()))
       	jifenTx = tolua.cast(luckImg:getChildByName('jifen_num_tx'), 'UILabel')
       	jifenTx:setText(jifen)

		MainCloseBtn = tolua.cast(titleBgImg:getChildByName('close_btn'), 'UIButton')
		GameController.addButtonSound(MainCloseBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		MainCloseBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(luckrunner, ELF_HIDE.SMART_HIDE)
		end)

		MainHelpBtn = tolua.cast(titleBgImg:getChildByName('help_btn'), 'UIButton')
		GameController.addButtonSound(MainHelpBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		MainHelpBtn:registerScriptTapHandler(onOpenHelpPanel)

        panPl = tolua.cast(luckImg:getChildByName('pan_pl'), 'UIPanel')   
        speedPl = tolua.cast(panPl:getChildByName('speed_pl'), 'UIPanel')
        turncashTx = tolua.cast(speedPl:getChildByName('cash_num_tx'), 'UILabel')
        turnjifenTx = tolua.cast(speedPl:getChildByName('jifen_num_tx'), 'UILabel')
        timeTx = tolua.cast(luckImg:getChildByName('time_tx'), 'UILabel')
       	timeCDTx = UICDLabel:create()
		timeCDTx:setFontSize(22)
		timeCDTx:setPosition(ccp(0,0))
		timeCDTx:setFontColor(ccc3(50, 240, 50))
		timeCDTx:setAnchorPoint(ccp(0,0.5))
		timeTx:addChild(timeCDTx)
		timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
        timeCDTx:setTime(timeDiff)

        local bgImg = tolua.cast(luckImg:getChildByName('bg_img'),'UIImageView')
        prayArrow =tolua.cast(bgImg:getChildByName('arrow_btn'),'UIButton')
        prayArrow:setTextures('uires/ui_2nd/com/panel/luckrunner/pointer_ico.png', '', '')
        prayArrow:setAnchorPoint(ccp(0.5,0.43))
        prayArrow:registerScriptTapHandler(ClickTurnBtn)

        fiftyBtn = tolua.cast(luckImg:getChildByName('fifty_tbtn'), 'UITextButton')
		fiftyBtn:registerScriptTapHandler(function ()
			ClickMoreBtn(50)
		end)

		tenBtn = tolua.cast(luckImg:getChildByName('ten_tbtn'), 'UITextButton')
		tenBtn:registerScriptTapHandler(function ()
			ClickMoreBtn(10)
		end)

        update(LuckRunnerData.lucky_circle)
        updateTitle()
        updateTurnCash()

		refreshBtn = tolua.cast(luckImg:getChildByName('refresh_tbtn'), 'UITextButton')
		refreshBtn:registerScriptTapHandler(ClickRefreshBtn)

		getIntegralBtn = tolua.cast(luckImg:getChildByName('get_integral_tbtn'), 'UITextButton')
		getIntegralBtn:registerScriptTapHandler(ClickGetIntegralBtn)

		dailyAwardBtn = tolua.cast(luckImg:getChildByName('daily_awards_tbtn'), 'UITextButton')
		dailyAwardBtn:registerScriptTapHandler(ClickDailyAwardBtn)
	end
end

local function genLuckRunnerPanel()
	local luckrunner = SceneObjEx:createObj('panel/luck_runner_panel.json', 'luck-runner-lua')

    local panel = luckrunner:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('luck_runner_bg_img', 'luck_runner_img')
    local viewUpdater = genViewUpdater(panel, luckrunner)

	panel:registerInitHandler(function()
		viewUpdater()
	end)
    	
    panel:registerOnShowHandler(function()
    end)
    panel:registerOnHideHandler(function()
    end)
    -- Show now
    CUIManager:GetInstance():ShowObject(luckrunner, ELF_SHOW.SMART)
end

local function doGetLuckRunnerResponse(jsonData)
	cclog(jsonData)
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		LuckRunnerData = response.data
		turncolorTab = {LuckRunnerData.lucky_circle.color.green,LuckRunnerData.lucky_circle.color.orange
		,LuckRunnerData.lucky_circle.color.purple,LuckRunnerData.lucky_circle.color.blue}
		gotTab = {LuckRunnerData.lucky_circle.got.green,LuckRunnerData.lucky_circle.got.orange
		,LuckRunnerData.lucky_circle.got.purple,LuckRunnerData.lucky_circle.got.blue}
		genLuckRunnerPanel()
	end
end

function LuckRunner.enter()
	Message.sendPost('lucky_circle_get', 'activity', '{}', doGetLuckRunnerResponse)	
end