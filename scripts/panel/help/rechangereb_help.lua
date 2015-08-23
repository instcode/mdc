local function genViewUpdater(panel, help)
	return function() 
		local root = panel:GetRawPanel()
        local helpBgImg = tolua.cast(root:getChildByName('recharge_help_bg_img'), 'UIImageView')
        local helpImg = tolua.cast(helpBgImg:getChildByName('help_img'), 'UIImageView')
        local closeBtn = tolua.cast(helpImg:getChildByName('close_btn'), 'UIButton')
        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(help, ELF_HIDE.SMART_HIDE)
		end)

		local knowBtn = tolua.cast(helpImg:getChildByName('ok_btn'), 'UITextButton')
        GameController.addButtonSound(knowBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		knowBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(help, ELF_HIDE.SMART_HIDE)
		end)

		local infoTx1 = tolua.cast(helpImg:getChildByName('info_1_tx'), 'UILabel')
		infoTx1:setText(getLocalStringValue('HELP_RECHANGEREB_1'))
		infoTx1:setPreferredSize(580,1)
		local infoTx2 = tolua.cast(helpImg:getChildByName('info_2_tx'), 'UILabel')
		infoTx2:setText(getLocalStringValue('HELP_RECHANGEREB_2'))
		infoTx2:setPreferredSize(580,1)
		local infoTx3 = tolua.cast(helpImg:getChildByName('info_3_tx'), 'UILabel')
		infoTx3:setText(getLocalStringValue('HELP_RECHANGEREB_3'))
		infoTx3:setPreferredSize(580,1)
		local infoTx4 = tolua.cast(helpImg:getChildByName('info_4_tx'), 'UILabel')
		infoTx4:setText(getLocalStringValue('HELP_RECHANGEREB_4'))
		infoTx4:setPreferredSize(580,1)		
	end
end

function genRechangerebHelpPanel()
    local help = SceneObjEx:createObj('panel/rechangereb_help_panel.json', 'rechangereb-help-lua')

    local panel = help:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('recharge_help_bg_img', 'help_img')
    local viewUpdater = genViewUpdater(panel, help)

	panel:registerInitHandler(function()
		viewUpdater()
	end)
    -- Show now
    CUIManager:GetInstance():ShowObject(help, ELF_SHOW.SMART)
end
