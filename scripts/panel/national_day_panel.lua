NationalDay = {}

function NationalDay.isActive()
	local NationalDayData = UserData:getLuaActivityData().national_day
	if not UserData:getLuaActivityData() or not NationalDayData then
	 	--print('national day erro__________________')
		return false
	end 
	
	local NationalDayConf = GameData:getArrayData('nationalday.dat');
	
	print(#NationalDayConf)
	for i=1,#NationalDayConf do
		local charge_cash = tonumber(NationalDayData.cash[tostring(i)])
		if not charge_cash then 
			charge_cash = 0
		end
		local got = tonumber(NationalDayData.got[tostring(i)])
		if not got then 
			got = 0
		end 
		if charge_cash >= tonumber(NationalDayConf[i]['Cash']) then 	-- 不可领取
			if got == 0 then -- 可领取 未领取
				return true
			end 
		end
	end
	
	return false
end

--活动是否超时-- 活动开始结束时间和延时领取时间
function NationalDay.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'nationalday' then
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

-- 进入国庆充值
function NationalDay.enter()
	
	-- 定义一些常量
	local NationalDayConf = GameData:getArrayData('nationalday.dat');
	local REWARD_LAND_COUNT = #NationalDayConf
	local REWARD_ITEM_COUNT = 3
	local DAY_TIME_PATH_HEAD = 'uires/ui_2nd/com/panel/nationalday/day_'
	local COLOR_FRAME = 'uires/ui_2nd/com/panel/common/frame_sred.png'

	
	local NationalDayData = 
	{
		-- cash = {
		-- ['1'] = 100,
		-- ['2'] = 0,
		-- ['3'] = 300,
		-- ['4'] = 400,
		-- ['5'] = 250,
		-- ['6'] = 0,
		-- ['7'] = 300
		-- },
		-- got  = {
		-- ['1'] = 0,
		-- ['2'] = 0,
		-- ['3'] = 0,
		-- ['4'] = 0,
		-- ['5'] = 0,
		-- ['6'] = 0,
		-- ['7'] = 0
		--}
	}

	local sceneObj
	local panel

	-- 按钮状态 0 不可领取 1 可以 2 已经领取
	local awardBtnType = {}
	-- 按钮集合
	local awardBtnArr  = {}
	-- 充值按钮
	local chargeCashPanelArr = {}
	-- 剩余时间
	local timeTxArr = {}
	local leftTimeLabelArr = {}
	-- 时间状态 0 已结束 1 还剩余 2 未开启
	local timeType = {2,2,2,2,2,2,2}
	
	-- 判断活动是否结束
	local function judgeOverTime()
		if NationalDay.isOverTime() then
			GameController.showPrompts(getLocalStringValue('E_STR_ACTIVITY_TIMEOUT_DESC'), COLOR_TYPE.RED)
			return true
		end
		return false
	end

	-- 设置按钮状态
	local function setAwardBtnType()
		for i = 1,REWARD_LAND_COUNT do
			local charge_cash = tonumber(NationalDayData.cash[tostring(i)])
			if not charge_cash then 
				charge_cash = 0
			end
			local got = tonumber(NationalDayData.got[tostring(i)])
			if not got then 
				got = 0
			end 
			if charge_cash < tonumber(NationalDayConf[i]['Cash']) then 	-- 不可领取
				awardBtnType[i] = 0	
			else
				if got == 0 then -- 可领取 未领取
					awardBtnType[i] = 1
				elseif got == 1 then -- 已领取
					awardBtnType[i] = 2
				end 
			end
		end
	end

	-- 设置时间状态
	local function setTimeType()
		local conf = GameData:getArrayData('activities.dat')
		local data
		table.foreach(conf , function (_ , v)
			if v['Key'] == 'nationalday' then
				data = v
			end
		end)

		if data then

			if data.StartTime ~= nil and data.StartTime ~= '' then 
				local serverTime = UserData:getServerTime()
				local actyStartTime = UserData:convertTime(1,data.StartTime)
				local actyEndTime   = UserData:convertTime(1,data.EndTime)

				    local stTab = os.date('*t',actyStartTime)
                	local seTab = os.date('*t',serverTime)
                	local edTab = os.date('*t',actyEndTime)

                	-- print('stTab'..stTab.year..' '..stTab.month..' '..stTab.day..' '..stTab.hour..' '..stTab.min..' '..stTab.sec)
                	-- print('seTab'..seTab.year..' '..seTab.month..' '..seTab.day..' '..seTab.hour..' '..seTab.min..' '..seTab.sec)
                	-- print('edTab'..edTab.year..' '..edTab.month..' '..edTab.day..' '..edTab.hour..' '..edTab.min..' '..edTab.sec)

                	-- print('se time'..serverTime)
                	-- print('start'..actyStartTime)
                	-- print('end'..actyEndTime)
				
				if serverTime < actyStartTime then -- 未开启
					for i=1,REWARD_LAND_COUNT do
                		timeType[i] = 2
                	end
                elseif serverTime > actyEndTime then -- 已结束
                	for i=1,REWARD_LAND_COUNT do
                		timeType[i] = 0
                	end
                else 				-- 活动时间内
                	-- 向上取整
                	local dayIndex  = math.ceil(tonumber(serverTime - actyStartTime)/24/3600)
                	--print('day index'..dayIndex..'left time'..leftTime..'sub'..tonumber(actyEndTime - serverTime))
                	
                	if dayIndex < 1 or dayIndex > REWARD_LAND_COUNT then 
                		return
                	end
                	
                	-- local leftTime  = tonumber(actyEndTime - serverTime) - (REWARD_LAND_COUNT - dayIndex)*24*3600
                	local leftTime  = tonumber(serverTime - actyStartTime) - (dayIndex - 1)*24*3600
                	
                	for i=1,REWARD_LAND_COUNT do
                		chargeCashPanelArr[i]:setVisible(false)
                		if i < dayIndex then
                			timeType[i] = 0
                		elseif i == dayIndex then 
                			timeType[i] = 1
                			leftTimeLabelArr[i]:setTime(leftTime)
                			-- 如果在活动当日且未领取领取
                			if NationalDayData.got[tostring(i)]  ~= 1 then
                				chargeCashPanelArr[i]:setVisible(true)
                			end
                		else
                			timeType[i] = 2
                		end 
                	end

                end
            end
		
		end

	end

	-- 刷新按钮
	local function updatePanel()

		setAwardBtnType()
		setTimeType()

		for i=1,REWARD_LAND_COUNT do
			-- 刷新时间
			print(REWARD_LAND_COUNT)
			print(timeType[i])
			if timeType[i] == 0 then 
				timeTxArr[i]:setText(getLocalStringValue('E_STR_WELFARE_END'))
			 	timeTxArr[i]:setColor(ccc3(166,166,166))
				leftTimeLabelArr[i]:setVisible(false)
			elseif timeType[i] == 1 then
				timeTxArr[i]:setText(getLocalStringValue('E_STR_COUNTDOWN'))
				timeTxArr[i]:setColor(COLOR_TYPE.ORANGE)
				leftTimeLabelArr[i]:setVisible(true)
			elseif timeType[i] == 2 then
				timeTxArr[i]:setText(getLocalStringValue('LS_NOT_OPEN_YET'))			
				timeTxArr[i]:setColor(COLOR_TYPE.ORANGE)
				leftTimeLabelArr[i]:setVisible(false)
			end 

			-- 刷新按钮状态
			if awardBtnType[i] == 0 then
				awardBtnArr[i]:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
		  		awardBtnArr[i]:setTouchEnable(false)
		  		awardBtnArr[i]:setNormalButtonGray(true)
			elseif awardBtnType[i] == 1 then 
				awardBtnArr[i]:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
		  		awardBtnArr[i]:setTouchEnable(true)
		  		awardBtnArr[i]:setNormalButtonGray(false)
			elseif awardBtnType[i] == 2 then 
				awardBtnArr[i]:setText(getLocalStringValue('E_STR_ACCPAY_GOT_REWARD_1'))
		  		awardBtnArr[i]:setTouchEnable(false)
		  		awardBtnArr[i]:setNormalButtonGray(true)
			end 
		end
	end

	local function onHide()
		-- body
	end 

	local function onShow()
		-- body
	end

	local function init()
		-- body
		local root = panel:GetRawPanel()
		--关闭
		local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local vScrollView = tolua.cast(root:getChildByName('reward_sv'),'UIScrollView')
		vScrollView:setClippingEnable(true)
    	vScrollView:setDirection(SCROLLVIEW_DIR_VERTICAL)

    	for i=1,REWARD_LAND_COUNT do
    		local rewardLand = createWidgetByName('panel/national_day_rewards_panel.json')
			
			--充值信息 value/300
			local charge_Panel = tolua.cast(rewardLand:getChildByName('charge_Panel'),'UIPanel')
			charge_Panel:setVisible(false)
			table.insert(chargeCashPanelArr,charge_Panel)
			local txCharge = tolua.cast(charge_Panel:getChildByName('ratio_tx'),'UILabel')
			local charge_cash_limit = tonumber(NationalDayConf[i]['Cash'])
			local charge_cash = tonumber(NationalDayData.cash[tostring(i)])
			if not charge_cash then 
				charge_cash = 0
			end
			txCharge:setText(charge_cash..'/'..charge_cash_limit)
			if charge_cash >= charge_cash_limit then 
				txCharge:setColor(COLOR_TYPE.GREEN)
			else
				txCharge:setColor(COLOR_TYPE.RED) 
			end


			-- 设置天数艺术字
			local dayImg = tolua.cast(rewardLand:getChildByName('day_1_txt_img'),'UIImageView')
			dayImg:setTexture(DAY_TIME_PATH_HEAD..i..'.png')

			-- 按钮
			local getAwrardBtn = tolua.cast(rewardLand:getChildByName('reveice_btn'),'UITextButton')
			getAwrardBtn:setNormalButtonGray(true)
			table.insert(awardBtnArr,getAwrardBtn)
			GameController.addButtonSound(getAwrardBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
			getAwrardBtn:registerScriptTapHandler(function ()
				-- 判断是否超时
				if judgeOverTime() then
					return
				end
				-- 判断状态确定是否可以点击发出请求
				if awardBtnType[i] == 1 then
					local pJson = { id = i }
					Message.sendPost('get_national_day_rewards','activity',json.encode(pJson),function (jsondata)

						--cclog(jsondata)
						local response = json.decode(jsondata)
						local code = tonumber(response.code)
						if code == 0 then
						    local data     = response['data']
							local awards   = data['awards']
							local awardStr = json.encode(awards)
							UserData.parseAwardJson(awardStr)
							GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
							-- 刷新状态
							NationalDayData.got[tostring(i)] = 1
							local luaNationalDayData = UserData:getLuaActivityData().national_day
							if luaNationalDayData then 
								luaNationalDayData.got[tostring(i)] = 1
							end 
							-- 刷新界面
							updatePanel()	
						end
					end)
					 	
				end
				
			end)		

			-- 时间
			 local timeTx = tolua.cast(rewardLand:getChildByName('info_tx'),'UILabel')
			 timeTx:setPreferredSize(120,1)
			 
			 local leftTimeLabel = UICDLabel:create()
			 leftTimeLabel:setVisible(true)
			 leftTimeLabel:setFontSize(20)
			 leftTimeLabel:setFontColor(COLOR_TYPE.GREEN)
			 leftTimeLabel:setPosition(ccp(timeTx:getPosition().x, 20))
			 -- 倒计时结束 刷新
			 leftTimeLabel:registerTimeoutHandler(function ()
				updatePanel()
			 end)
			 
			 rewardLand:addChild(leftTimeLabel)
			 timeTx:setVisible(true)
			 
			 table.insert(timeTxArr, timeTx)
			 table.insert(leftTimeLabelArr, leftTimeLabel)

			for j=1,REWARD_ITEM_COUNT do
				local rewardFrame = tolua.cast(rewardLand:getChildByName('card_nei_img'),'UIImageView')
				rewardFrame:setTouchEnable(true)
				local rewardPhoto  = tolua.cast(rewardFrame:getChildByName('frame_'..j..'_ico'),'UIImageView')
				local rewardIco    = tolua.cast(rewardPhoto:getChildByName('reward_ico'),'UIImageView')
				local rewardNameTx = tolua.cast(rewardPhoto:getChildByName('name_tx'),'UILabel')
				local rewardNumTx  = tolua.cast(rewardPhoto:getChildByName('number_tx'),'UILabel')
				rewardNameTx:setPreferredSize(110,1)
 				
 				local awardTmp = UserData:getAward(NationalDayConf[i]['Award'.. j])
				if awardTmp then
					-- 判断个数是否为0如果为0隐藏
					local rewardNum = tonumber(awardTmp.count)
					if  rewardNum == 0 then
						rewardFrame:setVisible(false)
					elseif rewardNum > 0 then
						rewardFrame:setVisible(true)
					end

					rewardNameTx:setText(awardTmp.name)
					--rewardNameTx:setColor(awardTmp.color) -- 不加颜色吗
					rewardNumTx:setText(toWordsNumber(tonumber(awardTmp.count)))
					rewardIco:setTexture(awardTmp.icon)
					local awardStr = NationalDayConf[i]['Award' .. j]
					rewardIco:setTouchEnable(true) 
					rewardIco:registerScriptTapHandler(function()
					    UISvr:showTipsForAward(awardStr)
				    end)

					-- 如果奖励是第一列
					if j == 1 then
						rewardPhoto:setTexture(COLOR_FRAME) --彩色边框
						local light = CUIEffect:create()
						light:Show("yellow_light", 0)
						light:setScale(0.81)
						light:setPosition( ccp(0, 0))
						light:setAnchorPoint(ccp(0.5, 0.5))
						rewardPhoto:getContainerNode():addChild(light)
						light:setZOrder(100)
					end

				end 
			end

    		vScrollView:addChildToBottom(rewardLand)
    	end
		vScrollView:scrollToTop()

    	--刷新
    	updatePanel()
	end


	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/national_day_panel.json','national-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('party_bg_img','party_img')

		panel:registerInitHandler(init)
		panel:registerOnShowHandler(onShow)
		panel:registerOnHideHandler(onHide)

		UiMan.show(sceneObj)
	end

	local function getNationaldayResponse()
		Message.sendPost('national_day_get','activity','{}',function (jsondata)

			cclog(jsondata)
			
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			if code == 0 then
				NationalDayData = response.data.national_day

			    -- 创建主界面
				createPanel()
			end
		end)
	end

	--国庆充值入口
	getNationaldayResponse()
end