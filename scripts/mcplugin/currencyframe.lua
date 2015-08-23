

local _stateUpdater = {}
local _visibilityUpdater = {}
local _openingUpdater = {}
local godPlaintIco
local function runPlaintAction ( widget )
	local actArr = CCArray:create()
	local mov1 = CCRotateBy:create(0.15, 15)
	local mov2 = CCRotateBy:create(0.15, -15)
	for i = 1 , 3 do
	    actArr:addObject(mov1)
	    actArr:addObject(mov1:reverse())
	    actArr:addObject(mov2)
	    actArr:addObject(mov2:reverse())
   	end
	actArr:addObject(CCDelayTime:create(1))
	widget:runAction(CCRepeatForever:create(CCSequence:create(actArr)))
end

local function genStateUpdater(widget)
	local goldTx = tolua.cast(widget:getChildByName('gold_num_tx'), 'UILabel')
	local foodTx = tolua.cast(widget:getChildByName('food_num_tx'), 'UILabel')
	local cashTx = tolua.cast(widget:getChildByName('cash_num_tx'), 'UILabel')
	local prestigeTx = tolua.cast(widget:getChildByName('prestige_num_tx'), 'UILabel')

	local goldIco = tolua.cast(widget:getChildByName('gold_bg_ico'),'UIImageView')
	local foodIco = tolua.cast(widget:getChildByName('food_bg_ico'),'UIImageView')
	local cashIco = tolua.cast(widget:getChildByName('cash_bg_ico'),'UIImageView')

	local activeBtn = tolua.cast(widget:getChildByName('act_hall_btn'), 'UIButton')		-- 活动大厅
	local activePlaint = tolua.cast(activeBtn:getChildByName('plaint_ico'), 'UIImageView')

	local dailyTaskBtn = tolua.cast(widget:getChildByName('active_btn'), 'UIButton')		-- 活跃度
	local dailyTaskPlaint = tolua.cast(dailyTaskBtn:getChildByName('plaint_ico'), 'UIImageView')

	local firstpayBtn = tolua.cast(widget:getChildByName('firstpay_btn'), 'UIButton')
	local firstpayPlaint = tolua.cast(firstpayBtn:getChildByName('plaint_ico'),'UIImageView')

	return function(shakeGold, shakeFood, shakeCash)
		local gold = PlayerCoreData.getGoldValue()
		local tx = CStringUtil:numToStr(gold)
		goldTx:setText(tx)

		local food = PlayerCoreData.getFoodValue()
		local tx = CStringUtil:numToStr(food)
		foodTx:setText(tx)

		local cash = PlayerCoreData.getCashValue()
		local tx = CStringUtil:numToStr(cash)
		cashTx:setText(tx)

		local fame = PlayerCore:getFameValue()
		local tx = CStringUtil:numToStr(fame)
		prestigeTx:setText(tx)

		if shakeGold then 
			goldIco:startShaking() 
		end

		if shakeFood then 
			foodIco:startShaking() 
		end
		
		activePlaint:setVisible(UserData:updateActPromptStatus())
		--dailyTaskPlaint:setVisible(false)
		dailyTaskPlaint:setVisible(Activity.canGetBox())
		--local uid = PlayerCoreData.getUID()
		--local longTx = tostring(uid) .. 'firstpay'
		--local firstPayFlag = CCUserDefault:sharedUserDefault():getBoolForKey(longTx)
		local flag = PlayerCoreData.getFirstPay()
    	if flag == 1 then
    		firstpayPlaint:setVisible(true)
    	else
    		firstpayPlaint:setVisible(false)
    	end
		--firstpayPlaint:setVisible(not firstPayFlag)
	end
end

local function setQuanAction(quan)
	--  设置光圈
	local array = CCArray:create()
	array:addObject(CCRotateBy:create(2 , 360))
	local action = CCRepeatForever:create(CCSequence:create(array))
	quan:setVisible(true)
	quan:runAction(action)
end

function setGodPlaintIcoStatus(b)
	-- godPlaintIco:setVisible(b)
end

local function genVisibilityUpdater(widget, sideBarEnabled)
	local firstBtn = tolua.cast(widget:getChildByName('firstpay_btn'), 'UIButton')
	local atcHallBtn  = tolua.cast(widget:getChildByName('act_hall_btn'), 'UIButton')
	local activeBtn = tolua.cast(widget:getChildByName('active_btn'), 'UIButton')
	local bullBtn = tolua.cast(widget:getChildByName('bulletin_btn'), 'UIButton')
	local foodBtn = tolua.cast(widget:getChildByName('food_btn'), 'UIButton')

	return function()
		local playerLevel = PlayerCoreData.getPlayerLevel()
		foodBtn:setVisible( PlayerCoreData.getMaxFoodBuyTime() > 0 )

		local buttons = {
			firstBtn, atcHallBtn, activeBtn, bullBtn--,targetBtn
		}
		local opNames = {
			'TopUpOpenLevel',
			'ActivitiesOpenLevel',
			'VitilityOpenLevel',
			'ChipOpenLevel'--,
			--'AllTargetOpenLevel'
		}
		local extraMask = {
			2 ~= PlayerCoreData.getFirstPay(),		-- Already claimed
			true,
			true,
			true,
			--genGiftsIsOpen()
		}
		assert( #opNames == #extraMask and #buttons == #extraMask, 'must be true')

		local x, y = 690, 52
		local verticalFall = 104
		local isMove = false
		for i=1,#buttons do
			local opLevel = getGlobalIntegerValue(opNames[i])
			local visible = (playerLevel >= opLevel) and extraMask[i]
			--print('op is ' .. tostring(opLevel)  .. ' for '.. opNames[i])
			buttons[i]:setVisible(visible and sideBarEnabled)
			isMove = isMove or(visible and sideBarEnabled)
			buttons[i]:setPosition(ccp(x,y))
			if visible then
				y = y - verticalFall
			end
		end

		-- 横向图标 需要动态移动，移动根据竖向图标当前是否有活动图标
		-- 扩展可以按照竖向图标计算方式相同
		-- local extraMask1 = {
		-- 	genGiftsIsOpen(),
		-- 	God.isTimeOver() == false,
		-- 	true,
		-- 	isOpenHofman(),
		-- 	OBzh:isOpen(),
		-- }
		-- local buttons1 = {
		-- 	targetBtn, godBtn , newSignBtn,hofmanBtn,awardBtn
		-- }
		-- local opNames1 = {
		-- 	'AllTargetOpenLevel',
		-- 	'RecruitLvBuOpenLevel',
		-- 	'AllTargetOpenLevel',
		-- 	'NewYearLevelLimit',
		-- 	'RankOpenLevel'
		-- }
		-- if isMove then
		-- 	x, y = 580,52
		-- else
		-- 	x, y = 690,52
		-- end
		-- verticalFall = 110
		-- for i=1,#buttons1 do
		-- 	local opLevel = getGlobalIntegerValue(opNames1[i])
		-- 	local visible = (playerLevel >= opLevel) and extraMask1[i]
		-- 	print(visible)
		-- 	buttons1[i]:setVisible(visible and sideBarEnabled)
		-- 	isMove = isMove or(visible and sideBarEnabled)
		-- 	buttons1[i]:setPosition(ccp(x,y))
		-- 	if visible then
		-- 		x = x - verticalFall
		-- 	end
		-- end
	end
end

local function genOpeningUpdater(widget)

end


local function installHandler(widget, name, cb)
	local btn = tolua.cast(widget:getChildByName(name),'UIButton')
	btn:selectEffect(1)
	btn:registerScriptTapHandler(cb)
end

local function installEvents(widget)
	local btn = tolua.cast(widget:getChildByName('active_btn'),'UIButton')
	btn:selectEffect(1)
	--local activePlaint = tolua.cast(btn:getChildByName('plaint_ico'), 'UIImageView')
	btn:registerScriptTapHandler(
		function()
			--activePlaint:setVisible(false)
			Activity.enter()
		end
	)

	installHandler(widget, 'gold_btn', genBuyGoldPanel)
	installHandler(widget, 'food_btn', genBuyFoodPanel)
	installHandler(widget, 'cash_btn', genCashBoard)
	installHandler(widget, 'act_hall_btn',genActivityHall)
	installHandler(widget, 'firstpay_btn',function ()
		--local uid = PlayerCoreData.getUID()
		--local longTx = tostring(uid) .. 'firstpay'
		--CCUserDefault:sharedUserDefault():setBoolForKey(longTx,true)
		genFirstPayPanel()
	end)
	-- installHandler(widget, 'target_btn',function ()
	-- 	genGiftsPanel()
	-- end)
	-- installHandler(widget, 'newsign_btn',function ()
	-- 	New_SignIn.enter()
	-- end)
	-- installHandler(widget, 'god_btn',function ()
	-- 	God.giveGodAward()
	-- end)
	-- installHandler(widget, 'hofman_btn',function ()
	-- 	HofmanEnter()
	-- end)
	-- installHandler(widget, 'award_btn',function ()
	-- 	OBzh:openObGetAwards()
	-- end)
	installHandler(widget, 'bulletin_btn',
		function()
			-- requestSystemReward(0)
			-- genStrongPanel()
			openChipPanel()
		end
	)
end

local function genCurrencyFrame(name, sideBarEnabled)
	print('generating for '..name)
	local widget = createWidgetByName('panel/mainscene_top_panel.json')
	installEvents(widget)

	local sideBarUpdater = genVisibilityUpdater(widget, sideBarEnabled)
	sideBarUpdater()		--Call on site

	-- Updates
	_stateUpdater[name] = genStateUpdater(widget)
	_visibilityUpdater[name] = sideBarUpdater
	_openingUpdater[name] = genOpeningUpdater(widget)
	return widget
end

function createCurrencyFrame(host, name, sideBarVisible)
	-- print('createCurrencyFrame')
	-- genRoleInfoPanel1(7,0)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local bar = genCurrencyFrame(name, sideBarVisible)
	bar:setWidgetZOrder(10)
	local frameSize = bar:getContentSize()
	bar:setPosition(ccp(winSize.width - frameSize.width, winSize.height - frameSize.height - 5))
	host:addChild(bar)
	bar:setName('currency-frame-x13')
	print('currency-frame installed.')
end


--- The belows are all protocols
function updateState_CurrencyFrame(name, ...)
	if _stateUpdater and _stateUpdater[name] then 
		_stateUpdater[name](...) 
	end
end

function updateVisibilityByLevelRestrict_CurrencyFrame(name, ...)
	if _visibilityUpdater and _visibilityUpdater[name] then 
		_visibilityUpdater[name](...) 
	end
end

function updatePlugInOpening_CurrencyFrame(name, ...)
	if _openingUpdater and _openingUpdater[name] then 
		_openingUpdater[name](...) 
	end
end