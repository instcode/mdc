Avborrowarrow = {}

local markBoxIsActive

function ShowTotalAwardsPanel(awards,infoTx )
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
	if markBoxIsActive == 0 then 
		return true
	elseif markBoxIsActive ==1 then 
		return false
	end
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

    local openServerTime = UserData:getOpenServerDays()
    local nowTime = UserData:getServerTime()
    local diffDay = (nowTime - openServerTime)/86400
    if diffDay < tonumber(conf.OpenDay) then
    	return true
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
	local serverArrowsNum
	local personalArrowsNum
	local rankNum --个人名次
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
	local scroeGlobal  --score的全局变量，请无视名字

	-- --服务器标记  0为未发送 1为已发送
	-- local markPost = 1

	--总箭数
	local allArrowNum  --服务器total箭数

	--排名
	local rankData
	local rankDataEncode


	--fix
	local remainTimesCD
	local remainTimesInfo
	local updateDataEncode
	local borrowArrowDataEncode
	local tenArrowsCostGlobal    --下次十连发消耗，用于判断是否有足够金币放箭
	local OneArrowLeftTimesGlobal   --免费一箭单发剩余次数
	local myRankGlobal = 0            --我的排名

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
		arrowThird:setCascadeOpacityEnabled(true)
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

	local function boxState()  
		local borrowArrowDataDecode = json.decode(borrowArrowDataEncode)
		
		for i = 1 , #serverAwardMap do
			for k,v in pairs(borrowArrowDataDecode.got) do
				--print('k~~~~~~~~~~~~~' .. k)
				for x = 1 , #serverAwardMap do 
					--cclog("serverAwardMap["..x.."]['Id']============" .. serverAwardMap[x]['Id'])
					if tonumber(k) == tonumber(serverAwardMap[x]['Id']) then 
						boxIcon[x][2] = 1
						--cclog("boxIcon["..x.."][2]=========="..boxIcon[x][2])
					end
					--print('x============' .. x)
				end
			end

			--boxIcon[i][1]:setRotation(0)

			if allArrowNum >= tonumber(serverAwardMap[4].Id) then 
				if boxIcon[i][2] == 1 then  --临时标记已经领取
					markBoxIsActive = 1
					boxIcon[i][1]:setTexture('uires/ui_2nd/com/panel/active/box_2.png')
					boxIcon[i][1]:setTouchEnable(false)
					--cclog('boxIcon['..i..'][1]     :1-----------------------------1')
					--cclog("boxIcon["..i.."][2]=================="..boxIcon[i][2])
				else
					markBoxIsActive = 0
					boxIcon[i][1]:stopAllActions()
					local boxArr = CCArray:create()
					local boxRotateTo1 = CCRotateTo:create(0.1, 15)
					local boxRotateTo2 = CCRotateTo:create(0.1, -15)
					local boxRotateTo3 = CCRotateTo:create(0.1, 0)
						boxArr:addObject(CCCallFunc:create(function (  )
							boxIcon[i][1]:setRotation(0)
						end))
					for t = 1 ,3 do
						boxArr:addObject(boxRotateTo1)
						boxArr:addObject(boxRotateTo2)
					end
					boxArr:addObject(boxRotateTo3)
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
					boxIcon[i][1]:stopAllActions()
					local boxArr = CCArray:create()
					local boxRotateTo1 = CCRotateTo:create(0.1, 15)
					local boxRotateTo2 = CCRotateTo:create(0.1, -15)
					local boxRotateTo3 = CCRotateTo:create(0.1, 0)
						boxArr:addObject(CCCallFunc:create(function (  )
							boxIcon[i][1]:setRotation(0)
						end))
					for t = 1 ,3 do
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
							markBoxIsActive = 1
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

	local function canShoot(  )
		oneArrowBtn:active()
		oneArrowRemainTimes:setVisible(true)
		oneArrowResetTimes:setVisible(false)
		oneArrowResetTimesCD:setTime(0)
	end

	local function cannotShoot()
		oneArrowBtn:disable()
		oneArrowRemainTimes:setVisible(false)
		oneArrowResetTimes:setVisible(true)
		oneArrowResetTimesCD:setTime(tonumber(UserData:getServerTime()) - tonumber(updateTime))
	end

	local function oneArrowState()
		if OneArrowLeftTimesGlobal <= 0 then
			oneArrowBtn:disable()
			oneArrowRemainTimes:setVisible(true)
			oneArrowResetTimes:setVisible(false)
			oneArrowResetTimesCD:setTime(0)
		else
			if tonumber(updateTime) + tonumber(getGlobalIntegerValue('BorrowArrowOneShotIntervalTime')) - tonumber(UserData:getServerTime()) > 0 then
				cannotShoot()
				oneArrowResetTimesCD:setTime(tonumber(updateTime)+ tonumber(getGlobalIntegerValue('BorrowArrowOneShotIntervalTime')) - tonumber(UserData:getServerTime()))
			else
				canShoot()
			end
		end
	end

	local function getMyRank(rankdata)
		--cclog('rankdata~~~~~~~~~~~~~~~~')
		--printall(rankdata)

		if rankdata then
			for i = 1 , #rankdata do 
				if PlayerCoreData.getUID() == tonumber(rankdata[i]['uid']) then
					--cclog('getMyRank(rankdata)~~~~~~~~~~~~~~~~1-1  ' .. i)
					return i
				end
				--cclog('i========='..i)
			end
			--cclog('getMyRank(rankdata)~~~~~~~~~~~~~~~~1-2')
			return 0
		elseif rankdata[1]  then
			for i = 1 , #rankdata do 
				if PlayerCoreData.getUID() == tonumber(rankdata[i]['uid']) then
					--cclog('getMyRank(rankdata)~~~~~~~~~~~~~~~~2-1  ' .. i)
					return i
				end
			end
			--cclog('getMyRank(rankdata)~~~~~~~~~~~~~~~~2-2')
			return 0
		else
			--cclog('getMyRank(rankdata)~~~~~~~~~~~~~~~~3-2')
			return 0	
		end
	end

	local function  update()	

		local updateDataDecode = json.decode(updateDataEncode)

		local borrowArrowDataDecode = json.decode(borrowArrowDataEncode)

		local rankDataDecode = json.decode(rankDataEncode)

		scoreNum:setText(borrowArrowDataDecode.score)  
		personalArrowsNum:setText(borrowArrowDataDecode.arrow)
		serverArrowsNum:setText(updateDataDecode.total_arrow)

		--活动倒计时
		if UserData:convertTime(1,conf.EndTime) - UserData:getServerTime() > 0 then
			remainTimesCD:setTime(UserData:convertTime(1,conf.EndTime) - UserData:getServerTime())
		else
			remainTimesInfo:setText(getLocalStringValue('E_STR_GETAWARD_COUNTDOWN'))
			remainTimesCD:setTime(UserData:convertTime(1,conf.EndTime) + (tonumber(conf.DelayDays))*86400 - UserData:getServerTime())
			oneArrowBtn:disable()
			tenArrowBtn:disable()
			oneArrowResetTimesCD:setVisible(false)
			oneArrowResetTimesCD:setTime(0)
			oneArrowResetBtn:setVisible(false)
			oneArrowResetTimes:setVisible(false)
		end

		--主界面rank名字
		local tempRank = 5
		if rankDataDecode[1]  then
			if tonumber(#rankDataDecode) < tempRank then
				tempRank = tonumber(#rankDataDecode)
			end
			for i = 1 , tempRank do
				rank[i]:setText(rankDataDecode[i]['name'])
			end
		else
			for i = 1 , tempRank do
				rank[i]:setText(getLocalStringValue('E_STR_WELFARE_NORANK1'))
			end
		end

		--单发CD
		updateTime = borrowArrowDataDecode.update


		--单发次数BorrowArrowDailyFreeCount
		OneArrowLeftTimesGlobal = tonumber(getGlobalIntegerValue('BorrowArrowDailyFreeCount')) - tonumber(borrowArrowDataDecode.one)
		oneArrowRemainTimes:setText(tostring(OneArrowLeftTimesGlobal))

		--十箭连发初始消耗金额
		if tonumber(borrowArrowDataDecode['ten']) >= #tenArrowCostMap - 1 then
			tenArrowsCost:setText(tenArrowCostMap[#tenArrowCostMap]['Cash'])
			tenArrowsCostGlobal = tonumber(tenArrowCostMap[#tenArrowCostMap]['Cash'])
		else
			local tenArrowNextTime = tonumber(borrowArrowDataDecode['ten']) + 1
			tenArrowsCost:setText(tenArrowCostMap[tenArrowNextTime]['Cash'])
			tenArrowsCostGlobal = tonumber(tenArrowCostMap[tenArrowNextTime]['Cash'])
		end

		--十连发次数
		tenAC = tonumber(borrowArrowDataDecode['ten'])

		--十连发积分累计
		scroeGlobal = borrowArrowDataDecode.score

		--总箭数
		allArrowNum = updateDataDecode.total_arrow
		
		--获取排名
		myRankGlobal = getMyRank(rankDataDecode)
		cclog('myRankGlobal~~~~~~~~~~~' .. myRankGlobal)
		if myRankGlobal == 0 then
			rankNum:setText(getLocalString('E_STR_WELFARE_NORANK'))	
		else
			rankNum:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK'),myRankGlobal))
		end

		--元宝总数
		cashNum:setText(toWordsNumber(PlayerCoreData.getCashValue()))

		--4个箱子状态
		for i = 1 , 4 do
			boxNum[i]:setText(serverAwardMap[i]['Id'])
			boxGift[i] = {serverAwardMap[i]['Award1'],serverAwardMap[i]['Award2'],serverAwardMap[i]['Award3'],serverAwardMap[i]['Award4']}
		end
		boxState()

		if UserData:convertTime(1,conf.EndTime) - UserData:getServerTime() > 0 then
			oneArrowState()
		end
	end

	local function whenCloseOtherPanel()
		Message.sendPost('get_borrow_arrow','activity','{}',function (jsonData)
			--cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic.code ~= 0 then
				--cclog('oneArrow error~~~~~~~:'.. jsonDic.desc)
				return
			end
			local data = jsonDic.data
			updateDataEncode = json.encode(data)

			local borrowArrow = data.borrow_arrow
			borrowArrowDataEncode = json.encode(borrowArrow)  --4个箱子需要引用  一箭单发要用

			local rankData = data.rank
			rankDataEncode = json.encode(rankData)   --排名要用

			scoreNum:setText(borrowArrow.score)  	--积分

			serverArrowsNum:setText(borrowArrow.total_arrow)	--服务器总箭数

			updateTime = borrowArrow.update     --单发CD

			--主界面rank名字
			local tempRank = 5
			if rankData[1]  then
				if tonumber(#rankData) < tempRank then
					tempRank = tonumber(#rankData)
				end
				for i = 1 , tempRank do
					rank[i]:setText(rankData[i]['name'])
				end
			else
				for i = 1 , tempRank do
					rank[i]:setText(getLocalStringValue('E_STR_WELFARE_NORANK1'))
				end
			end

			--名次变化
			if myRankGlobal ~= getMyRank(rankData) then
				if getMyRank(rankData) == 0 then   --暂无排名
					GameController.showMessageBox(string.format(getLocalStringValue('E_STR_NO_PERSON_ON_RANK'),getMyRank(rankData)),MESSAGE_BOX_TYPE.OK,function()
						myRankGlobal = getMyRank(rankData)
						 end)
				elseif myRankGlobal == 0 and myRankGlobal < getMyRank(rankData) then
					GameController.showMessageBox(string.format(getLocalStringValue('E_STR_BORROWARROW_UP_TO_RANK'),getMyRank(rankData)),MESSAGE_BOX_TYPE.OK,function()
						myRankGlobal = getMyRank(rankData)
						end)
				elseif myRankGlobal > getMyRank(rankData) and myRankGlobal ~= 0 then
					GameController.showMessageBox(string.format(getLocalStringValue('E_STR_BORROWARROW_UP_TO_RANK'),getMyRank(rankData)),MESSAGE_BOX_TYPE.OK,function()
						myRankGlobal = getMyRank(rankData)
						end)
				elseif myRankGlobal < getMyRank(rankData) and myRankGlobal ~= 0 then
					GameController.showMessageBox(string.format(getLocalStringValue('E_STR_BORROWARROW_DOWN_TO_RANK'),getMyRank(rankData)),MESSAGE_BOX_TYPE.OK,function()
						myRankGlobal = getMyRank(rankData)
						end)
				end
			end

			if getMyRank(rankData) == 0 then
				rankNum:setText(getLocalString('E_STR_WELFARE_NORANK'))	
			else
				rankNum:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK'),getMyRank(rankData)))
			end
			-----------------------------------
			if UserData:convertTime(1,conf.EndTime) - UserData:getServerTime() > 0 then
				oneArrowState()
			end

			boxState()
		end)
	end

	local function showRank()

		local pCard
		local pPage
		local rankSv
		local genBtn


		local function genBtnState()

			local rankDataDecode = json.decode(rankDataEncode)
			if rankDataDecode then
				--cclog('genBtnState~~~~~~~~~~~~~~~~~~~~~~1')
				--printall(rankDataDecode)
				--cclog('genBtnState~~~~~~~~~~~~~~~~~~~~~~1-3')
				genBtn:disable()
				genBtn:setText(getLocalStringValue('E_STR_ARENA_HAVE_NOT_ACHIEVE'))
				for i = 1 , #rankDataDecode do
					if tonumber(PlayerCoreData.getUID()) == tonumber(rankDataDecode[i]['uid']) then
						if tonumber(rankDataDecode[i]['got']) == 0  then 
							--cclog('genBtnState~~~~~~~~~~~~~~~~~~~~~~1-1')
							genBtn:active()
							genBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
							return
						elseif tonumber(rankDataDecode[i]['got']) == 1  then 
							--cclog('genBtnState~~~~~~~~~~~~~~~~~~~~~~1-2')
							genBtn:disable()
							genBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
							return
						end
					end
				end
			else
				--cclog('genBtnState~~~~~~~~~~~~~~~~~~~~~~2-1')
				genBtn:disable()
				genBtn:setText(getLocalStringValue('E_STR_ARENA_HAVE_NOT_ACHIEVE'))
			end
		end

		local sceneObjRank = SceneObjEx:createObj('panel/borrowarrow_rank_main.json','borrowarrow-rank-in-lua')
		local panelRank = sceneObjRank:getPanelObj()
		panelRank:setAdaptInfo('top_ranking_bg_img','top_ranking_img')

		panelRank:registerInitHandler(function ()
			local rootRank = panelRank:GetRawPanel()

			local closeBtn = tolua.cast(rootRank:getChildByName('close_btn'), 'UIButton')
			closeBtn:registerScriptTapHandler(function()
				CUIManager:GetInstance():HideObject(sceneObjRank, ELF_SHOW.NORMAL)
				--UiMan.genCloseHandler(sceneObjRank)
				whenCloseOtherPanel()
				end)
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			genBtn = tolua.cast(rootRank:getChildByName('get_award_btn'),'UITextButton')
			GameController.addButtonSound(genBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			genBtn:registerScriptTapHandler(function ()
				local timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
				--cclog('timeDiff~~~~~~~~~~~~')
				--cclog(timeDiff)
				if timeDiff >= 0 then 
					GameController.showPrompts(getLocalString('E_STR_NOTATTHETIME'),COLOR_TYPE.RED)
					return
				end
				
				Message.sendPost('get_borrow_arrow_rank_award','activity','{}',function( jsonData )
					--cclog(jsonData)
					local jsonDic = json.decode(jsonData)
					if jsonDic.code ~= 0 then
						return
					end
					local data = jsonDic.data
					local awards = data['awards']
				    local awardStr = json.encode(awards)
					GameController.showPrompts(getLocalString('E_STR_GET_SUCCEED'),COLOR_TYPE.GREEN)
					UserData.parseAwardJson(awardStr)

					genBtn:disable()
					genBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
				end)
			end)
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
					local kingIcon = tolua.cast(pCard:getChildByName('king_ico'),'UIImageView')
					if i == 1 or i ==2 or i == 3 then
						rankTx:setVisible(false)
						kingIcon:setVisible(true)
						kingIcon:setTexture('uires/ui_2nd/com/panel/trena/'..i..'.png')
					else
						rankTx:setVisible(true)
						kingIcon:setVisible(false)
						rankTx:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK') , i))
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

	local function clickOneArrowBtn(  )
		local args = {type = 1}
		Message.sendPost('shot_borrow_arrow','activity',json.encode(args),function (jsonData)
			--cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic.code ~= 0 then
				local timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
				if timeDiff < 0 then 
					GameController.showPrompts(getLocalString('E_STR_GET_GOD_ROLE_FALIUE'),COLOR_TYPE.RED)
				end
				return
			end
			local data = jsonDic.data
			local args = jsonDic.args
			--积分增加
			local tempScore = tonumber(data['score'])
			scoreNum:setText(tostring(tonumber(scroeGlobal)+tempScore))
			scroeGlobal = tonumber(scroeGlobal) + tempScore

			--箭数增加
			personalArrowsNum:setText(args.arrow_count)
			serverArrowsNum:setText(data.total_arrow)
			--更新全服总箭数的值
			allArrowNum = tonumber(data.total_arrow)

			--暴击与否提示
			if tonumber(jsonDic['args']['message']) == 1 then 
				GameController.showPrompts(string.format(getLocalString("E_STR_GOT_CRIT_SCORE"),tonumber(data['score'])) , COLOR_TYPE.ORANGE)
			else
				GameController.showPrompts(string.format(getLocalString("E_STR_GOT_SCORE"),tonumber(data['score'])) , COLOR_TYPE.GREEN)
			end

			updateTime = tonumber(jsonDic.serverTime)    --记录当前服务器时间，转冷却时间

			OneArrowLeftTimesGlobal = OneArrowLeftTimesGlobal - 1
			oneArrowRemainTimes:setText(tostring(OneArrowLeftTimesGlobal))

			--名次变化后刷新
			if myRankGlobal ~= tonumber(data['rank']) then
				whenCloseOtherPanel()
			end

			arrowActionNormal()

			boxState()

			if UserData:convertTime(1,conf.EndTime) - UserData:getServerTime() > 0 then
				oneArrowState()
			end
		end)
	end

	local function clickTenArrowsBtn(  )
		local args = {type = 10}
		Message.sendPost('shot_borrow_arrow','activity',json.encode(args),function (jsonData)
			--cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic.code ~= 0 then
				local timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
				if timeDiff < 0 then 
					GameController.showPrompts(getLocalString('E_STR_GET_GOD_ROLE_FALIUE'),COLOR_TYPE.RED)
				else
					GameController.showPrompts(getLocalString('E_STR_CASH_NOT_ENOUGH'),COLOR_TYPE.RED)
				end
				return
			end
			local data = jsonDic.data
			local args = jsonDic.args

			PlayerCoreData.addCashDelta(tonumber(data['cash']))

			--元宝消耗增加
			tenAC = tenAC + 1
			local temAC = tenAC + 1
			--cclog('tenAC~~~~~~~~~~~~~'..tenAC)
			--cclog('temAC~~~~~~~~~~~~~'..temAC)
			if tenAC >= (#tenArrowCostMap - 1) then
				tenArrowsCost:setText(tostring(tenArrowCostMap[#tenArrowCostMap]['Cash']))
			else
				tenArrowsCost:setText(tostring(tenArrowCostMap[temAC]['Cash']))
			end
			cashNum:setText(toWordsNumber(PlayerCoreData.getCashValue()))

			--积分增加
			local tempScore = tonumber(data['score'])
			scoreNum:setText(tostring(tonumber(scroeGlobal)+tempScore))
			scroeGlobal = tonumber(scroeGlobal) + tempScore

			--箭数增加
			personalArrowsNum:setText(args.arrow_count)
			serverArrowsNum:setText(data.total_arrow)
			--更新全服总箭数的值
			allArrowNum = tonumber(data.total_arrow)

			--暴击与否提示
			if tonumber(jsonDic['args']['message']) == 1 then 
				GameController.showPrompts(string.format(getLocalString("E_STR_GOT_CRIT_SCORE"),tonumber(data['score'])) , COLOR_TYPE.ORANGE)
			else
				GameController.showPrompts(string.format(getLocalString("E_STR_GOT_SCORE"),tonumber(data['score'])) , COLOR_TYPE.GREEN)
			end

			--名次变化后刷新
			if myRankGlobal ~= tonumber(data['rank']) then
				whenCloseOtherPanel()
			end

			arrowAction()

			boxState()
		end)
	end

	local function clickExchangeBtn(  )

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
			remainScore:setText(scroeGlobal)  --兑换奖励后刷新积分
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
			titleMoneyTx:setText(scroeGlobal)  --兑换奖励后刷新积分
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
			else
				leftBtn:active()
			end
				if num >= Limit.MAX_COUNT or num >= math.floor(scroeGlobal / price) then
					rightBtn:disable()
				else
					rightBtn:active()
				end
		end

		-- 初始化购买界面
		local function initConfirmBuyPanel()
		    local sceneObjExchangeIn = SceneObjEx:createObj('panel/confirm_buy_panel_small.json', 'confirm-buy-lua')
		    local panel = sceneObjExchangeIn:getPanelObj()
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
					if math.floor(scroeGlobal / price) <= Limit.MAX_COUNT then
						num = math.floor(scroeGlobal / price)
					else
						num = Limit.MAX_COUNT
					end
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
					if math.floor(scroeGlobal / price) <= Limit.MAX_COUNT then
						num = math.floor(scroeGlobal / price)
					else
						num = Limit.MAX_COUNT
					end
				CNumEditorAct:getInst():numAddOnce(leftBtn, numEditBox, rightBtn, num)
				updateNumbers()
			end

			local function onClickBuyBtn()
				--cclog('clickbuy in~~~~~~~~~~~~~~~~~~')
				local ct = numEditBox:getTextFromInt()
				--cclog(scroeGlobal - ct*price)
				if (scroeGlobal - ct*price) < 0 then 
					GameController.showPrompts( getLocalStringValue('E_STR_CARD_MASTER_NOT_ENOUGH_SCORE'),COLOR_TYPE.RED )
					return
				else
					local args = { id = cardId, num = ct,}
					--cclog('before send Message~~~~~~~~~~~~~~~~~~~~~')
					Message.sendPost('borrow_arrow_score_exchange', 'activity', json.encode(args), function (jsonData)
						--cclog('send Message in ~~~~~~~~~~~~~~~~~~~~~')
			        	--cclog(jsonData)
				        local jsonDic = json.decode(jsonData)
				        if jsonDic['code'] ~= 0 then
				            return
				        end

				        local data = jsonDic['data']
				        if not data then return end

				        local awards = data['awards']
				        local awardStr = json.encode(awards)
				       --cclog('awardStr~~~~~~~~~~~~~~~~~~~~~~~')
				       --cclog(awardStr)
				        UserData.parseAwardJson(awardStr)

				        GameController.showPrompts( getLocalStringValue('E_STR_EXCHANGE_SUCCEED'),COLOR_TYPE.GREEN )

				       	scroeGlobal =  scroeGlobal - ct * price
				       	--cclog('before Updatescore~~~~~~~~~~~~~~~~')
				       	upDateScore()
			        end)
	            end
	            --cclog('clickbuy out1~~~~~~~~~~~~~~~~~~')
				CUIManager:GetInstance():HideObject(sceneObjExchangeIn, ELF_HIDE.ZOOM_OUT_FADE_OUT)
				--cclog('clickbuy out2~~~~~~~~~~~~~~~~~~')
			end

		    local function editBoxEventHandler( eventType )
				local num = numEditBox:getTextFromInt()
				if num <= 0 then
					num = 0
				else
						if num > Limit.MAX_COUNT then
							num = Limit.MAX_COUNT
						end
						if num > math.floor(scroeGlobal / price) then
							num = math.floor(scroeGlobal / price)
						end
				end
				numEditBox:setTextFromInt(num)
				updateNumbers()
				updateBtnStatus()
			end

		    panel:registerInitHandler(function()
		        local root = panel:GetRawPanel()
		        local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		        closeBtn:registerScriptTapHandler(function ()
		        	CUIManager:GetInstance():HideObject(sceneObjExchangeIn, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		        end)
		        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		        local background = tolua.cast(root:getChildByName('zhegai_bg_img'), 'UIImageView')
		        background:registerScriptTapHandler(function ()
		        	CUIManager:GetInstance():HideObject(sceneObjExchangeIn, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		        end)
		        --Init title.
		        titleIco = tolua.cast(root:getChildByName('buy_title_tx') , 'UILabel')
		        titleIco:setText(getLocalStringValue('E_STR_SHOP_CONFIRM_BUY_TITLE'))
		        titleMoneyIcon = tolua.cast(root:getChildByName('honor_ico') , 'UIImageView')
		        titleMoneyTx = tolua.cast(root:getChildByName('honor_num_tx') , 'UILabel')

		        --Init left side.
		        local contentImg = root:getChildByName('buy_img')
		        nameTx = tolua.cast(contentImg:getChildByName('name_tx') , 'UILabel')
		        nameBgImg = tolua.cast(contentImg:getChildByName('name_bg_ico') , 'UIImageView')
		        itemIco = tolua.cast(contentImg:getChildByName('material_ico') , 'UIImageView')
		        hasTx = tolua.cast(contentImg:getChildByName('own_tx') , 'UILabel')
		        descTx = tolua.cast(contentImg:getChildByName('info_tx') , 'UITextArea')

		        local editBoxBg = tolua.cast(root:getChildByName('number_bg_ico') , 'UIImageView')

		        numEditBox = tolua.cast(UISvr:replaceUIImageViewByCCEditBox(editBoxBg) , 'CCEditBox')
				numEditBox:setHAlignment(kCCTextAlignmentCenter)
				numEditBox:setInputMode(kEditBoxInputModeDecimal)
				numEditBox:setFontSize(42)
				numEditBox:registerScriptEditBoxHandler( editBoxEventHandler )

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
				
				descTx:setText(PlayerCoreData.getMaterialDesc(shopId))
				nameTx:setText(PlayerCoreData.getMaterialName(shopId))
				nameTx:setColor(PlayerCoreData.getMaterialColor(shopId))
				itemIco:setTexture(PlayerCoreData.getMaterialIco(shopId))
				hasNum = PlayerCoreData.getMaterialCount(shopId)
				hasTx:setText(string.format(getLocalString('E_STR_BS_CONFIRM_HAS_NUM_STR') , toWordsNumber(hasNum)))
				price = tonumber(exchangeItemConf[tonumber(cardId)]['Score'])
				titleMoneyTx:setText(scroeGlobal)
				titleMoneyIcon:setTexture('uires/ui_2nd/com/panel/borrowarrow/score_icon.png')
				currMoneyIcon:setTexture('uires/ui_2nd/com/panel/borrowarrow/score_icon.png')
				confirmBtn:setText(getLocalString('E_STR_BAG_SHOP_EXCHANGE_STR'))
				if tonumber(price) > tonumber(scroeGlobal) then
					numEditBox:setTextFromInt(0)
					leftBtn:disable()
					rightBtn:disable()
				else
					numEditBox:setTextFromInt(1)
				end
				updateNumbers()
				upDateScore()
		    end)
			

		    CUIManager:GetInstance():ShowObject(sceneObjExchangeIn, ELF_SHOW.ZOOM_IN)
		end


		local function onClickCardExchange(i, id, count)
			shopId = id
			cardId = i
			initConfirmBuyPanel()
		end

		local function getPCard()
			pPage = UIContainerWidget:create()
			pPage:setWidgetZOrder(9)
			pPage:setAnchorPoint(ccp(0.5,0.5))
			pPage:setPosition(ccp(850/2 , 530/2))

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
			closeBtn:registerScriptTapHandler(function()
				CUIManager:GetInstance():HideObject(sceneObjExchange, ELF_SHOW.NORMAL)
				--UiMan.genCloseHandler(sceneObjExchange)
				whenCloseOtherPanel()
				end)
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			remainScore = tolua.cast(rootExchange:getChildByName('rescore_num_tx'),'UILabel')
			remainScore:setText('')



			local exchangeBg = tolua.cast(rootExchange:getChildByName('cardroot_img'),'UIImageView')
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
		oneArrowBtn:registerScriptTapHandler(clickOneArrowBtn)
		GameController.addButtonSound(oneArrowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		tenArrowBtn = tolua.cast(root:getChildByName('tenarrows_btn'),'UITextButton')
		tenArrowBtn:registerScriptTapHandler(clickTenArrowsBtn)
		GameController.addButtonSound(tenArrowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		exchangeBtn = tolua.cast(root:getChildByName('exchange_btn'),'UITextButton')
		exchangeBtn:registerScriptTapHandler(clickExchangeBtn)
		GameController.addButtonSound(exchangeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		remainTimesInfo = tolua.cast(root:getChildByName('timeout_info_tx'),'UILabel')
		remainTimesInfo:setText(getLocalStringValue('E_STR_WELFARE_TIMEEND'))

		local remainTimes = tolua.cast(root:getChildByName('info_1_bg'),'UIImageView')
		local remainTimesTx = tolua.cast(remainTimes:getChildByName('time_tx'),'UILabel')
		remainTimesTx:setText('')
		remainTimesCD = UICDLabel:create()
		remainTimesCD:setFontSize(22)
		remainTimesCD:setPosition(ccp(0,0))
		remainTimesCD:setFontColor(ccc3(50,240,50))
		remainTimesCD:setAnchorPoint(ccp(0,0.5))
		remainTimesTx:addChild(remainTimesCD)
		remainTimesCD:registerTimeoutHandler(function()
			remainTimesCD:setTime(UserData:convertTime(1,conf.EndTime) + (tonumber(conf.DelayDays))*86400 - UserData:getServerTime())
			remainTimesInfo:setText(getLocalStringValue('E_STR_GETAWARD_COUNTDOWN'))
			oneArrowBtn:disable()
			tenArrowBtn:disable()
			oneArrowResetTimesCD:setVisible(false)
			oneArrowResetTimesCD:setTime(0)
			oneArrowResetBtn:setVisible(false)
			oneArrowResetTimes:setVisible(false)
			end)

		--个人箭数
		local personalArrows = tolua.cast(root:getChildByName('info_2_bg'),'UIImageView')
		personalArrowsNum = tolua.cast(personalArrows:getChildByName('time_tx'),'UILabel')

		--个人名次设置为服务器返回的数值
		local rankBg = tolua.cast(root:getChildByName('info_3_bg'),'UIImageView')
		rankNum = tolua.cast(rankBg:getChildByName('rank_num'),'UILabel')
		
		for i = 1 , 5 do
			rank[i] = tolua.cast(root:getChildByName('rank'..i..'_tx'),'UILabel')
		end

		--服务器总箭数
		serverArrowsNum = tolua.cast(root:getChildByName('allarrow_num'),'UILabel')

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
		oneArrowResetTimesCD:registerTimeoutHandler(canShoot)
		
		oneArrowResetBtn = tolua.cast(root:getChildByName('reset_btn'), 'UIButton')
		GameController.addButtonSound(oneArrowResetBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		oneArrowResetBtn:registerScriptTapHandler(function()
			if tonumber(PlayerCoreData.getCashValue()) < tonumber(getGlobalIntegerValue('BorrowArrowCDCashCost')) then
				GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'),COLOR_TYPE.RED)
				return
			end

			local str = string.format(getLocalStringValue('E_STR_BORROWARROW_RESET'),tonumber(getGlobalIntegerValue('BorrowArrowCDCashCost')))
			GameController.showMessageBox(str, MESSAGE_BOX_TYPE.OK_CANCEL, function ()
				Message.sendPost('clear_cd_borrow_arrow', 'activity', '{}', function( jsonData )
					--cclog(jsonData)
					local jsonDic = json.decode(jsonData)
					if jsonDic.code ~= 0 then
						return
					end
					PlayerCoreData.addCashDelta(-tonumber(getGlobalIntegerValue('BorrowArrowCDCashCost')))
					cashNum:setText(toWordsNumber(PlayerCoreData.getCashValue()))

					canShoot()
				end)
			end)
		end)

		--十连发消耗
		tenArrowsCost = tolua.cast(root:getChildByName('cash_cost'),'UILabel')

		--积分总数
		scoreNum = tolua.cast(root:getChildByName('score_tx'),'UILabel')

		--元宝总数
		cashNum = tolua.cast(root:getChildByName('cash_num_tx'),'UILabel')

		--4个箱子状态
		for i = 1 , 4 do
			boxIcon[i] = {}
			boxNum[i] = tolua.cast(root:getChildByName('box'..i..'_num'),'UILabel')
			boxIcon[i][1] = tolua.cast(boxNum[i]:getChildByName('box'..i..'_img'),'UIImageView')
			boxIcon[i][2] = 0  --临时标记，0为未领取,从服务器获取
		end

		update()
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/borrowarrow.json','borrowarrow-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('recharge_bg_img','recharge_img')

		panel:registerInitHandler(init)
		--panel:registerOnShowHandler(onShow)
		--panel:registerOnHideHandler(onHide)
		UiMan.show(sceneObj)
	end

	local function sendUpdateRequest()
		Message.sendPost('get_borrow_arrow','activity','{}',function (jsonData)
			--cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic.code ~= 0 then
				return
			end
			local data = jsonDic.data
			updateDataEncode = json.encode(data)

			local borrowArrow = data.borrow_arrow
			borrowArrowDataEncode = json.encode(borrowArrow)  --4个箱子需要引用  一箭单发要用

			local rankData = data.rank
			rankDataEncode = json.encode(rankData)   --排名要用

			createPanel()
		end)
	end

	local function getborrowarrowResponse()
		sendUpdateRequest()
	end
	--入口
	getborrowarrowResponse()
end

