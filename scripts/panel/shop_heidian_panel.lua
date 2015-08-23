


function openShopHeidianPanel()
	-- UI
	local sceneObj
	local panel
	local heidianScene
	local heidianPanel
	local shopCellPl
	local reputationNumTx
	local dataTab = {}
	local souls = {}
	local lights = {}

	local heidianConf = GameData:getArrayData('blackshop.dat') -- 黑店
	local vipConf = GameData:getArrayData('vip.dat') -- 黑店
	local refreshTime =  tonumber(GameData:getGlobalValue('BlackShopRefreshInterval'))
	local materialId =  tonumber(GameData:getGlobalValue('BlackShopRefreshMaterialId'))
	local materialNum =  tonumber(GameData:getGlobalValue('BlackShopRefreshMaterial'))
	local refreshCash = tonumber(GameData:getGlobalValue('BlackShopRefreshCash'))
	local vipLevel = PlayerCoreData.getPlayerVIP()
	local heidianData = data
	local timeCDTx

	local function getRefreshTimes()
		refreshTimes = 0
		for i,v in ipairs(vipConf) do
			if tonumber(v.Level) == vipLevel then
				refreshTimes = tonumber(v.BlackShopRefresh)
			end
		end
	end

	local function getData()
		local index = 1
		for k,v in pairs(heidianData.black_shop.goods) do
			local tab = {id = tonumber(k),got = v}
			table.insert(dataTab,index)
			dataTab[index] = tab
			index = index + 1
		end
	end

	local function soulSetVisible(i,cardImg)
		if not souls[i] then
			local pSoul = CUIEffect:create()
			pSoul:Show( 'hun' , 0)
			cardImg:getContainerNode():addChild(pSoul)
			table.insert(souls,i)
			souls[i] = pSoul
		end
	end

	local function lightSetVisible(i,cardImg)
		if not lights[i] then
			local light = CUIEffect:create()
			light:Show("yellow_light", 0)
			light:setScale(0.81)
			light:setPosition( ccp(0, 0))
			light:setAnchorPoint(ccp(0.5, 0.5))
			cardImg:getContainerNode():addChild(light)
			light:setZOrder(100)
			table.insert(lights,i)
			lights[i] = light
		end
	end
	local function updateHeidianCell()

		local soulTx = tolua.cast(heidianPanel:getChildByName('soul_tx') , 'UILabel')
		local cashTx = tolua.cast(heidianPanel:getChildByName('cash_tx') , 'UILabel')
		local goldTx = tolua.cast(heidianPanel:getChildByName('gold_tx') , 'UILabel')
		local info1Tx = tolua.cast(heidianPanel:getChildByName('info_1_tx') , 'UILabel')
		local freshNumTx = tolua.cast(heidianPanel:getChildByName('fresh_num_tx') , 'UILabel')
		reputationNumTx = tolua.cast(heidianPanel:getChildByName('reputation_num_tx') , 'UILabel')
		local mat = Material:findById(materialId)
		local num = mat:getCount()
		soulTx:setText(toWordsNumber(PlayerCoreData.getSoulValue()))
		cashTx:setText(toWordsNumber(PlayerCoreData.getCashValue()))
		goldTx:setText(toWordsNumber(PlayerCoreData.getGoldValue()))
		reputationNumTx:setText(num)
		local nowTime = UserData:getServerTime() - Time.beginningOfToday()
		local diffTime = refreshTime - nowTime%refreshTime
		timeCDTx:setTime(diffTime)
		
		print(tonumber(heidianData.black_shop.count))
		print(refreshTimes)
		if tonumber(heidianData.black_shop.count) >= refreshTimes then
			freshNumTx:setText(tonumber(heidianData.black_shop.count)..'/'..refreshTimes)
			freshNumTx:setColor(ccc3(255,0,0))
		else
			freshNumTx:setText(tonumber(heidianData.black_shop.count)..'/'..refreshTimes)
		end

		
		for i=1,6 do
			print(dataTab[i])
			print(heidianConf[dataTab[i].id].Award1)
			-- print(heidianConf[dataTab[i].got])
			local str = 'card_'..i..'_img'
			local cardImg = tolua.cast(heidianPanel:getChildByName(str) , 'UIImageView')
			local frameImg = tolua.cast(cardImg:getChildByName('fram_img') , 'UIImageView')
			local photoIco = tolua.cast(cardImg:getChildByName('photo_ico') , 'UIImageView')
			local numTx = tolua.cast(cardImg:getChildByName('num_tx') , 'UILabel')
			local nameTx = tolua.cast(cardImg:getChildByName('name_tx') , 'UILabel')
			local priceTx = tolua.cast(cardImg:getChildByName('price_tx') , 'UILabel')
			local typeImg = tolua.cast(cardImg:getChildByName('type_img') , 'UIImageView')
			local discountImg = tolua.cast(cardImg:getChildByName('discount_img') , 'UIImageView')

			local stype = 1
			print(dataTab[i].id)
			local tab = heidianConf[dataTab[i].id]
			local award = UserData:getAward(tab.Award1)
			print(tab.Discount)
			if tonumber(tab.Discount) >= 1 and tonumber(tab.Discount) <= 9 then
				discountStr = 'uires/ui_2nd/com/panel/shop/discount_'..tab.Discount..'.png'
				discountImg:setVisible(true)
				discountImg:setTexture(discountStr)
			else
				discountImg:setVisible(false)
			end

			print(tab.Color)
			frameImg:setTexture('uires/ui_2nd/com/panel/common/frame.png')
			lightSetVisible(i,frameImg)
			lights[i]:setVisible(false)
			local color = tab.Color or 'blue'
			if tostring(color) == 'sred' then
				frameImg:setTexture('uires/ui_2nd/com/panel/common/frame_sred.png')
				lights[i]:setVisible(true)
			elseif tostring(color) == 'red' then
				frameImg:setTexture('uires/ui_2nd/com/panel/common/frame_red.png')
				lights[i]:setVisible(false)
			elseif tostring(color) == 'yellow' then
				frameImg:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
				lights[i]:setVisible(false)
			elseif tostring(color) == 'purple' then
				frameImg:setTexture('uires/ui_2nd/com/panel/common/frame_purple.png')
				lights[i]:setVisible(false)
			end

			nameTx:setText(award.name)
			nameTx:setColor(award.color)
			numTx:setText(toWordsNumber(tonumber(award.count)))
			priceTx:setText(toWordsNumber(tonumber(tab.Price)))
			photoIco:setTouchEnable(true)
			photoIco:setTexture(award.icon)
			photoIco:registerScriptTapHandler(function()
				UISvr:showTipsForAward(tab.Award1)
			end)

			soulSetVisible(i,cardImg)
			if tab.Currency == 'cash' then
				typeImg:setVisible(true)
				typeImg:setTexture('uires/ui_2nd/com/panel/common/cash_icon.png')
				typeImg:setScale(0.85)
				souls[i]:setVisible(false)
				stype = 1
			elseif tab.Currency == 'gold' then
				typeImg:setVisible(true)
				typeImg:setTexture('uires/ui_2nd/com/panel/common/gold_icon.png')
				typeImg:setScale(0.85)
				souls[i]:setVisible(false)
				stype = 2
			elseif tab.Currency == 'soul' then
				souls[i]:setPosition(ccp(19,50))
				souls[i]:setVisible(true)
				typeImg:setVisible(false)
				stype = 3
			end

			local buyBtn = tolua.cast(cardImg:getChildByName('buy_btn') , 'UITextButton')
			buyBtn:registerScriptTapHandler(function ()
				local myCash = 0
				if stype == 1 then
					myCash = PlayerCoreData.getCashValue()
				elseif stype == 2 then
					myCash = PlayerCoreData.getGoldValue()
				elseif stype == 3 then
					myCash = PlayerCoreData.getSoulValue()
				end
				
				cclog(tonumber(tab.Price))
				cclog(myCash)
				if myCash < tonumber(tab.Price) then
					if stype == 1 then
						GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
					elseif stype == 2 then
						GameController.showPrompts(getLocalStringValue('E_STR_NOT_ENOUGH_GOLD'), COLOR_TYPE.RED)
					elseif stype == 3 then
						GameController.showPrompts(getLocalStringValue('E_STR_SOUL_ENOUGH'), COLOR_TYPE.RED)
					end
					return
				end
				args = {
					id = tonumber(dataTab[i].id)
				}
				Message.sendPost('buy_black_shop','activity',json.encode(args),function (jsonData)
					print(jsonData)
					local jsonDic = json.decode(jsonData)
					local awards = jsonDic.data.awards
					if tonumber(jsonDic.code) == 0 then
						UserData.parseAwardJson(json.encode(awards))
						dataTab[i].got = 1
						updateHeidianCell()
						GameController.showPrompts(string.format(getLocalStringValue('E_STR_YOUR_GAIN_MATERIAL'),tonumber(award.count),award.name), COLOR_TYPE.GREEN)
					else
						GameController.showPrompts(getLocalStringValue('E_STR_SHOP_DATA_ERR'))
						Message.sendPost('get_black_shop','activity','{}',function (jsonData)
							print(jsonData)
							local jsonDic = json.decode(jsonData)
							if tonumber(jsonDic.code) == 0 then
								heidianData = jsonDic.data
								getData()
								updateHeidianCell()
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

	local function createShopHeidianPanel()
		getRefreshTimes()
		heidianPanel = createWidgetByName('panel/shop_heidian_panel.json')
		local pSoulMain = CUIEffect:create()
		pSoulMain:Show( 'hun' , 0)
		heidianPanel:getContainerNode():addChild(pSoulMain)
		pSoulMain:setPosition(ccp(158,520))
		shopCellPl:addChild(heidianPanel)

		local freshTx = tolua.cast(heidianPanel:getChildByName('fresh_tx') , 'UILabel')
		freshTx:setText(refreshCash)
		timeTx = tolua.cast(heidianPanel:getChildByName('time_tx') , 'UILabel')
		timeTx:setText('')
		timeCDTx = UICDLabel:create()
		timeCDTx:setFontSize(22)
		timeCDTx:setPosition(ccp(0,0))
		timeCDTx:setFontColor(ccc3(50, 240, 50))
		timeCDTx:setAnchorPoint(ccp(0,0.5))
		timeTx:addChild(timeCDTx)

		timeCDTx:registerTimeoutHandler(function ()
			Message.sendPost('get_black_shop','activity','{}',function (jsonData)
				print(jsonData)
				local jsonDic = json.decode(jsonData)
				if tonumber(jsonDic.code) == 0 then
					heidianData = jsonDic.data
					getData()
					updateHeidianCell()
				end
			end)
		end)

		freshBtn = tolua.cast(heidianPanel:getChildByName('fresh_btn') , 'UIButton')
		freshBtn:registerScriptTapHandler(function ()
			print(materialId)
			mat = Material:findById(materialId)
			local num = mat:getCount()
			local cash = PlayerCoreData.getCashValue()
			if tonumber(heidianData.black_shop.count) < refreshTimes then
				if num < materialNum then
					if cash < refreshCash then
						GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
					else
						Message.sendPost('refresh_black_shop','activity','{}',function (jsonData)
							print(jsonData)
							local jsonDic = json.decode(jsonData)
							if tonumber(jsonDic.code) == 0 then
								heidianData = jsonDic.data
								mat:dec(materialNum)
								getData()
								PlayerCore:addCashDelta(0 - refreshCash)
								updateHeidianCell()
							else
								GameController.showPrompts(getLocalStringValue('E_STR_SHOP_BLACKSHOP_DESC3'), COLOR_TYPE.RED)
							end
						end)
					end
				else
					Message.sendPost('refresh_black_shop','activity','{}',function (jsonData)
						print(jsonData)
						local jsonDic = json.decode(jsonData)
						if tonumber(jsonDic.code) == 0 then
							heidianData = jsonDic.data
							mat:dec(materialNum)
							getData()
							updateHeidianCell()
						else
							GameController.showPrompts(getLocalStringValue('E_STR_SHOP_BLACKSHOP_DESC3'), COLOR_TYPE.RED)
						end
					end)	
				end
			else
				GameController.showPrompts(getLocalStringValue('E_STR_SHOP_BLACKSHOP_DESC3'), COLOR_TYPE.RED)
			end
		end)
		GameController.addButtonSound(freshBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		updateHeidianCell()
	end
	
	local function init()
		root = panel:GetRawPanel()
    	closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		helpBtn = tolua.cast(root:getChildByName('help_btn') , 'UIButton')
    	helpBtn:registerScriptTapHandler(function ()
			-- createShopHelpPanel()
			helpScene = SceneObjEx:createObj('panel/heidian_help_panel.json' , 'shop-help-in-lua')
			helpPanel = helpScene:getPanelObj()
			helpPanel:setAdaptInfo('help_bg_img' , 'help_img')
			helpPanel:registerInitHandler(function ()
				-- inithelp
				local root = helpPanel:GetRawPanel()
				closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		    	closeBtn:registerScriptTapHandler(function ()
					CUIManager:GetInstance():HideObject(helpScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
				end)
				GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

				helpBgImg = tolua.cast(root:getChildByName('help_bg_img') , 'UIButton')
		    	helpBgImg:registerScriptTapHandler(function ()
					CUIManager:GetInstance():HideObject(helpScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
				end)

				local sv = tolua.cast(root:getChildByName('system_sv'), 'UIScrollView')
				local infoTx1 = tolua.cast(sv:getChildByName('info_1_tx'), 'UILabel')
				infoTx1:setText(getLocalStringValue('E_STR_HEIDIAN_HELP_DESC1'))
				infoTx1:setPreferredSize(590,1)
				local infoTx2 = tolua.cast(sv:getChildByName('info_2_tx'), 'UILabel')
				infoTx2:setText(getLocalStringValue('E_STR_HEIDIAN_HELP_DESC2'))
				infoTx2:setPreferredSize(590,1)
				local infoTx3 = tolua.cast(sv:getChildByName('info_3_tx'), 'UILabel')
				infoTx3:setText(getLocalStringValue('E_STR_HEIDIAN_HELP_DESC3'))
				infoTx3:setPreferredSize(590,1)
				local infoTx4 = tolua.cast(sv:getChildByName('info_4_tx'), 'UILabel')
				infoTx4:setText(getLocalStringValue('E_STR_HEIDIAN_HELP_DESC4'))
				infoTx4:setPreferredSize(590,1)
				local infoTx5 = tolua.cast(sv:getChildByName('info_5_tx'), 'UILabel')
				infoTx5:setText(getLocalStringValue('E_STR_HEIDIAN_HELP_DESC5'))
				infoTx5:setPreferredSize(590,1)
				local infoTx6 = tolua.cast(sv:getChildByName('info_6_tx'), 'UILabel')
				infoTx6:setText(getLocalStringValue('E_STR_HEIDIAN_HELP_DESC6'))
				infoTx6:setPreferredSize(590,1)
				local infoTx7 = tolua.cast(sv:getChildByName('info_7_tx'), 'UILabel')
				infoTx7:setText(getLocalStringValue('E_STR_HEIDIAN_HELP_DESC7'))
				infoTx7:setPreferredSize(590,1)
				local infoTx8 = tolua.cast(sv:getChildByName('info_8_tx'), 'UILabel')
				infoTx8:setText(getLocalStringValue('E_STR_HEIDIAN_HELP_DESC8'))
				infoTx8:setPreferredSize(590,1)
				sv:setClippingEnable(true)
				sv:scrollToTop()

			end)
			UiMan.show(helpScene)
		end)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		shopCellPl = tolua.cast(root:getChildByName('shop_cell_pl') , 'UIPanel')

		getData()
		createShopHeidianPanel()
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/shop_heidian_bg_panel.json', 'shop-heidian-panel-lua')
	    panel = sceneObj:getPanelObj()
	    panel:setAdaptInfo('shop_bg_img', 'shop_img')

		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end

	Message.sendPost('get_black_shop','activity','{}',function (jsonData)
		print(jsonData)
		local jsonDic = json.decode(jsonData)
		if tonumber(jsonDic.code) == 0 then
			heidianData = jsonDic.data
			createPanel()
		end
	end)
end