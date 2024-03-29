LegionWarHelpPanel = LegionView:new{
	jsonFile = 'panel/legion_war_help_panel.json',
	panelName = 'legion-war-help-panel'
}

function LegionWarHelpPanel:init()
	self.panel:setAdaptInfo('help_img', 'tavern_help_img')
	self.panel:registerInitHandler(function()
		local root = self.panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		local sv = tolua.cast(root:getChildByName('system_sv'), 'UIScrollView')
		sv:setClippingEnable(true)
		sv:scrollToTop()

		local infoTx1 = tolua.cast(sv:getChildByName('info_1_tx'), 'UILabel')
		infoTx1:setText(getLocalStringValue('HELP_LEGION_WAR_1'))
		infoTx1:setPreferredSize(580,1)
		local infoTx2 = tolua.cast(sv:getChildByName('info_2_tx'), 'UILabel')
		infoTx2:setText(getLocalStringValue('HELP_LEGION_WAR_2'))
		infoTx2:setPreferredSize(580,1)
		local infoTx3 = tolua.cast(sv:getChildByName('info_3_tx'), 'UILabel')
		infoTx3:setText(getLocalStringValue('HELP_LEGION_WAR_3'))
		infoTx3:setPreferredSize(580,1)
		local infoTx4 = tolua.cast(sv:getChildByName('info_4_tx'), 'UILabel')
		infoTx4:setText(getLocalStringValue('HELP_LEGION_WAR_4'))
		infoTx4:setPreferredSize(580,1)	
		local infoTx5 = tolua.cast(sv:getChildByName('info_5_tx'), 'UILabel')
		infoTx5:setText(getLocalStringValue('HELP_LEGION_WAR_5'))
		infoTx5:setPreferredSize(580,1)
		local infoTx6 = tolua.cast(sv:getChildByName('info_6_tx'), 'UILabel')
		infoTx6:setText(getLocalStringValue('HELP_LEGION_WAR_6'))
		infoTx6:setPreferredSize(580,1)	
		local infoTx7 = tolua.cast(sv:getChildByName('info_7_tx'), 'UILabel')
		infoTx7:setText(getLocalStringValue('HELP_LEGION_WAR_7'))
		infoTx7:setPreferredSize(580,1)	
		local infoTx8 = tolua.cast(sv:getChildByName('info_8_tx'), 'UILabel')
		infoTx8:setText(getLocalStringValue('HELP_LEGION_WAR_8'))
		infoTx8:setPreferredSize(580,1)	
		local infoTx9 = tolua.cast(sv:getChildByName('info_9_tx'), 'UILabel')
		infoTx9:setText(getLocalStringValue('HELP_LEGION_WAR_9'))
		infoTx9:setPreferredSize(580,1)	
		local infoTx10 = tolua.cast(sv:getChildByName('info_10_tx'), 'UILabel')
		infoTx10:setText(getLocalStringValue('HELP_LEGION_WAR_10'))
		infoTx10:setPreferredSize(580,1)	
		local infoTx11 = tolua.cast(sv:getChildByName('info_11_tx'), 'UILabel')
		infoTx11:setText(getLocalStringValue('HELP_LEGION_WAR_11'))
		infoTx11:setPreferredSize(580,1)	
		local infoTx12 = tolua.cast(sv:getChildByName('info_12_tx'), 'UILabel')
		infoTx12:setText(getLocalStringValue('HELP_LEGION_WAR_12'))
		infoTx12:setPreferredSize(580,1)	
		local infoTx13 = tolua.cast(sv:getChildByName('info_13_tx'), 'UILabel')
		infoTx13:setText(getLocalStringValue('HELP_LEGION_WAR_13'))
		infoTx13:setPreferredSize(580,1)	
		local infoTx14 = tolua.cast(sv:getChildByName('info_14_tx'), 'UILabel')
		infoTx14:setText(getLocalStringValue('HELP_LEGION_WAR_14'))
		infoTx14:setPreferredSize(580,1)	
		local infoTx15 = tolua.cast(sv:getChildByName('info_15_tx'), 'UILabel')
		infoTx15:setText(getLocalStringValue('HELP_LEGION_WAR_15'))
		infoTx15:setPreferredSize(580,1)	
		local infoTx16 = tolua.cast(sv:getChildByName('info_16_tx'), 'UILabel')
		infoTx16:setText(getLocalStringValue('HELP_LEGION_WAR_16'))
		infoTx16:setPreferredSize(580,1)	
		local infoTx17 = tolua.cast(sv:getChildByName('info_17_tx'), 'UILabel')
		infoTx17:setText(getLocalStringValue('HELP_LEGION_WAR_17'))
		infoTx17:setPreferredSize(580,1)	
		local infoTx18 = tolua.cast(sv:getChildByName('info_18_tx'), 'UILabel')
		infoTx18:setText(getLocalStringValue('HELP_LEGION_WAR_18'))
		infoTx18:setPreferredSize(580,1)	
		local infoTx19 = tolua.cast(sv:getChildByName('info_19_tx'), 'UILabel')
		infoTx19:setText(getLocalStringValue('HELP_LEGION_WAR_19'))
		infoTx19:setPreferredSize(580,1)	
	end)
end