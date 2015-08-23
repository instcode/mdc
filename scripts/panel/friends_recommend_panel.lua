
local e = require('ceremony/panel/friends_data'):getRecommend() 		-- lock data
local elements = e.elements					-- 界面元素
local recommend = e.recommend				-- 申请数据
local kSceneObj = e.kSceneObj				-- SceneObj
local kFriendsPanel = e.kFriendsPanel		-- PanelObj

-- local elements = {}				-- 界面元素
-- local recommend = {}			-- 推荐好友列表
-- local kSceneObj = 0				-- 场景Obj
-- local kFriendsPanel = 0			-- 界面Obj
----------------------------------------------------------------------------------------------------------------------------
-- 界面常量
local kNameMaxLength = 14		-- 姓名最大长度


-- 刷新推荐列表界面
local function initRecommendList(  )
	elements.sv:removeAllChildrenAndCleanUp(true)
	local conStatus = require('ceremony/panel/friends_data'):getControlerStatus()

	for _, v in pairs(recommend) do
		if v ~= nil then
			-- 创建好友名片
			local widget = createFriendsCard(v.uid, v.name, v.headpic, v.level, v.last_login, v.fight_force, false, v.legion_name, conStatus.kRecommend)

			-- 隐藏不用的控件
			local chat = tolua.cast(widget:getChildByName('private_chat_btn'), 'UITextButton')
			chat:setVisible(false)

			local accept = tolua.cast(widget:getChildByName('ok_btn'), 'UITextButton')
			accept:setVisible(false)

			local refuse = tolua.cast(widget:getChildByName('no_btn'), 'UITextButton')
			refuse:setVisible(false)

			local food = tolua.cast(widget:getChildByName('food_img'), 'UIImageView')
			food:setVisible(false)

			elements.sv:addChildToBottom(widget)
		end
	end
	elements.sv:scrollToTop()
end

-- 初始化界面
local function initPanel()
	kSceneObj = SceneObjEx:createObj('panel/add_friends_bg_panel.json' , 'add-friends-bg-in-lua')
	kFriendsPanel = kSceneObj:getPanelObj()
	kFriendsPanel:setAdaptInfo('friends_bg_panel' , 'friends_panel')

	kFriendsPanel:registerInitHandler(function (  )
		-- init callback function
		local root = kFriendsPanel:GetRawPanel()

		elements.di = tolua.cast(root:getChildByName('friends_bg_panel'), 'UIImageView')
		elements.di:setTouchEnable(true)

		elements.closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		elements.closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(kSceneObj))
		elements.closeBtn:setWidgetZOrder( 9999 )
		GameController.addButtonSound(elements.closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local nameImg = tolua.cast(root:getChildByName('input_bg_img'), 'UIImageView')
		elements.name = tolua.cast(UISvr:replaceUIImageViewByCCEditBox(nameImg) , 'CCEditBox')
		elements.name:setHAlignment(kCCTextAlignmentCenter)
		elements.name:setFontSize(20)
		elements.name:setPlaceHolder(getLocalStringValue('E_STR_SET_NAME'))
		elements.name:registerScriptEditBoxHandler(function ( t )
			-- editBox 事件回调
			if t == 'ended' then
				local noticeText = elements.name:getText()
				noticeText = CheckAndModifyStr(noticeText)
				elements.name:setText(noticeText)
			elseif t == 'began' then
				elements.name:setPosition(nameImg:getPosition())
			end
		end)

		elements.accept = tolua.cast(root:getChildByName('ok_btn'), 'UITextButton')
		elements.accept:registerScriptTapHandler(function (  )
			-- 搜索目标玩家
			local name = elements.name:getText()
			local nameLen = string.utf8len(name)
			if nameLen == 0 then
				GameController.showMessageBox(getLocalStringValue('E_STR_NAME_EMPTY'), MESSAGE_BOX_TYPE.OK)
				return
			elseif nameLen > kNameMaxLength then
				GameController.showMessageBox(getLocalStringValue('E_STR_NAME_TOO_LENG'), MESSAGE_BOX_TYPE.OK)
				return
			else 
				-- 匹配汉字和字母和数字
				local symbolIndex = string.find(name, '[^\128-\254^%w]')
				if symbolIndex then
					GameController.showMessageBox(getLocalStringValue('E_STR_SET_NAME_INVALID_TYPE'), MESSAGE_BOX_TYPE.OK)
					return
				end
			end

			-- 檢測是不是在搜索自己[多蛋疼的玩家啊]
			local playerName = PlayerCoreData.getPlayerName()
			if name == playerName then
				GameController.showMessageBox(getLocalStringValue('E_STR_FRIENDS_SEARCH_SELF'), MESSAGE_BOX_TYPE.OK)
				return
			end

			Message.sendPost('search', 'friend', '{"name":"' .. name .. '"}', function ( jsonData )
				-- 搜索玩家消息回调
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic['code'] ~= 0 then
					cclog('request error : ' .. jsonDic['desc'])
					return
				end

				local data = jsonDic['data']
				local info = data['info']
				if info == nil or _G.next(info) == nil then
					-- 提示
					local tip = getLocalStringValue('E_STR_FRIENDS_NOT_FOUND')
					GameController.showPrompts(tip, COLOR_TYPE.WHITE)
					return
				end

				recommend = {info}
				initRecommendList()
			end)
		end)
		GameController.addButtonSound(elements.accept , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		elements.sv = tolua.cast(root:getChildByName('ScrollView'), 'UIScrollView')
		elements.sv:setDirection(SCROLLVIEW_DIR_VERTICAL)
		elements.sv:setClippingEnable(true)
		-- 初始化完成 更新一次界面
		initRecommendList()
	end)

	UiMan.show(kSceneObj)
end

-- 重新拉取推荐好友列表数据
local function regetRecommend()
	-- 需要重新从服务器拉取数据 open 接口无法复用
	Message.sendPost('recommend', 'friend', '{}', function ( jsonData )
		-- 获取 推荐好友列表
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end

		local data = jsonDic['data']
		recommend = data['recommend']

		initRecommendList()
	end)
end

-- 刪除 推薦好友中 數據
-- 返回沒有刪除的個數
local function delRecommend(uid)
	local ct = 0
	for k, v in pairs(recommend) do
		if v ~= nil then
			if v.uid == uid then
				recommend[k] = nil
			else
				ct = ct + 1
			end
		end
	end
	return ct
end


------------------------------------------------------------------------------------
-- 打开推荐好友界面
function openFriendsRecommendPanel()
	elements = {}
	recommend = {}

	Message.sendPost('recommend', 'friend', '{}', function ( jsonData )
		-- 获取 推荐好友列表
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end

		local data = jsonDic['data']
		recommend = data['recommend']

		-- 打开好友推荐的界面
		initPanel()
	end)
end

-- 添加好友接口
function onRequestFriend(uid)
	Message.sendPost('apply', 'friend', '{"id":' .. uid .. '}', function( jsonData )
		-- 添加好友消息回调
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end

		local data = jsonDic['data']
		local status = data['status']

		-- 刪除推薦列表
		local d = delRecommend(uid)
		if d <= 0 then
			regetRecommend()		-- 推薦列表空 重新拉取
		else
			local card = elements.sv:getChildByTag(uid)
			local childArray = elements.sv:getChildren()
			local ct = childArray:count()
			local idx = childArray:indexOfObject(card)

			card:removeFromParentAndCleanup(true)
			if ct == 1 then
				return
			end
			elements.sv:resetChildrensPos()

			if idx == 0 then
				elements.sv:scrollToTop()
			end

			if idx == ct - 1 then
				elements.sv:scrollToBottom()
			end
		end

		-- 返回消息提示
		local stip = getLocalStringValue('E_STR_FRIENDS_APPLY_' .. status)
		GameController.showPrompts(stip, COLOR_TYPE.WHITE)
	end)
end


