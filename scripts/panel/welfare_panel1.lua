Welfare1 = {}

function Welfare1.isActive()
	local level = PlayerCoreData.getPlayerLevel()
    local activitiesConf = GameData:getMapData('activities.dat')
    local openLevel = activitiesConf['allgift1'].OpenLevel
    if  tonumber(level) < tonumber(openLevel) then      -- 如果等级不够
    	return false
    else 
    	return true
    end 
end
function Welfare1.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'allgift1' then
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
        print(nowTime)
        print(actyStartTime)
        print(actyEndTime)
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
function Welfare1.enter()
	local MAX_AWARD = 0
	local MAX_RANK = 10
	local sceneObj
	local panel
	local helpPanel
	local helpScene
	local awardPanel
	local awardScene
	local cardSv
	local nameSv
	local rankSv
	local conf
	local allGift = {}
	local selfRank = {}
	local rank
	local allStatus
	local selfStatus
	local paid
	local paidAll
	local getSelfAwardBtn 
	local getAllAwardBtns = {}

	local function getConf()
		allgiftData = GameData:getArrayData('allgift1.dat')
		for i,v in ipairs(allgiftData) do
			if v.Type == 'self' then
				table.insert(selfRank , v)
			else
				table.insert(allGift , v)
				MAX_AWARD = MAX_AWARD + 1
			end
		end

		local data = GameData:getArrayData('activities.dat')
		table.foreach(data , function (_ , v)
			if v['Key'] == 'allgift1' then
				conf = v
			end
		end)
	end
	local function getRank()
		if type(rank) ~= 'table' then
			return nil
		end
		for i,v in ipairs(rank) do
			if PlayerCoreData.getUID() == v.uid then
				return i
			end
		end
		return nil
	end
	local function updateAward(i,tab,rewardVView)
		photoIco1 = tolua.cast(rewardVView:getChildByName('photo_1_ico') , 'UIImageView')
		numberTx1 = tolua.cast(photoIco1:getChildByName('number_tx') , 'UILabel')
		awardIco1 = tolua.cast(photoIco1:getChildByName('award_ico') , 'UIImageView')

		photoIco2 = tolua.cast(rewardVView:getChildByName('photo_2_ico') , 'UIImageView')
		numberTx2 = tolua.cast(photoIco2:getChildByName('number_tx') , 'UILabel')
		awardIco2 = tolua.cast(photoIco2:getChildByName('award_ico') , 'UIImageView')

		photoIco3 = tolua.cast(rewardVView:getChildByName('photo_3_ico') , 'UIImageView')
		numberTx3 = tolua.cast(photoIco3:getChildByName('number_tx') , 'UILabel')
		awardIco3 = tolua.cast(photoIco3:getChildByName('award_ico') , 'UIImageView')

		photoIco4 = tolua.cast(rewardVView:getChildByName('photo_4_ico') , 'UIImageView')
		numberTx4 = tolua.cast(photoIco4:getChildByName('number_tx') , 'UILabel')
		awardIco4 = tolua.cast(photoIco4:getChildByName('award_ico') , 'UIImageView')

		award1 = UserData:getAward(tab[i].Award1)
		award2 = UserData:getAward(tab[i].Award2)
		award3 = UserData:getAward(tab[i].Award3)
		award4 = UserData:getAward(tab[i].Award4)

		photoIcos = {photoIco1,photoIco2,photoIco3,photoIco4}
		numberTxs = {numberTx1,numberTx2,numberTx3,numberTx4}
		awardIcos = {awardIco1,awardIco2,awardIco3,awardIco4}
		awards = {award1,award2,award3,award4}
		local giftAwards = {tab[i].Award1,tab[i].Award2,tab[i].Award3,tab[i].Award4}

		for j=1,4 do
			numberTxs[j]:setText(toWordsNumber(tonumber(awards[j].count)))
			awardIcos[j]:setTexture(awards[j].icon)
			photoIcos[j]:registerScriptTapHandler(function()
				UISvr:showTipsForAward(giftAwards[j])
			end)
		end
	end
	local function updateMainPanel()
		for i=1,MAX_AWARD do
			if not allStatus[tostring(i)] and paidAll > tonumber(allGift[i].PayMin) then
				getAllAwardBtns[i]:setNormalButtonGray(false)
				getAllAwardBtns[i]:setTouchEnable(true)
				getAllAwardBtns[i]:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
			elseif allStatus[tostring(i)] == 1 then
				getAllAwardBtns[i]:setNormalButtonGray(true)
				getAllAwardBtns[i]:setTouchEnable(false)
				getAllAwardBtns[i]:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			else 
				getAllAwardBtns[i]:setNormalButtonGray(true)
				getAllAwardBtns[i]:setTouchEnable(false)
				getAllAwardBtns[i]:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))			
			end
		end
	end
	local function getAwardRsp(i)
		args = {
			type = 'all',
			id = i or 0
		}
		Message.sendPost('get_all_gift_reward1','activity',json.encode(args),function (jsondata)

			cclog(jsondata)
			
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			-- local awards = response.data.awards
			local data = response['data']
			if code == 0 then

				if data['awards'] then
					UserData.parseAwardJson(json.encode(data['awards']))
				end
				-- for i,v in ipairs(awards) do
				-- 	UserData.parseAwardJson(json.encode(v))
				-- end
				allStatus[tostring(i)] = 1
				updateMainPanel()
				GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
			else
				GameController.showPrompts(getLocalStringValue('E_STR_GETAWARD_OVERTIME'), COLOR_TYPE.RED)
			end
		end)
	end
	local function OnGetSelfAward()
		-- self按钮
		args = {
			type = 'self',
		}
		Message.sendPost('get_all_gift_reward1','activity',json.encode(args),function (jsondata)

			cclog(jsondata)
			
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			local awards = response.data.awards
			if code == 0 then
				selfStatus = 1
				UserData.parseAwardJson(json.encode(awards))
				getSelfAwardBtn:setNormalButtonGray(true)
				getSelfAwardBtn:setTouchEnable(false)
				getSelfAwardBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
				GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
			else
				selfStatus = 1
				GameController.showPrompts(getLocalStringValue('E_STR_GETAWARD_OVERTIME'), COLOR_TYPE.RED)
			end
		end)
	end
	local function updateAwardCell(i,rewardVView)
		kingIco = tolua.cast(rewardVView:getChildByName('king_ico') , 'UIImageView')
		topNum = tolua.cast(rewardVView:getChildByName('top_num_tx') , 'UILabel')
		topNum:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK'),i))
		nameTx = tolua.cast(rewardVView:getChildByName('name_tx') , 'UILabel')
		if not rank[i] then
			nameTx:setText(getLocalStringValue('E_STR_WELFARE_NORANK1'))
		else
			nameTx:setText(rank[i].name)
		end
		if i == 1 then
			kingIco:setVisible(true)
			topNum:setVisible(false)
			kingIco:setTexture('uires/ui_2nd/com/panel/trena/1.png')
		elseif i == 2 then
			kingIco:setVisible(true)
			topNum:setVisible(false)
			kingIco:setTexture('uires/ui_2nd/com/panel/trena/2.png')
		elseif i == 3 then
			kingIco:setVisible(true)
			topNum:setVisible(false)
			kingIco:setTexture('uires/ui_2nd/com/panel/trena/3.png')
		else
			topNum:setVisible(true)
			kingIco:setVisible(false)
		end

		updateAward(i,selfRank,rewardVView)
	end
	local function createAwardCell()
		for i=1,MAX_RANK do
			local rewardVView = createWidgetByName('panel/top_ranking_card_cell.json')
			updateAwardCell(i,rewardVView)
			rankSv:addChildToBottom(rewardVView)
		end
		rankSv:scrollToTop()
	end
	local function updateAwardPanel()
		local root = awardPanel:GetRawPanel()
		local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(awardScene))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		getSelfAwardBtn = tolua.cast(root:getChildByName('get_award_btn') , 'UITextButton')
		getSelfAwardBtn:registerScriptTapHandler(function ()
			OnGetSelfAward()
		end)
		GameController.addButtonSound(getSelfAwardBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		rankSv = tolua.cast(root:getChildByName('card_sv') , 'UIScrollView')
		rankSv:setClippingEnable(true)
		createAwardCell()

		-- timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
		serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
		timeDiff = serverOpenTime + (tonumber(conf.OpenDay) + tonumber(conf.Duration) - 1)* 86400 - UserData:getServerTime()
		if timeDiff > 0 then
			getSelfAwardBtn:setNormalButtonGray(true)
			getSelfAwardBtn:setTouchEnable(false)
			getSelfAwardBtn:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
			return
		end

		if selfStatus == 0 and getRank() then
			getSelfAwardBtn:setNormalButtonGray(false)
			getSelfAwardBtn:setTouchEnable(true)
			getSelfAwardBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
		elseif selfStatus == 1 then
			getSelfAwardBtn:setNormalButtonGray(true)
			getSelfAwardBtn:setTouchEnable(false)
			getSelfAwardBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
		else
			getSelfAwardBtn:setNormalButtonGray(true)
			getSelfAwardBtn:setTouchEnable(false)
			getSelfAwardBtn:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
		end
	end
	local function createAwardPanel()
		awardScene = SceneObjEx:createObj('panel/top_ranking_bg_panel.json' , 'topranking-in-lua')
		awardPanel = awardScene:getPanelObj()
		awardPanel:setAdaptInfo('top_ranking_bg_img' , 'top_ranking_img')
		awardPanel:registerInitHandler(updateAwardPanel)
		UiMan.show(awardScene)
	end
	local function helpPanelInit()
		local root = helpPanel:GetRawPanel()

		local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(helpScene))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		
		local knowBtn = tolua.cast(root:getChildByName('know_btn') , 'UIButton')
		knowBtn:registerScriptTapHandler(UiMan.genCloseHandler(helpScene))
		GameController.addButtonSound(knowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		
		local helpBg = tolua.cast(root:getChildByName('fuli_help_bg_img') , 'UIImageView')
		helpBg:registerScriptTapHandler(UiMan.genCloseHandler(helpScene))
	end
	local function createHelpPanel()
		helpScene = SceneObjEx:createObj('panel/quanminfuli_help_panel.json' , 'quanminfuli-in-lua')
		helpPanel = helpScene:getPanelObj()
		helpPanel:setAdaptInfo('fuli_help_bg_img' , 'fuli_img')
		helpPanel:registerInitHandler(helpPanelInit)
		UiMan.show(helpScene)
	end
	local function updateNameCell(i,rewardVView)
		nameTx = tolua.cast(rewardVView:getChildByName('name_tx') , 'UILabel')
		if not rank[i] then
			nameTx:setText(getLocalStringValue('E_STR_WELFARE_NORANK1'))
		else
			nameTx:setText(rank[i].name)
		end
		rankTx = tolua.cast(rewardVView:getChildByName('rank_tx') , 'UILabel')
		rankTx:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK'),i))
	end
	local function createNameCell()
		for i=1,MAX_RANK do
			local rewardVView = createWidgetByName('panel/whole_people_name_cell.json')
			updateNameCell(i,rewardVView)
			nameSv:addChildToBottom(rewardVView)
		end
		nameSv:scrollToTop()
	end
	local function OnGetAllAward(i)
		if PlayerCoreData.getPlayerVIP() > 0 then
			getAwardRsp(i)
		else
			updateMainPanel()
			GameController.showMessageBox(getLocalStringValue('E_STR_WELFARE_DESC'), MESSAGE_BOX_TYPE.OK_CANCEL,function ()
				getAwardRsp(i)
			end)
		end
	end
	local function updateAwardCell(i,rewardVView)

		local getAwardBtn = tolua.cast(rewardVView:getChildByName('get_award_btn') , 'UITextButton')
		getAwardBtn:registerScriptTapHandler(function ()
			OnGetAllAward(i)
		end)
		table.insert(getAllAwardBtns,getAwardBtn)

		nameBg = tolua.cast(rewardVView:getChildByName('name_bg_ico') , 'UIImageView')
		nameTx = tolua.cast(nameBg:getChildByName('name_tx') , 'UILabel')
		nameTx:setText(getLocalStringValue('E_STR_WELFARE_NAME_DESC'))
		numTx = tolua.cast(nameBg:getChildByName('num_tx') , 'UILabel')
		-- allConsume = 350000
		if paidAll > tonumber(allGift[i].PayMin) then
			numTx:setText(tonumber(allGift[i].PayMin)..'/'..tonumber(allGift[i].PayMin))
		else
			numTx:setText(paidAll..'/'..tonumber(allGift[i].PayMin))
		end
		numTx:setColor(ccc3(255,255,0))
		updateAward(i,allGift,rewardVView)
	end
	local function getAllStatus(jsonData)
		-- body
	end
	local function createAwardCell()
		for i=1,MAX_AWARD do
			local rewardVView = createWidgetByName('panel/whole_people_card_cell.json')
			updateAwardCell(i,rewardVView)
			cardSv:addChildToBottom(rewardVView)
		end
		cardSv:scrollToTop()
	end
	local function init()
		root = panel:GetRawPanel()
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
		awardBtn = tolua.cast(root:getChildByName('get_rank_award_btn') , 'UIButton')
    	awardBtn:registerScriptTapHandler(function ()
			createAwardPanel()
		end)
		GameController.addButtonSound(awardBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		rechargeBgTxtTx = tolua.cast(root:getChildByName('recharge_txt_tx') , 'UILabel')
		rechargeBgTxtTx:setText(getLocalStringValue('E_STR_WELFARE_RECHARG_DESC'))
		rankTxtTx = tolua.cast(root:getChildByName('rank_txt_tx') , 'UILabel')
		rankTxtTx:setText(getLocalStringValue('E_STR_WELFARE_RANK_DESC'))

		cashTx = tolua.cast(root:getChildByName('cash_tx') , 'UILabel')
		cashTx:setText(toWordsNumber(tonumber(PlayerCoreData.getCashValue())))

		overTimeBg = tolua.cast(root:getChildByName('over_time_bg_ico') , 'UIImageView')
		local overTimeTx = tolua.cast(root:getChildByName('over_time_tx') , 'UILabel')
		overTimeTx:setText(getLocalStringValue('E_STR_WELFARE_TIMEEND'))
		timeTx = tolua.cast(root:getChildByName('time_tx') , 'UILabel')
		timeTx:setText('')
		timeCDTx = UICDLabel:create()
		timeCDTx:setFontSize(22)
		timeCDTx:setPosition(ccp(5,0))
		timeCDTx:setFontColor(ccc3(50, 240, 50))
		timeCDTx:setAnchorPoint(ccp(0,0))
		timeTx:addChild(timeCDTx)
		
		-- timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
		serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
		timeDiff = serverOpenTime + (tonumber(conf.OpenDay) + tonumber(conf.Duration) - 1)* 86400 - UserData:getServerTime()
		local isEnd = false
		if timeDiff < 0 then
			overTimeTx:setText(getLocalStringValue('E_STR_GETAWARD_COUNTDOWN'))
			timeDiff = conf.DelayDays * 86400 + timeDiff
			isEnd = true
		end
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


		rechargeBg = tolua.cast(root:getChildByName('recharge_bg_ico') , 'UIImageView')
		rechargeTx = tolua.cast(rechargeBg:getChildByName('recharge_tx') , 'UILabel')
		rechargeTx:setText(paid)

		rankBg = tolua.cast(root:getChildByName('rank_bg_ico') , 'UIImageView')
		curRankBg = tolua.cast(rankBg:getChildByName('cur_rank_tx') , 'UILabel')
		-- curRankBg:setText('第一名')
		myRank = getRank()
		if myRank then
			curRankBg:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK'),myRank))
		else
			curRankBg:setText(getLocalStringValue('E_STR_WELFARE_NORANK'))
		end

		cardSv = tolua.cast(root:getChildByName('card_sv') , 'UIScrollView')
		cardSv:setClippingEnable(true)
		

		rightCardImg = tolua.cast(root:getChildByName('right_card_img') , 'UIImageView')
		nameSv = tolua.cast(rightCardImg:getChildByName('name_sv') , 'UIScrollView')
		nameSv:setClippingEnable(true)
		

		getAllAwardBtns = {}
		createAwardCell()
		createNameCell()
		updateMainPanel()

		-- Message.sendPost('get_all_target','activity','{}',function (jsonData)
		-- 	getAllStatus(jsonData)
		-- end)
	end
	local function createPanel()
		getConf()

		sceneObj = SceneObjEx:createObj('panel/whole_people_bg_panel.json','Welfare-in-lua-1')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('whole_people_bg_img','whole_people_img')
		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end
	
	local function getWelfareResponse()
		Message.sendPost('get_all_gift1','activity','{}',function (jsondata)

			cclog(jsondata)
			
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			if code == 0 then
				allStatus = response.data.got.all
				if type(allStatus) ~= 'table' then
					allStatus = {}
				end
				selfStatus = response.data.got.self
				paid = response.data.paid or 0
				paidAll = response.data.paid_all or 0
				rank = response.data.rank
			    -- 创建主界面
				createPanel()
			end
		end)
	end

	--累计充值入口
	getWelfareResponse()
	-- createPanel()
end