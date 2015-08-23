local turnBtn
local getAwardBtn
local MainHelpBtn
local MainCloseBtn
local handleIco
local numberPl = {}
local photoIco = {}
local awardIco = {}
local light = {}
local getData = {}
local fuwaAwardData
local fuwaNumTx
local rewardTab = GameData:getArrayData('newyearreward.dat')

--判读是否开启福满天下，true为开启，false为关闭
function isOpenHofman()
	local StartTime = UserData:convertTime(1 , GameData:getGlobalValue('NewYearStartTime'))
    local EndTime = UserData:convertTime(1 , GameData:getGlobalValue('NewYearEndTime'))
    local ServerTime = UserData:getServerTime()
    if tonumber(ServerTime) > tonumber(StartTime) and tonumber(ServerTime) < tonumber(EndTime) then
    	return true
    else
    	return false
    end
end

--读表 newyearreward.dat
local function getNewYearRewardConfDataByKey( key )
	for k , v in pairs (rewardTab)   do                          
		if(v['Id'] == key) then 
			return v
		end
	end
	return nil
end

--福满天下帮助界面Init
local function helpPanelInit()
	local root = helpPanel:GetRawPanel()
	local helpSv = tolua.cast(root:getChildByName('help_sv'),'UIScrollView')
	helpSv:setClippingEnable(true)
	local closeBtn = tolua.cast(root:getChildByName('close_btn'),'UIButton')
	closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(helpObj))
	GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

	local info_1_tx = tolua.cast(root:getChildByName('info_1_tx'), 'UILabel')
	info_1_tx:setPreferredSize(560, 1)
	info_1_tx:setText(getLocalStringValue('HELP_HOFMAN_1'))
	local info_2_tx = tolua.cast(root:getChildByName('info_2_tx'), 'UILabel')
	info_2_tx:setPreferredSize(560, 1)
	info_2_tx:setText(getLocalStringValue('HELP_HOFMAN_2'))
	local info_3_tx = tolua.cast(root:getChildByName('info_3_tx'), 'UILabel')
	info_3_tx:setPreferredSize(560, 1)
	info_3_tx:setText(getLocalStringValue('HELP_HOFMAN_3'))
	local info_4_tx = tolua.cast(root:getChildByName('info_4_tx'), 'UILabel')
	info_4_tx:setPreferredSize(560, 1)
	info_4_tx:setText(getLocalStringValue('HELP_HOFMAN_4'))
	helpSv:scrollToTop()

	local knowBtn = tolua.cast(root:getChildByName('know_btn'),'UITextButton')
	knowBtn:registerScriptTapHandler(UiMan.genCloseHandler(helpObj))
	GameController.addButtonSound(knowBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
end

--打开福满天下帮助界面
local function onOpenHelpPanel()
	helpObj = SceneObjEx:createObj('panel/hofman_help_panel.json','hofman-help-lua')
	helpPanel = helpObj:getPanelObj()
	helpPanel:setAdaptInfo('hofman_bg_img','hofman_img')
	helpPanel:registerInitHandler(helpPanelInit)
	UiMan.show(helpObj)
end

--转轮停止后获得元宝数提示
local function showPompt()
	local data = fuwaAwardData
	local awards = data.awards
	if awards then
		local msgArr = {}
        for k,v in pairs(awards) do
            local vStr = v[1] .. '.' .. v[2] .. ':' .. v[3]             -- 改成类似user.cash:10的形式
            local award = UserData:getAward(vStr)
			local awardname = award.name .. ' X' .. award.count
			local msgText = string.format(getLocalString('E_STR_GAIN_ANYTHING'),awardname)
            table.insert(msgArr,msgText)
        end
        GameController.showPrompts(msgArr, COLOR_TYPE.GREEN)
    end
end

--转轮转动时，屏蔽按钮
local function LockBtn()
	turnBtn:setTouchEnable(false)
	MainHelpBtn:setTouchEnable(false)
	MainCloseBtn:setTouchEnable(false)
end

--转轮停止时，打开按钮
local function UnLockBtn()
	turnBtn:setTouchEnable(true)
	MainHelpBtn:setTouchEnable(true)
	MainCloseBtn:setTouchEnable(true)
end

--转轮转动动画
local function PlayaAnimation(pl1, pl2, turns, pos, stopnumber, unlock)
	--local speed = 740 / 1 + turns * 40
	local speed = 740 / 1
	local pl1_actArr = CCArray:create()
	local pl1_move = CCMoveBy:create(740 / speed , ccp(0, -740))
	local pl1_fun = CCCallFunc:create(function ()
		local arr = CCArray:create()
		-- pl1 循环部分
		local setPos = CCCallFunc:create(function ()
			pl1:setPosition(ccp(pos,740))
		end)
		local turn = CCMoveBy:create(740 * 2 / speed , ccp(0, -740 * 2))
		for i = 1, turns -1 do
			arr:addObject(setPos)	 
			arr:addObject(turn)
		end
		-- pl1 停止部分
		local setStopPos = CCCallFunc:create(function ()
			pl1:setPosition(ccp(pos,740))
		end)
		local endDis = 740 + (stopnumber) * 74	    				
		local stopturn = CCMoveBy:create(endDis / speed , ccp(0, -endDis))
	    local showpompt = CCCallFunc:create(function ()
	    	if unlock == 4 then
				UnLockBtn()
				showPompt()
			end
		end)
		arr:addObject(setStopPos)
		arr:addObject(stopturn)
		arr:addObject(showpompt)
		pl1:runAction(CCSequence:create(arr))	    	
	end)

    local pl2_Action = CCCallFunc:create(function ()
    	local arr = CCArray:create()
		local turn = CCMoveBy:create(740 * 2 / speed , ccp(0, -740 * 2))
	    local setPos = CCCallFunc:create(function ()
			pl2:setPosition(ccp(pos, 740))
		end)
		for i = 1, turns do
			arr:addObject(turn)
    		arr:addObject(setPos)
		end
    	pl2:runAction(CCSequence:create(arr))
	end)
    pl1_actArr:addObject(pl1_move)
    pl1_actArr:addObject(pl1_fun)	
    local pl1_Action = CCSequence:create(pl1_actArr)

    local Mixarr = CCArray:create()
	Mixarr:addObject(pl1_Action)
    Mixarr:addObject(pl2_Action)
    local MixAction = CCSpawn:create(Mixarr)
    local delayTime = CCDelayTime:create(1 * unlock)
    local SunArr = CCArray:create()
    SunArr:addObject(delayTime)
    SunArr:addObject(MixAction)
	pl1:runAction(CCSequence:create(SunArr))
end

--把手动画及开始转轮动画
local function Animation(cash)
	local actArr = CCArray:create()
	local rotate = CCOrbitCamera:create(0.3, 1, 0, 180, 0, 0, 0)
	local rotate_1 = CCOrbitCamera:create(0.3, -1, 0, 180, 0, 0, 0)
	actArr:addObject(rotate)
	actArr:addObject(rotate_1)
	handleIco:runAction(CCSequence:create(actArr))
	for i = 1, 10 do
		if i % 2 ~= 0 then
			numberPl[i]:setPosition(ccp(math.floor(i / 2) * 79,0))
		else
			numberPl[i]:setPosition(ccp((i / 2 - 1) * 79,740))
		end
	end

	for i = 1, 5 do
		local stopnumber = cash + 10000
		stopnumber = tonumber(string.sub(tostring(stopnumber), i, i))
		if i == 1 then
			stopnumber = 0
		end
		local turns = 2
		local pos = (i - 1) * 79
		PlayaAnimation(numberPl[2 * i - 1], numberPl[2 * i], turns, pos, stopnumber, 5 - i)	
	end	
end

--收到转动转轮消息
local function doGetTurnResponse(jsonData)
	cclog(jsonData)
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		local data = response.data
		fuwaAwardData = data
		getData.fuwa = data.fuwa
		if tonumber(getData.total) == 3 and tonumber(getData.fuwa) <= 0 then
			fuwaNumTx:setText(getLocalStringValue('E_STR_TODAY_FUWA_END'))
       		fuwaNumTx:setPreferredSize(450,1)
		else
			fuwaNumTx:setText(tonumber(getData.fuwa) .. '/' .. (3 - (tonumber(getData.total) - tonumber(getData.fuwa))))
		end	
		local awards = data.awards
		UserData.parseAwardJson(json.encode(awards))
		local cash = 0
		if awards then
    		local msgArr = {}
            for k,v in pairs(awards) do
                local vStr = v[1] .. '.' .. v[2] .. ':' .. v[3]             -- 改成类似user.cash:10的形式
                local award = UserData:getAward(vStr)
    			cash = award.count
            end
        end		
		Animation(cash)
	end
end

--点击转动
local function onClickTurn()	
	if tonumber(getData.fuwa) > 0 then
		LockBtn()
		Message.sendPost('new_year_dice', 'activity', '{}', doGetTurnResponse)	
	else
		if tonumber(getData.total) == 3 then 
			GameController.showPrompts(getLocalStringValue('E_STR_TODAY_FUWA_END') , COLOR_TYPE.RED)
		else	
			GameController.showPrompts(getLocalStringValue('E_STR_FUWA_NOT_ENOUGH') , COLOR_TYPE.RED)
		end
	end
end

--刷新累计奖励
local function updateAward()
	local index = 0
	for i = 1, 5 do
		if tonumber(getData.days) >= tonumber(rewardTab[i].Day) then
			if i <= tonumber(getData.got) then
				light[i]:setVisible(false)
				photoIco[i]:setGray()
				awardIco[i]:setGray()
			else
				light[i]:setVisible(true)
			end
		end
		if light[i]:isVisible() then
			index = index + 1
		end
	end
	if index > 0 then 
		getAwardBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
		getAwardBtn:setNormalButtonGray(false)
		getAwardBtn:setTouchEnable(true)
	else
		if tonumber(rewardTab[tonumber(getData.got)].Day) == tonumber(getData.days) then
			getAwardBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
		else
			getAwardBtn:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
		end
		getAwardBtn:setNormalButtonGray(true)
		getAwardBtn:setTouchEnable(false)
	end
end

--收到领取累计奖励消息
local function doGetAwardResponse(jsonData)
	cclog(jsonData)
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		local data = response.data
		getData.got = data.got
		local awards = data.awards
    	if awards then
    		local msgArr = {}
            for k,v in pairs(awards) do
                local vStr = v[1] .. '.' .. v[2] .. ':' .. v[3]             -- 改成类似user.cash:10的形式
                local award = UserData:getAward(vStr)
    			local awardname = award.name .. ' X' .. award.count
    			local msgText = string.format(getLocalString('E_STR_GAIN_ANYTHING'),awardname)
                table.insert(msgArr,msgText)
            end
            UserData.parseAwardJson(json.encode(awards))
            GameController.showPrompts(msgArr, COLOR_TYPE.GREEN)
        end
        updateAward()
	end
end

--点击领取累计奖励
local function onClickGetAward()
	Message.sendPost('new_year_rewards', 'activity', '{}', doGetAwardResponse)	
end

--福满天下界面
local function genViewUpdater(panel, hofman)
	return function() 
		local root = panel:GetRawPanel()
        local hofmanBgImg = tolua.cast(root:getChildByName('hofman_bg_img'), 'UIImageView')
        local hofmanImg = tolua.cast(hofmanBgImg:getChildByName('hofman_img'), 'UIImageView')
       	local titleBgImg = tolua.cast(hofmanImg:getChildByName('title_ico'), 'UIImageView')
       	local timeTx = tolua.cast(hofmanImg:getChildByName('time_tx'), 'UILabel')
       	timeTx:setPreferredSize(400,1)
       	
       	local dateTab = string.split(GameData:getGlobalValue('NewYearStartTime') , ':')
       	local dateTab1 = string.split(GameData:getGlobalValue('NewYearEndTime') , ':')
       	local str = string.format(getLocalStringValue('E_STR_SHOP_DATE'),dateTab[1],dateTab[2],dateTab[3])
       	local str1 = string.format(getLocalStringValue('E_STR_SHOP_DATE'),dateTab1[1],dateTab1[2],dateTab1[3])
       	timeTx:setText(str..'-'..str1)
       	local overtimeTx = tolua.cast(hofmanImg:getChildByName('over_time_tx'), 'UILabel')
       	local StartTime = UserData:convertTime(1 , GameData:getGlobalValue('NewYearStartTime'))
       	local EndTime = UserData:convertTime(1 , GameData:getGlobalValue('NewYearEndTime'))
       	local ServerTime = UserData:getServerTime()
       	local timeCDTx = UICDLabel:create()
		timeCDTx:setFontSize(20)
		timeCDTx:setPosition(ccp(0,0.5))
		timeCDTx:setAnchorPoint(ccp(1,0.5))
		timeCDTx:setFontColor(COLOR_TYPE.WHITE)
		overtimeTx:addChild(timeCDTx)
		timeCDTx:registerTimeoutHandler( function ()
			CUIManager:GetInstance():HideObject(hofman, ELF_HIDE.SMART_HIDE)
		end)
		local time = tonumber(EndTime) - tonumber(ServerTime)
		if time < 0 then
			time = 0
		end
		timeCDTx:setTime(time)
       	local infoTx = tolua.cast(hofmanImg:getChildByName('info_tx'), 'UILabel')
       	infoTx:setPreferredSize(600, 1)
       	infoTx:setText(getLocalStringValue('E_STR_HOFMAN_INFO'))
       	fuwaNumTx = tolua.cast(hofmanImg:getChildByName('fuwa_num_tx'), 'UILabel')
       	if tonumber(getData.total) == 3 and tonumber(getData.fuwa) <= 0 then
       		fuwaNumTx:setText(getLocalStringValue('E_STR_TODAY_FUWA_END'))
       		fuwaNumTx:setPreferredSize(450,1)
       	else
       		fuwaNumTx:setText(getData.fuwa .. '/' .. (3 - (tonumber(getData.total) - tonumber(getData.fuwa))))
       	end
       	handleIco = tolua.cast(hofmanImg:getChildByName('bashou_ico'), 'UIImageView')
       	local Sv = tolua.cast(hofmanImg:getChildByName('ScrollView'), 'UIScrollView')
       	Sv:setClippingEnable(true)
       	Sv:setTouchEnable(false)
       	local numberSv = tolua.cast(Sv:getChildByName('number_sv'), 'UIScrollView')
       	numberSv:setTouchEnable(false)
       	for i = 1, 10 do
       		local str = string.format('number_%d_pl', i)
       		numberPl[i] = tolua.cast(numberSv:getChildByName(str), 'UIPanel')
       	end

       	MainCloseBtn = tolua.cast(titleBgImg:getChildByName('close_btn'), 'UIButton')
		GameController.addButtonSound(MainCloseBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		MainCloseBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(hofman, ELF_HIDE.SMART_HIDE)
		end)

		MainHelpBtn = tolua.cast(titleBgImg:getChildByName('help_btn'), 'UIButton')
		GameController.addButtonSound(MainHelpBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		MainHelpBtn:registerScriptTapHandler(onOpenHelpPanel)

		for i = 1, 5 do
			local award = UserData:getAward(rewardTab[i].Award)	
			photoIco[i] = tolua.cast(hofmanImg:getChildByName('photo_' .. i .. '_ico'), 'UIImageView')
			photoIco[i]:registerScriptTapHandler(function()
				UISvr:showTipsForAward(rewardTab[i].Award)
			end)
			light[i] = CUIEffect:create()
			light[i]:Show("yellow_light", 0)
			light[i]:setScale(0.81)
			light[i]:setPosition( ccp(0, 0))
			light[i]:setAnchorPoint(ccp(0.5, 0.5))
			photoIco[i]:getContainerNode():addChild(light[i])
			light[i]:setZOrder(100)
			light[i]:setVisible(false)
			awardIco[i] = tolua.cast(photoIco[i]:getChildByName('award_ico'), 'UIImageView')
			local awardNumTx = tolua.cast(photoIco[i]:getChildByName('number_tx'), 'UILabel')
			local awardNameTx = tolua.cast(photoIco[i]:getChildByName('name_tx'), 'UILabel')
			awardNameTx:setPreferredSize(110,1)
			awardIco[i]:setTexture(award.icon)
			awardNumTx:setText(award.count)
			awardNameTx:setText(GetTextForCfg(rewardTab[i].Desc))
		end		
		turnBtn = tolua.cast(hofmanImg:getChildByName('turn_btn'), 'UITextButton')
		turnBtn:registerScriptTapHandler(onClickTurn)

		getAwardBtn = tolua.cast(hofmanImg:getChildByName('get_award_btn'), 'UITextButton')
		getAwardBtn:registerScriptTapHandler(onClickGetAward)
		updateAward()
	end
end

--打开福满天下
local function genHofmanPanel()
	local hofman = SceneObjEx:createObj('panel/hofman_panel.json', 'hofman-lua')

    local panel = hofman:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('hofman_bg_img', 'hofman_img')
    local viewUpdater = genViewUpdater(panel, hofman)

	panel:registerInitHandler(function()
		viewUpdater()
	end)
    	
    panel:registerOnShowHandler(function()
    end)
    panel:registerOnHideHandler(function()
    end)

    CUIManager:GetInstance():ShowObject(hofman, ELF_SHOW.SMART)
end

--收到福满天下消息
local function doGetHofmanResponse(jsonData)
	cclog(jsonData)
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		getData = response.data.new_year
		genHofmanPanel()
	end
end

--福满天下进入
function HofmanEnter()
	Message.sendPost('new_year_get', 'activity', '{}', doGetHofmanResponse)	
end