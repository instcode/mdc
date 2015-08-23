Avfood = {}

function Avfood.isActive()
	local AvfoodData = UserData:getLuaActivityData().food
	if not AvfoodData then
	 	--print('national day erro__________________')
		return false
	end 
	local AvfoodConf = GameData:getArrayData('avfood.dat');
	local nowTime = UserData:getServerTime()
	local time = Time.beginningOfToday()
	local diffTime = nowTime - time
	local tab = os.date('*t' , nowTime)
	local hour =tonumber(string.format('%02d',tab.hour))

	local state ={false,false}

	for i=1,2 do
		local startime = tonumber(AvfoodConf[i].StartHour) * 3600 
		local endTime = tonumber(AvfoodConf[i].EndHour) * 3600
        if diffTime > startime and diffTime < endTime and (AvfoodData[tostring(i)] == 0 ) then
        	state[i] = true
        elseif (diffTime < startime or diffTime > endTime) and (AvfoodData[tostring(i)] == 0 ) then
        	state[i] = false
        elseif AvfoodData[tostring(i)] ~= 0 then
        	state[i] = false
        end
	end
	local fal = state[1] or state[2]
	return fal
	--return false
end

--活动是否超时-- 活动开始结束时间和延时领取时间
function Avfood.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'avfood' then
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

-- 进入行军粮饷
function Avfood.enter()
	
	-- 定义一些常量
	local DAY_TIME_PATH_HEAD = 'uires/ui_2nd/com/panel/nationalday/day_'
	local COLOR_FRAME = 'uires/ui_2nd/com/panel/common/frame_sred.png'

	local AVFoodConf = GameData:getArrayData('avfood.dat');

	local sceneObj
	local panel
	local root
	local genBtn
	local Btnstate

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
	end

	-- 刷新按钮
	local function updatePanel()
		local food = tolua.cast(root:getChildByName('user_food_tx'),'UILabel')
		food:setText(toWordsNumber(PlayerCoreData.getFoodValue()))

		local AvfoodData = UserData:getLuaActivityData().food
		local AvfoodConf = GameData:getArrayData('avfood.dat');
		printall(AvfoodData)
		local nowTime = UserData:getServerTime()
		local time = Time.beginningOfToday()
		local diffTime = nowTime - time
		local tab = os.date('*t' , nowTime)
		local hour =tonumber(string.format('%02d',tab.hour))
		local startime={}
		local endTime={}



		for i=1,2 do
			startime[i] = tonumber(AvfoodConf[i].StartHour) * 3600 
			endTime[i] = tonumber(AvfoodConf[i].EndHour) * 3600
			print(startime[i])
			print(endTime[i])
			print(startime[i] - endTime[i])
	        -- if diffTime > startime and diffTime < endTime and (AvfoodData[tostring(i)] == 0 ) then
	        -- 	genBtn:setNormalButtonGray(false)
	        -- 	genBtn:setTouchEnable(true)
	        -- 	Btnstate[i] =0
	        -- 	cclog("xxxxxxxxxxxxxxxxxxx" ..Btnstate)  --可以领取
	        -- elseif (diffTime < startime or diffTime > endTime) and (AvfoodData[tostring(i)] == 0 ) then
	        -- 	genBtn:setNormalButtonGray(true)
	        -- 	genBtn:setTouchEnable(false)
	        -- 	Btnstate[i] =1
	        -- 	cclog("xxxxxxxxxxxxxxxxxxx" ..Btnstate)  --时间过期
	        -- elseif AvfoodData[tostring(i)] ~= 0 then
	        -- 	genBtn:setNormalButtonGray(true)
	        -- 	genBtn:setTouchEnable(false)
	        -- 	Btnstate[i] =2
	        -- 	cclog("xxxxxxxxxxxxxxxxxxx" ..Btnstate)  --已经领过了
	        -- end
		end

		if diffTime > startime[1] and diffTime < endTime[1] then
			if AvfoodData['1'] == 0 then
				Btnstate = 0
				genBtn:setNormalButtonGray(false)
	        	genBtn:setTouchEnable(true)
			else
				Btnstate = 2
				genBtn:setNormalButtonGray(true)
	        	genBtn:setTouchEnable(false)
			end
		else
			if diffTime > startime[2] and diffTime < endTime[2]  then
				if AvfoodData['2'] == 0 then
					Btnstate = 0
					genBtn:setNormalButtonGray(false)
	        		genBtn:setTouchEnable(true)
				else
					Btnstate = 2
					genBtn:setNormalButtonGray(true)
	        		genBtn:setTouchEnable(false)
				end
			else
				Btnstate = 1
				genBtn:setNormalButtonGray(true)
	        	genBtn:setTouchEnable(false)
			end
		end
	end

	local function clickGen()
		--cclog("btn state ======"  .. Btnstate)
		if Btnstate == 0 then
			Message.sendPost('get_food','activity','{}',function (jsondata)

				cclog(jsondata)
				
				local response = json.decode(jsondata)
				local code = tonumber(response.code)
				if code ~= 0 then
					cclog('request error : '..response.desc)
					return
				end
				local data = response.data
				local food = tonumber(data.food) or 0 

				PlayerCoreData.addFoodDelta(food)



				local AvfoodData = UserData:getLuaActivityData().food
				local AvfoodConf = GameData:getArrayData('avfood.dat');
				--printall(AvfoodData)
				local nowTime = UserData:getServerTime()
				local time = Time.beginningOfToday()
				local diffTime = nowTime - time
				local tab = os.date('*t' , nowTime)
				local hour =tonumber(string.format('%02d',tab.hour))
				for i=1,2 do
					local startime = tonumber(AvfoodConf[i].StartHour) * 3600 
					local endTime = tonumber(AvfoodConf[i].EndHour) * 3600
			        if diffTime > startime and diffTime < endTime  then
			        	AvfoodData[tostring(i)] = diffTime
			        end
				end
				updatePanel()
				UpdateMainCity()
				local normalaward = getGlobalIntegerValue("DailyActivityFreeFoodCount")
				if food > tonumber(normalaward) then 
					foodExtra = food - tonumber(normalaward)
					GameController:showPrompts(string.format(getLocalString('E_STR_AVFOOD_FOODEXTRA'),foodExtra), COLOR_TYPE.GREEN)
				else
					GameController:showPrompts(getLocalString('E_STR_GET_SUCCEED'), COLOR_TYPE.GREEN)
				end
			end)
		elseif Btnstate == 1 then
				GameController:showPrompts(getLocalString('E_STR_AVFOOD_MISSTIME'), COLOR_TYPE.RED)
		elseif Btnstate == 2 then
				GameController:showPrompts(getLocalString('E_STR_AVFOOD_HADGEN'), COLOR_TYPE.RED)
		end
	end

	local function onHide()
		-- body
	end 

	local function onShow()
		-- body
	end

	local function init()
		root = panel:GetRawPanel()

		local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local foodCost = tolua.cast(root:getChildByName('food_num_tx'), 'UILabel')
		foodCost:setText(GameData:getGlobalValue('DailyActivityFreeFoodCount'))

		genBtn = tolua.cast(root:getChildByName('buy_btn'),'UIButton')
		genBtn:registerScriptTapHandler(clickGen)
		GameController.addButtonSound(genBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local infoTab = {}		
		for i=1,5 do
			infoTab[i] = tolua.cast(root:getChildByName('info_' .. i .. '_tx'),'UILabel')
			infoTab[i]:setPreferredSize(260,1)
		end


    	updatePanel()
	end


	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/avfood_panel.json','freefood-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('buy_food_bg_img','root_img')

		panel:registerInitHandler(init)
		panel:registerOnShowHandler(onShow)
		panel:registerOnHideHandler(onHide)

		UiMan.show(sceneObj)
	end

	local function getAvfoodResponse()
		-- 创建主界面
		createPanel()
	end

	--入口
	getAvfoodResponse()
end