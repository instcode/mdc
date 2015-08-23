function genPayChoice(cash, wareName)
	-- exchangeCash(cash, wareName)
	local sceneObj
	local panel
	local function init()
		root = panel:GetRawPanel()
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		bgImg = tolua.cast(root:getChildByName('vn_pay_choice_img') , 'UIImageView')
    	bgImg:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		vnBtn = tolua.cast(root:getChildByName('vn_btn') , 'UITextButton')
    	vnBtn:registerScriptTapHandler(function ()
			exchangeCash(cash, wareName,2)
		end)
		GameController.addButtonSound(vnBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		iosBtn = tolua.cast(root:getChildByName('ios_btn') , 'UITextButton')
    	iosBtn:registerScriptTapHandler(function ()
			exchangeCash(cash, wareName,1)
		end)
		GameController.addButtonSound(iosBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	end
	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/vn_pay_choice_panel.json','vn-pay-choice-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('vn_pay_choice_main_img','vn_pay_choice_img')
		panel:registerInitHandler(init)
		UiMan.show(sceneObj)
	end
	createPanel()
end