local function genViewUpdater(panel, help)
	return function() 
		local root = panel:GetRawPanel()
        local helpBgImg = tolua.cast(root:getChildByName('goldmine_help_bg_img'), 'UIImageView')
        local helpImg = tolua.cast(helpBgImg:getChildByName('goldmine_img'), 'UIImageView')
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
		for i=1,5 do
			local pre = tolua.cast(helpImg:getChildByName('percent_'.. i .. '_tx'),'UILabel')
			pre:setPreferredSize(160,1)
		end

		local infoTx1 = tolua.cast(helpImg:getChildByName('info_1_tx'), 'UILabel')
		infoTx1:setText(getLocalStringValue('HELP_GOLDMINE_1'))
		infoTx1:setPreferredSize(745,1)
		local infoTx2 = tolua.cast(helpImg:getChildByName('info_2_tx'), 'UILabel')
		local times = PlayerCoreData.getGoldMineOccFreeTime()
		local str = getLocalStringValue('HELP_GOLDMINE_2')
		local infoBuff   = string.format(str,times)
		infoTx2:setText(infoBuff)
		infoTx2:setPreferredSize(745,1)
		local infoTx3 = tolua.cast(helpImg:getChildByName('info_3_tx'), 'UILabel')
		infoTx3:setText(getLocalStringValue('HELP_GOLDMINE_3'))
		infoTx3:setPreferredSize(745,1)
		local infoTx4 = tolua.cast(helpImg:getChildByName('info_4_tx'), 'UILabel')
		infoTx4:setText(getLocalStringValue('HELP_GOLDMINE_4'))
		infoTx4:setPreferredSize(745,1)		
	end
end

function genGoldMineHelpPanel()
    local help = SceneObjEx:createObj('panel/goldmine_help_panel.json', 'goldmine-help-lua')

    local panel = help:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('goldmine_help_bg_img', 'goldmine_img')
    local viewUpdater = genViewUpdater(panel, help)

	panel:registerInitHandler(function()
		viewUpdater()
	end)
    -- Show now
    CUIManager:GetInstance():ShowObject(help, ELF_SHOW.SMART)
end
