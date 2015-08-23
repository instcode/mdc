require 'ceremony/panel/viptips'

local function getResPath(vip)
	local res_path = string.format('uires/ui_2nd/com/panel/vip/%d.png', vip)
	return res_path
end

local function getLabelResource()
	local currentVip = PlayerCoreData.getPlayerVIP()
	return getResPath(currentVip)
end

local info_list = {
	{key = 'MakeEquipAdd'},
	{key = 'BuyFood'},
	{key = 'OpenTrainSeat'},
	{key = 'OccupyMineCash'},
	{key = 'RankDailyCash'},
	{key = 'TowerLimitCash'},
	{key = 'Skillsynthesis'},
	{key = 'BusinessLimit'},
}

local subPanelName = 'panel/vip_fuli_panel.json'
local kTipTag = 30001

-- panel is the IBasePanel object
local function genViewUpdater(panel)
	return function()
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

		-- UI>>
		local rootWidget = panel:GetRawPanel()

		local infoTx = rootWidget:getChildByName('info_tx')
		infoTx = tolua.cast(infoTx, 'UILabel')
		local showV = nextCash - cashOwned
		if showV < 0 then showV = 0 end
		if isFull then
			infoTx:setText(getLocalStringValue('LS_VIP_ALREADY_MAX'))
		else
			infoTx:setText(string.format(getLocalStringValue('LS_PRO_CASH_APPEND'), showV))
		end

		local vNextIco = rootWidget:getChildByName('vip_lv_2_ico')
		vNextIco = tolua.cast(vNextIco, 'UIImageView')

	    local vNowIco = rootWidget:getChildByName('vip_lv_1_ico')
	    vNowIco = tolua.cast(vNowIco, 'UIImageView')
		vNowIco:setTexture(getLabelResource())

		local percentTx = tolua.cast(rootWidget:getChildByName('percent_tx'), 'UILabel')
		percentTx:setText(string.format('%d/%d', cashOwned, nextCash))

		local expBar = tolua.cast(rootWidget:getChildByName('exp_bar'), 'UILoadingBar')
		expBar:setPercent(percent)

		--
		if isFull then
			vNextIco:setTexture(getResPath(maxLevel))
		else
			vNextIco:setTexture(getResPath(vipLevel+1))
		end

		vNextIco:setScale(0.6)
		vNextIco:setAnchorPoint(ccp(0,0.5))
		vNowIco:setAnchorPoint(CCPointMake(0, 0.5))
	end
end

---[[
local function processSingleInfo(info, label)
	if label then
		if info then
			label:setVisible(true)
			label:setText(info)
		else
			label:setVisible(false)
		end
	end
end
--]]

local function genBoughtResponsor(index, cashSpent, successHandler)
	return function(response)
		-- print(response)
		local resp = json.decode(response)
		if resp.code == 0 then
			if resp.data and resp.data.awards then
				UserData.parseAwardJson(json.encode(resp.data.awards))
				-- print('ok, bought done')
				popGamePrompt(getLocalStringValue('LS_BOUGHT_DONE'))
				PlayerCoreData.addCashDelta(-cashSpent)
			else
				print('no award ?? for vip bought')
			end
			
			PlayerCoreData.markVipBoughtForLevel(index)
			successHandler()
		else
			GameController.showMessageBox(getLocalStringValue('LS_BOUGHT_ERROR'))
		end
	end
end

-- i is the VIP level
local function loadVipInfo(panel, one, i)
	if nil == one then
		-- Skip all
		return
	end

	local isBought = (PlayerCoreData.getVipBoughtForLevel(i) > 0)
	local boughtTimes = PlayerCoreData.getVipBuyTimes(i)
	if not isBought then
		boughtTimes = boughtTimes + 1
	end

	local label = one:getChildByName('vip_num_tx')
	label = tolua.cast(label, 'UILabel')
	if not label then return end
	local fuliLabel = one:getChildByName('fuli_tx')
	fuliLabel = tolua.cast(fuliLabel, 'UILabel')
	if not fuliLabel then return end

	local cashTx = one:getChildByName('need_cash_tx')
	cashTx = tolua.cast(cashTx, 'UILabel')
	if not cashTx then return end
	local cashnum = getCashAccForLevel(i)
	cashTx:setText(string.format(getLocalStringValue('LS_CASH_NUM'), cashnum))
	cashTx:setColor(COLOR_TYPE.ORANGE)
	label:setText(string.format(getLocalStringValue('LS_PRO_PREVILEGE'), i))
	label:setColor(COLOR_TYPE.ORANGE)
	fuliLabel:setText(string.format(getLocalStringValue('LS_PRO_FULI'), i))

	local infoLong = GetTextForCfg(loadVipProfileString(i, 'Description'))
	local splits = string.split(infoLong, '*')
	-- print('Splits up to ' .. tostring(#splits))

	for j=1, 14 do
		local name = string.format('privilege_info_%d_tx', j)
		local labelTx = tolua.cast(one:getChildByName(name),'UILabel')
		processSingleInfo(splits[j], labelTx)
	end

	-- Materials
	--local mat = loadVipProfileString(i, 'Award1')
	local mat, price = getMaterialForTime(i, boughtTimes)
	price = tonumber(price)
	-- print('Material is ' .. mat)
	local matInfo = UserData:getAward(mat)

	-- material image
	local ico = one:getChildByName('award_ico')
	ico = tolua.cast(ico, 'UIImageView')
	ico:setTexture(matInfo.icon)

	-- tips info
	local icoFrame = one:getChildByName('award_photo_ico')
	icoFrame:setTouchEnable(true)

	--[[   -- And this is going down.
	icoFrame:registerScriptLongPressHandler(
		function() 
			local tip = createWidgetByName('panel/viptips_1.json')
			tip:setWidgetTag(kTipTag)
			local rootWidget = panel:GetRawPanel()
			rootWidget:addChild(tip)
			tip:setWidgetZOrder(99999)

			local t1 = tolua.cast(tip:getChildByName('benefits_name_tx'), 'UILabel')
			local t2 = tolua.cast(tip:getChildByName('benefits_introduction_tx'), 'UITextArea')
			local info1 = loadVipProfileString(i, 'BenefitsName')
			local info2 = loadVipProfileString(i, 'BenefitsIntroduction')
			t1:setText(info1)
			t2:setText(info2)

			local sz = CCDirector:sharedDirector():getWinSize()
			local tsz = tip:getContentSize()
			tip:setPosition(ccp((sz.width - tsz.width)*0.5, (sz.height - tsz.height)*0.5))
			--tip:setPosition(ccp(sz.width * 0.5, sz.height * 0.5))
		end
	)
	icoFrame:registerScriptLongPressEndHandler( function() 
			local rootWidget = panel:GetRawPanel()
			local sub = rootWidget:getChildByTag(kTipTag)
			if sub then
				sub:removeFromParentAndCleanup(true)
			end
		end
	)
	]]
	icoFrame:registerScriptTapHandler(genTouchMatTips(matInfo, i, boughtTimes))

	-- material count
	local awardCountLabel = one:getChildByName('award_num_tx')
	awardCountLabel = tolua.cast(awardCountLabel, 'UILabel')
	awardCountLabel:setText(tostring(matInfo.count))
	awardCountLabel:setAnchorPoint(ccp(1,0.5))

	-- local price = loadVipProfileInt(i, 'CashPrice')
	-- print('Cashprice is ' .. tostring(price))
	local priceLabel = one:getChildByName('cash_num_tx')
	priceLabel = tolua.cast(priceLabel, 'UILabel')
	priceLabel:setText('X' .. tostring(price))
	priceLabel:setAnchorPoint(ccp(0, 0.5))

	--
	local buyBtn = tolua.cast(one:getChildByName('buy_btn'), 'UITextButton')
	buyBtn:setPressState(WidgetStateNormal)
	buyBtn:setTouchEnable(true)

	buyBtn:registerScriptTapHandler(function()
			-- print('go to buy ' .. tostring(matInfo.id))
			-- TODO
			-- Message.sendPost( act, mod, argsJson, function()end)

			if price > PlayerCoreData.getCashValue() then
				GameController.showMessageBox(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'))
				return
			end

			local param = {vip = i}
			print('Buy [' .. tostring(i) .. ']')
			Message.sendPost('vip_buy', 'user', json.encode(param), 
				genBoughtResponsor(i, price,
					function()
						buyBtn:setPressState(WidgetStateDisabled)
						buyBtn:setTouchEnable(false)
						buyBtn:setText(getLocalStringValue('LS_BOUGHT_ALREADY'))
					end)
			)
		end
	)

	-- 
	local vipNow = PlayerCoreData.getPlayerVIP()
	if isBought or vipNow < i then
		buyBtn:setPressState(WidgetStateDisabled)
		buyBtn:setTouchEnable(false)
		local strKey = 'LS_BOUGHT_ALREADY'
		local lt = vipNow < i
		if lt then 
			strKey = 'LS_NOT_OPEN_YET'
		end
		buyBtn:setText(getLocalStringValue(strKey))
	end
end

local function getViewPageCount()
	local vipNow = PlayerCoreData.getPlayerVIP() 
	if vipNow < 6 then
		return 6
	end
	return VipProfile:getMaxVipLevel()
end

local vipBoardName = 'vipboard-in-lua'

function genVipboard()
	if UiMan.isPanelPresent(vipBoardName) then
		return
	end

	-- print('inside genVipboard() v8')
	local maxLevel = VipProfile:getMaxVipLevel()
	print('Max Level is ' .. tostring(maxLevel))
	local vipPanel = SceneObjEx:createObj('panel/vip_bg_panel.json', vipBoardName)

	local _onHide = function()
		print('on-hide for vip board')
	end

	local panel = vipPanel:getPanelObj()		--IBasePanelEx
    panel:setAdaptInfo('vip_bg_img', 'vip_img')
    local viewUpdater = genViewUpdater(panel)

	local viewPageCount = getViewPageCount()

	local container = {}
	for i=1, viewPageCount do 
		container[i] = {}
		container[i].cont = UIContainerWidget:create()
		container[i].cont:setSize(CCSizeMake(790, 440))
	end

	local function fillContainer(page)
		page = page + 1
		if page > 0 and page <= #container then
			if not container[page].view then
				--print('Creating page '.. tostring(page))
				local view = tolua.cast(createWidgetByName(subPanelName), 'UIPanel')
				loadVipInfo(panel, view, page)
				container[page].cont:addChild(view)
				container[page].view = view
			end
		end
	end

	panel:registerInitHandler(
		function()
			panel:registerScriptTapHandler('close_btn', UiMan.genCloseHandler(vipPanel))
			panel:registerOnHideHandler(_onHide)

			-- Only here does rootWidget come to effect.
			local rootWidget = panel:GetRawPanel()
		    local buyCashBtn = rootWidget:getChildByName('buy_cash_btn')
		    buyCashBtn = tolua.cast(buyCashBtn, 'UIButton')
		    --buyCashBtn:setTouchEnable(false)
		    --buyCashBtn:setPressState(WidgetStateDisabled)
		    buyCashBtn:registerScriptTapHandler(
		    	function()
		    		if isCashBoardPresent() then
		    			UiMan.hide(vipPanel, ELF_HIDE.SMART_HIDE)
		    		else
		    			UiMan.hide(vipPanel, ELF_HIDE.HIDE_NORMAL)
		    			genCashBoard(ELF_SHOW.ZOOM_IN)
		    		end
		    		print('done.')
		    	end
		    )

			-- Scroll view
			local vipImg = rootWidget:getChildByName('vip_img')
			local pv = UIPageView:create()
			pv:setSize(CCSizeMake(790, 440))

			pv:setPosition(ccp(69, 10))
			vipImg:addChild(pv)

			for i=1,#container do
				pv:addPage(container[i].cont)
			end

			pv:addScroll2PageEventScript(fillContainer)
			panel:registerOnShowHandler(viewUpdater)

			local leftArrow = rootWidget:getChildByName('left_arrows_btn')
			leftArrow:registerScriptTapHandler(function()
					-- Pre-fill
					repeat
						local tPage = pv:getCurrentPage() - 1
						local pageCount = pv:getPageCount()
						if tPage < 0 then tPage = pageCount - 1 end
						--print('pre loading ' .. tostring(tPage))
						fillContainer(tPage)
					until true
					pv:scrollToLeft()
				end
			)

			local rightArrow =rootWidget:getChildByName('right_arrows_btn')
			rightArrow:registerScriptTapHandler(function()
					-- Pre-fill
					repeat
						local tPage = pv:getCurrentPage() + 1
						local pageCount = pv:getPageCount()
						if tPage >= pageCount then tPage = 0 end
						-- print('pre loading ' .. tostring(tPage))
						fillContainer(tPage)
					until true
					pv:scrollToRight()
				end
			)

			--
			viewUpdater()
			local targetPage = PlayerCoreData.getPlayerVIP() - 1
			if targetPage < 0 then targetPage = 0 end
			pv:scrollToPage(targetPage)
			print('done init vip-board')
		end
	)

	UiMan.show(vipPanel)
end


-- Process here>>>
-- print('vipboard is reloaded')

