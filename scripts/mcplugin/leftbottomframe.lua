-- const
local BEGIN_POS	= 160
local ICON_INTERVAL = 100
local SPEED = 0.2
-- ui
local leftBtn
local bgPanel
local riBoudBtn
local chatBtn
local friendBtn
local itemIco
local bottomNewIco
local messagebottomNewIco
local achievebottomNewIco
local godTips
local chatTips
local friendTips
-- data
local isOpen = false
local fnBtn = {}

local function getChild( p , n , t )
	return tolua.cast(p:getChildByName(n) , t)
end

local function runPlaintAction ( widget )
	local actArr = CCArray:create()
	local mov1 = CCRotateBy:create(0.15, 15)
	local mov2 = CCRotateBy:create(0.15, -15)
	for i = 1 , 3 do
	    actArr:addObject(mov1)
	    actArr:addObject(mov1:reverse())
	    actArr:addObject(mov2)
	    actArr:addObject(mov2:reverse())
   	end
	actArr:addObject(CCDelayTime:create(1))
	widget:runAction(CCRepeatForever:create(CCSequence:create(actArr)))
end

local function showTargetPanel( tag )
	if tag == 5 then
		genSettingPanel()
	elseif tag == 4 then
		-- genStrongPanel()
		requestSystemReward(0)
	elseif tag == 3 then
		openBagPanel(bs.E_BAG_MENU_ALL)
	elseif tag == 2 then
		messagebottomNewIco:setVisible(false)
		genNewsPanel(NEWS_TAG.TAG_ALL)
	elseif tag == 1 then
		ShowBeautyPanel(-2)
	elseif tag == 0 then
		genAchievementPanel()
	else
		print( 'failed to show Panel , tag = ' .. tag)
	end
end

local function setLeftBottomNew()
	bottomNewIco:setVisible(isOpen and
		(fnBtn[3]:isVisible() and messagebottomNewIco:isVisible()) or 
		(fnBtn[1]:isVisible() and achievebottomNewIco:isVisible()))
end

local function setLeftBtnStatus()
	if isOpen == false then
		leftBtn:setTextures('uires/ui_2nd/com/panel/mainscene/left_btn_2.png', '', '')
		isOpen = true
	else
		leftBtn:setTextures('uires/ui_2nd/com/panel/mainscene/left_btn_1.png', '', '')
		isOpen = false
	end
	leftBtn:setTouchEnable(true)
	setLeftBottomNew()
end

local function LockBtn()
	for i = 1 , 6 do
		fnBtn[i]:setTouchEnable(false)
	end
end

local function OpneBtn()
	for i = 1 , 6 do
		fnBtn[i]:setTouchEnable(true)
	end
end

local function setLeftPanelStatus( isInstant )
	if isInstant == nil then
		isInstant = false
	end
	local openNum = 0
	local size = #fnBtn
	local playerLv = PlayerCoreData.getPlayerLevel()

	for i = 0 , size - 1 do
		local btnVisible = false
		if i == 0 then				-- 成就
			btnVisible = playerLv >= getGlobalIntegerValue('AchievementOpenLevel')
		elseif i == 1 then			-- 美人
			btnVisible = IsAnyGirlPresent()
		elseif i == 2 then			-- 消息
			btnVisible = playerLv >= getGlobalIntegerValue('MsgOpenLevel')
		elseif i == 3 then			-- 背包
			btnVisible = playerLv >= getGlobalIntegerValue('KnapsackOpenLevel')
		elseif i == 4 then			-- 变强
			btnVisible = playerLv >= getGlobalIntegerValue('BulletinOpenLevel')
		elseif i == 5 then			-- 设置
			btnVisible = playerLv >= 1
		else
			btnVisible = false
		end
		fnBtn[i+1]:setVisible( btnVisible )
	end

	local index = 0
	local lastIconPosX = 0

	for i = 0 , size - 1 do
		if fnBtn[i+1]:isVisible() then
			local tempPosX = BEGIN_POS + index * ICON_INTERVAL
			fnBtn[i+1]:setPosition( ccp( tempPosX , 48) )
			lastIconPosX = tempPosX
			index = index + 1
		end
	end

	itemIco:setScale9Size(CCSizeMake(165 + 90 * index , 52))
	itemIco:stopAllActions()

	if isOpen == false then
		bgPanel:setSize(CCSizeMake(0,0))
	else
		bgPanel:setSize(CCSizeMake(165 + 90 * index , 115))
	end

	local arr = CCArray:create()
	local move = CCMoveTo:create(isInstant and 0 or SPEED , ccp((isOpen == false) and -itemIco:getContentSize().width or 0 , 0))
	local func = CCCallFunc:create(setLeftBtnStatus)
	arr:addObject(CCCallFunc:create(LockBtn))
	arr:addObject(move)
	arr:addObject(func)
	arr:addObject(CCCallFunc:create(OpneBtn))
	itemIco:runAction(CCSequence:create(arr))
	UpdateSceneId(30085)	-- 主城界面左下角按钮
end

function updateChatVisibility()
	if getGlobalIntegerValue('ChatOpenLevel') > PlayerCoreData.getPlayerLevel() then
		chatBtn:setVisible(false)
		friendBtn:setVisible(false)
	else
		chatBtn:setVisible(true)
		friendBtn:setVisible(true)
	end
end

local function updateLvbuVisibility()
	if riBoudBtn then
		riBoudBtn:setVisible( not _getGodRoleIfIsOver() )
		local riboudIco = getChild(riBoudBtn , 'god_role_ico' , 'UIImageView')
		riboudIco:setTexture( _getGodRole() )
	end
end

local function initPanel( widget )
	leftBtn = getChild(widget , 'left_btn' , 'UIButton')
	leftBtn:registerScriptTapHandler(function ()
		leftBtn:setTouchEnable(false)
		setLeftPanelStatus()
	end)
	bgPanel = getChild(widget , 'jiaohu_pl' , 'UIPanel')
	itemIco = getChild(widget , 'tiao_ico' , 'UIImageView')
	itemIco:setScale9Enable(true)
	itemIco:setAnchorPoint(ccp(0,0))
	bottomNewIco = getChild(leftBtn , 'quan_ico' , 'UIImageView')
	local plaintTx = getChild(bottomNewIco , 'gantan_tx' , 'UILabel')
	runPlaintAction( plaintTx )

	fnBtn = {}
	for i = 1 , 6 do
		local btn = getChild(itemIco , 'fn_' .. i .. '_btn' , 'UIButton')
		btn:setActionTag(i - 1)
		btn:setVisible(false)
		btn:setAnchorPoint(ccp(0.5 , 0.5))
		btn:registerScriptTapHandler(function ()
			showTargetPanel(btn:getActionTag())
		end)
		table.insert(fnBtn , btn)
	end

	achievebottomNewIco = getChild(fnBtn[1] , 'gantan_ico' , 'UIImageView')
	achievebottomNewIco:setVisible(false)
	local plaintTx1 = getChild(achievebottomNewIco , 'gantan_tx' , 'UILabel')
	runPlaintAction( plaintTx1 )

	messagebottomNewIco = getChild(fnBtn[3] , 'gantan_ico' , 'UIImageView')
	messagebottomNewIco:setVisible(false)
	local plaintTx2 = getChild(messagebottomNewIco , 'gantan_tx' , 'UILabel')
	runPlaintAction( plaintTx2 )

	riBoudBtn = getChild(widget , 'god_role_btn' , 'UIButton')
	riBoudBtn:selectEffect(1)
	riBoudBtn:registerScriptTapHandler( GodMain.giveGodMain )		-- 神将放送

	godTips = getChild(riBoudBtn , 'quan_ico' , 'UIImageView')
	godTips:setVisible(false)

	chatBtn = getChild(widget , 'chat_btn' , 'UIButton')
	chatBtn:registerScriptTapHandler( function ()
		require('ceremony/panel/chat/chat_panel'):genChatPanel()
	end )
	chatTips = getChild(chatBtn , 'quan_ico' , 'UIImageView')
	chatTips:setVisible(false)

	friendBtn = getChild(widget , 'friends_btn' , 'UIButton')
	friendBtn:registerScriptTapHandler( function (  )
		setFriendTipsVisible(false)
		openFriendsPanel()
	end )
	friendTips = getChild(friendBtn , 'quan_ico' , 'UIImageView')
	friendTips:setVisible(false)

	updateLvbuVisibility()
	updateChatVisibility()
	setLeftPanelStatus( true )

	fnBtn[2]:setTextures('uires/ui_2nd/com/panel/mainscene/girl.png', '', '')
end

local function genLeftBottomFrame(name , ispackup)
	local widget = createWidgetByName('panel/mainscene_left_btn_panel.json')
	initPanel(widget)
	return widget
end

function createLeftBottomFrame(parent , name , ispackup )
	local frame = genLeftBottomFrame(name, ispackup)
	frame:setPosition(ccp(0,0))
	parent:addChild(frame)
	frame:setName('leftbottom-frame')
	print('leftbottom-frame installed.')
end

---------------------- update API ------------------------

function setLeftPanelStatus_leftBottom( isinstant )			--控制面板展开还是收起
	setLeftPanelStatus( isinstant )	-- 默认收起
end

function updateRiboudStatus_leftBottom()		-- 更新吕布活动状态
	updateLvbuVisibility()
	updateChatVisibility()
end

function setAchievementIcon_leftBottom( vis )
	achievebottomNewIco:setVisible( vis )
	setLeftBottomNew()
end

function setGodRoleIcon_leftBottom( vis )
	godTips:setVisible( vis )
end

function setChatTipsVisible(vis)
	chatTips:setVisible(vis)
end

function setFriendTipsVisible( vis )
	friendTips:setVisible(vis)
end

function setMessageIcon_leftBottom( vis )
	if messagebottomNewIco:isVisible() == false then
		messagebottomNewIco:setVisible( vis )
	end
	setLeftBottomNew()
end

function updateStatus_leftBottom()
	local playerLv = PlayerCoreData.getPlayerLevel()

	leftBtn:setVisible(playerLv >= getGlobalIntegerValue('KnapsackOpenLevel'))
	itemIco:setVisible(playerLv >= getGlobalIntegerValue('KnapsackOpenLevel'))
end

function closeAll_leftBottom()
	local sizeTiao = itemIco:getContentSize()
	local tWidth = sizeTiao.width
	if isOpen == false then
		bgPanel:setSize(CCSizeMake(0,0))
		local arr = CCArray:create()
		arr:addObject(CCCallFunc:create(LockBtn))
		arr:addObject(CCMoveTo:create(SPEED , ccp(-tWidth , 0)))
		arr:addObject(CCCallFunc:create(setLeftBtnStatus))
		arr:addObject(CCCallFunc:create(OpneBtn))
		itemIco:runAction(CCSequence:create(arr))
	end
end