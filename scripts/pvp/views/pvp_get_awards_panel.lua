PvpGetAwardsPanel = PvpView:new{
	jsonFile = 'panel/pvp_get_award_panel.json',
	panelName = 'pvp-get-awards-in-lua',
	awards,
	awardsTab
}

function PvpGetAwardsPanel:getCellName(index)
	if index == 1 then
		return getLocalStringValue('E_STR_PVP_WAR_AWARDS_DESC1')
	elseif index == 2 then
		return getLocalStringValue('E_STR_PVP_WAR_AWARDS_DESC2')
	elseif index == 3 then
		return getLocalStringValue('E_STR_PVP_WAR_AWARDS_DESC2')
	elseif index == 4 then
		return getLocalStringValue('E_STR_PVP_WAR_AWARDS_DESC3')
	elseif index == 5 then
		return getLocalStringValue('E_STR_PVP_WAR_AWARDS_DESC4')
	end
end
function PvpGetAwardsPanel:createAwardsPanel()
	for i=1,#self.awards do
		local view = createWidgetByName('panel/pvp_award_card_panel.json')
		
		awardNameTx = tolua.cast(view:getChildByName('award_name_tx') , 'UILabel')
		awardNameTx:setPreferredSize(150,1)
		awardNameTx:setText(self:getCellName(self.awardsTab[i]))
		for j=1,4 do
			str = 'frame_'..j..'_img'
			frameImg = tolua.cast(view:getChildByName(str) , 'UIImageView')
			if j > #self.awards[i] then
				frameImg:setVisible(false)
			else
				frameImg:setVisible(true)
				numberTx = tolua.cast(frameImg:getChildByName('number_tx') , 'UILabel')
				awardImg = tolua.cast(frameImg:getChildByName('award_img') , 'UIImageView')
				nameTx = tolua.cast(frameImg:getChildByName('name_tx') , 'UILabel')
				nameTx:setPreferredSize(110,1)

				local str1 = self.awards[i][j][1]..'.'..self.awards[i][j][2]..':'..self.awards[i][j][3]
				local award = UserData:getAward(str1)

				numberTx:setText(toWordsNumber(tonumber(award.count)))
				nameTx:setText(award.name)
				awardImg:setTexture(award.icon)
				awardImg:registerScriptTapHandler(function()
					UISvr:showTipsForAward(str1)
				end)
			end
		end
		self.award_sv:addChildToBottom(view)
		UserData.parseAwardJson(json.encode(self.awards[i]))
	end
	self.award_sv:scrollToTop()
end

function PvpGetAwardsPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('pvp_award_bg_img','award_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		
		self.award_sv = tolua.cast(root:getChildByName('award_sv') , 'UIScrollView')
		self.award_sv:setClippingEnable(true)
		
		gotBtn = tolua.cast(root:getChildByName('got_btn') , 'UIButton')
    	gotBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(gotBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		self:createAwardsPanel()
	end)
end

function PvpGetAwardsPanel:enter(index,data)
	self.awards = data
	self.awardsTab = index
	PvpController.show(PvpGetAwardsPanel, ELF_SHOW.SLIDE_IN)
end