Rechangereb = {
}
--活动是否超时-- 活动开始结束时间和延时领取时间
function Rechangereb.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	table.foreach(data , function (_ , v)
		if v['Key'] == 'payrebate' then
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
    local beginTimeOfOpenServerTime = Time.beginningOfOneDay(openServerTime)
    local nowTime = UserData:getServerTime()
    local diffDay = (nowTime - beginTimeOfOpenServerTime)/86400 + 1
    if diffDay < tonumber(conf.OpenDay) then
        return true
    end
    return false
end

-- 进入行军粮饷
function Rechangereb.enter()
	
	-- 定义一些常量
	local sceneObj
	local panel
	local root
	local daydate = {}
	local rightSv = nil
	local selectday = 1
	local getdata = {}
	local getAllAwardBtns = {}
	local dayImg = {}
	local actsatrtTm = 0
	local remainTimesCD 
	local gotdate = {0,0,0}
	-- 判断活动是否结束
	local function judgeOverTime()
		if Rechangereb.isOverTime() then
			GameController.showPrompts(getLocalStringValue('E_STR_ACTIVITY_TIMEOUT_DESC'), COLOR_TYPE.RED)
			return true
		end
		return false
	end
	local function getDayrechangeMap(day)
		daydate ={}
		local avpayconf = GameData:getArrayData('avpayrebate.dat')
		table.foreach(avpayconf , function (key , value)
			if tonumber(value['Day']) == tonumber(day) then
				table.insert(daydate , value)
			end
		end)

	end

	local function getrechangelv(data,pay)
		pay = pay or 0
		local index =0
		table.foreach(data , function(key , value)
			if pay >= tonumber(value['Pay']) then
				index = index +1
			end
		end)
		return index
	end

	local function gettoday()
		local nowTime = UserData:getServerTime()
	 	local time = getdata.pay_rebate.time
		local  diffTime = nowTime - time
		local day = math.ceil(diffTime/86400)
		if day < 1 then
			day = 1
		end
		return day
	end
	--产生下边的滑动列表--
	local function genRechangerebCardItem(day)
		local index = 0
		getDayrechangeMap(day)
		rightSv:removeAllChildrenAndCleanUp(true)
		table.foreach(daydate , function(key , value)
			local pItem = createWidgetByName('panel/rechangereb_card_panel.json')
			if not pItem then
				cclog('failed to create active_card_panel!!')
			else
				local rechangetx = tolua.cast(pItem:getChildByName('rechange_tx') , 'UILabel')
				local rebatetx = tolua.cast(pItem:getChildByName('rebate_tx') , 'UILabel')
				getAllAwardBtns[index] = tolua.cast(pItem:getChildByName('reward_btn') , 'UITextButton')
				getAllAwardBtns[index]:registerScriptTapHandler(function ()
					local got = getdata.pay_rebate.got
				 	local nowTime = UserData:getServerTime()
				 	local time = getdata.pay_rebate.time
					local  diffTime = nowTime - time
					local day = math.ceil(diffTime/86400)
					if tonumber(day) - tonumber(selectday) > 0 then
						local args ={
							day = selectday,
						}
						Message.sendPost('get_pay_rebate_award','activity',json.encode(args),function (jsondata)

							cclog(jsondata)
							
							local response = json.decode(jsondata)
							local code = tonumber(response.code)
							if code ~= 0 then
								cclog('request error : '..response.desc)
								return
							end
							local data = response.data
							UserData.parseAwardJson(json.encode(data['awards']))
							GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
							gotdate[selectday] = 1

							for i =1,3 do
								if tonumber(selectday) == i then
									dayImg[i]:setScale(1.4)
								else
									dayImg[i]:setScale(1.0)
								end
							end
							genRechangerebCardItem(selectday)
						end)
					else
						GameController.showPrompts(getLocalString('E_STR_AWARD_TOM'),COLOR_TYPE.RED)
					end
				end)
				GameController.addButtonSound(getAllAwardBtns[index] , BUTTON_SOUND_TYPE.CLICK_EFFECT)
				local awardNametx = tolua.cast(pItem:getChildByName('award_tx') , 'UILabel')

				rechangetx:setText(value['Pay'] .. getLocalStringValue('E_STR_CASH'))
				local award1 =UserData:getAward(value['Award1'])
				rebatetx:setText(award1['count'] .. award1['name'])
				local award2 =UserData:getAward(value['Award2'])
				awardNametx:setText(award2['name'] ..'X'.. toWordsNumber(tonumber(award2['count'])))
				awardNametx:setColor(award2['color'])
				pItem:setPosition(ccp(0 , 420 - index * 106))
				rightSv:addChild(pItem)
				local todaypay = 0
				if getdata.pay_rebate.pay ~= nil then
					todaypay = getdata.pay_rebate.pay[tostring(selectday)]
				end
				local idx =getrechangelv(daydate,todaypay)
				if idx-1 == index  then
					if gotdate[selectday] == 0 then
						getAllAwardBtns[index]:setVisible(true)
						getAllAwardBtns[index]:setNormalButtonGray(false)
						getAllAwardBtns[index]:setTouchEnable(true)
						getAllAwardBtns[index]:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
					else
						getAllAwardBtns[index]:setVisible(true)
						getAllAwardBtns[index]:setNormalButtonGray(true)
						getAllAwardBtns[index]:setTouchEnable(false)
						getAllAwardBtns[index]:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
					end
				elseif idx-1 > index then
					--getAllAwardBtns[index]:setNormalButtonGray(true)
					--getAllAwardBtns[index]:setTouchEnable(false)
					--getAllAwardBtns[index]:setText(getLocalStringValue('E_STR_ARENA_AWARD_DESC2'))
					getAllAwardBtns[index]:setVisible(false)
				else
					getAllAwardBtns[index]:setVisible(true)
					getAllAwardBtns[index]:setNormalButtonGray(true)
					getAllAwardBtns[index]:setTouchEnable(false)
					getAllAwardBtns[index]:setText(getLocalStringValue('E_STR_ARENA_AWARD_DESC1'))
				end
				index = index + 1
			end
		end)
		rightSv:scrollToTop()
	end
	local function selectdayfn(day)
		local selday =day
		if day > gettoday() then
			GameController.showPrompts(getLocalStringValue('E_STR_ERROR_TOM'), COLOR_TYPE.RED)
		else
			if day > 3 then
				selday = 3
				local paytx =tolua.cast(root:getChildByName('rechage_tx'), 'UILabel')
		 		paytx:setText(getLocalStringValue('E_STR_ACTIVIT_OVER'))
			end
			for i =1,3 do
				if tonumber(selday) == i then
					dayImg[i]:setScale(1.4)
				else
					dayImg[i]:setScale(1.0)
				end
			end
			selectday = selday
			genRechangerebCardItem(selectday)
		end
	end
	-- 获取活动信息
	local function getrebatedate()
		Message.sendPost('get_pay_rebate','activity','{}',function (jsondata)

			cclog(jsondata)
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			if code ~= 0 then
				cclog('request error : '..response.desc)
				return
			end
			local data = response.data
		 	local pay = data.pay_rebate.pay

		 	local got = data.pay_rebate.got
		 	getdata = data
		 	local today = gettoday()
			local paytx =tolua.cast(root:getChildByName('rechage_tx'), 'UILabel')
		 	if data.pay_rebate.pay[tostring(today)] ~= nil then
		 		paytx:setText(data.pay_rebate.pay[tostring(today)])
		 	else
		 		paytx:setText('0')
		 	end
		 	for i =1,3 do
			 	if data.pay_rebate.got[tostring(i)] ~= nil then
			 		gotdate[i] = tonumber(data.pay_rebate.got[tostring(i)])
			 	else
			 		gotdate[i] = 0
			 	end

		 	end
		 	selectdayfn(today)
		end)
	end

	local function onShow()
		getrebatedate()
	end

	local function init()
		root = panel:GetRawPanel()

		local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		for i = 1,3 do
			local str = 'day' .. i .. '_img'
			dayImg[i] = tolua.cast(root:getChildByName(str),'UIImageView')
			dayImg[i]:registerScriptTapHandler(function()
				selectdayfn(i)
			end)
		end

		local data = GameData:getArrayData('activities.dat')
		table.foreach(data , function (_ , v)
			if v['Key'] == 'payrebate' then
				conf = v
			end
		end)

		local remainTimes = tolua.cast(root:getChildByName('rechangereb_img'), 'UIImageView')
		local remainTimesNum = tolua.cast(remainTimes:getChildByName('time_tx'), 'UILabel')
		remainTimesNum:setText('')
		local remainTimesNumCD = UICDLabel:create()
		remainTimesNumCD:setFontSize(22)
		remainTimesNumCD:setPosition(ccp(0,0))
		remainTimesNumCD:setFontColor(ccc3(50, 240, 50))
		remainTimesNumCD:setAnchorPoint(ccp(0,0.5))
		remainTimesNum:addChild(remainTimesNumCD)
		
		remainTimesNumCD:setTime(UserData:convertTime(1,conf.EndTime) + (tonumber(conf.DelayDays))*86400 - UserData:getServerTime())
		if UserData:convertTime(1, conf.EndTime) - UserData:getServerTime() < 0 then
			local timedesc_tx = tolua.cast(remainTimes:getChildByName('timedesc_tx'), 'UILabel')
			timedesc_tx:setText(getLocalStringValue('E_STR_AWARD_TIME'))
		end
		local rankBtn = tolua.cast(root:getChildByName('rank_btn'),'UIButton')
		rankBtn:registerScriptTapHandler(function()
			local awardsConf = GameData:getArrayData('avpayrebaterank.dat')
			Rankgifs:show('uires/ui_2nd/com/panel/mainscene/rebaterank.png',getdata.rank,nil,awardsConf,getLocalStringValue('E_STR_RECHANGEREB_DESC'),'get_pay_rebate_rank_award','payrebate')
			-- body
		end)
		GameController.addButtonSound(rankBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local helpBtn = tolua.cast(root:getChildByName('help_btn'),'UIButton')
		helpBtn:registerScriptTapHandler(function()
			genRechangerebHelpPanel()
		end)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		rightSv = tolua.cast(root:getChildByName('right_sv') , 'UIScrollView')
		rightSv:removeAllChildrenAndCleanUp(true)
		rightSv:setClippingEnable(true)
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/rechangereb_panel.json','rechangereb-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('rechangereb_bg_img','rechangereb_img')
		panel:registerInitHandler(init)
		panel:registerOnShowHandler(onShow)

		UiMan.show(sceneObj)
	end
	--入口
	createPanel()
end