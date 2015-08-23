BUY_PANEL_TYPE = readOnly{
	BUY = 0, 				--购买
	SELL = 1,				--出售
	SOUL = 2,				--化魂
	USE = 3,				--使用
	MOREUSE = 4,			--批量使用
	KEYBOX = 5,				--带钥匙的宝箱
	SCORE_SHOP = 6,			--卡牌积分商城
	PAWN_EXCHANGE = 7,		--当铺兑换
	LEGION_DONATE = 8,		--军团捐献
	LEGION_EXCHANGE = 9, 	--军团兑换
	TOKEN_EXCHANGE = 10 	--荣誉令牌兑换
}

local Limit = readOnly{
	MAX_COUNT = 99
}

local MoneyIco = readOnly{
	Cash = 'uires/ui_2nd/com/panel/common/cash_icon.png',
	Score = 'uires/ui_2nd/com/panel/card_master/score_label.png',
	Coin = 'uires/ui_2nd/com/panel/common/coin.png',
	LegionHonor = 'uires/ui_2nd/com/panel/army_war/gong_ico.png',
	Pvp = 'uires/ui_2nd/com/panel/pvp/pvp_token.png'
}

----------------------------------
--UI
-----------------------------------
-- title
local titleIco
local titleMoneyIcon
local titleMoneyTx
-- left side
local nameTx
local nameBgImg
local itemIco
local hasTx
local descTx
-- right side
local numEditBox
local leftBtn
local rightBtn
local currMoneyTx
local currMoneyIcon
local confirmBtn
----------------------------------
--DATA
-----------------------------------
local shopId
local panelType
local bSData
local buyCallBackFn			--购买回调
local totalMoney
local hasNum
local price					--单价
local maxCount  			--最大数量

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

	if panelType == BUY_PANEL_TYPE.BUY or panelType == BUY_PANEL_TYPE.PAWN_EXCHANGE or panelType == BUY_PANEL_TYPE.SCORE_SHOP or panelType == BUY_PANEL_TYPE.LEGION_EXCHANGE or panelType == BUY_PANEL_TYPE.TOKEN_EXCHANGE then
		if num >= Limit.MAX_COUNT or num >= math.floor(totalMoney / price) then
			rightBtn:disable()
		else
			rightBtn:active()
		end
	else
		if num >= hasNum or num >= Limit.MAX_COUNT then
			rightBtn:disable()
		else
			rightBtn:active()
		end
	end
end

-- 初始化购买界面
local function initConfirmBuyPanel()
    local sceneObj = SceneObjEx:createObj('panel/confirm_buy_panel.json', 'confirm-buy-lua')
    local panel = sceneObj:getPanelObj()
    panel:setAdaptInfo('zhegai_bg_img', 'buy_bg_img')

    local function updateNumbers()
		local ct = numEditBox:getTextFromInt()
		if ct < 0 then 
			return 
		end
		currMoneyTx:setTextFromInt( ct * price )

		updateConfirmBtn()
	end

	local function onLongPressLeftBtn()
		CNumEditorAct:getInst():numDec(leftBtn,numEditBox,rightBtn,1)
		CNumEditorAct:getInst():registerScriptNumDecHandler( updateNumbers )
	end

	local function onLongPressRightBtn()
		local num = 0
		if panelType == BUY_PANEL_TYPE.BUY or panelType == BUY_PANEL_TYPE.SCORE_SHOP 
			or panelType == BUY_PANEL_TYPE.PAWN_EXCHANGE or panelType == BUY_PANEL_TYPE.LEGION_EXCHANGE 
			or panelType == BUY_PANEL_TYPE.TOKEN_EXCHANGE then
			if math.floor(totalMoney / price) <= Limit.MAX_COUNT then
				num = math.floor(totalMoney / price)
			else
				num = Limit.MAX_COUNT
			end
		else 
			num = hasNum < Limit.MAX_COUNT and hasNum or Limit.MAX_COUNT
		end
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
		if panelType == BUY_PANEL_TYPE.BUY or panelType == BUY_PANEL_TYPE.PAWN_EXCHANGE 
			or panelType == BUY_PANEL_TYPE.SCORE_SHOP or panelType == BUY_PANEL_TYPE.LEGION_EXCHANGE 
			or panelType == BUY_PANEL_TYPE.TOKEN_EXCHANGE then
			if math.floor(totalMoney / price) <= Limit.MAX_COUNT then
				num = math.floor(totalMoney / price)
			else
				num = Limit.MAX_COUNT
			end
		else
			num = hasNum < Limit.MAX_COUNT and hasNum or Limit.MAX_COUNT
		end
		CNumEditorAct:getInst():numAddOnce(leftBtn, numEditBox, rightBtn, num)
		updateNumbers()
	end

	local function onClickBuyBtn()
		if not buyCallBackFn then
			return
		end

		local ct = numEditBox:getTextFromInt()
		if panelType == BUY_PANEL_TYPE.BUY or panelType == BUY_PANEL_TYPE.SCORE_SHOP or panelType == BUY_PANEL_TYPE.PAWN_EXCHANGE or panelType == BUY_PANEL_TYPE.TOKEN_EXCHANGE then
			buyCallBackFn( shopId , ct )
		end

		if panelType == BUY_PANEL_TYPE.LEGION_DONATE or panelType == BUY_PANEL_TYPE.LEGION_EXCHANGE then
			buyCallBackFn( shopId , ct )
		end

		CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
	end

    local function editBoxEventHandler( eventType )
		--if eventType == 'ended' then
			local num = numEditBox:getTextFromInt()
			if num <= 0 then
				num = 0
			else
				if panelType == BUY_PANEL_TYPE.BUY or panelType == BUY_PANEL_TYPE.PAWN_EXCHANGE 
					or panelType == BUY_PANEL_TYPE.SCORE_SHOP or panelType == BUY_PANEL_TYPE.LEGION_EXCHANGE 
					or panelType == BUY_PANEL_TYPE.TOKEN_EXCHANGE then
					if num > Limit.MAX_COUNT then
						num = Limit.MAX_COUNT
					end
					if num > math.floor(totalMoney / price) then
						num = math.floor(totalMoney / price)
					end
				else 
					if num > Limit.MAX_COUNT then
						num = Limit.MAX_COUNT
					end
					if num > hasNum then
						num = hasNum
					end
				end
			end
			numEditBox:setTextFromInt(num)
			updateNumbers()
			updateBtnStatus()
		--end
	end

    panel:registerInitHandler(function()
        local root = panel:GetRawPanel()
        local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
        closeBtn:registerScriptTapHandler(function ()
        	CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
        end)
        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
        local background = tolua.cast(root:getChildByName('zhegai_bg_img'), 'UIImageView')
        background:registerScriptTapHandler(function ()
        	CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
        end)
        --Init title.
        titleIco = tolua.cast(root:getChildByName('buy_title_tx') , 'UILabel')
        titleMoneyIcon = tolua.cast(root:getChildByName('honor_ico') , 'UIImageView')
        titleMoneyTx = tolua.cast(root:getChildByName('honor_num_tx') , 'UILabel')

        --Init left side.
        local contentImg = root:getChildByName('buy_img')
        nameTx = tolua.cast(contentImg:getChildByName('name_tx') , 'UILabel')
        nameBgImg = tolua.cast(contentImg:getChildByName('name_bg_ico') , 'UIImageView')
        itemIco = tolua.cast(contentImg:getChildByName('material_ico') , 'UIImageView')
        hasTx = tolua.cast(contentImg:getChildByName('own_tx') , 'UILabel')
        descTx = tolua.cast(contentImg:getChildByName('info_tx') , 'UITextArea')
        nameTx:setPreferredSize(280,1)
        --Init right side.
        local honorPl = tolua.cast(contentImg:getChildByName('honor_pl') , 'UIPanel')
        local prestigePl = tolua.cast(contentImg:getChildByName('prestige_pl') , 'UIPanel')
        honorPl:setVisible(true)
        prestigePl:setVisible(false)
        local editBoxBg = tolua.cast(honorPl:getChildByName('number_bg_ico') , 'UIImageView')
        numEditBox = tolua.cast(UISvr:replaceUIImageViewByCCEditBox(editBoxBg) , 'CCEditBox')
		numEditBox:setHAlignment(kCCTextAlignmentCenter)
		numEditBox:setInputMode(kEditBoxInputModeDecimal)
		numEditBox:setFontSize(42)
		numEditBox:registerScriptEditBoxHandler( editBoxEventHandler )
		leftBtn = tolua.cast(honorPl:getChildByName('left_page_btn') , 'UITextButton')
		rightBtn = tolua.cast(honorPl:getChildByName('right_page_btn') , 'UITextButton')
		currMoneyTx = tolua.cast(honorPl:getChildByName('need_honor_num_tx') , 'UILabel')
		currMoneyIcon = tolua.cast(honorPl:getChildByName('need_honor_ico') , 'UIImageView')
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
    end)

    CUIManager:GetInstance():ShowObject(sceneObj, ELF_SHOW.ZOOM_IN)
end

--打开积分商铺
--data : id , name , count(拥有数量) , color , icon , desc , price(单价)
--callcack : 购买回调
function openScoreShopPanel(data , callback )

	initConfirmBuyPanel()

	bSData = data
	shopId = bSData['id']
	panelType = BUY_PANEL_TYPE.SCORE_SHOP
	buyCallBackFn = callback
	titleIco:setText( getLocalStringValue("E_STR_SHOP_CONFIRM_BUY_TITLE") )
	titleMoneyIcon:setTexture( MoneyIco.Score )
	totalMoney = PlayerCoreData.getScoreValue()
	titleMoneyTx:setText( toWordsNumber(totalMoney) )

	hasNum = bSData['count'] or 0
	local hasStr = string.format(getLocalString('E_STR_BS_CONFIRM_HAS_NUM_STR') , toWordsNumber(hasNum))
	hasTx:setText(hasStr)
	nameTx:setText(bSData['name'])
	nameTx:setColor(bSData['color'])
	itemIco:setTexture(bSData['icon'])
	descTx:setText(bSData['desc'])
	numEditBox:setTextFromInt(1)
	price = bSData['price'] or 0
	local buyMax = math.floor(totalMoney / price)
	maxCount = buyMax > Limit.MAX_COUNT and Limit.MAX_COUNT or buyMax

	currMoneyIcon:setTexture( MoneyIco.Score )
	currMoneyTx:setTextFromInt( price )
	confirmBtn:setText( getLocalString('E_STR_BAG_SHOP_EXCHANGE_STR') )

	updateBtnStatus()
	updateConfirmBtn()
end

-- 打开古币兑换界面
function openPawnExchangePanel(data , callback )

	initConfirmBuyPanel()

	bSData = data
	shopId = bSData['id']
	panelType = BUY_PANEL_TYPE.PAWN_EXCHANGE
	buyCallBackFn = callback
	titleIco:setText( getLocalStringValue("E_STR_SHOP_CONFIRM_BUY_TITLE") )
	titleMoneyIcon:setTexture( MoneyIco.Coin )
	totalMoney = PlayerCoreData.getCoinValue()
	titleMoneyTx:setText( toWordsNumber(totalMoney) )

	hasNum = bSData['count'] or 0
	local hasStr = string.format(getLocalString('E_STR_BS_CONFIRM_HAS_NUM_STR') , toWordsNumber(hasNum))
	hasTx:setText(hasStr)
	nameTx:setText(bSData['name'])
	nameTx:setColor(bSData['color'])
	itemIco:setTexture(bSData['icon'])
	descTx:setText(bSData['desc'])
	price = bSData['price'] or 0
	local buyMax = math.floor(totalMoney / price)
	maxCount = buyMax > Limit.MAX_COUNT and Limit.MAX_COUNT or buyMax
	if maxCount == 0 then
		numEditBox:setTextFromInt(0)
	else
		numEditBox:setTextFromInt(1)
	end
	currMoneyIcon:setTexture( MoneyIco.Coin )
	currMoneyTx:setTextFromInt( price )
	confirmBtn:setText( getLocalString('E_STR_BAG_SHOP_EXCHANGE_STR') )

	updateBtnStatus()
	updateConfirmBtn()
end

-- 打开军团捐献界面
function openLegionDonatePanel(data , callback)
	initConfirmBuyPanel()

	bSData = data
	shopId = bSData['id']
	panelType = BUY_PANEL_TYPE.LEGION_DONATE
	buyCallBackFn = callback
	titleIco:setText( LegionConfig:getLegionLocalText('E_STR_LEGION_DONATE_DESC') )
	-- titleMoneyIcon:setTexture( MoneyIco.LegionHonor )
	titleMoneyIcon:setVisible(false)
	titleMoneyTx:setVisible(false)

	hasNum = bSData['count'] or 0
	local hasStr = string.format(getLocalString('E_STR_BS_CONFIRM_HAS_NUM_STR') , toWordsNumber(hasNum))
	hasTx:setText(hasStr)
	nameTx:setText(bSData['name'])
	nameTx:setColor(bSData['color'])
	itemIco:setTexture(bSData['icon'])
	descTx:setText(bSData['desc'])
	price = bSData['sellprice'] or 0
	maxCount = hasNum > Limit.MAX_COUNT and Limit.MAX_COUNT or hasNum
	if maxCount == 0 then
		numEditBox:setTextFromInt(0)
	else
		numEditBox:setTextFromInt(1)
	end
	currMoneyIcon:setTexture( MoneyIco.LegionHonor )
	currMoneyTx:setTextFromInt( price )
	confirmBtn:setText( LegionConfig:getLegionLocalText('E_STR_DONATE') )

	updateBtnStatus()
	updateConfirmBtn()
end

-- 打开军团兑换界面
function openLegionExchangePanel(data , callback)
	initConfirmBuyPanel()

	bSData = data
	shopId = bSData['id']
	panelType = BUY_PANEL_TYPE.LEGION_EXCHANGE
	buyCallBackFn = callback
	titleIco:setText(LegionConfig:getLegionLocalText('E_STR_LEGION_EXCHANGE_DESC'))
	titleMoneyIcon:setTexture( MoneyIco.LegionHonor )
	totalMoney = MyLegion:getMyData().honor		-- 个人贡献
	titleMoneyTx:setText( toWordsNumber(totalMoney) )

	hasNum = bSData['count'] or 0
	local hasStr = string.format(getLocalString('E_STR_BS_CONFIRM_HAS_NUM_STR') , toWordsNumber(hasNum))
	hasTx:setText(hasStr)
	-- hasTx:setVisible(false)
	nameTx:setText(bSData['name'])
	nameTx:setColor(bSData['color'])
	itemIco:setTexture(bSData['icon'])
	descTx:setText(bSData['desc'])
	price = bSData['sellprice'] or 0
	local buyMax = math.floor(totalMoney / price)
	maxCount = buyMax > Limit.MAX_COUNT and Limit.MAX_COUNT or buyMax
	if maxCount == 0 then
		numEditBox:setTextFromInt(0)
	else
		numEditBox:setTextFromInt(1)
	end

	currMoneyIcon:setTexture( MoneyIco.LegionHonor )
	currMoneyTx:setTextFromInt( maxCount == 0 and 0 or price )
	confirmBtn:setText( getLocalString('E_STR_BAG_SHOP_EXCHANGE_STR') )

	updateBtnStatus()
	updateConfirmBtn()
end

-- 打开军团令兑换界面
function openLegionOrderExchangePanel(data , callback)
	initConfirmBuyPanel()

	bSData = data
	shopId = bSData['id']
	panelType = BUY_PANEL_TYPE.LEGION_EXCHANGE
	buyCallBackFn = callback
	titleIco:setText(LegionConfig:getLegionLocalText('E_STR_LEGION_ORDER_EXCHANGE_DESC'))
	titleMoneyIcon:setTexture( MoneyIco.LegionHonor )
	totalMoney = PlayerCoreData.getScoreValue()
	titleMoneyTx:setText( toWordsNumber(totalMoney) )

	hasNum = bSData['count'] or 0
	local hasStr = string.format(getLocalString('E_STR_BS_CONFIRM_HAS_NUM_STR') , toWordsNumber(hasNum))
	hasTx:setText(hasStr)
	hasTx:setVisible(false)
	nameTx:setText(bSData['name'])
	nameTx:setColor(bSData['color'])
	itemIco:setTexture(bSData['icon'])
	descTx:setText(bSData['desc'])
	numEditBox:setTextFromInt(1)
	price = bSData['sellprice'] or 0
	local buyMax = math.floor(totalMoney / price)
	maxCount = buyMax > Limit.MAX_COUNT and Limit.MAX_COUNT or buyMax

	currMoneyIcon:setTexture( MoneyIco.LegionHonor )
	currMoneyTx:setTextFromInt( price )
	confirmBtn:setText( getLocalString('E_STR_BAG_SHOP_EXCHANGE_STR') )

	updateBtnStatus()
	updateConfirmBtn()
end

--打开购买界面
--data : id , name , count(拥有数量) , color , icon , desc , price(单价)
--callcack : 购买回调
function openShopBuyPanel(data , callback )

	initConfirmBuyPanel()

	bSData = data
	shopId = bSData['id']
	panelType = BUY_PANEL_TYPE.BUY
	buyCallBackFn = callback
	titleIco:setText( getLocalStringValue("E_STR_SHOP_CONFIRM_BUY_TITLE") )
	titleMoneyIcon:setTexture( MoneyIco.Cash )
	totalMoney = PlayerCoreData.getCashValue()
	titleMoneyTx:setText( toWordsNumber(totalMoney) )

	hasNum = bSData['count'] or 0
	local hasStr = string.format(getLocalString('E_STR_BS_CONFIRM_HAS_NUM_STR') , toWordsNumber(hasNum))
	hasTx:setText(hasStr)
	nameTx:setText(bSData['name'])
	nameTx:setColor(bSData['color'])
	itemIco:setTexture(bSData['icon'])
	descTx:setText(bSData['desc'])
	price = bSData['price'] or 0

	local buyMax = math.floor(totalMoney / price)
	maxCount = buyMax > Limit.MAX_COUNT and Limit.MAX_COUNT or buyMax
	if maxCount == 0 then
		numEditBox:setTextFromInt(0)
	else
		numEditBox:setTextFromInt(1)
	end

	currMoneyIcon:setTexture( MoneyIco.Cash )
	currMoneyTx:setTextFromInt( price )
	confirmBtn:setText( getLocalString('E_STR_BUY') )

	updateBtnStatus()
	updateConfirmBtn()
end

-- 打开PVP兑换界面
function openPvpExchangePanel(data , callback )

	initConfirmBuyPanel()

	bSData = data
	shopId = bSData['id']
	panelType = BUY_PANEL_TYPE.TOKEN_EXCHANGE
	buyCallBackFn = callback
	titleIco:setText( getLocalStringValue("E_STR_SHOP_CONFIRM_BUY_TITLE") )
	titleMoneyIcon:setTexture( MoneyIco.Pvp )
	titleMoneyIcon:setScale(0.4)
	totalMoney = PlayerCoreData.getTokenValue()
	titleMoneyTx:setText( toWordsNumber(totalMoney) )

	hasNum = bSData['count'] or 0
	local hasStr = string.format(getLocalString('E_STR_BS_CONFIRM_HAS_NUM_STR') , toWordsNumber(hasNum))
	hasTx:setText(hasStr)
	nameTx:setText(bSData['name'])
	nameTx:setColor(bSData['color'])
	itemIco:setTexture(bSData['icon'])
	descTx:setText(bSData['desc'])
	price = bSData['price'] or 0
	local buyMax = math.floor(totalMoney / price)
	maxCount = buyMax > Limit.MAX_COUNT and Limit.MAX_COUNT or buyMax
	if maxCount == 0 then
		numEditBox:setTextFromInt(0)
	else
		numEditBox:setTextFromInt(1)
	end
	currMoneyIcon:setTexture( MoneyIco.Pvp )
	currMoneyIcon:setScale(0.4)
	currMoneyTx:setTextFromInt( price )
	confirmBtn:setText( getLocalString('E_STR_BAG_SHOP_EXCHANGE_STR') )

	updateBtnStatus()
	updateConfirmBtn()
end