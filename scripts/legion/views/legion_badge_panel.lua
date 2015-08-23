-- 军团徽章界面

LegionBadgePanel = LegionView:new{
	jsonFile = 'panel/legion_badge_panel.json',
	panelName = 'legion-badge-panel'
}

function LegionBadgePanel:init()
	local MAX_BADGE_NUM = LegionConfig:getValueForKey('IconNum')			-- 图标总数量
	local BADGE_NUM_PER_ROW = 4			-- 每行图标数量

	local panel = self.sceneObject:getPanelObj()
	
	panel:setAdaptInfo('badge_bg_img', 'badge_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		local badgeBgImg = tolua.cast(root:getChildByName('badge_bg_img'), 'UIImageView')
		local badgeImg = tolua.cast(badgeBgImg:getChildByName('badge_img'), 'UIImageView')
		local closeBtn = tolua.cast(badgeImg:getChildByName('close_btn'), 'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		local badgeImg = tolua.cast(badgeImg:getChildByName('badge_img'), 'UIImageView')
		local badgeSv = tolua.cast(badgeImg:getChildByName('badge_sv'), 'UIScrollView')
		local uiPanel = UIPanel:create()
		local width = badgeSv:getContentSize().width
		local height = 104 + (math.ceil(MAX_BADGE_NUM/BADGE_NUM_PER_ROW)-1)*100
		print('height' .. height)
		uiPanel:setSize(CCSizeMake(width,height))
		uiPanel:setPosition(ccp(0,0))
		for i = 1, MAX_BADGE_NUM do
			local badgeIco = UIImageView:create()
			local badgeResource = 'uires/ui_2nd/com/panel/legion/' .. i .. '_jun.png'
			badgeIco:setTexture(badgeResource)
			badgeIco:setTouchEnable(true)
			badgeIco:registerScriptTapHandler(function ()
				LegionCreatePage:updateBadge(badgeResource, i)
				LegionSetingPanel:updateBadge(badgeResource , i)
				LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
			end)
			uiPanel:addChild(badgeIco)
			-- 坐标规范
			-- 第一竖排图标距离左边60，最后一竖排图标距离右边60 中间其他图标的间隔平均分
			-- 第一横排图标距离上边边缘52，最后一横排图标距离下边边缘52 上下图标间隔100
			local x = 60 + math.mod(i-1, BADGE_NUM_PER_ROW)*(width-120)/(BADGE_NUM_PER_ROW-1)
			local y = height - 52 - (math.ceil(i/BADGE_NUM_PER_ROW) - 1)*100
			badgeIco:setPosition(ccp(x, y))
			print('y = ' .. y)
		end
		badgeSv:setClippingEnable(true)
		badgeSv:setDirection(SCROLLVIEW_DIR_VERTICAL)
		badgeSv:addChild(uiPanel)
		badgeSv:scrollToTop()
	end)

	panel:registerOnShowHandler(function()
		LegionCreatePage:setInputEnabled(false)
	end)

	panel:registerOnHideHandler(function()
		
	end)
end