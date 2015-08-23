
PawnShop = {}

local orderTab-- = GameData:getArrayData('pawnorder.dat')
local shop-- = GameData:getArrayData('shopmystery.dat')
local exchangeTab-- = GameData:getArrayData('shopexchange.dat')
local materialTab-- = GameData:getArrayData('material.dat')
local materialMap-- = GameData:getMapData('material.dat')
local buyTab

local initPawnshop
local onChickBuyBtn
local onChickShopBtn
local onChickExchangeBtn
local upDateCoinView
local onClickIndent
local initIndent
local setAward
local setExchang
local showIndentPanel
local getAwardConfDataByKey
local getExchangeConfDataByKey
local getMaterialConfDataByKey
local getBuyConfDataByKey
local onChickGotoHeroHome
local onChickGotoBusiness
local onChickSubmit
local onClickRefresh
local refreshBtn
local refreshCashTx

function PawnShop.isActive()
	local orders = UserData:getPawnData().orders
	
	local finished = true
	for _, order in ipairs(orders) do
		if order > 0 then
			finished = false
			break
		end
	end
	return not finished
end
function PawnShop.sendGetRequest()
    print("--- Sending card master update time request ...")
    Message.sendPost('get', 'pawn', '{}', function ( res )
    	cclog(res)
        local resTable = json.decode(res)
        if resTable.code == 0 then
            UserData:setPawnData(json.encode(resTable.data.pawn))
            PawnShop.openPwan()
        end
    end)
end

function PawnShop.enter()
	cclog('--- open pawn shop ---')
    local cardConfig = GameData:getMapData('activities.dat').pawn
    local openLv = tonumber(cardConfig.OpenLevel) --tonumber(GameData:getGlobalValue('CardOpenLevel'))
    local playerLv = PlayerCoreData.getPlayerLevel()

    if playerLv < openLv then
        local msg = string.format(getLocalString('E_STR_TRAIN_LIMIT'), openLv)
        GameController.showMessageBox(msg, MESSAGE_BOX_TYPE.OK)
    else
    	PawnShop.sendGetRequest()
    end
	
end
function PawnShop.openPwan()
	orderTab = GameData:getArrayData('pawnorder.dat')
	shop = GameData:getArrayData('shopmystery.dat')
	exchangeTab = GameData:getArrayData('shopexchange.dat')
	materialTab = GameData:getArrayData('material.dat')
	materialMap = GameData:getMapData('material.dat')
	buyTab = GameData:getArrayData('buy.dat')




	pawnShop = SceneObjEx:createObj('panel/pawnshop_panel.json', 'pawn-shop-lua')
    panel = pawnShop:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('pawnshop_bg_img', 'pawnshop_img')

    panel:registerInitHandler(function()
            local root = panel:GetRawPanel()
            local closeBtn = root:getChildByName('close_btn')
            closeBtn:registerScriptTapHandler(function()
                CUIManager:GetInstance():HideObject(pawnShop, ELF_HIDE.SMART_HIDE)
            end)

            initPawnshop()
    		setExchang()
    		
        end)
        
    panel:registerOnShowHandler(function()
            cclog('here on-show for pawn-shop')
            initIndent()
            upDateCoinView()
        end)

    panel:registerOnHideHandler(function()
            cclog('here on-hide for pawn-shop')
        end)
    -- Show now
    CUIManager:GetInstance():ShowObject(pawnShop, ELF_SHOW.SMART)


end

function initPawnshop()
    local root = panel:GetRawPanel()

	RootImg = root:getChildByName('pawnshop_bg_img')
	MainFrame = RootImg:getChildByName('pawnshop_img')
	TitleIco = MainFrame:getChildByName('title_ico')

    BuyBtn = root:getChildByName('buy_btn')                        
    BuyBtn:registerScriptTapHandler(onChickBuyBtn)

    BtnShop = TitleIco:getChildByName('pawnshop_1_btn')               
    BtnShop:registerScriptTapHandler(onChickShopBtn)

    exchangeBtn = TitleIco:getChildByName('pawnshop_2_btn')   
    exchangeBtn:registerScriptTapHandler(onChickExchangeBtn)

    sellsName = root:getChildByName('sell_name_tx')

    sellsNum = root:getChildByName('sell_res_num_tx')

    sellIco = root:getChildByName('sell_res_ico')

    beforePrice = root:getChildByName('cost_price_num_tx')

    nowPrice = root:getChildByName('now_price_num_tx')

    pawnShopPl = MainFrame:getChildByName('pawnshop_pl')

	exchangePl = MainFrame:getChildByName('exchange_pl')

	jadeNum = TitleIco:getChildByName('jade_num_tx')
	jadeNum = tolua.cast(jadeNum, 'UILabel')


	cashNum = TitleIco:getChildByName('cash_num_tx')
    cashNum = tolua.cast(cashNum, 'UILabel')
    

    exchangeSv = exchangePl:getChildByName("exchange_sv")
    exchangeSv:setIgnoreFocusOnBody(false)
    exchangeSv = tolua.cast(exchangeSv, 'UIScrollView')
	exchangeSv:setClippingEnable(true)
	exchangeSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)

	BuyBgImg = MainFrame:getChildByName("buy_bg_img")

	refreshBtn = BuyBgImg:getChildByName('refresh_btn')
	refreshBtn:registerScriptTapHandler(onClickRefresh)

	refreshCashTx = BuyBgImg:getChildByName('cash_num_tx')
	refreshCashTx = tolua.cast(refreshCashTx, 'UILabel')

    arrIndent = {}

	for  i = 1, 6 do
	
		-- cclog('indent_photo_' .. i + 1 ..'_ico')
		arrIndent[i] = {}
		arrIndent[i].indentPhotoIco = BuyBgImg:getChildByName('indent_photo_' .. i .. '_ico')
		arrIndent[i].indentPhotoIco:setActionTag(i)
        arrIndent[i].indentPhotoIco:registerScriptTapHandler(function ()
		               onClickIndent(arrid[i],i)
				end)
		arrIndent[i].indentIco = arrIndent[i].indentPhotoIco:getChildByName('indent_ico')
		arrIndent[i].indentNameTx = arrIndent[i].indentPhotoIco:getChildByName('indent_name_tx')
		arrIndent[i].limitLvTx = arrIndent[i].indentPhotoIco:getChildByName('limit_num_tx')
		arrIndent[i].lockIco = arrIndent[i].indentPhotoIco:getChildByName('lock_ico')

		if i == 1 then
			limit = GameData:getGlobalValue( "FirstPosOpenLev" )	
		elseif i == 2 then
			limit = GameData:getGlobalValue( "SecondPosOpenLev" )	
		elseif i == 3 then
		 	limit = GameData:getGlobalValue( "ThirdPosOpenLev" )	
        elseif i == 4 then
		    limit = GameData:getGlobalValue( "FourthPosOpenLev" )	
	    elseif i == 5 then
	    	limit = GameData:getGlobalValue( "FifthPosOpenLev"  )
	    elseif i == 6 then
	    	limit = GameData:getGlobalValue( "SixthPosOpenLev"  )
	    end
		arrIndent[i].limitLvTx = tolua.cast(arrIndent[i].limitLvTx, 'UILabel')
		arrIndent[i].limitLvTx:setText(tostring(limit))
		arrIndent[i].limitLvIco = arrIndent[i].indentPhotoIco:getChildByName("open_lv_ico")
	end


	upDateCoinView()
	initIndent()
	setAward()
	onChickShopBtn()
end

function onChickBuyBtn()
	local buyId = UserData:getPawnData().buy
	local price = getAwardConfDataByKey( buyId ).Price

	if PlayerCoreData.getCashValue() < tonumber(price) then
		
		GameController.showPrompts( string.format(getLocalStringValue('E_STR_CASH_NOT_ENOUGH')),COLOR_TYPE.RED )
		return
	end

	local function updatePawnShopPanel()
		-- 买完后设置按钮不可点击 文字变为已购买
		BuyBtn:setPressState(WidgetStateDisabled)
		BuyBtn:setText(getLocalStringValue('E_STR_YET_BUY'))
		BuyBtn:setTouchEnable(false)
		-- 更新金币
		cashNum:setText(toWordsNumber(PlayerCoreData:getCashValue()))
	end

	local function buyResponse( jsonData )
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end
		local data = jsonDic['data']
		UserData.parseAwardJson(json.encode(data['awards']))

		local buyId = UserData:getPawnData().buy
		local awardStr = getAwardConfDataByKey( buyId ).Award1
		local award = UserData:getAward( awardStr )
		local pawnData = UserData:getPawnData()
		pawnData['buyed'] = 1
		UserData:setPawnData( json.encode(pawnData) )	
		--弹出奖励界面
		genOneAwardPanel(award , updatePawnShopPanel)	
	end
	Message.sendPost('buy','pawn','{}',buyResponse)
end

function onChickShopBtn()
	-- body
	pawnShopPl:setVisible(true)
	exchangePl:setVisible(false)
	BtnShop:setPressState(WidgetStateSelected);
	BtnShop:setTouchEnable(false);

	exchangeBtn:setPressState(WidgetStateNormal);
	exchangeBtn:setTouchEnable(true);
	-- cclog('chick shop btn')
end

function onChickExchangeBtn()
    -- cclog('chick exchange btn')
    pawnShopPl:setVisible(false)
	exchangePl:setVisible(true)
	exchangeBtn:setPressState(WidgetStateSelected);
	exchangeBtn:setTouchEnable(false);

	BtnShop:setPressState(WidgetStateNormal);
	BtnShop:setTouchEnable(true);
end

function sendRefreshRequest()
    Message.sendPost('refresh', 'pawn', '{}', function ( res )
        local resTable = json.decode(res)
        if resTable.code == 0 then
        	cclog(res)
            UserData:setPawnData(json.encode(resTable.data.pawn))
            PlayerCoreData.addCashDelta(resTable.data.cash)
            initIndent()
            upDateCoinView()
        end
    end)
end

function onClickRefresh()
	local times = UserData:getPawnData().refresh_times
	local cash = GameData:getGlobalValue('PawnOderBase') 
	+ GameData:getGlobalValue('PawnOderAdd') 
	 * math.floor((times) / (GameData:getGlobalValue('PawnOderGap')))
	if PlayerCoreData.getCashValue() < cash then
			local msg = getLocalString('E_STR_PAWNSHOP_NOT_ENOUGH_CASH')
			GameController.showMessageBox(msg,MESSAGE_BOX_TYPE.OK_CANCEL, function ()
 				genCashBoard()
			end)
	else
		sendRefreshRequest()
	end

end

function upDateCoinView(v)
	print('test')
	cashNum:setText(toWordsNumber(PlayerCoreData:getCashValue()))
	
	jadeNum:setText(toWordsNumber(PlayerCoreData:getCoinValue()))

end

function onClickIndent(v,i)
    showIndentPanel(v,i)
end

function initIndent()

	-- printall(UserData:getPawnData())
	arrid = {}
	local index = 0
	local orangeTimes = 0
	local sumTimes = 0
	local times = UserData:getPawnData().refresh_times
	local cash = GameData:getGlobalValue('PawnOderBase') 
	+ GameData:getGlobalValue('PawnOderAdd') 
	 * math.floor((times) / (GameData:getGlobalValue('PawnOderGap')))
	refreshCashTx:setTextFromInt(cash)
    for  i = 1, 6 do
    arrid[i] =  UserData:getPawnData().orders[i]

       if arrid[i] == 0 then
       arrIndent[i].indentPhotoIco:setTouchEnable(false)
       arrIndent[i].indentPhotoIco = tolua.cast(arrIndent[i].indentPhotoIco, 'UIImageView')
       arrIndent[i].indentPhotoIco:setGray()
       arrIndent[i].indentIco = tolua.cast(arrIndent[i].indentIco, 'UIImageView')
       arrIndent[i].indentIco:setTexture('uires/ui_2nd/image/item/item27.png')
       arrIndent[i].indentIco:setGray()
       arrIndent[i].limitLvTx:setVisible(true)
       arrIndent[i].limitLvIco:setVisible(true)
       arrIndent[i].indentNameTx = tolua.cast(arrIndent[i].indentNameTx, 'UILabel')
       arrIndent[i].indentNameTx:setColor(ccc3(255,255,255))
       --arrIndent[i].lockIco:setVisible(true)
       local str = string.format(getLocalStringValue("E_STR_INDENT"),i)	
	   arrIndent[i].indentNameTx:setText(str)
 
	   elseif arrid[i] == -1 then
	   index = index + 1
       arrIndent[i].indentPhotoIco:setTouchEnable(false)
       arrIndent[i].indentPhotoIco = tolua.cast(arrIndent[i].indentPhotoIco, 'UIImageView')
       arrIndent[i].indentPhotoIco:setGray()
       arrIndent[i].indentIco = tolua.cast(arrIndent[i].indentIco, 'UIImageView')
       arrIndent[i].indentIco:setTexture('uires/ui_2nd/image/item/item27.png')
       arrIndent[i].indentIco:setGray()
       arrIndent[i].limitLvTx:setVisible(false)
       arrIndent[i].limitLvIco:setVisible(false)
       arrIndent[i].indentNameTx = tolua.cast(arrIndent[i].indentNameTx, 'UILabel')
       arrIndent[i].indentNameTx:setColor(ccc3(255,255,255))
       --arrIndent[i].lockIco:setVisible(false)
       local str = string.format(getLocalStringValue("E_STR_FINISH"))	
	   arrIndent[i].indentNameTx:setText(str)

	   else 
	   	sumTimes = sumTimes + 1
	   	arrIndent[i].indentPhotoIco:setTouchEnable(true)
	   	arrIndent[i].indentPhotoIco = tolua.cast(arrIndent[i].indentPhotoIco, 'UIImageView')
	   	arrIndent[i].indentPhotoIco:setNormal()
	   	arrIndent[i].indentIco = tolua.cast(arrIndent[i].indentIco, 'UIImageView')
		arrIndent[i].indentIco:setNormal()
		arrIndent[i].limitLvTx:setVisible(false)
		arrIndent[i].limitLvIco:setVisible(false)
		--arrIndent[i].lockIco:setVisible(false)
		local str = string.format(getLocalStringValue("E_STR_INDENT"),i)	
		arrIndent[i].indentNameTx = tolua.cast(arrIndent[i].indentNameTx, 'UILabel')
		arrIndent[i].indentNameTx:setText(str)

		local quantity = orderTab[arrid[i]].Quantity
		if quantity == 'blue' then
		 	arrIndent[i].indentIco:setTexture("uires/ui_2nd/image/item/item29.png")
			arrIndent[i].indentNameTx:setColor(COLOR_TYPE.BLUE)
		
		elseif quantity == 'purple' then
			arrIndent[i].indentIco:setTexture("uires/ui_2nd/image/item/item31.png")
			arrIndent[i].indentNameTx:setColor(COLOR_TYPE.PURPLE)
		
		elseif quantity == 'orange' then
			orangeTimes = orangeTimes + 1
			arrIndent[i].indentIco:setTexture("uires/ui_2nd/image/item/item33.png")
			arrIndent[i].indentNameTx:setColor(COLOR_TYPE.ORANGE)
		end

	   end
	end
	if index >= 6 or sumTimes == orangeTimes then
		refreshBtn:disable()
	else
		refreshBtn:active()
	end
end

function setAward()

	local num = UserData:getPawnData().buy
	-- printall(UserData:getPawnData())
	local award = getAwardConfDataByKey(num).Award1
    --printall(award)
    local awardData = {}
	awardData = UserData:getAward(award)
	-- printall(awardData)
	sellIco = tolua.cast(sellIco, 'UIImageView')
	sellIco:setTexture(awardData.icon)
	sellIco:setTouchEnable(true)
	sellIco:registerScriptTapHandler(function ()
		local awardStr = award
		UISvr:showTipsForAward(awardStr)
	end)

	sellsName = tolua.cast(sellsName, 'UILabel')
	sellsName:setText(awardData.name)

	sellsNum = tolua.cast(sellsNum, 'UILabel')
	sellsNum:setTextFromInt(awardData.count)

	beforePrice = tolua.cast(beforePrice, 'UILabel')
	beforePrice:setTextFromInt(tonumber(getAwardConfDataByKey( num ).PriceText))

    nowPrice = tolua.cast(nowPrice, 'UILabel')
    nowPrice:setTextFromInt(tonumber(getAwardConfDataByKey( num ).Price))

    if UserData:getPawnData().buyed == 1 then
		BuyBtn:setPressState(WidgetStateDisabled)
		BuyBtn = tolua.cast(BuyBtn, 'UITextButton')
		BuyBtn:setText(getLocalStringValue("E_STR_YET_BUY"))
		BuyBtn:setTouchEnable(false)
    else   
    	BuyBtn:setPressState(WidgetStateNormal)
    	BuyBtn = tolua.cast(BuyBtn, 'UITextButton')
		BuyBtn:setText(getLocalStringValue("E_STR_BUY"))
		BuyBtn:setTouchEnable(true)
	end
end

function setExchang()
	exchangeSv:removeAllChildrenAndCleanUp(true)
	
    local pawnTab = {}
     pawnTab = getExchangeConfDataByKey('pawn')
     
    local pawnTabSize = table.getn(pawnTab)
    for i=1,pawnTabSize do
    	exchangePanel = createWidgetByName('panel/pawn_exchange_panel.json')
		exchangePanel:setPosition(ccp((i - 1) * 214, 0))
		exchangeSv:addChild(exchangePanel)
		local RootImg = exchangePanel:getChildByName("exchange_img")
        local ResBgIco = RootImg:getChildByName("res_photo_ico")
        local ResNameTx = RootImg:getChildByName("res_name_tx")
        local ResIco = ResBgIco:getChildByName("res_ico")
        local Desc = tolua.cast(RootImg:getChildByName("desc_tx"), 'UILabel')
        Desc:setPreferredSize(180,120)
        local ResNumTx = ResBgIco:getChildByName("res_num_tx")
        local PriceNumTx = RootImg:getChildByName("price_num_tx")
        local ExchangeBtn = RootImg:getChildByName("exchange_btn")
        ExchangeBtn:registerScriptTapHandler(function()
        	-- 兑换的回调
            local doExchangeResponse = function(jsonData)
            	print(jsonData)
		        local jsonDic = json.decode(jsonData)
		        if jsonDic['code'] ~= 0 then
		            cclog('request error : ' .. jsonDic['desc'])
		            return
		        end

		        local data = jsonDic['data']
		        if not data then return end

		        local awards = data['awards']
		        local awardStr = json.encode(awards)
		        UserData.parseAwardJson(awardStr)

		        GameController.showPrompts( getLocalStringValue('E_STR_EXCHANGE_SUCCEED'),COLOR_TYPE.GREEN )
		        upDateCoinView()
        	end
        	-- 兑换商品
            local exchangeCallBack = function(shopid,count)
            	local args = {}
		        args['id'] = i
		        args['num'] = count
		        local s = json.encode(args)
		        Message.sendPost('exchange','pawn', s , doExchangeResponse)
            end
            
            -- 设置兑换界面的物品的各项属性
            local exchangeAward = UserData:getAward(pawnTab[i].Award1)
            local exchangeData = {}
        	exchangeData.id = exchangeAward.id
            exchangeData.name = exchangeAward.name
            exchangeData.color = exchangeAward.color
            exchangeData.icon = exchangeAward.icon
            exchangeData.price = pawnTab[i].Price
        	if exchangeAward.type == 'material' then
        		local materialAward = Material:findById(exchangeAward.id)
        		exchangeData.count = materialAward:getCount()
 				exchangeData.desc = GetTextForCfg(materialMap[tostring(exchangeAward.id)].Desc)
        	elseif exchangeAward.type == 'user' then
        		if exchangeAward.id == 'food' then
        			exchangeData.count = PlayerCoreData.getFoodValue()
        		elseif exchangeAward.id == 'gold' then
        			exchangeData.count = PlayerCoreData.getGoldValue()
        		end
        		exchangeData.desc = ''
        	end
        	-- 打开兑换界面
            openPawnExchangePanel(exchangeData , exchangeCallBack)
        end)
		local award = pawnTab[i].Award1
	    -- printall(award)
	    local awardData = {}
		awardData = UserData:getAward(award)
		-- printall(awardData)

		if  tonumber(awardData.id) == nil then
		    ResNameTx = tolua.cast(ResNameTx, 'UILabel')
		    ResNameTx:setText(awardData.name)
		    ResNameTx:setColor(awardData.color)

		    ResIco = tolua.cast(ResIco, 'UIImageView')
		    ResIco:setTexture(awardData.icon)
		    ResIco:setTouchEnable(true)
		    ResIco:registerScriptTapHandler(function ()
		    	local awardStr = pawnTab[i].Award1
		    	UISvr:showTipsForAward(awardStr)
		    end)

		    ResNumTx = tolua.cast(ResNumTx, 'UILabel')
		    ResNumTx:setText(tostring(awardData.count))

		    --Desc = tolua.cast(Desc, 'UITextArea')
		    Desc:setText(getLocalStringValue("E_STR_FOOD_DESC"))

		    PriceNumTx = tolua.cast(PriceNumTx, 'UILabel')
		    PriceNumTx:setText(pawnTab[i].Price)

	    else
	    	ResNameTx = tolua.cast(ResNameTx, 'UILabel')
	    	ResNameTx:setPreferredSize(160,1)
		    ResNameTx:setText(PlayerCoreData.getMaterialName(tonumber(awardData.id)))
		    ResNameTx:setColor(awardData.color)
		    
	    	ResIco = tolua.cast(ResIco, 'UIImageView')
		    ResIco:setTexture(PlayerCoreData.getMaterialIco(tonumber(awardData.id)))
		    ResIco:setTouchEnable(true)
		    ResIco:registerScriptTapHandler(function ()
		    	local awardStr = pawnTab[i].Award1
		    	UISvr:showTipsForAward(awardStr)
		    end)

		    ResNumTx = tolua.cast(ResNumTx, 'UILabel')
		    ResNumTx:setText(tostring(awardData.count))

		    PriceNumTx = tolua.cast(PriceNumTx, 'UILabel')

		    PriceNumTx:setText(pawnTab[i].Price)

		    --Desc = tolua.cast(Desc, 'UITextArea')
		   
		    Desc:setText(GetTextForCfg(getMaterialConfDataByKey(awardData.id).Desc))
	    end

    end   
end

function showIndentPanel(v,i)
	indentPanel = SceneObjEx:createObj('panel/indent_panel.json', 'indent-panel-lua')
    local indentObj = indentPanel:getPanelObj()        --# This is a BasePanelEx object
    indentObj:setAdaptInfo('indent_bg_img', 'indent_img')

    indentObj:registerInitHandler(function()
            local root = indentObj:GetRawPanel()
            local closeBtn = root:getChildByName('close_btn')
            closeBtn:registerScriptTapHandler(function()
                CUIManager:GetInstance():HideObject(indentPanel, ELF_HIDE.SMART_HIDE)
            end)
 local root = indentObj:GetRawPanel()
		    local pRootImg = root:getChildByName("indent_bg_img")
			local pMainFrame = pRootImg:getChildByName("indent_img")
			local pIndentBg = pMainFrame:getChildByName("indent_name_bg_ico")
			local pIndentName = pIndentBg:getChildByName("indent_name_ico")

			local pNeedBgImg = pMainFrame:getChildByName("need_bg_ico")
		    local pNeedName_1 = pNeedBgImg:getChildByName("need_res_1_tx")
		    local pNeedNum_1 = pNeedBgImg:getChildByName("need_num_1_tx")

		    local pNeedName_2 = pNeedBgImg:getChildByName("need_res_2_tx")
		    local pNeedNum_2 = pNeedBgImg:getChildByName("need_num_2_tx")
		    local pAwardBg = pMainFrame:getChildByName("award_bg_ico")
		     
		     m_pAward = {}
		    for i = 1 , 2   do  
		        m_pAward[i] = {}                        
				local str = string.format("award_photo_%d_ico",i)
				local pAwardPhoto = pAwardBg:getChildByName(str)
				m_pAward[i].awardIco = pAwardPhoto:getChildByName("award_ico")
				m_pAward[i].awardNameTx = pAwardPhoto:getChildByName("award_name_tx")
		        m_pAward[i].awardNumTx = pAwardPhoto:getChildByName("award_num_tx")
			end 

			m_pGotoHeroHome = pNeedBgImg:getChildByName("goto_1_btn")
			m_pGotoHeroHome:registerScriptTapHandler(function()
		                onChickGotoHeroHome(v)
		            end)
			m_pGotoBusiness = pNeedBgImg:getChildByName("goto_2_btn")
			m_pGotoBusiness:registerScriptTapHandler(function()
		                onChickGotoBusiness(v,i)
		            end)
			m_pSubmitBtn = pMainFrame:getChildByName("submit_btn")
			m_pSubmitBtn:registerScriptTapHandler(function()
		                onChickSubmit(i,v)
		            end)

            local ord = orderTab[v]
			local awardData = {}
			awardData = UserData:getAward(ord.Award1)
			pNeedName_1 = tolua.cast(pNeedName_1, 'UILabel')
			pNeedName_1:setText(awardData.name)
			pNeedName_1:setColor(awardData.color)

			pNeedNum_1 = tolua.cast(pNeedNum_1, 'UILabel')
			pNeedNum_1:setText(0 - awardData.count)
			local gold = PlayerCoreData.getGoldValue()
			if gold < 0 - awardData.count then
				pNeedNum_1:setColor(COLOR_TYPE.RED)
			else
				pNeedNum_1:setColor(COLOR_TYPE.GREEN)
			end
			awardData1 = UserData:getAward(ord.Award2)
			
			pNeedName_2 = tolua.cast(pNeedName_2, 'UILabel')
			pNeedName_2:setText(awardData1.name)
			pNeedName_2:setColor(awardData1.color)
		    
		    sum2 = PlayerCoreData.getPawnCountById(awardData1.id)
			-- printall(sum2)
		    need2 = math.abs(awardData1.count)
		    str = string.format("%d/%d",sum2,need2)
			pNeedNum_2 = tolua.cast(pNeedNum_2, 'UILabel')
			pNeedNum_2:setText(str)
			if sum2 < need2 then
				pNeedNum_2:setColor(COLOR_TYPE.RED)
			else
				pNeedNum_2:setColor(COLOR_TYPE.GREEN)
			end
			str = string.format("uires/ui_2nd/com/panel/pawnshop/indent_%d.png",i)
			pIndentName = tolua.cast(pIndentName, 'UIImageView')

			pIndentName:setTexture(str);
			local strArr = {}
			table.insert(strArr, ord.Award3)
			table.insert(strArr, ord.Award4)

			for i, _ in ipairs(strArr) do
				awardData = UserData:getAward(strArr[i])
				m_pAward[i].awardIco = tolua.cast(m_pAward[i].awardIco, 'UIImageView')
				m_pAward[i].awardIco:setTexture(awardData.icon)
				m_pAward[i].awardIco:setTouchEnable(true)
				m_pAward[i].awardIco:registerScriptTapHandler(function()
                    local awardStr = strArr[i]
                    UISvr:showTipsForAward(awardStr)
                end)
				m_pAward[i].awardNameTx = tolua.cast(m_pAward[i].awardNameTx, 'UILabel')
		        m_pAward[i].awardNameTx:setPreferredSize(120,1)
				m_pAward[i].awardNameTx:setText(awardData.name)
				m_pAward[i].awardNameTx:setColor(awardData.color)
				m_pAward[i].awardNumTx = tolua.cast(m_pAward[i].awardNumTx, 'UILabel')
				m_pAward[i].awardNumTx:setText(awardData.count)
			end
           
        end)
        

	indentObj:registerOnShowHandler(function()
            cclog('here on-show for pawn-shop')
            local root = indentObj:GetRawPanel()
		    local pRootImg = root:getChildByName("indent_bg_img")
			local pMainFrame = pRootImg:getChildByName("indent_img")
			local pIndentBg = pMainFrame:getChildByName("indent_name_bg_ico")
			local pIndentName = pIndentBg:getChildByName("indent_name_ico")

			local pNeedBgImg = pMainFrame:getChildByName("need_bg_ico")
		    local pNeedName_1 = pNeedBgImg:getChildByName("need_res_1_tx")
		    local pNeedNum_1 = pNeedBgImg:getChildByName("need_num_1_tx")

		    local pNeedName_2 = pNeedBgImg:getChildByName("need_res_2_tx")
		    local pNeedNum_2 = pNeedBgImg:getChildByName("need_num_2_tx")
		    local pAwardBg = pMainFrame:getChildByName("award_bg_ico")
		     
		     m_pAward = {}
		    for i = 1 , 2   do  
		        m_pAward[i] = {}                        
				local str = string.format("award_photo_%d_ico",i)
				local pAwardPhoto = pAwardBg:getChildByName(str)
				m_pAward[i].awardIco = pAwardPhoto:getChildByName("award_ico")
				m_pAward[i].awardNameTx = pAwardPhoto:getChildByName("award_name_tx")
		        m_pAward[i].awardNumTx = pAwardPhoto:getChildByName("award_num_tx")
			end 

			m_pGotoHeroHome = pNeedBgImg:getChildByName("goto_1_btn")
			m_pGotoHeroHome:registerScriptTapHandler(function()
		                -- onChickGotoHeroHome(v)
		                GoldMan2:GetInst():OpenSvPanel()
		            end)
			m_pGotoBusiness = pNeedBgImg:getChildByName("goto_2_btn")
			m_pGotoBusiness:registerScriptTapHandler(function()
		                onChickGotoBusiness(v,i)
		            end)
			m_pSubmitBtn = pMainFrame:getChildByName("submit_btn")
			m_pSubmitBtn:registerScriptTapHandler(function()
		                onChickSubmit(i,v)
		            end)

            local ord = orderTab[v]
			local awardData = {}
			awardData = UserData:getAward(ord.Award1)
			-- printall(awardData)
			pNeedName_1 = tolua.cast(pNeedName_1, 'UILabel')
			pNeedName_1:setText(awardData.name)
			pNeedName_1:setColor(awardData.color)

			pNeedNum_1 = tolua.cast(pNeedNum_1, 'UILabel')
			pNeedNum_1:setText(0 - awardData.count)
			local gold = PlayerCoreData.getGoldValue()
			if gold < 0 - awardData.count then
				pNeedNum_1:setColor(COLOR_TYPE.RED)
			else
				pNeedNum_1:setColor(COLOR_TYPE.GREEN)
			end
			awardData1 = UserData:getAward(ord.Award2)
			
			pNeedName_2 = tolua.cast(pNeedName_2, 'UILabel')
			pNeedName_2:setText(awardData1.name)
			pNeedName_2:setColor(awardData1.color)
		    
		    sum2 = PlayerCoreData.getPawnCountById(awardData1.id)
			-- printall(sum2)
		    need2 = math.abs(awardData1.count)
		    str = string.format("%d/%d",sum2,need2)
			pNeedNum_2 = tolua.cast(pNeedNum_2, 'UILabel')
			pNeedNum_2:setText(str)
			if sum2 < need2 then
				pNeedNum_2:setColor(COLOR_TYPE.RED)
			else
				pNeedNum_2:setColor(COLOR_TYPE.GREEN)
			end
			str = string.format("uires/ui_2nd/com/panel/pawnshop/indent_%d.png",i)
			pIndentName = tolua.cast(pIndentName, 'UIImageView')

			pIndentName:setTexture(str);
			local strArr = {}
			table.insert(strArr, ord.Award3)
			table.insert(strArr, ord.Award4)

			for i, _ in ipairs(strArr) do
				awardData = UserData:getAward(strArr[i])
				m_pAward[i].awardIco = tolua.cast(m_pAward[i].awardIco, 'UIImageView')
				m_pAward[i].awardIco:setTexture(awardData.icon)
				m_pAward[i].awardNameTx = tolua.cast(m_pAward[i].awardNameTx, 'UILabel')
		        m_pAward[i].awardNameTx:setPreferredSize(120,1)
				m_pAward[i].awardNameTx:setText(awardData.name)
				m_pAward[i].awardNameTx:setColor(awardData.color)
				m_pAward[i].awardNumTx = tolua.cast(m_pAward[i].awardNumTx, 'UILabel')
				m_pAward[i].awardNumTx:setText(awardData.count)
			end
        end)


    indentObj:registerOnHideHandler(function()
            cclog('here on-hide for pawn-shop')
        end)


    CUIManager:GetInstance():ShowObject(indentPanel, ELF_SHOW.SMART)
end

function getAwardConfDataByKey( key )  
	for k , v in pairs (shop)   do                      
		if(tonumber(v['Id']) == tonumber(key)) then 
			return v
		end
	end
	return nil
end

function getExchangeConfDataByKey( key )

local pawnTab = {}
	i = 1
	for k , v in pairs (exchangeTab) do
		if(v['Key'] == key) then  
			pawnTab[i] = v
			i = i + 1;
		end
	end
	return pawnTab
end

function getMaterialConfDataByKey( key )
	for k , v in pairs (materialTab)   do                          
		if(v['Id'] == key) then 
			return v
		end
	end
	return nil
end

function getBuyConfDataByKey(key)
	for k , v in pairs (buyTab)   do                          
		if(v['Id'] == key) then 
			return v
		end
	end
	return nil
end	

function onChickGotoHeroHome(v)
	local bid = 0

	local ord = orderTab[v]

	if ord then
		bid = ord['DropId']
		 cclog('bid ========= ' .. bid)
		if CBattleAPI:getHeroStatusByID(bid) <= 0 then
			GameController.showPrompts(GetTextForCfg(ord['Hint']) , COLOR_TYPE.RED)
		else
			CCopySceneMgr:getInst():showAltar(tonumber(bid))
		end
	end
end

function onChickGotoBusiness(v,i)
	CBusinessMgr:GetInst():setEnterIntoValue(0)
	CPawnShopMgr:GetInst():SetIndent(v)
	CPawnShopMgr:GetInst():SetSite(i)
	CBusinessMgr:GetInst():ShowPawnBusinessPanel()
end

function onChickSubmit(site,id)

	local ord = orderTab[id]
	local awardData = {}
	awardData = UserData:getAward(ord.Award1)
	local gold = PlayerCoreData.getGoldValue()
		if gold < 0 - awardData.count then
				
			str = getLocalStringValue("E_STR_NOT_ENOUGH_GOLD")
		
		    GameController.showPrompts( str,COLOR_TYPE.RED )
		
		elseif sum2 < need2 then
		
			awardData = UserData:getAward(ord.Award2)
			
			str = string.format(getLocalStringValue("E_EXCHANGE_MATERIAL_NO_ENOUGH"),awardData.name)
		

		    GameController.showPrompts( str,COLOR_TYPE.RED )
		
		else
			local function SubmitResponse( jsonData )
		    cclog(jsonData)
		    local jsonDic = json.decode(jsonData)
		    if jsonDic['code'] ~= 0 then
			   cclog('request error : ' .. jsonDic['desc'])
			   return
		    end
		    local data = jsonDic['data']
		    local award = data['awards']

           
		    UserData.parseAwardJson(json.encode(data['awards']))
		    local leagth = #data['awards']
		    local mesgBox = {} 
		    for i = 1 ,leagth  do 
		    	
		     
             awardData = UserData:getAward(UserData.makeAwardStr(award[i]))
            
             	if tonumber(awardData.id) == nil then
             		str = string.format(getLocalStringValue("E_STR_GAIN_RES"),awardData.count,awardData.name)
             	else
             		str = string.format(getLocalStringValue("E_STR_GAIN_MATERIAL"),awardData.name,awardData.count)
             	end
                if  awardData.count > 0 then
             	    table.insert(mesgBox , str)
             	end
            	
            initIndent()
    
		     UserData:setPawnData(json.encode(data['pawn']))
		     CUIManager:GetInstance():HideObject(indentPanel, ELF_HIDE.SMART_HIDE)
            
		    end
            GameController.showPrompts(mesgBox, COLOR_TYPE.GREEN )


	       end
	       local strId =  string.format("{\"id\":%d}",site - 1)
	
	       Message.sendPost('commit','pawn',strId,SubmitResponse)
	       
		end	
end
