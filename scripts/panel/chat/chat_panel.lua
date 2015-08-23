local MATERIAL_DALABA_ID = 39
local Chat = {
	sceneObj = nil,
	rootImg = nil,
	closeBtn = nil,
	sendBtn = nil,
	chatSv = nil,
	editBox = nil,
	itemNameLabel = nil,
	itemCountLabel = nil,
	legionImg = nil,
	labaIco = nil,
	channelsBtn = {},
	isOpen = false,
	currentChannel = 1,
	firstInit = true,
	sendTime = 0,
	vecOldData = {{}, {}, {}, {}},
	vecNewData = {{}, {}, {}, {}}
}

-- Chat

function Chat:sendLegion(name, content)
	local args = {
		name = name,
		content = content
	}
	Message.sendPost('legiontalk', 'message', json.encode(args), function(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic.code ~= 0 then
			return
		end
		self.sendTime = UserData:getServerTime()
		local chatData = {
			time = UserData:getServerTime(),
			name = jsonDic.args.name,
			content = jsonDic.args.content,
			vip = PlayerCoreData.getPlayerVIP()
		}
		table.insert(self.vecNewData[CHAT_CHANNEL.LEGION], chatData)
		self:clearInputWords()
		self:updateChat(CHAT_CHANNEL.LEGION)
	end)
end

function Chat:sendLoudSpeaker(name, content)
	local labaNum = PlayerCoreData.getMaterialCount(MATERIAL_DALABA_ID)
	if labaNum <= 0 then
		-- 大喇叭不足 需要去买
		GameController.showMessageBox(getLocalStringValue('E_STR_CHAT_NOT_ENOUGH_DA'), MESSAGE_BOX_TYPE.OK_CANCEL, function ()
			local dalaba = PlayerCoreData.getMaterialById(MATERIAL_DALABA_ID)
			local shopId = getShopIDBymaterialID(MATERIAL_DALABA_ID, 1)
			local shopConf = GameData:getMapData('shop.dat')
			local data = {
				id = MATERIAL_DALABA_ID,
				name = dalaba:GetMaterialName(),
				count = 0,
				color = dalaba:GetMaterialNameColor(),
				icon = dalaba:GetResource(),
				desc = dalaba:GetDesc(),
				price = shopConf[tostring(shopId)].Price
			}
			openShopBuyPanel(data, function (id, ct)
				local buyArgs = {
					id = shopId,
					num = ct
				}
				Message.sendPost('buy', 'inventory', json.encode(buyArgs), function(jsonData2)
					local jsonDic2 = json.decode(jsonData2)
					if jsonDic2.code ~= 0 then
						return
					end
					if jsonDic2.data.awards then
						UserData.parseAwardJson( json.encode(jsonDic2.data.awards) )
   					end
   					local cost = jsonDic2.data.cost_num or 0
   					local costType = jsonDic2.data.cost_type
   					if costType == 'cash' then
						PlayerCoreData.addCashDelta(cost)
					end
   					GameController.showPrompts(getLocalStringValue('E_STR_BUY_SUCCEED'), COLOR_TYPE.GREEN)
				end)
			end)
		end)
		return
	end
	local args = {
		name = name,
		content = content
	}
	Message.sendPost('headline', 'message', json.encode(args), function(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic.code ~= 0 then
			return
		end
		PlayerCoreData.addMaterialDelta(MATERIAL_DALABA_ID, -1)
		CMainSceneMgr:GetInst():updateLoudSpeaker(jsonDic.args.name, jsonDic.args.content)
		self:clearInputWords()
		self:updateLittlePanelState()
	end)
end

function Chat:sendWorldChat(name, content)
	local args = {
		name = name,
		content = content,
		key = CGlobalData:GetInst():getAuthKey()
	}
	Message.sendPost('im', 'message', json.encode(args), function(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic.code ~= 0 then
			return
		end
		self.sendTime = UserData:getServerTime()
		local chatData = {
			time = UserData:getServerTime(),
			name = jsonDic.args.name,
			content = jsonDic.args.content,
			vip = PlayerCoreData.getPlayerVIP(),
			uid = PlayerCoreData.getUID()
		}
		table.insert(self.vecNewData[CHAT_CHANNEL.WORLD], chatData)
		self:clearInputWords()
		self:updateChat(CHAT_CHANNEL.WORLD)
	end)
end

function Chat:onClickSend(content, WORDS_LIMIT)
	if content == '' then
		--GameController.showMessageBox(getLocalStringValue('E_STR_CHATINPUTISEMPTY'), MESSAGE_BOX_TYPE.OK)
		return
	end
    local len = string.utf8len(content)
    if len > WORDS_LIMIT then
    	GameController.showMessageBox(string.format(getLocalStringValue('E_STR_CHAT_LEGION_CHAT_NOT_30_WORD'), WORDS_LIMIT), MESSAGE_BOX_TYPE.OK)
        return
    end
	local name = PlayerCoreData.getPlayerName()    
	if self.currentChannel == CHAT_CHANNEL.WORLD then
		local nowTime = UserData:getServerTime()
		if nowTime - self.sendTime > 5 then
			self:sendWorldChat(name, content)
		else
			GameController.showPrompts(getLocalStringValue('E_STR_CHAT_INTERVAL'), COLOR_TYPE.RED)
		end
	elseif self.currentChannel == CHAT_CHANNEL.LEGION then
		local nowTime = UserData:getServerTime()
		if nowTime - self.sendTime > 5 then
			self:sendLegion(name, content)
		else
			GameController.showPrompts(getLocalStringValue('E_STR_CHAT_INTERVAL'), COLOR_TYPE.RED)
		end
	elseif self.currentChannel == CHAT_CHANNEL.LOUDSPEAKER then
		self:sendLoudSpeaker(name, content)
	end
end

-- public function
function Chat:loadNewChat(channelTag)
	for i = 1, #self.vecNewData[channelTag] do
		local newData = table.remove(self.vecNewData[channelTag])
		local cellPanel = require('ceremony/panel/chat/chat_cell'):create()
		cellPanel:initPanel(true)
		cellPanel:setData(newData)
		self.chatSv:addChildToBottom(cellPanel.root)
		table.insert(self.vecOldData[channelTag], newData)
	end
end

function Chat:loadOldChat(channelTag)
	if #self.vecOldData[channelTag] > 30 then
		local erased = #self.vecOldData[channelTag] - 30
		for i = 1, erased do
			table.remove(self.vecOldData[channelTag])
		end
	end
	for j = 1, #self.vecOldData[channelTag] do
		local cellPanel = require('ceremony/panel/chat/chat_cell'):create()
		cellPanel:initPanel(true)
		cellPanel:setData(self.vecOldData[channelTag][j])
		self.chatSv:addChildToBottom(cellPanel.root)
	end
end

-- 切换频道
function Chat:setActiveChannel(channelTag)
	local legionID = getLegionID()
	if channelTag == CHAT_CHANNEL.WORLD then 	-- 世界频道
		self.channelsBtn[CHAT_CHANNEL.WORLD]:setPressState(WidgetStateSelected)
		self.channelsBtn[CHAT_CHANNEL.WORLD]:setTouchEnable(false)
		self.channelsBtn[CHAT_CHANNEL.WORLD]:setWidgetZOrder(3)
		self.channelsBtn[CHAT_CHANNEL.LEGION]:setPressState(WidgetStateNormal)
		self.channelsBtn[CHAT_CHANNEL.LEGION]:setTouchEnable(true)
		self.channelsBtn[CHAT_CHANNEL.LEGION]:setWidgetZOrder(1)
		self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:setPressState(WidgetStateNormal)
		self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:setTouchEnable(true)
		self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:setWidgetZOrder(1)
	elseif channelTag == CHAT_CHANNEL.LEGION then 	-- 军团频道
		self.channelsBtn[CHAT_CHANNEL.LEGION]:setPressState(WidgetStateSelected)
		self.channelsBtn[CHAT_CHANNEL.LEGION]:setTouchEnable(false)
		self.channelsBtn[CHAT_CHANNEL.LEGION]:setWidgetZOrder(3)
		self.channelsBtn[CHAT_CHANNEL.WORLD]:setPressState(WidgetStateNormal)
		self.channelsBtn[CHAT_CHANNEL.WORLD]:setTouchEnable(true)
		self.channelsBtn[CHAT_CHANNEL.WORLD]:setWidgetZOrder(1)
		self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:setPressState(WidgetStateNormal)
		self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:setTouchEnable(true)
		self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:setWidgetZOrder(1)
		if legionID == 0 then -- 没有军团
			self.currentChannel = channelTag
			self.legionImg:setVisible(true)
			self.editBox:setTouchEnabled(false)
			self.sendBtn:setTouchEnable(false)
			self.sendBtn:setPressState(WidgetStateDisabled)
			self:clearInputWords()
			self:updateLittlePanelState()
			self.chatSv:removeAllChildrenAndCleanUp(true)
			return
		end
	elseif channelTag == CHAT_CHANNEL.LOUDSPEAKER then 	-- 喊话频道
		self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:setPressState(WidgetStateSelected)
		self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:setTouchEnable(false)
		self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:setWidgetZOrder(3)
		self.channelsBtn[CHAT_CHANNEL.LEGION]:setPressState(WidgetStateNormal)
		self.channelsBtn[CHAT_CHANNEL.LEGION]:setTouchEnable(true)
		self.channelsBtn[CHAT_CHANNEL.LEGION]:setWidgetZOrder(1)
		self.channelsBtn[CHAT_CHANNEL.WORLD]:setPressState(WidgetStateNormal)
		self.channelsBtn[CHAT_CHANNEL.WORLD]:setTouchEnable(true)
		self.channelsBtn[CHAT_CHANNEL.WORLD]:setWidgetZOrder(1)
	end

	self.legionImg:setVisible(false)
	self.editBox:setTouchEnabled(true)
	self.sendBtn:setTouchEnable(true)
	self.sendBtn:setPressState(WidgetStateNormal)
	if self.firstInit then
		self.currentChannel = channelTag
		self.chatSv:removeAllChildrenAndCleanUp(true)
	else
		if self.currentChannel ~= channelTag then --切换频道
			self.currentChannel = channelTag
			self.chatSv:removeAllChildrenAndCleanUp(true)
			self:clearInputWords()
		end
	end
	self:updateChat(channelTag)
	self:updateLittlePanelState()
end

-- 更新显示喇叭图标
function Chat:updateLittlePanelState()
	if self.currentChannel == CHAT_CHANNEL.LOUDSPEAKER then
		self.itemNameLabel:setVisible(true)
		self.itemCountLabel:setVisible(true)
		self.labaIco:setVisible(true)
		local labaNum = PlayerCoreData.getMaterialCount(MATERIAL_DALABA_ID) .. '/1'
		self.itemNameLabel:setText(getLocalStringValue('E_STR_CHAT_DALABA_NAME'))
		self.itemCountLabel:setText(labaNum)
	else
		self.itemNameLabel:setVisible(false)
		self.itemCountLabel:setVisible(false)
		self.labaIco:setVisible(false)
	end
end

-- 更新聊天
function Chat:updateChat(channelTag)
	if self.chatSv:getChildren():count() <= 0 then
		self:loadOldChat(channelTag)
	end
	self:loadNewChat(channelTag)
	self.chatSv:scrollToBottom()
	self.chatSv:setBerthOrientation(SCROLLVIEW_BERTH_ORI_BOTTOM)
	self.chatSv:doBerth()
end

function Chat:clearInputWords()
	self.editBox:setText("")
end

-- 关闭聊天
function Chat:slowClosePanel()
	if self.sceneObj ~= nil and self.isOpen == true then
		local size = self.rootImg:getContentSize()
		local moveBox = CCMoveTo:create(0.15,ccp(-size.width, 0))
	    local arr = CCArray:create()
		arr:addObject(moveBox)
		arr:addObject(CCCallFunc:create(function ()
			self.closeBtn:setVisible(false)
		end))
		self.rootImg:runAction(CCSequence:create(arr))
	    self.isOpen = false
	end
end

-- 打开聊天
function Chat:genChatPanel()
	if self.sceneObj == nil then
		local chatData = getChatData()
		self.vecOldData = chatData.vecOldData
		self.vecNewData = chatData.vecNewData
		self.sceneObj = SceneObjEx:createObj('panel/chat_bg_panel.json', 'chat-lua')
		local panel = self.sceneObj:getPanelObj()
		panel:setIsOrdered(false)
		panel:registerInitHandler(function()
			local root = panel:GetRawPanel()
			root:setWidgetZOrder(999998)
			self.rootImg = tolua.cast(root:getChildByName('chat_bg_img'),'UIImageView')
			local size = self.rootImg:getContentSize()
			self.rootImg:setPosition(ccp(-size.width, 0))

			self.legionImg = tolua.cast(self.rootImg:getChildByName('legion_img'),'UIImageView')
			local promptTx = tolua.cast(self.legionImg:getChildByName('prompt_tx'),'UILabel')
			promptTx:setPreferredSize(400,1)
			promptTx:setText(getLocalStringValue('E_STR_UNLOCK_LEGION_CHAT'))

			self.closeBtn = tolua.cast(self.rootImg:getChildByName('close_btn'),'UIButton')
			GameController.addButtonSound(self.closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
			self.closeBtn:registerScriptTapHandler(function ()
				local moveBox = CCMoveTo:create(0.15,ccp(-size.width, 0))
	     		local arr = CCArray:create()
				arr:addObject(moveBox)
				arr:addObject(CCCallFunc:create(function ()
					self.closeBtn:setVisible(false)
				end))
				self.rootImg:runAction(CCSequence:create(arr))
	     		self.isOpen = false
			end)
			self.closeBtn:registerScriptCancelHandler(function ()
				local size = self.rootImg:getContentSize()
				local pos = self.rootImg:getPosition()
				if pos.x < -size.width / 2 then
					self:slowClosePanel()
				else
					local moveBox = CCMoveTo:create(0.15,ccp(0, 0))
					self.rootImg:runAction(moveBox)
				end
			end)
			self.closeBtn:registerMovHandler(function ()
				local startPos = self.closeBtn:getTouchStartPos()
				local endPos = self.closeBtn:getTouchMovePos()
				local movedX = endPos.x - startPos.x
				local size = self.rootImg:getContentSize()
				local oldPos = self.rootImg:getPosition()
				if movedX > 0 then
					movedX = 0
				end
				if movedX < -size.width then
					movedX = -size.width
				end
				local newPos = ccp(movedX, oldPos.y)
				self.rootImg:setPosition(newPos)
			end)

			self.itemNameLabel  = tolua.cast(self.rootImg:getChildByName('name_tx'),'UILabel')
			self.itemCountLabel = tolua.cast(self.rootImg:getChildByName('number_tx'),'UILabel')
			self.labaIco = tolua.cast(self.rootImg:getChildByName('xiaolaba_ico'),'UIImageView')

			local WORDS_LIMIT = getGlobalIntegerValue('DialogLimit', 0)
			local inputTextImg = tolua.cast(self.rootImg:getChildByName('chat_info_bg_ico'),'UIImageView')
			self.editBox = tolua.cast(UISvr:replaceUIImageViewByCCEditBox(inputTextImg) , 'CCEditBox')
			self.editBox:setInputMode(kEditBoxInputModeEmailAddr)
			self.editBox:setReturnType(kKeyboardReturnTypeDone)
			self.editBox:setMaxLength(WORDS_LIMIT * 2 + 10)
			self.editBox:setFontSize(24)
			self.editBox:setFontColor(COLOR_TYPE.BLACK)
			self.editBox:registerScriptEditBoxHandler( function (eventType)
				if eventType == 'ended' then
					self.editBox:setFontColor(COLOR_TYPE.LIGHT_GREEN)
					local noticeText = self.editBox:getText()
					noticeText = CheckAndModifyStr(noticeText)
					self.editBox:setText(noticeText)
				elseif eventType == 'began' then
					self.editBox:setPosition(inputTextImg:getPosition())
					self.editBox:setFontColor(COLOR_TYPE.BLACK)
				end
			end)

			self.sendBtn = tolua.cast(self.rootImg:getChildByName('send_btn'),'UIButton')
			GameController.addButtonSound(self.sendBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
			self.sendBtn:registerScriptTapHandler(function ()
				local content = self.editBox:getText()
				self:onClickSend(content, WORDS_LIMIT)
			end)

			self.channelsBtn[CHAT_CHANNEL.WORLD] = tolua.cast(self.rootImg:getChildByName('world_btn'),'UIButton')
			self.channelsBtn[CHAT_CHANNEL.WORLD]:setActionTag(CHAT_CHANNEL.WORLD)
			GameController.addButtonSound(self.channelsBtn[CHAT_CHANNEL.WORLD], BUTTON_SOUND_TYPE.CLICK_EFFECT)
			self.channelsBtn[CHAT_CHANNEL.WORLD]:registerScriptTapHandler(function ()
				self:setActiveChannel(CHAT_CHANNEL.WORLD)
			end)
			self.channelsBtn[CHAT_CHANNEL.LEGION] = tolua.cast(self.rootImg:getChildByName('legion_btn'),'UIButton')
			self.channelsBtn[CHAT_CHANNEL.LEGION]:setActionTag(CHAT_CHANNEL.LEGION)
			GameController.addButtonSound(self.channelsBtn[CHAT_CHANNEL.LEGION], BUTTON_SOUND_TYPE.CLICK_EFFECT)
			self.channelsBtn[CHAT_CHANNEL.LEGION]:registerScriptTapHandler(function ()
				self:setActiveChannel(CHAT_CHANNEL.LEGION)
			end)
			self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER] = tolua.cast(self.rootImg:getChildByName('say_btn'),'UIButton')
			self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:setActionTag(CHAT_CHANNEL.LOUDSPEAKER)
			GameController.addButtonSound(self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER], BUTTON_SOUND_TYPE.CLICK_EFFECT)
			self.channelsBtn[CHAT_CHANNEL.LOUDSPEAKER]:registerScriptTapHandler(function ()
				self:setActiveChannel(CHAT_CHANNEL.LOUDSPEAKER)
			end)

			self.chatSv = tolua.cast(self.rootImg:getChildByName('chat_info_sv'),'UIScrollView')
			self.chatSv:setClippingEnable(true)
			self.chatSv:setDirection(SCROLLVIEW_DIR_VERTICAL)
			self:setActiveChannel(CHAT_CHANNEL.WORLD)

			local moveBox = CCMoveTo:create(0.15,ccp(0,0))
     		local arr = CCArray:create()
			arr:addObject(moveBox)
			arr:addObject(CCCallFunc:create(function ()
				self.rootImg:setPosition(ccp(0, 0))
				local inputTextImg = tolua.cast(self.rootImg:getChildByName('chat_info_bg_ico'),'UIImageView')
				self.editBox:setPosition(inputTextImg:getPosition())
			end))
			self.rootImg:runAction(CCSequence:create(arr))
			self.firstInit = false
		end)

		panel:registerOnDestroyHandler(function ()
			self.sceneObj = nil
			self.rootImg = nil
			self.closeBtn = nil
			self.sendBtn = nil
			self.chatSv = nil
			self.editBox = nil
			self.itemNameLabel = nil
			self.itemCountLabel = nil
			self.legionImg = nil
			self.labaIco = nil
			self.channelsBtn = {}
			self.isOpen = false
			self.currentChannel = 1
			self.firstInit = true
			self.sendTime = 0
			self.vecOldData = {{}, {}, {}, {}}
			self.vecNewData = {{}, {}, {}, {}}
			setChatTipsVisible(false)
		end)
		UiMan.show(self.sceneObj, ELF_SHOW.NORMAL)
	else
		local moveBox = CCMoveTo:create(0.15,ccp(0,0))
		local arr = CCArray:create()
		arr:addObject(moveBox)
		arr:addObject(CCCallFunc:create(function ()
			self.rootImg:setPosition(ccp(0, 0))
			local inputTextImg = tolua.cast(self.rootImg:getChildByName('chat_info_bg_ico'),'UIImageView')
			self.editBox:setPosition(inputTextImg:getPosition())
		end))
		self.rootImg:runAction(CCSequence:create(arr))
		self:setActiveChannel(self.currentChannel)
	end
	self.closeBtn:setVisible(true)
	setChatTipsVisible(false)
	self.isOpen = true
end

return Chat