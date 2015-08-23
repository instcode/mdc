
-- copy from legion
-- thx the auth of legion
local function DayDisPlay(serTime, lastTime)
	local str =''
	if lastTime == nil then
		return str
	else
		if tonumber(lastTime) == 0 then
			return str
		else
			local interval = (tonumber(Time.beginningOfToday() + 3600 * 24 ) - tonumber(lastTime)) / 3600
			-- local interval = (tonumber(serTime) - tonumber(lastTime)) / 3600 
				if interval < 24 then
				str = string.format(getLocalStringValue('E_STR_LAST_TIME_TODAY'), os.date("%H:%M", tonumber(lastTime)))
			elseif interval >= 24 and interval < 48 then
				str = string.format(getLocalStringValue('E_STR_LAST_TIME_YESTERDAY'), os.date("%H:%M", tonumber(lastTime)))
			elseif interval >= 48 and interval < 72 then
				str = string.format(getLocalStringValue('E_STR_LAST_TIME_BEFORE_YESTERDAY'), os.date("%H:%M", tonumber(lastTime)))
			elseif interval >= 72 and interval < 168 then
				str = string.format(getLocalStringValue('E_STR_LAST_TIME_THREE_DAY'))
			elseif interval >= 168 then
				str = string.format(getLocalStringValue('E_STR_LAST_TIME_WEEK'))
			end
			return str
		end
	end
end

-- 打開好友戰鬥力界面
local function openFriendsControler( uid, name, fightForce, legionName, headpic, level, status )
	local sceneObj = SceneObjEx:createObj('panel/friends_info_panel.json' , 'friends-info-in-lua')
	local panelObj = sceneObj:getPanelObj()
	panelObj:setAdaptInfo('player_info_bg_img' , 'player_info_img')

	panelObj:registerInitHandler(function (  )
		local root = panelObj:GetRawPanel()

		local di = tolua.cast(root:getChildByName('player_info_bg_img'), 'UIImageView')
		di:setTouchEnable(true)
		di:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))

		-- card 初始化
		local headIco = tolua.cast(root:getChildByName('player_photo_img'), 'UIImageView')
		local headframe = tolua.cast(root:getChildByName('player_frame_img'), 'UIImageView')
		-- 设置头像 和 头像的框框
		local pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject( headpic, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
		pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
		framRes = pRoleCardObj:GetIconFrame()
		iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON)
		headIco:setTexture(iconRes)
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

		-- 等级
		local levelTx = tolua.cast(root:getChildByName('player_lv_tx'), 'UILabel')
		levelTx:setText(level)

		-- 军团名字
		local legionTx = tolua.cast(root:getChildByName('legion_name_tx'), 'UILabel')
		if legionName == '' then
			legionTx:setText(getLocalStringValue('E_STR_PVP_WAR_WU'))
		else
			legionTx:setText(legionName)
		end

		local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local nameTx = tolua.cast(root:getChildByName('player_name_tx'), 'UILabel')
		nameTx:setText(name)

		local ff = tolua.cast(root:getChildByName('force_num_la'), 'UILabelAtlas')
		ff:setStringValue(fightForce)

		local delBtn = tolua.cast(root:getChildByName('delete_btn'), 'UITextButton')
		local conStatus = require('ceremony/panel/friends_data'):getControlerStatus()
		if status == conStatus.kApplied then
			delBtn:disable()
		elseif status == conStatus.kFriends then
			delBtn:active()
			delBtn:setText(getLocalStringValue('E_STR_CHAT_DEL_FRIEND'))
			delBtn:registerScriptTapHandler(function (  )
				-- 刪除好友
				onDeleteFriend(uid)
				CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.SMART_HIDE)
			end)
		elseif status == conStatus.kRecommend then
			delBtn:active()
			delBtn:setText(getLocalStringValue('E_STR_CHAT_ADD_FRIEND'))
			delBtn:registerScriptTapHandler(function (  )
				-- 添加好友
				onRequestFriend(uid)
				CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.SMART_HIDE)
			end)
		end

		GameController.addButtonSound(delBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local infoBtn = tolua.cast(root:getChildByName('read_data_btn'), 'UITextButton')
		infoBtn:registerScriptTapHandler(function (  )
			-- 查看資料
			args = {
				id = tonumber(uid)
			}
			Message.sendPost('get_user', 'rank', json.encode(args), function( jsonData )
				print(jsonData)
				genRolePanel(uid, name, json.decode(jsonData))
			end)
		end)
		GameController.addButtonSound(infoBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	end)

	UiMan.show(sceneObj)
end


------------------------------------------------------------------------------------------------------------------------------
-- 创建单个好友名片
-- 最初的设计只有6个参数,虽然略多,但勉强还ok...后来随着更改...就这样一直增加到了9个参数...太脑残了...
function createFriendsCard(uid, name, rid, level, lastLogin, fightForce, hasMsg, legionName, status)
	-- 设置界面
	local root = createWidgetByName('panel/friends_card_panel.json')

	-- 设置标记
	root:setWidgetTag(uid)

	-- card 初始化
	local headpic = tolua.cast(root:getChildByName('photo_ico'), 'UIImageView')
	local headframe = tolua.cast(root:getChildByName('frame_img'), 'UIImageView')
	-- 设置头像 和 头像的框框
	local pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject( rid, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
	pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
	framRes = pRoleCardObj:GetIconFrame()
	iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON)

	headpic:setTexture(iconRes)
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

	local slevel = tolua.cast(root:getChildByName('lv_tx'), 'UILabel')
	slevel:setText(level)

	local sname = tolua.cast(root:getChildByName('player_name_tx'), 'UILabel')
	sname:setText(name)

	local time = tolua.cast(root:getChildByName('time_tx'), 'UILabel')
	time:setText(DayDisPlay(UserData:getServerTime(), lastLogin))

	local fight = tolua.cast(root:getChildByName('force_num_la'), 'UILabelAtlas')
	fight:setStringValue(fightForce)

	local chat = tolua.cast(root:getChildByName('private_chat_btn'), 'UITextButton')
	local quanIco = tolua.cast(chat:getChildByName('quan_ico'), 'UIImageView')
	quanIco:setVisible(hasMsg)
	chat:setTouchEnable(true)
	chat:registerScriptTapHandler(function (  )
		-- 点击私聊按钮回调事件
		quanIco:setVisible(false)
		local privateChat = require('ceremony/panel/chat/private_chat_panel'):create()
		privateChat:genPrivateChatPanel(uid, name)
	end)

	local add = tolua.cast(root:getChildByName('add_btn'), 'UITextButton')
	add:setTouchEnable(true)
	add:registerScriptTapHandler(function (  )
		-- 点击添加好友回调事件
		onRequestFriend(uid)
	end)

	local accept = tolua.cast(root:getChildByName('ok_btn'), 'UITextButton')
	accept:setTouchEnable(true)
	accept:registerScriptTapHandler(function (  )
		-- 点击接受回调事件
		onFriendAgreeHandler(uid)
	end)

	local refuse = tolua.cast(root:getChildByName('no_btn'), 'UITextButton')
	refuse:setTouchEnable(true)
	refuse:registerScriptTapHandler(function (  )
		-- 点击拒绝回调事件
		onFreindRefusHandler(uid)
	end)

	local frame = tolua.cast(root:getChildByName('player_info_bg_img'), 'UIImageView')
	frame:setTouchEnable(true)
	frame:registerScriptTapHandler(function (  )
		-- 点击信息板回调事件
		openFriendsControler(uid, name, fightForce, legionName, rid, level, status)
	end)

	return root
end

-- 改变控制面板状态
function changeFriendsControlerStatus( frame, friend, status )
	frame:registerScriptTapHandler(function (  )
		-- 点击信息板回调事件
		openFriendsControler(friend.uid, friend.name, friend.fight_force, friend.legion_name, friend.headpic, friend.level, 
			require('ceremony/panel/friends_data'):getControlerStatus().kFriends)
	end)
end
