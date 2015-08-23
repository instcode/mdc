function genBuyFoodPanel()
	-- ui
	local sceneObj
	local panel
	local root

	local function isFuncOpen()
		local targetLv = getGlobalIntegerValue('BuyFoodLevel')
		if PlayerCoreData.getPlayerLevel() < targetLv then
			local s = string.format(getLocalStringValue('E_STR_BUY_FOOD_LIMIT') , targetLv)
			GameController.showMessageBox(s, MESSAGE_BOX_TYPE.OK)
			return false
		end
		return true
	end

	local function updatePanel()
		local cashTx = tolua.cast(root:getChildByName('user_gold_tx') , 'UILabel')
		local foodTx = tolua.cast(root:getChildByName('user_food_tx') , 'UILabel')
		local costTx = tolua.cast(root:getChildByName('cost_tx') , 'UILabel')
		local timesTx = tolua.cast(root:getChildByName('times_tx') , 'UILabel')

		cashTx:setText(toWordsNumber(PlayerCoreData.getCashValue()))
		foodTx:setText(toWordsNumber(PlayerCoreData.getFoodValue()))
		timesTx:setTextFromInt(PlayerCoreData.getFoodBuyTimeRemains())
		costTx:setTextFromInt(PlayerCoreData.getBuyFoodCashCost())
	end

	local function onClickBuyBtn()
		if PlayerCoreData.getFoodBuyTimeRemains() <= 0 then
			GameController.showMessageBox(getLocalString('buy_food_count_limit'), MESSAGE_BOX_TYPE.OK)
			return
		end

		if PlayerCoreData.getBuyFoodCashCost() > PlayerCoreData.getCashValue() then
			GameController.showPrompts(getLocalString("E_STR_CASH_NOT_ENOUGH") , COLOR_TYPE.RED)
			return
		end

		Message.sendPost('buy_food','battle','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end
			local data = jsonDic['data']
			
			local cash = tonumber(data['cash']) or 0
			local food = tonumber(data['food']) or 0

			PlayerCoreData.addCashDelta(cash)
			PlayerCoreData.addFoodDelta(food)

			local markData = UserData:getMarkData()
			markData['food'] = tonumber(markData['food']) + 1
			local markStr = json.encode(markData)
			UserData:setMarkData(markStr)

			updatePanel()
			UpdateMainCity()
			GameController:showPrompts(getLocalString('E_STR_BUY_SUCCEED'), COLOR_TYPE.GREEN)
		end)
	end

	local function init()
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
		sceneObj = SceneObjEx:createObj('panel/buy_food_panel.json' , 'buyfood-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('buy_food_bg_img' , 'root_img')

		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end

	-- 入口
	if isFuncOpen() then
		createPanel()
	end
end