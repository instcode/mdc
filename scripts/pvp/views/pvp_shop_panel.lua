PvpShopPanel = PvpView:new{
	jsonFile = 'panel/pvp_shop_panel.json',
	panelName = 'pvp-shop-in-lua',
	cardSv,
	shopData
}

function PvpShopPanel:updateCells(i,rewardVView)
	materialMap = GameData:getMapData('material.dat')

	cellBg = tolua.cast(rewardVView:getChildByName('pvp_shop_card_img') , 'UIImageView')
	resNameTx = tolua.cast(rewardVView:getChildByName('res_name_tx') , 'UILabel')
	resPhotoIco = tolua.cast(rewardVView:getChildByName('res_photo_ico') , 'UIImageView')
	resIco = tolua.cast(rewardVView:getChildByName('res_ico') , 'UIImageView')
	resNumTx = tolua.cast(rewardVView:getChildByName('res_num_tx') , 'UILabel')
	descTx = tolua.cast(rewardVView:getChildByName('desc_tx') , 'UILabel')
	priceNumTx = tolua.cast(rewardVView:getChildByName('price_num_tx') , 'UILabel')
	exchangeBtn = tolua.cast(rewardVView:getChildByName('exchange_btn') , 'UIButton')
	resNameTx:setPreferredSize(190,1)
	exchangeBtn:registerScriptTapHandler(function ()
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
	        self:updateShop()
		end
		-- 兑换商品
	    local exchangeCallBack = function(shopid,count)
	    	local args = {}
	        args['id'] = i
	        args['num'] = count
	        local s = json.encode(args)
	        Message.sendPost('buy','serverwar', s , doExchangeResponse)
	    end
	    
	    -- 设置兑换界面的物品的各项属性
	    local exchangeAward = UserData:getAward(self.shopData[i].Award1)
	    local exchangeData = {}
		exchangeData.id = exchangeAward.id
	    exchangeData.name = exchangeAward.name
	    exchangeData.color = exchangeAward.color
	    exchangeData.icon = exchangeAward.icon
	    exchangeData.price = self.shopData[i].Price
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
	    openPvpExchangePanel(exchangeData , exchangeCallBack)
	end)

    -- 设置兑换界面的物品的各项属性
    local exchangeAward = UserData:getAward(self.shopData[i].Award1)
    if exchangeAward.type == 'material' then
		descTx:setText(GetTextForCfg(materialMap[tostring(exchangeAward.id)].Desc))
	else
		descTx:setText('')
	end

	resNumTx:setText(toWordsNumber(tonumber(exchangeAward.count)))
	resIco:setTexture(exchangeAward.icon)
	resPhotoIco:registerScriptTapHandler(function()
		UISvr:showTipsForAward(self.shopData[i].Award1)
	end)
	priceNumTx:setText(self.shopData[i].Price)
	
	descTx:setPreferredSize(180,120)
	resNameTx:setText(exchangeAward.name)
	resNameTx:setColor(exchangeAward.color)

end

function PvpShopPanel:updateShop()
	local panel = self.sceneObject:getPanelObj()
	root = panel:GetRawPanel()

	tokenNumTx = tolua.cast(root:getChildByName('token_num_tx') , 'UILabel')
	tokenNumTx:setText(PlayerCoreData.getTokenValue())
end

function PvpShopPanel:createCells()
	self.cardSv:removeAllChildrenAndCleanUp(true)
	for i=1,#self.shopData do
		local rewardVView = createWidgetByName('panel/pvp_shop_card_cell.json')
		self:updateCells(i,rewardVView)
		self.cardSv:addChildToRight(rewardVView)
	end
	self.cardSv:scrollToLeft()
end

function PvpShopPanel:init()
	self:makeData()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('pvpshop_bg_img','pvpshop_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()

		self.cardSv = tolua.cast(root:getChildByName('card_sv') , 'UIScrollView')
		self.cardSv:setClippingEnable(true)
		self.cardSv:setTouchEnable(true)
	    self.cardSv:setIgnoreFocusOnBody(false)
		self.cardSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
		
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		self:updateShop()
		self:createCells()
	end)
end

function PvpShopPanel:makeData()
	self.shopData = {}

	local conf = GameData:getArrayData('shopexchange.dat')
	for _, v in pairs(conf) do
		if v.Key == 'serverwar' then
			table.insert(self.shopData , v)
		end
	end
end

function PvpShopPanel:enter()
	self:init()
	return true
end