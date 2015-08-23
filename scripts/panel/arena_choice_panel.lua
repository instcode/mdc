require 'ceremony/pvp/pvp_entrance.lua'

function arenaChoiceEnter()
	local sceneObj
	local panel
	local function init()
		root = panel:GetRawPanel()
		pBgImg = tolua.cast(root:getChildByName('arena_choice_bg_img') , 'UIImageView')
    	pBgImg:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		button1 = tolua.cast(root:getChildByName('card_1_btn') , 'UIButton')
    	button1:registerScriptTapHandler(function ()
			CArenaMgr:getInst():sendGetMatchRankRequest()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(button1 , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local infoTx1_1 = tolua.cast(button1:getChildByName('info_1_tx'),'UILabel')
		local infoTx1_2 = tolua.cast(button1:getChildByName('info_2_tx'),'UILabel') 
		infoTx1_1:setPreferredSize(300,1)
		infoTx1_2:setPreferredSize(300,1)

		button2 = tolua.cast(root:getChildByName('card_2_btn') , 'UIButton')
    	button2:registerScriptTapHandler(function ()		
    		local openTime = UserData:getOpenServerWarDays()
			local nowTime = UserData:getServerTime()
    		if not openTime or openTime > nowTime then
    			GameController.showPrompts(getLocalStringValue('E_STR_PVP_NOT_OPEN'), COLOR_TYPE.RED)
    			return
			end
				
    		local level = PlayerCoreData.getPlayerLevel()
    		if level >= getGlobalIntegerValue('ServerWarLevelMin') then
				pvpEntrance()
				CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
			else
				GameController.showPrompts(getLocalStringValue('E_STR_PVP_OPEN_LEVEL'), COLOR_TYPE.RED)
			end
		end)
		GameController.addButtonSound(button2 , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		local infoTx2_1 = tolua.cast(button2:getChildByName('info_1_tx'),'UILabel')
		local infoTx2_2 = tolua.cast(button2:getChildByName('info_2_tx'),'UILabel') 
		infoTx2_1:setPreferredSize(300,1)
		infoTx2_2:setPreferredSize(300,1)

		CUIManager:GetInstance():updateSceneId(30096)
	end
	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/arena_choice_panel.json','arena-choice-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('arena_choice_bg_img','arena_choice_img')
		panel:registerInitHandler(init)
		UiMan.show(sceneObj)
		cclog('================================arena choice in lua')
	end
	createPanel()
end