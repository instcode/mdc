local function genViewUpdater(panel, help)
	return function() 
		local root = panel:GetRawPanel()
        local helpBgImg = tolua.cast(root:getChildByName('military_bg_img'), 'UIImageView')
        local helpImg = tolua.cast(helpBgImg:getChildByName('military_img'), 'UIImageView')
        local closeBtn = tolua.cast(helpImg:getChildByName('close_btn'), 'UIButton')
        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(help, ELF_HIDE.SMART_HIDE)
		end)

		local knowBtn = tolua.cast(helpImg:getChildByName('know_btn'), 'UITextButton')
        GameController.addButtonSound(knowBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		knowBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(help, ELF_HIDE.SMART_HIDE)
		end)
		local helpSv = tolua.cast(helpImg:getChildByName('help_sv'),'UIScrollView')
		helpSv:setClippingEnable(true)
		helpSv:scrollToTop()

		local infoTx1 = tolua.cast(helpImg:getChildByName('info_1_tx'), 'UILabel')
		infoTx1:setText(getLocalStringValue('HELP_MILITARY_1'))
		infoTx1:setPreferredSize(650,1)
		local infoTx2 = tolua.cast(helpImg:getChildByName('info_2_tx'), 'UILabel')
		infoTx2:setText(getLocalStringValue('HELP_MILITARY_2'))
		infoTx2:setPreferredSize(650,1)
		local infoTx3 = tolua.cast(helpImg:getChildByName('info_3_tx'), 'UILabel')
		infoTx3:setText(getLocalStringValue('HELP_MILITARY_3'))
		infoTx3:setPreferredSize(650,1)
		local infoTx4 = tolua.cast(helpImg:getChildByName('info_4_tx'), 'UILabel')
		infoTx4:setText(getLocalStringValue('HELP_MILITARY_4'))
		infoTx4:setPreferredSize(650,1)
		local infoTx5 = tolua.cast(helpImg:getChildByName('info_5_tx'), 'UILabel')
		infoTx5:setText(getLocalStringValue('HELP_MILITARY_5'))
		infoTx5:setPreferredSize(650,1)
		
	end
end

function genMilltaryHelpPanel()
    local help = SceneObjEx:createObj('panel/military_help_panel.json', 'military-help-lua')

    local panel = help:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('military_bg_img', 'military_img')
    local viewUpdater = genViewUpdater(panel, help)

	panel:registerInitHandler(function()
		viewUpdater()
	end)
    -- Show now
    CUIManager:GetInstance():ShowObject(help, ELF_SHOW.SMART)
end
