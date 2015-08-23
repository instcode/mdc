genAchievementPanel = function ()
	-- func
	local getAchievementRequest
	-- ui
	local sceneObj
	local panel
	local titleTx
	local cardInfoMap = {}
	-- data
	local achievementFile = 'achievement.dat'
	local stage				-- 当前阶段
	local progressData
	local goalData
	local nowItemArr = {}

	local function getAchievementData( achstage , achgoal )
		local conf = GameData:getArrayData(achievementFile)
		local data
		table.foreach(conf , function (k , v)
			if tonumber(v['StageId']) == tonumber(achstage) and tonumber(v['GoalId']) == tonumber(achgoal) then
				data = v
			end
		end)
		return data
	end

	local function genPlaintAction()
		local actArr = CCArray:create()
        actArr:addObject(CCRotateTo:create(0.05,-30))
        actArr:addObject(CCRotateTo:create(0.05,15))
        actArr:addObject(CCRotateTo:create(0.05,0))
        actArr:addObject(CCRotateTo:create(0.05,-30))
   		actArr:addObject(CCRotateTo:create(0.05,15))
   		actArr:addObject(CCRotateTo:create(0.05,0))
		actArr:addObject(CCDelayTime:create(1.0))
		return CCRepeatForever:create(CCSequence:create(actArr))
	end

	local function setFinishIcoOrRewardBtnStatus(i , j , isIco , isBtn )
		if goalData[i][j] == 2 then
			if isIco then
				cardInfoMap[i]['itemInfo'][j]['finishIco']:setTexture("uires/ui_2nd/com/panel/common/checkmark.png")
				cardInfoMap[i]['itemInfo'][j]['finishIco']:setVisible(true)
				cardInfoMap[i]['itemInfo'][j]['finishIco']:stopAllActions()
				cardInfoMap[i]['itemInfo'][j]['finishIco']:setRotation(0)
			end
			if isBtn then
				cardInfoMap[i]['rewardBtn']:setText(getLocalString('E_STR_ARENA_GOT_REWARD'))
				cardInfoMap[i]['rewardBtn']:setNormalButtonGray(true)
				cardInfoMap[i]['rewardBtn']:setTouchEnable(false)
			end
		elseif goalData[i][j] == 1 then
			if isIco then
				cardInfoMap[i]['itemInfo'][j]['finishIco']:setTexture("uires/ui_2nd/com/panel/playerguide/plaint.png")
				cardInfoMap[i]['itemInfo'][j]['finishIco']:setVisible(true)
				cardInfoMap[i]['itemInfo'][j]['finishIco']:stopAllActions()
				cardInfoMap[i]['itemInfo'][j]['finishIco']:setRotation(0)
				cardInfoMap[i]['itemInfo'][j]['finishIco']:runAction(genPlaintAction())
			end
			if isBtn then
				cardInfoMap[i]['rewardBtn']:setText(getLocalString('E_STR_GET_AWARD'))
				cardInfoMap[i]['rewardBtn']:setNormalButtonGray(false)
				cardInfoMap[i]['rewardBtn']:setTouchEnable(true)
			end
		else
			if isIco then
				cardInfoMap[i]['itemInfo'][j]['finishIco']:setVisible(false)
				cardInfoMap[i]['itemInfo'][j]['finishIco']:stopAllActions()
				cardInfoMap[i]['itemInfo'][j]['finishIco']:setRotation(0)
			end
			if isBtn then
				cardInfoMap[i]['rewardBtn']:setText(getLocalString('E_STR_GET_AWARD'))
				cardInfoMap[i]['rewardBtn']:setNormalButtonGray(true)
				cardInfoMap[i]['rewardBtn']:setTouchEnable(false)
			end
		end
	end

	local function updateAchPanel()
		for i = 0 , 2 do
			nowItemArr[i] = 0
			for j = 0 , 2 do
				if goalData[i][j] == 2 then
					if j == 2 then
						nowItemArr[i] = j
					else
						nowItemArr[i] = j + 1
					end
				end
			end
		end

		local tempURL = 'uires/ui_2nd/image/achievement/'
		for i = 0 , 2 do
			local achData = getAchievementData(stage , i + 1)
			cardInfoMap[i]['cardNameIco']:setTexture(tempURL .. achData.name)
			for j = 0 , 2 do
				cardInfoMap[i]['itemInfo'][j]['light']:setVisible(false)
				cardInfoMap[i]['itemInfo'][j]['itemIco']:setTexture(tempURL .. achData['icon' .. (j+1)])
				
				setFinishIcoOrRewardBtnStatus(i , j , true , false)
			end

			cardInfoMap[i]['itemDec']:setText(GetTextForCfg(achData['Info' .. (nowItemArr[i] + 1)]))
			cardInfoMap[i]['rewardIco']:setTexture("uires/ui_2nd/image/item/cash_icon.png")

			for j = 0 , 2 do
				cardInfoMap[i]['itemInfo'][j]['itemIco']:setAmbientLight(0,0,0)
				cardInfoMap[i]['itemInfo'][j]['light']:setVisible(false)
			end

			cardInfoMap[i]['itemInfo'][nowItemArr[i]]['itemIco']:setAmbientLight(0.4,0.4,0.4)
			cardInfoMap[i]['itemInfo'][nowItemArr[i]]['light']:setVisible(true)
			local rewardData = UserData:getAward( achData['Award' .. (nowItemArr[i] + 1)] )
			cardInfoMap[i]['rewardNum']:setTextFromInt(tonumber(rewardData.count))

			local strCurrent = tostring(progressData[i][nowItemArr[i]])
			local strMax = tostring(achData['Condition' .. (nowItemArr[i] + 1)])

			cardInfoMap[i]['expBarTx']:setText(strCurrent .. '/' ..strMax)
			local barNum = tonumber(progressData[i][nowItemArr[i]]) / tonumber(achData['Condition' .. (nowItemArr[i] + 1)])
			cardInfoMap[i]['expBar']:setPercent(barNum * 100)

			setFinishIcoOrRewardBtnStatus(i , nowItemArr[i] , false , true)

			if goalData[i][0] == 2 and goalData[i][1] == 2 and goalData[i][2] == 2 then
				cardInfoMap[i]['itemDec']:setVisible(false)
				cardInfoMap[i]['finishTx']:setVisible(true)
			else
				cardInfoMap[i]['itemDec']:setVisible(true)
				cardInfoMap[i]['finishTx']:setVisible(false)
			end

			cardInfoMap[i]['rewardBtn']:setWidgetTag((i + 1) * 10 + nowItemArr[i] + 1 + 100)
			titleTx:setText(GetTextForCfg(achData.stageIdname))
		end
	end

	local function onClickItemBtn( tag )
		local level = math.mod(tag , 10)
		local goal = math.floor(tag / 10)
		local num = goal - 1
		nowItemArr[num] = level - 1

		local achData = getAchievementData(stage , goal)
		cardInfoMap[num]['itemDec']:setText(GetTextForCfg(achData['Info' .. level]))
		local rewardData = UserData:getAward( achData['Award' .. level] )
		cardInfoMap[num]['rewardNum']:setTextFromInt(tonumber(rewardData.count))
		local achNum = tonumber(achData['Condition' .. level])

		for i = 0 , 2 do
			cardInfoMap[num]['itemInfo'][i]['itemIco']:setAmbientLight(0,0,0)
			cardInfoMap[num]['itemInfo'][i]['light']:setVisible(false)
		end

		cardInfoMap[num]['itemInfo'][level - 1]['itemIco']:setAmbientLight(0.4,0.4,0.4)
		cardInfoMap[num]['itemInfo'][level - 1]['light']:setVisible(true)

		local strCurrent = tostring(progressData[num][level - 1])
		local strMax = tostring(achData['Condition' .. level])

		cardInfoMap[num]['expBarTx']:setText(strCurrent .. '/' ..strMax)
		local barNum = tonumber(progressData[num][level - 1]) / achNum
		cardInfoMap[num]['expBar']:setPercent(barNum * 100)

		cardInfoMap[num]['rewardBtn']:setWidgetTag(tag + 100)

		setFinishIcoOrRewardBtnStatus(num , level - 1 , true , true)

		if goalData[num][0] == 2 and goalData[num][1] == 2 and goalData[num][2] == 2 then
			cardInfoMap[num]['itemDec']:setVisible(false)
			cardInfoMap[num]['finishTx']:setVisible(true)
		else
			cardInfoMap[num]['itemDec']:setVisible(true)
			cardInfoMap[num]['finishTx']:setVisible(false)
		end
	end

	local function getRewardRequest( goal , level )
		local tab = {goal = goal,id = level}
		Message.sendPost('get_reward','achievement',json.encode(tab),function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end
			local data = jsonDic['data']
			local awards = data['awards']

			UserData.parseAwardJson(json.encode(awards))
			GameController.showPrompts(getLocalString("E_STR_REWARD_SUCCEED") , COLOR_TYPE.GREEN)

			getAchievementRequest()
		end)
	end

	local function onClickGetRewardBtn( tag )
		local level = math.mod(tag , 10)
		local goal = math.floor(tag / 10)
		local num = goal - 1
		if goalData[num][level - 1] == 1 then
			getRewardRequest(goal , level)
		end
	end

	local function init()
		local root = panel:GetRawPanel()
		local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local achBgImg = tolua.cast(root:getChildByName('achievement_bg_img') , 'UIImageView')
		local achSmallBgImg = tolua.cast(achBgImg:getChildByName('achievement_img') , 'UIImageView')
		local titleImg = tolua.cast(achSmallBgImg:getChildByName('title_ico') , 'UIImageView')

		titleTx = tolua.cast(titleImg:getChildByName('title_tx') , 'UILabel')

		for i = 0 , 2 do
			local cardImg = tolua.cast(achSmallBgImg:getChildByName('card_' .. (i+1) .. '_ico') , 'UIImageView')
			local smallCardImg = tolua.cast(cardImg:getChildByName('kuang_ico') , 'UIImageView')
			cardInfoMap[i] = {}
			cardInfoMap[i]['cardNameIco'] = tolua.cast(smallCardImg:getChildByName('card_name_ico') , 'UIImageView')
			cardInfoMap[i]['itemInfo'] = {}
			for j = 0 , 2 do
				cardInfoMap[i]['itemInfo'][j] = {}
				local str = 'item_photo_' .. (j + 1) .. '_ico'
				cardInfoMap[i]['itemInfo'][j]['itemIcoBg'] = tolua.cast(smallCardImg:getChildByName(str) , 'UIImageView')
				cardInfoMap[i]['itemInfo'][j]['itemIcoBg']:registerScriptTapHandler(function ()
					local tag = cardInfoMap[i]['itemInfo'][j]['itemIcoBg']:getWidgetTag()
					onClickItemBtn(tag)
				end)
				cardInfoMap[i]['itemInfo'][j]['itemIcoBg']:setWidgetTag((i + 1) * 10 + (j + 1))

				cardInfoMap[i]['itemInfo'][j]['itemIco'] = tolua.cast(cardInfoMap[i]['itemInfo'][j]['itemIcoBg']:getChildByName('item_ico') , 'UIImageView')
				cardInfoMap[i]['itemInfo'][j]['finishIco'] = tolua.cast(cardInfoMap[i]['itemInfo'][j]['itemIcoBg']:getChildByName('finish_ico') , 'UIImageView')
				cardInfoMap[i]['itemInfo'][j]['light'] = CUIEffect:create()
				cardInfoMap[i]['itemInfo'][j]['light']:retain()
				cardInfoMap[i]['itemInfo'][j]['light']:Show('yellow_light' , 0)
				cardInfoMap[i]['itemInfo'][j]['light']:setScale(0.77)

				local containerNode = cardInfoMap[i]['itemInfo'][j]['itemIcoBg']:getContainerNode()
				local contentSize = cardInfoMap[i]['itemInfo'][j]['itemIcoBg']:getContentSize()
				cardInfoMap[i]['itemInfo'][j]['light']:setPosition(ccp(0,0))
				cardInfoMap[i]['itemInfo'][j]['light']:setAnchorPoint(ccp(0.5 , 0.5))
				containerNode:addChild(cardInfoMap[i]['itemInfo'][j]['light'])
			end
			cardInfoMap[i]['itemDec'] = tolua.cast(cardImg:getChildByName('info_tx') , 'UITextArea')
			cardInfoMap[i]['itemDec']:setTextHorizontalAlignment(kCCTextAlignmentCenter)
			cardInfoMap[i]['itemDec']:setTextVerticalAlignment(kCCVerticalTextAlignmentCenter)

			cardInfoMap[i]['rewardBtn'] = tolua.cast(cardInfoMap[i]['itemDec']:getChildByName('award_btn') , 'UITextButton')
			cardInfoMap[i]['rewardBtn']:registerScriptTapHandler(function ()
				local tag = tonumber(cardInfoMap[i]['rewardBtn']:getWidgetTag()) - 100
				onClickGetRewardBtn( tag )
			end)
			local itemIcoBg = tolua.cast(cardInfoMap[i]['itemDec']:getChildByName('award_photo_ico') , 'UIImageView')
			cardInfoMap[i]['rewardIco'] = tolua.cast(itemIcoBg:getChildByName('award_ico') , 'UIImageView')
			cardInfoMap[i]['rewardNum'] = tolua.cast(itemIcoBg:getChildByName('award_num_tx') , 'UILabel')
			local expBgImg = tolua.cast(cardInfoMap[i]['itemDec']:getChildByName('exp_bg_img') , 'UIImageView')
			cardInfoMap[i]['expBar'] = tolua.cast(expBgImg:getChildByName('exp_bar') , 'UILoadingBar')
			cardInfoMap[i]['expBar']:setVisible(true)
			cardInfoMap[i]['expBar']:setDirection(LoadingBarTypeLeft)
			cardInfoMap[i]['expBar']:setPercent(100)
			cardInfoMap[i]['expBarTx'] = tolua.cast(expBgImg:getChildByName('exp_num_tx') , 'UILabel')
			cardInfoMap[i]['finishTx'] = tolua.cast(cardImg:getChildByName('accomplish_tx') , 'UILabel')
		end

		nowItemArr = {}
		for i = 0 , 2 do
			nowItemArr[i] = 0
		end

		updateAchPanel()
		CUIManager:GetInstance():updateSceneId(30023)				-- 成就界面
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/achievement_panel.json' , 'achievement-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('achievement_bg_img' , 'achievement_img')

		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end

	initData = function ( data )
		goalData = {}
		progressData = {}

		stage = tonumber(data['stage'])
		if stage < 6 then
			for i = 0 , 2 do
				goalData[i] = {}
				for j = 0 , 2 do
					goalData[i][j] = tonumber(data['goal'][tostring(i+1)][j+1])
				end
			end
		else 			-- 当所有成就完成
			stage = 5
			goalData = {}
			for i = 0 , 2 do
				goalData[i] = {}
				for j = 0 , 2 do
					goalData[i][j] = 2
				end
			end
		end
	
		for i = 0 , 2 do
			progressData[i] = {}
			for j = 0 , 2 do
				progressData[i][j] = data['progress'][tostring(i+1)][j+1]
			end
		end
	end

	getAchievementRequest = function ()
		Message.sendPost('get','achievement','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end
			local data = jsonDic['data']['achievement']
			initData(data)

			if sceneObj then
				updateAchPanel()
			else
				createPanel()
			end
		end)
	end

	-- 入口
	getAchievementRequest()
end