local ChatCell = {
	root = nil,
	msgBg = nil,
	nameLabel = nil,
	contentText = nil,
	uid = 0
}

-- 玩家信息面板
local function openChatInfo(uid, name, isFriend, fightForce, headpic, lv, legionName)
	local sceneObj = SceneObjEx:createObj('panel/friends_info_panel.json' , 'chat-info-in-lua')
	local panelObj = sceneObj:getPanelObj()
	panelObj:setAdaptInfo('player_info_bg_img' , 'player_info_img')

	panelObj:registerInitHandler(function ()
		local root = panelObj:GetRawPanel()

		local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj, ELF_HIDE.HIDE_NORMAL))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local nameTx = tolua.cast(root:getChildByName('player_name_tx'), 'UILabel')
		nameTx:setText(name)

		local ff = tolua.cast(root:getChildByName('force_num_la'), 'UILabelAtlas')
		ff:setStringValue(fightForce)

		local headPic = tolua.cast(root:getChildByName('player_photo_img'),'UIImageView')
		local headframe = tolua.cast(root:getChildByName('player_frame_img'), 'UIImageView')
		-- 设置头像 和 头像的框框
		local pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject( headpic, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
		pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
		framRes = pRoleCardObj:GetIconFrame()
		iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON)
		headPic:setTexture(iconRes)
		headframe:setTexture(framRes)

		if pRoleCardObj:GetRoleQuality() == ROLE_QUALITY.SRED then
			local light = CUIEffect:create()
			light:Show("yellow_light", 0)
			light:setScale(0.81)
			light:setPosition( ccp(0, 0))
			light:setAnchorPoint(ccp(0.5, 0.5))
			headframe:getContainerNode():addChild(light)
			light:setZOrder(100)
		end

		local level = tolua.cast(root:getChildByName('player_lv_tx'),'UILabel')
		level:setText(lv)

		local legion = tolua.cast(root:getChildByName('legion_name_tx'),'UILabel')
		legion:setText(legionName)

		local delBtn = tolua.cast(root:getChildByName('delete_btn'), 'UITextButton')
		if isFriend == 0 then 	-- 可以申请为好友
			delBtn:setText(getLocalStringValue('E_STR_CHAT_ADD_FRIEND'))
		elseif isFriend == 1 then -- 已经是好友
			delBtn:setText(getLocalStringValue('E_STR_CHAT_DEL_FRIEND'))
		elseif isFriend == 2 then -- 申请中
			delBtn:setText(getLocalStringValue('E_STR_CHAT_APPLYING_FRIEND'))
			delBtn:setTouchEnable(false)
			delBtn:setPressState(WidgetStateDisabled)
		end
		delBtn:registerScriptTapHandler(function ()
			if isFriend == 0 then 	-- 申请加为好友
				local args = {
					id = uid
				}
				Message.sendPost('apply', 'friend', json.encode(args), function(jsonData)
					local jsonDic = json.decode(jsonData)
					if jsonDic.code ~= 0 then
						return
					end
					local status = jsonDic.data.status
					if status == 0 then -- 申请成功
						GameController.showPrompts(getLocalStringValue('E_STR_FRIENDS_APPLY_0'), COLOR_TYPE.GREEN)
					elseif status == 1 then -- 已经在自己的好友列表中
						GameController.showPrompts(getLocalStringValue('E_STR_FRIENDS_APPLY_1'), COLOR_TYPE.RED)
					elseif status == 2 then -- 已经在对方的申请好友列表中
						GameController.showPrompts(getLocalStringValue('E_STR_FRIENDS_APPLY_2'), COLOR_TYPE.RED)
					elseif status == 3 then -- 自己好友列表已满 
						GameController.showPrompts(getLocalStringValue('E_STR_FRIENDS_APPLY_3'), COLOR_TYPE.RED)
					elseif status == 4 then -- 对方好友列表已满
						GameController.showPrompts(getLocalStringValue('E_STR_FRIENDS_APPLY_4'), COLOR_TYPE.RED)
					elseif status == 5 then -- 对方已经申请自己，添加好友成功
						GameController.showPrompts(getLocalStringValue('E_STR_FRIENDS_APPLY_5'), COLOR_TYPE.GREEN)
					end
					UiMan.hide(sceneObj, ELF_HIDE.HIDE_NORMAL)
				end)
			elseif isFriend == 1 then -- 删除好友
				GameController.showMessageBox(getLocalStringValue('E_STR_CONFIRM_REMOVE_FRIEND'), MESSAGE_BOX_TYPE.OK_CANCEL,function ()
					local args = {
						id = uid
					}
					Message.sendPost('remove', 'friend', json.encode(args), function(jsonData)
						local jsonDic = json.decode(jsonData)
						if jsonDic.code ~= 0 then
							return
						end
						GameController.showPrompts(getLocalStringValue('E_STR_FRIENDS_REMOVE_SUC'), COLOR_TYPE.GREEN)
						UiMan.hide(sceneObj, ELF_HIDE.HIDE_NORMAL)
					end)
				end)
			end
		end)
		GameController.addButtonSound(delBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local infoBtn = tolua.cast(root:getChildByName('read_data_btn'), 'UITextButton')
		infoBtn:registerScriptTapHandler(function ()
			local args = {
				id = uid
			}
			Message.sendPost('get_user', 'rank', json.encode(args), function(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic.code ~= 0 then
					return
				end
				genRolePanel(uid, name, jsonDic)
			end)
		end)
		GameController.addButtonSound(infoBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	end)
	UiMan.show(sceneObj, ELF_SHOW.NORMAL)
end

function ChatCell:setData(data)
	local hourTime = os.date('%H', data.time)
	local minuteTime = os.date('%M', data.time)
	local timeStr = '<font color="#FF6600">[' .. hourTime .. ':' .. minuteTime .. ']</font>'
	local nameStr = ''
	local vip = data.vip
	if vip > 0 then
		nameStr = timeStr .. ' <font color="#FF0000">' .. data.name .. ' VIP' .. vip .. ':</font>'
	else
		nameStr = timeStr .. ' <font color="#00FF00">' .. data.name .. ':</font>'
	end
	self.nameLabel:setText(nameStr)
	self.contentText:setText(data.content)
	self.uid = data.uid
	local height = self.contentText:getContentSize().height
	self.msgBg:setScale9Size(CCSizeMake(430, height + 60))
	self.root:setSize(CCSizeMake(445, height + 70))
	self.nameLabel:setPosition(ccp(16, height + 60 - 20))
	self.contentText:setPosition(ccp(16, height + 60 - 40))
end

function ChatCell:initPanel(openChatInfoFlag)
	self.root = tolua.cast(createWidgetByName('panel/chat_info_panel.json'), 'UIPanel')
	self.msgBg = tolua.cast(self.root:getChildByName('message_bg_img'), 'UIImageView')
	self.nameLabel = tolua.cast(self.msgBg:getChildByName('player_name_tx'), 'UILabel')
	self.contentText = tolua.cast(self.msgBg:getChildByName('chat_info_tx'), 'UILabel')
	self.contentText:setPreferredSize(400, 20)
	if openChatInfoFlag then
		self.msgBg:registerScriptTapHandler(function ()
			if self.uid ~= PlayerCoreData.getUID() then
				local args = {
					id = self.uid
				}
				Message.sendPost('get_user', 'friend', json.encode(args), function(jsonData)
					local jsonDic = json.decode(jsonData)
					if jsonDic.code ~= 0 then
						return
					end
					openChatInfo(self.uid, jsonDic.data.name, jsonDic.data.friended, jsonDic.data.fight_force, jsonDic.data.headpic, jsonDic.data.level, jsonDic.data.legion_name)
				end)
			end
		end)
	end
end

function ChatCell:create()
	local o = {}
    setmetatable(o, self)
    self.__index = self

    o.root = nil
	o.msgBg = nil
	o.nameLabel = nil
	o.contentText = nil
	o.uid = 0
    return o
end

return ChatCell