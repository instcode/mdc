Avluckyroll = {}

--活动是否超时-- 活动开始结束时间和延时领取时间
function Avluckyroll.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'luckyroll' then
			conf = v
		end
	end)

	if conf == nil then
		return true
	end

	if tonumber(conf.Normalization) == 0 then -- 非常态活动

		local actyStartTime
        local actyEndTime
        if conf.StartTime ~= nil and conf.StartTime ~= '' then -- 优先判断StartTime字段
            actyStartTime = UserData:convertTime(1, conf.StartTime)
            actyEndTime   = UserData:convertTime(1, conf.EndTime) + (tonumber(conf.DelayDays))*86400 -- 加上奖励的领取延时1天 这两天充值元宝不计
        else
            local serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
            actyStartTime = serverOpenTime + (tonumber(conf.OpenDay) - 1)*86400
            actyEndTime = serverOpenTime + (tonumber(conf.OpenDay) + tonumber(conf.Duration) - 1)*86400
        end
        local nowTime = UserData:getServerTime()
        if nowTime < actyStartTime or nowTime > actyEndTime then
            return true
        end

    else    -- 常态活动
    	 if conf.StartTime ~= nil and conf.StartTime ~= '' then
            local time = UserData:getServerTime()
            local startTime = UserData:convertTime(1,conf.StartTime)
            local endTime = UserData:convertTime(1,conf.EndTime)

            if time < startTime or time > endTime then
                return true
            end
        end
    end

	return false
end

function Avluckyroll.enter()

	local runBgImg
	local runBtn
	local refreshBtn
	local showRankBtn
	local showHelpBtn
	local closeBtn

	local runCount
	local runCountGlobal  --转动次数

	local refreshCost
	local runCost
	local multiple
	local remainScore
	local remainTime
	local remainTimeInfo
	local remainTimeCD
	local frame = {}
	local itemIcon = {}
	local itemNum = {}

	--动画部分的变量
	local framePos = {}  --存放所有奖励的坐标，framePos = {framepos[i][1],framepos[i][2]} x,y坐标
	local itemFrameCount = 16   --中间抽奖的物品个数
	local selectFrame   --闪光的东东
	local posTable = {1}   --记录光标所在的ID位置
	local indexGlobal = 1	 --记录服务器发过来的位置
	
	--积分变化
	local multipleTable = {}  --存放转动倍数
	local multipleNum
	local runCostGlobal       --转动所需积分
	local refreshCostGlobal

	--消息
	local rankDataEncode = 0
	local rankHaveGot        --是否领奖
	local allStateEncode     --总状态刷新
	local remainScoreGlobal 
	local refreshTimesGlobal 
	local awardname

	local passTimeMark = 0  --倒计时结束标记

	local runRewardConf = GameData:getArrayData('luckgogogo.dat')   --暂定

	local refreshCostConf = GameData:getArrayData('avluckyrollcost.dat') 

	local itemRunConf = GameData:getArrayData('avluckyrollitem.dat') 

	local avData = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(avData,function ( _, v )
		if v['Key'] == 'luckyroll' then   --名字待定
			conf = v
		end
	end)


	local function createSelectFrame(obj)
		local light = CUIEffect:create()
		light:Show("yellow_light", 0)
		light:setScale(0.81)
		light:setPosition( ccp(0, 0))
		light:setAnchorPoint(ccp(0.5, 0.5))
		obj:getContainerNode():addChild(light)
		light:setZOrder(100)
		obj:setWidgetZOrder(99)
		runBgImg:addChild(obj)
	end

	local function rungogogoAction(positionId)

		local function lockButton()
			runBtn:disable()
			refreshBtn:disable()
			showRankBtn:disable()
			showHelpBtn:disable()
			closeBtn:disable()
		end

		local function openButton()
			runBtn:active()
			refreshBtn:active()
			showRankBtn:active()
			showHelpBtn:active()
			closeBtn:active()
		end

		local function showAward()
			if multipleNum == 1 then
				GameController.showPrompts(awardname , COLOR_TYPE.GREEN)
			else
				local multipleTx = 'X' .. multipleNum
				GameController.showPrompts(multipleTx , COLOR_TYPE.ORANGE)
			end
		end

		local function resetAward()
			awardname = nil
		end

		local function checkTimeMark()
			if passTimeMark == 1 then
				runBtn:disable()
				refreshBtn:disable()
			end
		end

		local delayTime = {}
		local function getDelayTime(positionId)
			for x = 1 , 4  do
				delayTime[x] = {}
				-- for y = 1 , itemFrameCount do 
					if x == 1  then
						for y = 1 , itemFrameCount do 
							delayTime[x][y] =  0.2 - (0.2-0.05)/itemFrameCount*y
						end
					elseif x == 2 then
						for y = 1 , itemFrameCount do 
							delayTime[x][y] =  0.05
						end
					elseif x == 3 then
						for y = 1 , itemFrameCount do
							delayTime[x][y] =  0.05 + 0.15/(positionId+1+itemFrameCount)*y
						end
					elseif x == 4 then
						for y = 1 , positionId+1 do
							delayTime[x][y] =  0.05 + 0.35/(positionId+1+itemFrameCount)*(y+itemFrameCount)
						end
					end
				-- end
			end
		end

		--奖品的位置
		getDelayTime(positionId)
		local arr = CCArray:create()
		arr:addObject(CCCallFunc:create(lockButton))
		local delayTimeTemp = {}
		for j = 1 , 4 do
			delayTimeTemp[j] = {} 
			if j ==1 or j ==2 or j == 3 then
				for i = 1 , itemFrameCount do 
					arr:addObject(CCCallFunc:create(function ()
						selectFrame:setPosition(ccp(framePos[i][1],framePos[i][2]))
					end))
					delayTimeTemp[j][i] = CCDelayTime:create(delayTime[j][i])
					arr:addObject(delayTimeTemp[j][i])
				end
			elseif j == 4 then
				for i = 1 , positionId+1 do 
					arr:addObject(CCCallFunc:create(function ()
						selectFrame:setPosition(ccp(framePos[i][1],framePos[i][2]))
					end))
					delayTimeTemp[j][i] = CCDelayTime:create(delayTime[j][i])
					arr:addObject(delayTimeTemp[j][i])
				end
				arr:addObject(CCCallFunc:create(function()

					table.insert(posTable,positionId)
					local allPosCount = 0
					for i =1 , #posTable do
						allPosCount = allPosCount + posTable[i]
					end
					local nowPos = (allPosCount-1)%itemFrameCount+1

					for i = 1 , itemFrameCount do
						framePos[i][1] = frame[(nowPos+i-1-1)%itemFrameCount+1]:getPosition().x
						framePos[i][2] = frame[(nowPos+i-1-1)%itemFrameCount+1]:getPosition().y
					end

				end))
				arr:addObject(CCCallFunc:create(showAward))
				arr:addObject(CCCallFunc:create(resetAward))
				arr:addObject(CCCallFunc:create(openButton))
				arr:addObject(CCCallFunc:create(checkTimeMark))
			end

		end
		selectFrame:runAction(CCRepeat:create(CCSequence:create(arr),1))
	end


	local function update()

		local allStateDecode = json.decode(allStateEncode)

		--定义全局变量
		refreshTimesGlobal = tonumber(allStateDecode['refresh'])
		remainScoreGlobal = tonumber(allStateDecode['score'])

		--定义剩余积分
		remainScore:setText(allStateDecode['score'])

		--定义刷新次数
		runCount:setText(allStateDecode['count'])
		runCountGlobal = tonumber(allStateDecode['count'])

		--定义刷新积分
		if tonumber(allStateDecode['refresh']) >= #refreshCostConf - 1 then
			refreshCost:setText(refreshCostConf[#refreshCostConf]['Score'])
			refreshCostGlobal = tonumber(refreshCostConf[#refreshCostConf]['Score'])
		else
			local nextRefreshTime = tonumber(allStateDecode['refresh']+1)
			refreshCost:setText(refreshCostConf[nextRefreshTime]['Score'])
			refreshCostGlobal = tonumber(refreshCostConf[nextRefreshTime]['Score'])
		end

		--定义转动消耗
		local runBaseCost = tonumber(GameData:getGlobalValue("LuckyRollBaseScoreCost"))
		local runAddCost = tonumber(GameData:getGlobalValue("LuckyRollMultiRollScoreCost"))
		if tonumber(allStateDecode.multi) == 0 then
			runCost:setText(tostring(runBaseCost))
			runCostGlobal = runBaseCost
		elseif tonumber(allStateDecode.multi) == 1 then
			runCost:setText(tostring(runBaseCost+runAddCost))
			runCostGlobal = runBaseCost+runAddCost
		elseif tonumber(allStateDecode.multi) == 2 then
			runCost:setText(tostring(runBaseCost+runAddCost*2))
			runCostGlobal = runBaseCost+runAddCost*2
		end

		--倍数显示
		multiple:setText(allStateDecode['times'])
		multipleNum = tonumber(allStateDecode['times'])

		--定义奖励
		local items = {}
		local runReward = {} 
		local arr = {}
		for i = 1 , #allStateDecode.items do
			items[i] = allStateDecode['items'][i]
			local str = itemRunConf[tonumber(items[i])]['Award1']
			-- isNotMultiple(str,i)
			--cclog(str)
			arr[i] = string.split(str,':')
			if arr[i][1] == 'multiple' then
				for j = 1 , 10 do 
					local url = string.format('uires/ui_2nd/com/panel/luckyroll/%d.png',arr[i][2])
					itemNum[i]:setText('')
					itemIcon[i]:setTexture(url)
					frame[i]:setTexture('uires/ui_2nd/com/panel/common/frame.png')
					frame[i]:setTouchEnable(false)
				end
			else
				items[i] = allStateDecode['items'][i]
				runReward[i] = UserData:getAward(itemRunConf[tonumber(items[i])]['Award1'])
				
		 		itemIcon[i]:setTexture(runReward[i].icon)
		 		if runReward[i].count > 10000 then 
		 			itemNum[i]:setText(toWordsNumber(runReward[i].count))
		 		else
		 			itemNum[i]:setText(runReward[i].count)
		 		end
		 		frame[i]:registerScriptTapHandler(function ()
					UISvr:showTipsForAward(itemRunConf[tonumber(items[i])]['Award1'])
				end)

				--设置边框颜色	
	 			if runReward[i].color.r == COLOR_TYPE.RED.r and runReward[i].color.g == COLOR_TYPE.RED.g and runReward[i].color.b == COLOR_TYPE.RED.b then
					frame[i]:setTexture('uires/ui_2nd/com/panel/common/frame_red.png')
				elseif runReward[i].color.r == COLOR_TYPE.WHITE.r and runReward[i].color.g == COLOR_TYPE.WHITE.g and runReward[i].color.b == COLOR_TYPE.WHITE.b then
					frame[i]:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
				elseif runReward[i].color.r == COLOR_TYPE.PURPLE.r and runReward[i].color.g == COLOR_TYPE.PURPLE.g and runReward[i].color.b == COLOR_TYPE.PURPLE.b then
					frame[i]:setTexture('uires/ui_2nd/com/panel/common/frame_purple.png')
				elseif runReward[i].color.r == COLOR_TYPE.ORANGE.r and runReward[i].color.g == COLOR_TYPE.ORANGE.g and runReward[i].color.b == COLOR_TYPE.ORANGE.b then
					frame[i]:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
				end
			end
		end

		--领奖时间判断
		if UserData:convertTime(1, conf.EndTime) - UserData:getServerTime() > 0 then
			--cclog('time1~~~~~~~~~~~~~~~~~~~~~~~~~~~choujiang')
			remainTimeCD:setTime(UserData:convertTime(1, conf.EndTime) - UserData:getServerTime())
		else
			--cclog('time2~~~~~~~~~~~~~~~~~~~~~~~~~~~lingjiang')
			remainTimeCD:setTime(UserData:convertTime(1, conf.EndTime) + (tonumber(conf.DelayDays))*86400 - UserData:getServerTime())
			remainTimeInfo:setText(getLocalStringValue('E_STR_GETAWARD_COUNTDOWN'))
			runBtn:disable()
			refreshBtn:disable()
		end

		--selectFrame动画框架，初始坐标为frame[1]
		selectFrame = UIImageView:create()
		selectFrame:setPosition(ccp(framePos[1][1],framePos[1][2]))
		createSelectFrame(selectFrame)
	end

	local function clickRun()
		if runCostGlobal > remainScoreGlobal then
			GameController.showPrompts(getLocalStringValue('E_STR_CARD_MASTER_NOT_ENOUGH_SCORE'), COLOR_TYPE.RED)
			return
		end

		Message.sendPost('lucky_roll_roll','activity','{}',function(res)
			cclog(res)
			local resTable = json.decode(res)
			if resTable.code ~= 0 then
				--cclog('lucky_roll_roll---- bad request~')
				return
			end
			local data = resTable.data

			--转动后的坐标变化
			local index = tonumber(data.index)
			--cclog('indexGlobal~~~~~~~~~per~~~~~~'..indexGlobal)
			local serverIndex = (index+itemFrameCount-indexGlobal)%itemFrameCount
			indexGlobal = index

			--转动的消耗
			local awards = data.awards
			local score = tonumber(data.score)
			--cclog(awards[1][1])
			local runBaseCost = tonumber(GameData:getGlobalValue("LuckyRollBaseScoreCost"))
			local runAddCost = tonumber(GameData:getGlobalValue("LuckyRollMultiRollScoreCost"))
			if awards[1][1] == 'multiple' then
				runCost:setText(tostring(math.abs(score)+runAddCost))
				runCostGlobal = math.abs(score)+runAddCost
			else
				runCost:setText(tostring(runBaseCost))
				runCostGlobal = runBaseCost
			end

			--转动次数
			runCountGlobal = runCountGlobal + 1
			runCount:setText(tostring(runCountGlobal))

			--积分扣除
			local costScore = tonumber(data.score)
			remainScoreGlobal = remainScoreGlobal + costScore
			remainScore:setText(tostring(remainScoreGlobal))

			--倍数的显示
			--cclog('multipleTable~~~~~~~~~~~~~~')
			printall(multipleTable)
			if awards[1][1] == 'multiple' then
				table.insert(multipleTable,awards[1][2])
				--cclog('multipleTable~~~~~~~~~~~~~~1')
				--printall(multipleTable)
				if multipleTable[2] then
					--cclog('multipleTable~~~~~~~~~~~~~~2')
					multipleNum = tonumber(multipleTable[2])*tonumber(multipleTable[1])
				else
					--cclog('multipleTable~~~~~~~~~~~~~~3')
					multipleNum = tonumber(multipleTable[1])
				end
				multiple:setText(tostring(multipleNum))
			else
				for i = 1 , #multipleTable do
					table.remove(multipleTable)
				end

				--cclog('awards[1]~~~~~~~~~~~~~')
				--cclog(UserData.makeAwardStr(awards[1]))
				if awards[1][2] == 'gold' then
					--cclog('it,s gold ~~~~~~~~~')
					PlayerCoreData.addGoldDelta(awards[1][3])
				else
					UserData.parseAwardJson(json.encode(awards))
				end

				local Award = UserData:getAward(UserData.makeAwardStr(awards[1]))
			    awardname = Award.name .. ' X' .. Award.count
			   -- GameController.showPrompts(awardname , COLOR_TYPE.GREEN)

				multipleNum = 1
				multiple:setText(tostring(multipleNum))
			end

			rungogogoAction(serverIndex)  --传入相对上次移动的数量，传入参数必须为1到itemFrameCount
		end)
		UpdateMainCity()
	end

	local function clickRefresh()
		if refreshCostGlobal > remainScoreGlobal then
			GameController.showPrompts(getLocalStringValue('E_STR_CARD_MASTER_NOT_ENOUGH_SCORE'), COLOR_TYPE.RED)
			return
		end

		Message.sendPost('lucky_roll_refresh','activity','{}',function(res)
			--cclog(res)
			local resTable = json.decode(res)
			if resTable.code ~= 0 then
				--cclog('lucky_roll_roll---- bad request~')
				return
			end
			local data = resTable.data
			
			--剩余积分
			local costScore = tonumber(data.score)
			remainScoreGlobal = remainScoreGlobal + costScore
			remainScore:setText(tostring(remainScoreGlobal))

			--刷新需要的消耗  ，需要已经刷新的次数
			refreshTimesGlobal = refreshTimesGlobal + 1
			if refreshTimesGlobal >= #refreshCostConf-1 then
				refreshCost:setText(refreshCostConf[#refreshCostConf]['Score'])
				refreshCostGlobal = tonumber(refreshCostConf[#refreshCostConf]['Score'])
			else
				local nextRefreshTime = refreshTimesGlobal+1
				--cclog('nextRefreshTime~	~~~~~~~~~~~~~~' .. nextRefreshTime)
				refreshCost:setText(refreshCostConf[nextRefreshTime]['Score'])
				refreshCostGlobal = tonumber(refreshCostConf[nextRefreshTime]['Score'])
			end
			
			--定义奖励
			local items = {}
			local runReward = {} 
			local arr = {}
			for i = 1 , #data.items do
				items[i] = data['items'][i]
				local str = itemRunConf[tonumber(items[i])]['Award1']
				-- isNotMultiple(str,i)
				--cclog(str)
				arr[i] = string.split(str,':')
				if arr[i][1] == 'multiple' then
					for j = 1 , 10 do 
						local url = string.format('uires/ui_2nd/com/panel/luckyroll/%d.png',arr[i][2])
						itemNum[i]:setText('')
						itemIcon[i]:setTexture(url)
						frame[i]:setTexture('uires/ui_2nd/com/panel/common/frame.png')
						frame[i]:setTouchEnable(false)
					end
				else
					items[i] = data['items'][i]
					runReward[i] = UserData:getAward(itemRunConf[tonumber(items[i])]['Award1'])
					
			 		itemIcon[i]:setTexture(runReward[i].icon)
			 		if runReward[i].count > 10000 then 
			 			itemNum[i]:setText(toWordsNumber(runReward[i].count))
			 		else
			 			itemNum[i]:setText(runReward[i].count)
			 		end
			 		frame[i]:registerScriptTapHandler(function ()
						UISvr:showTipsForAward(itemRunConf[tonumber(items[i])]['Award1'])
					end)

					--设置边框颜色	
		 			if runReward[i].color.r == COLOR_TYPE.RED.r and runReward[i].color.g == COLOR_TYPE.RED.g and runReward[i].color.b == COLOR_TYPE.RED.b then
						frame[i]:setTexture('uires/ui_2nd/com/panel/common/frame_red.png')
					elseif runReward[i].color.r == COLOR_TYPE.WHITE.r and runReward[i].color.g == COLOR_TYPE.WHITE.g and runReward[i].color.b == COLOR_TYPE.WHITE.b then
						frame[i]:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
					elseif runReward[i].color.r == COLOR_TYPE.PURPLE.r and runReward[i].color.g == COLOR_TYPE.PURPLE.g and runReward[i].color.b == COLOR_TYPE.PURPLE.b then
						frame[i]:setTexture('uires/ui_2nd/com/panel/common/frame_purple.png')
					elseif runReward[i].color.r == COLOR_TYPE.ORANGE.r and runReward[i].color.g == COLOR_TYPE.ORANGE.g and runReward[i].color.b == COLOR_TYPE.ORANGE.b then
						frame[i]:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
					end
					frame[i]:setTouchEnable(true)
				end
			end
		end)
	end

	local function showRank()
		local pCard
		local pPage
		local rankSv
		local genBtn
		local timeDiff

		local function getRank(rankData)
			--cclog('getRank(rankData)~~~~~~~~~~~~~~')
			for i,v in ipairs(rankData) do   --rankData暂未定义
				if tonumber(PlayerCoreData.getUID()) == tonumber(v.uid) then
					--cclog(i)
					return i
				end
			end
			return nil
		end

		local function genBtnState()

			timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
			--timeDiff = 20
			if timeDiff > 0 then
				--cclog('getBtnState~~~~~~~~~~~~~~~~~0-1')
				genBtn:setNormalButtonGray(false)
				genBtn:setTouchEnable(true)
				genBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
			end

			if rankDataEncode == 0 then
				--cclog('getBtnState~~~~~~~~~~~~~~~~~1-1')
				genBtn:setNormalButtonGray(true)
				genBtn:setTouchEnable(false)
				genBtn:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
			else 
				local rankDataDecode = json.decode(rankDataEncode)   

				if getRank(rankDataDecode) and tonumber(rankHaveGot) == 0 then
					--cclog('getBtnState~~~~~~~~~~~~~~~~~2-1')
					genBtn:setNormalButtonGray(false)
					genBtn:setTouchEnable(true)
					genBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
				elseif getRank(rankDataDecode) and tonumber(rankHaveGot) == 1 then
					--cclog('getBtnState~~~~~~~~~~~~~~~~~2-2')
					genBtn:setNormalButtonGray(true)
					genBtn:setTouchEnable(false)
					genBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
				else
					--cclog('getBtnState~~~~~~~~~~~~~~~~~2-3')
					genBtn:setNormalButtonGray(true)
					genBtn:setTouchEnable(false)
					genBtn:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
				end
			end
		end

		
		local sceneObjRank = SceneObjEx:createObj('panel/luckgogogo_rank_main.json','luckgogogo_rank-in-lua')
		local panelRank = sceneObjRank:getPanelObj()
		panelRank:setAdaptInfo('top_ranking_bg_img','top_ranking_img')

		panelRank:registerInitHandler(function ()
			local rootRank = panelRank:GetRawPanel()

			local closeBtn = tolua.cast(rootRank:getChildByName('close_btn'), 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObjRank))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			genBtn = tolua.cast(rootRank:getChildByName('get_award_btn'),'UITextButton')
			GameController.addButtonSound(genBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			genBtnState()
			genBtn:registerScriptTapHandler(function ()
				if UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime() > 0 then
					GameController.showPrompts(getLocalString('E_STR_NOTATTHETIME'),COLOR_TYPE.RED)
					return
				end
				Message.sendPost('lucky_roll_get_award','activity','{}',function(jsonData)
					--cclog(jsonData)
					local jsonDic = json.decode(jsonData)
					local data = jsonDic.data
					if jsonDic.code ~= 0 then
						GameController.showPrompts(getLocalString('E_STR_NOTATTHETIME'),COLOR_TYPE.RED)
						return
					end
					if data['awards'] then
						UserData.parseAwardJson(json.encode(data['awards']))
					end
					genBtn:setNormalButtonGray(true)
					genBtn:setTouchEnable(false)
					genBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
					GameController.showPrompts(getLocalString('E_STR_GET_SUCCEED'),COLOR_TYPE.GREEN)

				end)
			end)


			rankSv = tolua.cast(rootRank:getChildByName('card_sv'),'UIScrollView')
			--rankSv:removeAllChildrenAndCleanUp(true)
			rankSv:setClippingEnable(true)
			rankSv:setDirection(SCROLLVIEW_DIR_VERTICAL)
		end)

		UiMan.show(sceneObjRank)

		local function getPCard( )

			local rankName = {}
			local rankRunNum = {}
			for i = 1 , 10 do
				pCard = createWidgetByName('panel/luckgogogo_rank_panelin.json')
				if not pCard then
					print('failed to create luckgogogo_rank_panelin!!!!!')
				else
					local rankTx = tolua.cast(pCard:getChildByName('top_num_tx'),'UILabel')
					local rankTrena = tolua.cast(pCard:getChildByName('king_ico'),'UIImageView')
					rankTx:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK') , i))
					if i == 1 then
						rankTx:setVisible(false)
						rankTrena:setTexture('uires/ui_2nd/com/panel/trena/1.png')
					elseif i == 2 then
						rankTx:setVisible(false)
						rankTrena:setTexture('uires/ui_2nd/com/panel/trena/2.png')
					elseif i == 3 then
						rankTx:setVisible(false)
						rankTrena:setTexture('uires/ui_2nd/com/panel/trena/3.png')
					else
						rankTx:setVisible(true)
						rankTrena:setVisible(false)
					end

					if rankDataEncode ~= 0 then
						--local rankName = {}
						rankName[i] = tolua.cast(pCard:getChildByName('name_tx'),'UILabel')

						local rankDataDecode = json.decode(rankDataEncode)

						--for i = 1 , #rankDataDecode do
						if i <= #rankDataDecode then
							rankName[i]:setText(rankDataDecode[i]['name'])
						else
							rankName[i]:setText(getLocalString('E_STR_WELFARE_NORANK1'))
						end

						--local rankRunNum = {}
						rankRunNum[i] = tolua.cast(pCard:getChildByName('run_num_tx'),'UILabel')
						if i <= #rankDataDecode then
							rankRunNum[i]:setText(rankDataDecode[i]['count'])   
						else
							rankRunNum[i]:setText('0')
						end
					end

					--从表里读取奖励，放到card里，表中需要Id列
					local awards = {}
					local awardsConf = GameData:getArrayData('avluckyrollrankaward.dat')
					for _,v in pairs(awardsConf) do
						if tonumber(v['Rank']) == tonumber(i) then
							awards = {v['Award1'],v['Award2'],v['Award3'],v['Award4']}
							for j = 1 , #awards do
								local awardTmp = UserData:getAward(awards[j])
								local item = tolua.cast(pCard:getChildByName('photo_'..j..'_ico'),'UIImageView')
								local itemIcon = tolua.cast(item:getChildByName('award_ico'),'UIImageView')
								itemIcon:setTexture(awardTmp.icon)
								local itemNum = tolua.cast(item:getChildByName('number_tx'),'UILabel')
								itemNum:setText(toWordsNumber(tonumber(awardTmp.count)))
								--查看奖励
								item:registerScriptTapHandler(function ()
									-- local tabTmp = {awards[j]}
									-- ShowTotalAwardsPanel(tabTmp,'')
									UISvr:showTipsForAward(awards[j])
								end)
							end
						end
					end
					pCard:setPosition(ccp(10 , -200-160*i+400))
					pCard:setAnchorPoint(ccp(0.5,0.5))
					rankSv:addChild(pCard)
				end
			end
		end

		getPCard()
		rankSv:scrollToTop()
	end

	local function showHelp()
		local sceneObjHelp = SceneObjEx:createObj('panel/luckgogogo_help.json','luckgogogo_help_panel-in-lua')
		local panelHelp = sceneObjHelp:getPanelObj()
		panelHelp:setAdaptInfo('recharge_help_bg_img','help_img')

		panelHelp:registerInitHandler(function()
			local rootHelp = panelHelp:GetRawPanel()

			local closeBtn = tolua.cast(rootHelp:getChildByName('close_btn'), 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObjHelp))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			local knowBtn = tolua.cast(rootHelp:getChildByName('ok_btn'),'UIButton')
			knowBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObjHelp))
			GameController.addButtonSound(knowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			for i=1,4 do
				local infoTx = tolua.cast(rootHelp:getChildByName('info_'..i..'_tx'), 'UILabel')
				infoTx:setText(getLocalStringValue('E_STR_LUCK_GO_HELP_'..i))
				infoTx:setPreferredSize(580,1)
			end
			end)

		UiMan.show(sceneObjHelp)
	end

	local function sendRankRequest()
		Message.sendPost('lucky_roll_rank_list','activity','{}',function(res)
			--cclog(res)
			local resTable = json.decode(res)
			if resTable.code ~= 0 then
				--cclog('lucky_roll_get---- bad request~')
				return
			end
			local data = resTable.data
			local rank = data.rank_list

			if rank then
				rankDataEncode = json.encode(rank)
				rankHaveGot = data.got
				--cclog('have rankvalue')	
			end
			showRank()
		end)
	end

	local function init()
		root = panel:GetRawPanel()

		runBtn = tolua.cast(root:getChildByName('run_btn'),'UITextButton')
		runBtn:setText(getLocalStringValue('E_STR_RUN'))
		GameController.addButtonSound(runBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)
		runBtn:registerScriptTapHandler(clickRun)

		refreshBtn = tolua.cast(root:getChildByName('refresh_btn'),'UITextButton')
		GameController.addButtonSound(refreshBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)
		refreshBtn:registerScriptTapHandler(clickRefresh)

		showRankBtn = tolua.cast(root:getChildByName('rank_btn'),'UITextButton')
		GameController.addButtonSound(showRankBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)
		showRankBtn:registerScriptTapHandler(sendRankRequest)

		showHelpBtn = tolua.cast(root:getChildByName('help_btn'),'UIButton')
		GameController.addButtonSound(showHelpBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)
		showHelpBtn:registerScriptTapHandler(showHelp)

		runBgImg = tolua.cast(root:getChildByName('runer_bg_img'),'UIImageView')

		local runCostInfo = tolua.cast(root:getChildByName('runcostscore_info'),'UILabel')
		runCostInfo:setText(getLocalStringValue('E_STR_RUN_SCORE'))
		local refreshInfo = tolua.cast(root:getChildByName('refresh_info'),'UILabel')
		refreshInfo:setText(getLocalStringValue('E_STR_REFRESH_SCORE'))
		runCost = tolua.cast(root:getChildByName('run_cost_tx'),'UILabel')
		refreshCost = tolua.cast(root:getChildByName('refresh_cost_tx'),'UILabel')
		multiple = tolua.cast(root:getChildByName('multiple_tx'),'UILabel')
		runCount = tolua.cast(root:getChildByName('runcount_tx'),'UILabel')
		local runCountInfo = tolua.cast(root:getChildByName('runcount_info'),'UILabel')
		runCountInfo:setText(getLocalStringValue('E_STR_RUN_COUNT'))
		remainScore = tolua.cast(root:getChildByName('score_tx'),'UILabel')
		local remainScoreInfo = tolua.cast(root:getChildByName('score_info'),'UILabel')
		remainScoreInfo:setText(getLocalStringValue('E_STR_REMAIN_SCORE'))

		remainTimeInfo = tolua.cast(root:getChildByName('timeinfo_tx'),'UILabel')
		remainTimeInfo:setText(getLocalStringValue('E_STR_LEFT_TIME'))
		remainTime = tolua.cast(root:getChildByName('overtime_tx'),'UILabel')
		remainTime:setText('')
		remainTimeCD = UICDLabel:create()
		remainTimeCD:setFontSize(24)
		remainTimeCD:setFontColor(COLOR_TYPE.WHITE)
		remainTimeCD:setAnchorPoint(ccp(0,0.5))
		remainTimeCD:setPosition(ccp(20,0))
		remainTime:addChild(remainTimeCD)
		remainTimeCD:registerTimeoutHandler(function()
			passTimeMark = 1
			remainTimeInfo:setText(getLocalStringValue('E_STR_GETAWARD_COUNTDOWN'))
			remainTimeCD:setTime(UserData:convertTime(1, conf.EndTime) + (tonumber(conf.DelayDays))*86400 - UserData:getServerTime())
			runBtn:disable()
			refreshBtn:disable()
		end)


		for i = 1 , itemFrameCount do
			frame[i] = tolua.cast(runBgImg:getChildByName(string.format('item%d_frame_img',i)),'UIImageView')
			frame[i]:setTouchEnable(true)

			itemIcon[i] = tolua.cast(runBgImg:getChildByName(string.format('item%d_img',i)),'UIImageView')
			itemNum[i] = tolua.cast(runBgImg:getChildByName(string.format('num%d_tx',i)),'UILabel')

			framePos[i] = {}
			framePos[i][1] = frame[i]:getPosition().x
			framePos[i][2] = frame[i]:getPosition().y
		end

		closeBtn = tolua.cast(root:getChildByName('close_btn'),'UIButton')
		GameController.addButtonSound(closeBtn,BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))

		update()
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/luck_gogogo_bg_panel.json','luckgogogo_bg_panel-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('role_bg_img','role_img')

		panel:registerInitHandler(init)
		--panel:registerOnShowHandler(onShow)
		--panel:registerOnHideHandler(onHide)
		UiMan.show(sceneObj)
	end

	local function sendUpdateRequest()
		Message.sendPost('lucky_roll_get','activity','{}',function(res)
			cclog(res)
			local resTable = json.decode(res)
			if resTable.code ~= 0 then
				--cclog('lucky_roll_get---- bad request~')
				return
			end
			local data = resTable.data
			local luckyRoll = data.lucky_roll
			allStateEncode = json.encode(luckyRoll)
			createPanel()
		end)
	end

	local function getborrowarrowResponse()
		-- if isFuncOpen() then
			sendUpdateRequest()
		-- end
	end

	--入口
	getborrowarrowResponse()
end

