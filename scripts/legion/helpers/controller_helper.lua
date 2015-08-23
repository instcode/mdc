ControllerHelper = {
	
}

function ControllerHelper.handleErrorCode( code )
	if code == 0 then
		return true
	elseif code == 102 then -- 军团起名重复
		if LegionCreatePage.panel then
			LegionCreatePage:setInputEnabled( false )
		end
		GameController.showMessageBox(LegionConfig:getLegionLocalText('LEGION_NAME_REPETITION'), MESSAGE_BOX_TYPE.OK)
	elseif code == 101 then -- 军团起名非法
		if LegionCreatePage.panel then
			LegionCreatePage:setInputEnabled( false )
		end
		GameController.showMessageBox(LegionConfig:getLegionLocalText('LEGION_NAME_RULE'), MESSAGE_BOX_TYPE.OK)
	elseif code == 104 then -- 军团申请人数达到上限
		GameController.showMessageBox(LegionConfig:getLegionLocalText('LEGION_MAX_APPLY_PEOPLE'), MESSAGE_BOX_TYPE.OK)
	elseif code == 100 then	-- 军团数据过期
		GameController.showMessageBox(LegionConfig:getLegionLocalText('LEGION_SERVER_DATA_CHANGED'), MESSAGE_BOX_TYPE.OK, function ()
			CloseAllPanels()
		end)
	elseif code == 105 then
		GameController.showMessageBox(LegionConfig:getLegionLocalText('LEGION_ALEADY_JOINED_OTHERS'), MESSAGE_BOX_TYPE.OK, function ()
			CloseAllPanels()
		end)
	elseif code == 200 then -- 军团战数据过期
		if LegionWarBattlePanel.panel ~= nil then -- 如果军团战界面存在
			LegionWarController.sendLegionWarGetBattleFieldRequest(function ( res )
				local code = res.code
				if code == 0 then
					GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_SERVER_DATA_CHANGED_REFRESH'), COLOR_TYPE.GREEN)
					-- 更新战场主界面
					LegionWarBattlePanel:update()
					if LegionWarCityPanel.panel ~= nil then -- 如果军团战中city界面存在
						-- 更新city界面
						LegionWarCityPanel:requestCityInfo()
					end
				end
			end)
		end
	else
		return false
	end
	
	return false
end