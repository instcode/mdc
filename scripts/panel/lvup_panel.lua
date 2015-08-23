LvUp = {}

function LvUp.isOver()
	local data
	if UserData.activity and UserData.activity.level_up then
		data = UserData.activity.level_up
	end
	if not data or data.bought == 0 then
		return true
	end
	local lvupConf = GameData:getArrayData('levelupgift.dat')
	for i=1,#lvupConf do
		if not data[tostring(lvupConf[i].Level)] then
			return false
		end
	end
	return true
end

function LvUp.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	table.foreach(data , function (_ , v)
		if v['Key'] == 'level_up' then
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
            actyEndTime = serverOpenTime + (tonumber(conf.OpenDay) + tonumber(conf.Duration) - 1)*86400 + tonumber(conf.DelayDays)*86400
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

function LvUp.enter()
	-- UI
	local sceneObj = nil
	local panel = nil
	local closeBtn = nil
	local allData
	local awardSv
	local cells = {}
	local updatePanel
	local needCash =  tonumber(GameData:getGlobalValue('LevelUpGiftPrice'))
	local lvupConf = GameData:getArrayData('levelupgift.dat')
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'level_up' then
			conf = v
		end
	end)

	if conf == nil then
		return
	end

	local function getPos(i)
		local x = 235 * ((i-1)%2)
		local y = -((i-1) - (i-1)%2)/2*120
		return ccp(x,y)
	end
	local function getCash(key)
		if allData.bought ~= 1 then
			GameController.showPrompts(getLocalStringValue('E_STR_CANNOT_GET'), COLOR_TYPE.RED)
			return
		end
		local level = PlayerCoreData.getPlayerLevel()
		if level < tonumber(key) then
			GameController.showPrompts(getLocalStringValue('E_STR_OPEN_LEVEL'), COLOR_TYPE.RED)
			return
		end
		args = {
			level = tonumber(key)
		}
		Message.sendPost('level_up_reward','activity',json.encode(args),function (jsondata)
			cclog(jsondata)
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			local data = response['data']
			if code == 0 then
				local cash = data.cash
				PlayerCoreData.addCashDelta( tonumber(cash))
				allData.reward[tostring(key)] = 1
				UserData.activity.level_up = allData
				updatePanel()
				GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
			end
		end)
	end
	local function buyGift(buyBtn)
		local cash = PlayerCoreData.getCashValue()
		if cash < needCash then
			GameController.showMessageBox(getLocalStringValue('E_STR_PAWNSHOP_NOT_ENOUGH_CASH'), MESSAGE_BOX_TYPE.OK_CANCEL,function ()
				genCashBoard()
			end)
			return
		end
		Message.sendPost('level_up_buy','activity','{}',function (jsondata)
			cclog(jsondata)
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			local data = response['data']
			if code == 0 then
				local cash = data.cash
				PlayerCoreData.addCashDelta( tonumber(cash))
				allData.bought = 1
				UserData.activity.level_up = allData
				buyBtn:setNormalButtonGray(true)
				buyBtn:setTouchEnable(false)
				buyBtn:setText(getLocalStringValue('E_STR_YET_BUY'))
				GameController.showPrompts(getLocalStringValue('E_STR_BUY_SUCCEED'), COLOR_TYPE.GREEN)
			end
		end)
	end
	local function updateCell(i,data,v)
		local view = cells[i]
		local lvTx = tolua.cast(view:getChildByName('lv_tx') , 'UILabel')
		local cashNumTx = tolua.cast(view:getChildByName('cash_num_tx') , 'UILabel')
		lvTx:setText('Lv'..data.Level)
		cashNumTx:setText(data.Reward)

    	local getBtn = tolua.cast(view:getChildByName('get_btn') , 'UITextButton')
    	getBtn:registerScriptTapHandler(function ()
			getCash(data.Level)
		end)
		GameController.addButtonSound(getBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		if v == 1 then
			getBtn:setNormalButtonGray(true)
			getBtn:setTouchEnable(false)
			getBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
		else
			getBtn:setNormalButtonGray(false)
			getBtn:setTouchEnable(true)
			getBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
		end
	end
	updatePanel = function()
		local index = 0
		for i=1,#lvupConf do
			if not allData.reward[tostring(lvupConf[i].Level)] then
				index = index + 1
				updateCell(index,lvupConf[i],0)
			end
		end
		for i=1,#lvupConf do
			if allData.reward[tostring(lvupConf[i].Level)] and allData.reward[tostring(lvupConf[i].Level)] == 1 then
				index = index + 1
				updateCell(index,lvupConf[i],1)
			end
		end
		awardSv:scrollToTop()
	end

    local function init()
    	root = panel:GetRawPanel()
    	closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local timeTx = tolua.cast(root:getChildByName('time_tx') , 'UILabel')
		local timeInfoTx = tolua.cast(root:getChildByName('time_info_tx') , 'UILabel')
		timeTx:setText('')
		timeCDTx = UICDLabel:create()
		timeCDTx:setFontSize(22)
		timeCDTx:setPosition(ccp(5,0))
		timeCDTx:setFontColor(ccc3(50, 240, 50))
		timeCDTx:setAnchorPoint(ccp(0,0.5))
		timeTx:addChild(timeCDTx)
		local infoTx = tolua.cast(root:getChildByName('info_1_tx') , 'UILabel')
		infoTx:setPreferredSize(550,1)

		local openServerTime = UserData:getOpenServerDays()
	    local beginTimeOfOpenServerTime = Time.beginningOfOneDay(openServerTime)
	    local nowTime = UserData:getServerTime()
	    local beginTime = beginTimeOfOpenServerTime + (tonumber(conf.OpenDay) - 1) * 86400
	    local endTime = beginTimeOfOpenServerTime + tonumber(conf.Duration) * 86400
	    local diffTime = endTime - nowTime
	    local diffDay = (nowTime - beginTimeOfOpenServerTime)/86400 + 1
	    if diffDay < tonumber(conf.OpenDay) then
	        timeTx:setVisible(false)
	        timeInfoTx:setVisible(false)
	    else
	    	timeTx:setVisible(true)
	    	timeInfoTx:setVisible(true)
	    	timeCDTx:setTime(diffTime)
	    end

	    if diffTime < 0 then
	    	timeCDTx:setVisible(false)
	    	timeTx:setText(getLocalStringValue('E_STR_WELFARE_END'))
	    	timeTx:setColor(COLOR_TYPE.RED)
	    end

		awardSv = tolua.cast(root:getChildByName('award_sv') , 'UIScrollView')
		awardSv:setClippingEnable(true)

		local buyBtn = tolua.cast(root:getChildByName('buy_btn') , 'UITextButton')
    	buyBtn:registerScriptTapHandler(function ()
			buyGift(buyBtn)
		end)
		GameController.addButtonSound(buyBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		if allData.bought == 1 then
			buyBtn:setNormalButtonGray(true)
			buyBtn:setTouchEnable(false)
			buyBtn:setText(getLocalStringValue('E_STR_YET_BUY'))
		else
			buyBtn:setNormalButtonGray(false)
			buyBtn:setTouchEnable(true)
			buyBtn:setText(getLocalStringValue('E_STR_BUY'))
		end

		for i=1,#lvupConf do
			local view = createWidgetByName('panel/lvup_gift_cell_panel.json')
			awardSv:addChildToBottom(view)
			view:setPosition(getPos(i))
			cells[#cells + 1] = view
		end
		updatePanel()
    end

    local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/lvup_gift_main_panel.json', 'lvup-panel-lua')
	    panel = sceneObj:getPanelObj()
	    panel:setAdaptInfo('gift_bg_img', 'title_img')

		panel:registerInitHandler(init)
		UiMan.show(sceneObj)
	end

	-- -- 入口
	local function getResponse()
		Message.sendPost('level_up_get','activity','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			local code = jsonDic.code
			if code ~= 0 then
				return
			end
			allData = jsonDic.data.level_up
			UserData.activity.level_up = allData
			createPanel()
		end)
	end
	
	getResponse()
end