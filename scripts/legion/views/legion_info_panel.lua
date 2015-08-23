-- 军团信息界面

LegionInfoPanel = LegionView:new{
	jsonFile = 'panel/legion_info_panel.json',
	panelName = 'legion-info-panel',

	nameTx = nil,
	lvTx = nil,
	expTx = nil
}


function LegionInfoPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('info_bg_img', 'info_img')

	local function exitLegion()
		print('exit legion ... ')
		LegionController.sendLegionQuitRequest(function ()
			MyLegion.lid = 0	--手动置0
			CloseAllPanels()
		end)
	end

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		self:registerButtonWithHandler(root, 'info_bg_img', nil, function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		self.nameTx = tolua.cast(root:getChildByName('name_tx') , 'UILabel')
		self.lvTx = tolua.cast(root:getChildByName('lv_tx') , 'UILabel')
		self.expTx = tolua.cast(root:getChildByName('number_tx') , 'UILabel')

		local infoTx = tolua.cast(root:getChildByName('info_tx') , 'UILabel')
		infoTx:setColor(ccc3(72,194,53))
		infoTx:setPreferredSize(440,1)

		self:registerButtonWithHandler(root, 'set_up_tbtn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
			if MyLegion.position == 'commander' then
				LegionController.show(LegionSetingPanel , ELF_SHOW.SMART)
			else
				GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_NO_AUTHORITY') , COLOR_TYPE.RED)
			end
		end)
		self:registerButtonWithHandler(root, 'out_tbtn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
			if LegionWar:isWaring() then
				GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_CAN_NOT_OPERATE_DURING_WAR') , COLOR_TYPE.RED)
				return
			end

			if MyLegion.position == 'commander' then		-- 军团长
				if #MyLegion.members <= 1 then
					GameController.showMessageBox(LegionConfig:getLegionLocalText('E_STR_LEGION_DISMISS_DESC'), MESSAGE_BOX_TYPE.OK_CANCEL, exitLegion)
				else
					GameController.showPrompts(LegionConfig:getLegionLocalText('E_STR_LEGION_EXIT_DESC') , COLOR_TYPE.RED)
				end
			else
				GameController.showMessageBox(LegionConfig:getLegionLocalText('E_STR_LEGION_EXIT_TIME_PROMPT'), MESSAGE_BOX_TYPE.OK_CANCEL, exitLegion)
			end
		end)

		self:updateInfo()
	end)

	panel:registerOnShowHandler(function ()
		self:updateInfo()
	end)
end

function LegionInfoPanel:updateInfo()
	local data , maxLv = LegionConfig:getLegionLevelData(MyLegion.level)

	self.nameTx:setText(MyLegion.name)
	self.lvTx:setText(MyLegion.level .. (MyLegion.level >= maxLv and getLocalString('E_STR_GOLDMINE_FULL') or ''))
	self.expTx:setText(MyLegion.point .. '/' .. data.Exp)

end

function LegionInfoPanel:release()
	LegionView.release(self)
	self.nameTx = nil
	self.lvTx = nil
	self.expTx = nil
end