God = {}

function God.isTimeOver()
	local giveGodAwardConf = GameData:getArrayData('god.dat')
	local time = UserData:getServerTime() - PlayerCoreData.getCreatePlayerTime()
	local leftTime = tonumber(giveGodAwardConf[3].AccountCreateTimePass) - time
	if leftTime < 0 then
		return true
	end
	return false
end
function God.giveGodAward()
	local sceneObj
	local panel
	local data

	local giveGodAwardConf = GameData:getArrayData('god.dat')
    local giveheroConf = GameData:getArrayData('givehero.dat')

    local function getAward(i,receiveBtn)
	    args = {
			id = i
		}
    	Message.sendPost('get_reward','god',json.encode(args),function(jsondata)
    			print(jsondata)
				local response = json.decode(jsondata)
				local code = tonumber(response.code)
				if code == 0 then
					giveGod = response.data.god
					setGodData(response.data.god)
					for i=1,3 do
						print(giveGod.got_reward[i])
						print(giveGod.status[i])
						if giveGod.got_reward[i] ~= 1 and giveGod.status[i] == 1 then
						end
					end

					local awards = response.data.awards
					local awardStr = json.encode(awards)
					UserData.parseAwardJson(awardStr)
					GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
					receiveBtn:setNormalButtonGray(true)
					receiveBtn:setTouchEnable(false)
					receiveBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
				end
    		end)
    end
    local function updateAward(view)
    	for i=1,3 do
    		local str = 'land_'..i..'_img'
    		local land = tolua.cast(view:getChildByName(str), 'UIImageView')
    		local info = tolua.cast(land:getChildByName('info'), 'UILabel')
    		local timeTx = tolua.cast(land:getChildByName('time_tx'), 'UILabel')
    		local receiveBtn = tolua.cast(land:getChildByName('receive_btn'), 'UITextButton')
    		local award1 = UserData:getAward(giveGodAwardConf[i].Award1)
    		local award2 = UserData:getAward(giveGodAwardConf[i].Award2)
    		local award3 = UserData:getAward(giveGodAwardConf[i].Award3)
    		local award4 = UserData:getAward(giveGodAwardConf[i].Award4)
			local awards = {award1,award2,award3,award4}
			local godAwards = {giveGodAwardConf[i].Award1,giveGodAwardConf[i].Award2,giveGodAwardConf[i].Award3,giveGodAwardConf[i].Award4}

    		for j=1,4 do
    			local str1 = 'item_photo_'..j
    			local item = tolua.cast(land:getChildByName(str1), 'UIImageView')
    			local itemIco = tolua.cast(item:getChildByName('item_ico'), 'UIImageView')
    			local itemNum = tolua.cast(item:getChildByName('item_num_tx'), 'UILabel')
    			local itemName = tolua.cast(item:getChildByName('item_name_tx'), 'UILabel')
    			itemName:setPreferredSize(120,1)

				itemNum:setText(toWordsNumber(tonumber(awards[j].count)))
				itemName:setFontSize(16)
				itemName:setText(awards[j].name)
				itemIco:setTexture(awards[j].icon)
				itemIco:registerScriptTapHandler(function()
					UISvr:showTipsForAward(godAwards[j])
				end)
    		end

    		timeTx:setText('')
    		local leftTimeLabel = UICDLabel:create()
			leftTimeLabel:setFontSize(20)
			leftTimeLabel:setFontColor(COLOR_TYPE.WHITE)
			-- leftTimeLabel:setPosition(ccp(80, 0))
			leftTimeLabel:setAnchorPoint(ccp(0,0))
			timeTx:addChild(leftTimeLabel)

    		local time = UserData:getServerTime() - PlayerCoreData.getCreatePlayerTime()
			local leftTime = tonumber(giveGodAwardConf[i].AccountCreateTimePass) - time
			if leftTime < 0 then
				leftTime = 0
				timeTx:setVisible(false)
			end
			leftTimeLabel:setTime(leftTime)
			leftTimeLabel:setFontColor(ccc3(255,255,204))

			if tonumber(data.status[i]) == 0 then
				if leftTime == 0 then
					status = getLocalStringValue('E_STR_GET_GOD_ROLE_FALIUE')
				else
					status = getLocalStringValue('E_STR_GOD_ROLE_ING')
				end
			elseif tonumber(data.status[i]) == 1 then
				status = getLocalStringValue('E_STR_GOD_ROLE_OVER')
			end

    		local roleCard = Role.getDataById(giveheroConf[1].GodRid)
    		if i == 1 or i == 2 then
    			day = tonumber(giveGodAwardConf[i].AccountCreateTimePass/86400)
    			level = tonumber(giveGodAwardConf[i].RoleLevelLimit)
    			-- status = 1
				local strBuff = string.format(getLocalStringValue('E_STR_GET_GOD_ROLE_LIMIT_ONE'), day, GetTextForCfg(roleCard.Name), level, status)
				info:setText(strBuff)
    		elseif i == 3 then
    			day = tonumber(giveGodAwardConf[i].AccountCreateTimePass/86400)
    			level = tonumber(giveGodAwardConf[i].SoldierLevelLimit)
    			-- status = 0

				local strBuff = string.format(getLocalStringValue('E_STR_GET_GOD_ROLE_LIMIT_TWO'), day, GetTextForCfg(roleCard.Name), level,status)
				info:setText(strBuff)
    		end
    		receiveBtn:registerScriptTapHandler(function()
    			getAward(i,receiveBtn)
    		end)
    		if data.got_reward[i] == 1 then
    			receiveBtn:setNormalButtonGray(true)
				receiveBtn:setTouchEnable(false)
				receiveBtn:setFontSize(20)
				receiveBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			elseif data.status[i] == 1 then
    			receiveBtn:setNormalButtonGray(false)
				receiveBtn:setTouchEnable(true)
				receiveBtn:setFontSize(24)
				receiveBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
			elseif data.status[i] == 0 then
    			receiveBtn:setNormalButtonGray(true)
				receiveBtn:setTouchEnable(false)
				receiveBtn:setText('')
				local tx = UILabel:create()
				tx:setFontSize(20)
				tx:setPreferredSize(100,1)
				tx:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
				receiveBtn:addChild(tx)
				-- receiveBtn:setFontSize(32)
				-- receiveBtn:setText(getLocalStringValue('E_STR_GIFTS_DAY_BTN_DESC_7'))
			end
    	end
    end

	-- 初始化界面元素
	local function init()
	
		local root = panel:GetRawPanel()
		-- 关闭
		local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		local rewardView = tolua.cast(root:getChildByName('reward_view'),'UIImageView')
		updateAward(rewardView)
	end
	
	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/god_role_award_panel.json','god-role-award-panel-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('god_role_award_bg_img','god_role_award_img')

		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end
	
	local function getResponse()
		-- Message.sendPost('get','god','{}',getGiveGodResponse)
		Message.sendPost('get','god',json.encode(pJson),function(jsondata)

			cclog(jsondata)
			
			local response = json.decode(jsondata)
			local code = tonumber(response.code)
			if code == 0 then
				-- AccumuPayData = response.data.accumulate_pay
			 --    -- 创建主界面
				data = response.data.god
				createPanel()
			end
		end)
	end

	getResponse()
end