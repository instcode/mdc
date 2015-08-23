-- 创建军团页面

-- TEST STRING: 创建军团将消耗1000元宝，是否确认？

LegionCreatePage = LegionPage:new{
	jsonFile = 'panel/legion_create_panel.json',
	panelName = 'legion-create-panel',

	nameEditbox = nil,
	descEditbox = nil,
	badgeImg = nil,
	levelEditbox = nil,
	levelNum = 0,
	legionType = 0,
	levelLimit = 0,
	flagIndex = 1
}

function LegionCreatePage:updateNumbers()
	local ct = self.levelEditbox:getTextFromInt()
	if ct < 0 then 
		return 
	end
	self.levelLimit = ct
end

function LegionCreatePage:init()
	local levelConf = GameData:getArrayData('level.dat')
	local MAX_LEVEL = #levelConf
	local MIN_LEVEL = getGlobalIntegerValue('LegionOpenLevel', 34)
	self.levelNum = MIN_LEVEL
	local createBgImg = tolua.cast(self.panel:getChildByName('create_bg_img'), 'UIImageView')
	local createSv = tolua.cast(createBgImg:getChildByName('create_sv'), 'UIScrollView')
	local createPl = tolua.cast(createSv:getChildByName('create_pl'), 'UIPanel')
	createSv:setClippingEnable(true)

	self.cashNumTx = tolua.cast(createPl:getChildByName('cash_tx'), 'UILabel')
	self.levelLimit = MIN_LEVEL
	self.cashNumTx:setText(tonumber(LegionConfig:getValueForKey('CashCreate')))

	local legionNameBgIco = tolua.cast(createPl:getChildByName('legion_name_bg_ico'), 'UIImageView')
	self.nameEditbox = self:createCCEditbox(self.panel, 'legion_name_bg_ico')
	self.nameEditbox:setFontSize(20)
	self.nameEditbox:registerScriptEditBoxHandler( function (eventType)
		if eventType == 'ended' then
			local nameText = self.nameEditbox:getText()
			nameText = CheckAndModifyStr(nameText)
			self.nameEditbox:setText(nameText)
		elseif eventType == 'began' then
			self.nameEditbox:setPosition(legionNameBgIco:getPosition())
		end
	end)

	local bulletinNameBgIco = tolua.cast(createPl:getChildByName('bulletin_name_bg_ico'), 'UIImageView')
	self.descEditbox = self:createCCEditbox(self.panel, 'bulletin_name_bg_ico')
	self.descEditbox:setFontSize(30)
	self.descEditbox:setFontName('Arial')
	self.descEditbox:setVAlignment(kCCVerticalTextAlignmentTop)
	self.descEditbox:registerScriptEditBoxHandler( function (eventType)
		if eventType == 'ended' then
			local noticeText = self.descEditbox:getText()
			noticeText = CheckAndModifyStr(noticeText)
			self.descEditbox:setText(noticeText)
		elseif eventType == 'began' then
			self.descEditbox:setPosition(bulletinNameBgIco:getPosition())
		end
	end)

	self.levelEditbox = self:createCCEditbox(self.panel, 'lv_bg_ico')
	self.levelEditbox:setFontSize(24)
	self.levelEditbox:setInputMode(kEditBoxInputModeNumeric)
	self.levelEditbox:setHAlignment(kCCTextAlignmentCenter)
	self.levelEditbox:setTextFromInt(MIN_LEVEL)
	
	self:registerButtonWithHandler(self.panel, 'change_tbtn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
		LegionController.show(LegionBadgePanel, ELF_SHOW.SMART)
	end)

	local leftBtn = tolua.cast(createPl:getChildByName('left_btn'), 'UIButton')
	local rightBtn = tolua.cast(createPl:getChildByName('right_btn'), 'UIButton')
	leftBtn:disable()
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

	self.legionType = 0
	local checkCb1 = tolua.cast(createPl:getChildByName('check_1_ico'), 'UICheckBox')
	local checkCb2 = tolua.cast(createPl:getChildByName('check_2_ico'), 'UICheckBox')
	checkCb1:setSelectedState(true)
	checkCb2:setSelectedState(false)
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

	local createBtn = tolua.cast(createPl:getChildByName('create_btn'), 'UIButton')
	GameController.addButtonSound(createBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	-- 创建公会按钮
	createBtn:registerScriptTapHandler( function ()
		self:setInputEnabled(false)
		local legionName = self.nameEditbox:getText()
		local legionNameLen = string.utf8len(legionName)
		if legionNameLen == 0 then
			GameController.showMessageBox(LegionConfig:getLegionLocalText('LEGION_NAME_EMPTY'), MESSAGE_BOX_TYPE.OK)
			return
		elseif legionNameLen > tonumber(LegionConfig:getValueForKey('NameMax')) then
			GameController.showMessageBox(string.format(LegionConfig:getLegionLocalText('LEGION_NAME_TOO_LONG'), tonumber(LegionConfig:getValueForKey('NameMax'))), MESSAGE_BOX_TYPE.OK)
			return
		else 
			-- 匹配汉字和字母和数字
			--'[^\128-\254^%w]'
			local symbolIndex = string.find(legionName, '[^\128-\254^%w]')--\7840-\\7929^\\1-\\127^\\194-\\244^\\128-\\191]")

			-- '[%z\1-\127\194-\244][\128-\191]*'
			-- symbolIndex = string.find(legionName, '[^\\7840-\\7929^%w]')
			-- symbolIndex = string.find(legionName, '[^\\192-\\432^%w]')
			if symbolIndex then
				GameController.showMessageBox(LegionConfig:getLegionLocalText('LEGION_NAME_RULE'), MESSAGE_BOX_TYPE.OK)
				return
			end
		end
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
		LegionCreatePage:setInputEnabled(false)
		GameController.showMessageBox(string.format(LegionConfig:getLegionLocalText('LEGION_CONFIRM_CREATE'), tonumber(LegionConfig:getValueForKey('CashCreate'))), MESSAGE_BOX_TYPE.OK_CANCEL, function ()
			LegionCreatePage:setInputEnabled(true)
			if PlayerCoreData.getCashValue() < tonumber(LegionConfig:getValueForKey('CashCreate')) then
				GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
				return
			end
			LegionController.sendLegionCreateRequest( legionName, legionDesc, self.flagIndex, self.legionType, self.levelLimit, function (response)
				local code = tonumber(response.code)
				if code == 0 then
					PlayerCoreData.addCashDelta(response.data.cash)
					LegionController.close(LegionCreateRootPanel, ELF_HIDE.HIDE_NORMAL)
					LegionController.show(LegionMainPanel, ELF_SHOW.NORMAL)
					GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_CREATE_SUCCESS'), COLOR_TYPE.GREEN)
				end
			end )
		end)
	end )

	self.badgeImg = tolua.cast(self.panel:getChildByName('badge_ico'), 'UIImageView')
end

function LegionCreatePage:release()
	LegionPage.release(self)

	self.nameEditbox = nil
	self.descEditbox = nil
	self.badgeImg = nil
	self.levelEditbox = nil
	self.levelNum = nil
	self.cashNumTx = nil
	self.legionType = nil
	self.levelLimit = nil
	self.flagIndex = nil
end

function LegionCreatePage:setInputEnabled( enable )
	if self.nameEditbox then
		self.nameEditbox:setTouchEnabled(enable)
	end

	if self.descEditbox then
		self.descEditbox:setTouchEnabled(enable)
	end

	if self.levelEditbox then
		self.levelEditbox:setTouchEnabled(enable)
	end
end

function LegionCreatePage:updateBadge( badgeIcon , index)
	if self and self.badgeImg then
		self.flagIndex = index
		self.badgeImg:setTexture(badgeIcon)
	end
end
