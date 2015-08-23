-- 加入、创建军团主界面

LegionCreateRootPanel = LegionView:new{
	jsonFile = 'panel/legion_bg_panel.json',
	panelName = 'legion-bg-panel',

	tags = { 'join_btn', 'create_btn' },
	pages = { LegionJoinPage, LegionCreatePage }
}

function LegionCreateRootPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('legion_bg_img', 'legion_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		
		self.container = tolua.cast(root:getChildByName('content_pl'), 'UIPanel')

		local cashIco = tolua.cast(root:getChildByName('cash_ico'), 'UIImageView')
		local cashNumTx = tolua.cast(root:getChildByName('cash_num_tx'), 'UILabel')
		local cash = PlayerCoreData.getCashValue()
		cashNumTx:setText(CStringUtil:numToStr(cash))

		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.SLIDE_OUT)
		end)

		table.foreach(self.tags, function ( i, v )
			self.tags[i] = self:registerButtonWithHandler(root, v, BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
				self:switchPage(i)
				if i == 1 then
					cashIco:setVisible(false)
					cashNumTx:setVisible(false)
				elseif i == 2 then
					cashIco:setVisible(true)
					cashNumTx:setVisible(true)
				end
			end)
		end)

		self:switchPage(1)
	end)

	panel:registerOnShowHandler(function()
		LegionCreatePage:setInputEnabled(true)
	end)
	UpdateSceneId(30091)
end


function LegionCreateRootPanel:release()
	LegionView.release(self)
end