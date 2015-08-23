local _DAYS = getGlobalIntegerValue('AllTargetOpenDays')
local _DAYSSTATUS = 18
allStatus = {}
vipStatus = {}
function genGiftsIsOpen()
	local standardTime = UserData:convertTime( 1 , '2014:5:22:0:0:0')
	local nowTime = UserData:getServerTime()-- 时区问题
	local playerTime = PlayerCoreData.getCreatePlayerTime()
	local startTime = playerTime - (playerTime - standardTime)%86400-- +86400
	local keepDays = getGlobalIntegerValue('AllTargetReserveDays')

	if nowTime > startTime + 86400 * keepDays then 
		return false
	end
	return true
end
local function updateVipAward(jsonData)
	for i=1,_DAYS do
		day = jsonData[string.format('%d',i)]
		vipStatus[i] = day
	end
end
local function updateNormalAward(jsonData)
	for i=1,_DAYS do
		day = jsonData[string.format('%d',i)]
		if day then
			allStatus[1 +(3*(i-1))] = day['1']
			allStatus[2 +(3*(i-1))] = day['2']
			allStatus[3 +(3*(i-1))] = day['3']
		else
			allStatus[1 +(3*(i-1))] = nil
			allStatus[2 +(3*(i-1))] = nil
			allStatus[3 +(3*(i-1))] = nil
		end
	end
end
local function updateStatusForCurrency(jsonData)
	print("jsonData = "..jsonData)
	local jsonDic = json.decode(jsonData)
	data = jsonDic['data']
	alltarget = data['all_target']
	if alltarget == nil then
		return
	end
	daygot = alltarget['day_got']
	updateNormalAward(daygot)
	vipgot = alltarget['vip_got']
	updateVipAward(vipgot)
end
function updateAllStatusForCurrency()
	for var=1,_DAYSSTATUS do
		table.insert(allStatus,var)
		allStatus[var] = -1
	end

	for var=1,_DAYS do
		table.insert(vipStatus,var)
		vipStatus[var] = -1
	end

	Message.sendPost('get_all_target','activity','{}',function (jsonData)
		updateStatusForCurrency(jsonData)
	end)
end
function genGiftsPanel()
	-- UI
	local sceneObj = nil
	local panel = nil
	local dayBtns = {}
    local dayInfoTxs = {}
	local closeBtn = nil
    local rightBgImg = nil
	local headImg = nil
	local headDayTx = nil
	local headInfoTx = nil
	local dayDesc = nil
	local timeImg = nil
	local timeTX = nil
	local timeCDTx = nil
	local vipCardPl = nil
	local vipLV = nil
	local vipFrameImg = nil
	local vipInfoTx = nil
	local vipNumTx = nil
	local vipReward = nil
	local vipReceiveBtn = nil
	local vipLight = nil  --VIP 物品高亮
	local cardImg = {}
	local cardInfoTx = {}
	local cardFrameImg = {}
	local cardNumTx = {}
	local cardReward = {}
	local cardReceiveBtn = {}
	local allTargetData = {}
	local currDay = 1
	local currBtn = 1
	local _TexBtnNormal = 'uires/ui_2nd/com/panel/shop/bag_normal_btn.png'
	local _TexBtnSelected = 'uires/ui_2nd/com/panel/shop/bag_selected_btn.png'
	local _TexHeadDay = 'uires/ui_2nd/com/panel/open_service_activities/%d.png'
	local _TexHeadInfo = 'uires/ui_2nd/com/panel/open_service_activities/0%d.png'
	local _TexVIP = 'uires/ui_2nd/com/panel/vip/%d.png'
	local _TexDayDesc = 'E_STR_GIFTS_DAY_DESC_%d'--'CFGKEY_GIFTS_DAY_DESC%d'  
	local _TexTargetDesc = 'E_STR_GIFTS_TARGET_DESC_%d'--'CFGKEY_GIFTS_TARGET_DESC%d'
	local _TexDayBtnDesc = 'E_STR_GIFTS_DAY_BTN_DESC_%d'--'CFGKEY_GIFTS_DAY_BTN_DESC%d'

	local function getAllTarget()
		allTargetData = GameData:getArrayData('alltarget.dat')
	end
	local function updateNormalCellBtn(v)
		for currRightBtn=1,3,1 do
			currStatus = (v-1)*3 + currRightBtn
			if allStatus[currStatus] == 1 then
				cardReceiveBtn[currRightBtn]:setNormalButtonGray(true)
				cardReceiveBtn[currRightBtn]:setTouchEnable(false)
				cardReceiveBtn[currRightBtn]:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
				else if allStatus[currStatus] == 0 then 
					cardReceiveBtn[currRightBtn]:setNormalButtonGray(false)
					cardReceiveBtn[currRightBtn]:setTouchEnable(true)
					cardReceiveBtn[currRightBtn]:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
					else 
						cardReceiveBtn[currRightBtn]:setNormalButtonGray(true)
						cardReceiveBtn[currRightBtn]:setTouchEnable(false)
						cardReceiveBtn[currRightBtn]:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
				end
			end
		end
	end
	local function updateNormalCell(v)
		--获取
		if v >= 4 and v <= 5 then
			infotx1 = string.format(getLocalStringValue(string.format(_TexTargetDesc,v)),allTargetData[v].Target1,allTargetData[v].Param1)
			infotx2 = string.format(getLocalStringValue(string.format(_TexTargetDesc,v)),allTargetData[v].Target2,allTargetData[v].Param2)
			infotx3 = string.format(getLocalStringValue(string.format(_TexTargetDesc,v)),allTargetData[v].Target3,allTargetData[v].Param3)
		else
			infotx1 = string.format(getLocalStringValue(string.format(_TexTargetDesc,v)),allTargetData[v].Target1)
			infotx2 = string.format(getLocalStringValue(string.format(_TexTargetDesc,v)),allTargetData[v].Target2)
			infotx3 = string.format(getLocalStringValue(string.format(_TexTargetDesc,v)),allTargetData[v].Target3)
		end

		cardInfoTx[1]:setText(infotx1)
		cardInfoTx[2]:setText(infotx2)
		cardInfoTx[3]:setText(infotx3)

		reward1 = UserData:getAward(allTargetData[v].Award1)
		reward2 = UserData:getAward(allTargetData[v].Award2)
		reward3 = UserData:getAward(allTargetData[v].Award3)

		cardNumTx[1]:setText(toWordsNumber(tonumber(reward1.count)))
		cardNumTx[2]:setText(toWordsNumber(tonumber(reward2.count)))
		cardNumTx[3]:setText(toWordsNumber(tonumber(reward3.count)))

		cardReward[1]:setTexture(reward1.icon)
		cardReward[2]:setTexture(reward2.icon)
		cardReward[3]:setTexture(reward3.icon)

		cardFrameImg[1]:registerScriptTapHandler(function()
			UISvr:showTipsForAward(allTargetData[v].Award1)
		end)
		cardFrameImg[2]:registerScriptTapHandler(function()
			UISvr:showTipsForAward(allTargetData[v].Award2)
		end)
		cardFrameImg[3]:registerScriptTapHandler(function()
			UISvr:showTipsForAward(allTargetData[v].Award3)
		end)

		updateNormalCellBtn(v)
	end
	local function updateVIPcell(v)
		--获取VIP等级
		currVip = PlayerCoreData:getPlayerVIP()
		requiredVip = tonumber(allTargetData[v].VipTarget)
		vipLV:setTexture(string.format(_TexVIP,requiredVip))
		if vipStatus[v] == 1 then
			vipReceiveBtn:setNormalButtonGray(true)
			vipReceiveBtn:setTouchEnable(false)
			vipReceiveBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			else if currVip >= requiredVip and vipStatus[v] == 0 then
				vipReceiveBtn:setNormalButtonGray(false)
				vipReceiveBtn:setTouchEnable(true)
				vipReceiveBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
				else 
					vipReceiveBtn:setNormalButtonGray(true)
					vipReceiveBtn:setTouchEnable(false)
					vipReceiveBtn:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))			
				end
		end

		vipRewards = UserData:getAward(allTargetData[v].Award0)
		vipNumTx:setText(toWordsNumber(tonumber(vipRewards.count)))
		vipReward:setTexture(vipRewards.icon)
		vipFrameImg:registerScriptTapHandler(function()
			UISvr:showTipsForAward(allTargetData[v].Award0)
		end)
	end
	local function getTime(v)
		--存在时区问题 东8区
		local standardTime = UserData:convertTime( 1 , '2014:5:22:0:0:0')
		local nowTime = UserData:getServerTime()-- 时区问题
		local playerTime = PlayerCoreData.getCreatePlayerTime()
		local startTime = playerTime - (playerTime - standardTime)%86400 + 86400 * (v-1)-- 将开始时间格式化成北京时间
		
		if nowTime < startTime then
			return -1
		elseif nowTime >= startTime and nowTime < startTime + 86400 then
			return 0 , 86400 -nowTime + startTime
		else
			return 1
		end
	end
	local function updateTimePanel(v)
		local isStart , remainTime = getTime(v)
		if isStart == -1 then
			timeTX:setText(getLocalStringValue('E_STR_NOT_OPEN_BOSS'))
			timeTX:setColor(ccc3(50, 240, 50))
			timeCDTx:setVisible(false)
			else if isStart == 1 then
				timeTX:setText(getLocalStringValue('E_STR_ACCPAY_REWARD_OUT_OF_TIME'))
				timeTX:setColor(ccc3(50, 240, 50))
				timeCDTx:setVisible(false)
				else
					timeTX:setText('')
					timeTX:setColor(ccc3(50, 240, 50))
					timeCDTx:setVisible(true)
					timeCDTx:setTime(remainTime)
					timeCDTx:registerTimeoutHandler(function ()
						updateTimePanel(v)
					end)
			end
		end
	end
	local function updateRightPanel(v)
		buf = string.format(_TexHeadDay,v)
		headDayTx:setTexture(buf)
		buf = string.format(_TexHeadInfo,v)
		headInfoTx:setTexture(buf)
		headInfoTx:setAnchorPoint(ccp(0.0,0.5))

		dayDesc:setText(getLocalStringValue(string.format(_TexDayDesc,v)))
		dayDesc:setColor(ccc3(0, 200, 210))

		updateVIPcell(v)
		updateNormalCell(v)
	    updateTimePanel(v)
	end	
	local function updateBtnTex(v)
		for i=1,_DAYS,1 do
			if i ~= v then
				dayBtns[i]:setPressState(WidgetStateNormal)
				dayBtns[i]:setTouchEnable(true)
			end
		end
		dayBtns[v]:setTouchEnable(false)
		dayBtns[v]:setPressState(WidgetStateSelected)
	end
	local function updateLeftPanel()
		dayBtnDesc = {
			getLocalStringValue(string.format(_TexDayBtnDesc,1)),
			getLocalStringValue(string.format(_TexDayBtnDesc,2)),
			getLocalStringValue(string.format(_TexDayBtnDesc,3)),
			getLocalStringValue(string.format(_TexDayBtnDesc,4)),
			getLocalStringValue(string.format(_TexDayBtnDesc,5)),
			getLocalStringValue(string.format(_TexDayBtnDesc,6))
		}
		for i=1,_DAYS,1 do
			dayInfoTxs[i]:setText(dayBtnDesc[i])
		end
		local standardTime = UserData:convertTime( 1 , '2014:5:22:0:0:0')
		local nowTime = UserData:getServerTime()-- 时区问题
		local playerTime = PlayerCoreData.getCreatePlayerTime()
		local startTime = playerTime - (playerTime - standardTime)%86400
		timeDiff = nowTime - startTime
		local today = (timeDiff - timeDiff%86400)/86400 + 1
		if today < 1 or today > _DAYS then
			today = 6
		end
		dayBtns[today]:setPressState(WidgetStateSelected)
		dayBtns[today]:setTouchEnable(false)
		currBtn = today
	end
	local function unclaimed(v)
		isUnclaimed = false
		for i=1,v-1 do
			isUnclaimed = isUnclaimed or (allStatus[i + 3 * (i - 1)] == 0)
			isUnclaimed = isUnclaimed or (allStatus[i + 3 * (i - 1) + 1] == 0)
			isUnclaimed = isUnclaimed or (allStatus[i + 3 * (i - 1) + 2] == 0)
			if isUnclaimed == true then
				GameController.showMessageBox(getLocalStringValue('E_STR_GIFTS_REMINDER_DESC'), MESSAGE_BOX_TYPE.OK)
				break
			end
		end
	end
	local function updateStatus(jsonData)
		updateRightPanel(currBtn)
		if isInit == true then
			unclaimed(currBtn)
			isInit = false
		end
	end
	local function updateAllStatus()
		updateStatus(jsonData)
	end
	local function updateNormalAwardsStatus(jsonData)
		print("jsonData = "..jsonData)
		local jsonDic = json.decode(jsonData)
		data = jsonDic['data']
		alltarget = data['all_target']
		award = data['awards']
		UserData.parseAwardJson(json.encode(award))
		updateAllStatus()
		GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
	end
	local function updateVipAwardsStatus(jsonData)
		print("jsonData = "..jsonData)
		local jsonDic = json.decode(jsonData)
		data = jsonDic['data']
		alltarget = data['all_target']
		award = data['awards']
		UserData.parseAwardJson(json.encode(award))
		updateAllStatus()
		GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
	end
	local function onClickCardReceiveBtn(v)
		args = {
			day = currBtn,
			type = v,
		}
		Message.sendPost('get_all_target_rewards','activity',json.encode(args),function (jsonData)
			allStatus[v + 3 * (currBtn - 1)] = 1
			updateNormalAwardsStatus(jsonData)
		end)
	end	
	local function onClickVipReceiveBtn()
		args = {
			day = currBtn,
			type = 0,
		}
		Message.sendPost('get_all_target_rewards','activity',json.encode(args),function (jsonData)
			vipStatus[currBtn] = 1
			updateVipAwardsStatus(jsonData)
		end)
	end
	local function onClickDayBtn(v)
		currBtn = v
		updateBtnTex(v)
		updateRightPanel(v)
	end
	local function registerHandler()
		closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		for i=1,_DAYS,1 do
			dayBtns[i]:registerScriptTapHandler(function ()
				onClickDayBtn(i)
			end)
			GameController.addButtonSound(dayBtns[i] , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		end
		for i=1,3,1 do
			cardReceiveBtn[i]:registerScriptTapHandler(function ()
				onClickCardReceiveBtn(i)
			end)
			GameController.addButtonSound(cardReceiveBtn[i] , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		end	
		vipReceiveBtn:registerScriptTapHandler(function ()
			onClickVipReceiveBtn()
		end)
		GameController.addButtonSound(vipReceiveBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	end
    local function init()
    	
    	root = panel:GetRawPanel()
    	closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')

	    dayBtn1 = tolua.cast(root:getChildByName('day_1_btn') , 'UIButton')
	    dayBtn2 = tolua.cast(root:getChildByName('day_2_btn') , 'UIButton')
	    dayBtn3 = tolua.cast(root:getChildByName('day_3_btn') , 'UIButton')
	    dayBtn4 = tolua.cast(root:getChildByName('day_4_btn') , 'UIButton')
	    dayBtn5 = tolua.cast(root:getChildByName('day_5_btn') , 'UIButton')
	    dayBtn6 = tolua.cast(root:getChildByName('day_6_btn') , 'UIButton')
	    dayBtns = {dayBtn1,dayBtn2,dayBtn3,dayBtn4,dayBtn5,dayBtn6}
		dayInfoTx1 = tolua.cast(dayBtn1:getChildByName('info_tx') , 'UILabel')
		dayInfoTx1:setPreferredSize(170,1)
	    dayInfoTx2 = tolua.cast(dayBtn2:getChildByName('info_tx') , 'UILabel')
		dayInfoTx2:setPreferredSize(170,1)
	    dayInfoTx3 = tolua.cast(dayBtn3:getChildByName('info_tx') , 'UILabel')
		dayInfoTx3:setPreferredSize(170,1)
	    dayInfoTx4 = tolua.cast(dayBtn4:getChildByName('info_tx') , 'UILabel')
		dayInfoTx4:setPreferredSize(170,1)
	    dayInfoTx5 = tolua.cast(dayBtn5:getChildByName('info_tx') , 'UILabel')
		dayInfoTx5:setPreferredSize(170,1)
	    dayInfoTx6 = tolua.cast(dayBtn6:getChildByName('info_tx') , 'UILabel')
		dayInfoTx6:setPreferredSize(170,1)
		dayInfoTxs = {dayInfoTx1,dayInfoTx2,dayInfoTx3,dayInfoTx4,dayInfoTx5,dayInfoTx6}
		dayTx1 = tolua.cast(dayBtn1:getChildByName('day_tx') , 'UILabel')
	    dayTx2 = tolua.cast(dayBtn2:getChildByName('day_tx') , 'UILabel')
	    dayTx3 = tolua.cast(dayBtn3:getChildByName('day_tx') , 'UILabel')
	    dayTx4 = tolua.cast(dayBtn4:getChildByName('day_tx') , 'UILabel')
	    dayTx5 = tolua.cast(dayBtn5:getChildByName('day_tx') , 'UILabel')
	    dayTx6 = tolua.cast(dayBtn6:getChildByName('day_tx') , 'UILabel')
	    dayTx1:setColor(ccc3(255, 255, 0))
	    dayTx2:setColor(ccc3(255, 255, 0))
	    dayTx3:setColor(ccc3(255, 255, 0))
	    dayTx4:setColor(ccc3(255, 255, 0))
	    dayTx5:setColor(ccc3(255, 255, 0))
	    dayTx6:setColor(ccc3(255, 255, 0))
		rightBgImg = tolua.cast(root:getChildByName('right_bg_img') , 'UIImageView')
		headImg = tolua.cast(rightBgImg:getChildByName('liangtiao_img') , 'UIImageView')
		headDayTx = tolua.cast(headImg:getChildByName('day_txt_ico') , 'UIImageView')
		headInfoTx = tolua.cast(headImg:getChildByName('info_2_txt_ico') , 'UIImageView')

		dayDesc = tolua.cast(rightBgImg:getChildByName('info_tx') , 'UILabel')
		dayDesc:setPreferredSize(600,1)

	    timeImg = tolua.cast(rightBgImg:getChildByName('time_pl') , 'UIImageView')
	    timeTX = tolua.cast(timeImg:getChildByName('time_tx') , 'UILabel')
	    timeTX:setPreferredSize(400,1)
		timeCDTx = UICDLabel:create()
		timeCDTx:setFontSize(26)
		timeCDTx:setPosition(ccp(60,0))
		timeCDTx:setFontColor(ccc3(50, 240, 50))
		timeTX:addChild(timeCDTx)

	    vipCardPl = tolua.cast(root:getChildByName('vip_card_pl') , 'UIPanel')
	    vipLV = tolua.cast(vipCardPl:getChildByName('lv_ico') , 'UIImageView')
	    vipFrameImg = tolua.cast(vipCardPl:getChildByName('frame_img') , 'UIImageView')
	    vipInfoTx = tolua.cast(vipCardPl:getChildByName('info_tx') , 'UILabel')
	    vipInfoTx:setColor(ccc3(230,230,100))
	    vipNumTx = tolua.cast(vipCardPl:getChildByName('number_tx') , 'UILabel')
	    vipReward = tolua.cast(vipCardPl:getChildByName('reward_img') , 'UIImageView')
	    vipReceiveBtn = tolua.cast(vipCardPl:getChildByName('receive_btn') , 'UITextButton')
	    
	    --  设置光圈
	    vipLight = CUIEffect:create()
		vipLight:Show("yellow_light",0)
		vipLight:setScale(0.8)
		contentSize = vipFrameImg:getContentSize()
		vipLight:setPosition( ccp(0.0 , 0.0))
		vipLight:setAnchorPoint(ccp(0.5,0.5))
		vipFrameImg:getContainerNode():addChild(vipLight)
		vipLight:setTag(100)
		vipLight:setZOrder(100)
		vipLight:setVisible(true)

		cardPl1 = tolua.cast(root:getChildByName('card_1_pl') , 'UIPanel')
		cardInfoTx1 = tolua.cast(cardPl1:getChildByName('info_tx') , 'UILabel')
	    cardFrameImg1 = tolua.cast(cardPl1:getChildByName('frame_img') , 'UIImageView')
	    cardNumTx1 = tolua.cast(cardPl1:getChildByName('number_tx') , 'UILabel')
	   	cardReward1 = tolua.cast(cardPl1:getChildByName('reward_img') , 'UIImageView')
	    cardReceiveBtn1 = tolua.cast(cardPl1:getChildByName('receive_btn') , 'UITextButton')
	    cardInfoTx1:setPreferredSize(135,1)
	    
	    cardPl2 = tolua.cast(root:getChildByName('card_2_pl') , 'UIPanel')
		cardInfoTx2 = tolua.cast(cardPl2:getChildByName('info_tx') , 'UILabel')
	    cardFrameImg2 = tolua.cast(cardPl2:getChildByName('frame_img') , 'UIImageView')
	    cardNumTx2 = tolua.cast(cardPl2:getChildByName('number_tx') , 'UILabel')
	    cardReward2 = tolua.cast(cardPl2:getChildByName('reward_img') , 'UIImageView')
	   	cardReceiveBtn2 = tolua.cast(cardPl2:getChildByName('receive_btn') , 'UITextButton')
	    cardInfoTx2:setPreferredSize(135,1)

	    cardPl3 = tolua.cast(root:getChildByName('card_3_pl') , 'UIPanel')
		cardInfoTx3 = tolua.cast(cardPl3:getChildByName('info_tx') , 'UILabel')
	    cardFrameImg3 = tolua.cast(cardPl3:getChildByName('frame_img') , 'UIImageView')
	    cardNumTx3 = tolua.cast(cardPl3:getChildByName('number_tx') , 'UILabel')
	    cardReward3 = tolua.cast(cardPl3:getChildByName('reward_img') , 'UIImageView')
	    cardReceiveBtn3 = tolua.cast(cardPl3:getChildByName('receive_btn') , 'UITextButton')
	    cardInfoTx3:setPreferredSize(135,1)
	    cardImg = {cardPl1,cardPl2,cardPl3}
	    cardInfoTx = {cardInfoTx1,cardInfoTx2,cardInfoTx3}
	    cardFrameImg = {cardFrameImg1,cardFrameImg2,cardFrameImg3}
	    cardNumTx = {cardNumTx1,cardNumTx2,cardNumTx3}
	    cardReward = {cardReward1,cardReward2,cardReward3}
	    cardReceiveBtn = {cardReceiveBtn1,cardReceiveBtn2,cardReceiveBtn3}

		farmLight = {farmLight1,farmLight2,farmLight3}
		for i=1,3 do
			farmLight[i] = CUIEffect:create()
			farmLight[i]:Show("yellow_light",0)
			farmLight[i]:setScale(0.8)
			contentSize = cardFrameImg[i]:getContentSize()
			farmLight[i]:setPosition( ccp(0.0 , 0.0))
			farmLight[i]:setAnchorPoint(ccp(0.5,0.5))
			cardFrameImg[i]:getContainerNode():addChild(farmLight[i])
			farmLight[i]:setTag(100)
			farmLight[i]:setZOrder(100)
			farmLight[i]:setVisible(true)
		end
	    getAllTarget()
	    updateLeftPanel()
	    updateAllStatus()
	    registerHandler()
	    isInit = true
    end

    local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/gifts_panel.json', 'gifts-panel-lua')
	    panel = sceneObj:getPanelObj()
	    panel:setAdaptInfo('gifts_bg_img', 'gifts_img')

		panel:registerInitHandler(init)
		UiMan.show(sceneObj)
	end

	-- 入口
	local function getResponse()
		Message.sendPost('get_all_target','activity','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if tonumber(jsonDic['code']) ~= 0 then
				return
			end
			updateStatusForCurrency(jsonData)
			createPanel()
		end)
	end
	
	getResponse()
end