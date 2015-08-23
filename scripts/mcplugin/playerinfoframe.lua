require 'ceremony/mcplugin/fightforce'
require 'ceremony/mcplugin/playertips'


local _stateUpdater = {}
local _visibilityUpdater = {}
local _openingUpdater = {}
local _sdkBtn = {}
local showSdkIco = 0
local lastLevel = 0
local monthCardPlaintIco = 0
local function _showTips()
	FightForce:createPanel()
end
local function _hideTips()
	-- print("_hideTips")
	FightForce:closePanel()
end
local function _showPlayerTips()
	PlayerTips:createPanel()
end
local function _hidePlayerTips()
	-- print("_hidePlayerTips")
	PlayerTips:closePanel()
end
local function _showSdkCenter()
	Third:Inst():ShowSdkCenter()
end
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
	local zhanPl = tolua.cast(widget:getChildByName('zhan_pl'), 'UIPanel')
	local alFightForce = tolua.cast(zhanPl:getChildByName('zhan_num_al'), 'UILabelAtlas')

	local nameTx = tolua.cast(widget:getChildByName('name_tx'), 'UILabel')
	local vipPl = tolua.cast(widget:getChildByName('vip_pl'), 'UIPanel')
	local vipLvIco = tolua.cast(widget:getChildByName('vip_lv_ico'), 'UIImageView')
	local shopBtn = tolua.cast(widget:getChildByName('shop_btn'), 'UIButton')
	-- shopBtn:setTextures('uires/ui_2nd/com/panel/mainscene/shop.png', '', '')
	vipPl:registerScriptTapHandler(function ()
		genVipboard()
	end)

	local ppBtn = tolua.cast(widget:getChildByName('pp_btn'), 'UIButton')
	ppBtn:registerScriptTapHandler(function ()
		_showSdkCenter()
	end)

	if showSdkIco == 1 then
		_sdkBtn[ppBtn] = ppBtn
		ppBtn:registerWidgetDestroyHandler(function ()
			_sdkBtn[ppBtn] = nil
		end)
		if CPlayerGuideMgr:GetInst():IsPlayerGuideRunning() then
			setSdkIconVis(false)
		else
			setSdkIconVis(true)
		end
	else
		ppBtn:setVisible(false)
	end
	

	local expBg = tolua.cast(widget:getChildByName('exp_bg_img'),'UIImageView')

	expBg:setTouchEnable(true)
	expBg:registerScriptCancelHandler(function()
		_hidePlayerTips()
	end)
	expBg:registerScriptLongPressHandler(function ()
		_showPlayerTips()
	end)
	expBg:registerScriptLongPressEndHandler(function()
		_hidePlayerTips()
	end)
	local levelTx = tolua.cast(expBg:getChildByName('lv_tx'), 'UILabel')
	local radialExpBg = tolua.cast(expBg:getChildByName('exp_bar'), 'UIImageView')
	local expProgress = CCProgressTimer:create(CCSprite:create(radialExpBg:getTextureFile()))
	radialExpBg:setVisible(false)
	expProgress:setAnchorPoint(radialExpBg:getAnchorPoint())
	s = radialExpBg:getContentSize()
	expProgress:setPosition(ccp(s.width / 2, s.height / 2))
	radialExpBg:getWidgetParent():getValidNode():addChild(expProgress)
	expProgress:setPercentage(0)
	expProgress:retain()

	zhanPl:setTouchEnable(true)
	zhanPl:registerScriptLongPressHandler(function ()
		_showTips()
	end)
	zhanPl:registerScriptLongPressEndHandler(function ()
		_hideTips()
	end)
	zhanPl:registerScriptCancelHandler(function()
		_hideTips()
	end)

	return function()
		strName = PlayerCoreData.getPlayerName()
		if strName then
			nameTx:setText(strName)
		else
			nameTx:setText("")
		end

		fightForce = PlayerCoreData.getPlayerFightForce()
		strBuff = string.format('%d',fightForce)
		alFightForce:setStringValue(strBuff)
		vip = PlayerCoreData:getPlayerVIP()
		strBuff = string.format('uires/ui_2nd/com/panel/vip/%d.png',vip)
		vipLvIco:setTexture(strBuff)
		curExp = PlayerCoreData.getPlayerExp()

		per = nil
		pSelfObj =PlayerCore:getSelfObject()
		level = PlayerCoreData.getPlayerLevel()
		PlayerCore:JudegeIsReachMaxLevel(level,0)
		if pSelfObj:IsReachMaxLevelAndFullExp() then
			level = PlayerCore:getPlayerMaxLevel()
			per = 99.9
		else
			levelUpExp = getPlayerLevelUpExp(level)
			per = curExp * 100 / levelUpExp
		end
		levelTx:setTextFromInt(level)

		running1 = CCProgressTo:create(0.3, 100)
		running2 = CCProgressTo:create(0.3, per)
		if lastLevel == 0 or level <= lastLevel then
			local array = CCArray:create()
			array:addObject(running2)
			expProgress:runAction(CCSequence:create(array))
			lastLevel = level
		else
			local array = CCArray:create()
			array:addObject(running1)
			local func = CCCallFunc:create(function()
				
				if PlayerCore:IsReachMaxLevel() then
					level = PlayerCore:getPlayerMaxLevel()
				end
				levelTx:setTextFromInt(level)
				lastLevel = level
			end)
			array:addObject(func)
			array:addObject(running2)
			expProgress:runAction(CCSequence:create(array))
		end
		-- SetExpEffect(0)
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

local function genVisibilityUpdater(widget, sideBarEnabled)
	-- local payBtn  = widget:getChildByName('pay_btn')
	-- local shopBtn  = widget:getChildByName('shop_btn')

	-- return function()
	-- 	payBtn:setVisible(sideBarEnabled)
	-- 	shopBtn:setVisible(sideBarEnabled)
	-- end
	local payBtn = tolua.cast(widget:getChildByName('pay_btn'), 'UIButton')
	local shopBtn = tolua.cast(widget:getChildByName('shop_btn'), 'UIButton')
	local strongBtn = tolua.cast(widget:getChildByName('strong_btn'), 'UIButton')
	local targetBtn = tolua.cast(widget:getChildByName('target_btn'), 'UIButton')
	local newSignBtn = tolua.cast(widget:getChildByName('newsign_btn'), 'UIButton')
	local hofmanBtn = tolua.cast(widget:getChildByName('hofman_btn'), 'UIButton')
	local godBtn = tolua.cast(widget:getChildByName('god_btn'), 'UIButton')
	local rebateBtn = tolua.cast(widget:getChildByName('rebate_btn'), 'UIButton')
	local lvupBtn = tolua.cast(widget:getChildByName('lvupaward_btn'), 'UIButton')
	local rebateFrame = tolua.cast(rebateBtn:getChildByName('rebate_quan_ico'), 'UIImageView')
	local lvupFrame = tolua.cast(lvupBtn:getChildByName('lvupaward_quan_ico'), 'UIImageView')
	local strongFrame = tolua.cast(strongBtn:getChildByName('strong_quan_ico'), 'UIImageView')
	local targetFrame = tolua.cast(targetBtn:getChildByName('target_quan_ico'), 'UIImageView')
	local newsignFrame = tolua.cast(newSignBtn:getChildByName('newsign_quan_ico'), 'UIImageView')
	local godFrame = tolua.cast(godBtn:getChildByName('god_quan_ico'), 'UIImageView')
	local hofmanFrame = tolua.cast(hofmanBtn:getChildByName('hofman_quan_ico'), 'UIImageView')
	local awardBtn = tolua.cast(widget:getChildByName('award_btn'), 'UIButton')
	local awardFrame = tolua.cast(awardBtn:getChildByName('award_quan_ico'), 'UIImageView')
	local discountBtn = tolua.cast(widget:getChildByName('discount_btn'), 'UIButton')
	local discountFrame = tolua.cast(discountBtn:getChildByName('discount_quan_ico'), 'UIImageView')
	local rechargeAndPayBtn = tolua.cast(widget:getChildByName('rechargeandpay_btn'), 'UIButton')
	local rechargeAndPayFrame = tolua.cast(rechargeAndPayBtn:getChildByName('rechargeandpay_quan_ico'), 'UIImageView')
	godPlaintIco = tolua.cast(godBtn:getChildByName('plaint_ico'), 'UIImageView')
	strongPlaintIco = tolua.cast(strongBtn:getChildByName('plaint_ico'), 'UIImageView')
	signPlaintIco = tolua.cast(newSignBtn:getChildByName('plaint_ico'), 'UIImageView')
	if setOpenGiftsImg(godPlaintIco) == true then
		setOpenGiftsVisible(false)
	end
	if setStrongImg(strongPlaintIco) == true then
		setStrongVisible(genStrongPanel(1) or false)
	end
	if setSignImg(signPlaintIco) == true then
		New_SignIn.enter(1)
	end
	for i=1,3 do
		if giveGod and giveGod.got_reward and giveGod.got_reward[i] ~= 1 and giveGod.status[i] == 1 then
			-- godPlaintIco:setVisible(true)
			setOpenGiftsVisible(true)
		end
	end

	local plaintIco = tolua.cast(targetBtn:getChildByName('plaint_ico'), 'UIImageView')
	local plaintTx = tolua.cast(plaintIco:getChildByName('gantan_tx'), 'UILabel')
	--runPlaintAction( plaintTx )
	plaintIco:setVisible(false)
	-- setQuanAction(strongFrame)
	setQuanAction(targetFrame)
	setQuanAction(newsignFrame)
	setQuanAction(godFrame)
	setQuanAction(hofmanFrame)
	setQuanAction(awardFrame)
	setQuanAction(rebateFrame)
	setQuanAction(lvupFrame)
	setQuanAction(discountFrame)
	setQuanAction(rechargeAndPayFrame)
	return function()
		-- setStrongVisible(genStrongPanel(1) or false)
		for i=1,3 do
			if giveGod and giveGod.got_reward and giveGod.got_reward[i] ~= 1 and giveGod.status[i] == 1 then
				-- godPlaintIco:setVisible(true)
				setOpenGiftsVisible(true)
			end
		end
		New_SignIn.enter(1)
		local playerLevel = PlayerCoreData.getPlayerLevel()
		local extraMask1 = {
			true,
			true,
			true,
			true,
			genGiftsIsOpen(),
			God.isTimeOver() == false,
			isOpenHofman(),
			OBzh:isOpen(),
			Rechangereb.isOverTime() == false,
			DiscountShop.isOverTime() == false,
			RechargeAndPay.isOpen(),
			LvUp.isOverTime() == false or LvUp.isOver() == false,
		}
		local buttons1 = {
			payBtn,shopBtn,strongBtn , newSignBtn , targetBtn, godBtn ,hofmanBtn,awardBtn,rebateBtn,discountBtn,rechargeAndPayBtn,lvupBtn
		}
		local data = GameData:getArrayData('activities.dat')
		local conf
		local conf1
		local conf2
		local conf3
		table.foreach(data , function (_ , v)
			if v['Key'] == 'payrebate' then
				conf = v
			end
			if v['Key'] == 'discountshop' then
				conf1 = v
			end
			if v['Key'] == 'paycostrank' then
				conf2 = v
			end
			if v['Key'] == 'level_up' then
				conf3 = v
			end
		end)
		local opNames1 = {
			getGlobalIntegerValue('AllTargetOpenLevel'),
			getGlobalIntegerValue('AllTargetOpenLevel'),
			getGlobalIntegerValue('StrengthenOpenLevel'),
			getGlobalIntegerValue('AllTargetOpenLevel'),
			getGlobalIntegerValue('AllTargetOpenLevel'),
			getGlobalIntegerValue('RecruitLvBuOpenLevel'),
			getGlobalIntegerValue('NewYearLevelLimit'),
			getGlobalIntegerValue('OBOpenLevel'),
			tonumber(conf.OpenLevel),
			tonumber(conf1.OpenLevel),
			tonumber(conf2.OpenLevel),
			tonumber(conf3.OpenLevel),
		}
		local x,y,c  = 300, -105,0
		verticalFall = 75
		for i=1,#buttons1 do
			local visible = (playerLevel >= opNames1[i]) and extraMask1[i]
			buttons1[i]:setVisible(visible and sideBarEnabled)
			isMove = isMove or(visible and sideBarEnabled)
			buttons1[i]:setPosition(ccp(x,y))
			if visible then
				x = x + verticalFall

			end
			if x == (300 + verticalFall*8) then
				c = c + 1
				local p = x/900
				x = 300
				y = -105 - p*c*75
			end
		end
	end
end
local function genOpeningUpdater(widget)

end
local function installHandler(widget, name, cb, one)
	local btn = tolua.cast(widget:getChildByName(name),'UIButton')
	btn:selectEffect(1)
	btn:registerScriptTapHandler(function()
		cb(one)
	end)
end
local function installEvents(widget)
	installHandler(widget, 'pay_btn', genCashBoard)
	installHandler(widget, 'shop_btn', openShopMainPanel,1)
	installHandler(widget, 'strong_btn',function ()
		genStrongPanel()
	end)
	installHandler(widget, 'target_btn',function ()
		genGiftsPanel()
	end)
	installHandler(widget, 'newsign_btn',function ()
		New_SignIn.enter()
	end)
	installHandler(widget, 'god_btn',function ()
		God.giveGodAward()
	end)
	installHandler(widget, 'hofman_btn',function ()
		HofmanEnter()
	end)
	installHandler(widget, 'award_btn',function ()
		OBzh:openObGetAwards()
	end)
	installHandler(widget, 'rebate_btn',function ()
		Rechangereb.enter()
	end)
	installHandler(widget, 'discount_btn',function ()
		DiscountShop.Enter()		
	end)
	installHandler(widget, 'rechargeandpay_btn',function ()
		RechargeAndPay.enter()
	end)
	installHandler(widget, 'lvupaward_btn',function ()
		LvUp.enter()
	end)
end
local function genPlayerInfoFrame(name, sideBarEnabled)
	local widget = createWidgetByName('panel/user_info_panel.json')

	installEvents(widget)

	local sideBarUpdater = genVisibilityUpdater(widget, sideBarEnabled)
	sideBarUpdater()		--Call on site

	-- Updates
	_stateUpdater[name] = genStateUpdater(widget)
	_visibilityUpdater[name] = sideBarUpdater
	_openingUpdater[name] = genOpeningUpdater(widget)
	return widget
end

function setMonthCardPlaintIcoStatus(b)
	monthCardPlaintIco:setVisible(b)
end
function createPlayerInfoFrame(host, name, sideBarVisible, showSdk)
	print('createPlayerInfoFrame')
	showSdkIco = showSdk
	local winSize = CCDirector:sharedDirector():getWinSize()
	local bar = genPlayerInfoFrame(name, sideBarVisible)
	bar:setWidgetZOrder(10)
	local frameSize = bar:getContentSize()
	bar:setPosition(ccp(0, winSize.height - frameSize.height))
	host:addChild(bar)
	bar:setName('playerinfo-frame-x13')

	isGet = PlayerCoreData.isActiveMonthPlayerDayAwardClaimed()
	num =  PlayerCoreData.getActiveMonthPlayerLeftDays()
	monthCardPlaintIco = tolua.cast(bar:getChildByName('plaint_ico'), 'UIImageView')
	if isGet == false and num > 0 then
		gantanTx = tolua.cast(bar:getChildByName('gantan_tx'), 'UILabel')
		monthCardPlaintIco:setVisible(true)
		runPlaintAction(gantanTx)
	else
		monthCardPlaintIco:setVisible(false)
	end

	pRoot = tolua.cast(bar:getChildByName('top_bg_img'),'UIImageView')
	pPanel = bar:getContentSize()
	pRoot:setPosition(ccp(0, pPanel.height))
	pRoot:setWidgetZOrder(0)
	pRoot:setScale9Enable(true)
	pRootSize = pRoot:getContentSize()
	newSize = CCSizeMake(winSize.width, pRootSize.height)
	pRoot:setScale9Size(newSize)
	print('playerinfo-frame installed.')
end

function updateState_PlayerInfoFrame(name, ...)
	if _stateUpdater and _stateUpdater[name] then 
		_stateUpdater[name](...) 
	end
end

function updateVisibilityByLevelRestrict_PlayerInfoFrame(name, ...)
	if _visibilityUpdater and _visibilityUpdater[name] then 
		_visibilityUpdater[name](...) 
	end
end

function updatePlugInOpening_PlayerInfoFrame(name, ...)
	if _openingUpdater and _openingUpdater[name] then 
		_openingUpdater[name](...) 
	end
end

function setSdkIconVis(vis)
	if showSdkIco == 1 then
		for k, v in pairs(_sdkBtn) do
			v:setVisible(vis)
		end
	end
end