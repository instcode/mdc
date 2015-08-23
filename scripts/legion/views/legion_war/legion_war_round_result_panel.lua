LegionWarRoundResultPanel = LegionView:new{
	jsonFile = 'panel/legion_war_round_result_panel.json',
	panelName = 'legion-war-round-result-panel',

	cells = nil
}


function LegionWarRoundResultPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('info_bg_img', 'info_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionWarController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		local sv = tolua.cast(root:getChildByName('result_sv'), 'UIScrollView')

		self.cells = {}
		for i = 1, 10 do
			table.insert(self.cells, LegionWarRoundResultCell:createCell())
		end

		self:bindCellsToScrollView(self.cells, sv, SCROLLVIEW_DIR_VERTICAL)
		sv:scrollToTop()
		sv:setClippingEnable(true)
	end)
end