OneRide = {}

function OneRide.isActive()
	return false
end

function OneRide.enter()
	local BOX_ONE_INDEX = 4
	local BOX_TWO_INDEX = 8
	local BOX_THREE_INDEX = 10

	local RES_DAO = 'uires/ui_2nd/com/panel/common/dao.png'
	local RES_QIANG = 'uires/ui_2nd/com/panel/common/qiang.png'
	local RES_QI = 'uires/ui_2nd/com/panel/common/qibing.png'
	local RES_MOU = 'uires/ui_2nd/com/panel/common/mou.png'
	local RES_HONG = 'uires/ui_2nd/com/panel/common/hong.png'

	local BOX_ONE_ICON = 'uires/ui_2nd/com/panel/pass/box1.png'
	local BOX_ONE_OPEN_ICON = 'uires/ui_2nd/com/panel/pass/box4.png'
	local BOX_TWO_ICON = 'uires/ui_2nd/com/panel/pass/box2.png'
	local BOX_TWO_OPEN_ICON = 'uires/ui_2nd/com/panel/pass/box5.png'
	local BOX_THREE_ICON = 'uires/ui_2nd/com/panel/pass/box3.png'
	local BOX_THREE_OPEN_ICON = 'uires/ui_2nd/com/panel/pass/box6.png'

	local DAO_ICON = 'uires/ui_2nd/com/panel/pass/dao.png'
	local QIANG_ICON = 'uires/ui_2nd/com/panel/pass/qiang.png'
	local QI_ICON = 'uires/ui_2nd/com/panel/pass/qi.png'
	local HONG_ICON = 'uires/ui_2nd/com/panel/pass/red.png'
	local MOU_ICON = 'uires/ui_2nd/com/panel/pass/meng.png'

	-- ui
	local sceneObj
	local panel
	local boxPanel
	local emBattlePanel
	local playerGoldTx
	local playerCashTx
	local challengeGoldTx
	local fightForceTx
	local nameTx
	local progressBarImg
	local progressBar
	local fightIcon
	local lookPosBtn
	local challengeBtn
	local emBattleBtn
	local resetBtn
	local boxSmallIcon
	local boxIcon
	local posIconArr
	local bossIcon
	local soldierTypeIcon
	local goldIcon
	local cashIcon
	local resetCashTx
	-- data
	local oneRideConf = GameData:getArrayData('oneride.dat')
	local oneRideData
	local isShowBox
	local bossId
	local needGold
	local rewardData
	local isNeedUpdate = false
	local freeTimes = 0
	local cashTimes = 0

	local function getMaxResetTimesByKey( key )
		local tab = {}

		local conf = GameData:getArrayData('vip.dat')
		for _, v in pairs ( conf ) do
			if tonumber(v.Level) == PlayerCoreData.getPlayerVIP() then
				tab = v
			end
		end 

		return tonumber(tab[key]) or 0
	end

	-- return : cost , lefttimes
	local function getResetData()
		local maxFreeTimes = getMaxResetTimesByKey( 'OneRideFree' )
		local maxCashTimes = getMaxResetTimesByKey( 'OneRideCash' )
		
		local leftFreeTimes = maxFreeTimes - freeTimes
		local leftCashTimes = maxCashTimes - cashTimes

		if leftFreeTimes > 0 then
			return 0 , leftFreeTimes
		end

		local resetTab = {}

		local conf = GameData:getArrayData('buy.dat')
		for _, v in pairs ( conf ) do
			if v.CashOneRide and v.CashOneRide ~= '' then
				table.insert(resetTab , tonumber(v.CashOneRide) )
			end
		end 

		local length = #resetTab
		local nextTimes = cashTimes + 1
		if nextTimes > length then
			nextTimes = length
		end

		return tonumber(resetTab[nextTimes]) , leftCashTimes
	end

	local function getFormationDataById( id )
		local data
		local formationConf = GameData:getArrayData('onerideformation.dat')
		table.foreach(formationConf , function (key , value)
			if tonumber(value['Id']) == id then
				data = value
			end
		end)
		return data
	end

	local function getBoxReward( id , index)
		local str = ''
		table.foreach(oneRideConf , function (key , value)
			if tonumber(value['Id']) == id and value['Award' .. index] then
				str = value['Award' .. index]
			end
		end)
		return str
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

	local function getBoxStatusUrl( index )
		local isOpen = oneRideData.progress >= index
		if index == BOX_ONE_INDEX then
			return isOpen and BOX_ONE_OPEN_ICON or BOX_ONE_ICON
		elseif index == BOX_TWO_INDEX then
			return isOpen and BOX_TWO_OPEN_ICON or BOX_TWO_ICON
		elseif index == BOX_THREE_INDEX then
			return isOpen and BOX_THREE_OPEN_ICON or BOX_THREE_ICON
		else 
			return ''
		end
	end

	local function getSoldierIconUrl( soldierType )
		if soldierType == 1 then
			return	DAO_ICON , RES_DAO
		elseif soldierType == 2 then
			return	QIANG_ICON , RES_QIANG
		elseif soldierType == 3 then
			return	QI_ICON , RES_QI
		elseif soldierType == 4 then
			return	MOU_ICON , RES_MOU
		elseif soldierType == 5 then
			return	HONG_ICON , RES_HONG
		else
			return	''
		end
	end

	local function makeTeamData( id )
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

	local function onClickEmBattleBtn()
		OpenEmbattleUi()
		isNeedUpdate = true
	end

	-- 查看阵型
	local function onClickLookPosBtn()
		isShowBox = not isShowBox
		boxPanel:setVisible(isShowBox)
		emBattlePanel:setVisible(not isShowBox)
		lookPosBtn:setText(getLocalString(isShowBox and 'E_STR_LOOK_POSITION' or 'E_STR_LOOK_BOX'))
		emBattleBtn:setVisible(not isShowBox)
		resetBtn:setVisible(isShowBox)
		challengeGoldTx:setVisible(isShowBox)
		goldIcon:setVisible(isShowBox)
		cashIcon:setVisible(isShowBox)
		resetCashTx:setVisible(isShowBox)
	end

	local function onClickChallengeBtn()
		if oneRideData.progress >= #oneRideConf then
			GameController.showPrompts(getLocalStringValue('E_ONERIDE_FINISH_NOTICE_DESC'))
			return
		end

		if PlayerCoreData.getGoldValue() < needGold then
			GameController.showPrompts(getLocalStringValue('E_STR_NOT_ENOUGH_GOLD'), COLOR_TYPE.RED)
			return
		end

		Message.sendPost('fight_one_ride','activity','{}',function (jsonData)
			--cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']

			if data['awards'] then
				local nextPro = oneRideData.progress + 1
				if nextPro == BOX_ONE_INDEX or nextPro == BOX_TWO_INDEX or nextPro == BOX_THREE_INDEX then
					rewardData = data['awards']		-- 缓存奖励，等战斗返回后显示
				end
				UserData.parseAwardJson(json.encode(data['awards']))
			end

			if data['battle'] then
				isNeedUpdate = tonumber(data['battle']['success']) == 1
				GameController.clearAwardView()
				GameController.playBattle(json.encode(data['battle']) , 5)
			end
		end)
	end

	local function updateEnemyPos()
		local realNum = oneRideData.num
		local showIndex = 0
		for i = 1 , 9 do
			if posIconArr[i] and oneRideData.team[i] then
				local stype = tonumber(oneRideData.team[i])

				if stype ~= 0 then
					showIndex = showIndex + 1
					posIconArr[i]:setVisible(showIndex <= realNum)
					posIconArr[i]:setTexture((getSoldierIconUrl(stype)))
				else
					posIconArr[i]:setVisible(false)
				end
			end
		end
	end

	local function updateBox()
		boxIcon[1]:setTexture(getBoxStatusUrl(BOX_ONE_INDEX))
		boxSmallIcon[1]:setTexture(getBoxStatusUrl(BOX_ONE_INDEX))
		boxIcon[2]:setTexture(getBoxStatusUrl(BOX_TWO_INDEX))
		boxSmallIcon[2]:setTexture(getBoxStatusUrl(BOX_TWO_INDEX))
		boxIcon[3]:setTexture(getBoxStatusUrl(BOX_THREE_INDEX))
		boxSmallIcon[3]:setTexture(getBoxStatusUrl(BOX_THREE_INDEX))

		local tab = {BOX_ONE_INDEX , BOX_TWO_INDEX , BOX_THREE_INDEX}
		for k,v in pairs(tab) do
			local item = tolua.cast(boxPanel:getChildByName('box_' .. k .. '_ico') , 'UIImageView')
			for i = 1 , 3 do
				local frame = tolua.cast(item:getChildByName('frame_' .. i .. '_img') , 'UIImageView')
				local photo = tolua.cast(frame:getChildByName('photo_img') , 'UIImageView')
				local numTx = tolua.cast(frame:getChildByName('num_tx') , 'UILabel')
				local awardStr = getBoxReward(v, i)
				photo:setTouchEnable(true)
				photo:registerScriptTapHandler(function ()
					UISvr:showTipsForAward(awardStr)
				end)
				local award = UserData:getAward(awardStr)
				photo:setTexture(award.icon)
				numTx:setTextFromInt(tonumber(award.count))
			end
		end

	end

	local function updateBar()
		local percent = oneRideData.progress * 10
		progressBar:setPercent(percent)

		local expBar = tolua.cast(progressBarImg:getChildByName('exp_bg_ico') , 'UIImageView')
	    local targetPosX = 17 + math.floor(expBar:getContentSize().width / 100 * percent)
	    fightIcon:setPosition(ccp(targetPosX , fightIcon:getPosition().y))
	end

	local function updatePanel()
		playerGoldTx:setText(toWordsNumber(PlayerCoreData.getGoldValue()))
		playerCashTx:setText(toWordsNumber(PlayerCoreData.getCashValue()))
		fightForceTx:setTextFromInt(oneRideData['fightForce'])

		local nextPro = oneRideData.progress + 1
		if nextPro > #oneRideConf then
			nextPro = #oneRideConf
		end
		local str = oneRideConf[nextPro]['Award0']
		needGold = math.abs(UserData:getAward(str)['count'])
		challengeGoldTx:setTextFromInt(needGold)

		local costCash , lefttimes = getResetData()

		resetCashTx:setText( tostring(costCash) )

		local bossData = getMonsterDataById(bossId)
		bossIcon:setTexture('uires/ui_2nd/image/' .. oneRideConf[nextPro].URL)
		local _,url = getSoldierIconUrl(tonumber(bossData.Soldier))
		soldierTypeIcon:setTexture(url)

		local  roleData = RoleCard:findById(tonumber(oneRideConf[nextPro].BossId))
		if roleData then
			nameTx:setText(GetTextForCfg(roleData:getData().Name))
			nameTx:setColor(roleData.card:GetRoleNameColor())
		else
			nameTx:setText('')
		end

		if oneRideData.progress >= #oneRideConf then
			challengeBtn:disable()
			fightIcon:setVisible(false)
		else
			challengeBtn:active()
			fightIcon:setVisible(true)
		end

		if lefttimes > 0 then
			resetBtn:active()
		else
			resetBtn:disable()
		end

		updateBar()
		updateBox()
		updateEnemyPos()
	end

	local function onShow()
		if isNeedUpdate then
			Message.sendPost('get_one_ride','activity','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				print('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']
			local teamId = data['team_id']
			bossId = tonumber(getFormationDataById(teamId)['Boss'])
			oneRideData = {}
			oneRideData['progress'] = tonumber(data['progress'])
			oneRideData['team'] = makeTeamData(teamId)
			oneRideData['fightForce'] = tonumber(data['fight_force'])
			oneRideData['num'] = tonumber(data['num'])
			freeTimes = tonumber(data['free_times'])
			cashTimes = tonumber(data['cash_times'])

			-- printall(rewardData)
			if rewardData and #rewardData > 0 then
				local awardStr = ''
				for k , v in pairs ( rewardData ) do
					local strType = tostring(v[1])
					if strType == 'material' then
						awardStr = 'material.' .. tonumber(v[2]) .. ':' .. tonumber(v[3])
					elseif strType == 'gem' then
						awardStr = 'gem.' .. tonumber(v[2]) .. ':' .. tonumber(v[3])
					end
				end
				
				local award = UserData:getAward(awardStr)
				genOneAwardPanel(award)
				rewardData = {}
			end

			isNeedUpdate = false

			updatePanel()
			end)
		end
	end

	local function doResetRequest()
		Message.sendPost('reset_one_ride','activity','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']
			if data['cash'] then
				PlayerCoreData.addCashDelta( tonumber(data['cash']) )
			end

			isNeedUpdate = true

			onShow()
		end)
	end

	local function init()
		local root = panel:GetRawPanel()
		local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
	
		progressBarImg = tolua.cast(root:getChildByName('exp_bg_img') , 'UIImageView')

		boxSmallIcon = {}
		for i = 1 , 3 do
			local box = tolua.cast(progressBarImg:getChildByName('box_' .. i .. '_ico') , 'UIImageView')
			table.insert(boxSmallIcon , box)
		end

		progressBar = tolua.cast(root:getChildByName('exp_bar') , 'UILoadingBar')
		local expBar = tolua.cast(progressBarImg:getChildByName('exp_bg_ico') , 'UIImageView')
		expBar:setGray()

		fightIcon = tolua.cast(progressBarImg:getChildByName('dao_ico') , 'UIImageView')
		local cloneIcon = tolua.cast(fightIcon:getChildByName('clone_ico') , 'UIImageView')

		local array = CCArray:create()
		array:addObject(CCMoveBy:create(0.2 , ccp(0, 15)))
		array:addObject(CCMoveBy:create(0.2 , ccp(0, -15)))
		array:addObject(CCCallFunc:create(function ()
			local arr = CCArray:create()
			arr:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0) , CCScaleTo:create(0,1)))
			arr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.6) , CCScaleTo:create(0.6 , 2)))
			arr:addObject(CCDelayTime:create(0.5))
			cloneIcon:stopAllActions()
			cloneIcon:runAction(CCSequence:create(arr))
		end))
		array:addObject(CCDelayTime:create(1.1))
		local action = CCRepeatForever:create(CCSequence:create(array))
		fightIcon:runAction(action)

		local titleBg = tolua.cast(root:getChildByName('pass_title_img') , 'UIImageView')
		playerGoldTx = tolua.cast(titleBg:getChildByName('gold_num_tx') , 'UILabel')
		playerCashTx = tolua.cast(titleBg:getChildByName('cash_num_tx') , 'UILabel')

		local heroBottomBg = tolua.cast(root:getChildByName('hero_pl') , 'UIImageView')
		challengeGoldTx = tolua.cast(heroBottomBg:getChildByName('gold_num_tx') , 'UILabel')
		goldIcon = tolua.cast(heroBottomBg:getChildByName('gold_ico') , 'UIImageView')
		fightForceTx = tolua.cast(heroBottomBg:getChildByName('fight_force_tx') , 'UILabel')
		nameTx = tolua.cast(heroBottomBg:getChildByName('name_tx') , 'UITextArea')
		bossIcon = tolua.cast(heroBottomBg:getChildByName('role_ico') , 'UIImageView')
		soldierTypeIcon = tolua.cast(heroBottomBg:getChildByName('soldier_type_ico') , 'UIImageView')
		cashIcon = tolua.cast(heroBottomBg:getChildByName('cash_ico') , 'UIImageView')
		resetCashTx = tolua.cast(heroBottomBg:getChildByName('cash_num_tx') , 'UILabel')

		boxPanel = tolua.cast(heroBottomBg:getChildByName('box_panel') , 'UIPanel')
		local promptTx = tolua.cast(boxPanel:getChildByName('prompt_tx'),'UILabel')
		promptTx:setPreferredSize(380,1)
		boxIcon = {}
		for i = 1 , 3 do
			local box = tolua.cast(boxPanel:getChildByName('box_' .. i .. '_ico') , 'UIImageView')
			table.insert(boxIcon , box)
		end

		emBattlePanel = tolua.cast(heroBottomBg:getChildByName('buzheng_img') , 'UIImageView')

		posIconArr = {}
		for i = 1 , 9 do
			local icon = tolua.cast(emBattlePanel:getChildByName('dao_' .. i .. '_ico') , 'UIImageView')
			table.insert(posIconArr , icon)
		end

		challengeBtn = tolua.cast(heroBottomBg:getChildByName('challenge_btn') , 'UIButton')
		lookPosBtn = tolua.cast(heroBottomBg:getChildByName('look_btn') , 'UITextButton')
		emBattleBtn = tolua.cast(heroBottomBg:getChildByName('embattle_btn') , 'UITextButton')
		resetBtn = tolua.cast(heroBottomBg:getChildByName('reset_btn') , 'UITextButton')

		challengeBtn:registerScriptTapHandler(onClickChallengeBtn)
		lookPosBtn:registerScriptTapHandler(onClickLookPosBtn)
		emBattleBtn:registerScriptTapHandler(onClickEmBattleBtn)
		resetBtn:registerScriptTapHandler(function ()
			if oneRideData['progress'] == 0 then
				GameController.showPrompts(getLocalStringValue('E_STR_ZERO_FLOOR') , COLOR_TYPE.RED)
				return 
			end

			local cost , lefttimes = getResetData()

			if cost == 0 then
				GameController.showMessageBox(string.format(getLocalString('E_STR_RESET_ONERIDE_FREE_DESC'), lefttimes), MESSAGE_BOX_TYPE.OK_CANCEL, function ()
					doResetRequest()
				end)
				return
			end

			if lefttimes > 0 then
				GameController.showMessageBox(string.format(getLocalString('E_STR_ONERIDE_RESET_DESC'), cost , lefttimes), MESSAGE_BOX_TYPE.OK_CANCEL, function ()
					if PlayerCoreData.getCashValue() < cost then
						GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
						return
					end
					doResetRequest()
				end)
			else
				GameController.showPrompts(getLocalStringValue('E_STR_ONERIDE_RESET_OVER'))
			end
		end)

		GameController.addButtonSound(challengeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		GameController.addButtonSound(lookPosBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		isShowBox = true
		boxPanel:setVisible(isShowBox)
		emBattlePanel:setVisible(not isShowBox)
		emBattleBtn:setVisible(not isShowBox)
		resetBtn:setVisible(isShowBox)
		challengeGoldTx:setVisible(isShowBox)
		goldIcon:setVisible(isShowBox)
		cashIcon:setVisible(isShowBox)
		resetCashTx:setVisible(isShowBox)

		updatePanel()
	end	

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/one_ride_panel.json' , 'oneride-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('oneride_bg_img' , 'oneride_img')

		panel:registerInitHandler(init)
		panel:registerOnShowHandler(onShow)

		UiMan.show(sceneObj)
	end

	local function getOneRideRequest()
		Message.sendPost('get_one_ride','activity','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']
			local teamId = data['team_id']
			bossId = tonumber(getFormationDataById(teamId)['Boss'])
			oneRideData = {}
			oneRideData['progress'] = tonumber(data['progress'])
			oneRideData['team'] = makeTeamData(teamId)
			oneRideData['fightForce'] = tonumber(data['fight_force'])
			oneRideData['num'] = tonumber(data['num'])
			freeTimes = tonumber(data['free_times'])
			cashTimes = tonumber(data['cash_times'])

			createPanel()
		end)
	end

	-- 入口
	getOneRideRequest()
end