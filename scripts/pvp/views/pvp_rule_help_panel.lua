PvpRuleHelpPanel = PvpView:new{
	jsonFile = 'panel/pvp_rule_help_panel.json',
	panelName = 'pvp-rule-help-panel'
}

function PvpRuleHelpPanel:init()
	self.panel:setAdaptInfo('help_bg_img', 'help_img')
	self.panel:registerInitHandler(function()
		local root = self.panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			PvpController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		self:registerButtonWithHandler(root, 'help_bg_img', nil, function()
			PvpController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		local sv = tolua.cast(root:getChildByName('system_sv'), 'UIScrollView')
		local infoTx1 = tolua.cast(sv:getChildByName('info_1_tx'), 'UILabel')
		infoTx1:setText(getLocalStringValue('E_STR_PVP_RULE_HELP_DESC1'))
		infoTx1:setPreferredSize(580,1)
		local infoTx2 = tolua.cast(sv:getChildByName('info_2_tx'), 'UILabel')
		infoTx2:setText(getLocalStringValue('E_STR_PVP_RULE_HELP_DESC2'))
		infoTx2:setPreferredSize(580,1)
		local infoTx3 = tolua.cast(sv:getChildByName('info_3_tx'), 'UILabel')
		infoTx3:setText(getLocalStringValue('E_STR_PVP_RULE_HELP_DESC3'))
		infoTx3:setPreferredSize(580,1)
		local infoTx4 = tolua.cast(sv:getChildByName('info_4_tx'), 'UILabel')
		infoTx4:setText(getLocalStringValue('E_STR_PVP_RULE_HELP_DESC4'))
		infoTx4:setPreferredSize(580,1)
		sv:setClippingEnable(true)
		sv:scrollToTop()
	end)
end