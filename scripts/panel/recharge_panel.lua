Recharge ={}
local cardBtn = {}
local cardBgImg
local curtyep
local explainTx
local infoIco
local infoTx
local rechargeTab = GameData:getArrayData('avpaycarnival.dat')
local expendTab = GameData:getArrayData('avpaycarnivalcost.dat')
local stageTab = GameData:getArrayData('avpaycarnivalstage.dat')
local RechargeData = {}
local CardId
local cardObj
local expendFile = 'avpaycarnivalcost.dat'

function Recharge.isActive()
	local level = PlayerCoreData.getPlayerLevel()
    local activitiesConf = GameData:getMapData('activities.dat')
    local openLevel = activitiesConf['paycarnival'].OpenLevel
    if  tonumber(level) < tonumber(openLevel) then      -- 如果等级不够
    	return false
    else 
    	return true
    end 
end

function Recharge.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'paycarnival' then
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
            actyEndTime = serverOpenTime + (tonumber(conf.OpenDay) + tonumber(conf.Duration) + tonumber(conf.DelayDays) - 1)*86400
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

local function getRechargeConfDataByKey( key )
	for k , v in pairs (rechargeTab)   do                          
		if(v['Id'] == key) then 
			return v
		end
	end
	return nil
end

local function getExpendTabConfDataByKey( key )
	for k , v in pairs (expendTab)   do                          
		if(v['Id'] == key) then 
			return v
		end
	end
	return nil
end

local function getstageTabConfDataByKey( key )
	for k , v in pairs (stageTab)   do                          
		if(v['StageId'] == key) then 
			return v
		end
	end
	return nil
end

local function getExpendData(stageId , itenId)
	local conf = GameData:getArrayData(expendFile)
	local data
	table.foreach(conf , function (k , v)
		if tonumber(v['StageId']) == tonumber(stageId) and tonumber(v['ItemId']) == tonumber(itenId) then
			data = v
		end
	end)
	return data
end

local function helpPanelInit()
	local root = helpPanel:GetRawPanel()
	local closeBtn = tolua.cast(root:getChildByName('close_btn'),'UIButton')
	local helpSv = tolua.cast(root:getChildByName('help_sv'),'UIScrollView')
	local helpPl = tolua.cast(root:getChildByName('help_pl'),'UIPanel')
	helpSv:setClippingEnable(true)
	helpSv:scrollToTop()
	closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(helpObj))
	GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

	local info_1_tx = tolua.cast(helpPl:getChildByName('info_1_tx'), 'UILabel')
	info_1_tx:setPreferredSize(580, 1)
	info_1_tx:setText(getLocalStringValue('HELP_PAYCARNIVAL_1'))
	local info_2_tx = tolua.cast(helpPl:getChildByName('info_2_tx'), 'UILabel')
	info_2_tx:setPreferredSize(580, 1)
	info_2_tx:setText(getLocalStringValue('HELP_PAYCARNIVAL_2'))
	local info_3_tx = tolua.cast(helpPl:getChildByName('info_3_tx'), 'UILabel')
	info_3_tx:setPreferredSize(580, 1)
	info_3_tx:setText(getLocalStringValue('HELP_PAYCARNIVAL_3'))
	local info_4_tx = tolua.cast(helpPl:getChildByName('info_4_tx'), 'UILabel')
	info_4_tx:setPreferredSize(580, 1)
	info_4_tx:setText(getLocalStringValue('HELP_PAYCARNIVAL_4'))
	local info_5_tx = tolua.cast(helpPl:getChildByName('info_5_tx'), 'UILabel')
	info_5_tx:setPreferredSize(580, 1)
	info_5_tx:setText(getLocalStringValue('HELP_PAYCARNIVAL_5'))

	local knowBtn = tolua.cast(root:getChildByName('recharge_help_bg_img'),'UIImageView')
	knowBtn:registerScriptTapHandler(UiMan.genCloseHandler(helpObj))
end

local function onOpenHelpPanel()
	helpObj = SceneObjEx:createObj('panel/recharge_help_panel.json','recharge-help-lua')
	helpPanel = helpObj:getPanelObj()
	helpPanel:setAdaptInfo('recharge_help_bg_img','recharge_help_img')
	helpPanel:registerInitHandler(helpPanelInit)
	UiMan.show(helpObj)
end

local function doOpenAwardResponse(jsonData)
	local response = json.decode(jsonData)
	local code = response.code
	if tonumber(code) == 0 then
		local data = response.data
		local awards = data.awards
		local msgs = {}
		for k,v in pairs(awards) do
            local vStr = v[1] .. '.' .. v[2] .. ':' .. v[3]             -- 改成类似user.cash:10的形式
            local award = UserData:getAward(vStr)
            msg = string.format(getLocalString('E_STR_GAIN_MATERIAL'),tostring(award.name),tonumber(award.count))
            table.insert(msgs, msg)
        end
        GameController.showPrompts(msgs)
		UserData.parseAwardJson(json.encode(response.data.awards))
		--GameController.showPrompts(getLocalStringValue('E_STR_EXCHANGE_SUCCEED'), COLOR_TYPE.GREEN)
		RechargeData.paid_get = 1
		updateRecharge()
		CUIManager:GetInstance():HideObject(cardObj, ELF_SHOW.NORMAL)
	end
end

local function doCostAwardResponse(jsonData)
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		local data = response.data
		local awards = data.awards
		local msgs = {}
		for k,v in pairs(awards) do
            local vStr = v[1] .. '.' .. v[2] .. ':' .. v[3]             -- 改成类似user.cash:10的形式
            local award = UserData:getAward(vStr)
            msg = string.format(getLocalString('E_STR_GAIN_MATERIAL'),tostring(award.name),tonumber(award.count))
            table.insert(msgs, msg)
        end
        GameController.showPrompts(msgs)
		UserData.parseAwardJson(json.encode(response.data.awards))
		--GameController.showPrompts(getLocalStringValue('E_STR_EXCHANGE_SUCCEED'), COLOR_TYPE.GREEN)
		RechargeData.cost_progress = RechargeData.cost_progress + 1
		if (tonumber(RechargeData.cost_progress) > tonumber(#stageTab)) then
			RechargeData.cost_progress = #stageTab
			RechargeData.cost_get = 1
		end
		updateRecharge()
		CUIManager:GetInstance():HideObject(cardObj, ELF_SHOW.NORMAL)
	end	
end

local function OnClickGetAward()
	if tonumber(RechargeData.paid_get) == 0 then
		local args = { id = CardId }
			Message.sendPost('pay_carnival_open_award', 'activity', json.encode(args), function (jsonData)
				doOpenAwardResponse(jsonData)
			end)
	elseif tonumber(RechargeData.paid_get) == 1 then
		local args = { id = CardId }
			Message.sendPost('pay_carnival_cost_award', 'activity', json.encode(args), function (jsonData)
				doCostAwardResponse(jsonData)
			end)
	end
end

local function setCardInfo(cardBgImg)
	if tonumber(RechargeData.paid_get) == 0 then
		local info = tolua.cast(cardBgImg:getChildByName('info_tx'), 'UILabel')
		info:setPreferredSize(380,1)
		local strBuff = string.format(getLocalStringValue('E_STR_PAYCARNIVAL_INFO'), GetTextForCfg(rechargeTab[CardId].AwardTitle))
		info:setText(strBuff)
		local cardImg = tolua.cast(cardBgImg:getChildByName('card_img'),'UIImageView')
		local cardNameTx = tolua.cast(cardImg:getChildByName('card_name_tx'), 'UILabel')
		cardNameTx:setText(GetTextForCfg(rechargeTab[CardId].AwardTitle))
		local award1 = UserData:getAward(rechargeTab[CardId].Award1)
		local award2 = UserData:getAward(rechargeTab[CardId].Award2)
		local award3 = UserData:getAward(rechargeTab[CardId].Award3)
		local awards = {award1,award2,award3}
		local giftAwards = {rechargeTab[CardId].Award1,rechargeTab[CardId].Award2,rechargeTab[CardId].Award3}
		for j = 1, 3 do
			local photoIco = tolua.cast(cardImg:getChildByName('photo_' .. j .. '_ico'), 'UIImageView')
			photoIco:registerScriptTapHandler(function()
				UISvr:showTipsForAward(giftAwards[j])
			end)
			local awardIco = tolua.cast(photoIco:getChildByName('award_ico'), 'UIImageView')
			local awardNumTx = tolua.cast(photoIco:getChildByName('number_tx'), 'UILabel')
			awardIco:setTexture(awards[j].icon)
			awardNumTx:setText(awards[j].count)	
		end
	elseif tonumber(RechargeData.paid_get) == 1 then
		local cardImg = tolua.cast(cardBgImg:getChildByName('card_img'),'UIImageView')
		local cardNameTx = tolua.cast(cardImg:getChildByName('card_name_tx'), 'UILabel')
		local expData = getExpendData(RechargeData.cost_progress, CardId)
		local str = string.format(getLocalStringValue('E_STR_PAYCARNIVAL_VIP_DOUBLE'), expData.DoubleVIP)
		cardNameTx:setText(str)
		local info = tolua.cast(cardBgImg:getChildByName('info_tx'), 'UILabel')
		info:setPreferredSize(380,1)
		local strBuff = string.format(getLocalStringValue('E_STR_PAYCARNIVAL_INFO'), str)
		info:setText(strBuff)
		local award1 = UserData:getAward(expData.Award1)
		local award2 = UserData:getAward(expData.Award2)
		local award3 = UserData:getAward(expData.Award3)
		local awards = {award1,award2,award3}
		local giftAwards = {expData.Award1,expData.Award2,expData.Award3}
		for j = 1, 3 do
			local photoIco = tolua.cast(cardImg:getChildByName('photo_' .. j .. '_ico'), 'UIImageView')
			photoIco:registerScriptTapHandler(function()
				UISvr:showTipsForAward(giftAwards[j])
			end)
			local awardIco = tolua.cast(photoIco:getChildByName('award_ico'), 'UIImageView')
			local awardNumTx = tolua.cast(photoIco:getChildByName('number_tx'), 'UILabel')
			awardIco:setTexture(awards[j].icon)
			awardNumTx:setText(awards[j].count)	
		end
	end	
end

local function CardPanelInit()
	local root = cardPanel:GetRawPanel()
	local awardBgImg = tolua.cast(root:getChildByName('award_bg_img'),'UIImageView')
	local awardImg = tolua.cast(awardBgImg:getChildByName('award_img'),'UIImageView')
	local cardBgImg = tolua.cast(awardImg:getChildByName('card_bg_img'),'UIImageView')	
	setCardInfo(cardBgImg)
	local getAwardBtn = tolua.cast(awardImg:getChildByName('get_award_btn'), 'UITextButton')
    getAwardBtn:registerScriptTapHandler(OnClickGetAward)
	
	local closeBtn = tolua.cast(awardImg:getChildByName('close_btn'),'UIButton')
	closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(cardObj))
	GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
end

local function onOpenCardPanel()
	cardObj = SceneObjEx:createObj('panel/recharge_award_panel.json','recharge-card-panel-lua')
	cardPanel = cardObj:getPanelObj()
	cardPanel:setAdaptInfo('award_bg_img','award_img')
	cardPanel:registerInitHandler(CardPanelInit)
	UiMan.show(cardObj)
end

local function OnClickCard(index, isActive)
	if tonumber(RechargeData.cost_get) == 1 then
		GameController.showPrompts(getLocalStringValue('E_STR_PAYCARNIVAL_ALREADY'), COLOR_TYPE.RED)
	else
		if tostring(isActive) == 'finished' then
			CardId = index
			onOpenCardPanel()
		elseif tostring(isActive) == 'recharge_not_enough' then
			GameController.showPrompts(getLocalStringValue('E_STR_PAYCARNIVAL_RECHARGE_NOTENOUGH'), COLOR_TYPE.RED)
		elseif tostring(isActive) == 'expend_not_enough' then
			GameController.showPrompts(getLocalStringValue('E_STR_PAYCARNIVAL_EXPEDN_NOTENOUGH'), COLOR_TYPE.RED)
		end
	end
end

local function genViewUpdater(panel, recharge)
	return function() 
		local root = panel:GetRawPanel()
        local rechargeBgImg = tolua.cast(root:getChildByName('recharge_bg_img'), 'UIImageView')
        local rechargeImg = tolua.cast(rechargeBgImg:getChildByName('recharge_img'), 'UIImageView')
       	local titleBgImg = tolua.cast(rechargeImg:getChildByName('title_ico'), 'UIImageView')

       	explainTx = tolua.cast(rechargeImg:getChildByName('info_tx'), 'UILabel')
       	infoIco = tolua.cast(rechargeImg:getChildByName('expend_ico'), 'UIImageView')
       	infoTx = tolua.cast(rechargeImg:getChildByName('expend_tx'), 'UILabel')

       	cardBgImg = tolua.cast(rechargeImg:getChildByName('card_bg_img'), 'UIImageView')
       	updateRecharge()
		local closeBtn = tolua.cast(titleBgImg:getChildByName('close_btn'), 'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(recharge, ELF_HIDE.SMART_HIDE)
		end)

		local helpBtn = tolua.cast(titleBgImg:getChildByName('help_btn'), 'UIButton')
		GameController.addButtonSound(helpBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		helpBtn:registerScriptTapHandler(onOpenHelpPanel)
	end
end

local function genRechargePanel()
	local recharge = SceneObjEx:createObj('panel/recharge_panel.json', 'recharge-lua')
    local panel = recharge:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('recharge_bg_img', 'recharge_img')
    local viewUpdater = genViewUpdater(panel, recharge)

	panel:registerInitHandler(function()
		viewUpdater()
	end)
    	
    panel:registerOnShowHandler(function()
    end)
    panel:registerOnHideHandler(function()
    end)
    -- Show now
    CUIManager:GetInstance():ShowObject(recharge, ELF_SHOW.SMART)
end

local function doGetRechargeResponse(jsonData)
	cclog(jsonData)
	local response = json.decode(jsonData)	
	local code = response.code
	if tonumber(code) == 0 then
		RechargeData = response.data.pay_carnival
		genRechargePanel()
	end
end

function updateRecharge()
	if tonumber(RechargeData.paid_get) == 0 then
		local needCash = getGlobalIntegerValue('PayCarnivalTotalCash')
		local curCash = RechargeData.paid
		local day = getGlobalIntegerValue('PayCarnivalAwardDays')
		local isActive = ''
		local strExp = string.format(getLocalStringValue('E_STR_PAYCARNIVAL_RECHARGE_EXPLAIN'), needCash, day)
		explainTx:setText(strExp)
		explainTx:setPreferredSize(540, 1)
		infoIco:setTexture('uires/ui_2nd/com/panel/recharge/addup_cash.png')
		if tonumber(curCash) >= tonumber(needCash) then
			infoTx:setText(getLocalStringValue('E_STR_PAYCARNIVAL_FINISHED'))
			isActive = 'finished'
		else
			local str = string.format(getLocalStringValue('E_STR_PAYCARNIVAL_UNFINISHED'), curCash, needCash)
			infoTx:setText(str)
			isActive = 'recharge_not_enough'
		end	
	   	for i = 1 , 4 do 
			cardBtn[i] = tolua.cast(cardBgImg:getChildByName('card_' .. i .. '_btn'), 'UIButton')
			cardBtn[i]:setTextures('uires/ui_2nd/com/panel/recharge/award_bg.png','','')
			cardBtn[i]:registerScriptTapHandler(function()
				OnClickCard(i, isActive)
	   		end)
			local cardNameTx = tolua.cast(cardBtn[i]:getChildByName('card_namet_tx'), 'UILabel')
			cardNameTx:setText(GetTextForCfg(rechargeTab[i].AwardTitle))
			local award1 = UserData:getAward(rechargeTab[i].Award1)
			local award2 = UserData:getAward(rechargeTab[i].Award2)
			local award3 = UserData:getAward(rechargeTab[i].Award3)
			local awards = {award1,award2,award3}
			local giftAwards = {rechargeTab[i].Award1,rechargeTab[i].Award2,rechargeTab[i].Award3}
			for j = 1, 3 do
				local photoIco = tolua.cast(cardBtn[i]:getChildByName('photo_' .. j .. '_ico'), 'UIImageView')
				local awardIco = tolua.cast(photoIco:getChildByName('award_ico'), 'UIImageView')
				local awardNumTx = tolua.cast(photoIco:getChildByName('number_tx'), 'UILabel')
				awardIco:setTexture(awards[j].icon)
				awardNumTx:setText(awards[j].count)	
			end
	   	end
	elseif tonumber(RechargeData.paid_get) == 1 then
		local needCash = stageTab[RechargeData.cost_progress].Goal
		local curCash = RechargeData.cost
		local day = RechargeData.days
		if tonumber(day) == 0 then
			day = getGlobalIntegerValue('PayCarnivalAwardDays')
		end
		local isActive = ''
		local strExp = string.format(getLocalStringValue('E_STR_PAYCARNIVAL_EXPEND_EXPLAIN'), needCash, day)
		explainTx:setText(strExp)
		explainTx:setPreferredSize(540, 1)
		infoIco:setTexture('uires/ui_2nd/com/panel/recharge/expend.png')
		if tonumber(curCash) >= tonumber(needCash) then
			infoTx:setText(getLocalStringValue('E_STR_PAYCARNIVAL_FINISHED'))
			isActive = 'finished'
		else
			local str = string.format(getLocalStringValue('E_STR_PAYCARNIVAL_UNFINISHED'), curCash, needCash)
			infoTx:setText(str)
			isActive = 'expend_not_enough'
		end		
	 	for i = 1 , 4 do 
			cardBtn[i] = tolua.cast(cardBgImg:getChildByName('card_' .. i .. '_btn'), 'UIButton')
			cardBtn[i]:setTextures('uires/ui_2nd/com/panel/recharge/award_bg.png','','')
			cardBtn[i]:registerScriptTapHandler(function()
				OnClickCard(i, isActive)
	   		end)
			local cardNameTx = tolua.cast(cardBtn[i]:getChildByName('card_namet_tx'), 'UILabel')
			local expData = getExpendData(RechargeData.cost_progress, i)
			local str = string.format(getLocalStringValue('E_STR_PAYCARNIVAL_VIP_DOUBLE'), expData.DoubleVIP)
			cardNameTx:setText(str)
			local award1 = UserData:getAward(expData.Award1)
			local award2 = UserData:getAward(expData.Award2)
			local award3 = UserData:getAward(expData.Award3)
			local awards = {award1,award2,award3}
			local giftAwards = {expData.Award1,expData.Award2,expData.Award3}
			for j = 1, 3 do
				local photoIco = tolua.cast(cardBtn[i]:getChildByName('photo_' .. j .. '_ico'), 'UIImageView')
				local awardIco = tolua.cast(photoIco:getChildByName('award_ico'), 'UIImageView')
				local awardNumTx = tolua.cast(photoIco:getChildByName('number_tx'), 'UILabel')
				awardIco:setTexture(awards[j].icon)
				awardNumTx:setText(awards[j].count)	
			end
	   	end
	end
end

function Recharge.enter()
	Message.sendPost('pay_carnival_get', 'activity', '{}', doGetRechargeResponse)	
end