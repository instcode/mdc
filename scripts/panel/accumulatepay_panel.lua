Accumulatepay = {}

function Accumulatepay.isActive()
	local activity = UserData:getLuaActivityData()
	if not activity then
		return false
	end
	local AccumuPayData = activity.accumulate_pay
	 if not AccumuPayData then 
	 	--print('accpay erro__________________')
	 	return false
	 end 
	 local charge_cash = AccumuPayData.cash 
	 if not charge_cash then 
		charge_cash = 0
	 end 
	 local AccumuPayConf = GameData:getArrayData('accumulatepay.dat')
	 for i=1,7 do
	 
	 local cash_begin = tonumber(AccumuPayConf[i].CashBegin)   
		--print('************'..charge_cash..'cash begin'..cash_begin)
		local got = tonumber(AccumuPayData.got[tostring(i)])
		if not got then 
			got = 0
		end 
		
		if charge_cash >= cash_begin then -- 未达标 不可以领取		
			if  got == 0 then -- 0 未领取-可以领取
				return true
			end 			
		end
	end
	 
	return false
end

-- 活动是否超时-- 活动时间和活动延时时间
function Accumulatepay.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'accumulatepay' then
			conf = v
		end
	end)

	if conf == nil then
		return true
	end

	if tonumber(conf.Normalization) == 0 then -- 非常态活动

		--print('Normalization activity')
        local actyStartTime
        local actyEndTime
        if conf.StartTime ~= nil and conf.StartTime ~= '' then -- 优先判断StartTime字段
            actyStartTime = UserData:convertTime(1, conf.StartTime)
            actyEndTime = UserData:convertTime(1, conf.EndTime) + (tonumber(conf.DelayDays))*86400 -- 加上奖励的领取延时2天 这两天充值元宝不计
        else
            local serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
            actyStartTime = serverOpenTime + (tonumber(conf.OpenDay) - 1)*86400
            actyEndTime = serverOpenTime + (tonumber(conf.OpenDay) + tonumber(conf.Duration) - 1)*86400
        end
        local nowTime = UserData:getServerTime()
        --print('server time'..nowTime..'activity startTime'..actyStartTime..'activity endTime'..actyEndTime..'DelayDays'..tonumber(conf.DelayDays))
        if nowTime < actyStartTime or nowTime > actyEndTime then
            return true
        end
    else    -- 常态活动
    	--print('not Normalization activity')
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

-- 进入累计充值
function Accumulatepay.enter()
	local sceneObj
	local panel

	-- 定义一些常量
	local REWARD_LAND_COUNT = 7
	local REWARD_ITEM_COUNT = 4
	local COLOR_FRAME = 'uires/ui_2nd/com/panel/common/frame_sred.png'
	-- 充值请求内容
	local AccumuPayConf = GameData:getArrayData('accumulatepay.dat')
	local AccumuPayData = 
	{
		-- cash = 8000,
		-- got = {
		-- ['1'] = 1,
		-- ['2'] = 1,
		-- ['3'] = 1,
		-- ['4']= 1
		-- }
	}


	local awardBtnType = {}			-- 按钮的状态	0 - 不可领取 1 可以 2 已经领取	
	local awardBtnArr = {}			-- 按钮的集合

		-- 判断活动是否结束
	local function judgeOverTime()
		if Accumulatepay.isOverTime() then
			GameController.showPrompts(getLocalStringValue('E_STR_ACTIVITY_TIMEOUT_DESC'), COLOR_TYPE.RED)
			return true
		end
		return false
	end

	local function setAwardBtnType()
		-- 当前已充值
    	local charge_cash = tonumber(AccumuPayData.cash)

		for i = 1, REWARD_LAND_COUNT do
		
			local cash_begin = tonumber(AccumuPayConf[i].CashBegin)   
		
			if charge_cash < cash_begin then -- 未达标 不可以领取
				awardBtnType[i] = 0
			else
				
				if not AccumuPayData.got[tostring(i)] then
					awardBtnType[i] = 1
				else
					if  tonumber(AccumuPayData.got[tostring(i)]) == 0 then -- 0 未领取-可以领取
						awardBtnType[i] = 1
					else -- 1 已经领取
						awardBtnType[i] = 2
					end
				end 			
				
			end
		end
	end
	
	-- 刷新数据
	local function updatePanel()
		-- 刷新相应的资源
		setAwardBtnType()
		
		for i=1,REWARD_LAND_COUNT do
			-- 按钮状态
 			if awardBtnType[i] == 0 then--不可领取-灰色
		  		awardBtnArr[i]:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
		  		awardBtnArr[i]:setTouchEnable(false)
		  		awardBtnArr[i]:setNormalButtonGray(true)
		  	elseif awardBtnType[i] == 1 then --领取-高亮
		  		awardBtnArr[i]:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
		  		awardBtnArr[i]:setTouchEnable(true)
		  		awardBtnArr[i]:setNormalButtonGray(false)
		  	elseif awardBtnType[i] == 2 then -- 已经领取-灰色
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

	-- 初始化界面元素
	local function init()
	
		local root = panel:GetRawPanel()
		-- 关闭
		local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local timeLine = tolua.cast(root:getChildByName('info_time'),'UILabel')
		-- 活动纵向滚动
		local sv = tolua.cast(root:getChildByName('reward_scroll_view'),'UIScrollView')
		sv:setClippingEnable(true)
    	sv:setDirection(SCROLLVIEW_DIR_VERTICAL)

    	-- 界面时间开始 结束
    	local conf = GameData:getArrayData('activities.dat')
		local data
		table.foreach(conf , function (_ , v)
			if v['Key'] == 'accumulatepay' then
				data = v
			end
		end)

		timeLine:setText('')
		if data then
			local actyStartTime
	        local actyEndTime
	        if data.StartTime ~= nil and data.StartTime ~= '' then -- 优先判断StartTime字段
	            actyStartTime = UserData:convertTime(1, data.StartTime)
	            actyEndTime = UserData:convertTime(1, data.EndTime)	-- 不加延时时间
	        else
	            local serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
	            actyStartTime = serverOpenTime + (tonumber(data.OpenDay) - 1)*86400
	            actyEndTime = serverOpenTime + (tonumber(data.OpenDay) + tonumber(data.Duration) - 1)*86400
	        end
	        local sTab = os.date('*t', actyStartTime )
	        local eTab = os.date('*t', actyEndTime - 86400) -- 显示差1天

            -- 超过领取时间
            local nowTime = UserData:getServerTime()
            -- 领取时间
			if not judgeOverTime() then
				-- 大于活动时间 - 只能领取
				if nowTime > (actyEndTime) then
				 	timeLine:setText(getLocalString('E_STR_ACCPAY_REWARD_OUT_OF_TIME'))
				 	timeLine:setColor(COLOR_TYPE.RED)
				-- 正常显示活动时间
				else
					timeLine:setText(string.format(getLocalString('E_STR_ACTIVITY_TIEM_DESC'), tonumber(sTab.month) , tonumber(sTab.day) ,tonumber(eTab.month) , tonumber(eTab.day)))
					timeLine:setColor(COLOR_TYPE.GREEN)
				end 
			end 
		end

    	-- 当前已充值
    	local charge_cash = tonumber(AccumuPayData.cash)       
		
    	-- 循环创建

    	for i=1,REWARD_LAND_COUNT do
    		-- 创建奖励栏
			local rewardVView = createWidgetByName('panel/accpay_rewards_panel.json')

			-- 信息 充值%d-%d即可获得
			local infoTx = tolua.cast(rewardVView:getChildByName('info'),'UILabel')
			-- 充值信息
 			local localInfoHead = getLocalStringValue('E_STR_ACCPAY_RECHARGE')
 			--print(localInfoHead)
			local cash_begin = tonumber(AccumuPayConf[i].CashBegin)
			local infoBuff   = string.format(localInfoHead,cash_begin)
			infoTx:setText(infoBuff)
			infoTx:setColor(COLOR_TYPE.ORANGE)
			
			-- 值串 (已冲/最小值)
			local valueTx = tolua.cast(rewardVView:getChildByName('value'),'UILabel')
			-- 值信息
			valueTx:setText('('..charge_cash..'/'..cash_begin..')')
			-- 设置位置
			valueTx:setPosition(ccp(infoTx:getPosition().x+infoTx:getContentSize().width+5, infoTx:getPosition().y))
			valueTx:setAnchorPoint(ccp(0,0.5))
			-- 设置颜色 和初始化按钮状态
			if charge_cash >= cash_begin then 
				valueTx:setColor(COLOR_TYPE.WHITE)
			else
				valueTx:setColor(COLOR_TYPE.RED)
			end
			
			-- 设置按钮状态
			local getAwrardBtn = tolua.cast(rewardVView:getChildByName('receive_btn'),'UITextButton')
			-- 插入到按钮集合表中
			table.insert(awardBtnArr,getAwrardBtn)
			GameController.addButtonSound(getAwrardBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
			
			-- 点击事件
			getAwrardBtn:registerScriptTapHandler(function ()
				-- 判断是否超时
				if judgeOverTime() then
					return
				end
				-- 判断状态确定是否可以点击发出请求
				if awardBtnType[i] == 1 then
					local pJson = { id = i }
					--请求
					--print('click buuton id'..i)
					Message.sendPost('get_accumulate_pay_rewards','activity',json.encode(pJson),function (jsondata)

						--cclog(jsondata)
						local response = json.decode(jsondata)
						local code = tonumber(response.code)
						if code == 0 then
						    local data = response['data']
							local awards = data['awards']
							local awardStr = json.encode(awards)
							UserData.parseAwardJson(awardStr)
							--GameController.showAwardsFlowText( awards )
							GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
							-- 刷新状态
							AccumuPayData.got[tostring(i)] = 1
							local luaAccumuPayData = UserData:getLuaActivityData().accumulate_pay
							if luaAccumuPayData then 
								luaAccumuPayData.got[tostring(i)] = 1
							end
							-- 刷新界面
							updatePanel()	
						end
					end)
					 	
				end
				
			end)
				
				
			for j=1,REWARD_ITEM_COUNT do
				-- 创建奖励栏
				local rewardFrame  = createWidgetByName('panel/accpay_reward_icon.json')
				rewardFrame:setTouchEnable(true)
				local rewardPhoto  = tolua.cast(rewardFrame:getChildByName('item_photo'),'UIImageView')
				local rewardIco    = tolua.cast(rewardPhoto:getChildByName('item_ico'),'UIImageView')
				local rewardNameTx = tolua.cast(rewardPhoto:getChildByName('item_name_tx'),'UILabel')
				local rewardNumTx  = tolua.cast(rewardPhoto:getChildByName('item_num_tx'),'UILabel')

				local awardTmp = UserData:getAward(AccumuPayConf[i]['Award' .. j])
				if awardTmp then 
					-- 判断个数是否为0 为0隐藏
					if tonumber(awardTmp.count) == 0 then
						 rewardFrame:setVisible(false)
					elseif  tonumber(awardTmp.count) > 0 then
						rewardFrame:setVisible(true)
						local size = rewardFrame:getRect()
						local width = size:getMaxX() - size:getMinX()
						rewardFrame:setPosition(ccp(rewardFrame:getPosition().x+width *(j-1) + 21,rewardFrame:getPosition().y+15))
						rewardFrame:setWidgetZOrder(99)
						rewardVView:addChild(rewardFrame)
					end
					
					rewardNameTx:setText(awardTmp.name)
					rewardNameTx:setColor(awardTmp.color)
					rewardNumTx:setText(toWordsNumber(tonumber(awardTmp.count)))
					rewardIco:setTexture(awardTmp.icon)
					local awardStr = AccumuPayConf[i]['Award' .. j] 
						rewardIco:registerScriptTapHandler(function()
					        UISvr:showTipsForAward(awardStr)
				        end)
							
					-- 设置边框颜色
					if awardTmp.color.r == COLOR_TYPE.RED.r and awardTmp.color.g == COLOR_TYPE.RED.g and awardTmp.color.b == COLOR_TYPE.RED.b then
						rewardPhoto:setTexture('uires/ui_2nd/com/panel/common/frame_red.png')
					elseif awardTmp.color.r == COLOR_TYPE.WHITE.r and awardTmp.color.g == COLOR_TYPE.WHITE.g and awardTmp.color.b == COLOR_TYPE.WHITE.b then
						rewardPhoto:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
					elseif awardTmp.color.r == COLOR_TYPE.PURPLE.r and awardTmp.color.g == COLOR_TYPE.PURPLE.g and awardTmp.color.b == COLOR_TYPE.PURPLE.b then
						rewardPhoto:setTexture('uires/ui_2nd/com/panel/common/frame_purple.png')
					elseif awardTmp.color.r == COLOR_TYPE.ORANGE.r and awardTmp.color.g == COLOR_TYPE.ORANGE.g and awardTmp.color.b == COLOR_TYPE.ORANGE.b then
						rewardPhoto:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
					end

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

			sv:addChildToBottom(rewardVView)
    	end
		
		sv:scrollToTop()		

		-- 刷新
		updatePanel()  
	end
	
	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/accpay_panel.json','accpay-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('accpay_award_bg_img','accpay_award_img')

		panel:registerInitHandler(init)
		panel:registerOnShowHandler(onShow)
		panel:registerOnHideHandler(onHide)

		UiMan.show(sceneObj)
	end
	
	local function getAccumulatepayResponse()
		Message.sendPost('accumulate_pay_get','activity','{}',function (jsondata)

			--cclog(jsondata)
			
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			if code == 0 then
				AccumuPayData = response.data.accumulate_pay
			    -- 创建主界面
				createPanel()
			end
		end)
	end

	--累计充值入口
	getAccumulatepayResponse()
end