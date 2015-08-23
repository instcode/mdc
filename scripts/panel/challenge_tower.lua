ChallengeTower = {}

-- 建号时间
--local createPlayerTime = PlayerCoreData.getCreatePlayerTime()
-- 活动时间
--local activityTime = createPlayerTime + GameData:getGlobalValue('TowerActivityTime')
local activityTime = PlayerCoreData.getCreatePlayerTime() + GameData:getGlobalValue('TowerActivityTime')
-- 领奖时间
--local getAwardTime = activityTime + GameData:getGlobalValue('GetTowerActivityRewardTime')
local getAwardTime = PlayerCoreData.getCreatePlayerTime() + GameData:getGlobalValue('TowerActivityTime') + GameData:getGlobalValue('GetTowerActivityRewardTime')
local towerConf = GameData:getArrayData('toweractivityreward.dat')

-- TODO: 检查挑战重楼是否有奖励未领
function ChallengeTower.isActive()
	local serverTime = UserData:getServerTime()
	local getAwardTime = PlayerCoreData.getCreatePlayerTime() + GameData:getGlobalValue('TowerActivityTime') + GameData:getGlobalValue('GetTowerActivityRewardTime')

	if serverTime < getAwardTime then
		local dataTab = UserData:getChallengeTowerData()
		local maxFloor = dataTab['floor'] or 0
		local got = dataTab['got'] or {}

		local hasAward = false
		table.foreach(towerConf , function ( _, value)
			if maxFloor >= tonumber(value['Floor']) and got[tonumber(value['Id'])] == 0 and not hasAward then
				hasAward = true
			end
		end)
		return hasAward
	else 
		return false
	end
end

-- TODO: 判断挑战重楼是否在开启时间内
function ChallengeTower.isOverTime()
	local serverTime = UserData:getServerTime()
	local getAwardTime = PlayerCoreData.getCreatePlayerTime() + GameData:getGlobalValue('TowerActivityTime') + GameData:getGlobalValue('GetTowerActivityRewardTime')

	if serverTime < PlayerCoreData.getCreatePlayerTime() or serverTime > getAwardTime then
		return true
	end
	return false
end

function ChallengeTower.enter()
	cclog('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++')
	-- ui
	local sceneObj
	local panel
	local itemSv
	local goBtn
	local timeTx
	local timeOverTx
	local timeCDTx
	local timeOverCDTx
	-- data
	local itemTab = {}
	local maxFloor
	local towerGotMap = {}

	local function updateItemStatus()
		table.foreach(itemTab , function(_ , value)
			local item = value['item']
			local data = value['data']
			local getAwardTx = tolua.cast(item:getChildByName('get_award_tx') , 'UILabel')
			local getBtn = tolua.cast(item:getChildByName('get_award_btn') , 'UIButton')
			getAwardTx:setVisible(false)
			getBtn:setVisible(true)

			local getStatus = towerGotMap[tonumber(data.Id)]
			if getStatus then
				if maxFloor < tonumber(data.Floor) then
					getBtn:disable()
				else
					getBtn:active()
					if getStatus == 1 then
						getAwardTx:setVisible(true)
						getBtn:setVisible(false)
					end
				end
			else
				cclog('failed in updateItemStatus')
			end
		end)
	end

	local function getAwardResponse( jsonData )
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end

		local data = jsonDic['data']
		if not data then 
			return 
		end

		local towerData = data['tower_activity']
		local str = json.encode(towerData)
		UserData:setChallengeTowerData(str)
		maxFloor = tonumber(towerData['floor']) or 0

		towerGotMap = {}
		local index = 1
		table.foreach(towerData['got'] , function(_,value)
			towerGotMap[index] = value
			index = index + 1
		end)

		local msgBox = {}

		local awards = data['awards']
		local awardStr = json.encode(awards)
		UserData.parseAwardJson(awardStr)

		for _ , v in pairs ( awards ) do
			local reawrdStr = UserData.makeAwardStr(v)
			local award = UserData:getAward(reawrdStr)

			if award.count ~= 0 then
				local promptStr = string.format(getLocalString('E_STR_YOUR_GAIN_MATERIAL') , award.count , award.name)
				table.insert(msgBox , promptStr)
			end
		end

		if #msgBox > 0 then
			GameController.showPrompts( msgBox )
		end

		updateItemStatus()
	end

	local function getAward( id )
		local getAwardTime = PlayerCoreData.getCreatePlayerTime() + GameData:getGlobalValue('TowerActivityTime') + GameData:getGlobalValue('GetTowerActivityRewardTime')

		if UserData:getServerTime() > getAwardTime then 
			GameController.showPrompts(getLocalString('E_STR_GETAWARD_OVERTIME') , COLOR_TYPE.RED)
			return 
		end

		local tab = {id = id}
		local jsonData = json.encode(tab)
		Message.sendPost('get_reward','tower_activity', jsonData , getAwardResponse)
	end

	local function genRewardItem()
		index = 0
		table.foreach(towerConf , function(_ , value)
			local pItem = createWidgetByName('panel/challenge_card_panel.json')
			if not pItem then
				print('failed to create challenge_card_panel!')
			else
				local cardImage = tolua.cast(pItem:getChildByName('challenge_card_img') , 'UIImageView')
				local floorTx = tolua.cast(cardImage:getChildByName('number_tx') , 'UILabel')
				floorTx:setTextFromInt(tonumber(value['Floor']))
				floorTx:setColor(COLOR_TYPE.GREEN)

				local infoTx1 = tolua.cast(cardImage:getChildByName('info_1_tx'),'UILabel')
				local infoTx2 = tolua.cast(cardImage:getChildByName('info_2_tx'),'UILabel')
				local infoTx3 = tolua.cast(cardImage:getChildByName('info_3_tx'),'UILabel')
				infoTx1:setPreferredSize(210,1)
				infoTx3:setPreferredSize(100,1)
				infoTx2:setText(string.format(getLocalStringValue('E_STR_TOWER_CHALLENGE'),tonumber(value['Floor'])))
				infoTx2:setPreferredSize(200,1)

				local awardIcon = tolua.cast(pItem:getChildByName('award_ico') , 'UIImageView')
				local awardNumTx = tolua.cast(pItem:getChildByName('award_num_tx') , 'UILabel')
				local awardNameTx  =tolua.cast(pItem:getChildByName('award_name_tx') , 'UILabel')
				local awardTab = UserData:getAward(value['Award1'])
				awardNameTx:setPreferredSize(210,1)
				awardIcon:setTexture(awardTab.icon)
				awardIcon:setTouchEnable(true)
				awardIcon:registerScriptTapHandler(function ()
					local awardStr = value['Award1']
					UISvr:showTipsForAward(awardStr)
				end)
				awardNameTx:setText(awardTab.name)
				awardNameTx:setColor(awardTab.color)
				awardNumTx:setTextFromInt(tonumber(awardTab.count))

				local cashTx = tolua.cast(pItem:getChildByName('cash_num_tx') , 'UILabel')
				cashTx:setTextFromInt(tonumber(value['Value']))

				local getBtn = tolua.cast(pItem:getChildByName('get_award_btn') , 'UIButton')
				getBtn:registerScriptTapHandler( function ()
					local id = value['Id']
					getAward(tonumber(id))
				end)

				local tab = {}
				tab['data'] = value
				tab['item'] = pItem
				table.insert(itemTab , tab)

				pItem:setPosition(ccp(index * 240 , 60))
				itemSv:addChild(pItem)
				index = index + 1
			end
		end)
	end

	local function updateTime()
		local serverTime = UserData:getServerTime()
		local activityTime = PlayerCoreData.getCreatePlayerTime() + GameData:getGlobalValue('TowerActivityTime')
		local getAwardTime = PlayerCoreData.getCreatePlayerTime() + GameData:getGlobalValue('TowerActivityTime') + GameData:getGlobalValue('GetTowerActivityRewardTime')

		if serverTime < activityTime then
			timeTx:setVisible(true)
			timeOverTx:setVisible(false)
			timeCDTx:setTime(activityTime - serverTime)
		elseif serverTime > activityTime and serverTime < getAwardTime then
			timeTx:setVisible(false)
			timeOverTx:setVisible(true)
			timeOverCDTx:setTime(getAwardTime - serverTime)
			goBtn:setVisible(false)
		else
			timeTx:setVisible(false)
			timeOverTx:setVisible(false)
			goBtn:setVisible(false)
		end
	end

	local function timeOver(dt)
		updateTime()
	end

	local function init()
		local root = panel:GetRawPanel()
		local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.SMART_HIDE)
		end)
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local parentTx
		timeTx = tolua.cast(root:getChildByName('time_one_tx') , 'UILabel')
		parentTx = tolua.cast(timeTx:getChildByName('time_tx') , 'UILabel')
		parentTx:setText('')
		timeCDTx = UICDLabel:create()
		timeCDTx:setFontSize(24)
		timeCDTx:setPosition(ccp(20,0))
		timeCDTx:setFontColor(COLOR_TYPE.LIGHT_YELLOW)
		parentTx:addChild(timeCDTx)
		timeCDTx:registerTimeoutHandler(timeOver)
		timeOverTx = tolua.cast(root:getChildByName('time_two_tx') , 'UILabel')
		parentTx = tolua.cast(timeOverTx:getChildByName('time_tx') , 'UILabel')
		parentTx:setText('')
		timeOverCDTx = UICDLabel:create()
		timeOverCDTx:setFontSize(24)
		timeOverCDTx:setPosition(ccp(20,0))
		timeOverCDTx:setFontColor(COLOR_TYPE.LIGHT_YELLOW)
		parentTx:addChild(timeOverCDTx)
		timeOverCDTx:registerTimeoutHandler(timeOver)

		local cashNumTx = tolua.cast(root:getChildByName('cash_num_tx') , 'UILabel')
		local cashIcon = tolua.cast(cashNumTx:getChildByName('cash_ico') , 'UIImageView')
		local honorNumTx = tolua.cast(root:getChildByName('honor_num_tx') , 'UILabel')
		local honorIcon = tolua.cast(honorNumTx:getChildByName('honor_ico') , 'UIImageView')
		cashNumTx:setVisible(false)
		cashIcon:setVisible(false)
		honorNumTx:setVisible(false)
		honorIcon:setVisible(false)

		local titleNameTx = tolua.cast(root:getChildByName('title_name_tx') , 'UILabel')
		titleNameTx:setText(getLocalString('E_STR_CHALLENGE_TOWER_DESC'))

		goBtn = UITextButton:create()
		goBtn:setTextures('uires/ui_2nd/com/common_btn/green_btn.png','','')
		goBtn:setFontSize(32)
		goBtn:setText(getLocalString('E_STR_GOTO'))
		goBtn:setTouchEnable(true)
		goBtn:setScale9Enable(true)
		goBtn:setScale9Size(CCSizeMake(145,60))

		local roleBg = root:getChildByName('role_img')

		GameController.addButtonSound(goBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		goBtn:registerScriptTapHandler(function ()
			-- 前往千重楼
			CUIManager:GetInstance():HideAllObjects()
			CThousandFloorMgr:GetInst():Show()
		end)
		goBtn:setPosition(ccp(roleBg:getContentSize().width - goBtn:getContentSize().width / 2 - 35 ,48))
		goBtn:setWidgetZOrder(99)
		roleBg:addChild(goBtn)

		itemSv = tolua.cast(root:getChildByName('equip_sv') , 'UIScrollView')
		itemSv:removeAllChildrenAndCleanUp(true)
		itemSv:setClippingEnable(true)
		itemSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)

		-- 产生滑动列表 -- 
		genRewardItem()
		-- 更新领取状态 --
		updateItemStatus()
		-- 更新计时器 --
		updateTime()
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/select_role_bg_panel.json', 'tower-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('role_bg_img' , 'role_img')

		panel:registerInitHandler(init)

	    CUIManager:GetInstance():ShowObject(sceneObj, ELF_SHOW.SMART)
	end

	local function requestCTDataResponse( jsonData )
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end

		local data = jsonDic['data']
		if not data then return end

		local towerData = data['tower_activity']
		local str = json.encode(towerData)
		UserData:setChallengeTowerData(str)

		maxFloor = tonumber(towerData['floor']) or 0

		towerGotMap = {}
		local index = 1
		table.foreach(towerData['got'] , function(_,value)
			towerGotMap[index] = value
			index = index + 1
		end)
		createPanel()
	end

	local function requestCTData()
		Message.sendPost('get','tower_activity','{}' , requestCTDataResponse)
	end

	-- 入口
	requestCTData()
end