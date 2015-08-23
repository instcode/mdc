require 'ceremony/panel/vipboard'
require 'ceremony/panel/viptips'

local posInfo = {
	{0, 316 - 20},
	{330, 316 - 20},
	{0, 182 - 20},
	{330, 182 - 20},
	{0, 48  - 20},
	{330, 48  - 20},
	{0, -86  - 20}
}

local boughtSkin = 'uires/ui_2nd/com/panel/vip/month_card.png'
local toBuySkin = 'uires/ui_2nd/com/panel/vip/25_month_card.png'

local function genDecorateSubItem(sub, index)
	local tuijianIco = tolua.cast(sub:getChildByName('tuijian_ico'), 'UIImageView')
	local awardIco = tolua.cast(sub:getChildByName('award_ico'), 'UIImageView')
	local awardNumTx = tolua.cast(sub:getChildByName('award_num_tx'), 'UILabel')
	local buyBtn = tolua.cast(sub:getChildByName('buy_cash_card_btn'), 'UITextButton')
	local infoTx1 = tolua.cast(sub:getChildByName('info_1_tx'),'UILabel')
	local infoTx2 = tolua.cast(sub:getChildByName('info_2_tx'),'UILabel')
	local infoTx3 = tolua.cast(sub:getChildByName('info_3_tx'),'UILabel')
	local infoTx4 = tolua.cast(sub:getChildByName('info_4_tx'),'UILabel')
	infoTx3:setPreferredSize(220,1)

	local url = loadRechargeProfileString(index, 'Url')
	url = 'uires/ui_2nd/image/' .. url
	awardIco:setTexture(url)

	local rmb  = loadRechargeProfileString(index,'Rmb')
	local cash = loadRechargeProfileInt(index, 'Cash')
	awardNumTx:setText(tostring(cash))
	awardNumTx:setVisible(false)

	local wareName = string.format(getLocalStringValue('LS_CASH_NUM'), cash)
	infoTx1:setText(wareName)
	infoTx2:setText(string.format(getLocalStringValue('LS_RMB_NUM'), rmb))

	buyBtn:registerScriptTapHandler(
		function()
			print('sent...>> ' .. tostring(cash).. ' in cash')
			exchangeCash(cash, wareName,0)
		end
	)

	return function()
		local deskey = 'FirstDescription'
		if PlayerCoreData.getPayTimesForID(index) > 0 then
			deskey = 'FollowDescription'
		end
		local description = GetTextForCfg(loadRechargeProfileString(index, deskey))

		if description and string.len(description) > 1 then

			local infos = string.split(description,'*')
			while #infos < 2 do
				infos[#infos+1] = ''
			end
			infoTx3:setText(GetTextForCfg(infos[1]))
			infoTx4:setText(GetTextForCfg(infos[2]))

			infoTx3:setVisible(true)
			infoTx4:setVisible(true)

			tuijianIco:setVisible(true)
		else

			infoTx3:setVisible(false)
			infoTx4:setVisible(false)

			tuijianIco:setVisible(false)
		end

		infoTx3:setAnchorPoint(ccp(0,1))
		infoTx4:setAnchorPoint(ccp(0.3,0.5))
	end
end

local function genOnMonthBoughtCb(updater)
	return function(response)
		print(response)
		local resp = json.decode(response)
		if 0 == resp.code then
			if resp.data then
				-- Cash update
				if resp.data.costCash then
					PlayerCoreData.addCashDelta(tonumber(resp.data.costCash))
				end
				-- State
				if resp.data.month_card then
					LD_TOOLS:ParseMonthCard(json.encode(resp.data.month_card))
				end
			end
			--GameController.showMessageBox('Buy month card success !')
			GameController.showMessageBox(getLocalStringValue('LS_MONTH_CARD_BOUGHT_DONE'))
		else
			--TODO : Prompt that there is something wrong
			GameController.showMessageBox(getLocalStringValue('LS_MONTH_CARD_BOUGHT_ERROR'))
		end
		updater()
	end
end

local function genOnMonthClaimedCb(updater)
	return function(response)
		print(response)
		local resp = json.decode(response)
		if 0 == resp.code then
			if resp.data then
				if resp.data.month_card then
					LD_TOOLS:ParseMonthCard(json.encode(resp.data.month_card))
					setMonthCardPlaintIcoStatus(false)
				end
				if resp.data.awards then
					LD_TOOLS:ParseAwardJson(json.encode(resp.data.awards))
				end
			end
			GameController.showMessageBox(getLocalStringValue('LS_MONTH_DAILY_CLAIM_DONE'))
		else
			print('Error getting award for month player')
			GameController.showMessageBox(getLocalStringValue('LS_MONTH_DAILY_CLAIM_ERROR'))
		end
		updater()
	end
end

local function genMasterUpdater(root)
	local updaters = {}

	local host = root:getChildByName('buy_cash_img')
	local buyCashSV = tolua.cast(host:getChildByName('buy_cash_sv'),'UIScrollView')
	buyCashSV:setClippingEnable(true)
	for i=1, #posInfo do
		local one = createWidgetByName('panel/buy_cash_card_panel.json')
		one:setPosition(ccp(posInfo[i][1], posInfo[i][2]))
		buyCashSV:addChild(one)
		table.insert(updaters, genDecorateSubItem(one,i))
	end
	buyCashSV:scrollToTop()

	
	local monthlyBtn = assert(tolua.cast(root:getChildByName('month_card_bg_btn'),'UIButton'))
	local buyMonthCardBtn = assert(tolua.cast(root:getChildByName('buy_btn'),'UIButton'))
	local claimAwardBtn = assert(tolua.cast(root:getChildByName('get_award_btn'),'UITextButton'))
	local infoPl = assert(root:getChildByName('info_pl'))
	local getAwardPl = assert(root:getChildByName('get_award_pl'))
	local dayTxLabel = assert(tolua.cast(root:getChildByName('day_tx'), 'UILabel'))
	local monthCardIco = assert(tolua.cast(root:getChildByName('month_card_ico'), 'UIImageView'))
	----

	local monthCardPrice = getGlobalIntegerValue('MonthCardPrice')
	local monthCardExRate= getGlobalIntegerValue('MonthCardTimes')
	-- update month card info
	repeat 
		local info1 = tolua.cast(root:getChildByName('month_info_1_tx'),'UILabel')
		local info2 = tolua.cast(root:getChildByName('month_info_2_tx'),'UILabel')

		local dailyPick = getGlobalIntegerValue('EverydayCash', 20)
		local monthInAll= getGlobalIntegerValue('MonthCardDays',15)

		info1:setText(string.format(getLocalStringValue('LS_CONTINUOUS_DAYS_CASH'), monthInAll))
		info2:setText(string.format(getLocalStringValue('LS_PICKUP_DAILY'), dailyPick))

		local dayCashTxLabel = assert(tolua.cast(root:getChildByName('day_cash_tx'), 'UILabel'))
		dayCashTxLabel:setText(string.format(getLocalStringValue('LS_PICKUP_DAILY2'), dailyPick))

		local infoLabel = assert(tolua.cast(root:getChildByName('month_days_left_tx'),'UILabel'))
		infoLabel:setText(string.format(getLocalStringValue('LS_IMMEDIATE_GOT_CASH'), monthCardPrice * monthCardExRate))
	until true

	-- callbacks stay
	buyMonthCardBtn:registerScriptTapHandler(
		function()
			print('buy month card:TODO')
			--Message.sendPost('buy_month_card', 'activity', '{}', genOnMonthBoughtCb(viewUpdater))
			exchangeCash(monthCardPrice*10, getLocalStringValue('LS_MONTH_CARD_NAME'))
		end
	)
	

	local function viewUpdater()
		claimAwardBtn:registerScriptTapHandler(
			function()
				print('claim month player award')
				Message.sendPost('get_month_card_reward', 'activity', '{}',
					genOnMonthClaimedCb(viewUpdater))
			end
		)

		local daysLeft = PlayerCoreData.getActiveMonthPlayerLeftDays()
		dayTxLabel:setText(string.format(getLocalStringValue('LS_MONTH_DAYS_LEFT'),	daysLeft))	
		local isNotMonthUser = daysLeft <= 0
		infoPl:setVisible(isNotMonthUser)
		getAwardPl:setVisible(not isNotMonthUser)

		if isNotMonthUser then
			monthCardIco:setTexture(toBuySkin)
			-- ok , you need to buy more
		else
			monthCardIco:setTexture(boughtSkin)
			if PlayerCoreData.isActiveMonthPlayerDayAwardClaimed() then
				claimAwardBtn:setTouchEnable(false)
				claimAwardBtn:setPressState(WidgetStateDisabled)
				claimAwardBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			else
				claimAwardBtn:setTouchEnable(true)
				claimAwardBtn:setPressState(WidgetStateNormal)
				claimAwardBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
			end
		end

		-- Updaters for each
		for k,v in pairs(updaters) do
			if type(v)=='function' then
				v()
			end
		end
	end
	return viewUpdater
end

local function getLabelResource(lv)
	local res_path = string.format('uires/ui_2nd/com/panel/vip/%d.png', lv)
	return res_path
end

local function genViewUpdater(panel)
	return function()
		local rootWidget = panel:GetRawPanel()

		-- numeric [Template]
		local vipLevel = PlayerCoreData.getPlayerVIP()
		local cashOwned = PlayerCoreData.getCashAccumulated()
		local upCash = cashOwned - getCashAccForLevel(vipLevel)
		local nextCash= getCashAccForLevel(vipLevel + 1)
		local maxLevel = VipProfile:getMaxVipLevel()
		local isFull = ( maxLevel == vipLevel)
		local span = getCashToLevel(vipLevel + 1)
		--local percent = upCash / span * 100
		local percent = cashOwned / nextCash * 100
		if isFull then percent = 100 end

		---[[Debug here
		print('------------------')
		print('Vip is now ' .. tostring(vipLevel))
		print('Next level cash : '  .. tostring(nextCash))
		print('Cash owned : ' .. tostring(cashOwned))
		print('Span : ' .. tostring(span))
		print('Up cash : ' .. tostring(upCash))
		print('Percent : ' .. tostring(percent))
		print('------------------')
		--]]  -- end of debug show

		-- UI
		local expBar = rootWidget:getChildByName('exp_bar')
		expBar = tolua.cast(expBar,'UILoadingBar')
		expBar:setPercent(percent)

		local expTx = tolua.cast(rootWidget:getChildByName('exp_tx'),'UILabel')
		expTx:setText(string.format('%d/%d', cashOwned, nextCash))

		local numTx = rootWidget:getChildByName('cash_num_tx')
		numTx = tolua.cast(numTx, 'UILabel')
		local showV = (nextCash - cashOwned)
		if showV < 0 then showV = 0 end
		if isFull then
			numTx:setText(getLocalStringValue('LS_VIP_ALREADY_MAX'))
		else
			numTx:setText(string.format(getLocalStringValue('LS_CHARGE_MORE'),showV))
		end

		local vipStuff = tolua.cast(rootWidget:getChildByName('buy_vip_stuff_img'), 'UIImageView')
		if vipLevel > 0 then
			vipStuff:setTexture('uires/ui_2nd/com/panel/vip/buy_vip_stuff.png')
		else
			vipStuff:setTexture('uires/ui_2nd/com/panel/vip/charge_to_buy_vip_stuff.png')
		end

		local vNowIco = rootWidget:getChildByName('vip_lv_1_ico')
		vNowIco = tolua.cast(vNowIco, 'UIImageView')

		local vNextIco = rootWidget:getChildByName('vip_lv_2_ico')
		vNextIco = tolua.cast(vNextIco, 'UIImageView')

		if isFull then
			vNowIco:setTexture(getLabelResource(maxLevel))
			vNextIco:setTexture(getLabelResource(maxLevel))
			expBar:setPercent(100)	-- Hard coded like this, is ok
		else
			vNowIco:setTexture( getLabelResource(vipLevel))
			vNextIco:setTexture( getLabelResource(vipLevel+1))
		end

		--Now and the coming one
		vNowIco:setScale(1)
		vNowIco:setAnchorPoint(ccp(0,0.5))
		vNextIco:setScale(0.6)
		vNextIco:setAnchorPoint(ccp(0,0.5))
	end
end

local cashBoardNameString = 'cash-board-special-panel'

--Exportings 
function isCashBoardPresent()
	return UiMan.isPanelPresent(cashBoardNameString)
end

-- --------
function genCashBoard(showType)
	-- Skip in advance
	if isCashBoardPresent() then
		return
	end

	local sceneObj = SceneObjEx:createObj('panel/buy_cash_panel.json', cashBoardNameString)
	local panel = sceneObj:getPanelObj()
	panel:setAdaptInfo('buy_cash_bg_img', 'buy_cash_img')

	local updateView = genViewUpdater(panel)
	panel:registerInitHandler(
		function()
			panel:registerOnShowHandler(updateView)
			panel:registerScriptTapHandler('close_btn', UiMan.genCloseHandler(sceneObj))
			local rootWidget = panel:GetRawPanel()
			local privilegeBtn = rootWidget:getChildByName('privilege_btn')
			privilegeBtn:registerScriptTapHandler(genVipboard)

			local masterUpdater = genMasterUpdater(rootWidget)
			panel:registerForceUpdateHandler( 
				function()
					updateView()
					masterUpdater()
				end
			)

			------##########################
			updateView()
			masterUpdater()
			print('Cashpanel init done')
		end
	)
	UiMan.show(sceneObj, showType)
end

print('cash panel loaded')