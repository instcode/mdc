-- 军团设置界面

LegionSetingPanel = LegionView:new{
	jsonFile = 'panel/legion_setting_panel.json',
	panelName = 'legion-seting-panel',

	descEditbox = nil,
	badgeImg = nil,
	levelEditbox = nil,
	levelNum = 0,
	legionType = 0,
	levelLimit = 0,
	flagIndex = 1
}

function LegionSetingPanel:updateNumbers()
	local ct = self.levelEditbox:getTextFromInt()
	if ct < 0 then 
		return 
	end
	self.levelLimit = ct
end

function LegionSetingPanel:showChangeBadgePanel()
	LegionController.show(LegionBadgePanel, ELF_SHOW.SMART)
	self:setInputEnabled(false)
	print('disable input ... ')
end

function LegionSetingPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('set_bg_img', 'set_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		self:registerButtonWithHandler(root, 'set_bg_img', nil, function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		local levelConf = GameData:getArrayData('level.dat')
		local MAX_LEVEL = #levelConf
		local MIN_LEVEL = getGlobalIntegerValue('LegionOpenLevel', 34)
		self.levelNum = MIN_LEVEL

		self.levelLimit = MyLegion.level_limit
		if self.levelLimit < MIN_LEVEL then
			self.levelLimit = MIN_LEVEL
		end

		local nameTx = tolua.cast(root:getChildByName('legion_name_tx') , 'UILabel')
		nameTx:setText(MyLegion.name)

		self.descEditbox = self:createCCEditbox(root, 'notice_bg_img')
		self.descEditbox:setFontSize(18)
		self.descEditbox:setVAlignment(kCCVerticalTextAlignmentTop)
		self.descEditbox:setText(MyLegion.notice)
		self.descEditbox:registerScriptEditBoxHandler( function (eventType)
			if eventType == 'ended' then
				local noticeText = self.descEditbox:getText()
				noticeText = CheckAndModifyStr(noticeText)
				self.descEditbox:setText(noticeText)
			end
		end)

		self.levelEditbox = self:createCCEditbox(root, 'su_bg_img')
		self.levelEditbox:setInputMode(kEditBoxInputModeNumeric)
		self.levelEditbox:setHAlignment(kCCTextAlignmentCenter)
		self.levelEditbox:setTextFromInt(self.levelLimit)
		self.levelEditbox:setFontSize(30)
		
		local changeTx = tolua.cast(root:getChildByName('change_tx') , 'UILabel')
		changeTx:registerScriptTapHandler(function ()
			self:showChangeBadgePanel()
		end)

		local leftBtn = tolua.cast(root:getChildByName('left_btn'), 'UIButton')
		local rightBtn = tolua.cast(root:getChildByName('right_btn'), 'UIButton')

		if self.levelLimit <= MIN_LEVEL then
			leftBtn:disable()
		end
		if self.levelLimit >= MAX_LEVEL then
			rightBtn:disable()
		end
		
		-- 点击
		leftBtn:registerScriptTapHandler( function ()
			CNumEditorAct:getInst():numDecOnce(leftBtn, self.levelEditbox, rightBtn, MIN_LEVEL)
			self:updateNumbers()
		end )
		-- 长按
		leftBtn:registerScriptLongPressHandler( function ()
			CNumEditorAct:getInst():numDec(leftBtn,self.levelEditbox,rightBtn,MIN_LEVEL)
			CNumEditorAct:getInst():registerScriptNumDecHandler( function ()
				self:updateNumbers()
			end )
		end )
		-- 取消长按
		leftBtn:registerScriptLongPressEndHandler( function ()
			CNumEditorAct:getInst():stop()
		end )
		-- 点击
		rightBtn:registerScriptTapHandler( function ()
			CNumEditorAct:getInst():numAddOnce(leftBtn, self.levelEditbox, rightBtn, MAX_LEVEL)
			self:updateNumbers()
		end )
		-- 长按
		rightBtn:registerScriptLongPressHandler( function ()
			CNumEditorAct:getInst():numAdd(leftBtn,self.levelEditbox,rightBtn,MAX_LEVEL)
			CNumEditorAct:getInst():registerScriptNumAddHandler( function ()
				self:updateNumbers()
			end )
		end )
		-- 取消长按
		rightBtn:registerScriptLongPressEndHandler( function ()
			CNumEditorAct:getInst():stop()
		end )

		self.levelEditbox:registerScriptEditBoxHandler( function (eventType)
			print(eventType)
			if eventType == 'ended' then
				local num = self.levelEditbox:getTextFromInt()
				if num < MIN_LEVEL or num > MAX_LEVEL then
					self.levelEditbox:setTextFromInt(self.levelNum)
				else	
					if num == MIN_LEVEL then
						leftBtn:disable()
						rightBtn:active()
					elseif num == MAX_LEVEL then
						rightBtn:disable()
						leftBtn:active()
					else
						leftBtn:active()
						rightBtn:active()
					end
					self.levelEditbox:setTextFromInt(num)
				end
				self:updateNumbers()
			elseif eventType == 'began' then
				self.levelNum = self.levelEditbox:getTextFromInt()
			end
		end )

		self.legionType = MyLegion.join_type
		local checkCb1 = tolua.cast(root:getChildByName('check_1_cb'), 'UICheckBox')
		local checkCb2 = tolua.cast(root:getChildByName('check_2_cb'), 'UICheckBox')
		checkCb1:setSelectedState(self.legionType == 0)
		checkCb2:setSelectedState(self.legionType == 1)
		checkCb1:addSelectEventHandler(function ()
			self.legionType = 0
			checkCb2:setSelectedState(false)
		end)
		checkCb1:addUnSelectEventHandler(function ()
			checkCb1:setSelectedState(true)
		end)

		checkCb2:addSelectEventHandler(function ()
			self.legionType = 1
			checkCb1:setSelectedState(false)
		end)
		checkCb2:addUnSelectEventHandler(function ()
			checkCb2:setSelectedState(true)
		end)

		local saveBtn = tolua.cast(root:getChildByName('save_tbtn'), 'UIButton')
		GameController.addButtonSound(saveBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		-- 保存按钮
		saveBtn:registerScriptTapHandler( function ()
			local legionDesc = self.descEditbox:getText()
			local legionDescLen = string.utf8len(legionDesc)
			if legionDescLen > tonumber(LegionConfig:getValueForKey('NoticeMax')) then
				GameController.showMessageBox(string.format(LegionConfig:getLegionLocalText('LEGION_DESC_TOO_LONG'),tonumber(LegionConfig:getValueForKey('NoticeMax'))), MESSAGE_BOX_TYPE.OK)
				return
			else
				local symbolIndex = string.find(legionDesc, '[%$%.]')
				if symbolIndex then
					GameController.showMessageBox(LegionConfig:getLegionLocalText('LEGION_DESC_RULE'), MESSAGE_BOX_TYPE.OK)
					return
				end
			end

			LegionController.sendLegionSettingRequest(legionDesc, self.flagIndex, self.legionType, self.levelLimit, function (response)
				local code = tonumber(response.code)
				if code == 0 then
					GameController.showPrompts(LegionConfig:getLegionLocalText('E_STR_LEGION_SETTING_SUCCESS_DESC'), COLOR_TYPE.GREEN)
					LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)

					LegionMainPanel:update()
				end
			end )
		end)

		self.badgeImg = tolua.cast(root:getChildByName('emblem_ico'), 'UIImageView')
		self.badgeImg:registerScriptTapHandler(function ()
			self:showChangeBadgePanel()
		end)
		self:updateBadge(MyLegion:getLegionBadge() , MyLegion.icon)
	end)

	panel:registerOnShowHandler(function ()
		print('enable input ... ')
		self:setInputEnabled(true)
	end)
end

function LegionSetingPanel:release()
	LegionView.release(self)

	self.descEditbox = nil
	self.badgeImg = nil
	self.levelEditbox = nil
	self.levelNum = nil
	self.legionType = nil
	self.levelLimit = nil
	self.flagIndex = nil
end

function LegionSetingPanel:setInputEnabled( enable )
	if self.descEditbox then
		self.descEditbox:setTouchEnabled(enable)
	end

	if self.levelEditbox then
		self.levelEditbox:setTouchEnabled(enable)
	end
end

function LegionSetingPanel:updateBadge( badgeIcon , index)
	if self and self.badgeImg then
		self.flagIndex = index
		self.badgeImg:setTexture(badgeIcon)
	end
end
