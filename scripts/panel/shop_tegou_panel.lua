


function openShopTegouPanel(pl,cashTx,currPanel)
	-- UI
	local tegouPanel
	local page = 1
	local shopCellPl = pl
	local vipSv
	local cashNumTx1 = cashTx

	local MAX_TITLE_BTNS = 2
	local MAX_TEGOU_CELLS = 12
	local vipConf = GameData:getArrayData('vip.dat')
	local vipLevel = PlayerCoreData.getPlayerVIP()

	local function getPos(i)
		local x = 30 + 293 * ((i-1)%3)
		local y = 368 - ((i-1) - (i-1)%3)/3*330
		return ccp(x,y)
	end

	local function updateTegouCell(i,view)
		cashNumTx = tolua.cast(view:getChildByName('cash_num_tx') , 'UILabel')
		cashNumTx:setText(vipConf[i + 1].CashPrice)
		
		vipNumImg = tolua.cast(view:getChildByName('vip_num_img') , 'UIImageView')
		local str = 'uires/ui_2nd/com/panel/vip/'..i..'.png'
		vipNumImg:setTexture(str)

		goodsNameTx = tolua.cast(view:getChildByName('goods_name_tx') , 'UILabel')
		frameImg = tolua.cast(view:getChildByName('frame_img') , 'UIImageView')
		goodsIco = tolua.cast(frameImg:getChildByName('goods_ico') , 'UIImageView')
		numTx = tolua.cast(frameImg:getChildByName('num_tx') , 'UILabel')
		award = UserData:getAward(vipConf[i + 1].Award1)
		goodsNameTx:setText(award.name)
		goodsNameTx:setColor(award.color)
		numTx:setText(toWordsNumber(tonumber(award.count)))
		goodsIco:setTexture(award.icon)
		goodsIco:registerScriptTapHandler(function()
			UISvr:showTipsForAward(vipConf[i + 1].Award1)
		end)

		local isBought = (PlayerCoreData.getVipBoughtForLevel(i) > 0)
		local boughtTimes = PlayerCoreData.getVipBuyTimes(i)
		if not isBought then
			boughtTimes = boughtTimes + 1
		end

		local buyBtn = tolua.cast(view:getChildByName('buy_btn') , 'UITextButton')
		local vipNow = PlayerCoreData.getPlayerVIP()
		if isBought or vipNow < i then
			buyBtn:setNormalButtonGray(true)
			buyBtn:setTouchEnable(false)
			local strKey = 'E_STR_YET_BUY'
			local lt = vipNow < i
			if lt then 
				strKey = 'LS_NOT_OPEN_YET'
			end
			buyBtn:setText(getLocalStringValue(strKey))
		end

		buyBtn:registerScriptTapHandler(function ()
			local myCash = PlayerCoreData.getCashValue()
			if myCash < tonumber(vipConf[i + 1].CashPrice) then
				GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
				return
			end
			args = {
				vip = i
			}
			Message.sendPost('vip_buy','user',json.encode(args),function (jsonData)
				print(jsonData)
				local jsonDic = json.decode(jsonData)
				local awards = jsonDic.data.awards
				local cash = jsonDic.data.cash
				if tonumber(jsonDic.code) == 0 then
					PlayerCoreData.addCashDelta( cash )
					cashNumTx1:setText(toWordsNumber(PlayerCoreData.getCashValue()))

					UserData.parseAwardJson(json.encode(awards))
					buyBtn:setNormalButtonGray(true)
					buyBtn:setTouchEnable(false)
					buyBtn:setText(getLocalStringValue('E_STR_YET_BUY'))
					GameController.showPrompts(getLocalStringValue('E_STR_BUY_SUCCEED'), COLOR_TYPE.GREEN)
					PlayerCoreData.markVipBoughtForLevel(i)
				end
			end)
		end)
		GameController.addButtonSound(buyBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	end

	local function createTegouCell()
		for i=1,MAX_TEGOU_CELLS do
			local view = createWidgetByName('panel/shop_tegou_cell.json')
			updateTegouCell(i,view)
			vipSv:addChild(view)
			view:setPosition(getPos(i))
		end
		vipSv:scrollToTop()
	end

	local function createShopTegouPanel()
		if currPanel then
			currPanel:setVisible(false)
		end
		if tegouPanel then
			tegouPanel:setVisible(true)
		else
			tegouPanel = createWidgetByName('panel/shop_tegou_panel.json')
			vipSv = tolua.cast(tegouPanel:getChildByName('vip_sv') , 'UIScrollView')
			vipSv:setClippingEnable(true)
			shopCellPl:addChild(tegouPanel)
			createTegouCell()
		end
	end

	createShopTegouPanel()
	return tegouPanel
end