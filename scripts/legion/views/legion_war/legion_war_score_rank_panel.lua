LegionWarFieldRankPanel = LegionView:new{
	jsonFile = 'panel/legion_field_rank_panel.json',
	panelName = 'legion-war-score-rank-panel',
}

function LegionWarFieldRankPanel:showWithData( data )
	self.data = data
	LegionController.show(self , ELF_SHOW.SLIDE_IN)
end

function LegionWarFieldRankPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('di_ico', 'integra_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionWarController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		
		local turnTx = tolua.cast(root:getChildByName('round_tx') , 'UILabel')
		turnTx:setPreferredSize(680,1)

		if LegionWar.progress then
			local turn = tonumber(LegionWar.progress)
			local notice
			if turn == 9 then
				notice = 'LEGION_ONE_TURN_DESC'
			elseif turn == 3 then
				notice = 'LEGION_TWO_TURN_DESC'
			elseif turn == 1 then
				notice = 'LEGION_THREE_TURN_DESC'
			end
			turnTx:setText(LegionConfig:getLegionLocalText(notice) )
		else
			turnTx:setText('')
		end

		table.sort( self.data , function ( a , b )
			return a[1] > b[1]
		end)

		for i = 1 , 3 do
			local diIco = tolua.cast(root:getChildByName('di_' .. i .. '_ico') , 'UIImageView')
			local item = tolua.cast(root:getChildByName('medal_di_' .. i .. '_ico') , 'UIImageView')

			local leigonIco = tolua.cast(item:getChildByName('medal_ico') , 'UIImageView')
			local nameTx = tolua.cast(item:getChildByName('legion_name_tx') , 'UILabel')
			local scoreTx = tolua.cast(item:getChildByName('score_tx') , 'UILabel')

			if self.data and self.data[i] then
				leigonIco:setTexture('uires/ui_2nd/com/panel/legion/' .. self.data[i][3] .. '_jun.png')
				nameTx:setText( self.data[i][2] )
				scoreTx:setText( tostring(self.data[i][1]) or '')
			else
				diIco:setVisible(false)
				item:setVisible(false)
			end
		end

	end)
end