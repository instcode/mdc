RechargeAndPay = {}

function RechargeAndPay.isOpen()
	local activeConf = GameData:getMapData('activities.dat')
	local playerLevel = PlayerCoreData.getPlayerLevel()
	local serverOpenTime = Time.beginningOfOneDay(UserData:getServerTime())
	local actyStartTime = serverOpenTime + (tonumber(activeConf['paycostrank']['OpenDay']) - 1)*86400
	local nowTime = UserData:getServerTime()
	if playerLevel >= tonumber(activeConf['paycostrank']['OpenLevel']) then
		if nowTime >= actyStartTime then
			return true
		end
		return false
	end
	return false
end

function RechargeAndPay.enter()

	local sceneObj
	local panel
	local root
	local rechargeBtn
	local payBtn
	local rechargeWidget
	local payWidget
	local rechargeAndPayNum
	local rechargeAndPayTx
	local timeLeftCD
	local payGenBtn= {}
	local rechargeGenBtn= {}
	local payName = {}
	local rechargeName = {}
	local type = {
		'first',
		'second',
		'third',
	}

	local buttonMark = 0
	local updateDataEncode
	local totalIcon


	local function update()
		Message.sendPost('get_pay_cost_rank','activity','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic.code ~= 0 then
				return
			end
			local data = jsonDic.data
			updateDataEncode = json.encode(data)
			--消费或充值金额
			local updateDecode = json.decode(updateDataEncode)
			if buttonMark == 1 then
				rechargeAndPayNum:setText(updateDecode.pay)
				for i = 1, 3 do
					rechargeName[i]:setText(getLocalStringValue('E_STR_WELFARE_NORANK1'))
					if updateDecode['pay_rank'][i] then
						rechargeName[i]:setText(updateDecode['pay_rank'][i]['name'])
					end
				end
			elseif buttonMark == 2 then
				rechargeAndPayNum:setText(updateDecode.cost)
				for i = 1, 3 do
					payName[i]:setText(getLocalStringValue('E_STR_WELFARE_NORANK1'))
					if updateDecode['cost_rank'][i] then
						payName[i]:setText(updateDecode['cost_rank'][i]['name'])
					end
				end
			else
				print('buttonMark error!!!!!!!!!')
			end

			local beginWeek = Time.beginningOfWeek()
			local nowTime = UserData:getServerTime()
			print('xxxxddddd')
			print(beginWeek)
			print(nowTime)
			print(nowTime - beginWeek)
			local diffTime = nowTime - beginWeek

			--按钮状态及倒计时
			for i = 1, 3 do 
				if rechargeGenBtn[i] then
					rechargeGenBtn[i]:disable()
					rechargeGenBtn[i]:setText(getLocalStringValue('E_STR_RECHARGEANDPAY_CANGOT'))
				end
				if payGenBtn[i] then
					payGenBtn[i]:disable()
					payGenBtn[i]:setText(getLocalStringValue('E_STR_RECHARGEANDPAY_CANGOT'))
				end
			end
			print('diffTime~~~~~~~~~~~~~'..diffTime)
			if diffTime >= 86400 then --在星期二和星期天之间
				timeLeftInfo:setText(getLocalStringValue('E_STR_SHOP_DESC3'))
				timeLeftCD:setTime(7*86400 - diffTime)
			elseif diffTime >= 0 and diffTime < 86400 then  --在星期一
				timeLeftInfo:setText(getLocalStringValue('E_STR_GETAWARD_COUNTDOWN'))
				timeLeftCD:setTime(86400 - diffTime)
				local uid = PlayerCoreData.getUID()
				local rechargeRank = updateDecode.pay_rank
				local payRank = updateDecode.cost_rank

	 			for i = 1 , #rechargeRank do
	 				if tonumber(rechargeRank[i].uid) ==  tonumber(uid) then
	 					if rechargeRank[i] then
		 					if tonumber(updateDecode.got_pay) == 0 then
			 					rechargeGenBtn[i]:active()
			 				else
			 					rechargeGenBtn[i]:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			 				end
			 			end
	 				end
	 			end
	 			for i = 1 , #payRank do
	 				if tonumber(payRank[i].uid) ==  tonumber(uid) then
	 					if payGenBtn[i] then
		 					if tonumber(updateDecode.got_cost) == 0 then
			 					payGenBtn[i]:active()
			 				else
			 					payGenBtn[i]:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			 				end
			 			end
	 				end
	 			end
			end
		end)
	end

	local function clickRechargeBtn()
		buttonMark = 1
		totalIcon:setTexture('uires/ui_2nd/com/panel/rechargeandpay/rechargetotal.png')
		rechargeBtn:setPressState(WidgetStateSelected)
		payBtn:setPressState(WidgetStateNormal)
		rechargeWidget:setVisible(true)
		payWidget:setVisible(false)
		rechargeAndPayTx:setText(getLocalStringValue('E_STR_RECHARGEANDPAY_RECHARGEINFO'))

		local rechargeBg = {}
		local frame = {}
		local icon = {}
		local num = {}
		local award = {}
		local rechargeConf = GameData:getArrayData('paycostrankpayaward.dat')

		for i = 1 , 3 do
			local str = string.format('%s_img',type[i])
			rechargeBg[i] = tolua.cast(rechargeWidget:getChildByName(str), 'UIImageView')
			rechargeName[i] = tolua.cast(rechargeBg[i]:getChildByName('name1_tx'),'UILabel')
			rechargeGenBtn[i] = tolua.cast(rechargeBg[i]:getChildByName('gen1_btn'),'UITextButton')
			rechargeGenBtn[i]:registerScriptTapHandler(function()
				Message.sendPost('get_pay_cost_rank_award','activity',json.encode({type = 'pay'}),function (jsonData)
					cclog(jsonData)
					local jsonDic = json.decode(jsonData)
					if jsonDic.code ~= 0 then
						return
					end
					local data = jsonDic['data']
			        if not data then return end

			        local awards = data['awards']
			        local awardStr = json.encode(awards)
			        GameController.showPrompts(getLocalStringValue('E_STR_GET_SUCCEED'),COLOR_TYPE.GREEN)
			        UserData.parseAwardJson(awardStr)

			        rechargeGenBtn[i]:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))

					print('xxxx')
					update()
				end)
				end)
			frame[i] = {}
			icon[i] = {}
			num[i] = {}
			award[i] = {}
			for j = 1 , 4 do
				award[i][j] = UserData:getAward(rechargeConf[i][string.format('Award%d',j)])
				frame[i][j] = tolua.cast(rechargeBg[i]:getChildByName('frame'..j..'_img'), 'UIImageView')
				frame[i][j]:setTouchEnable(true)
				frame[i][j]:setTexture(GameController.getColorFrame(award[i][j].quality))
				frame[i][j]:registerScriptTapHandler(function()
					UISvr:showTipsForAward(rechargeConf[i][string.format('Award%d',j)])
					end)
				icon[i][j] = tolua.cast(frame[i][j]:getChildByName('icon'..j..'_img'), 'UIImageView')
				icon[i][j]:setTexture(award[i][j].icon)
				num[i][j] = tolua.cast(frame[i][j]:getChildByName('num'..j..'_tx'),'UILabel') 
				num[i][j]:setText(award[i][j].count)
			end
		end

		update()
	end

	local function clickPayBtn()
		buttonMark = 2
		totalIcon:setTexture('uires/ui_2nd/com/panel/rechargeandpay/paytotal.png')
		rechargeBtn:setPressState(WidgetStateNormal)
		payBtn:setPressState(WidgetStateSelected)
		rechargeWidget:setVisible(false)
		payWidget:setVisible(true)
		rechargeAndPayTx:setText(getLocalStringValue('E_STR_RECHARGEANDPAY_PAYINFO'))

		local payBg = {}
		local frame = {}
		local icon = {}
		local num = {}
		local award = {}
		local payConf = GameData:getArrayData('paycostrankcostaward.dat')

		for i = 1 , 3 do
			local str = string.format('%s_img',type[i])
			payBg[i] = tolua.cast(payWidget:getChildByName(str), 'UIImageView')
			payName[i] = tolua.cast(payBg[i]:getChildByName('name1_tx'),'UILabel')
			payGenBtn[i] = tolua.cast(payBg[i]:getChildByName('gen1_btn'),'UITextButton')
			payGenBtn[i]:registerScriptTapHandler(function()
				Message.sendPost('get_pay_cost_rank_award','activity',json.encode({type = 'cost'}),function (jsonData)
					cclog(jsonData)
					local jsonDic = json.decode(jsonData)
					if jsonDic.code ~= 0 then
						return
					end

					local data = jsonDic['data']
			        if not data then return end

			        local awards = data['awards']
			        local awardStr = json.encode(awards)
			        GameController.showPrompts(getLocalStringValue('E_STR_GET_SUCCEED'),COLOR_TYPE.GREEN)
			        UserData.parseAwardJson(awardStr)

			        payGenBtn[i]:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))

					print('uuuu')
					update()
				end)
				end)
			frame[i] = {}
			icon[i] = {}
			num[i] = {}
			award[i] = {}
			for j = 1 , 4 do
				award[i][j] = UserData:getAward(payConf[i][string.format('Award%d',j)])
				frame[i][j] = tolua.cast(payBg[i]:getChildByName('frame'..j..'_img'), 'UIImageView')
				frame[i][j]:setTouchEnable(true)
				frame[i][j]:setTexture(GameController.getColorFrame(award[i][j].quality))
				frame[i][j]:registerScriptTapHandler(function()
					UISvr:showTipsForAward(payConf[i][string.format('Award%d',j)])
					end)
				icon[i][j] = tolua.cast(frame[i][j]:getChildByName('icon'..j..'_img'), 'UIImageView')
				icon[i][j]:setTexture(award[i][j].icon)
				num[i][j] = tolua.cast(frame[i][j]:getChildByName('num'..j..'_tx'),'UILabel') 
				num[i][j]:setText(award[i][j].count)
			end
		end

		update()
	end

	local function showHelp()

		local sceneObjHelp = SceneObjEx:createObj('panel/rechargeandpay_help.json','rechargeandpay_help-in-lua')
		local panelHelp = sceneObjHelp:getPanelObj()
		panelHelp:setAdaptInfo('recharge_help_bg_img','help_img')

		panelHelp:registerInitHandler(function ()
			local rootHelp = panelHelp:GetRawPanel()

			local closeBtn = tolua.cast(rootHelp:getChildByName('close_btn'), 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObjHelp))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			local knowBtn = tolua.cast(rootHelp:getChildByName('ok_btn'),'UIButton')
			knowBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObjHelp))
			GameController.addButtonSound(knowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			for i = 1 , 5  do 
				local infoTx = tolua.cast(rootHelp:getChildByName('info_'..i..'_tx'),'UILabel') 
				infoTx:setText(getLocalStringValue('E_STR_RECHARGEANDPAY_HELP'..i))
				infoTx:setPreferredSize(580,1)
			end
		end)
		UiMan.show(sceneObjHelp)
	end

	local function init()
		root = panel:GetRawPanel()

		local helpBtn = tolua.cast(root:getChildByName('help_btn'),'UIButton')
		helpBtn:registerScriptTapHandler(showHelp)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		rechargeBtn = tolua.cast(root:getChildByName('title_1_btn'), 'UIButton')
		rechargeBtn:registerScriptTapHandler(clickRechargeBtn)
		GameController.addButtonSound(rechargeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		payBtn = tolua.cast(root:getChildByName('title_2_btn'), 'UIButton')
		payBtn:registerScriptTapHandler(clickPayBtn)
		GameController.addButtonSound(payBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local timeLeft = tolua.cast(root:getChildByName('timeleft_tx'),'UILabel') 
		timeLeftCD = UICDLabel:create()
 		timeLeftCD:setFontSize(22)
 		timeLeftCD:setPosition(ccp(0,0))
 		timeLeftCD:setFontColor(ccc3(50, 240, 50))
 		timeLeftCD:setAnchorPoint(ccp(0,0.5))
 		timeLeft:addChild(timeLeftCD)
		timeLeftCD:registerTimeoutHandler(function ()
			print('xxxxxxxx123456')
			update()
			end)
		timeLeftInfo = tolua.cast(root:getChildByName('timeleftinfo_tx'),'UILabel')  

		rechargeAndPayNum = tolua.cast(root:getChildByName('cashcost_num_tx'),'UILabel') 
		rechargeAndPayTx = tolua.cast(root:getChildByName('rechargeorpay_tx'),'UILabel') 

		rechargeWidget = tolua.cast(root:getChildByName('recharge_panel_img'), 'UIImageView')
		rechargeWidget:setVisible(false)

		payWidget = tolua.cast(root:getChildByName('pay_panel_img'), 'UIImageView')
		payWidget:setVisible(false)

		totalIcon = tolua.cast(root:getChildByName('total_img'),'UIImageView')

		clickRechargeBtn()
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/rechargeandpay_panel.json','rechargeandpay_panel-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('rank_bg_img','rank_img')

		panel:registerInitHandler(init)
		--panel:registerOnShowHandler(onShow)
		--panel:registerOnHideHandler(onHide)
		UiMan.show(sceneObj)
	end

	local function sendUpdateRequestAndCreate()
		Message.sendPost('get_pay_cost_rank','activity','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic.code ~= 0 then
				return
			end
			-- local data = jsonDic.data
			-- updateDataEncode = json.encode(data)

			createPanel()
		end)
	end

	local function isFunctionOpen()
		sendUpdateRequestAndCreate()
	end
	--入口
	isFunctionOpen()
end

