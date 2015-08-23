
local e = require('ceremony/panel/friends_data'):getFriends() 		-- lock data
local elements = e.elements				-- 界面元素
local friends = e.friends				-- 好友数据
local applied = e.applied				-- 申请好友列表
local grain = e.grain					-- 是否有粮可收

-- local elements = {}				-- 界面元素
-- local friends = {}				-- 好友数据
-- local applied = {}				-- 申请好友列表
-- local grain = 0					-- 是否有粮可收

-- 界面常量
local kConstInitCardsCount = 6
local kSceneObj = 0
local kFriendsPanel = 0

-- 更新好友数量
local function updateFriendsCount()
	local limit = getGlobalIntegerValue('FriendCountLimit', -1)
	if limit == -1 then
		cclog('cant find key FriendCountLimit in global....')
		return
	end
	local ct = #friends
	elements.numTx:setText(ct .. '/' .. limit)
end

-- 更新赠送按钮状态
local function upateGaveBtnStatus()
	if elements.giveBtn:isActive() == true then
		elements.giveBtn:disable()
	end
	for _, v in pairs(friends) do
		if v.gave ~= 1 then
			elements.giveBtn:active()
			return
		end
	end
end

-- 更新界面逻辑
local function setCardsFoodVis()
	for _, v in pairs(friends) do
		local card = elements.friendsList:getChildByTag(v.uid)
		if card ~= nil then
			local food = tolua.cast(card:getChildByName('food_img'), 'UIImageView')
			food:setVisible(true)
		end
	end
end

-- 更新一件收取糧草提示
local function updateGetFoodStatus()
	if grain ~= 0 then
		elements.getBtn:active()
	else
		elements.getBtn:disable()
	end
end

-- 添加kConstInitCardsCount个名片
local function autoAddCards()
	-- 获取各种数据数量
	local childArray = elements.friendsList:getChildren()
	local alreadyCt = childArray:count()
	local conStatus = require('ceremony/panel/friends_data'):getControlerStatus()

	local count = 0
	for k, v in pairs(applied) do
		if v ~= nil then
			count = count + 1
			local cal = count - alreadyCt
			if cal > 0 and cal <= kConstInitCardsCount then
				if elements.friendsList:getChildByTag(v.uid) == nil then
					local widget = createFriendsCard(v.uid, v.name, v.headpic, v.level, v.last_login, v.fight_force, false, v.legion_name, conStatus.kApplied)
					-- 设置界面 显示神马 隐藏神马
					local chat = tolua.cast(widget:getChildByName('private_chat_btn'), 'UITextButton')
					chat:setVisible(false)

					local add = tolua.cast(widget:getChildByName('add_btn'), 'UITextButton')
					add:setVisible(false)

					local food = tolua.cast(widget:getChildByName('food_img'), 'UIImageView')
					food:setVisible(false)

					-- 添加界面到 SV 中
					elements.friendsList:addChildToBottom(widget)
				end
			end

			-- 添加够了 就死出去
			if cal > kConstInitCardsCount then
				return
			end
		end
	end

	local vecNewData = getPrivateVecNewData()
	if vecNewData == nil then
		vecNewData = {}
	end
	for k, v in pairs(friends) do
		if v ~= nil then
			count = count + 1
			local cal = count - alreadyCt
			if cal > 0 and cal <= kConstInitCardsCount then
				local hasMsg = false
				if vecNewData[tostring(v.uid)] ~= nil and #vecNewData[tostring(v.uid)] > 0 then
					hasMsg = true
				end

				if elements.friendsList:getChildByTag(v.uid) == nil then
					local widget = createFriendsCard(v.uid, v.name, v.headpic, v.level, v.last_login, v.fight_force, hasMsg, v.legion_name, conStatus.kFriends)
					-- 设置界面 显示神马 隐藏神马
					local add = tolua.cast(widget:getChildByName('add_btn'), 'UITextButton')
					add:setVisible(false)

					local accept = tolua.cast(widget:getChildByName('ok_btn'), 'UITextButton')
					accept:setVisible(false)

					local refuse = tolua.cast(widget:getChildByName('no_btn'), 'UITextButton')
					refuse:setVisible(false)

					local food = tolua.cast(widget:getChildByName('food_img'), 'UIImageView')
					food:setVisible(v.gave ~= 0)

					elements.friendsList:addChildToBottom(widget)
				end
			end

			-- 添加够了 就死出去
			if cal > kConstInitCardsCount then
				return
			end
		end
	end
end

-- 初始化 界面
local function initPanel()
	-- 初始化界面
	kSceneObj = SceneObjEx:createObj('panel/friends_bg_panel.json' , 'friends-bg-in-lua')
	kFriendsPanel = kSceneObj:getPanelObj()
	kFriendsPanel:setAdaptInfo('friends_bg_panel' , 'friends_panel')

	kFriendsPanel:registerInitHandler(function (  )
		-- init callback function
		local root = kFriendsPanel:GetRawPanel()
		elements.frame = tolua.cast(root:getChildByName('friends_bg_panel'), 'UIImageView')
		elements.frame:setTouchEnable(true)

		elements.closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		elements.closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(kSceneObj))
		elements.closeBtn:setWidgetZOrder( 9999 )
		GameController.addButtonSound(elements.closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		elements.numTx = tolua.cast(root:getChildByName('num_tx'), 'UILabel')

		elements.addBtn = tolua.cast(root:getChildByName('add_friend_btn'), 'UITextButton')
		elements.addBtn:registerScriptTapHandler(function (  )
			-- 添加好友 点击回调
			openFriendsRecommendPanel()
		end)
		elements.addBtn:setWidgetZOrder(9999)
		GameController.addButtonSound(elements.addBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		elements.giveBtn = tolua.cast(root:getChildByName('send_btn'), 'UITextButton')
		elements.giveBtn:registerScriptTapHandler(function (  )
			-- 赠送粮草 点击回调
			Message.sendPost('give_food', 'friend', '{}', function ( jsonData )
				-- 赠送粮草 消息回调
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic['code'] ~= 0 then
					cclog('request error : ' .. jsonDic['desc'])
					return
				end

				-- 更新好友數據
				for _, v in pairs(friends) do
					v.gave = 1
				end

				local food = getGlobalIntegerValue('FriendGiveFood', 0)
				local strTips = getLocalStringValue('E_STR_FRIENDS_GIVE_FOOD')
				GameController.showPrompts(string.format(strTips, food), COLOR_TYPE.WHITE)

				-- 更新每一	個名片
				setCardsFoodVis()

				upateGaveBtnStatus()
			end)
		end)
		elements.giveBtn:setWidgetZOrder(9999)
		GameController.addButtonSound(elements.giveBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		elements.getBtn = tolua.cast(root:getChildByName('get_btn'), 'UITextButton')
		elements.getBtn:registerScriptTapHandler(function (  )
			-- 收取粮草 点击回调
			Message.sendPost('get_food', 'friend', '{}', function ( jsonData )
				-- 收取粮草 消息回调
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic['code'] ~= 0 then
					cclog('request error : ' .. jsonDic['desc'])
					return
				end

				local data = jsonDic['data']

				-- 收取是否已達上限
				local limit = data['limit']
				if limit == 1 then
					local strTips = getLocalStringValue('E_STR_FRIENDS_GET_FOOD')
					GameController.showPrompts(string.format(strTips, food), COLOR_TYPE.WHITE)
					return
				end

				-- 当前玩家粮草
				local food = data['got']
				PlayerCore:addFoodDelta(food)

				local strTips = getLocalStringValue('E_STR_FRIENDS_GET_FOOD')
				GameController.showPrompts(string.format(strTips, food), COLOR_TYPE.WHITE)
				grain = 0

				updateGetFoodStatus()
			end)
		end)
		elements.getBtn:setWidgetZOrder(9999)
		GameController.addButtonSound(elements.getBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		elements.getFlagIco = tolua.cast(root:getChildByName('quan_ico'), 'UIImageView')

		elements.friendsList = tolua.cast(root:getChildByName('ScrollView'), 'UIScrollView')
		elements.friendsList:setDirection(SCROLLVIEW_DIR_VERTICAL)
		elements.friendsList:setClippingEnable(true)
		elements.friendsList:registerScrollToBottomEvent(function (  )
			autoAddCards()
		end)

		-- 更新赠送状态
		upateGaveBtnStatus()

		-- 更新收取状态
		updateGetFoodStatus()

		-- 更新好友数量
		updateFriendsCount()

		-- 初始化列表好了 先添加一次Cards
		autoAddCards()
		elements.friendsList:scrollToTop()
	end)

	kFriendsPanel:registerOnHideHandler(function (  )
		elements = {}
		friends = {}
		applied = {}
		grain = nil
	end)
	UiMan.show(kSceneObj)
end


-----------------------------------------------------------------------------------------------------------------------
-- 打开好友界面
function openFriendsPanel()
	-- 清空数据
	elements = {}
	friends = {}
	applied = {}
	grain = 0

	Message.sendPost('get','friend','{}', function (jsonData)
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end

		-- 设置好友数据
		local data = jsonDic['data']

		friends = data['friends']
		applied = data['applied']
		grain = data['food']

		local vecNewData = getPrivateVecNewData()
		if vecNewData == nil then
			vecNewData = {}
		end

		-- 战斗力 从高到低排序
		if friends then
			table.sort( friends, function (a, b)
				if vecNewData[tostring(a.uid)] ~= nil then
					return true
				elseif vecNewData[tostring(b.uid)] ~= nil then
					return false
				else
					return a.fight_force > b.fight_force
				end
			end)
		end

		if #applied == 0 and #friends == 0 then
			openFriendsRecommendPanel()
			return
		end

		-- 获取数据之后 再打开界面
		initPanel()
	end)
end

-- 接受好友申請處理函數
function onFriendAgreeHandler(uid)
	Message.sendPost('handle_apply', 'friend', '{"id":' .. uid .. ', "agree": 1}', function( jsonData )
		-- 接受好友申請消息回调
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end

		local data = jsonDic['data']
		if data['succ'] ~= nil then			-- 成功
			-- 从申请列表中找出玩家
			-- 添加至好友列表数据里
			local bSuc = false
			for k, v in pairs(applied) do
				if v.uid == uid then
					v.gave = 0
					v.time = nil
					table.insert(friends, v)
					table.remove(applied, k)
					bSuc = true
					break
				end
			end

			-- 提示
			local tip = getLocalStringValue('E_STR_FRIENDS_ADD_SUC')
			GameController.showPrompts(tip, COLOR_TYPE.WHITE)

			-- 把这个卡牌从 SV 中拿下来 更新位置 然后再加到最后
			if bSuc == true then
				-- 成功了 更新一次赠送按钮
				upateGaveBtnStatus()

				-- 更新好友数量
				updateFriendsCount()

				local childArray = elements.friendsList:getChildren()
				local ct = childArray:count()

				-- 当好友列表名片少于 6 个的时候 自动生成
				if ct < kConstInitCardsCount then
					autoAddCards()
					ct = childArray:count()
				end

				local card = elements.friendsList:getChildByTag(uid)
				local idx = childArray:indexOfObject(card)
				-- 当还需要加载申请列表的时候...
				if ct <= #applied then
					card:removeFromParentAndCleanup(true)
					card = nil
				else
					local chat = tolua.cast(card:getChildByName('private_chat_btn'), 'UITextButton')
					chat:setVisible(true)

					local add = tolua.cast(card:getChildByName('add_btn'), 'UITextButton')
					add:setVisible(false)

					local food = tolua.cast(card:getChildByName('food_img'), 'UIImageView')
					food:setVisible(false)

					local accept = tolua.cast(card:getChildByName('ok_btn'), 'UITextButton')
					accept:setVisible(false)

					local refuse = tolua.cast(card:getChildByName('no_btn'), 'UITextButton')
					refuse:setVisible(false)

					-- 做一次回调函数 status 修正 Fucking
					local frame = tolua.cast(card:getChildByName('player_info_bg_img'), 'UIImageView')
					frame:setTouchEnable(true)
					for _, v in pairs(friends) do
						if v ~= nil and v.uid == uid then
							changeFriendsControlerStatus( frame, v, require('ceremony/panel/friends_data'):getControlerStatus().kFriends)
						end
					end

					card:removeFromParentAndCleanup(false)
				end
				elements.friendsList:resetChildrensPos()

				if card ~= nil then
					elements.friendsList:addChildToBottom(card)
				end

				ct = childArray:count()
				if ct == 0 then
					return
				end

				if idx == 0 then
					elements.friendsList:scrollToTop()
				end

				if idx == ct - 1 then
					elements.friendsList:scrollToBottom()
				end
			end
			return
		end

		if data['fulled'] ~= nil then			-- 對方好友滿
			local tip = getLocalStringValue('E_STR_FRIENDS_FULL')
			GameController.showPrompts(tip, COLOR_TYPE.WHITE)
			return
		end

		-- 未知錯誤
		local tip = getLocalStringValue('E_STR_FRIENDS_UNKNOW')
		GameController.showPrompts(tip, COLOR_TYPE.WHITE)
	end)
end

-- 拒絕好友申請處理函數
function onFreindRefusHandler( uid )
	Message.sendPost('handle_apply', 'friend', '{"id":' .. uid .. ', "agree": 0}', function( jsonData )
		-- 拒絕好友申請消息回调
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end

		local data = jsonDic['data']
		if data['succ'] ~= nil then
			-- 從申請列表中 刪除
			local bSec = false
			for k, v in pairs(applied) do
				if v.uid == uid then
					table.remove(applied, k)
					bSec = true
					break
				end
			end

			-- 提示
			local tip = getLocalStringValue('E_STR_FRIENDS_DEL_SUC')
			GameController.showPrompts(tip, COLOR_TYPE.WHITE)

			-- 刷新一下界面
			if bSec == true then
				local card = elements.friendsList:getChildByTag(uid)
				local childArray = elements.friendsList:getChildren()
				local ct = childArray:count()
				local idx = childArray:indexOfObject(card)

				card:removeFromParentAndCleanup(true)
				if ct == 1 then
					return
				end
				elements.friendsList:resetChildrensPos()

				if idx == 0 then
					elements.friendsList:scrollToTop()
				end

				if idx == ct - 1 then
					elements.friendsList:scrollToBottom()
				end
			end
			return
		end

		-- 提示
		local tip = getLocalStringValue('E_STR_FRIENDS_UNKNOW')
		GameController.showPrompts(tip, COLOR_TYPE.WHITE)
	end)
end

-- 刪除好友接口
function onDeleteFriend( uid )
	local tip = getLocalStringValue('E_STR_FRIENDS_DELETE')
	GameController.showMessageBox(tip, MESSAGE_BOX_TYPE.OK_CANCEL, function ()
		Message.sendPost('remove', 'friend', '{"id":' .. uid .. '}', function( jsonData )
			-- 刪除好友 消息回調
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			for k, v in pairs(friends) do
				if v.uid == uid then
					table.remove(friends, k)
					break
				end
			end

			local card = elements.friendsList:getChildByTag(uid)
			if card == nil then
				return
			end
			local childArray = elements.friendsList:getChildren()
			local ct = childArray:count()
			local idx = childArray:indexOfObject(card)

			card:removeFromParentAndCleanup(true)

			-- 更新好友数量
			updateFriendsCount()
			if ct == 1 then
				return
			end
			elements.friendsList:resetChildrensPos()

			if idx == 0 then
				elements.friendsList:scrollToTop()
			end

			if idx == ct - 1 then
				elements.friendsList:scrollToBottom()
			end

			-- 删除的人太多了...自动加一点儿补足界面
			if ct < kConstInitCardsCount - 1 then
				autoAddCards()
			end
		end)
	end)
end

-- 设置收粮按钮状态
function setFriendsGetBtnStatus( vis )
	if elements.getBtn == nil then
		return
	end

	if vis == true then
		grain = 1
	else
		grain = 0
	end
	updateGetFoodStatus()
end

