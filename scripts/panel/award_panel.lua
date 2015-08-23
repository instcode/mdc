--获得单个奖励界面--
function genOneAwardPanel( award , callBack )
	local awardImg
	local numberTx
	local nameTx

	local act = SceneObjEx:createObj('panel/gain_res_panel.json', 'gain_res_panel')
    local panel = act:getPanelObj()
    panel:setAdaptInfo('gain_res_bg_img', 'gain_res_img')

    panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		local closeBtn = root:getChildByName('know_btn')
		closeBtn:registerScriptTapHandler(function()
			if callBack then
				callBack()
			end
			CUIManager:GetInstance():HideObject(act, ELF_HIDE.SMART_HIDE)
		end)
		local resImg = tolua.cast(root:getChildByName('res_photo_ico') , 'UIImageView')

		awardImg = tolua.cast(resImg:getChildByName('res_ico') , 'UIImageView')
		numberTx = tolua.cast(resImg:getChildByName('res_num_tx') , 'UILabel')
		nameTx = tolua.cast(resImg:getChildByName('res_name_tx') , 'UILabel')

		awardImg:setTexture(award['icon'])
 		awardImg:setAnchorPoint(ccp(0,0))
 		numberTx:setText(award['count'])
 		nameTx:setText(award['name'])
 		nameTx:setColor(award['color'])
	end)
	
    CUIManager:GetInstance():ShowObject(act, ELF_SHOW.SMART)
end

-- 预览多个奖励的界面
-- awards 奖励数组 
-- btnName1 确定按钮text
-- btnName2 取消按钮text
-- infoTx 提示信息text
-- onlyConfirm 只能点确定，disable取消按钮
-- callBack 确定按钮的回调
function genShowAwardsPanel(awards, btnName1 , btnName2, infoTx , onlyConfirm, callBack)
	local showAward = SceneObjEx:createObj('panel/show_award_panel.json', 'show-award-panel')
    local panel = showAward:getPanelObj()
    panel:setAdaptInfo('gain_res_bg_img', 'gain_res_img')

    panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		local gainBgImg = tolua.cast(root:getChildByName('gain_res_bg_img'),'UIImageView')
		local gainImg = tolua.cast(gainBgImg:getChildByName('gain_res_img'),'UIImageView')
		local confirmBtn = tolua.cast(gainImg:getChildByName('confirm_btn'),'UITextButton')
		GameController.addButtonSound(confirmBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		confirmBtn:setText(btnName1)
		confirmBtn:registerScriptTapHandler(function()
			if callBack then
				callBack()
			end
			CUIManager:GetInstance():HideObject(showAward, ELF_HIDE.SMART_HIDE)
		end)

		local cancelBtn = tolua.cast(gainImg:getChildByName('cancel_btn'),'UITextButton')
		GameController.addButtonSound(cancelBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		cancelBtn:setText(btnName2)
		cancelBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(showAward, ELF_HIDE.SMART_HIDE)
		end)
		gainBgImg:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(showAward, ELF_HIDE.SMART_HIDE)
		end)

		local info_tx = tolua.cast(gainImg:getChildByName('info_tx') , 'UILabel')
		info_tx:setPreferredSize(330,1)
		info_tx:setText(infoTx)

		local awardSv = tolua.cast(gainImg:getChildByName('award_sv') , 'UIScrollView')
		awardSv:setClippingEnable(true)
		awardSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
		local awardNum = #awards
		for k, v in pairs(awards) do
			local award = UserData:getAward(v)
			local awardImg = createWidgetByName('panel/thousandfloor_award_panel.json')
			local awardRoot = tolua.cast(awardImg:getChildByName('res_photo_ico') , 'UIImageView')
			local pIco = tolua.cast(awardRoot:getChildByName('res_ico') , 'UIImageView')
			local pName = tolua.cast(awardRoot:getChildByName('res_name_tx') , 'UILabel')
			local pNum = tolua.cast(awardRoot:getChildByName('res_num_tx') , 'UILabel')
			pName:setPreferredSize(130,1)
			pIco:setTouchEnable(true)
			pIco:registerScriptTapHandler( function()
				UISvr:showTipsForAward(v)
			end )
			pIco:setTexture(award.icon)
			pIco:setAnchorPoint(ccp(0,0))
			pName:setText(award.name)
			pName:setColor(award.color)
			pNum:setText(award.count)
			awardSv:addChildToRight(awardImg)
			if award.quality == AWARD_QUALITY.SRED then
				local light = CUIEffect:create()
				light:Show("yellow_light", 0)
				light:setScale(0.8)
				local contentSize = pIco:getContentSize()
				light:setPosition(ccp(contentSize.width * 0.5 , contentSize.height * 0.5))
				light:setAnchorPoint(ccp(0.5, 0.5))
				pIco:getContainerNode():addChild(light)
				light:setZOrder(100)
			end
		end
		if awardNum == 1 then
			awardSv:setPosition(ccp(140,150))
		elseif awardNum == 2 then
			awardSv:setPosition(ccp(75,150))
		end

		if onlyConfirm then
			info_tx:setVisible(false)
			cancelBtn:setTouchEnable(false)
			cancelBtn:setPressState(WidgetStateDisabled)
			awardSv:setPosition(ccp(51,170))
		end
	end)
    CUIManager:GetInstance():ShowObject(showAward, ELF_SHOW.SMART)
end
-- 奖励总览界面
-- awards 奖励数组 
-- infoTx 提示信息text
function genShowTotalAwardsPanel(awards,infoTx )
	local showAward = SceneObjEx:createObj('panel/thousandfloor_res_panel.json', 'show-award-total-panel')
    local panel = showAward:getPanelObj()
    panel:setAdaptInfo('gain_res_bg_img', 'gain_res_img')

    panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		local gainBgImg = tolua.cast(root:getChildByName('gain_res_bg_img'),'UIImageView')
		local gainImg = tolua.cast(gainBgImg:getChildByName('gain_res_img'),'UIImageView')

		local know_btn = tolua.cast(gainImg:getChildByName('know_btn'),'UITextButton')
		GameController.addButtonSound(know_btn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		know_btn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(showAward, ELF_HIDE.SMART_HIDE)
		end)

		local info_tx = tolua.cast(gainImg:getChildByName('info_tx') , 'UILabel')
		info_tx:setPreferredSize(370,1)
		info_tx:setText(infoTx)

		local awardSv = tolua.cast(gainImg:getChildByName('award_sv') , 'UIScrollView')
		awardSv:setClippingEnable(true)
		awardSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
		local awardNum = #awards
		for k, v in pairs(awards) do
			local award = UserData:getAward(v)
			local awardImg = createWidgetByName('panel/thousandfloor_award_panel.json')
			local awardRoot = tolua.cast(awardImg:getChildByName('res_photo_ico') , 'UIImageView')
			local pIco = tolua.cast(awardRoot:getChildByName('res_ico') , 'UIImageView')
			local pName = tolua.cast(awardRoot:getChildByName('res_name_tx') , 'UILabel')
			local pNum = tolua.cast(awardRoot:getChildByName('res_num_tx') , 'UILabel')
			pName:setPreferredSize(120,1)
			pIco:setTouchEnable(true)
			pIco:registerScriptTapHandler( function()
				UISvr:showTipsForAward(v)
			end )
			pIco:setTexture(award.icon)
			pIco:setAnchorPoint(ccp(0,0))
			pName:setText(award.name)
			pName:setColor(award.color)
			pNum:setText(toWordsNumber(award.count))
			awardSv:addChildToRight(awardImg)
		end
		if awardNum == 1 then
			awardSv:setPosition(ccp(140,130))
		elseif awardNum == 2 then
			awardSv:setPosition(ccp(75,130))
		end
	end)
    CUIManager:GetInstance():ShowObject(showAward, ELF_SHOW.SMART)
end