LegionTipsPanel = LegionView:new{
	jsonFile = 'panel/legion_tips_panel.json',
	panelName = 'legion-tips-panel'
}


function LegionTipsPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('tips_bg_img', 'tips_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
	end)
end