function genBuyGoldPanel()
	-- ui
	local sceneObj
	local panel
	local root

	-- conf
	local buyConf = GameData:getArrayData('buy.dat')

	local buyTimes = 0
	local buyMaxCount

	local markData

	local function isFuncOpen()
		local targetLv = tonumber(GameData:getGlobalValue('BuyGoldLevelLimit'))
		if PlayerCoreData.getPlayerLevel() < targetLv then
			local s = string.format(getLocalStringValue('E_STR_BUY_GOLD_LIMIT') , targetLv)
			GameController.showMessageBox(s, MESSAGE_BOX_TYPE.OK)
			return false
		end
		return true
	end

	local function getBuyGoldNum()
		local gold = tonumber(GameData:getGlobalValue('BuyGoldFormulaBaseNumber')) + tonumber(GameData:getGlobalValue('BuyGoldFormulaCoefficient'))*(tonumber(PlayerCoreData.getPlayerLevel()) - tonumber(GameData:getGlobalValue('BuyGoldLevelLimit')))
		return gold
	end

	local function updatePanel()
		local cashTx = tolua.cast(root:getChildByName('user_cash_tx') , 'UILabel')
		local goldTx = tolua.cast(root:getChildByName('user_gold_tx') , 'UILabel')
		local costTx = tolua.cast(root:getChildByName('cost_tx') , 'UILabel')
		local timesTx = tolua.cast(root:getChildByName('times_tx') , 'UILabel')
		local addGoldTx = tolua.cast(root:getChildByName('get_gold_tx') , 'UILabel')
		local getGoldTx = tolua.cast(root:getChildByName('gold_num_tx') , 'UILabel')

		cashTx:setText(toWordsNumber(PlayerCoreData.getCashValue()))
		goldTx:setText(toWordsNumber(PlayerCoreData.getGoldValue()))
		timesTx:setTextFromInt(buyMaxCount - buyTimes)
		if buyTimes == buyMaxCount then
			costTx:setTextFromInt(buyConf[buyMaxCount].CashGold)
		else
			costTx:setTextFromInt(buyConf[buyTimes + 1].CashGold)
		end
		addGoldTx:setText('+' .. toWordsNumber(getBuyGoldNum()))
		getGoldTx:setText(toWordsNumber(getBuyGoldNum()))
	end

	local function onClickBuyBtn()
		if buyTimes == buyMaxCount then
			GameController.showMessageBox(getLocalString('buy_food_count_limit'), MESSAGE_BOX_TYPE.OK)
			return
		end

		if tonumber(buyConf[buyTimes + 1].CashGold) > PlayerCoreData.getCashValue() then
			GameController.showPrompts(getLocalString("E_STR_CASH_NOT_ENOUGH") , COLOR_TYPE.RED)
			return
		end

		Message.sendPost('buy_gold','user','{}',function (jsonData)
			print(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end
			local data = jsonDic['data']
			
			local cash = tonumber(data['cash']) or 0
			local gold = tonumber(data['gold']) or 0

			PlayerCoreData.addCashDelta(cash)
			PlayerCoreData.addGoldDelta(gold)

			markData['gold'] = tonumber(markData['gold']) + 1
			buyTimes = tonumber(markData['gold'])
			local markStr = json.encode(markData)
			UserData:setLuaMarkData(markStr)

			updatePanel()
			UpdateMainCity()
			GameController:showPrompts(getLocalString('E_STR_BUY_SUCCEED'), COLOR_TYPE.GREEN)
		end)
	end

	local function initData()
		buyMaxCount = tonumber(GameData:getGlobalValue('MaxBuyGoldTimes'))
		local vipConf = GameData:getMapData('vip.dat')
		buyMaxCount = buyMaxCount + tonumber(vipConf[tostring(PlayerCoreData.getPlayerVIP())].AddBuyGold)
		markData = UserData:getLuaMarkData()
		buyTimes = tonumber(markData.gold)
	end

	local function init()
		initData()

		root = panel:GetRawPanel()
		local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		closeBtn:setWidgetZOrder( 9999 )
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local buyBtn = tolua.cast(root:getChildByName('buy_btn') , 'UITextButton')
		buyBtn:registerScriptTapHandler(onClickBuyBtn)
		buyBtn:setWidgetZOrder( 9999 )
		GameController.addButtonSound(buyBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		updatePanel()
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/buy_gold_panel.json' , 'buygold-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('buy_gold_bg_img' , 'root_img')

		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end

	-- 入口
	if isFuncOpen() then
		createPanel()
	end
end