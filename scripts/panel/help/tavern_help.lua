local function genViewUpdater(panel, help)
	return function() 
		local root = panel:GetRawPanel()
        local helpBgImg = tolua.cast(root:getChildByName('tavern_help_bg_img'), 'UIImageView')
        local helpImg = tolua.cast(helpBgImg:getChildByName('tavern_help_img'), 'UIImageView')
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

		local infoTx1 = tolua.cast(helpImg:getChildByName('info_1_tx'), 'UILabel')
		infoTx1:setText(getLocalStringValue('HELP_TAVERN_1'))
		infoTx1:setPreferredSize(600,1)
		local infoTx2 = tolua.cast(helpImg:getChildByName('info_2_tx'), 'UILabel')
		infoTx2:setText(getLocalStringValue('HELP_TAVERN_2'))
		infoTx2:setPreferredSize(600,1)
		local infoTx3 = tolua.cast(helpImg:getChildByName('info_3_tx'), 'UILabel')
		infoTx3:setText(getLocalStringValue('HELP_TAVERN_3'))
		infoTx3:setPreferredSize(600,1)
		local infoTx4 = tolua.cast(helpImg:getChildByName('info_4_tx'), 'UILabel')
		infoTx4:setText(getLocalStringValue('HELP_TAVERN_4'))
		infoTx4:setPreferredSize(600,1)		
	end
end

function genTavernHelpPanel()
    local help = SceneObjEx:createObj('panel/tavern_help_panel.json', 'tavern-help-lua')

    local panel = help:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('tavern_help_bg_img', 'tavern_help_img')
    local viewUpdater = genViewUpdater(panel, help)

	panel:registerInitHandler(function()
		viewUpdater()
	end)
    -- Show now
    CUIManager:GetInstance():ShowObject(help, ELF_SHOW.SMART)
end
