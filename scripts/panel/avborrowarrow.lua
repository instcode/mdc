Avborrowarrow = {}

local markBoxIsActive

local function genShowTotalAwardsPanel(awards,infoTx )
	local showAward = SceneObjEx:createObj('panel/thousandfloor_res_panel.json', 'show-award-total-panel')
    local panel = showAward:getPanelObj()
    panel:setAdaptInfo('gain_res_bg_img', 'gain_res_img')

    panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		local gainBgImg = tolua.cast(root:getChildByName('gain_res_bg_img'),'UIImageView')
		local gainImg = tolua.cast(gainBgImg:getChildByName('gain_res_img'),'UIImageView')

		local know_btn = tolua.cast(gainImg:getChildByName('know_btn'),'UITextButton')
		know_btn:setText(getLocalString('E_STR_ARENA_CAN_GET'))
		GameController.addButtonSound(know_btn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		know_btn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(showAward, ELF_HIDE.SMART_HIDE)
		end)

		local info_tx = tolua.cast(gainImg:getChildByName('info_tx') , 'UILabel')
		info_tx:setText(infoTx)

		local awardSv = tolua.cast(gainImg:getChildByName('award_sv') , 'UIScrollView')
		awardSv:setClippingEnable(true)
		awardSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
		local awardNum = #awards
		for k, v in pairs(awards) do
			local award = UserData:getAward(v)
			local awardImg = createWidgetByName('panel/thousandfloor_award_panel.json')
			local awardRoot = tolua.cast(awardImg:getChildByName('res_photo_ico') , 'UIImageView')
			local pIco = tolua.cast(awardRoot:getChildByName('res_ico') , 'UIImageView')
			local pName = tolua.cast(awardRoot:getChildByName('res_name_tx') , 'UILabel')
			local pNum = tolua.cast(awardRoot:getChildByName('res_num_tx') , 'UILabel')
			pName:setPreferredSize(120,1)
			pIco:setTouchEnable(true)
			pIco:registerScriptTapHandler( function()
				UISvr:showTipsForAward(v)
			end )
			pIco:setTexture(award.icon)
			pIco:setAnchorPoint(ccp(0,0))
			pName:setText(award.name)
			pName:setColor(award.color)
			pNum:setText(toWordsNumber(award.count))
			awardSv:addChildToRight(awardImg)
		end
		if awardNum == 1 then
			awardSv:setPosition(ccp(140,150))
		elseif awardNum == 2 then
			awardSv:setPosition(ccp(75,150))
		end
	end)
    CUIManager:GetInstance():ShowObject(showAward, ELF_SHOW.SMART)
end

local function ShowTotalAwardsPanel(awards,infoTx )
	local showAward = SceneObjEx:createObj('panel/thousandfloor_res_panel.json', 'show-award-total-panel')
    local panel = showAward:getPanelObj()
    panel:setAdaptInfo('gain_res_bg_img', 'gain_res_img')

    panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		local gainBgImg = tolua.cast(root:getChildByName('gain_res_bg_img'),'UIImageView')
		local gainImg = tolua.cast(gainBgImg:getChildByName('gain_res_img'),'UIImageView')
		local gongxi = tolua.cast(root:getChildByName('gongxi_bg_ico'),'UIImageView')
		gongxi:setVisible(false)

		local know_btn = tolua.cast(gainImg:getChildByName('know_btn'),'UITextButton')
		GameController.addButtonSound(know_btn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		know_btn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(showAward, ELF_HIDE.SMART_HIDE)
		end)

		local info_tx = tolua.cast(gainImg:getChildByName('info_tx') , 'UILabel')
		info_tx:setText(infoTx)

		local awardSv = tolua.cast(gainImg:getChildByName('award_sv') , 'UIScrollView')
		awardSv:setClippingEnable(true)
		awardSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
		local awardNum = #awards
		for k, v in pairs(awards) do
			local award = UserData:getAward(v)
			local awardImg = createWidgetByName('panel/thousandfloor_award_panel.json')
			local awardRoot = tolua.cast(awardImg:getChildByName('res_photo_ico') , 'UIImageView')
			local pIco = tolua.cast(awardRoot:getChildByName('res_ico') , 'UIImageView')
			local pName = tolua.cast(awardRoot:getChildByName('res_name_tx') , 'UILabel')
			local pNum = tolua.cast(awardRoot:getChildByName('res_num_tx') , 'UILabel')
			pName:setPreferredSize(120,1)
			pIco:setTouchEnable(true)
			pIco:registerScriptTapHandler( function()
				UISvr:showTipsForAward(v)
			end )
			pIco:setTexture(award.icon)
			pIco:setAnchorPoint(ccp(0,0))
			pName:setText(award.name)
			pName:setColor(award.color)
			pNum:setText(toWordsNumber(award.count))
			awardSv:addChildToRight(awardImg)
		end
		if awardNum == 1 then
			awardSv:setPosition(ccp(140,150))
		elseif awardNum == 2 then
			awardSv:setPosition(ccp(75,150))
		end
	end)
    CUIManager:GetInstance():ShowObject(showAward, ELF_SHOW.SMART)
end

function Avborrowarrow.isActive()
	--临时通道
	--return true

	if markBoxIsActive == 0 then 
		return true
	elseif markBoxIsActive ==1 then 
		return false
	end

	-- local count = 0 

	-- local level = PlayerCoreData.getPlayerLevel()
 --    local activitiesConf = GameData:getMapData('activities.dat')
 --    local openLevel = activitiesConf['borrowarrow'].OpenLevel
 --    if  tonumber(level) < tonumber(openLevel) then      -- 如果等级不够
 --    	return false
 --    else 
 --    	--return true
 --    	count = count + 1
 --    end 

 --    local data = UserData:getBorrowArrow()  --名字待定
 --    --看不到就打印
 --    cclog('isActivedata~~~~~~~~~~~~~~~ :'.. data)
 --    if data.id > 4 then
 --    	return false
 --    else
 --    	local severTime = data.time 
 --    	local finishTime = tonumber(severTime) + 1*3600
 --    	local currTime = UserData:getServerTime()
 --    	return tonumber(finishTime) <= tonumber(currTime)
 --    	count = count + 1
 --    end

 --    if count == 2 then 
 --    	return true
 --    else
 --    	return false
 --    end
end

--活动是否超时-- 活动开始结束时间和延时领取时间
function Avborrowarrow.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'borrowarrow' then
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


function Avborrowarrow.enter()
	
	-- 定义一些常量
	local avData = GameData:getArrayData('activities.dat')
	local conf
		table.foreach(avData,function ( _, v )
		if v['Key'] == 'borrowarrow' then
			conf = v
		end
	end)
	local materialMap = GameData:getMapData('material.dat')
	local serverAwardMap = GameData:getArrayData('avborrowarrowserveraward.dat')
	local tenArrowCostMap = GameData:getArrayData('avborrowarrowcost.dat')
	local sceneObj
	local panel
	local root
	local cashNum
	local serverArrowsNum
	local personalArrowsNum
	local rankNum --个人名次
	local rankDi
	local rankMing
	local rank = {}
	local boxNum = {}
	local borrowArrowData -- 服务器中的borrow_arrow的表数据


	local scoreNum
	local remainScore
	local boxIcon = {}
	local boxGift = {}

 	-- 一箭单发
 	local oneArrowRemainTimes  --每天免费次数
 	local oneArrowResetTimes  --倒计时的父节点label
 	local oneArrowResetTimesCD  --倒计时
 	local oneArrowResetBtn   --倒计时刷新按钮
	local oneArrowBtn
	local tenArrowBtn
	local exchangeBtn
	local showRankBtn
	local helpBtn

	local tempOneArrowTimes  --次数
	local tempOneArrow       --箭数

	local oneArrowFreeTimesInSever  --服务器上点击单发的次数
	local serverTime                --服务器时间  
	local updateTime                --上次点击单发的时间
	
	--十箭连发
	local tenArrowsCost
	local tenAC

	--onshow message里数据
	local score  --引用json中score的全局变量
	local allTenScroe  --score的全局变量，请无视名字

	--服务器标记  0为未发送 1为已发送
	local markPost = 1

	--总箭数
	local allArrowNum  --服务器total箭数

	--排名
	local rankData
	local rankDataEncode


	-- local function isFuncOpen()
	-- 	local targetLv = tonumber(GameData:getGlobalValue('activities.dat'))
	-- 	if PlayerCoreData.getPlayerLevel() < targetLv then
	-- 		local s = string.format(getLocalStringValue('E_STR_GO_OPEN') , targetLv)
	-- 		GameController.showMessageBox(s, MESSAGE_BOX_TYPE.OK)
	-- 		return false
	-- 	end
	-- 	return true
	-- end
	local function buttonLock()
		oneArrowBtn:setTouchEnable(false)
		tenArrowBtn:setTouchEnable(false)
		exchangeBtn:setTouchEnable(false)
		oneArrowResetBtn:setTouchEnable(false)
		showRankBtn:setTouchEnable(false)
		helpBtn:setTouchEnable(false)
	end

	local function buttonOpen()
		oneArrowBtn:setTouchEnable(true)
		tenArrowBtn:setTouchEnable(true)
		exchangeBtn:setTouchEnable(true)
		oneArrowResetBtn:setTouchEnable(true)
		showRankBtn:setTouchEnable(true)
		helpBtn:setTouchEnable(true)
	end

	local function arrowActionNormal()
		local arrowThird = tolua.cast(root:getChildByName('arrow_thr_img'),'UIImageView')
		local arrT = CCArray:create()
		local moveTime = 0.5
		local rotateTo1 = CCRotateTo:create(0.2, -35)
		local rotateTo2 = CCRotateTo:create(0.2, -55)
		local fadeOut3 = CCFadeOut:create(2)
		local fadeIn3 = CCFadeIn:create(0.5)
		local bezier3 = ccBezierConfig()
		bezier3.controlPoint_1 = ccp(-400,187)
		bezier3.controlPoint_2 = ccp(-36,187)
		bezier3.endPosition = ccp(-36,37)
		local bezierTo3 = CCBezierTo:create(1,bezier3)
		local newRotateTo3 = CCRotateTo:create(1,-45)
		local easeSineIn3 = CCEaseSineIn:create(bezierTo3) 
		local spawn3 = CCSpawn:createWithTwoActions(newRotateTo3,easeSineIn3)
		local rotateToReset3 = CCRotateTo:create(0,-135)

		--第三只箭
		--arrT:addObject(CCCallFunc:create(buttonLock))
		arrowThird:stopAllActions()
		arrT:addObject(rotateToReset3)

		--新加动作  设置初始角度
		arrT:addObject(CCCallFunc:create(function (  )
			arrowThird:setPosition(ccp(-400,37))
			--cclog('setPosition~~~~~~~~3-1')
		end))

		arrT:addObject(fadeIn3)

		--cclog('setPosition~~~~~~~~3-2')
		arrT:addObject(spawn3)
		--cclog('setPosition~~~~~~~~3-3')
		for i=1,3 do
			arrT:addObject(rotateTo1)
			arrT:addObject(rotateTo2)
		end
		--cclog('setPosition~~~~~~~~3-4')
		arrT:addObject(fadeOut3)
		arrT:addObject(CCCallFunc:create(function (  )
			arrowThird:setPosition(ccp(-400,37))
			--cclog('setPosition~~~~~~~~3-5')
		end))
		arrowThird:runAction(CCSequence:create(arrT))
	end

	local function arrowAction()

		local arrowThird = tolua.cast(root:getChildByName('arrow_thr_img'),'UIImageView')
		local arrowSecond = tolua.cast(root:getChildByName('arrow_sec_img'),'UIImageView')
		local arrowFirst = tolua.cast(root:getChildByName('arrow_frs_img'),'UIImageView')

		local arrT = CCArray:create()
		local arrS = CCArray:create()
		local arrF = CCArray:create()
		local moveTime = 0.5

		local delayTime1 = CCDelayTime:create(0.2)
		local delayTime2 = CCDelayTime:create(0.5)
		local moveToT = CCMoveTo:create(moveTime,ccp(-36,37))
		local moveToS = CCMoveTo:create(moveTime,ccp(41,0))
		local moveToF = CCMoveTo:create(moveTime,ccp(42,18))
		local rotateBy1 = CCRotateBy:create(0.1, -10)
		local rotateBy2 = CCRotateBy:create(0.1, 10)
		local rotateBy3 = CCRotateBy:create(0.1, -10)
		local rotateBy4 = CCRotateBy:create(0.1, 10)
		local rotateBy5 = CCRotateBy:create(0.1, -10)
		local rotateBy6 = CCRotateBy:create(0.1, 10)
		local fadeOut1 = CCFadeOut:create(0.5)
		local fadeOut2 = CCFadeOut:create(0.5)
		local fadeOut3 = CCFadeOut:create(0.5)
		local fadeIn1 = CCFadeIn:create(0.5)
		local fadeIn2 = CCFadeIn:create(0)
		local fadeIn3 = CCFadeIn:create(0)

		local bezier3 = ccBezierConfig()
		bezier3.controlPoint_1 = ccp(-400,187)
		bezier3.controlPoint_2 = ccp(-36,187)
		bezier3.endPosition = ccp(-36,37)
		local bezierTo3 = CCBezierTo:create(0.5,bezier3)
		local newRotateBy3 = CCRotateBy:create(0.5,90)
		local easeSineIn3 = CCEaseSineIn:create(bezierTo3) 
		local spawn3 = CCSpawn:createWithTwoActions(newRotateBy3,easeSineIn3)
		local rotateToReset3 = CCRotateTo:create(0,-135)

		local bezier2 = ccBezierConfig()
		bezier2.controlPoint_1 = ccp(141,450)
		bezier2.controlPoint_2 = ccp(41,100)
		bezier2.endPosition = ccp(41,0)
		local bezierTo2 = CCBezierTo:create(0.5,bezier2)
		local newRotateBy2 = CCRotateBy:create(0.5,-40)
		local easeSineIn2 = CCEaseSineIn:create(bezierTo2)
		local spawn2 = CCSpawn:createWithTwoActions(newRotateBy2,easeSineIn2)
		local rotateToReset2 = CCRotateTo:create(0,70)

		local bezier1 = ccBezierConfig()
		--第三只箭

		--arrT:addObject(CCCallFunc:create(buttonLock))
		arrowThird:stopAllActions()
		arrowSecond:stopAllActions()
		arrowFirst:stopAllActions()

		arrT:addObject(CCCallFunc:create(function (  )
			arrowThird:setPosition(ccp(-400,37))
			--cclog('setPosition~~~~~~~~3-1')
		end))
		--新加动作  设置初始角度
		arrT:addObject(rotateToReset3)

		arrT:addObject(fadeIn3)
		arrT:addObject(spawn3)
		for i=1,3 do
			arrT:addObject(rotateBy1)
			arrT:addObject(rotateBy2)
		end
		arrT:addObject(fadeOut1)
		arrT:addObject(CCCallFunc:create(function (  )
			arrowThird:setPosition(ccp(-400,37))
			--cclog('setPosition~~~~~~~~3-2')
		end))
		arrowThird:runAction(CCRepeat:create(CCSequence:create(arrT),4))

		--第二只箭
		arrS:addObject(CCCallFunc:create(function (  )
			arrowSecond:setPosition(ccp(450,450))
			--cclog('setPosition~~~~~~~~2-1')
		end))
		arrS:addObject(rotateToReset2)
		arrS:addObject(fadeIn2)
		arrS:addObject(delayTime1)
		arrS:addObject(spawn2)
		for i=1,3 do
			arrS:addObject(rotateBy4)
			arrS:addObject(rotateBy3)
		end
		arrS:addObject(fadeOut2)
		arrS:addObject(CCCallFunc:create(function (  )
			arrowSecond:setPosition(ccp(450,450))
			--cclog('setPosition~~~~~~~~2-2')
		end))
		arrowSecond:runAction(CCRepeat:create(CCSequence:create(arrS),3))

		--第一只箭
		arrF:addObject(CCCallFunc:create(function (  )
			arrowFirst:setPosition(ccp(350,-350))
			--cclog('setPosition~~~~~~~~1-1')
		end))
		arrF:addObject(fadeIn1)
		arrF:addObject(delayTime2)
		arrF:addObject(moveToF)
		for i=1,3 do
			arrF:addObject(rotateBy5)
			arrF:addObject(rotateBy6)
		end
		arrF:addObject(fadeOut3)
		arrF:addObject(CCCallFunc:create(function (  )
			arrowFirst:setPosition(ccp(350,-350))
			--cclog('setPosition~~~~~~~~1-2')
		end))
		--arrF:addObject(CCDelayTime:create(1))
		--arrF:addObject(CCCallFunc:create(buttonOpen))
		arrowFirst:runAction(CCRepeat:create(CCSequence:create(arrF),3))


	end

	local function upDateScore(  )
		remainScore:setText(allTenScroe)  --兑换奖励后刷新积分

		--从服务器获取积分
	end

	local function boxAction(  )
		for i=1,#serverAwardMap do
			boxIcon[i][1]:stopAllActions()
		if allArrowNum >= tonumber(serverAwardMap[4].Id) then 
			if boxIcon[i][2] == 1 then  --临时标记已经领取
				markBoxIsActive = 1
				boxIcon[i][1]:setTexture('uires/ui_2nd/com/panel/active/box_2.png')
				boxIcon[i][1]:setTouchEnable(false)
				--cclog('boxIcon['..i..'][1]     :1-----------------------------1')
				--cclog("boxIcon["..i.."][2]=================="..boxIcon[i][2])
			else
				markBoxIsActive = 0
				local boxArr = CCArray:create()
				local boxRotateBy1 = CCRotateBy:create(0.1, 15)
				local boxRotateBy2 = CCRotateBy:create(0.1, -15)
				for t = 1 ,3 do
					boxArr:addObject(boxRotateBy1)
					boxArr:addObject(boxRotateBy1:reverse())
					boxArr:addObject(boxRotateBy2)
					boxArr:addObject(boxRotateBy2:reverse())
				end
				boxArr:addObject(CCDelayTime:create(1))
				boxIcon[i][1]:runAction(CCRepeatForever:create(CCSequence:create(boxArr)))
				boxIcon[i][1]:setTexture('uires/ui_2nd/com/panel/active/box_1.png')
				boxIcon[i][1]:setTouchEnable(true)
				boxIcon[i][1]:registerScriptTapHandler(function()
					--send打开箱子messagesend
					local args = { id = serverAwardMap[i]['Id']}
					Message.sendPost('get_borrow_arrow_server_award','activity',json.encode(args),function(jsonData)
						--cclog(jsonData)
						local jsonDic = json.decode(jsonData)
						if jsonDic.code ~= 0 then
							--cclog('severBox error~~~~~~~')
							return
						end
						local data = jsonDic.data
						local awards = data.awards
						local awardsData = json.encode(awards)
						UserData.parseAwardJson(awardsData)  
						boxIcon[i][1]:setTouchEnable(false)
						boxIcon[i][1]:stopAllActions()
						boxIcon[i][2] = 1
						boxIcon[i][1]:setTexture('uires/ui_2nd/com/panel/active/box_2.png')
						genShowTotalAwardsPanel(boxGift[i],'')
					end)
				end)
				--cclog('boxIcon['..i..'][1]     :1-----------------------------2')
				--cclog("boxIcon["..i.."][2]=================="..boxIcon[i][2])
			end
		else
			if tonumber(serverAwardMap[i].Id) > allArrowNum then 
				boxIcon[i][1]:setTexture('uires/ui_2nd/com/panel/active/box_1.png')
				boxIcon[i][1]:setTouchEnable(true)
				boxIcon[i][1]:registerScriptTapHandler(function (  )
					ShowTotalAwardsPanel(boxGift[i],getLocalStringValue('E_STR_MYSTICAL'))
				end)

				--cclog('boxIcon['..i..'][1]     :2-----------------------------1')
				--cclog("boxIcon["..i.."][2]=================="..boxIcon[i][2])
			elseif boxIcon[i][2] == 1 then  --临时标记已经领取
				markBoxIsActive = 1
				boxIcon[i][1]:setTexture('uires/ui_2nd/com/panel/active/box_2.png')
				boxIcon[i][1]:setTouchEnable(false)
				--cclog('boxIcon['..i..'][1]     :2-----------------------------2')
				--cclog("boxIcon["..i.."][2]=================="..boxIcon[i][2])
			else
				markBoxIsActive = 0
				--if allArrowNum >= tonumber(serverAwardMap[i].Id) and allArrowNum -10 < 
				local boxArr = CCArray:create()
				local boxRotateTo1 = CCRotateTo:create(0.1, 15)
				local boxRotateTo2 = CCRotateTo:create(0.1, -15)
				local boxRotateTo3 = CCRotateTo:create(0.1, 0)
				
					boxIcon[i][1]:setPosition(ccp(-10,-63))
					boxIcon[i][1]:setRotation(0)
				
				for t = 1 ,3 do
				boxArr:addObject(boxRotateTo1)
				boxArr:addObject(boxRotateTo2)
				boxArr:addObject(boxRotateTo1)
				boxArr:addObject(boxRotateTo2)
				end
				boxArr:addObject(boxRotateTo3)
				boxArr:addObject(CCDelayTime:create(1))
				boxIcon[i][1]:runAction(CCRepeatForever:create(CCSequence:create(boxArr)))
				boxIcon[i][1]:setTexture('uires/ui_2nd/com/panel/active/box_1.png')
				boxIcon[i][1]:setTouchEnable(true)
				boxIcon[i][1]:registerScriptTapHandler(function (  )
					--send打开箱子messagesend
					local args = { id = serverAwardMap[i]['Id']}
					Message.sendPost('get_borrow_arrow_server_award','activity',json.encode(args),function(jsonData)
						--cclog(jsonData)
						local jsonDic = json.decode(jsonData)
						if jsonDic.code ~= 0 then
							--cclog('severBox error~~~~~~~')
							return
						end
						local data = jsonDic.data
						local awards = data.awards
						local awardsData = json.encode(awards)
						UserData.parseAwardJson(awardsData)  
						boxIcon[i][1]:setTouchEnable(false)
						boxIcon[i][1]:stopAllActions()
						boxIcon[i][2] = 1
						boxIcon[i][1]:setTexture('uires/ui_2nd/com/panel/active/box_2.png')
						genShowTotalAwardsPanel(boxGift[i],'')							
					end)
				end)
				--cclog('boxIcon['..i..'][1]     :2-----------------------------3')
				--cclog("boxIcon["..i.."][2]=================="..boxIcon[i][2])
			end
		end
		end
	end

	local function boxState()  
		local borrowArrowNum = json.decode(borrowArrowData)
		
		for i = 1 , #serverAwardMap do
			--print('=========================')
			for k,v in pairs(borrowArrowNum.got) do
				--print('k~~~~~~~~~~~~~' .. k)
				for x = 1 , #serverAwardMap do 
					--cclog("serverAwardMap["..x.."]['Id']============" .. serverAwardMap[x]['Id'])
					if tonumber(k) == tonumber(serverAwardMap[x]['Id']) then 
						boxIcon[x][2] = 1
					end
				end
			end
		end
	end

	local function oneArrowState()

		local tempTimes = 1
		local tempScore = score
		local tempArrow = 1
		local arrowFreeLocal = tonumber(GameData:getGlobalValue('BorrowArrowDailyFreeCount'))
		local arrowFreeSever = tonumber(oneArrowFreeTimesInSever)
		local arrowFreeRemainTime = arrowFreeLocal - arrowFreeSever
		tempOneArrowTimes = arrowFreeRemainTime
		oneArrowRemainTimes:setText(tostring(arrowFreeRemainTime))
		oneArrowResetTimesCD:registerTimeoutHandler(function ()
			oneArrowRemainTimes:setVisible(true)
			oneArrowResetTimes:setVisible(false)
			--oneArrowResetTimesCD:setTime( 0 )
			oneArrowResetBtn:setVisible(false)
		end)
		oneArrowResetBtn:registerScriptTapHandler(function ()
			--向服务器发请求，扣除服务器中所配的元宝   目前存在问题，点击reset后单发箭数不增加了
			markPost = 1
			GameController.showMessageBox(string.format(getLocalString('E_STR_BORROWARROW_RESET'),tonumber(GameData:getGlobalValue('BorrowArrowCDCashCost'))), MESSAGE_BOX_TYPE.OK_CANCEL,function ()
				
				--cclog('markPost===========reset========='..markPost)
				Message.sendPost('clear_cd_borrow_arrow','activity','{}',function (jsonData)
					--cclog('i am on my way~~~~~~~~~~~~~waitting')
					cclog(jsonData)
					local jsonDic = json.decode(jsonData)
					if jsonDic.code ~= 0 then
						--cclog('oneArrow error~~~~~~~:'.. jsonDic.desc)
						GameController.showPrompts(getLocalString('E_STR_CASH_NOT_ENOUGH'),COLOR_TYPE.RED)
						return
					end
					--扣除元宝
					PlayerCoreData.addCashDelta(-tonumber(GameData:getGlobalValue('BorrowArrowCDCashCost')))
					cashNum:setText(toWordsNumber(PlayerCoreData.getCashValue()))
					oneArrowRemainTimes:setVisible(true)
					oneArrowResetTimes:setVisible(false)
					oneArrowResetTimesCD:setTime( 0 )
					oneArrowResetBtn:setVisible(false)
					oneArrowBtn:active()
				end)
			end)
		end)
		oneArrowBtn:registerScriptTapHandler(function ()
			--向服务器发单发请求

			local argsOne = {type = 1}
			Message.sendPost('shot_borrow_arrow','activity',json.encode(argsOne),function (jsonData)
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic.code ~= 0 then
					--cclog('oneArrow error~~~~~~~:'.. jsonDic.desc)
					timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
					if timeDiff < 0 then 
						GameController.showPrompts(getLocalString('E_STR_GET_GOD_ROLE_FALIUE'),COLOR_TYPE.RED)
					end
					return
				end
				local data = jsonDic.data
				local personArrowCount = tonumber(jsonDic.args.arrow_count)

				--获得积分
				oneArrowRemainTimes:setVisible(false)
				
				--剩余免费次数
				tempOneArrowTimes = arrowFreeRemainTime - tempTimes
				if tempOneArrowTimes <= 0 then
					oneArrowRemainTimes:setText(tostring(tempOneArrowTimes))
					oneArrowRemainTimes:setVisible(true)
					oneArrowResetTimes:setVisible(false)
					oneArrowResetTimesCD:setTime(0)
					oneArrowResetBtn:setVisible(false)
					oneArrowBtn:disable()
				elseif tempOneArrowTimes > 0 then
					oneArrowRemainTimes:setText(tostring(tempOneArrowTimes))
					oneArrowRemainTimes:setVisible(false)
					tempTimes = tempTimes + 1 
					oneArrowResetTimes:setVisible(true)
					oneArrowResetTimesCD:setTime(GameData:getGlobalValue('BorrowArrowOneShotIntervalTime'))
					--oneArrowResetTimesCD:setTime(tonumber(GameData:getGlobalValue('BorrowArrowOneShotIntervalTime')))  --加上服务器的时间搓
					oneArrowResetBtn:setVisible(true)
					oneArrowBtn:disable()
				end

				--积分增加 allTenScroe

				local tempAddScore = jsonDic['data']['score']
				--cclog('allTenScroe~~~~~~~~~~'..allTenScroe)
				--cclog('tempAddScore~~~~~~~~~~'..tempAddScore)
				scoreNum:setText(tostring(tonumber(allTenScroe) + tonumber(tempAddScore)))
				allTenScroe = allTenScroe + tempAddScore


				--箭数增加   allArrowNum
				
				personalArrowsNum:setText(tostring(personArrowCount))
				serverArrowsNum:setText(jsonDic['data']['total_arrow'])
				--serverArrowsNum:setText(tostring(tonumber(allArrowNum) + tempArrow))
				--allArrowNum = tonumber(allArrowNum) +  tempArrow

				--总箭数增加到开箱子水平，刷新Update，即使领取箱子
				-- for i = 1 ,#serverAwardMap do
				-- 	if tonumber(jsonDic['data']['total_arrow']) >= tonumber(serverAwardMap[i]['Id']) and (tonumber(jsonDic['data']['total_arrow']) - 1) < tonumber(serverAwardMap[i]['Id']) and boxIcon[i][2] == 0 then
				-- 		update()
				-- 	end
				-- end

				--暴击
				--cclog("jsonDic['args']['message']==============1==" .. jsonDic['args']['message'])
				if tonumber(jsonDic['args']['message']) == 1 then 
					--cclog("jsonDic['args']['message']==============2==" .. jsonDic['args']['message'])
					GameController.showPrompts(string.format(getLocalString("E_STR_GOT_CRIT_SCORE"),tonumber(data['score'])) , COLOR_TYPE.ORANGE)
				else
					GameController.showPrompts(string.format(getLocalString("E_STR_GOT_SCORE"),tonumber(data['score'])) , COLOR_TYPE.GREEN)
				end

				-- if data.rank ~= 0 then
				-- 	update()
				-- end
				arrowActionNormal()

				--update()

				boxAction()

				--cclog('oneArrowBtn~~~~~~~~~~~~~~~~~: end')
			end)

		end)

			--cclog('arrowFreeRemainTime~~~~~~~~~~~~~:'.. arrowFreeRemainTime)
			--cclog('serverTime - updateTime~~~~~~~~~~~~'..(serverTime - updateTime))
		if tempOneArrowTimes <= 0 then
			oneArrowBtn:disable()
			oneArrowRemainTimes:setVisible(true)
			oneArrowResetTimes:setVisible(false)
			oneArrowResetTimesCD:setTime(0)
			oneArrowResetBtn:setVisible(false)
			--cclog('onearrow: 1---------------------1')
		else
			if updateTime == 0 then
				oneArrowRemainTimes:setVisible(true)
				oneArrowResetTimes:setVisible(false)
				oneArrowResetTimesCD:setTime(0)
				oneArrowResetBtn:setVisible(false)
				oneArrowBtn:active()
				--cclog('onearrow: 2---------------------1')
			else
				if  ( serverTime - updateTime) >= tonumber(GameData:getGlobalValue('BorrowArrowOneShotIntervalTime'))  then
					oneArrowRemainTimes:setVisible(true)
					oneArrowResetTimes:setVisible(false)
					oneArrowResetTimesCD:setTime(0)
					oneArrowResetBtn:setVisible(false)
					oneArrowBtn:active()
					--cclog('onearrow: 2---------------------1--1')
				else
					oneArrowRemainTimes:setVisible(false)
					oneArrowResetTimes:setVisible(true)
					oneArrowResetTimesCD:setTime(0)
					oneArrowResetTimesCD:setTime(updateTime - serverTime + tonumber(GameData:getGlobalValue('BorrowArrowOneShotIntervalTime')))
					oneArrowResetBtn:setVisible(true)
					oneArrowBtn:disable()
				end
			end
		end
	end


	local function  update()

		--个人箭数
		local personalArrows = tolua.cast(root:getChildByName('info_2_bg'),'UIImageView')
		personalArrowsNum = tolua.cast(personalArrows:getChildByName('time_tx'),'UILabel')

		local rankBg = tolua.cast(root:getChildByName('info_3_bg'),'UIImageView')
		rankNum = tolua.cast(rankBg:getChildByName('rank_num'),'UILabel')
		rankMing = tolua.cast(rankBg:getChildByName('ming_tx2'),'UILabel')
		rankDi = tolua.cast(rankBg:getChildByName('di_tx'),'UILabel')
		--个人名次设置为服务器返回的数值

		--元宝总量
		cashNum:setText(toWordsNumber(PlayerCoreData.getCashValue()))
		
		for i = 1 , 5 do
			rank[i] = tolua.cast(root:getChildByName('rank'..i..'_tx'),'UILabel')
		end


		serverArrowsNum = tolua.cast(root:getChildByName('allarrow_num'),'UILabel')
		--服务器总箭数


		oneArrowResetBtn = tolua.cast(root:getChildByName('reset_btn'), 'UIButton')
		GameController.addButtonSound(oneArrowResetBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		--oneArrowState()

		tenArrowsCost = tolua.cast(root:getChildByName('cash_cost'),'UILabel')
		--十连发消耗

		scoreNum = tolua.cast(root:getChildByName('score_tx'),'UILabel')
		--积分总数

		--服务器发送消息标记

			Message.sendPost('get_borrow_arrow','activity','{}',function (jsonData)
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic.code ~= 0 then
					--cclog('oneArrow error~~~~~~~:'.. jsonDic.desc)
					return
				end
				local data = jsonDic.data
				local borrowArrow = data.borrow_arrow
				borrowArrowData = json.encode(borrowArrow)  --4个箱子需要引用  一箭单发要用
				rankData = data.rank
				rankDataEncode = json.encode(rankData)   --排名要用
				oneArrowFreeTimesInSever = borrowArrow.one
				score = borrowArrow.score
				allArrowNum = data.total_arrow
				updateTime = tonumber(borrowArrow.update)
				serverTime = tonumber(jsonDic.serverTime)

				scoreNum:setText(score)  
				personalArrowsNum:setText(borrowArrow.arrow)
				serverArrowsNum:setText(data.total_arrow)

				--主界面rank名字
				local tempRank = 5
				if tonumber(#data.rank) < 5 then
					tempRank = tonumber(#data.rank)
				end
				for i = 1 , tempRank do
					rank[i]:setText(data.rank[i]['name'])
				end

				--十箭连发初始消耗金额
				local tempTenAC = tonumber(borrowArrow['ten']) + 1
				--cclog('#tenArrowCostMap==========' .. (#tenArrowCostMap))
				if (tonumber(borrowArrow['ten']) + 1) > (#tenArrowCostMap ) then
					tempTenAC = (#tenArrowCostMap )
				end
				tenAC = tempTenAC
				--cclog('tenAC================='..tenAC)
				--cclog("tenArrowCostMap[tostring(tenAC)]['Cash']=========="..tenArrowCostMap[tenAC]['Cash'])
				tenArrowsCost:setText(tostring(tenArrowCostMap[tenAC]['Cash']))

				--十连发积分累计
				allTenScroe = score

				--获取排名
				local rankX = 0
				for i = 1 , #rankData do 
				--	cclog(rankData[i]['name'])
				--	cclog(PlayerCoreData.getPlayerName())
					if PlayerCoreData.getPlayerName() == rankData[i]['name'] then
						rankNum:setText(tostring(i))
						rankMing:setVisible(true)
						rankDi:setVisible(true)
						rankX = 1
					end
				end	
				if rankX == 0 then
					rankNum:setText(getLocalString('E_STR_WELFARE_NORANK'))	
					rankMing:setVisible(false)
					rankDi:setVisible(false)
				end

				--4个箱子状态
				for i = 1 , 4 do
					boxIcon[i] = {}
					boxNum[i] = tolua.cast(root:getChildByName('box'..i..'_num'),'UILabel')
					boxIcon[i][1] = tolua.cast(boxNum[i]:getChildByName('box'..i..'_img'),'UIImageView')
					boxIcon[i][2] = 0  --临时标记，0为未领取,从服务器获取
					--cclog('serverAwardMap2============'..serverAwardMap2)
					-- cclog("serverAwardMap["..i.."]['Id']=========="..serverAwardMap[i]['Id'])
					boxNum[i]:setText(serverAwardMap[i]['Id'])
					boxGift[i] = {serverAwardMap[i]['Award1'],serverAwardMap[i]['Award2'],serverAwardMap[i]['Award3'],serverAwardMap[i]['Award4']}
				end


				boxState()
				boxAction()

				oneArrowState()

			end)
	end

	local function onShow()



		--cclog('markPost===========1========='..markPost)
		if markPost == 1 then
			--cclog('markPost=============2============='..markPost)
			return
		else
		Message.sendPost('get_borrow_arrow','activity','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic.code ~= 0 then
				--cclog('oneArrow error~~~~~~~:'.. jsonDic.desc)
				return
			end
			local data = jsonDic.data
			local borrowArrow = data.borrow_arrow
			borrowArrowData = json.encode(borrowArrow)  --4个箱子需要引用
			oneArrowFreeTimesInSever = borrowArrow.one
			score = borrowArrow.score
			allArrowNum = data.total_arrow
			rankData = data.rank
			rankDataEncode = json.encode(rankData)
			updateTime = tonumber(borrowArrow.update)
			serverTime = tonumber(jsonDic.serverTime)

			scoreNum:setText(score)  
			personalArrowsNum:setText(borrowArrow.arrow)
			serverArrowsNum:setText(data.total_arrow)

			--主界面rank名字
			local tempRank = 5
			if tonumber(#data.rank) < 5 then
				tempRank = tonumber(#data.rank)
			end
			for i = 1 , tempRank do
				rank[i]:setText(data.rank[i]['name'])
			end

			--十箭连发初始消耗金额
			local tempTenAC = tonumber(borrowArrow['ten']) + 1
			--cclog('#tenArrowCostMap==========' .. (#tenArrowCostMap))
			if (tonumber(borrowArrow['ten']) + 1) > (#tenArrowCostMap) then
				tempTenAC = (#tenArrowCostMap)
			end
			tenAC = tempTenAC
			--cclog('tenAC================='..tenAC)
			--cclog("tenArrowCostMap[tostring(tenAC)]['Cash']=========="..tenArrowCostMap[tenAC]['Cash'])
			tenArrowsCost:setText(tostring(tenArrowCostMap[tenAC]['Cash']))

			--十连发积分累计
			allTenScroe = score

			--获取排名
			local rankX = 0
			for i = 1 , #rankData do 
				--cclog(rankData[i]['name'])
				--cclog(PlayerCoreData.getPlayerName())
				if PlayerCoreData.getPlayerName() == rankData[i]['name'] then
					rankNum:setText(tostring(i))
					rankMing:setVisible(true)
					rankDi:setVisible(true)
					rankX = 1
				end
			end	
			if rankX == 0 then
				rankNum:setText(getLocalString('E_STR_WELFARE_NORANK'))	
				rankMing:setVisible(false)
				rankDi:setVisible(false)
			end


			oneArrowState()

		end)
		end
	end

	local function onHide()

	end

	local function showRank()
		markPost = 0
		local pCard
		local pPage
		local rankSv
		local genBtn

		local function getRank()
			for i,v in ipairs(rankData) do
				if tonumber(PlayerCoreData.getUID()) == tonumber(v.uid) then
					cclog(i)
					return i
				end
			end
			return nil
		end

		local function genBtnState()

			timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
			if timeDiff > 0 then
				genBtn:setNormalButtonGray(true)
				genBtn:setTouchEnable(false)
				genBtn:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
				return
			end

			local rankDataDecode = json.decode(rankDataEncode)

			if getRank() and tonumber(rankDataDecode[tonumber(getRank())]['got']) == 0 then
				genBtn:setNormalButtonGray(false)
				genBtn:setTouchEnable(true)
				genBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
			elseif getRank() and rankDataDecode[tonumber(getRank())]['got'] == 1 then
				genBtn:setNormalButtonGray(true)
				genBtn:setTouchEnable(false)
				genBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			else
				genBtn:setNormalButtonGray(true)
				genBtn:setTouchEnable(false)
				genBtn:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
			end
			genBtn:registerScriptTapHandler(function ()
				Message.sendPost('get_borrow_arrow_rank_award','activity','{}',function(jsonData)
					cclog(jsonData)
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
		end

		local sceneObjRank = SceneObjEx:createObj('panel/borrowarrow_rank_main.json','borrowarrow-rank-in-lua')
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

			rankSv = tolua.cast(rootRank:getChildByName('card_sv'),'UIScrollView')
			--rankSv:removeAllChildrenAndCleanUp(true)
			rankSv:setClippingEnable(true)
			rankSv:setDirection(SCROLLVIEW_DIR_VERTICAL)
		end)

		UiMan.show(sceneObjRank)


		local function getPCard( )

			for i = 1 , 10 do
				pCard = createWidgetByName('panel/borrowarrow_rank_panelin.json')
				if not pCard then
					print('failed to create borrowarrow_rank_panelin!!!!!')
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

					local rankName = {}
					rankName[i] = tolua.cast(pCard:getChildByName('name_tx'),'UILabel')
					local rankDataDecode = json.decode(rankDataEncode)
					--for i = 1 , #rankDataDecode do
					if i <= #rankDataDecode then
						rankName[i]:setText(rankDataDecode[i]['name'])
					else
						rankName[i]:setText(getLocalString('E_STR_WELFARE_NORANK1'))
					end


					--从表里读取奖励，放到card里，表中需要Id列
					local awards = {}
					local awardsConf = GameData:getArrayData('avborrowarrowrankaward.dat')
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
		markPost = 0
		local sceneObjHelp = SceneObjEx:createObj('panel/borrowarrow_help.json','borrowarrowhelp-in-lua')
		local panelHelp = sceneObjHelp:getPanelObj()
		panelHelp:setAdaptInfo('recharge_help_bg_img','help_img')

		panelHelp:registerInitHandler(function ()
			local rootHelp = panelHelp:GetRawPanel()

			local closeBtn = tolua.cast(rootHelp:getChildByName('close_btn'), 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObjHelp))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			local knowBtn = tolua.cast(rootHelp:getChildByName('ok_btn'),'UIButton')
			knowBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObjHelp))
			GameController.addButtonSound(knowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		end)
		UiMan.show(sceneObjHelp)
	end

	-- local function clickOneArrowBtn(  )

	-- end



	local function clickTenArrowsBtn(  )
		local argsOne = {type = 10}
		Message.sendPost('shot_borrow_arrow','activity',json.encode(argsOne),function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic.code ~= 0 then
				--cclog('oneArrow error~~~~~~~:'.. jsonDic.desc)
				timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
				if timeDiff < 0 then 
					GameController.showPrompts(getLocalString('E_STR_GET_GOD_ROLE_FALIUE'),COLOR_TYPE.RED)
				end
				return
			end
			local data = jsonDic.data
			local args = jsonDic.args
			--cclog("data['cash']================"..data['cash'])
			--cclog('tenAC================='..tenAC)
			PlayerCoreData.addCashDelta(tonumber(data['cash']))

			--元宝增加
			tenAC = tenAC + 1
			local tempTenAC = tenAC
			if tenAC > (#tenArrowCostMap ) then
				tempTenAC = (#tenArrowCostMap)
			end
			cclog('tempTenAC==============='..tempTenAC)
			tenArrowsCost:setText(tostring(tenArrowCostMap[tempTenAC]['Cash']))

			--积分增加
			local tempScore = tonumber(data['score'])
			--local allTenScroe = score
			--cclog('allTenScroe=============' ..allTenScroe)
			--cclog('tempScore=============' ..tempScore)
			--cclog("(tonumber(score)+tonumber(data['score']))============" ..(tonumber(allTenScroe)+tempScore))
			scoreNum:setText(tostring(tonumber(allTenScroe)+tempScore))
			allTenScroe = tonumber(allTenScroe) + tempScore

			--箭数增加
			local tempArrow = tonumber(args.type)  --10支箭
			personalArrowsNum:setText(args.arrow_count)
			serverArrowsNum:setText(jsonDic['data']['total_arrow'])
			--serverArrowsNum:setText(tostring(tempArrow + tonumber(allArrowNum)))
			--allArrowNum = tonumber(allArrowNum) + tempArrow

			--总箭数增加到开箱子水平，刷新Update，即使领取箱子
			-- for i = 1 ,#serverAwardMap do
			-- 	if tonumber(jsonDic['data']['total_arrow']) >= tonumber(serverAwardMap[i]['Id']) and (tonumber(jsonDic['data']['total_arrow']) - 10) < tonumber(serverAwardMap[i]['Id']) and boxIcon[i][2] == 0 then
			-- 		update()
			-- 	end
			-- end


			--暴击
			-- cclog("jsonDic['args']['message']==============1==" .. jsonDic['args']['message'])
			if tonumber(jsonDic['args']['message']) == 1 then 
				--cclog("jsonDic['args']['message']==============2==" .. jsonDic['args']['message'])
				GameController.showPrompts(string.format(getLocalString("E_STR_GOT_CRIT_SCORE"),tonumber(data['score'])) , COLOR_TYPE.ORANGE)
			else
				GameController.showPrompts(string.format(getLocalString("E_STR_GOT_SCORE"),tonumber(data['score'])) , COLOR_TYPE.GREEN)
			end

			arrowAction()


			update()
			

			boxAction()
		end)
	end

	local function clickExchangeBtn(  )
		markPost = 0
		local pPage
		local pCard
		local exchangeItemConf = GameData:getArrayData('avborrowarrowexchange.dat')  --获取兑换奖励物品序列表
		local MatExchangeObj

		--local shopId
		local cardId
		local Limit = readOnly{
			MAX_COUNT = 99
		}
		--local hasNum

		local function getExchangeCount() --获取兑换列表总个数
			local count
			if not count then 
				local exchangeConf = GameData:getMapData('avborrowarrowexchange.dat')
				local num = 0 
				for k, v in pairs(exchangeConf) do 
					num = num + 1
				end 
				count = num
			end
			return count
		end

		local function onShow(  )
			upDateScore()  --显示积分兑换后的变化
		end

		----------------------------------
		--UI
		-----------------------------------
		-- title
		local titleIco
		local titleMoneyIcon
		local titleMoneyTx
		-- left side
		local nameTx
		local nameBgImg
		local itemIco
		local hasTx
		local descTx
		-- right side
		local numEditBox
		local leftBtn
		local rightBtn
		local currMoneyTx
		local currMoneyIcon
		local confirmBtn
		----------------------------------
		--DATA
		-----------------------------------
		local shopId
		local panelType
		local bSData
		local buyCallBackFn			--购买回调
		--local totalMoney
		local hasNum
		local price					--单价
		local maxCount  			--最大数量

		local function upDateScore(  )
	
			titleMoneyTx:setText(allTenScroe)  --兑换奖励后刷新积分

		end

		local function updateConfirmBtn()
			local num = numEditBox:getTextFromInt()
			if num < 1 then
				confirmBtn:disable()
			else
				confirmBtn:active()
			end
		end

		local function updateBtnStatus()
			local num = numEditBox:getTextFromInt()
			if num <= 1 then
				leftBtn:disable()
				-- if hasNum <= 1 then 
				-- 	rightBtn:disable() 
				-- end
			else
				leftBtn:active()
			end

			--if panelType == BUY_PANEL_TYPE.BUY or panelType == BUY_PANEL_TYPE.PAWN_EXCHANGE or panelType == BUY_PANEL_TYPE.SCORE_SHOP or panelType == BUY_PANEL_TYPE.LEGION_EXCHANGE or panelType == BUY_PANEL_TYPE.TOKEN_EXCHANGE then
				if num >= Limit.MAX_COUNT or num >= math.floor(allTenScroe / price) then
					rightBtn:disable()
				else
					rightBtn:active()
				end
			-- else
			-- 	if num >= hasNum or num >= Limit.MAX_COUNT then
			-- 		rightBtn:disable()
			-- 	else
			-- 		rightBtn:active()
			-- 	end
			-- end
		end

		-- 初始化购买界面
		local function initConfirmBuyPanel()
		    local sceneObj = SceneObjEx:createObj('panel/confirm_buy_panel_small.json', 'confirm-buy-lua')
		    local panel = sceneObj:getPanelObj()
		    panel:setAdaptInfo('zhegai_bg_img', 'buy_bg_img')

		    local function updateNumbers()
				local ct = numEditBox:getTextFromInt()
				if ct < 0 then 
					return 
				end
				currMoneyTx:setTextFromInt( ct * price )

				updateConfirmBtn()
			end

			local function onLongPressLeftBtn()
				CNumEditorAct:getInst():numDec(leftBtn,numEditBox,rightBtn,1)
				CNumEditorAct:getInst():registerScriptNumDecHandler( updateNumbers )
			end

			local function onLongPressRightBtn()
				local num = 0
				-- if panelType == BUY_PANEL_TYPE.BUY or panelType == BUY_PANEL_TYPE.SCORE_SHOP 
				-- 	or panelType == BUY_PANEL_TYPE.PAWN_EXCHANGE or panelType == BUY_PANEL_TYPE.LEGION_EXCHANGE 
				-- 	or panelType == BUY_PANEL_TYPE.TOKEN_EXCHANGE then
					if math.floor(allTenScroe / price) <= Limit.MAX_COUNT then
						num = math.floor(allTenScroe / price)
					else
						num = Limit.MAX_COUNT
					end
				-- else 
				-- 	num = hasNum < Limit.MAX_COUNT and hasNum or Limit.MAX_COUNT
				-- end
				CNumEditorAct:getInst():numAdd(leftBtn,numEditBox,rightBtn,num)
				CNumEditorAct:getInst():registerScriptNumAddHandler( updateNumbers )
			end

			local function onLongPressBtnCancelled()
				CNumEditorAct:getInst():stop()
			end

		    local function onClickLeftBtn()
				CNumEditorAct:getInst():numDecOnce(leftBtn, numEditBox, rightBtn, 0)
				updateNumbers()
			end

			local function onClickRightBtn()
				local num = 0
				-- if panelType == BUY_PANEL_TYPE.BUY or panelType == BUY_PANEL_TYPE.PAWN_EXCHANGE 
				-- 	or panelType == BUY_PANEL_TYPE.SCORE_SHOP or panelType == BUY_PANEL_TYPE.LEGION_EXCHANGE 
				-- 	or panelType == BUY_PANEL_TYPE.TOKEN_EXCHANGE then
					if math.floor(allTenScroe / price) <= Limit.MAX_COUNT then
						num = math.floor(allTenScroe / price)
					else
						num = Limit.MAX_COUNT
					end
				-- else
				-- 	num = hasNum < Limit.MAX_COUNT and hasNum or Limit.MAX_COUNT
				-- end
				CNumEditorAct:getInst():numAddOnce(leftBtn, numEditBox, rightBtn, num)
				updateNumbers()
			end

			local function onClickBuyBtn()
				-- if not buyCallBackFn then
				-- 	return
				-- end


				local ct = numEditBox:getTextFromInt()
				-- if panelType == BUY_PANEL_TYPE.BUY or panelType == BUY_PANEL_TYPE.SCORE_SHOP or panelType == BUY_PANEL_TYPE.PAWN_EXCHANGE or panelType == BUY_PANEL_TYPE.TOKEN_EXCHANGE then
				-- 	buyCallBackFn( shopId , ct )
				-- end

				-- if panelType == BUY_PANEL_TYPE.LEGION_DONATE or panelType == BUY_PANEL_TYPE.LEGION_EXCHANGE then
				-- 	buyCallBackFn( shopId , ct )
				-- end
				if (allTenScroe - ct*price) < 0 then 
					GameController.showPrompts( getLocalStringValue('E_STR_CARD_MASTER_NOT_ENOUGH_SCORE'),COLOR_TYPE.RED )
					return
				else
					local args = { id = cardId, num = ct,}
					cclog('num~~~~~~~~~~~~~~~~~~~:'..args.num)
					cclog('cardId~~~~~~~~~~~~~~~~~~~:'..args.id)
					Message.sendPost('borrow_arrow_score_exchange', 'activity', json.encode(args), function (jsonData)
			        	print(jsonData)
				        local jsonDic = json.decode(jsonData)
				        if jsonDic['code'] ~= 0 then
				            --cclog('request error : ' .. jsonDic['desc'])
				            return
				        end

				        local data = jsonDic['data']
				        if not data then return end

				        local awards = data['awards']
				        local awardStr = json.encode(awards)
				        UserData.parseAwardJson(awardStr)

				        GameController.showPrompts( getLocalStringValue('E_STR_EXCHANGE_SUCCEED'),COLOR_TYPE.GREEN )

				       	allTenScroe =  allTenScroe - ct * price

				       	upDateScore()
			        end)
	            end

				CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
			end

		    local function editBoxEventHandler( eventType )
				--if eventType == 'ended' then
					local num = numEditBox:getTextFromInt()
					if num <= 0 then
						num = 0
					else
						-- if panelType == BUY_PANEL_TYPE.BUY or panelType == BUY_PANEL_TYPE.PAWN_EXCHANGE 
						-- 	or panelType == BUY_PANEL_TYPE.SCORE_SHOP or panelType == BUY_PANEL_TYPE.LEGION_EXCHANGE 
						-- 	or panelType == BUY_PANEL_TYPE.TOKEN_EXCHANGE then
							if num > Limit.MAX_COUNT then
								num = Limit.MAX_COUNT
							end
							if num > math.floor(allTenScroe / price) then
								num = math.floor(allTenScroe / price)
							end
						-- else 
						-- 	if num > Limit.MAX_COUNT then
						-- 		num = Limit.MAX_COUNT
						-- 	end
						-- 	if num > hasNum then
						-- 		num = hasNum
						-- 	end
						-- end
					end
					numEditBox:setTextFromInt(num)
					updateNumbers()
					updateBtnStatus()
				--end
			end

		    panel:registerInitHandler(function()
		        local root = panel:GetRawPanel()
		        local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		        closeBtn:registerScriptTapHandler(function ()
		        	CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		        end)
		        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		        local background = tolua.cast(root:getChildByName('zhegai_bg_img'), 'UIImageView')
		        background:registerScriptTapHandler(function ()
		        	CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		        end)
		        --Init title.
		        titleIco = tolua.cast(root:getChildByName('buy_title_tx') , 'UILabel')
		        titleMoneyIcon = tolua.cast(root:getChildByName('honor_ico') , 'UIImageView')
		        titleMoneyTx = tolua.cast(root:getChildByName('honor_num_tx') , 'UILabel')

		        --Init left side.
		        local contentImg = root:getChildByName('buy_img')
		        nameTx = tolua.cast(contentImg:getChildByName('name_tx') , 'UILabel')
		        nameBgImg = tolua.cast(contentImg:getChildByName('name_bg_ico') , 'UIImageView')
		        itemIco = tolua.cast(contentImg:getChildByName('material_ico') , 'UIImageView')
		        hasTx = tolua.cast(contentImg:getChildByName('own_tx') , 'UILabel')
		        descTx = tolua.cast(contentImg:getChildByName('info_tx') , 'UITextArea')

		        --Init right side.

		        -- local honorPl = tolua.cast(contentImg:getChildByName('honor_pl') , 'UIPanel')
		        -- local prestigePl = tolua.cast(contentImg:getChildByName('prestige_pl') , 'UIPanel')
		        -- honorPl:setVisible(true)
		        -- prestigePl:setVisible(false)
		        -- local editBoxBg = tolua.cast(honorPl:getChildByName('number_bg_ico') , 'UIImageView')

		        local editBoxBg = tolua.cast(root:getChildByName('number_bg_ico') , 'UIImageView')

		        numEditBox = tolua.cast(UISvr:replaceUIImageViewByCCEditBox(editBoxBg) , 'CCEditBox')
				numEditBox:setHAlignment(kCCTextAlignmentCenter)
				numEditBox:setInputMode(kEditBoxInputModeDecimal)
				numEditBox:setFontSize(42)
				numEditBox:registerScriptEditBoxHandler( editBoxEventHandler )

				-- leftBtn = tolua.cast(honorPl:getChildByName('left_page_btn') , 'UITextButton')
				-- rightBtn = tolua.cast(honorPl:getChildByName('right_page_btn') , 'UITextButton')
				-- currMoneyTx = tolua.cast(honorPl:getChildByName('need_honor_num_tx') , 'UILabel')
				-- currMoneyIcon = tolua.cast(honorPl:getChildByName('need_honor_ico') , 'UIImageView')

				leftBtn = tolua.cast(root:getChildByName('left_page_btn') , 'UITextButton')
				rightBtn = tolua.cast(root:getChildByName('right_page_btn') , 'UITextButton')
				currMoneyTx = tolua.cast(root:getChildByName('need_honor_num_tx') , 'UILabel')
				currMoneyIcon = tolua.cast(root:getChildByName('need_honor_ico') , 'UIImageView')

				confirmBtn = tolua.cast(contentImg:getChildByName('buy_btn') , 'UITextButton')

				leftBtn:registerScriptTapHandler( onClickLeftBtn )
				leftBtn:registerScriptLongPressHandler( onLongPressLeftBtn )
				leftBtn:registerScriptLongPressEndHandler( onLongPressBtnCancelled )
				rightBtn:registerScriptTapHandler( onClickRightBtn )
				rightBtn:registerScriptLongPressHandler( onLongPressRightBtn )
				rightBtn:registerScriptLongPressEndHandler( onLongPressBtnCancelled )
				confirmBtn:registerScriptTapHandler( onClickBuyBtn )
				GameController.addButtonSound(leftBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
				GameController.addButtonSound(rightBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
				GameController.addButtonSound(confirmBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
				

				--numEditBox:setTextFromInt(1)
				descTx:setText(PlayerCoreData.getMaterialDesc(shopId))
				nameTx:setText(PlayerCoreData.getMaterialName(shopId))
				nameTx:setColor(PlayerCoreData.getMaterialColor(shopId))
				itemIco:setTexture(PlayerCoreData.getMaterialIco(shopId))
				hasNum = PlayerCoreData.getMaterialCount(shopId)
				hasTx:setText(string.format(getLocalString('E_STR_BS_CONFIRM_HAS_NUM_STR') , toWordsNumber(hasNum)))
				price = tonumber(exchangeItemConf[tonumber(cardId)]['Score'])
				titleMoneyTx:setText(allTenScroe)
				titleMoneyIcon:setTexture('uires/ui_2nd/com/panel/borrowarrow/score_icon.png')
				currMoneyIcon:setTexture('uires/ui_2nd/com/panel/borrowarrow/score_icon.png')
				confirmBtn:setText(getLocalString('E_STR_BAG_SHOP_EXCHANGE_STR'))
				if tonumber(price) > tonumber(allTenScroe) then
					numEditBox:setTextFromInt(0)
					leftBtn:disable()
					rightBtn:disable()
				else
					numEditBox:setTextFromInt(1)
				end


				updateNumbers()
				upDateScore()
		    end)
			

		    CUIManager:GetInstance():ShowObject(sceneObj, ELF_SHOW.ZOOM_IN)
		end


		local function onClickCardExchange(i, id, count)
			shopId = id
			cardId = i
			initConfirmBuyPanel()
		end

		local function getPCard()
			--cclog('setPosition pre')
			pPage = UIContainerWidget:create()
			pPage:setWidgetZOrder(9)
			pPage:setAnchorPoint(ccp(0.5,0.5))
			pPage:setPosition(ccp(850/2 , 530/2))
			--cclog('setPosition aft')

			for i = 1 , tonumber(getExchangeCount()) do
				pCard = createWidgetByName('panel/borrowarrow_exchange_panelin.json')
				if not pCard then
					print('failed to create borrowarrow_exchange_panelin!!!!!')
				else
					local scoreCostTx = tolua.cast(pCard:getChildByName('score_cost_num'),'UILabel')
					scoreCostTx:setText(tostring(exchangeItemConf[i].Score))   --Score名字待定（兑换所需要的分数）
					local itemName = tolua.cast(pCard:getChildByName('item_name'),'UILabel')
					local itemIcon = tolua.cast(pCard:getChildByName('item_icon_img'),'UIImageView')
					local itemNum = tolua.cast(pCard:getChildByName('item_num_tx'),'UILabel')
					local exchangeBtn = tolua.cast(pCard:getChildByName('exchange_btn'),'UITextButton')
					GameController.addButtonSound(exchangeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
					local itemFrame = tolua.cast(pCard:getChildByName('item_frame_img'),'UIImageView')


					--从表里读取兑换物品，放到card里，表中需要Id列
					local item
					local itemTmp = {}
					for _,v in pairs(exchangeItemConf) do 
						if tonumber(v['Id']) == tonumber(i) then  --Id名字待定
							item = v['Award1']  --Award1 名字待定
							itemTmp = UserData:getAward(item)
							itemName:setText(tostring(itemTmp.name))
							itemName:setColor(itemTmp.color)
							itemIcon:setTexture(itemTmp.icon)
							itemNum:setText(tostring(itemTmp.count))
							itemFrame:registerScriptTapHandler(function (  )
								UISvr:showTipsForAward(item)
							end)

							exchangeBtn:registerScriptTapHandler(function (  )
								onClickCardExchange(i , itemTmp.id , itemTmp.count)
							end)
						end
					end
					pCard:setPosition(ccp( -400*(i%2), 530/2-175*(i+i%2)/2 ))
					pCard:setAnchorPoint(ccp(0.5,0.5))
					pPage:addChild(pCard)
				end
			end
		end

		local sceneObjExchange = SceneObjEx:createObj('panel/borrowarrow_exchange_main.json','borrowarrow-exchange-in-lua')
		local panelExchange = sceneObjExchange:getPanelObj()
		panelExchange:setAdaptInfo('recharge_bg_img','recharge_img')

		panelExchange:registerInitHandler(function ()
			local rootExchange = panelExchange:GetRawPanel()

			local closeBtn = tolua.cast(rootExchange:getChildByName('close_btn'), 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObjExchange))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			remainScore = tolua.cast(rootExchange:getChildByName('rescore_num_tx'),'UILabel')
			--remainScore = scoreNum  --两个数值应该一样

			--不使用scrollview
			-- local exchangeSv = tolua.cast(rootExchange:getChildByName('ScrollView'),'UIScrollView')
			-- exchangeSv:setClippingEnable(true)
			-- exchangeSv:setDirection(SCROLLVIEW_DIR_VERTICAL)
			-- exchangeSv:setTouchEnable(false)
			local exchangeBg = tolua.cast(rootExchange:getChildByName('cardroot_img'),'UIImageView')
			--cclog('getpcard pre')
			getPCard()
			exchangeBg:addChild(pPage)


		end)

		panelExchange:registerOnShowHandler(onShow)

		UiMan.show(sceneObjExchange)
	end

	

	local function init()
		root = panel:GetRawPanel()

		showRankBtn = tolua.cast(root:getChildByName('arrowrank_btn'),'UITextButton')
		showRankBtn:registerScriptTapHandler(showRank)
		GameController.addButtonSound(showRankBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		helpBtn = tolua.cast(root:getChildByName('help_btn'),'UIButton')
		helpBtn:registerScriptTapHandler(showHelp)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		oneArrowBtn = tolua.cast(root:getChildByName('onearrow_btn'),'UITextButton')
		--oneArrowBtn:registerScriptTapHandler(clickOneArrowBtn)
		GameController.addButtonSound(oneArrowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		tenArrowBtn = tolua.cast(root:getChildByName('tenarrows_btn'),'UITextButton')
		tenArrowBtn:registerScriptTapHandler(clickTenArrowsBtn)
		GameController.addButtonSound(tenArrowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		exchangeBtn = tolua.cast(root:getChildByName('exchange_btn'),'UITextButton')
		exchangeBtn:registerScriptTapHandler(clickExchangeBtn)
		GameController.addButtonSound(exchangeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		cashNum = tolua.cast(root:getChildByName('cash_cost'),'UILabel')
		-- cashNum:setFontSize(24)


		--设置一箭单发
		oneArrowRemainTimes = tolua.cast(root:getChildByName('onearrow_retime_tx'),'UILabel')
		oneArrowResetTimes = tolua.cast(root:getChildByName('onearrow_cd_tx'),'UILabel')
		oneArrowResetTimes:setText('')
		oneArrowResetTimesCD = UICDLabel:create()
		oneArrowResetTimesCD:setFontSize(22)
		oneArrowResetTimesCD:setPosition(ccp(0,0))
		oneArrowResetTimesCD:setFontColor(ccc3(50, 240, 50))
		oneArrowResetTimesCD:setAnchorPoint(ccp(0,0.5))
		oneArrowResetTimesCD:setPosition(ccp(-80,0))
		oneArrowResetTimes:addChild(oneArrowResetTimesCD)

		local overTimeTx = tolua.cast(root:getChildByName('count_down_tx') , 'UILabel')
		local remainTimes = tolua.cast(root:getChildByName('info_1_bg'),'UIImageView')
		local remainTimesTx = tolua.cast(remainTimes:getChildByName('time_tx'),'UILabel')
		remainTimesTx:setText('')
		local remainTimesCD = UICDLabel:create()
		remainTimesCD:setFontSize(18)
		remainTimesCD:setPosition(ccp(0,0))
		remainTimesCD:setFontColor(ccc3(50,240,50))
		remainTimesCD:setAnchorPoint(ccp(0,0.5))
		remainTimesTx:addChild(remainTimesCD)
		-- remainTimesCD:setTime(UserData:convertTime(1,conf.EndTime) - UserData:getServerTime())

		timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
		local isEnd = false
		if timeDiff < 0 then
			overTimeTx:setText(getLocalStringValue('E_STR_GETAWARD_COUNTDOWN'))
			timeDiff = conf.DelayDays * 86400 + timeDiff
			 isEnd = true
		end
		remainTimesCD:setTime(timeDiff)
		remainTimesCD:registerTimeoutHandler(function ()
			if isEnd == false then
				isEnd = true
				overTimeTx:setText(getLocalStringValue('E_STR_GETAWARD_COUNTDOWN'))
				remainTimesCD:setTime(conf.DelayDays * 86400)
			else
				CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
			end
		end)

		update()
	end



	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/borrowarrow.json','borrowarrow-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('recharge_bg_img','recharge_img')

		panel:registerInitHandler(init)
		-- panel:registerOnShowHandler(onShow)
		-- panel:registerOnHideHandler(onHide)
		UiMan.show(sceneObj)
	end

	local function getborrowarrowResponse()
		-- if isFuncOpen() then
			createPanel()
		-- end
	end

	--入口
	getborrowarrowResponse()
end


