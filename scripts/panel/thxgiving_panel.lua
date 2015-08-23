Thxgiving = {}

local isAward = true
local currPaid = 0
function Thxgiving.isActive()
	local thxgivingData = UserData:getLuaActivityData().thx_giving
	if not thxgivingData then
	 	return false and isAward
	end
	local maxAward = 0
	local rewardData = {}
	local conf = GameData:getArrayData('thxgiving.dat')
	for i,v in ipairs(conf) do
	 	table.insert(rewardData , v)
		maxAward = maxAward + 1
	end
	local paid = 0
	if currPaid == 0 then
		paid = thxgivingData.paid
	else
		paid = currPaid
	end
	local got = thxgivingData.got
	if not paid or paid < tonumber(rewardData[1].Paid) then 
		return false and isAward
	end

	for i=1,maxAward do
		if not got[tostring(i)] then
			if paid >= tonumber(rewardData[i].Paid) then
				return true and isAward
			end
		end
	end
	return false and isAward
end
function Thxgiving.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'thxgiving' then
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
function Thxgiving.enter()
	local MAX_AWARD = 0
	local sceneObj
	local panel
	local conf
	local helpPanel
	local helpScene
	local rewardSv
	local allCost = 0
	local moveHeight = 0
	local rewardData = {}
	local allStatus = {}
	local getAllAwardBtns = {}

	local function getConf()
		thxgivingData = GameData:getArrayData('thxgiving.dat')
		for i,v in ipairs(thxgivingData) do
			table.insert(rewardData , v)
			MAX_AWARD = MAX_AWARD + 1
		end

		local data = GameData:getArrayData('activities.dat')
		table.foreach(data , function (_ , v)
			if v['Key'] == 'thxgiving' then
				conf = v
			end
		end)
	end
	local function updateMainPanel()
		isAward = false
		for i=1,MAX_AWARD do
			if not allStatus[tostring(i)] and allCost >= tonumber(rewardData[i].Paid) then
				getAllAwardBtns[MAX_AWARD-i+1]:setNormalButtonGray(false)
				getAllAwardBtns[MAX_AWARD-i+1]:setTouchEnable(true)
				getAllAwardBtns[MAX_AWARD-i+1]:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
				isAward = true
			elseif allStatus[tostring(i)] == 1 then
				getAllAwardBtns[MAX_AWARD-i+1]:setNormalButtonGray(true)
				getAllAwardBtns[MAX_AWARD-i+1]:setTouchEnable(false)
				getAllAwardBtns[MAX_AWARD-i+1]:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			else 
				getAllAwardBtns[MAX_AWARD-i+1]:setNormalButtonGray(true)
				getAllAwardBtns[MAX_AWARD-i+1]:setTouchEnable(false)
				getAllAwardBtns[MAX_AWARD-i+1]:setText('')
				local tx = UILabel:create()
				tx:setFontSize(20)
				tx:setPreferredSize(130,1)
				tx:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
				getAllAwardBtns[MAX_AWARD-i+1]:addChild(tx)
				-- getAllAwardBtns[MAX_AWARD-i+1]:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))			
			end
		end
	end
	local function OnGetAward(i)
		args = {
			id = i,
		}
		Message.sendPost('get_thx_giving_rewards','activity',json.encode(args),function (jsondata)

			cclog(jsondata)
			
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			local awards = response.data.awards
			if code == 0 then
				allStatus[tostring(i)] = 1
				UserData.parseAwardJson(json.encode(awards))
				GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
			else
				allStatus[tostring(i)] = 1
				GameController.showPrompts(getLocalStringValue('E_STR_GETAWARD_OVERTIME'), COLOR_TYPE.RED)
			end
			updateMainPanel()
		end)
	end
	local function updateAwardCell(i,rewardVView)
		rewardFrameImg = tolua.cast(rewardVView:getChildByName('reward_frame_img') , 'UIImageView')
		rewardIco = tolua.cast(rewardVView:getChildByName('reward_ico') , 'UIImageView')
		rewardNameTx = tolua.cast(rewardVView:getChildByName('reward_name_tx') , 'UILabel')
		numTx = tolua.cast(rewardVView:getChildByName('num_tx') , 'UILabel')
		radioTx = tolua.cast(rewardVView:getChildByName('radio_tx') , 'UILabel')
		if allCost >= tonumber(rewardData[i].Paid) then
			radioTx:setText(rewardData[i].Paid..'/'..rewardData[i].Paid)
			radioTx:setColor(ccc3(50,240,50))
		else
			radioTx:setText(allCost..'/'..rewardData[i].Paid)
			radioTx:setColor(ccc3(255,0,0))
		end
		getBtn = tolua.cast(rewardVView:getChildByName('get_btn') , 'UITextButton')
		getBtn:registerScriptTapHandler(function ()
			OnGetAward(i)
		end)
		table.insert(getAllAwardBtns,getBtn)

		award = UserData:getAward(rewardData[i].Award1)
		numTx:setText(toWordsNumber(tonumber(award.count)))
		rewardIco:setTexture(award.icon)
		rewardNameTx:setText(award.name)

		-- 设置边框颜色
		if award.color.r == COLOR_TYPE.RED.r and award.color.g == COLOR_TYPE.RED.g and award.color.b == COLOR_TYPE.RED.b then
			rewardFrameImg:setTexture('uires/ui_2nd/com/panel/common/frame_red.png')
		elseif award.color.r == COLOR_TYPE.WHITE.r and award.color.g == COLOR_TYPE.WHITE.g and award.color.b == COLOR_TYPE.WHITE.b then
			rewardFrameImg:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
		elseif award.color.r == COLOR_TYPE.PURPLE.r and award.color.g == COLOR_TYPE.PURPLE.g and award.color.b == COLOR_TYPE.PURPLE.b then
			rewardFrameImg:setTexture('uires/ui_2nd/com/panel/common/frame_purple.png')
		elseif award.color.r == COLOR_TYPE.ORANGE.r and award.color.g == COLOR_TYPE.ORANGE.g and award.color.b == COLOR_TYPE.ORANGE.b then
			-- rewardFrameImg:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
			rewardFrameImg:setTexture('uires/ui_2nd/com/panel/common/frame_sred.png')
		end

		rewardIco:registerScriptTapHandler(function()
			UISvr:showTipsForAward(rewardData[i].Award1)
		end)

		-- updateAward(i,selfRank,rewardVView)
	end
	local function createAwardCell()
		for i=MAX_AWARD,1,-1 do
			if i < MAX_AWARD and i%2 == 0 then
				moveHeight = moveHeight + 1
			end
			local rewardVView = createWidgetByName('panel/thanksgiving_reward_card_panel.json')
			updateAwardCell(i,rewardVView)
			rewardSv:addChildToBottom(rewardVView)
			rewardVView:setPosition(ccp((i+1)%2*290, rewardVView:getContentSize().height*moveHeight))
			-- print((i+1)%2*290)
			-- print(rewardVView:getContentSize().height*moveHeight)
		end
		rewardSv:scrollToTop()
	end
	local function genThxgivingHelpPanel(panel, help)
		return function()
			local root = panel:GetRawPanel()
			local helpBg = tolua.cast(root:getChildByName('thanksgiving_help_bg_img') , 'UIImageView')

			helpBg:registerScriptTapHandler(function()
				CUIManager:GetInstance():HideObject(help, ELF_HIDE.SMART_HIDE)
			end)

			local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
			closeBtn:registerScriptTapHandler(function()
				CUIManager:GetInstance():HideObject(help, ELF_HIDE.SMART_HIDE)
			end)
			
			local knowBtn = tolua.cast(root:getChildByName('know_btn') , 'UITextButton')
			GameController.addButtonSound(knowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			knowBtn:registerScriptTapHandler(function()
				CUIManager:GetInstance():HideObject(help, ELF_HIDE.SMART_HIDE)
			end)	
		end
	end
	local function createHelpPanel()
		helpScene = SceneObjEx:createObj('panel/thanksgiving_help_panel.json' , 'thanksgiving-help-in-lua')
		helpPanel = helpScene:getPanelObj()
		helpPanel:setAdaptInfo('thanksgiving_help_bg_img' , 'thanksgiving_img')
		local viewPanel = genThxgivingHelpPanel(helpPanel, helpScene)

		helpPanel:registerInitHandler(function()
			viewPanel()
		end)
		CUIManager:GetInstance():ShowObject(helpScene, ELF_SHOW.SMART)
	end
	local function init()
		local root = panel:GetRawPanel()
    	closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		helpBtn = tolua.cast(root:getChildByName('help_btn') , 'UIButton')
    	helpBtn:registerScriptTapHandler(function ()
			createHelpPanel()
		end)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		dataTx = tolua.cast(root:getChildByName('data_tx') , 'UILabel')
		dateTab = string.split(conf.EndTime , ':')
		dataTx:setText(dateTab[1]..'/'..dateTab[2]..'/'..dateTab[3])
		dataTx:setColor(ccc3(255,255,0))

		cashNumTx = tolua.cast(root:getChildByName('cash_num_tx') , 'UILabel')
		cashNumTx:setText(allCost)

		local overTimeTx = tolua.cast(root:getChildByName('count_down_tx') , 'UILabel')
		timeTx = tolua.cast(root:getChildByName('time_tx') , 'UILabel')
		timeTx:setText('')
		timeCDTx = UICDLabel:create()
		timeCDTx:setFontSize(22)
		timeCDTx:setPosition(ccp(0,0))
		timeCDTx:setFontColor(ccc3(255, 0, 0))
		timeCDTx:setAnchorPoint(ccp(0,0))
		timeTx:addChild(timeCDTx)
		
		timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
		local isEnd = false
		if timeDiff < 0 then
			overTimeTx:setText(getLocalStringValue('E_STR_GETAWARD_COUNTDOWN'))
			timeDiff = conf.DelayDays * 86400 + timeDiff
			 isEnd = true
		end
		-- timeDiff = 100
		timeCDTx:setTime(timeDiff)
		timeCDTx:registerTimeoutHandler(function ()
			if isEnd == false then
				isEnd = true
				overTimeTx:setText(getLocalStringValue('E_STR_GETAWARD_COUNTDOWN'))
				timeCDTx:setTime(conf.DelayDays * 86400)
			else
				CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
			end
		end)

		rewardSv = tolua.cast(root:getChildByName('reward_scroll_view') , 'UIScrollView')
		rewardSv:setClippingEnable(true)

		createAwardCell()
		updateMainPanel()
	end
	local function createPanel()
		getConf()

		sceneObj = SceneObjEx:createObj('panel/thanksgiving_bg_panel.json','thanksgiving-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('thanksgiving_bg_img','main_frame_img')
		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end
	
	local function getWelfareResponse()
		Message.sendPost('get_thx_giving','activity','{}',function (jsondata)

			cclog(jsondata)
			
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			if code == 0 then
				allCost = response.data.thx_giving.paid or 0
				currPaid= allCost
				allStatus = response.data.thx_giving.got or {}
				if type(allStatus) ~= 'table' then
					allStatus = {}
				end
			    -- 创建主界面
				createPanel()
			end
		end)
	end

	--感恩回馈入口
	getWelfareResponse()
	-- createPanel()
end