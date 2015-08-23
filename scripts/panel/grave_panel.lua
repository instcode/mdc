Grave = {}

function Grave.isActive()
    return false -- 纯人民币活动不做提示
end

function Grave.enter()
	-- 定义一些常量
	local GEM_MAX    = 5
	local GEM_LAND_COUNT = 4
	local BOSS_COUNT = 5
	local INCREMENT	 = 10
	local OFFSETX = 18
	local mainPanelWidth = 600
	local BOSS_CARD_Y_POS = 20
	local BOSS_CARD_PATH = 'panel/tomb_card_panel.json'

	local RES_DAO 	= 'uires/ui_2nd/com/panel/common/dao.png'
	local RES_QIANG = 'uires/ui_2nd/com/panel/common/qiang.png'
	local RES_QI 	= 'uires/ui_2nd/com/panel/common/qibing.png'
	local RES_MOU 	= 'uires/ui_2nd/com/panel/common/mou.png'
	local RES_HONG 	= 'uires/ui_2nd/com/panel/common/hong.png'

	local sceneObj
	local panel
	local panelImgMain 
	local imgMain
	local helpObj
	local helpPanel
	local dropBoxObj
	local dropBoxPanel
	local bossCards = {}
	local gemLands = {}

	-- 消耗元宝

	local challengeBtn
	local challengeGoldTx
	local soldierTypeIcon
	local nameTx 
	local fightForceTx
	local unlockTime
	local fightMaxCount =GameData:getGlobalValue('GraveFightCountLimit')
	local fightCount

	local forwardAction
	
	-- data
	local gravePropConf = GameData:getArrayData('graveawardweight.dat')
	local graveConf = GameData:getArrayData('grave.dat')
	local graveData
	local bossId = 47
	local needGold
	local rewardData
	local isNeedUpdate = 0
	-- current select widget
	local cardWidgetZOrders = {}

	local moveBg = {0,0,0,0,0}
	local lastX  = {0.0,0.0,0.0,0.0,0.0}
	local isView = {true,true,true,true,true}

	-- 当前选中的boss
	local bossIndex = 1
	
	local function getFormationDataById( id )
		local data
		local formationConf = GameData:getArrayData('graveformation.dat')
		table.foreach(formationConf , function (key , value)
			if tonumber(value['Id']) == id then
				data = value
			end
		end)
		return data
	end

	local function getMonsterDataById( id )
		local monsterConf = GameData:getMapData('monster.dat')
		local data
		table.foreach(monsterConf , function (key , value)
			if tonumber(value['Id']) == id then
				data = value
			end
		end)
		return data
	end

	local function getSoldierResUrl( soldierType )
		if soldierType == 1 then
			return RES_DAO
		elseif soldierType == 2 then
			return	RES_QIANG
		elseif soldierType == 3 then
			return	RES_QI
		elseif soldierType == 4 then
			return	RES_MOU
		elseif soldierType == 5 then
			return	RES_HONG
		else
			return	''
		end
	end

	local  function makeTeamData(id)
		local teamData = getFormationDataById( id )
		local tab = {}
		for i = 0 , 8 do
			if teamData['Pos' .. i] ~= '' then
				local monsterData = getMonsterDataById(tonumber(teamData['Pos' .. i]))
				table.insert(tab , tonumber(monsterData.Soldier))
			else
				table.insert(tab , 0)
			end
		end

		return tab
	end

	local function helpPanelInit()
		local root = helpPanel:GetRawPanel()
		local closeBtn = tolua.cast(root:getChildByName('close_btn'),'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(helpObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local knowBtn = tolua.cast(root:getChildByName('know_btn'),'UITextButton')
		knowBtn:registerScriptTapHandler(UiMan.genCloseHandler(helpObj))
		GameController.addButtonSound(knowBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local infoTx1 = tolua.cast(root:getChildByName('info_1_tx'), 'UILabel')
		infoTx1:setText(getLocalStringValue('HELP_TOMB_1'))
		infoTx1:setPreferredSize(555,1)
		local infoTx2 = tolua.cast(root:getChildByName('info_2_tx'), 'UILabel')
		infoTx2:setText(getLocalStringValue('HELP_TOMB_2'))
		infoTx2:setPreferredSize(555,1)
		local infoTx3 = tolua.cast(root:getChildByName('info_3_tx'), 'UILabel')
		infoTx3:setText(getLocalStringValue('HELP_TOMB_3'))
		infoTx3:setPreferredSize(555,1)
		local infoTx4 = tolua.cast(root:getChildByName('info_4_tx'), 'UILabel')
		infoTx4:setText(getLocalStringValue('HELP_TOMB_4'))
		infoTx4:setPreferredSize(555,1)
	end

	local function onOpenHelpPanel()
		helpObj = SceneObjEx:createObj('panel/tomb_help_panel.json','grave-help-lua')
		helpPanel = helpObj:getPanelObj()
		helpPanel:setAdaptInfo('tomb_help_bg_img','tomb_help_img')
		helpPanel:registerInitHandler(helpPanelInit)

		UiMan.show(helpObj)
	end

	local function onClickChallengeBtn()
		-- 显示元宝不足
		if tonumber(needGold) + fightCount * 5 - tonumber(PlayerCoreData.getCashValue()) > 0  then
			GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
			return
		end

		-- 检测次数
		if tonumber(fightMaxCount) - tonumber(fightCount) == 0 then
			GameController.showMessageBox(getLocalStringValue('E_STR_MAX_CHALENGE_TIME'), MESSAGE_BOX_TYPE.OK)
			return
		end 

		-- 参数第几个boss
		local pJson = {id = bossIndex}

		Message.sendPost('fight_grave','activity',json.encode(pJson),function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']

			if data['awards'] then
				rewardData = data['awards']
				UserData.parseAwardJson(json.encode(data['awards']))
			end

			isNeedUpdate = 0
			if data['battle'] then
				isNeedUpdate = tonumber(data['battle']['success'])
				GameController.clearAwardView()

				-- 刷新奖励数据
				if isNeedUpdate ==  1 then
					local tmpAwards = {}
					if rewardData and #rewardData > 0 then
					 	for k , v in pairs ( rewardData ) do
					 		local strType = tostring(v[1])
					 		if strType ~= 'user' then
					 			table.insert(tmpAwards,v)
					 		end
					 	end
						
						GameController.updateAwardView(json.encode(tmpAwards))
					end
				end 
				GameController.playBattle(json.encode(data['battle']) , 5)
			end
		end)
	end


	local  function updatePanel()
		-- 根据当前boss挑战消耗元宝
		local str = graveConf[bossIndex]['Award0']
		needGold = math.abs(UserData:getAward(str)['count']) + fightCount * 5
		challengeGoldTx:setText(getLocalString('E_STR_TOMB_FIGHT').. ' ' .. needGold)
		--challengeGoldTx:setTextFromInt(needGold)

		-- 刷新挑战次数
		local fightCntTx = tolua.cast(panelImgMain:getChildByName('fight_count_value_tx'),'UILabel')
		local lasttime = fightMaxCount - fightCount
		fightCntTx:setText(lasttime..'/'..fightMaxCount)
		fightCntTx:setColor(COLOR_TYPE.GREEN)

		-- 当前boss挑战掉落宝石概率
		for i=1,GEM_LAND_COUNT do
		 	local gembg    = tolua.cast(panelImgMain:getChildByName('gem_bg_'..tostring(i)..'_img'),'UIImageView')
		 	local gemIco   = tolua.cast(gembg:getChildByName('gem_ico'),'UIImageView')
		 	local gemlv    = tolua.cast(gembg:getChildByName('lv_tx'),'UILabel')

		 	local gemIndex = GEM_MAX - GEM_LAND_COUNT + i
		 	-- 等级
		 	gemlv:setText('Lv'..gemIndex)
		 	local awardStr = graveConf[bossIndex]['Award'..gemIndex]
		 	local awardTmp = UserData:getAward(awardStr)
		
		 	if awardTmp then	
		 		gemIco:setTexture(awardTmp.icon)
		 		gemIco:setTouchEnable(true)
		 		gemIco:registerScriptTapHandler(function ()
		 			UISvr:showTipsForAward(awardStr)
		 		end)
		 	end 
		end
	end

	local function onShow()
		if isNeedUpdate == 1 then 			
			Message.sendPost('get_grave','activity','{}',function (jsondata)
			cclog(jsondata)

			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			if code == 0 then
			  	graveData = response.data
			  	unlockTime = tonumber(response.data.unluck_count)
			  	fightCount = tonumber(response.data.fight_count)
				
				updatePanel()
			end	
					
			end)
		end 
	end

	local function onClickEmbattleBtn()
		OpenEmbattleUi()
	end


	-- 卡牌中心点
	local function getCardCenterPostion(card)
		local pos = card:getPosition()
		local rect = card:getRect()
		local size = rect.size 
		
		return ccp(pos.x + size.width/2, pos.y + size.height/2)
	end


	local function setCardBossPostion(card,pos)
		local rect = card:getRect()
		local size = rect.size 
		card:setPosition(ccp(pos.x - size.width/2, pos.y - size.height/2))
	end

	local function  setCardBossProjection(card,dx)
		local x = -dx /(mainPanelWidth / 2.0) * 2.0
		card:getContainerNode():getCamera():setEyeXYZ(x,0.0,1.0)
	end

	local function setCardBossOpacity(card,dx)
		local preIndex = bossIndex - 1
		local nextIndex = bossIndex + 1

		if preIndex < 1 then
			preIndex = BOSS_COUNT
		end 
		
		if nextIndex > BOSS_COUNT then 
			nextIndex = 1
		end

		if bossCards[bossIndex] then 
			bossCards[bossIndex]:setOpacity(255)
		end 

		if bossCards[preIndex] then 
			bossCards[preIndex]:setOpacity(100)
		end
		
		if bossCards[nextIndex] then 
			bossCards[nextIndex]:setOpacity(100)
		end 
	end

	local function setCardBossWidgetZOrder(card,dx)
		card:setWidgetZOrder(mainPanelWidth - math.abs(dx))
	end

	local function updateCurrentBossIndex()
		local index = 1
		local max = tonumber(cardWidgetZOrders['1'])
		
		for i=2,BOSS_COUNT do
			local value = tonumber(cardWidgetZOrders[tostring(i)])
			if value > max then 
				max = value
				index = i
			end
		end

		if tonumber(bossIndex) ~= tonumber(index) then 
			bossIndex = index
			updatePanel()
		end 

	end


	local function moveBossCards(dx)
    	-- 主界面
		local widgetWidth = mainPanelWidth
		-- 中间位置
		local halfWidth = widgetWidth / 2

		for i=1,BOSS_COUNT do
			if bossCards[i] then
				bossCards[i]:setScale(0.8)
				bossCards[i]:setOpacity(100)
				-- 当前卡牌中心点位置
		 		local cardPos = getCardCenterPostion(bossCards[i])
		 		cardPos.x = cardPos.x + dx
		 		local disDx = halfWidth - cardPos.x
				-- 超过边界就跳到另一边

				-- 左边
				local useAnimate = true 
		 		if disDx < -(mainPanelWidth + bossCards[i]:getContentSize().width * 2) /2.0 then
		 		 	cardPos.x = cardPos.x - mainPanelWidth - bossCards[i]:getContentSize().width * 2 + OFFSETX
		 		 	useAnimate = false
		 		 -- 右边移动 
		 		elseif disDx > (mainPanelWidth + bossCards[i]:getContentSize().width * 2)/2.0  then
		 		  	cardPos.x = cardPos.x + mainPanelWidth + bossCards[i]:getContentSize().width * 2 - OFFSETX
		 			useAnimate = false
		 		end

	 		 	setCardBossPostion(bossCards[i],cardPos)

		 		-- update z order table value
		 		setCardBossWidgetZOrder(bossCards[i] , halfWidth - cardPos.x)		 		
		 		cardWidgetZOrders[tostring(i)] = bossCards[i]:getWidgetZOrder()
		 	end
		end

		updateCurrentBossIndex()
	end

	local function setZooms()
		local preIndex = bossIndex - 1
		local nextIndex = bossIndex + 1

		if preIndex < 1 then
			preIndex = 5
		end 
		
		if nextIndex > BOSS_COUNT then 
			nextIndex = 1
		end

		if bossCards[bossIndex] then 
			bossCards[bossIndex]:setScale(1.0)
		end 

		if bossCards[preIndex] then 
			bossCards[preIndex]:setScale(0.8)
		end
		
		if bossCards[nextIndex] then 
			bossCards[nextIndex]:setScale(0.8)
		end 
		
		for i=1,BOSS_COUNT do
			if bossCards[i] then 
				local cardPos = getCardCenterPostion(bossCards[i])
				setCardBossPostion(bossCards[i],ccp(cardPos.x - 60,cardPos.y))
			end 
		end
	end

	local function limitCards(dx)
		local widgetWidth = mainPanelWidth
		local halfWidth = widgetWidth / 2

		for i=1,BOSS_COUNT do
			
			if bossCards[i] then 
				local cardPos = getCardCenterPostion(bossCards[i])
				cardPos.x = cardPos.x + dx
				
				local disDx = halfWidth - cardPos.x		
				-- 左边
				local useAnimate = true 
			 	if disDx < -(mainPanelWidth + bossCards[i]:getContentSize().width * 2) /2.0 then
			 	 	cardPos.x = cardPos.x - mainPanelWidth - bossCards[i]:getContentSize().width * 2 + OFFSETX
			 	 	useAnimate = false
			 	 -- 右边移动 
			 	elseif disDx > (mainPanelWidth + bossCards[i]:getContentSize().width * 2)/2.0  then
			 	  	cardPos.x = cardPos.x + mainPanelWidth + bossCards[i]:getContentSize().width * 2 - OFFSETX
			 		useAnimate = false
			 	end

 		 		setCardBossPostion(bossCards[i],cardPos)
			end 		
		end
	end

	

	local function resetCards()
		-- 主界面
		local widgetWidth = mainPanelWidth
		-- 中间位置
		local halfWidth = widgetWidth / 2
		local selectCardPos = getCardCenterPostion(bossCards[bossIndex])
		
		if selectCardPos.x > halfWidth then
			limitCards(halfWidth - selectCardPos.x)
		else
			limitCards(halfWidth - selectCardPos.x)
		end

		-- 刷放大缩小
		setZooms()
		-- 刷透明度
		setCardBossOpacity(bossCards[i] , 0)
	end

	local  function init()
		local  root = panel:GetRawPanel()
		-- 关闭
		local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		
		-- 帮助
		local helpBtn = tolua.cast(root:getChildByName('help_btn'),'UIButton')
		helpBtn:registerScriptTapHandler(onOpenHelpPanel)
		
		-- 布阵
		local emBattleBtn = tolua.cast(root:getChildByName('buzhen_btn'),'UIButton')
		emBattleBtn:registerScriptTapHandler(onClickEmbattleBtn)
			
		-- 挑战按钮
		challengeBtn = tolua.cast(root:getChildByName('battle_btn'),'UIButton')
		challengeBtn:registerScriptTapHandler(onClickChallengeBtn)
		-- 挑战花费
		challengeGoldTx = tolua.cast(root:getChildByName('cost_tx'),'UILabel')
		
		-- 宝石栏
		for i=1,GEM_LAND_COUNT do
			local gemBg = tolua.cast(root:getChildByName('gem_bg_'..tostring(i)..'_img'),'UIImageView')
			table.insert(gemLands,gemBg)
		end

		-- 背景
		panelImgMain = tolua.cast(root:getChildByName('tomb_img'),'UIImageView')
		mainPanelWidth = panelImgMain:getContentSize().width

		local sv = tolua.cast(root:getChildByName('card_sv'),'UIScrollView')
    	sv:setClippingEnable(true)
    	sv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)



		-- 创建Boss卡栏
		for i=1,BOSS_COUNT do
			local widget = createWidgetByName(BOSS_CARD_PATH)
			if widget then
				table.insert(cardWidgetZOrders,1)
				widget:setTouchEnable(true)
				widget:setCascadeOpacityEnabled(true)
				widget:setAnchorPoint(ccp(0.5,0.5))
				widget:registerMovHandler(function ()

					local touchStPos  = widget:getTouchStartPos()
					local touchMovPos = widget:getTouchMovePos()
					local dtx = touchStPos.x - touchMovPos.x
					local dty = touchStPos.y - touchMovPos.y
					
					if isView[i] and math.sqrt(dtx * dtx + dty * dty) < 10 then 
						return
					end 
					
					-- 如果刚开始移动
					if moveBg[i] == 0 then 
						lastX[i] = widget:getTouchStartPos().x
						isView[i] = false
						moveBg[i] = 1
					end 
					
					local movePos = widget:getTouchMovePos()
					local distance = movePos.x - lastX[i]
					lastX[i] = movePos.x

					moveBossCards(distance)
				end)

				widget:registerScriptCancelHandler(function ()
					resetCards()
					moveBg[i] = 0
				end)

				widget:registerScriptTapHandler(function ()
					-- for i=1,BOSS_COUNT do
					-- 	if bossCards[i] then 
					-- 		bossCards[i]:stopAllActions()
					-- 	end 
					-- end
					moveBossCards(0.0)
					resetCards()
				end)


				local heroBottomBg = tolua.cast(widget:getChildByName('role_card_img'),'UIImageView')
				-- 战力数字
				fightForceTx = tolua.cast(heroBottomBg:getChildByName('zhan_num_tx') , 'UILabel')
				-- 角色名字-关羽
				nameTx = tolua.cast(heroBottomBg:getChildByName('name_tx') , 'UITextArea')
				-- 角色类型-刀
				soldierTypeIcon = tolua.cast(heroBottomBg:getChildByName('kind_ico') , 'UIImageView')
				-- 角色大图-大图
				bossIcon = tolua.cast(heroBottomBg:getChildByName('role_img') , 'UIImageView')
				local bossData = getMonsterDataById(tonumber(graveConf[i].BossId))
				bossIcon:setTexture('uires/ui_2nd/image/' .. graveConf[i].URL)

				fightForceTx:setText(tostring(graveData['fight_force']))

				nameTx:setText(GetTextForCfg(bossData.Name))
				local url = getSoldierResUrl(tonumber(bossData.Soldier))
				soldierTypeIcon:setTexture(url)

				sv:addChild(widget)				
				widget:setPosition(ccp((i-1)*(widget:getContentSize().width),BOSS_CARD_Y_POS))
				table.insert(bossCards,widget)
			end 
		end
		-- 动画效果
		moveBossCards(0.0)
		resetCards()

		updatePanel()
	end

	local  function createPanel()
		sceneObj = SceneObjEx:createObj('panel/tomb_bg_panel.json','grave-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('tomb_bg_img','tomb_img')

		panel:registerInitHandler(init)
		panel:registerOnShowHandler(onShow)

		UiMan.show(sceneObj)
	end

	local function getGraveResponse()
		Message.sendPost('get_grave','activity','{}',function (jsondata)
		
		cclog(jsondata)
		local response = json.decode(jsondata)
		local code = tonumber(response.code)
		if code == 0 then
		   	graveData = response.data

		  	unlockTime = tonumber(response.data.unluck_count)
		  	fightCount = tonumber(response.data.fight_count)

		    -- 创建主界面
			createPanel()
		end
		
		end)
	end

	--勇闯汉墓入口
	getGraveResponse()
end