LegionWarResultPanel = LegionView:new{
	jsonFile = 'panel/legion_war_result_panel.json',
	panelName = 'legion-war-result-panel'
}


function LegionWarResultPanel:showWithData( data )
	self.data = data
	LegionWarController.show(self, ELF_SHOW.ZOOM_IN)
end

function LegionWarResultPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('over_bg_img', 'over_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'ok_tbtn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			CloseAllPanels()
		end)

		local infoTx = tolua.cast(root:getChildByName('info_tx'), 'UILabel')
		infoTx:setPreferredSize(580,1)
		if tostring(self.data.wins[1][1]) == tostring(MyLegion.name) then -- 晋升成功
			if tonumber(LegionWar.progress) == 1 then -- 如果是最后一场
				infoTx:setText(LegionConfig:getLegionLocalText('LEGION_PROMOTE_EMPEROR'))
			else
				infoTx:setText(LegionConfig:getLegionLocalText('LEGION_BATTLE_PROMOTION_SUCCESS'))
			end
		else
			if tonumber(LegionWar.progress) == 1 then -- 如果是最后一场
				infoTx:setText('')
			else
				infoTx:setText(LegionConfig:getLegionLocalText('LEGION_BATTLE_PROMOTION_FAILED'))
			end
		end

		for i = 1, 3 do
			local pl = tolua.cast(root:getChildByName(i .. '_pl'), 'UIPanel')
			if self.data.wins[i] then
				pl:setVisible(true)
				local nameTx = tolua.cast(pl:getChildByName('name_tx'), 'UILabel')
				local junTx = tolua.cast(pl:getChildByName('jun_tx'), 'UILabel')
				local integralNumberTx = tolua.cast(pl:getChildByName('integral_number_tx'), 'UILabel')
				local stongTx = tolua.cast(pl:getChildByName('stong_tx'), 'UILabel')
				nameTx:setText(self.data.wins[i][1])
				integralNumberTx:setText(tostring(self.data.wins[i][2]))
				junTx:setText('+' .. LegionWarConfig:getRewardData(LegionWar.progress, i).LegionExp)
				stongTx:setText('+' .. LegionWarConfig:getRewardData(LegionWar.progress, i).Order)
				if tostring(self.data.wins[i][1]) == tostring(MyLegion.name) then -- 我的军团就设为绿色
					nameTx:setColor(COLOR_TYPE.GREEN)
					integralNumberTx:setColor(COLOR_TYPE.GREEN)
					junTx:setColor(COLOR_TYPE.GREEN)
					stongTx:setColor(COLOR_TYPE.GREEN)
				else
					nameTx:setColor(COLOR_TYPE.WHITE)
					integralNumberTx:setColor(COLOR_TYPE.WHITE)
					junTx:setColor(COLOR_TYPE.WHITE)
					stongTx:setColor(COLOR_TYPE.WHITE)
				end
			else
				pl:setVisible(false)
			end
		end
	end)
end

function LegionWarResultPanel:release()
	LegionView.release(self)
end