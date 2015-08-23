


function openShopShengwangPanel(pl,cashTx,data,currPanel)
	-- UI
	local shopCellPl = pl
	local cashNumTx1 = cashTx
	local shengwangScene
	local shengwangPanel
	local reputationNumTx
	local cardSv
	local views = {}

	local shengwangConf = GameData:getArrayData('fameshop.dat') -- 黑店
	local vipConf = GameData:getArrayData('vip.dat') -- 黑店
	local refreshTime =  tonumber(GameData:getGlobalValue('FameShopRefreshInterval'))
	local costNum =  tonumber(GameData:getGlobalValue('FameShopRefreshCost'))
	local sellCount =  tonumber(GameData:getGlobalValue('FameShopSellCount'))
	local vipLevel = PlayerCoreData.getPlayerVIP()
	local shengwangData = data
	local timeCDTx

	local function getPos(i)
		local x = 10 + 290 * ((i-1)%3)
		local y = 200 - ((i-1) - (i-1)%3)/3*160
		return ccp(x,y)
	end

	local function getRefreshTimes()
		refreshTimes = 0
		for i,v in ipairs(vipConf) do
			if tonumber(v.Level) == vipLevel then
				refreshTimes = tonumber(v.BlackShopRefresh)
			end
		end
	end
	local function updateShengwangCell()
		local dataTab = {}
		local index = 1
		for k,v in pairs(shengwangData.fame_shop.goods) do
			local tab = {id = tonumber(k),got = v}
			table.insert(dataTab,index)
			dataTab[index] = tab
			index = index + 1
		end
		print(PlayerCore:getFameValue())
		reputationNumTx:setText(PlayerCore:getFameValue())
		for i,v in ipairs(views) do
			cardSv:removeChildReferenceOnly(v)
			if dataTab[i] then
				cardSv:addChildToBottom(views[i])
				v:setPosition(getPos(i))
				local cardImg = tolua.cast(v:getChildByName('card_img') , 'UIImageView')
				local photoIco = tolua.cast(cardImg:getChildByName('photo_ico') , 'UIImageView')
				local numTx = tolua.cast(cardImg:getChildByName('num_tx') , 'UILabel')
				local nameTx = tolua.cast(cardImg:getChildByName('name_tx') , 'UILabel')
				local priceTx = tolua.cast(cardImg:getChildByName('price_tx') , 'UILabel')
				local typeImg = tolua.cast(cardImg:getChildByName('type_img') , 'UIImageView')
				local tab = shengwangConf[dataTab[i].id]
				local award = UserData:getAward(tab.Award1)
				nameTx:setText(award.name)
				nameTx:setColor(award.color)
				numTx:setText(toWordsNumber(tonumber(award.count)))
				priceTx:setText(tab.Price)
				photoIco:setTouchEnable(true)
				photoIco:setTexture(award.icon)
				photoIco:registerScriptTapHandler(function()
					UISvr:showTipsForAward(tab.Award1)
				end)

				local buyBtn = tolua.cast(cardImg:getChildByName('buy_btn') , 'UITextButton')
				buyBtn:registerScriptTapHandler(function ()
					local fame = PlayerCore:getFameValue()
					if fame < tonumber(tab.Price) then
						GameController.showPrompts(getLocalStringValue('E_STR_SHOP_SHENGWANG_DESC'), COLOR_TYPE.RED)
						return
					end
					args = {
						id = tonumber(dataTab[i].id)
					}
					Message.sendPost('buy_fame_shop','activity',json.encode(args),function (jsonData)
						print(jsonData)
						local jsonDic = json.decode(jsonData)
						local awards = jsonDic.data.awards
						if tonumber(jsonDic.code) == 0 then
							UserData.parseAwardJson(json.encode(awards))
							reputationNumTx:setText(PlayerCore:getFameValue())
							cashNumTx1:setText(toWordsNumber(PlayerCoreData.getCashValue()))
							buyBtn:setNormalButtonGray(true)
							buyBtn:setTouchEnable(false)
							buyBtn:setText(getLocalStringValue('E_STR_YET_BUY'))
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_YOUR_GAIN_MATERIAL'),tonumber(award.count),award.name), COLOR_TYPE.GREEN)
						else
							GameController.showPrompts(getLocalStringValue('E_STR_SHOP_DATA_ERR'))
							Message.sendPost('get_fame_shop','activity','{}',function (jsonData)
								print(jsonData)
								local jsonDic = json.decode(jsonData)
								if tonumber(jsonDic.code) == 0 then
									updateTitleBtns(5)
									shengwangData = jsonDic.data
									updateShengwangCell()
								end
							end)
						end
					end)
				end)
				GameController.addButtonSound(buyBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

				local bought = dataTab[i].got
				if bought and bought == 1 then
					buyBtn:setNormalButtonGray(true)
					buyBtn:setTouchEnable(false)
					buyBtn:setText(getLocalStringValue('E_STR_YET_BUY'))
				else
					buyBtn:setNormalButtonGray(false)
					buyBtn:setTouchEnable(true)
					buyBtn:setText(getLocalStringValue('E_STR_BUY'))
				end
			end
		end
		cardSv:scrollToTop()
	end

	local function createShengwangCell()
		views = {}
		for i=1,sellCount do
			local view = createWidgetByName('panel/shop_shengwang_cell.json')
			cardSv:addChildToBottom(view)
			table.insert(views,i)
			views[i] = view
			view:setPosition(getPos(i))
		end
		cardSv:scrollToTop()
		updateShengwangCell()
	end
	local function createShopShengwangPanel()
		if currPanel then
			currPanel:setVisible(false)
		end
		if shengwangPanel then
			shengwangPanel:setVisible(true)
			updateShengwangCell()
		else
			shengwangPanel = createWidgetByName('panel/shop_shengwang_panel.json')
			shopCellPl:addChild(shengwangPanel)
			cardSv = tolua.cast(shengwangPanel:getChildByName('card_sv') , 'UIListView')
			reputationNumTx = tolua.cast(shengwangPanel:getChildByName('reputation_num_tx') , 'UILabel')
			local numTx = tolua.cast(shengwangPanel:getChildByName('num_tx') , 'UILabel')
			numTx:setText(costNum)
			cardSv:setClippingEnable(true)
			freshBtn = tolua.cast(shengwangPanel:getChildByName('fresh_btn') , 'UIButton')
			freshBtn:registerScriptTapHandler(function ()
				local fame = PlayerCore:getFameValue()
				print(fame)
				if fame >= costNum then
					Message.sendPost('refresh_fame_shop','activity','{}',function (jsonData)
						print(jsonData)
						local jsonDic = json.decode(jsonData)
						local awards = jsonDic.data.cost
						if tonumber(jsonDic.code) == 0 then
							shengwangData = jsonDic.data
							UserData.parseAwardJson(json.encode(awards))
							updateShengwangCell()
						else
							GameController.showPrompts(getLocalStringValue('E_STR_SHOP_SHENGWANG_DESC'), COLOR_TYPE.RED)
						end
					end)
				else
					GameController.showPrompts(getLocalStringValue('E_STR_SHOP_SHENGWANG_DESC'), COLOR_TYPE.RED)
				end
			end)
			GameController.addButtonSound(freshBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			createShengwangCell()
		end
	end
	createShopShengwangPanel()
	return shengwangPanel
end