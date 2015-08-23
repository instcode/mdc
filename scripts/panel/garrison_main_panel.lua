
GarrisonMine = {}

	local isNeedUpdate = false
	local isWin = false
	local mineId = 0
	--UserData:getServerTime()
	--金矿信息
	local mineData
	--武将品质
	local E_ROLE_QUALITY_WHITE = 0
	local E_ROLE_QUALITY_BLUE = 1
	local E_ROLE_QUALITY_PURPLE = 2
	local E_ROLE_QUALITY_ORANGE = 3
	local E_ROLE_QUALITY_ARED = 4
	local E_ROLE_QUALITY_SRED = 5
	--res
	local RES_DAO = 'uires/ui_2nd/com/panel/common/dao.png'
	local RES_QIANG = 'uires/ui_2nd/com/panel/common/qiang.png'
	local RES_QI = 'uires/ui_2nd/com/panel/common/qibing.png'
	local RES_MOU = 'uires/ui_2nd/com/panel/common/mou.png'
	local RES_HONG = 'uires/ui_2nd/com/panel/common/hong.png'

	local DAO_ICON = 'uires/ui_2nd/com/panel/pass/dao.png'
	local QIANG_ICON = 'uires/ui_2nd/com/panel/pass/qiang.png'
	local QI_ICON = 'uires/ui_2nd/com/panel/pass/qi.png'
	local HONG_ICON = 'uires/ui_2nd/com/panel/pass/red.png'
	local MOU_ICON = 'uires/ui_2nd/com/panel/pass/meng.png'

	local CHALLENGE_ICON = 'uires/ui_2nd/com/panel/garrison/can_challenge.png'
	local EMPTY_ICON = 'uires/ui_2nd/com/panel/garrison/empty.png'
	local REWARD_ICON = 'uires/ui_2nd/com/panel/garrison/award.png'

	--主界面信息
	local getDate
	local mineCount = 5
	local mineArray = {}
	local garrisonBgImg 
	local playerForceNum  
	local playerGoldNum 
	local playerCashNum 
	local lightArray = {}
	local CDTimeTxArray = {}


	--读表
	local patrolBattleConf = GameData:getArrayData('patrolbattle.dat')
	local patrolEventConf = GameData:getArrayData('patrolevent.dat')
	local patrolIntervalConf = GameData:getArrayData('patrolinterval.dat')
	local patrolTypeConf = GameData:getArrayData('patroltype.dat')
	local monsterConf = GameData:getArrayData('monster.dat')
	local materialConf = GameData:getArrayData('material.dat')
	local roleConf = GameData:getArrayData('role.dat')

	

function GarrisonMine.isActive()
	Message.sendPost('patrol_get','activity','{}',function(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end
		getDate = jsonDic.data.patrol
	end)
	if not getDate then 
	 	return false
	end 
	local con = GarrisonMine:countTable(getDate)
	for i = 1,con do 
		if getDate[tostring(i)].state == 1 or getDate[tostring(i)].state == 3 then
			return true
		end
	end
	return false
end

--  设置光圈
function GarrisonMine:createLights(i,frame)
	-- body
    local light = CUIEffect:create()
	light:Show("yellow_light",0)
	light:setScale(0.8)
	contentSize = frame:getContentSize()
	
	light:setAnchorPoint(ccp(0.5,0.5))
	light:setTag(100)
	light:setZOrder(100)
	light:setVisible(true)
	frame:getContainerNode():addChild(light)
	lightArray[i] = light
	lightArray[i]:setVisible(false)
end


--计算表的长度
function GarrisonMine:countTable(table)
	-- body
	local count = 0
	if table then
		for i,v in pairs(table) do 
			count = count + 1
		end
	end
	return count
end

local function jump(pTarget, jumpInterval ,jumpHigh )
	-- body
	local jumpInterval = jumpInterval or 1.0
	local jumpHigh = jumpHigh or 20

	if not pTarget then
		return
	end
	pTarget:stopAllActions()
	local bottomPosition = ccp(16,78)
	local topPosition = ccp(16, 78 + 20)

	local pMove2Top = CCMoveTo:create(jumpInterval / 2, topPosition)
	local pMove2Bottom = CCMoveTo:create(jumpInterval / 2, bottomPosition)
	local array = CCArray:create()
	array:addObject(pMove2Top)
	array:addObject(pMove2Bottom)
	local pSeq = CCSequence:create(array)
	local pRepeat = CCRepeatForever:create(pSeq)
	pTarget:runAction(pRepeat)

end 
--关闭主界面
function GarrisonMine:closeMainPanel(garrison)
	CUIManager:GetInstance():HideObject(garrison, ELF_HIDE.ZOOM_OUT_FADE_OUT)
end


-- 主界面刷新
function GarrisonMine:updatePanel()
	-- body
	Message.sendPost('patrol_get','activity','{}',function(jsonData)
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if jsonDic['code'] ~= 0 then
			cclog('request error : ' .. jsonDic['desc'])
			return
		end
		getDate = jsonDic.data.patrol

		playerForceNum:setStringValue(tostring(PlayerCoreData.getPlayerFightForce()))
		playerGoldNum:setText(toWordsNumber(PlayerCoreData.getGoldValue()))
		playerCashNum:setText(toWordsNumber(PlayerCoreData.getCashValue()))
		
		local mineMarkRes

		local con = 0
			con = GarrisonMine:countTable(getDate) 


		if con == 0 then
			mineMarkRes = CHALLENGE_ICON
			mineArray[1]:setNormalButtonGray(false)	
			mineArray[1]:setTouchEnable(true)
			mineArray[1].shadow:setVisible(true)
			mineArray[1].shadow.mark:setTexture(mineMarkRes)
			mineArray[1].lock:setVisible(false)
		else
			for i = 1,con do 
				if getDate[tostring(i)].state  == 0 then --未开启
					mineMarkRes = CHALLENGE_ICON
					mineArray[i].shadow:stopAllActions()
				elseif getDate[tostring(i)].state == 1 then -- 空
					mineMarkRes = EMPTY_ICON
					jump(mineArray[i].shadow, jumpInterval ,jumpHigh )
				elseif getDate[tostring(i)].state == 2 then -- 正在驻守
					mineArray[i].shadow.headIco:setVisible(true)

					mineArray[i].shadow:stopAllActions()
					local roleId = getDate[tostring(i)].rid
					local roleCardObj = tolua.cast(CLDObjectManager:GetInst():GetOrCreateObject(roleId,E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD),'CLDRoleCardObject')

					mineArray[i].shadow.headIco:setTexture(roleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON))
					mineMarkRes = roleCardObj:GetIconFrame()

					

					if mineMarkRes == 'uires/ui_2nd/com/panel/common/frame_sred.png' then
						lightArray[i]:setVisible(true)		
					end
					local duration
					table.foreach(patrolTypeConf,function(_ , v)
						-- body
						if v['Id'] == tostring(getDate[tostring(i)].type) then 
							duration = tonumber(v['Duration'])
						end
					end)
					CDTimeTxArray[i]:setVisible(true)
					local timeDiff = (tonumber(duration) * 3600) - (UserData:getServerTime() - tonumber(getDate[tostring(i)].time))
					CDTimeTxArray[i]:setTime(timeDiff)

				elseif getDate[tostring(i)].state == 3 then -- 等待领奖
					mineMarkRes = REWARD_ICON
					jump(mineArray[i].shadow, jumpInterval ,jumpHigh )
					mineArray[i].shadow.headIco:setVisible(false)
					lightArray[i]:setVisible(false)
				end

				mineArray[i].lock:setVisible(false)
				mineArray[i]:setNormalButtonGray(false)	
				mineArray[i]:setTouchEnable(true)
				mineArray[i].shadow:setVisible(true)
				mineArray[i].shadow.mark:setTexture(mineMarkRes)

				if con < 5 then
					mineArray[con + 1]:setNormalButtonGray(false)	
					mineArray[con + 1]:setTouchEnable(true)
					mineArray[con + 1].shadow:setVisible(true)
					mineArray[con + 1].shadow.mark:setTexture(CHALLENGE_ICON)
					mineArray[con + 1].lock:setVisible(false)
				end

			end
		end
		
	end)

end


--  设置倒计时
function GarrisonMine:createCDTimeTx(i,frame)
	-- body
    local CDTimeTx = UICDLabel:create()	
	CDTimeTx:setAnchorPoint(ccp(0.5,0.5))
	CDTimeTx:setPosition(ccp(0,-15))
	CDTimeTx:setFontSize(22)
	-- CDTimeTx:setZOrder(100)
	CDTimeTx:setVisible(true)
	frame:addChild(CDTimeTx)
	CDTimeTxArray[i] = CDTimeTx
	CDTimeTxArray[i]:setVisible(false)
	CDTimeTx:registerTimeoutHandler(function()
		-- body
		GarrisonMine:updatePanel()
	end)
end

--点击金矿
local function onClickMine(id)
	mineId = id
	if mineId <= GarrisonMine:countTable(getDate) then
		isWin = true
	else
		isWin = false
	end
	genGarrisonMinePanel(isWin,getDate,mineId)
end

--主界面初始化
local function genViewUpdater(panel,garrison,getDate)
	-- body
	return function()
		-- body
		local root = panel:GetRawPanel()
		garrisonBgImg = tolua.cast(root:getChildByName('garrison_bg_img'),'UIImageView')
		local playerPl = tolua.cast(root:getChildByName('player_pl'),'UIPanel')
		local closeBtn = tolua.cast(root:getChildByName('close_btn'),'UIButton')
		closeBtn:registerScriptTapHandler(function()
			-- body
			GarrisonMine:closeMainPanel(garrison)
		end)
		local buZhenBtn = tolua.cast(root:getChildByName('buzhen_btn'),'UIButton')
		buZhenBtn:registerScriptTapHandler(function()
			OpenEmbattleUi()
		end)
		local winSize = CCDirector:sharedDirector():getWinSize()
		garrisonBgImg:setPosition(ccp(winSize.width/2,winSize.height/2))
		local playerPlSize = playerPl:getContentSize()
		playerPl:setPosition(ccp(0, winSize.height - playerPlSize.height))
		local closeBtnSize = closeBtn:getContentSize()
		closeBtn:setPosition(ccp(winSize.width - closeBtnSize.width /2 - 20, closeBtnSize.height /2 + 10))
		
		GarrisonMine:updatePanel()

		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		playerForceNum = tolua.cast(playerPl:getChildByName('force_num_la'),'UILabelAtlas') 
		playerGoldNum = tolua.cast(playerPl:getChildByName('gold_num_tx'),'UILabel')
		playerCashNum = tolua.cast(playerPl:getChildByName('cash_num_tx'),'UILabel')
		for i = 1,5 do
			mineArray[i] = tolua.cast(garrisonBgImg:getChildByName('mine_' .. i .. '_btn'),'UIButton')
			mineArray[i]:setTextures('uires/ui_2nd/com/panel/garrison/mine.png','','')
			GameController.addButtonSound(mineArray[i],BUTTON_SOUND_TYPE.CLICK_EFFECT)
			mineArray[i].shadow = tolua.cast(mineArray[i]:getChildByName('shadow_img'),'UIImageView')
			mineArray[i].shadow.mark = tolua.cast(mineArray[i].shadow:getChildByName('mark_img'),'UIImageView')
			mineArray[i].shadow.headIco = tolua.cast(mineArray[i].shadow:getChildByName('head_img'),'UIImageView')
			GarrisonMine:createCDTimeTx(i,mineArray[i])
			mineArray[i].shadow.headIco:setVisible(false)
			mineArray[i].shadow:setVisible(false)
			mineArray[i].shadow.mark:setVisible(true)
			mineArray[i].shadow.mark:setTexture('uires/ui_2nd/com/panel/garrison/lock.png')
			mineArray[i]:setNormalButtonGray(true)	
			mineArray[i]:setTouchEnable(false)
			mineArray[i].lock = tolua.cast(mineArray[i]:getChildByName('lock_img'),'UIImageView')
			mineArray[i].lock:setVisible(true)

			GarrisonMine:createLights(i,mineArray[i].shadow.mark)

			mineArray[i]:registerScriptTapHandler(function()

				onClickMine(i)
			end)
		end


	end
end

local function genGarrisonPanel(getDate)
	-- body
	local garrison = SceneObjEx:createObj('panel/garrison_main_panel.json','garrison-in-lua')
	local panel = garrison:getPanelObj()
	local viewUpdater = genViewUpdater(panel,garrison,getDate)
	panel:registerInitHandler(function()
		-- body
		viewUpdater()
	end)
	UiMan.show(garrison)
end

local function doGetGarrisonResponse(jsonData)
	-- body
	cclog(jsonData)
	local response = json.decode(jsonData)
	local code = response.code
	if tonumber(code) == 0 then
		getDate = response.data.patrol

		genGarrisonPanel(getDate)
	end
end

--进入驻守金矿
function GarrisonMine.enter()
	-- body
	Message.sendPost('patrol_get','activity','{}',doGetGarrisonResponse)
end