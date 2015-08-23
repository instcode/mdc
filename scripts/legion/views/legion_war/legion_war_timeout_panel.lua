LegionWarTimeoutPanel = LegionView:new{
	jsonFile = 'panel/legion_war_timeout_panel.json',
	panelName = 'legion-war-timeout-panel'
}

function LegionWarTimeoutPanel:init()
	local panel = self.sceneObject:getPanelObj()

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		local grayImg = tolua.cast(root:getChildByName('legion_timeout_bg_img'), 'UIImageView')
		local winSize = CCDirector:sharedDirector():getWinSize()
		grayImg:setScale9Enable(true)
		grayImg:setPosition(ccp(winSize.width / 2, winSize.height / 2))
		grayImg:setScale9Size(winSize)

		local timeImg = tolua.cast(root:getChildByName('num_img'), 'UIImageView')
		local times = 10
		local scheduleId = 0
		scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function ()
			times = times - 1
			-- 倒计时结束再去结算
			if times == 0 then
				LegionWarController.sendLegionWarEndWarrequest(function ( res )
					LegionController.close(self, ELF_HIDE.HIDE_NORMAL)
					local code = res.code
					if code == 0 then
						LegionWarResultPanel:showWithData(res.data)
					end
				end)
				if scheduleId ~= 0 then
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
					scheduleId = 0
				end
			else
				timeImg:setTexture('uires/ui_2nd/com/panel/vip/' .. times .. '.png')
			end
		end,1,false)
	end)
end

function LegionWarTimeoutPanel:release()
	LegionView.release(self)
end