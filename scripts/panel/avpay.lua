Avpay = {}

local conf = GameData:getArrayData('activities.dat')
local gift = {}
local rewardFrame = {}
local pPage

local function getConf()
	local data = GameData:getArrayData('activities.dat')
	table.foreach(data , function (_ , v)
		if v['Key'] == 'payceremony' then
			conf = v
		end
	end)
end

function onClickIndent(v,i)
    showIndentPanel(v,i)
end

function ShowTotalAwardsPanel(awards,infoTx )
	local showAward = SceneObjEx:createObj('panel/thousandfloor_res_panel.json', 'show-award-total-panel')
    local panel = showAward:getPanelObj()
    panel:setAdaptInfo('gain_res_bg_img', 'gain_res_img')

    panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		local gainBgImg = tolua.cast(root:getChildByName('gain_res_bg_img'),'UIImageView')
		local gainImg = tolua.cast(gainBgImg:getChildByName('gain_res_img'),'UIImageView')
		local gongxi = tolua.cast(root:getChildByName('gongxi_bg_ico'),'UIImageView')
		gongxi:setVisible(false)

		local know_btn = tolua.cast(gainImg:getChildByName('know_btn'),'UITextButton')
		GameController.addButtonSound(know_btn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		know_btn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(showAward, ELF_HIDE.SMART_HIDE)
		end)

		local info_tx = tolua.cast(gainImg:getChildByName('info_tx') , 'UILabel')
		info_tx:setText(infoTx)

		local awardSv = tolua.cast(gainImg:getChildByName('award_sv') , 'UIScrollView')
		awardSv:setClippingEnable(true)
		awardSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
		local awardNum = #awards
		for k, v in pairs(awards) do
			local award = UserData:getAward(v)
			local awardImg = createWidgetByName('panel/thousandfloor_award_panel.json')
			local awardRoot = tolua.cast(awardImg:getChildByName('res_photo_ico') , 'UIImageView')
			local pIco = tolua.cast(awardRoot:getChildByName('res_ico') , 'UIImageView')
			local pName = tolua.cast(awardRoot:getChildByName('res_name_tx') , 'UILabel')
			local pNum = tolua.cast(awardRoot:getChildByName('res_num_tx') , 'UILabel')
			pIco:setTouchEnable(true)
			pIco:registerScriptTapHandler( function()
				UISvr:showTipsForAward(v)
			end )
			pIco:setTexture(award.icon)
			pIco:setAnchorPoint(ccp(0,0))
			pName:setText(award.name)
			pName:setColor(award.color)
			pNum:setText(toWordsNumber(award.count))
			awardSv:addChildToRight(awardImg)
		end
		if awardNum == 1 then
			awardSv:setPosition(ccp(140,150))
		elseif awardNum == 2 then
			awardSv:setPosition(ccp(75,150))
		end
	end)
    CUIManager:GetInstance():ShowObject(showAward, ELF_SHOW.SMART)
end

local function isFuncOpen()
	local targetLv = tonumber(GameData:getGlobalValue('xxxxxx'))
	if PlayerCoreData.getPlayerLevel() < targetLv then
		local s = string.format(getLocalStringValue('E_STR_GO_OPEN') , targetLv)
		GameController.showMessageBox(s, MESSAGE_BOX_TYPE.OK)
		return false
	end
	return true
end

function Avpay.isActive()
	return false
end

--活动是否超时-- 活动开始结束时间和延时领取时间
function Avpay.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'payceremony' then
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
function Avpay.enter()
	
	-- 定义一些常量

	--local AVFoodConf = GameData:getArrayData('avfood.dat');

	local sceneObj
	local panel
	local root
	local genBtn
	local startBtn
	local giftBox
	local remainScoreNum
	local remainGiftNum
	local markScore
	local markBox
	local genBtnState =0
	local startBtnState
	local rankTab = {}  --充值档次
	local cashNum = 0 
	local gotNum = 0
	local closeBtn
	local helpBtn
	local tabrm = {}
	local quan = {}
	local rewardCash = {}
	local rewardPos =nil
	local function getGotNextLevel( cash )
		local  gotconf = GameData:getArrayData('avpayceremony.dat')

		for _, v in pairs(gotconf) do
			if tonumber(cash) < tonumber(v.Id) then
				return v
			end
		end
		return nil
	end 

	-- 判断活动是否结束
	local function judgeOverTime()
		if Avpay.isOverTime() then
			GameController.showPrompts(getLocalStringValue('E_STR_ACTIVITY_TIMEOUT_DESC'), COLOR_TYPE.RED)
			return true
		end
		return false
	end

	-- 设置按钮状态
	-- local function setAwardBtnType()
	-- end
	local function btnState()
		--判断领奖的三个状态，未达成、已领取、达成未领取
		--cclog('genBtnState~~~~~~~~~~~~~~' .. genBtnState)
		if genBtnState == 1 then
			genBtn:setText('')
			local str = UILabel:create()
			str:setFontSize(20)
			str:setPreferredSize(70,1)
			str:setText(getLocalStringValue('E_STR_ARENA_HAVE_NOT_ACHIEVE'))
			genBtn:addChild(str)
			-- genBtn:setText(getLocalStringValue('E_STR_ARENA_HAVE_NOT_ACHIEVE'))
			genBtn:setTouchEnable(false)
			genBtn:setNormalButtonGray(true)
		elseif genBtnState == 2 then
			genBtn:setText('')
			local str = UILabel:create()
			str:setFontSize(20)
			str:setPreferredSize(70,1)
			str:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			genBtn:addChild(str)
			-- genBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			genBtn:setTouchEnable(false)
			genBtn:setNormalButtonGray(true)
		elseif genBtnState == 3 then
			genBtn:setText('')
			local str = UILabel:create()
			str:setFontSize(20)
			str:setPreferredSize(70,1)
			str:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
			genBtn:addChild(str)
			-- genBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
			genBtn:setTouchEnable(true)
			genBtn:setNormalButtonGray(false)
		end
	end

	local function startBtnStateFun()
		--判断开启按钮的两个状态，领取、开启
		--cclog('startBtnState~~~~~~~~~~~~~~' .. startBtnState)
		if startBtnState == 1 then
			startBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
		elseif startBtnState == 2 then
			startBtn:setText(getLocalStringValue('E_STR_ATTR_GEM_START'))
		end
	end

	local function genRandomCount()
		local count
		if not count then
			local values = GameData:getMapData('avpayceremonybox.dat')
			local num = 0
			for k,v in pairs(values) do
				num = num + 1
			end
			count = num
		end
		return count
	end

	local function genRandomawards(id)
		id = tostring(id)
		local values = GameData:getMapData('avpayceremonybox.dat')
		for _, v in pairs(values) do
			if id == v['Id'] then
				return v.Award1
			end
		end
	end
	local function genRandomIndex(awards)
		awards = tostring(awards)
		local values = GameData:getMapData('avpayceremonybox.dat')
		for _, v in pairs(values) do
			if awards == v['Award1'] then
				cclog("v.Award1".. v['Award1'])
				return v.Id
			end
		end
	end

	-- 刷新按钮
	local function updatePanel()
		--cclog('xlxlxlxxlxlxlxlxlx')

		local totalCashCost = tolua.cast(root:getChildByName('info_2_bg'), 'UIImageView')
		local totalCashCostNum = tolua.cast(totalCashCost:getChildByName('time_tx'), 'UILabel')		
		local remainGift = tolua.cast(root:getChildByName('info_3_bg'), 'UIImageView')
		remainGiftNum = tolua.cast(remainGift:getChildByName('time_tx'), 'UILabel')
		local remainScore = tolua.cast(root:getChildByName('info_4_bg'), 'UIImageView') 
		remainScoreNum = tolua.cast(remainScore:getChildByName('time_tx'), 'UILabel') 


		local function messagereq(  )
			Message.sendPost('get_pay_ceremony','activity','{}',function ( jsonData )
				cclog(jsonData)
				local response = json.decode(jsonData)
				if response.code ~= 0 then
					return
				end
				local data = response.data
				local avpay = data.pay_ceremony
				local box = avpay.box
				local score = avpay.score
				local cash = avpay.cash
				local got = avpay.got
				cashNum = cash
				gotNum = got
				--cclog('aaaaaaaaaaaaaaaaaaaaaaaaaaaa')

				markScore = score
				markBox = box
				totalCashCostNum:setText(cash)
				remainGiftNum:setText(box)
				remainScoreNum:setText(score)

				--判断累计充值领奖状态 rankTab[][x,0,0,x] 未达到  rankTab[][x,1,0,x]达到未领取  rankTab[][x,1,1,x]达到已领取
				for i =1 ,6 do
					rankTab[i] = {} 
					local rankData = GameData:getArrayData('avpayceremony.dat')
					table.foreach(rankData , function (_ , v)
						if tonumber(v['key']) == i then
							rankTab[i] = {v['Id'] ,0 ,0 , v['Award1']}
							if tonumber(got) >= tonumber(v['Id']) then
								rankTab[i][3] = 1
								gift[i]:setGray()
								gift[i]:setTouchEnable(false)
								local item={}
								item[i] = tolua.cast(gift[i]:getChildByName('item_ico'), 'UIImageView')
								item[i]:setGray()
								item[i]:setTouchEnable(false)
								quan[i]:setVisible(true)
							end
						end

					end)
				end

				local process = tolua.cast(root:getChildByName('exp_bar'), 'UILoadingBar')
				process:setTexture('uires/ui_2nd/com/panel/haoli/recharge_bar.png')
				local percentForEach = 100/14
				if cash == 0 then  
				process:setPercent(percentForEach*0)
				elseif cash > 0 and cash < tonumber(rankTab[1][1]) then
				process:setPercent(percentForEach*1)
				elseif cash == tonumber(rankTab[1][1])  then
				process:setPercent(percentForEach*2)
				elseif cash > tonumber(rankTab[1][1]) and cash < tonumber(rankTab[2][1]) then
				process:setPercent(percentForEach*3)
				elseif cash == tonumber(rankTab[2][1])  then
				process:setPercent(percentForEach*4)
				elseif cash > tonumber(rankTab[2][1]) and cash < tonumber(rankTab[3][1]) then
				process:setPercent(percentForEach*5)
				elseif cash == tonumber(rankTab[3][1])  then
				process:setPercent(percentForEach*6)
				elseif cash > tonumber(rankTab[3][1]) and cash < tonumber(rankTab[4][1]) then
				process:setPercent(percentForEach*7)
				elseif cash == tonumber(rankTab[4][1])  then
				process:setPercent(percentForEach*8)
				elseif cash > tonumber(rankTab[4][1]) and cash < tonumber(rankTab[5][1]) then
				process:setPercent(percentForEach*9)			
				elseif cash == tonumber(rankTab[5][1])  then
				process:setPercent(percentForEach*10)
				elseif cash > tonumber(rankTab[5][1]) and cash < tonumber(rankTab[6][1]) then
				process:setPercent(percentForEach*11)	
				elseif cash == tonumber(rankTab[6][1])  then
				process:setPercent(percentForEach*12)
				elseif cash > tonumber(rankTab[6][1])  then				
				process:setPercent(percentForEach*13)	
				end		

				--判断按钮状态
				--判断领奖的三个状态，未达成、已领取、达成未领取
				if getGotNextLevel(gotNum) ~= nil then
					local nextgot =tonumber(getGotNextLevel(gotNum).Id)
					local tempcash =tonumber(cash)
					local tempgot = tonumber(gotNum)

					if (tempcash > tempgot) and (tempcash >= nextgot) then
						genBtnState = 3
					elseif  rankTab[6][3] == 1 then
						genBtnState = 2
					else --(tempcash == 0 and tempgot == tempcash) or (( tempcash > tempgot) and (tempcash < nextgot)) then
						genBtnState = 1
					end
				else
					genBtnState = 2
				end

				------
				btnState()
			end)
		end

		messagereq()

	end

	local function clickHelp()
		local sceneObjHelp = SceneObjEx:createObj('panel/luxury_gift_recharge_help_panel.json','avpayhelp-in-lua')
		local panelHelp = sceneObjHelp:getPanelObj()
		panelHelp:setAdaptInfo('recharge_help_bg_img','help_img')

		panelHelp:registerInitHandler(function ()
			local rootHelp = panelHelp:GetRawPanel()
			rootHelp:setTouchEnable(true)

			local closeBtn = tolua.cast(rootHelp:getChildByName('close_btn'), 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObjHelp))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			local knowBtn = tolua.cast(rootHelp:getChildByName('ok_btn'),'UIButton')
			knowBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObjHelp))
			GameController.addButtonSound(knowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		end)
		--panel:registerOnShowHandler(onShow)
		--panel:registerOnHideHandler(onHide)

		UiMan.show(sceneObjHelp)
	end

	local function clickGen()

		local vvStr

		Message.sendPost('get_award_pay_ceremony','activity','{}',function ( jsonData )
			cclog(jsonData)
			local response = json.decode(jsonData)
			if response.code ~= 0 then
				--genBtnState = 1
				--btnState()
				return
			end
			
			local data = response.data
			local awards = data.awards
			local awardsData = json.encode(awards)
			UserData.parseAwardJson(awardsData)

			local vStr
			local tab = {}
			cclog('awards.....')
			cclog(awardsData)
			gotNum =getGotNextLevel(gotNum).Id
			if awards then
				for k,v in pairs(awards) do
					vStr = v[1]..'.'..v[2]..':'..v[3]
					table.insert(tab , vStr)
					vvStr = vStr
				end
				genShowTotalAwardsPanel(tab,'' )
				for i =1 ,6 do
					if rankTab[i][4] == vvStr then
						rankTab[i][3] = 1
					end
				end

			end

		end)
	end
	local function LockBtn()

		startBtn:setTouchEnable(false)
		genBtn:setTouchEnable(false)
		helpBtn:setTouchEnable(false)
		closeBtn:setTouchEnable(false)
		for i=1,6 do
			gift[i]:setTouchEnable(false)
		end
	end
	local function OpenBtn()
		startBtn:setTouchEnable(true)
		genBtn:setTouchEnable(true)
		helpBtn:setTouchEnable(true)
		closeBtn:setTouchEnable(true)
		for i=1,6 do
			gift[i]:setTouchEnable(true)
		end
	end
	local function boxopen(  )
		giftBox:setTexture('uires/ui_2nd/com/panel/avpay/box_open.png')
	end
	local function boxclosed(  )
		giftBox:setTexture('uires/ui_2nd/com/panel/avpay/box_closed.png')
	end
	local function resetAwardsPos(  )
		for i = 1, tonumber(genRandomCount())*4 do
       		local id = i % tonumber(genRandomCount()) +1
       		local awards =genRandomawards(id)
       		pPage:setPosition(ccp(252,55))
			local awardTmp = UserData:getAward(awards)
			local item_frame_name = 'item_frame_' .. i ..'_img'
			local rewardPhoto  = tolua.cast(rewardFrame[i]:getChildByName('item_frame_img'),'UIImageView')
			local rewardIco    = tolua.cast(rewardFrame[i]:getChildByName('item_ico'),'UIImageView')
			local rewardNumTx  = tolua.cast(rewardFrame[i]:getChildByName('num_tx'),'UILabel')
			local rewardGai    = tolua.cast(rewardFrame[i]:getChildByName('gai_ico'),'UIImageView')
				  rewardGai:setVisible(false)
				  rewardPhoto:setNormal()
				  rewardIco:setNormal()
			if awardTmp then 
				rewardFrame[i]:setVisible(true)
				local size = rewardFrame[i]:getRect()
				local width = size:getMaxX() - size:getMinX()
				local hight = size:getMaxY() - size:getMinY()
				--cclog('width ====' ..width)
				rewardFrame[i]:setPosition(ccp((width)*(i-1)-200-width/2,-hight /2))
				rewardFrame[i]:setWidgetZOrder(99)
				rewardFrame[i]:setWidgetTag(i*9527)
				rewardNumTx:setText(toWordsNumber(tonumber(awardTmp.count)))
				rewardIco:setTexture(awardTmp.icon)
				rewardIco:setAnchorPoint(ccp(0.5, 0.5))
						
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
			end
       	end
       	boxclosed()
	end
	local function ResetGai()
		for i = 1, tonumber(genRandomCount())*4 do
			local rewardIco    = tolua.cast(rewardFrame[i]:getChildByName('item_ico'),'UIImageView')
			local rewardGai = tolua.cast(rewardFrame[i]:getChildByName('gai_ico'),'UIImageView')
			rewardGai:setVisible(false)
			local rewardPhoto  = tolua.cast(rewardFrame[i]:getChildByName('item_frame_img'),'UIImageView')
			rewardPhoto:setTexture('uires/ui_2nd/com/panel/common/frame.png')
			rewardPhoto:setGray()
			rewardIco:setGray()
			if rewardPos ~= nil then
				if (genRandomCount()*2+rewardPos -1) == i then
					rewardPhoto:setNormal()
					rewardIco:setNormal()
				end
			end
		end
	end
	local function getRandomAward(  )
		-- genShowTotalAwardsPanel(tabrm,'' )
		for i,v in ipairs(tabrm) do
			award = UserData:getAward(v)
			str = string.format(getLocalStringValue('E_STR_YOUR_GAIN_MATERIAL'),award.count,award.name)
			GameController.showPrompts(str, COLOR_TYPE.GREEN)
		end
		table.remove(tabrm, 1)
	end
	local function Animation( index )
		cclog ('index=====' ..index)
		cclog('animation')
		local dis = (genRandomCount()*2+index)*(-100)+252+400
		local eftDelay =3
		local arr = CCArray:create()
		local moveTo = CCMoveTo:create(eftDelay, ccp(dis,55))
		local fun1 = CCCallFunc:create(resetAwardsPos)
		local fun2 = CCCallFunc:create(ResetGai)
		local fun4 = CCCallFunc:create(OpenBtn)
		local fun5 = CCCallFunc:create(boxopen)
		local fun6 = CCCallFunc:create(getRandomAward)
		arr:addObject(fun1)
		arr:addObject(moveTo)
		arr:addObject(fun5)
		arr:addObject(fun2)
		arr:addObject(fun6)
		arr:addObject(CCDelayTime:create(1))
		arr:addObject(fun4)
		pPage:runAction(CCSequence:create(arr))	

	end
	local function clickStart()
		if markBox and type(markBox) == 'number' then
			Message.sendPost('open_box_pay_ceremony','activity','{}',function ( jsonData )
				cclog(jsonData)
				local response = json.decode(jsonData)
				if response.code ~= 0 then
					if markBox == 0 then
						GameController:showPrompts(getLocalString('E_STR_AVPAY_NO_BOX'), COLOR_TYPE.RED)
					elseif markScore < getGlobalIntegerValue("PayCeremonyEachScoreCost") then
						GameController:showPrompts(getLocalString('E_STR_AVPAY_NO_SCORE'), COLOR_TYPE.RED)
					end
					return
				end
				LockBtn()
				local data = response.data
				local awards = data.awards
				local awardsData = json.encode(awards)
				UserData.parseAwardJson(awardsData)

				local vStr
				
				cclog('awards.....')
				cclog(awardsData)		
				if awards then
					for k,v in pairs(awards) do
						vStr = v[1]..'.'..v[2]..':'..v[3]
						print(vStr)
						table.insert(tabrm , vStr)
					end
					--cclog('clickStart~~~~~~~~~~~~~~~~~~~~genShowTotalAwardsPanel')
				end
				markScore = markScore - getGlobalIntegerValue("PayCeremonyEachScoreCost")
				remainScoreNum:setText(markScore)
				markBox = markBox - 1
				remainGiftNum:setText(markBox)
				rewardPos =tonumber(genRandomIndex(vStr))
				Animation(tonumber(rewardPos))
			end)
			--播放完3秒动画后，箱子变成开启状态
			--
		end
	end

	local function onHide()
	end 

	local function onShow()
		btnState()
		updatePanel()
	end

	local function init()
		root = panel:GetRawPanel()
		root:setTouchEnable(true)

		closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		helpBtn = tolua.cast(root:getChildByName('help_btn'),'UIButton')
		helpBtn:registerScriptTapHandler(clickHelp)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		genBtn = tolua.cast(root:getChildByName('get_btn'),'UITextButton')
		genBtn:registerScriptTapHandler(clickGen)
		GameController.addButtonSound(genBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		startBtn = tolua.cast(root:getChildByName('start_btn'),'UITextButton')
		startBtn:setTouchEnable(true)
		startBtn:registerScriptTapHandler(clickStart)
		GameController.addButtonSound(startBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		pPage = UIContainerWidget:create()
		getConf()
		local fr = tolua.cast(root:getChildByName('frame_2_img'), 'UIImageView')
		local infoTx = tolua.cast(fr:getChildByName('info_tx'), 'UILabel')
		infoTx:setPreferredSize(820,1)
		local remainTimes = tolua.cast(root:getChildByName('info_1_bg'), 'UIImageView')
		local remainTimesNum = tolua.cast(remainTimes:getChildByName('time_tx'), 'UILabel')
		remainTimesNum:setText('')
		local remainTimesNumCD = UICDLabel:create()
		remainTimesNumCD:setFontSize(22)
		remainTimesNumCD:setPosition(ccp(0,0))
		remainTimesNumCD:setFontColor(ccc3(50, 240, 50))
		remainTimesNumCD:setAnchorPoint(ccp(0,0.5))
		remainTimesNum:addChild(remainTimesNumCD)
		remainTimesNumCD:setTime(UserData:convertTime(1, conf.EndTime) - UserData:getServerTime())
		
		

		local tab = {}
		--local gift = {}
		local item = {}
		for i = 1 , 6 do
			tab[i] = {}
			
			local data = GameData:getArrayData('avpayceremony.dat')
			table.foreach(data , function (_ , v)
				if tonumber(v['key']) == i then
					tab[i] = {v['Award1'],v['Id']}
				end
			end)


			gift[i] = tolua.cast(root:getChildByName('item_frame_'..i..'_img'), 'UIImageView')
			rewardCash[i] = tolua.cast(root:getChildByName('num_tx_'..i),'UILabelAtlas')
			rewardCash[i]:setStringValue(tostring(tab[i][2]))
			item[i] = tolua.cast(gift[i]:getChildByName('item_ico'), 'UIImageView')
			quan[i] = tolua.cast(gift[i]:getChildByName('quan_img'), 'UIImageView')
			quan[i]:setVisible(false)
			item[i]:setTexture('uires/ui_2nd/image/item/wheel_bag_gem3.png')
			gift[i]:registerScriptTapHandler(function (  )
				local tab1 = {tab[i][1]}
				ShowTotalAwardsPanel(tab1,getLocalStringValue('E_STR_MYSTICAL') )

			end)
		end
		--初始化抽奖箱子
		local function resetRewardPos()

			local selectItem = tolua.cast(root:getChildByName('select_bg_img'), 'UIImageView')
			local selectItemIcon = tolua.cast(selectItem:getChildByName('select_frame_img'), 'UIImageView') 
			selectItemIcon:setWidgetZOrder(9999)
			local Sv = tolua.cast(selectItem:getChildByName('sv'), 'UIScrollView')
	      	Sv:setClippingEnable(true)
	       	Sv:setTouchEnable(false) 
	       	
	        pPage:setWidgetZOrder(9)
	        pPage:setAnchorPoint(ccp(0.5,0.5))


	        for i=1,5 do
	        	local rewardPhoto  = tolua.cast(selectItem:getChildByName('item_frame_' .. i ..'_img'),'UIImageView')
	        	rewardPhoto:setVisible(false)
	        end
			for i = 1, tonumber(genRandomCount())*4 do
	       		local id = i % tonumber(genRandomCount()) +1
	       		local awards =genRandomawards(id)
	       		pPage:setPosition(ccp(252,55))
				local awardTmp = UserData:getAward(awards)
				local item_frame_name = 'item_frame_' .. i ..'_img'
				rewardFrame[i] = createWidgetByName('panel/luxury_gift_recharge_reward_panel.json')
				rewardFrame[i]:setTouchEnable(true)
				local rewardPhoto  = tolua.cast(rewardFrame[i]:getChildByName('item_frame_img'),'UIImageView')
				local rewardIco    = tolua.cast(rewardFrame[i]:getChildByName('item_ico'),'UIImageView')
				local rewardNumTx  = tolua.cast(rewardFrame[i]:getChildByName('num_tx'),'UILabel')
				local rewardGai    = tolua.cast(rewardFrame[i]:getChildByName('gai_ico'),'UIImageView')
					  rewardGai:setVisible(false)
					  rewardGai:setScale(1.2)
					  rewardGai:setTexture('uires/ui_2nd/com/panel/role/stone2.png')
				if awardTmp then 
					rewardFrame[i]:setVisible(true)
					local size = rewardFrame[i]:getRect()
					local width = size:getMaxX() - size:getMinX()
					local hight = size:getMaxY() - size:getMinY()
					--cclog('width ====' ..width)
					rewardFrame[i]:setPosition(ccp((width)*(i-1)-200-width/2,-hight /2))
					rewardFrame[i]:setWidgetZOrder(99)
					rewardFrame[i]:setWidgetTag(i*9527)
					rewardNumTx:setText(toWordsNumber(tonumber(awardTmp.count)))
					rewardIco:setTexture(awardTmp.icon)
					rewardIco:setAnchorPoint(ccp(0.5, 0.5))
				end
				pPage:addChild(rewardFrame[i])
	       	end
	       	    Sv:addChild(pPage)
		end
		resetRewardPos()

		giftBox = tolua.cast(root:getChildByName('box_img'), 'UIImageView') 
		giftBox:setTexture('uires/ui_2nd/com/panel/avpay/box_closed.png')

    	updatePanel()
	end


	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/luxury_gift_recharge_bg_panel.json','avpay-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('recharge_bg_img','recharge_img')

		panel:registerInitHandler(init)
		panel:registerOnShowHandler(onShow)
		panel:registerOnHideHandler(onHide)
		UiMan.show(sceneObj)
	end

	local function getAvpayResponse()
		-- if isFuncOpen() then
			createPanel()
		-- end
	end

	--入口
	getAvpayResponse()
end