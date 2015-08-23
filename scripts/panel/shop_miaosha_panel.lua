


function openShopMiaoshaPanel(pl,cashTx,data,currPanel)
	-- UI
	local shopCellPl = pl
	local miaoshaPanel = nil
	local cashNumTx1 = cashTx
	local noticeScene
	local noticePanel

	local seckillingOneConf = GameData:getArrayData('seckilling_one.dat') -- 一元
	local seckillingSecConf = GameData:getArrayData('seckilling_sec.dat') -- 一折
	local startTimeStr =  GameData:getGlobalValue('SeckillingStartTime')
	local remainTime = tonumber(GameData:getGlobalValue('SeckillingRemainTime')) * 3600
	local miaoshaData = data
	local noticeData = nil
	local maxNoticeIndex = 0
	local currNoticePage = 1
	local timeMiaoshaCDTx

	local function updateNoticePanel()
		root = noticePanel:GetRawPanel()
		local maxPage = ((maxNoticeIndex-1) - (maxNoticeIndex-1)%4)/4 + 1
		local leftBtn = tolua.cast(root:getChildByName('left_btn') , 'UIButton')
		leftBtn:setNormalButtonGray(currNoticePage == 1)
		leftBtn:setTouchEnable(currNoticePage ~= 1)
		local rightBtn = tolua.cast(root:getChildByName('right_btn') , 'UIButton')
		rightBtn:setNormalButtonGray(currNoticePage == maxPage)
		rightBtn:setTouchEnable(currNoticePage ~= maxPage)

		local pageNumTx = tolua.cast(root:getChildByName('page_num_tx') , 'UILabel')
		pageNumTx:setText(currNoticePage..'/'..maxPage)
		for i=1,4 do
			local str = 'card_'..i..'_pl'
			local cardPl = tolua.cast(root:getChildByName(str) , 'UIPanel')

			local dateTx = tolua.cast(cardPl:getChildByName('date_tx') , 'UILabel')
			local playerNameTx = tolua.cast(cardPl:getChildByName('player_name_tx') , 'UILabel')
			local nameTx = tolua.cast(cardPl:getChildByName('material_name_tx') , 'UILabel')
			local numTx = tolua.cast(cardPl:getChildByName('material_num_tx') , 'UILabel')
			local cellData = noticeData[i + ( currNoticePage- 1)*4]
			if cellData then
				local item = cellData.item[1]..'.'..cellData.item[2]..':'..cellData.item[3]
				local award = UserData:getAward(item)
				local dateTab = string.split(cellData.date , '-')
				dateTx:setText(string.format(getLocalStringValue('E_STR_SHOP_DATE'),dateTab[1],dateTab[2],dateTab[3]))
				playerNameTx:setText(cellData.name)
				nameTx:setText(award.name)
				nameTx:setColor(award.color)
				numTx:setText(' * '..award.count)
				numTx:setColor(award.color)
				cardPl:setVisible(true)
			else
				cardPl:setVisible(false)
			end

		end
	end

	local function initMiaoshaNoticePanel()
		root = noticePanel:GetRawPanel()
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(noticeScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local maxPage = ((maxNoticeIndex-1) - (maxNoticeIndex-1)%4)/4 + 1
		local leftBtn = tolua.cast(root:getChildByName('left_btn') , 'UIButton')
		leftBtn:setNormalButtonGray(currNoticePage == 1)
		leftBtn:setTouchEnable(currNoticePage ~= 1)
		leftBtn:registerScriptTapHandler(function ()
			currNoticePage = currNoticePage - 1
			updateNoticePanel()
		end)
		GameController.addButtonSound(leftBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local rightBtn = tolua.cast(root:getChildByName('right_btn') , 'UIButton')
		rightBtn:setNormalButtonGray(currNoticePage == maxPage)
		rightBtn:setTouchEnable(currNoticePage ~= maxPage)
		rightBtn:registerScriptTapHandler(function ()
			currNoticePage = currNoticePage + 1
			updateNoticePanel()
		end)
		GameController.addButtonSound(rightBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		updateNoticePanel()
	end

	local function createMiaoshaNoticePanel()
		noticeScene = SceneObjEx:createObj('panel/shop_miaosha_notice_panel.json' , 'shop-notice-in-lua')
		noticePanel = noticeScene:getPanelObj()
		noticePanel:setAdaptInfo('maiosha_bg_img' , 'maisha_img')
		noticePanel:registerInitHandler(initMiaoshaNoticePanel)
		UiMan.show(noticeScene)
	end

	local function updateMiaoshaCell()
		
		-- 秒杀标题
		local titleBgImg = tolua.cast(miaoshaPanel:getChildByName('title_bg_img') , 'UIImageView')
		local titleImg = tolua.cast(titleBgImg:getChildByName('title_img') , 'UIImageView')
		local timeInfoTx = tolua.cast(miaoshaPanel:getChildByName('time_info_tx') , 'UILabel')
		local timeEnd = false
		local timeTab = string.split(startTimeStr , '|')

		local diffTime = 0
		local stype = 0
		local nowTime = UserData:getServerTime() - Time.beginningOfToday()
		local i = 1
		local isToday = false
		repeat
			local sTime = timeTab[i] *3600
			local diff = nowTime - sTime
			if diff < 0 then
				diffTime = 0 - diff
				stype = 0
				isToday =true
				break
			elseif diff < remainTime then
				diffTime = remainTime - diff
				stype = 1
				isToday =true
				break
			end
			i = i + 1
        until i > #timeTab
		if isToday == true then
			if stype == 0 then
				timeInfoTx:setText(getLocalStringValue('E_STR_SHOP_DESC7'))
				timeEnd = true
			elseif stype == 1 then
				timeInfoTx:setText(getLocalStringValue('E_STR_WELFARE_TIMEEND'))
				timeEnd = false
			end
		else
			local nextTime = timeTab[1] *3600 - Time.beginningOfToday() + 86400
			diffTime = nextTime - UserData:getServerTime()
			timeEnd = true
		end
		timeMiaoshaCDTx:setTime(diffTime)

		local round = miaoshaData.seckilling.round
		local sstype = tonumber(miaoshaData.seckilling.type) -- 0是一折 1是一元
		local conf
		if sstype == 0 then
			conf = seckillingSecConf
			titleImg:setTexture('uires/ui_2nd/com/panel/shop/discount.png')
		else
			conf = seckillingOneConf
			titleImg:setTexture('uires/ui_2nd/com/panel/shop/one.png')
		end
		for i=1,3 do
			str = 'card_'..i..'_img'
			local cardImg = tolua.cast(miaoshaPanel:getChildByName(str) , 'UIImageView')
			local cashBgImg = tolua.cast(cardImg:getChildByName('cash_bg_img') , 'UIImageView')
			local cashNumTx = tolua.cast(cashBgImg:getChildByName('cash_num_tx') , 'UILabel')
			local got = miaoshaData.seckilling.got
			local id = miaoshaData.seckilling.selling_id[i]
			local count = tonumber(miaoshaData.seckilling.selling_remain[i])
			local tab = conf[tonumber(id)]
			local award = UserData:getAward(tab.Award1)
			local nameTx = tolua.cast(cardImg:getChildByName('name_tx') , 'UILabel')
			local frameImg = tolua.cast(cardImg:getChildByName('frame_img') , 'UIImageView')
			local goodsIco = tolua.cast(frameImg:getChildByName('goods_ico') , 'UIImageView')
			local numTx = tolua.cast(frameImg:getChildByName('num_tx') , 'UILabel')
			local buyBtn = tolua.cast(cardImg:getChildByName('buy_btn') , 'UITextButton')
			-- nameTx:setPreferredSize(170,1)
			buyBtn:registerScriptTapHandler(function ()
				local myCash = PlayerCoreData.getCashValue()
				if myCash < tonumber(tab.Price) then
					GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
					return
				end
				args = {
					id = i
				}
				Message.sendPost('buy_seckilling','activity',json.encode(args),function (jsonData)
					print(jsonData)
					local jsonDic = json.decode(jsonData)
					local awards = jsonDic.data.award
					local cash = jsonDic.data.cash
					if tonumber(jsonDic.code) == 0 then
						UserData.parseAwardJson(json.encode(awards))
						cashNumTx1:setText(toWordsNumber(PlayerCoreData.getCashValue()))
						GameController.showPrompts(string.format(getLocalStringValue('E_STR_YOUR_GAIN_MATERIAL'),tonumber(award.count),award.name), COLOR_TYPE.GREEN)
					elseif tonumber(jsonDic.code) == 103 then
						GameController.showPrompts(getLocalStringValue('E_STR_SHOP_DESC10'))
					else
						GameController.showPrompts(getLocalStringValue('E_STR_SHOP_DATA_ERR'))
					end
					Message.sendPost('get_seckilling','activity','{}',function (jsonData)
						print(jsonData)
						local jsonDic = json.decode(jsonData)
						if tonumber(jsonDic.code) == 0 then
							miaoshaData = jsonDic.data
							updateMiaoshaCell()
						end
					end)
				end)
			end)
			GameController.addButtonSound(buyBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			if timeEnd == false then
				-- nameTx:setText(award.name)
				-- nameTx:setColor(award.color)
				nameTx:setText(string.format(getLocalStringValue('EXP_EFFECT_REMAIN'),count))
				numTx:setText(toWordsNumber(tonumber(award.count)))
				cashNumTx:setText(tab.Price)
				-- titleImg:setTexture('uires/ui_2nd/com/panel/shop/discount.png')
				goodsIco:setTouchEnable(true)
				goodsIco:setTexture(award.icon)
				goodsIco:registerScriptTapHandler(function()
					UISvr:showTipsForAward(tab.Award1)
				end)

				local bought = got[i]
				if bought and bought == 1 then
					buyBtn:setNormalButtonGray(true)
					buyBtn:setTouchEnable(false)
					buyBtn:setText(getLocalStringValue('E_STR_SHOP_MIAOSHA1'))
				elseif miaoshaData.seckilling.selling_remain[i] <= 0 then
					buyBtn:setNormalButtonGray(true)
					buyBtn:setTouchEnable(false)
					buyBtn:setText(getLocalStringValue('E_STR_SHOP_SELLALL'))
				elseif timeEnd == true then
					buyBtn:setNormalButtonGray(true)
					buyBtn:setTouchEnable(false)
					buyBtn:setText(getLocalStringValue('E_STR_WELFARE_END'))
				else
					buyBtn:setNormalButtonGray(false)
					buyBtn:setTouchEnable(true)
					buyBtn:setText(getLocalStringValue('E_STR_SHOP_MIAOSHA'))
				end
			else
				local str = 'E_STR_SHOP_CARD_NAME_DESC'..i
				nameTx:setText(getLocalStringValue(str))
				nameTx:setColor(ccc3(255,0,0))
				numTx:setText('')
				cashNumTx:setText(0)
				titleImg:setTexture('uires/ui_2nd/com/panel/shop/wait.png')
				goodsIco:setTexture('uires/ui_2nd/com/common_btn/help_1.png')
				goodsIco:setTouchEnable(false)
				buyBtn:setNormalButtonGray(true)
				buyBtn:setTouchEnable(false)
				buyBtn:setText(getLocalStringValue('E_STR_SHOP_DESC8'))
			end
		end

		local cardRightImg = tolua.cast(miaoshaPanel:getChildByName('card_right_img') , 'UIImageView')
		for i=1,7 do
			str = 'name_'..i..'_tx'
			local nameTx = tolua.cast(cardRightImg:getChildByName(str) , 'UILabel')
			if miaoshaData.seckilling.latest and type(miaoshaData.seckilling.latest) == 'table' and miaoshaData.seckilling.latest[i] then
				nameTx:setText(miaoshaData.seckilling.latest[i])
			else
				nameTx:setText(getLocalStringValue('E_STR_WELFARE_NORANK1'))
			end
		end

		infoBtn = tolua.cast(miaoshaPanel:getChildByName('info_btn') , 'UIButton')
		infoBtn:registerScriptTapHandler(function ()
			Message.sendPost('list_seckilling','activity','{}',function (jsonData)
				print(jsonData)
				local jsonDic = json.decode(jsonData)
				if tonumber(jsonDic.code) == 0 then
					noticeData = jsonDic.data.record
					if not noticeData then
						GameController.showPrompts(getLocalStringValue('E_STR_SHOP_MIAOSHA_NOTICE'), COLOR_TYPE.RED)
						return
					end
					maxNoticeIndex = #noticeData
					if maxNoticeIndex > 0 then
						currNoticePage = 1
						createMiaoshaNoticePanel()
					else
						GameController.showPrompts(getLocalStringValue('E_STR_SHOP_MIAOSHA_NOTICE'), COLOR_TYPE.RED)
					end
				end
			end)	
		end)
		GameController.addButtonSound(infoBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	end

	local function createShopMiaoshaPanel()
		if currPanel then
			currPanel:setVisible(false)
		end
		if miaoshaPanel then
			miaoshaPanel:setVisible(true)
			updateMiaoshaCell()
		else
			miaoshaPanel = createWidgetByName('panel/shop_miaosha_panel.json')
			shopCellPl:addChild(miaoshaPanel)
			timeTx = tolua.cast(miaoshaPanel:getChildByName('time_tx') , 'UILabel')
			local timeInfoTx = tolua.cast(miaoshaPanel:getChildByName('time_info_tx') , 'UILabel')
			timeInfoTx:setPreferredSize(280,1)
			timeTx:setText('')
			timeMiaoshaCDTx = UICDLabel:create()
			timeMiaoshaCDTx:setFontSize(22)
			timeMiaoshaCDTx:setPosition(ccp(0,0))
			timeMiaoshaCDTx:setFontColor(ccc3(50, 240, 50))
			timeMiaoshaCDTx:setAnchorPoint(ccp(0,0.5))
			timeTx:addChild(timeMiaoshaCDTx)

			timeMiaoshaCDTx:registerTimeoutHandler(function ()
				Message.sendPost('get_seckilling','activity','{}',function (jsonData)
					print(jsonData)
					local jsonDic = json.decode(jsonData)
					if tonumber(jsonDic.code) == 0 then
						miaoshaData = jsonDic.data
						createShopMiaoshaPanel()
					end
				end)
			end)

			freshBtn = tolua.cast(miaoshaPanel:getChildByName('fresh_btn') , 'UIButton')
			freshBtn:registerScriptTapHandler(function ()
				Message.sendPost('get_seckilling','activity','{}',function (jsonData)
					print(jsonData)
					local jsonDic = json.decode(jsonData)
					if tonumber(jsonDic.code) == 0 then
						miaoshaData = jsonDic.data
						createShopMiaoshaPanel()
					end
				end)
			end)
			GameController.addButtonSound(freshBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			updateMiaoshaCell()
		end
	end
	createShopMiaoshaPanel()
	return miaoshaPanel
end