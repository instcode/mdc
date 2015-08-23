Protection = {}

function Protection.isActive()
	local data = UserData:getProtectData()

	if data.id > 4 then
		return false
	else
		local conf = GameData:getMapData('protectreward.dat')
		local confData = conf[tostring(data.id)]

		local serverTime = data.time
		local finishTime = tonumber(serverTime) + tonumber(confData.Interval)*60
		local currTime = UserData:getServerTime()
		return tonumber(finishTime) <= tonumber(currTime)
	end
end

function Protection.enter()
	-- UI      
	local awardBgIco
	local protectBtn          -- 保护按钮
	local awardPl
	local driveBtn            -- 驱赶按钮
	local driveTimeImg		  -- 驱赶按钮上的次数img
	local driveTimeTx
	local driveTimes   		  -- 驱赶次数
	local infoTx
	local lockIco
	local protectDay
	local driveInfo
	local rewardCDTime        -- 倒计时
	-- 其他
	local awardArr = {}		  -- award_photo UI数组
	local awardPhotoArr = {}
	local protectData         -- 保护献帝相关数据
	-- 常量
	local E_MAX_AWARD_NUM = 2
	local MAX_DAY_PROTECT = 5  -- 每天驱逐次数
	local STONE_ICO_RESOURCE = 'uires/ui_2nd/com/panel/role/stone2.png'

	-- 保护献帝5次后获得奖励panel
	local function showAwardPanel(award)
		cclog('--- open showAwardPanel panel ---')
	    local gainRes = SceneObjEx:createObj('panel/gain_res_panel.json', 'gain-res-lua')
	    local gainPanel = gainRes:getPanelObj()        --# This is a BasePanelEx object
	    gainPanel:setAdaptInfo('gain_res_bg_img','gain_res_img')

	    gainPanel:registerInitHandler(function()
	    	local root = gainPanel:GetRawPanel()
	        local knownBtn = tolua.cast(root:getChildByName('know_btn'), 'UIButton')
	        knownBtn:registerScriptTapHandler(function()
	        	CUIManager:GetInstance():HideObject(gainRes, ELF_HIDE.SMART_HIDE)
	        end)
	        GameController.addButtonSound(knownBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)

	        local resNum = tolua.cast(root:getChildByName('res_num_tx'),'UILabel')
	        local resIco = tolua.cast(root:getChildByName('res_ico'),'UIImageView')
	        local resName = tolua.cast(root:getChildByName('res_name_tx'),'UILabel')
	        local awardData = UserData:getAward(award)
	        resNum:setText(awardData.count)
	        resIco:setTexture(awardData.icon)
	        resIco:setAnchorPoint(ccp(0,0))
	        resName:setText(awardData.name)
			--LD_TOOLS::AdaptWindowForFullScreen(this, "gain_res_bg_img", "gain_res_img");
	    end)
	        
	    gainPanel:registerOnShowHandler(function()
	    	
	    end)

	    gainPanel:registerOnHideHandler(function()
	    	-- body
	    end)

	    -- Show now
	    CUIManager:GetInstance():ShowObject(gainRes, ELF_SHOW.SMART)
	end

	-- 时间到了后显示驱逐按钮或者奖励
	local function rewardCountDown(dt)
		infoTx:setVisible(false)
		rewardCDTime:setVisible(false)
		if protectData.awards == 0 then	 	-- 如果没有奖励
			driveBtn:setText(getLocalString('E_STR_DRIVE'))
		 	driveBtn:setVisible(true)
		 	driveInfo:setVisible(false)
			driveTimeImg:setVisible(true)
			local id = tonumber(protectData.id)
			driveTimes = MAX_DAY_PROTECT - id
			driveTimeTx:setText(tostring(driveTimes))
		else                                -- 如果有奖励               
			driveBtn:setText(getLocalString('E_STR_GET_AWARD'))
		 	driveBtn:setVisible(true)
		 	driveInfo:setVisible(false)
			driveTimeImg:setVisible(false)
		end	
	end

	-- 显示可获得的奖励
	local function setAward()
		local protectRewardConf = GameData:getMapData('protectreward.dat')
		-- 已保护了X天
		local bysign = tonumber(protectData.sign)
		local strBuff = string.format(getLocalString('E_STR_PROTECT_DAY'),bysign)
		protectDay:setText(strBuff)
		local id = tostring(protectData.id)
		if tonumber(id) > 4 then		-- 今天的次数已经用完了
			protectBtn:disable()
			awardPl:setVisible(true)
			lockIco:setVisible(false)
			awardBgIco:setVisible(false)
			driveBtn:setVisible(false)
			driveInfo:setVisible(false)
			infoTx:setVisible(true)
			infoTx:setText(getLocalString('E_STR_PROTECT_END'))
			infoTx:setPosition(ccp(170, 190))
			for i=1,E_MAX_AWARD_NUM do
				awardPhotoArr[i]:setVisible(false)
			end
		else
			local award1 = protectRewardConf[id].Award0
			local awardData1 = UserData:getAward(award1)

			-- 第一个奖励
			awardArr[1].awardNum:setText(awardData1.count)
			awardArr[1].awardIco:setTexture(awardData1.icon)
			awardArr[1].awardName:setText(awardData1.name)
			-- 第二个奖励开始是问号
			awardArr[2].awardNum:setVisible(false);
			awardArr[2].awardIco:setTexture(STONE_ICO_RESOURCE)
			awardArr[2].awardName:setText(getLocalString('E_STR_MYSTICAL'))

			if protectData.awards ~= 0 then
				local awardTable2 = protectData.awards[2]
				local award2 = awardTable2[1] .. '.' .. awardTable2[2] .. ':' ..awardTable2[3]
				local awardData2 = UserData:getAward(award2)
				awardArr[2].awardNum:setText(awardData2.count);
				awardArr[2].awardNum:setVisible(true);
				awardArr[2].awardIco:setTexture(awardData2.icon)
				awardArr[2].awardName:setText(awardData2.name)
			end
			-- 显示或隐藏右侧的奖励图标
			local today = tonumber(protectData.today)
			if today == 0 then
				protectBtn:active()		
				awardPl:setVisible(false)
				lockIco:setVisible(true)
			else
				protectBtn:disable()
				awardPl:setVisible(true)
				lockIco:setVisible(false)
			end
			-- 显示倒计时
			local servertime = tonumber(protectData.time)
			local finishtime = servertime + tonumber(protectRewardConf[id].Interval) * 60
			local curtime = tonumber(UserData:getServerTime())
			if not rewardCDTime then
				rewardCDTime = UICDLabel:create()
				rewardCDTime:setFontSize(24)
				rewardCDTime:setFontColor(COLOR_TYPE.LIGHT_YELLOW)
				rewardCDTime:setPosition(ccp(0,-30))
				driveInfo:addChild(rewardCDTime)
				rewardCDTime:registerTimeoutHandler(rewardCountDown)
			end
			-- 判断是否可以驱逐
			if  finishtime <= curtime then
				infoTx:setVisible(false)
				rewardCDTime:setVisible(false)
				rewardCDTime:setTime(0)
				
				if protectData.awards == 0 then	 	-- 如果没有奖励
					driveBtn:setText(getLocalString('E_STR_DRIVE'))
				 	driveBtn:setVisible(true)
				 	driveInfo:setVisible(false)
				 	driveTimeImg:setVisible(true)
				 	driveTimes = MAX_DAY_PROTECT - tonumber(id)
				 	driveTimeTx:setText(tostring(driveTimes))
				else                                -- 如果有奖励               
					driveBtn:setText(getLocalString('E_STR_GET_AWARD'))
				 	driveBtn:setVisible(true)
				 	driveInfo:setVisible(false)
				 	driveTimeImg:setVisible(false)
				end	
			else
				driveBtn:setVisible(false)
				driveInfo:setVisible(true)
				rewardCDTime:setVisible(true)
				infoTx:setPosition(ccp(170, 80))
				infoTx:setText(getLocalString('E_STR_SAFE'))
				infoTx:setVisible(true)
				rewardCDTime:setTime(finishtime - curtime)
			end
		end
	end

	-- 领取奖励回调
	local function doGetAwardsResponse(jsonData)
		local response = json.decode(jsonData)
		local code = tonumber(response.code)
		if code == 0 then
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
	        UserData.parseAwardJson(json.encode(awards))
	        local protect = data.protect
	        protectData.id = protect.id
	        protectData.time = protect.time
	        protectData.awards = 0
	        setAward()
	        UserData:setProtectData(json.encode(protectData))       -- 更新下Data数据
		end
	end

	-- 驱赶回调
	local function doDriveResponse(jsonData)
		GameController.saveOldBattleInfo()
		local response = json.decode(jsonData)
		-- print('=======================')
		-- print(jsonData)
		-- print('=======================')
		local code = tonumber(response.code)
		if code == 0 then
			local data = response.data
			local battle = data.battle
			local protect = data.protect
			local time = tonumber(protect.time)
			protectData.time = time
			if protectData.awards == 0 then
				protectData.awards = protect.awards
			end
			GameController.clearAwardView()
			GameController.playBattle(json.encode(battle), 0)
			setAward()
			UserData:setProtectData(json.encode(protectData))       -- 更新下Data数据
		end
	end

	-- 点击驱赶
	local function onClickDrive()
		local awards = protectData.awards
		if awards == 0 then
			-- 驱赶
			Message.sendPost('fight','protect','{}',doDriveResponse)
		else
			-- 领奖
			Message.sendPost('get_reward','protect','{}',doGetAwardsResponse)
		end
	end

	-- 点击保护按钮的回调
	local function doGetVipSignResponse(jsonData)
		--print(jsonData)
		local response = json.decode(jsonData)
		local code = response.code
		if code == 0 then
			local data = response.data
			local protect = data.protect
			protectData.today = protect.today
			protectData.sign = protect.sign

			local awards = data.awards
			if awards~=0 then
				local userAward = awards[1]
				local award = userAward[1] .. '.' .. userAward[2] .. ':' ..userAward[3]
				showAwardPanel(award)
				UserData.parseAwardJson(json.encode(awards))
			end
			setAward()
			UserData:setProtectData(json.encode(protectData))       -- 更新下Data数据
		end	
	end

	-- 点击保护按钮
	local function onClickProtect()
		Message.sendPost('sign','protect','{}',doGetVipSignResponse)
	end

	-- 显示界面
	local function showProtectVipPanel()
	    local protect = SceneObjEx:createObj('panel/protect_vip_panel.json', 'protect-vip-lua')
	    local panel = protect:getPanelObj()        --# This is a BasePanelEx object
	    panel:setAdaptInfo('vip_bg_img', 'vip_img')
	    -- init
	    panel:registerInitHandler(function ()
	    	local root = panel:GetRawPanel()
			local vipBgImg = tolua.cast(root:getChildByName('vip_bg_img'),'UIImageView')
			
			local vipImg = tolua.cast(vipBgImg:getChildByName('vip_img'),'UIImageView')
			local titleIco = tolua.cast(vipImg:getChildByName('title_ico'),'UIImageView')
			local closeBtn = tolua.cast(titleIco:getChildByName('close_btn'),'UIButton')
			GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
			closeBtn:registerScriptTapHandler(function ()
				CUIManager:GetInstance():HideObject(protect, ELF_HIDE.SMART_HIDE)
			end)

			protectBtn = tolua.cast(vipImg:getChildByName('protect_btn'),'UITextButton')
			GameController.addButtonSound(protectBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
			protectBtn:registerScriptTapHandler(onClickProtect)

			awardPl = tolua.cast(vipImg:getChildByName('award_pl'),'UIPanel')
			awardBgIco = tolua.cast(awardPl:getChildByName('award_bg_ico'),'UIImageView')
			driveBtn = tolua.cast(awardPl:getChildByName('drive_btn'),'UITextButton')
			GameController.addButtonSound(driveBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
			driveBtn:registerScriptTapHandler(onClickDrive)

			driveTimeImg = tolua.cast(driveBtn:getChildByName('drive_time_img'),'UIImageView')
			driveTimeTx = tolua.cast(driveTimeImg:getChildByName('drive_time_tx'),'UILabel')

			infoTx = tolua.cast(awardPl:getChildByName('info_2_tx'),'UILabel')
			lockIco = tolua.cast(vipImg:getChildByName('lock_ico'),'UIImageView')

			protectDay = tolua.cast(vipImg:getChildByName('protect_day_tx'),'UILabel')
			driveInfo = tolua.cast(awardPl:getChildByName('next_time_tx'),'UILabel')
			driveInfo:setPreferredSize(300,1)
			
			for i=1,E_MAX_AWARD_NUM do
				local strBuff = 'award_photo_' .. i .. '_ico'
				-- cclog('strBuff=%s',strBuff)
				local awardPhoto = tolua.cast(awardPl:getChildByName(strBuff),'UIImageView')
				table.insert(awardPhotoArr, awardPhoto)
				local obj = {
					awardIco = nil,
					awardName = nil,
					awardNum = nil
				}
				obj.awardIco = tolua.cast(awardPhoto:getChildByName('award_ico'),'UIImageView')
				obj.awardName = tolua.cast(awardPhoto:getChildByName('award_name_tx'),'UILabel')
				obj.awardNum = tolua.cast(awardPhoto:getChildByName('award_num_tx'),'UILabel')
				obj.awardName:setPreferredSize(150,1)
				awardArr[i] = obj
			end
			setAward()
	    end)
	        
	    -- onShow
	    panel:registerOnShowHandler(function ()
	    end)
	    -- onHide
	    panel:registerOnHideHandler(function ()
	    	UserData:setProtectData(json.encode(protectData))       -- 关闭界面的时候更新下Data数据
	    end)
	    	    
	    -- Show now
	    CUIManager:GetInstance():ShowObject(protect, ELF_SHOW.SMART)
	end

	-- 获得保护献帝的回调
	local function doGetProtectResponse(jsonData)
		local response = json.decode(jsonData)
		protectData = UserData:getProtectData()         -- 获取签到相关的数据
		local code = response.code
		if tonumber(code) == 0 then
			protectData.sign = response.data.protect.sign
			protectData.awards = response.data.protect.awards
			protectData.time = response.data.protect.time
			protectData.day = response.data.protect.day
			protectData.today = response.data.protect.today
			protectData.id = response.data.protect.id
			showProtectVipPanel()
		end
	end

	-- 获取保护献帝的数据
	local function doGetProtect()
		Message.sendPost('get', 'protect', '{}', doGetProtectResponse)
	end

	-- -- 从这里开始执行Protection.enter()
	local level = PlayerCoreData.getPlayerLevel()
	local activitiesConf = GameData:getMapData('activities.dat')
	local openLevel = activitiesConf['protection'].OpenLevel
	if  tonumber(level) < tonumber(openLevel) then    	-- 如果等级不够
		local msg = string.format(getLocalString('E_STR_TRAIN_LIMIT'),tonumber(openLevel))
        GameController.showMessageBox(msg,MESSAGE_BOX_TYPE.OK)
	else												-- 如果等级足够	
		doGetProtect()
	end
end