


function openShopMainPanel(nowPage)
	-- UI
	local sceneObj = nil
	local panel = nil
	local titleBns = {}
	local page = nowPage
	local shopCellPl = nil
	local tuangouPanel = nil
	local miaoshaPanel = nil
	local tegouPanel = nil
	local shengwangPanel = nil
	local currPanel
	local panels = {}
	local cashNumTx1

	local function updateTitleBtns(newPage)
		titleBns[page]:setPressState(WidgetStateNormal)
		titleBns[page]:setTouchEnable(true)
		page = newPage
		titleBns[page]:setPressState(WidgetStateSelected)
		titleBns[page]:setTouchEnable(false)
	end

	local function initShopHelpPanel()
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
		infoTx1:setText(getLocalStringValue('E_STR_SHOP_HELP_DESC1'))
		infoTx1:setPreferredSize(580,1)
		local infoTx2 = tolua.cast(sv:getChildByName('info_2_tx'), 'UILabel')
		infoTx2:setText(getLocalStringValue('E_STR_SHOP_HELP_DESC2'))
		infoTx2:setPreferredSize(580,1)
		local infoTx3 = tolua.cast(sv:getChildByName('info_3_tx'), 'UILabel')
		infoTx3:setText(getLocalStringValue('E_STR_SHOP_HELP_DESC3'))
		infoTx3:setPreferredSize(580,1)
		local infoTx4 = tolua.cast(sv:getChildByName('info_4_tx'), 'UILabel')
		infoTx4:setText(getLocalStringValue('E_STR_SHOP_HELP_DESC4'))
		infoTx4:setPreferredSize(580,1)
		local infoTx5 = tolua.cast(sv:getChildByName('info_5_tx'), 'UILabel')
		infoTx5:setText(getLocalStringValue('E_STR_SHOP_HELP_DESC5'))
		infoTx5:setPreferredSize(580,1)
		local infoTx6 = tolua.cast(sv:getChildByName('info_6_tx'), 'UILabel')
		infoTx6:setText(getLocalStringValue('E_STR_SHOP_HELP_DESC6'))
		infoTx6:setPreferredSize(580,1)
		local infoTx7 = tolua.cast(sv:getChildByName('info_7_tx'), 'UILabel')
		infoTx7:setText(getLocalStringValue('E_STR_SHOP_HELP_DESC7'))
		infoTx7:setPreferredSize(580,1)
		local infoTx8 = tolua.cast(sv:getChildByName('info_8_tx'), 'UILabel')
		infoTx8:setText(getLocalStringValue('E_STR_SHOP_HELP_DESC8'))
		infoTx8:setPreferredSize(580,1)
		local infoTx9 = tolua.cast(sv:getChildByName('info_9_tx'), 'UILabel')
		infoTx9:setText(getLocalStringValue('E_STR_SHOP_HELP_DESC9'))
		infoTx9:setPreferredSize(580,1)
		sv:setClippingEnable(true)
		sv:scrollToTop()
	end

	local function createShopHelpPanel()
		helpScene = SceneObjEx:createObj('panel/shop_help_panel.json' , 'shop-help-in-lua')
		helpPanel = helpScene:getPanelObj()
		helpPanel:setAdaptInfo('help_bg_img' , 'help_img')
		helpPanel:registerInitHandler(initShopHelpPanel)
		UiMan.show(helpScene)
	end

	local function updateNowPanel()
		if page == 1 then
			currPanel = openShopTegouPanel(shopCellPl,cashNumTx1)
		elseif page == 2 then
			Message.sendPost('get_group_buying','activity','{}',function (jsonData)
				print(jsonData)
				local jsonDic = json.decode(jsonData)
				if tonumber(jsonDic.code) == 0 then
					tuangouData = jsonDic.data
					currPanel = openShopTuangouPanel(shopCellPl,cashNumTx1,tuangouData)
				else
					page = 1
					currPanel = openShopTegouPanel(shopCellPl,cashNumTx1)
				end
			end)
		elseif page == 3 then
			Message.sendPost('get_seckilling','activity','{}',function (jsonData)
				print(jsonData)
				local jsonDic = json.decode(jsonData)
				if tonumber(jsonDic.code) == 0 then
					miaoshaData = jsonDic.data
					currPanel = openShopMiaoshaPanel(shopCellPl,cashNumTx1,miaoshaData)
				else
					page = 1
					currPanel = openShopTegouPanel(shopCellPl,cashNumTx1)
				end
			end)
		-- elseif page == 4 then
		-- 	Message.sendPost('get_black_shop','activity','{}',function (jsonData)
		-- 		print(jsonData)
		-- 		local jsonDic = json.decode(jsonData)
		-- 		if tonumber(jsonDic.code) == 0 then
		-- 			heidianData = jsonDic.data
		-- 			currPanel = openShopHeidianPanel(shopCellPl,cashNumTx1,heidianData)
		-- 		else
		-- 			page = 1
		-- 			currPanel = openShopTegouPanel(shopCellPl,cashNumTx1)
		-- 		end
		-- 	end)
		-- elseif page == 5 then
		-- 	Message.sendPost('get_fame_shop','activity','{}',function (jsonData)
		-- 		print(jsonData)
		-- 		local jsonDic = json.decode(jsonData)
		-- 		if tonumber(jsonDic.code) == 0 then
		-- 			shengwangData = jsonDic.data
		-- 			currPanel = openShopShengwangPanel(shopCellPl,cashNumTx1,shengwangData)
		-- 		else
		-- 			page = 1
		-- 			currPanel = openShopTegouPanel(shopCellPl,cashNumTx1)
		-- 		end
		-- 	end)
		else
			page = 1
			currPanel = openShopTegouPanel(shopCellPl,cashNumTx1)
		end
	end

    local function init()
    	root = panel:GetRawPanel()
    	closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
    		for i,v in ipairs(panels) do
    			panels[i] = nil
    		end
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		helpBtn = tolua.cast(root:getChildByName('help_btn') , 'UIButton')
    	helpBtn:registerScriptTapHandler(function ()
			createShopHelpPanel()
		end)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

	    tegouBtn = tolua.cast(root:getChildByName('title_1_btn') , 'UIButton')
	    tuangouBtn = tolua.cast(root:getChildByName('title_2_btn') , 'UIButton')
	    miaoshaBtn = tolua.cast(root:getChildByName('title_3_btn') , 'UIButton')
	    -- heidianBtn = tolua.cast(root:getChildByName('title_4_btn') , 'UIButton')
	    -- shengwangBtn = tolua.cast(root:getChildByName('title_5_btn') , 'UIButton')
	    shopCellPl = tolua.cast(root:getChildByName('shop_cell_pl') , 'UIPanel')
	    cashNumTx1 = tolua.cast(root:getChildByName('cash_num_tx') , 'UILabel')
		cashNumTx1:setText(toWordsNumber(PlayerCoreData.getCashValue()))
	    tegouBtn:registerScriptTapHandler(function ()
	    	print(currPanel)
	    	updateTitleBtns(1)
			tegouPanel = openShopTegouPanel(shopCellPl,cashNumTx1,currPanel)
			currPanel = tegouPanel
		end)
		GameController.addButtonSound(tegouBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		tuangouBtn:registerScriptTapHandler(function ()
			print(currPanel)
			Message.sendPost('get_group_buying','activity','{}',function (jsonData)
				print(jsonData)
				local jsonDic = json.decode(jsonData)
				if tonumber(jsonDic.code) == 0 then
					updateTitleBtns(2)
					tuangouData = jsonDic.data
					tuangouPanel = openShopTuangouPanel(shopCellPl,cashNumTx1,tuangouData,currPanel)
					currPanel = tuangouPanel
				end
			end)
		end)
		GameController.addButtonSound(tuangouBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		miaoshaBtn:registerScriptTapHandler(function ()
			print(currPanel)
			Message.sendPost('get_seckilling','activity','{}',function (jsonData)
				print(jsonData)
				local jsonDic = json.decode(jsonData)
				if tonumber(jsonDic.code) == 0 then
					updateTitleBtns(3)
					miaoshaData = jsonDic.data
					miaoshaPanel = openShopMiaoshaPanel(shopCellPl,cashNumTx1,miaoshaData,currPanel)
					currPanel = miaoshaPanel
				end
			end)
		end)
		GameController.addButtonSound(miaoshaBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		-- heidianBtn:registerScriptTapHandler(function ()
		-- 	Message.sendPost('get_black_shop','activity','{}',function (jsonData)
		-- 		print(jsonData)
		-- 		local jsonDic = json.decode(jsonData)
		-- 		if tonumber(jsonDic.code) == 0 then
		-- 			updateTitleBtns(4)
		-- 			heidianData = jsonDic.data
		-- 			heidianPanel = openShopHeidianPanel(shopCellPl,cashNumTx1,heidianData,currPanel)
		-- 			currPanel = heidianPanel
		-- 		end
		-- 	end)
		-- end)
		-- GameController.addButtonSound(heidianBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		-- shengwangBtn:registerScriptTapHandler(function ()
		-- 	Message.sendPost('get_fame_shop','activity','{}',function (jsonData)
		-- 		print(jsonData)
		-- 		local jsonDic = json.decode(jsonData)
		-- 		if tonumber(jsonDic.code) == 0 then
		-- 			updateTitleBtns(5)
		-- 			shengwangData = jsonDic.data
		-- 			shengwangPanel = openShopShengwangPanel(shopCellPl,cashNumTx1,shengwangData,currPanel)
		-- 			currPanel = shengwangPanel
		-- 		end
		-- 	end)
		-- end)
		-- GameController.addButtonSound(shengwangBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		-- titleBns = {tegouBtn, tuangouBtn , miaoshaBtn , heidianBtn,shengwangBtn}
		titleBns = {tegouBtn, tuangouBtn , miaoshaBtn }
		page = nowPage or 1

		updateTitleBtns(page)
		updateNowPanel()
    end

    local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/shop_main_panel.json', 'shop-main-panel-lua')
	    panel = sceneObj:getPanelObj()
	    panel:setAdaptInfo('shop_bg_img', 'shop_img')

		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end

	createPanel()
end