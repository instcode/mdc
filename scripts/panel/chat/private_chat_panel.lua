local PrivateChat = {
	chatSv = nil,
	editBox = nil,
	privateVecOldData = {},
	privateVecNewData = {}

}

function PrivateChat:onClickSendChat(uid, content, WORDS_LIMIT)
	if content == '' then
		GameController.showPrompts(getLocalStringValue('E_STR_CHATINPUTISEMPTY'), COLOR_TYPE.RED)
		return
	end
    local len = string.utf8len(content)
    if len > WORDS_LIMIT then
    	GameController.showPrompts(string.format(getLocalStringValue('E_STR_CHAT_LEGION_CHAT_NOT_30_WORD'), WORDS_LIMIT), COLOR_TYPE.RED)
        return
    end

    local args = {
		uid = uid,
		content = content
	}
	Message.sendPost('chat', 'message', json.encode(args), function(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic.code ~= 0 then
			return
		end
		local chatData = {
			time = UserData:getServerTime(),
			name = PlayerCoreData.getPlayerName(),
			content = jsonDic.args.content,
			vip = PlayerCoreData.getPlayerVIP(),
			uid = PlayerCoreData.getUID()
		}
		if self.privateVecNewData[tostring(uid)] == nil then
			self.privateVecNewData[tostring(uid)] = {}
		end
		table.insert(self.privateVecNewData[tostring(uid)], chatData)
		self.editBox:setText('')
		self:loadNewChat(uid)
		self.chatSv:scrollToBottom()
		self.chatSv:setBerthOrientation(SCROLLVIEW_BERTH_ORI_BOTTOM)
		self.chatSv:doBerth()
	end)
end

function PrivateChat:loadNewChat(uid)
	if self.privateVecNewData[tostring(uid)] ~= nil then
		for i = 1, #self.privateVecNewData[tostring(uid)] do
			local newData = table.remove(self.privateVecNewData[tostring(uid)])
			local cellPanel = require('ceremony/panel/chat/chat_cell'):create()
			cellPanel:initPanel(false)
			cellPanel:setData(newData)
			self.chatSv:addChildToBottom(cellPanel.root)
			if self.privateVecOldData[tostring(uid)] == nil then
				self.privateVecOldData[tostring(uid)] = {}
			end
			table.insert(self.privateVecOldData[tostring(uid)], newData)
		end
	end
end

function PrivateChat:loadOldChat(uid)
	if self.privateVecOldData[tostring(uid)] ~= nil then
		if #self.privateVecOldData[tostring(uid)] > 30 then
			local erased = #self.privateVecOldData[tostring(uid)] - 30
			for i = 1, erased do
				table.remove(self.privateVecOldData[tostring(uid)])
			end
		end
		for j = 1, #self.privateVecOldData[tostring(uid)] do
			local cellPanel = require('ceremony/panel/chat/chat_cell'):create()
			cellPanel:initPanel(false)
			cellPanel:setData(self.privateVecOldData[tostring(uid)][j])
			self.chatSv:addChildToBottom(cellPanel.root)
		end
	end
end

function PrivateChat:updateChat(uid)
	if self.chatSv:getChildren():count() <= 0 then
		self:loadOldChat(uid)
	end
	self:loadNewChat(uid)
	self.chatSv:scrollToBottom()
	self.chatSv:setBerthOrientation(SCROLLVIEW_BERTH_ORI_BOTTOM)
	self.chatSv:doBerth()
end

function PrivateChat:genPrivateChatPanel(uid, name)
	local chatData = getChatData()
	self.privateVecOldData = chatData.privateVecOldData
	self.privateVecNewData = chatData.privateVecNewData
	local sceneObj = SceneObjEx:createObj('panel/private_chat_bg_panel.json', 'private-chat-lua')
	local panel = sceneObj:getPanelObj()
	panel:setAdaptInfo('private_chat_bg_img' , 'chat_bg_img')
	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()

		local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		self.chatSv = tolua.cast(root:getChildByName('message_sv') , 'UIScrollView')
		self.chatSv:setClippingEnable(true)
		self.chatSv:setDirection(SCROLLVIEW_DIR_VERTICAL)

		local chatBgImg = tolua.cast(root:getChildByName('chat_btn_bg_img') , 'UIImageView')
		local playerNameTx = tolua.cast(chatBgImg:getChildByName('player_name_tx') , 'UILabel')
		playerNameTx:setText(name)

		local WORDS_LIMIT = getGlobalIntegerValue('DialogLimit', 0)
		local inputTextImg = tolua.cast(chatBgImg:getChildByName('chat_info_bg_ico'),'UIImageView')
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

		local sendBtn = tolua.cast(chatBgImg:getChildByName('send_btn'),'UIButton')
		GameController.addButtonSound(sendBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		sendBtn:registerScriptTapHandler(function ()
			local content = self.editBox:getText()
			self:onClickSendChat(uid, content, WORDS_LIMIT)
		end)
		self:updateChat(uid)
		ChatData.updatePrivateChat = function ()
			self:updateChat(uid)
		end
	end)
	panel:registerOnDestroyHandler(function ()
		ChatData.updatePrivateChat = nil
	end)
	UiMan.show(sceneObj, ELF_SHOW.ZOOM_IN)
end

function PrivateChat:create()
	local o = {}
    setmetatable(o, self)
    self.__index = self

    o.chatSv = nil
	o.editBox = nil
    return o
end

return PrivateChat
