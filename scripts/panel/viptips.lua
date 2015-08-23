
local function updateView(panel, matInfo, level, buyTimes)
	local rootWidget = panel:GetRawPanel()
	local awardIco = tolua.cast(rootWidget:getChildByName('award_ico'),'UIImageView')
	local numTx = tolua.cast(rootWidget:getChildByName('award_num_tx'),'UILabel')
	local nameTx = tolua.cast(rootWidget:getChildByName('award_name_tx'),'UILabel')
	local infoTx = tolua.cast(rootWidget:getChildByName('info_tx'), 'UITextArea')

	numTx:setText(tostring(matInfo.count))
	awardIco:setTexture(matInfo.icon)

	--This is going to be changed.  Soon...>>
	--local info1 = loadVipProfileString(level, 'BenefitsName')
	--local info2 = loadVipProfileString(level, 'BenefitsIntroduction')

	local info1, info2 = getMatDescriptionForTime(level, buyTimes)
	nameTx:setText(GetTextForCfg(info1))
	infoTx:setText(GetTextForCfg(info2))
	print('GetTextForCfg(info2)' .. GetTextForCfg(info2))
end

function genTouchMatTips(matInfo, viplevel, bt)
	return function()
		local tip = SceneObjEx:createObj('panel/material_tips_panel.json', 'VipSpecialTips')
		local panel = tip:getPanelObj()
		panel:setAdaptInfo('material_tips_bg_img', 'material_tips_img')
		panel:registerInitHandler(
			function()
				local shutdowner = UiMan.genCloseHandler(tip)
				panel:registerScriptTapHandler('close_btn', shutdowner)
				panel:registerScriptTapHandler('material_tips_bg_img', shutdowner)
				updateView(panel, matInfo, viplevel, bt)
			end
		)
		UiMan.show(tip)
	end
end