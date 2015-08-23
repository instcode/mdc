


function openShopTuangouPanel(pl,cashTx,data,currPanel)
	-- UI
	local shopCellPl = pl
	local tuangouPanel = nil
	local cashNumTx1 = cashTx
	local returnScene
	local returnPanel

	local tuangouGoodsConf = GameData:getArrayData('groupbuying.dat')
	local tuangouData = data
	local returnData = nil
	local maxReturnIndex = 0
	local currPage
	local currGotArr = {}
	local currTabCount = 0
	local timeCDTx

	local function setCurrReturnTabStatus()
		for i=1,maxReturnIndex do
			local index = returnData.bought_ids[i]
			if returnData[tostring(index)] then
				local got = returnData[tostring(index)].got
				if got and tonumber(got) == 0 then
					returnData[tostring(index)].got = 1
				end
			end
		end
	end

	local function getCurrReturnTab()
		currTabCount = 0
		currGotArr = {}
		for i=1,maxReturnIndex do
			local index = returnData.bought_ids[i]
			if returnData[tostring(index)] then
				local got = returnData[tostring(index)].got
				if got and tonumber(got) == 0 then
					currTabCount = currTabCount + 1
					table.insert(currGotArr,currTabCount)
					currGotArr[currTabCount] = index
				end
			end
		end
	end

	local function getCurrReturn()
		for i=1,maxReturnIndex do
			local index = returnData.bought_ids[i]
			if returnData[tostring(index)] then
				local got = returnData[tostring(index)].got
				if got and tonumber(got) == 0 then
					return true
				end
			end
		end
		return false
	end

	local function updateReturnPanel()
		root = returnPanel:GetRawPanel()
		local maxPage = ((maxReturnIndex-1) - (maxReturnIndex-1)%3)/3 + 1
		local leftBtn = tolua.cast(root:getChildByName('left_btn') , 'UIButton')
		leftBtn:setNormalButtonGray(currPage == 1)
		leftBtn:setTouchEnable(currPage ~= 1)
		local rightBtn = tolua.cast(root:getChildByName('right_btn') , 'UIButton')
		rightBtn:setNormalButtonGray(currPage == maxPage)
		rightBtn:setTouchEnable(currPage ~= maxPage)

		local pageNumTx = tolua.cast(root:getChildByName('page_num_tx') , 'UILabel')
		pageNumTx:setText(currPage..'/'..maxPage)
		for i=1,3 do
			local str = 'card_'..i..'_img'
			local cardImg = tolua.cast(root:getChildByName(str) , 'UIImageView')
			local frameImg = tolua.cast(cardImg:getChildByName('frame_img') , 'UIImageView')
			local awardIco = tolua.cast(frameImg:getChildByName('award_ico') , 'UIImageView')
			local numTx = tolua.cast(frameImg:getChildByName('num_tx') , 'UILabel')
			local infoBgImg = tolua.cast(cardImg:getChildByName('info_1_bg_img') , 'UIImageView')
			local timeTx = tolua.cast(infoBgImg:getChildByName('time_tx') , 'UILabel')
			local infoTx = tolua.cast(infoBgImg:getChildByName('info_3_tx') , 'UILabel')
			local infoBgImg1 = tolua.cast(cardImg:getChildByName('info_2_bg_img') , 'UIImageView')
			local priceTx = tolua.cast(infoBgImg1:getChildByName('price_tx') , 'UILabel')
			local numTx1 = tolua.cast(infoBgImg1:getChildByName('num_tx') , 'UILabel')
			local getBtn = tolua.cast(cardImg:getChildByName('get_btn') , 'UITextButton')
			local index = returnData.bought_ids[i + ( currPage- 1)*3]
			if returnData[tostring(index)] then
				cardImg:setVisible(true)
				local id = returnData[tostring(index)].item_id
				local count = returnData[tostring(index)].count
				local date = returnData[tostring(index)].date
				local tab = tuangouGoodsConf[tonumber(id)]
				local got = returnData[tostring(index)].got
				local cash = returnData[tostring(index)].ret_cash

				local dateTab = string.split(date , '-')
				local length = #dateTab
				if length == 3 then
					-- time = UserData:convertTime( 2 , date )
					-- local now = os.date('*t', tonumber(time))
					timeTx:setText(string.format(getLocalStringValue('E_STR_SHOP_DESC5'),dateTab[2],dateTab[3]))
				else
					timeTx:setText('')
				end

				infoTx:setText(cash)
				priceTx:setText(tab.Cash)
				numTx1:setText(count)

				award = UserData:getAward(tab.Award1)
				numTx:setText(toWordsNumber(tonumber(award.count)))
				awardIco:setTexture(award.icon)
				awardIco:registerScriptTapHandler(function()
					UISvr:showTipsForAward(tab.Award1)
				end)

				if not got then
					getBtn:setNormalButtonGray(true)
					getBtn:setTouchEnable(false)
					getBtn:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
				elseif tonumber(got) == 0 then
					getBtn:setNormalButtonGray(false)
					getBtn:setTouchEnable(true)
					getBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
				elseif tonumber(got) == 1 then
					getBtn:setNormalButtonGray(true)
					getBtn:setTouchEnable(false)
					getBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
				end
				getBtn:registerScriptTapHandler(function()
					local tab = {}
					table.insert(tab,1)
					tab[1] = index
					args = {
						buying_ids = tab
					}
					Message.sendPost('return_group_buying','activity',json.encode(args),function (jsonData)
						print(jsonData)
						local jsonDic = json.decode(jsonData)
						local cash = jsonDic.data.cash
						if tonumber(jsonDic.code) == 0 then
							PlayerCoreData.addCashDelta( cash )
							cashNumTx1:setText(toWordsNumber(PlayerCoreData.getCashValue()))
							returnData[tostring(index)].got = 1
							getBtn:setNormalButtonGray(true)
							getBtn:setTouchEnable(false)
							getBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_GAIN_CASH_DESC'),tonumber(cash)), COLOR_TYPE.WHITE)
						end
					end)
				end)
			else
				cardImg:setVisible(false)
			end
		end
	end

	local function initReturnPanel()
		root = returnPanel:GetRawPanel()
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(returnScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local maxPage = ((maxReturnIndex-1) - (maxReturnIndex-1)%3)/3 + 1
		local leftBtn = tolua.cast(root:getChildByName('left_btn') , 'UIButton')
		leftBtn:setNormalButtonGray(currPage == 1)
		leftBtn:setTouchEnable(currPage ~= 1)
		leftBtn:registerScriptTapHandler(function ()
			currPage = currPage - 1
			updateReturnPanel()
		end)
		GameController.addButtonSound(leftBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local rightBtn = tolua.cast(root:getChildByName('right_btn') , 'UIButton')
		rightBtn:setNormalButtonGray(currPage == maxPage)
		rightBtn:setTouchEnable(currPage ~= maxPage)
		rightBtn:registerScriptTapHandler(function ()
			currPage = currPage + 1
			updateReturnPanel()
		end)
		GameController.addButtonSound(rightBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local getAllBtn = tolua.cast(root:getChildByName('got_all_btn') , 'UITextButton')
		local isCanGet = getCurrReturn()
		getAllBtn:setNormalButtonGray(isCanGet == false)
		getAllBtn:setTouchEnable(isCanGet)
		getAllBtn:registerScriptTapHandler(function ()
			getCurrReturnTab()
			args = {
				buying_ids = currGotArr
			}
			Message.sendPost('return_group_buying','activity',json.encode(args),function (jsonData)
				print(jsonData)
				local jsonDic = json.decode(jsonData)
				local cash = jsonDic.data.cash
				if tonumber(jsonDic.code) == 0 then
					PlayerCoreData.addCashDelta( cash )
					cashNumTx1:setText(toWordsNumber(PlayerCoreData.getCashValue()))
					setCurrReturnTabStatus()
					updateReturnPanel()
					getAllBtn:setNormalButtonGray(true)
					getAllBtn:setTouchEnable(false)
					getAllBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
					GameController.showPrompts(string.format(getLocalStringValue('E_STR_GAIN_CASH_DESC'),tonumber(cash)), COLOR_TYPE.WHITE)
				end
			end)
		end)
		GameController.addButtonSound(getAllBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		updateReturnPanel()
	end

	local function createReturnPanel()
		returnScene = SceneObjEx:createObj('panel/shop_return_panel.json' , 'shop-return-in-lua')
		returnPanel = returnScene:getPanelObj()
		returnPanel:setAdaptInfo('restore_bg_img' , 'restore_img')
		returnPanel:registerInitHandler(initReturnPanel)
		UiMan.show(returnScene)
	end

	local function updateTuangouCell()
		timeImg = tolua.cast(tuangouPanel:getChildByName('time_img') , 'UIImageView')
		timeInfoTx = tolua.cast(tuangouPanel:getChildByName('time_info_tx') , 'UILabel')
		
		local timeEnd = false
		local nowTime = UserData:getServerTime() - Time.beginningOfToday()
		local diffTime = nowTime%(3600*6) - 3600*5
		local time
		if diffTime < 0 then
			time = 0 - diffTime
			timeInfoTx:setText(getLocalStringValue('E_STR_WELFARE_TIMEEND'))
			timeEnd = false
		else
			time = 3600 - diffTime
			timeInfoTx:setText(getLocalStringValue('E_STR_SHOP_DESC3'))
			timeEnd = true
		end
		timeCDTx:setTime(time + 2)

		for i=1,3 do
			str = 'card_'..i..'_img'
			local cardImg = tolua.cast(tuangouPanel:getChildByName(str) , 'UIImageView')
			local peoplesNumTx4 = tolua.cast(cardImg:getChildByName('peoples_num_4_tx') , 'UILabel')
			local cashNumTx = tolua.cast(cardImg:getChildByName('cash_num_tx') , 'UILabel')
			local index = tuangouData.current_buying.current_ids[i]
			local id = tuangouData.current_buying[tostring(index)].item_id
			local count = tuangouData.current_buying[tostring(index)].count
			local tab = tuangouGoodsConf[tonumber(id)]
			local award = UserData:getAward(tab.Award1)
			cashNumTx:setText(tab.Cash)
			nameTx = tolua.cast(cardImg:getChildByName('name_tx') , 'UILabel')
			frameImg = tolua.cast(cardImg:getChildByName('frame_img') , 'UIImageView')
			goodsIco = tolua.cast(frameImg:getChildByName('goods_ico') , 'UIImageView')
			numTx = tolua.cast(frameImg:getChildByName('num_tx') , 'UILabel')
			nameTx:setText(award.name)
			nameTx:setColor(award.color)
			numTx:setText(toWordsNumber(tonumber(award.count)))
			goodsIco:setTexture(award.icon)
			goodsIco:registerScriptTapHandler(function()
				UISvr:showTipsForAward(tab.Award1)
			end)
			peoplesNumTx4:setText(count)

			for j=1,3 do
				str1 = 'num_bg_'..j..'_img'
				numBgImg = tolua.cast(cardImg:getChildByName(str1) , 'UIImageView')
				peoplesNumTx = tolua.cast(numBgImg:getChildByName('peoples_num_tx') , 'UILabel')
				returnCashTx = tolua.cast(numBgImg:getChildByName('return_cash_tx') , 'UILabel')
				str2 = 'Target'..j
				str3 = 'Return'..j
				peoplesNumTx:setText(string.format(getLocalStringValue('E_STR_SHOP_DESC1'),tab[str2]))
				returnCashTx:setText(string.format(getLocalStringValue('E_STR_SHOP_DESC2'),tab[str3]))
			end

			local buyBtn = tolua.cast(cardImg:getChildByName('buy_btn') , 'UITextButton')
			local bought = tuangouData.current_buying[tostring(index)].bought
			if bought and bought == 1 then
				buyBtn:setNormalButtonGray(true)
				buyBtn:setTouchEnable(false)
				buyBtn:setText(getLocalStringValue('E_STR_YET_BUY'))
			elseif timeEnd == true then
				buyBtn:setNormalButtonGray(true)
				buyBtn:setTouchEnable(false)
				buyBtn:setText(getLocalStringValue('E_STR_WELFARE_END'))
			else
				buyBtn:setNormalButtonGray(false)
				buyBtn:setTouchEnable(true)
				buyBtn:setText(getLocalStringValue('E_STR_BUY'))
			end
			buyBtn:registerScriptTapHandler(function ()
				local myCash = PlayerCoreData.getCashValue()
				if myCash < tonumber(tab.Cash) then
					GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
					return
				end
				args = {
					buying_id = index
				}
				Message.sendPost('buy_group_buying','activity',json.encode(args),function (jsonData)
					print(jsonData)
					local jsonDic = json.decode(jsonData)
					local awards = jsonDic.data.awards
					local cash = jsonDic.data.cash
					if tonumber(jsonDic.code) == 0 then
						PlayerCoreData.addCashDelta( cash )
						count = count + 1
						peoplesNumTx4:setText(count)
						tuangouData.current_buying[tostring(index)].count = count
						cashNumTx1:setText(toWordsNumber(PlayerCoreData.getCashValue()))

						UserData.parseAwardJson(json.encode(awards))
						buyBtn:setNormalButtonGray(true)
						buyBtn:setTouchEnable(false)
						buyBtn:setText(getLocalStringValue('E_STR_YET_BUY'))
						GameController.showPrompts(string.format(getLocalStringValue('E_STR_YOUR_GAIN_MATERIAL'),tonumber(award.count),award.name)..getLocalStringValue('E_STR_SHOP_DESC6'), COLOR_TYPE.GREEN)
					end
				end)
			end)
			GameController.addButtonSound(buyBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		end

		returnBtn = tolua.cast(tuangouPanel:getChildByName('return_btn') , 'UIButton')
		returnBtn:registerScriptTapHandler(function ()
			Message.sendPost('get_bought_group_buying','activity','{}',function (jsonData)
				print(jsonData)
				local jsonDic = json.decode(jsonData)
				if tonumber(jsonDic.code) == 0 then
					returnData = jsonDic.data.bought_buying
					maxReturnIndex = #returnData.bought_ids
					if maxReturnIndex > 0 then
						currPage = 1
						createReturnPanel()
					else
						GameController.showPrompts(getLocalStringValue('E_STR_SHOP_DESC4'), COLOR_TYPE.RED)
					end
				end
			end)	
		end)
		GameController.addButtonSound(returnBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	end

	local function createShopTuangouPanel()
		if currPanel then
			currPanel:setVisible(false)
		end
		if tuangouPanel then
			tuangouPanel:setVisible(true)
			updateTuangouCell()
		else
			tuangouPanel = createWidgetByName('panel/shop_tuangou_panel.json')
			shopCellPl:addChild(tuangouPanel)
			timeTx = tolua.cast(tuangouPanel:getChildByName('time_tx') , 'UILabel')
			local info2 = tolua.cast(tuangouPanel:getChildByName('info1_tx'),'UILabel')
			local timeInfo = tolua.cast(tuangouPanel:getChildByName('time_info_tx'),'UILabel')
			info2:setPreferredSize(360,1)
			timeInfo:setPreferredSize(240,1)
			timeTx:setText('')
			timeCDTx = UICDLabel:create()
			timeCDTx:setFontSize(22)
			timeCDTx:setPosition(ccp(5,-2))
			timeCDTx:setFontColor(ccc3(50, 240, 50))
			timeCDTx:setAnchorPoint(ccp(0,0.5))
			timeTx:addChild(timeCDTx)

			timeCDTx:registerTimeoutHandler(function ()
				Message.sendPost('get_group_buying','activity','{}',function (jsonData)
					print(jsonData)
					local jsonDic = json.decode(jsonData)
					if tonumber(jsonDic.code) == 0 then
						tuangouData = jsonDic.data
						createShopTuangouPanel()
					end
				end)
			end)

			freshBtn = tolua.cast(tuangouPanel:getChildByName('fresh_btn') , 'UIButton')
			freshBtn:registerScriptTapHandler(function ()
				Message.sendPost('get_group_buying','activity','{}',function (jsonData)
					print(jsonData)
					local jsonDic = json.decode(jsonData)
					if tonumber(jsonDic.code) == 0 then
						tuangouData = jsonDic.data
						createShopTuangouPanel()
					end
				end)
			end)
			GameController.addButtonSound(freshBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			updateTuangouCell()
		end
	end
	createShopTuangouPanel()
	return tuangouPanel
end