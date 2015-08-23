LegionWarEntrancePanel = LegionView:new{
	jsonFile = 'panel/legion_war_entrance_panel.json',
	panelName = 'legion-war-entrannce',

	backBtn = nil,
	rewardBtn = nil,
	reportBtn = nil,
	helpBtn = nil,
	registBtn = nil,
	legionNameTx = nil,
	occupyDayTx = nil,
	plaintIco = nil,
	registerTx = nil,
	infoTxOne = nil,
	infoTxTwo = nil,
	contentTx = nil,
	timeCDTx = nil,
	rolePlArr = nil,
	wins = nil,
	progress = nil,
	register = nil,
	war = nil,
	isaward = nil
}

local function shake()
    local mov1 = CCRotateBy:create(0.1, 10)
    local mov2 = CCRotateBy:create(0.1, -20)
    local actArr = CCArray:create()
    for i = 1, 3 do
        actArr:addObject(mov1)
        actArr:addObject(mov1:reverse())
        actArr:addObject(mov2)
        actArr:addObject(mov2:reverse())
    end
    actArr:addObject(CCDelayTime:create(0.2))

    return CCRepeatForever:create(CCSequence:create(actArr))
end

function LegionWarEntrancePanel:showWithData( data )
	self.wins = data.wins or {}
	self.progress = data.progress
	self.register = data.register or false
	self.war = data.war or false
	self.isaward = data.reward_battle or false

	LegionController.show(self , ELF_SHOW.SLIDE_IN)
end

-- Do fucking adapting...
function LegionWarEntrancePanel:fuckingAdapting( root )
	local background = tolua.cast(root:getChildByName('bg_ico'), 'UIImageView')
	self:adaptChildToScreen(background, LEGION_VIEW_POSITION.MIDDLE_MIDDLE)

	local dayPanel = tolua.cast(root:getChildByName('day_pl'), 'UIPanel')
	self:adaptChildToScreen(dayPanel, LEGION_VIEW_POSITION.TOP_LEFT)

	local infoPanel = tolua.cast(root:getChildByName('info_pl'), 'UIPanel')
	self:adaptChildToScreen(infoPanel, LEGION_VIEW_POSITION.BOTTOM_MIDDLE)

	local btnPanel = tolua.cast(root:getChildByName('btn_pl'), 'UIPanel')
	self:adaptChildToScreen(btnPanel, LEGION_VIEW_POSITION.TOP_RIGHT)

	self:adaptChildToScreen(self.registBtn, LEGION_VIEW_POSITION.BOTTOM_RIGHT)
	self:adaptChildToScreen(self.backBtn, LEGION_VIEW_POSITION.BOTTOM_LEFT)
end


function LegionWarEntrancePanel:init()
	local panel = self.sceneObject:getPanelObj()

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		-- 返回
		self.backBtn = self:registerButtonWithHandler(root, 'back_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionWarController.close(self, ELF_HIDE.SLIDE_OUT)
		end)
		-- 报名
		self.registBtn = self:registerButtonWithHandler(root, 'registration_btn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
			self:onclickRegister()
		end)
		-- 奖励
		self.rewardBtn = self:registerButtonWithHandler(root, 'reward_btn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
			LegionWarController.sendLegionWarGetRewardrequest( function ( response )
				if response.code == 0 then
					self:getReward( response.data )
				end
			end)
		end)
		-- 帮助
		self.helpBtn = self:registerButtonWithHandler(root, 'help_btn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
			LegionWarController.show(LegionWarHelpPanel, ELF_SHOW.ZOOM_IN)
		end)
		-- 赛况
		self.reportBtn = self:registerButtonWithHandler(root, 'results_btn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
			LegionWarController.sendLegionWarInfoRequest( function ( response )
				if response.code == 0 then
					response.data.progress , response.data.waring = self:getProgress()
					response.data.inwar = self.war
					LegionWarInfoPanel:showWithData( response.data )
				end
			end)
		end)

		self.rolePlArr = {}
		for i = 1 , 3 do
			local rItem = tolua.cast(root:getChildByName('role_' .. i .. '_pl') , 'UIPanel')
			table.insert(self.rolePlArr , rItem)
		end

		-- 国号
		self.legionNameTx = tolua.cast(root:getChildByName('legionname_tx') , 'UILabel')
		-- 占领天数
		self.occupyDayTx = tolua.cast(root:getChildByName('day_tx') , 'UILabel')
		-- 奖励叹号
		self.plaintIco = tolua.cast(root:getChildByName('plaint_ico') , 'UIImageView')
		-- 报名状态
		self.registerTx = tolua.cast(root:getChildByName('register_tx') , 'UILabel')
		-- 提示信息一
		self.infoTxOne = tolua.cast(root:getChildByName('info_1_tx') , 'UILabel')
		-- 提示信息二
		self.infoTxTwo = tolua.cast(root:getChildByName('info_2_tx') , 'UILabel')
		-- 赛事预告
		self.contentTx = tolua.cast(root:getChildByName('content_tx') , 'UILabel')

		local timeTx = tolua.cast(root:getChildByName('time_tx') , 'UILabel')
		timeTx:setText('')
		-- 倒计时label
		self.timeCDTx = UICDLabel:create()
		self.timeCDTx:setAnchorPoint(ccp(0,0.5))
		self.timeCDTx:setFontSize(26)
		self.timeCDTx:setPosition(ccp(20,0))
		self.timeCDTx:setFontColor(COLOR_TYPE.LIGHT_YELLOW)
		timeTx:addChild(self.timeCDTx)
		self.timeCDTx:setVisible(false)

		self:fuckingAdapting(root)

		self:updateAll()
	end)
end

function LegionWarEntrancePanel:updateAll()
	self.legionNameTx:setText(self.wins.legion or LegionConfig:getLegionLocalText('LEGION_NO_PEOPLE_OCCUPY_DESC'))

	if self.wins.time and self.wins.time > 0 then
		local days = math.ceil((UserData:getServerTime() - self.wins.time) / 86400)
		self.occupyDayTx:setText( string.format(LegionConfig:getLegionLocalText('LEGION_DAY_DESC') , tostring(days)) )
	else
		self.occupyDayTx:setText( string.format(LegionConfig:getLegionLocalText('LEGION_DAY_DESC') , '0') )
	end

	self:updateNoticePanel()
	self:updateRolePanel()
	self:updateBtn()
end

function LegionWarEntrancePanel:updateTime()
	-- self.timeCDTx:setVisible(false)

	self.infoTxOne:setText(LegionConfig:getLegionLocalText('LEGION_WAR_BATTLEFIELD_INIT_DESC'))
	self.infoTxTwo:setText(LegionConfig:getLegionLocalText('LEGION_COUNT_DOWN_DESC'))
	self.timeCDTx:registerTimeoutHandler(function ()
		self:getRequestAndUpdate()
	end)
	self.timeCDTx:setTime( 10 )
end

function LegionWarEntrancePanel:getRequestAndUpdate()
	LegionWarController.sendLegionWarGetRequest(function ( response ) 
		if response.code == 0 then
			local data = response.data
			self.wins = data.wins or {}
			self.progress = data.progress
			self.register = data.register or false
			self.war = data.war or false
			self.isaward = data.reward_battle or false

			self:updateAll()
		end
	end)
end

function LegionWarEntrancePanel:resetCDLabel( progress )
	if tonumber(progress) ~= nil then
		local oneWeekSecond = 24 * 7 * 3600
		local registerWeek = tonumber(GameData:getMapData('legionwarschedule.dat')['register']['StartWeek'])
		local bt = Time.beginningOfWeek()
		if Time.currentWeek() < registerWeek then
			bt = bt - oneWeekSecond
		elseif Time.currentWeek() == registerWeek then
			local registerStartTime = tonumber(GameData:getMapData('legionwarschedule.dat')['register']['StartTime'])
			local nowTime = tonumber(os.date('%H' , st))
			if nowTime < registerStartTime then
				bt = bt - oneWeekSecond
			end
		end

		local dt = LegionWarConfig:getWarScheduleByProgress( progress )
		local c_st = bt + ((tonumber(dt.StartWeek)-1) * 24 + tonumber(dt.StartTime)) * 3600
		if tonumber(dt.StartWeek) < registerWeek then
			c_st = c_st + oneWeekSecond
		end

		local left_time = c_st - UserData:getServerTime()
		if left_time > 0 then
			self.timeCDTx:registerTimeoutHandler(function ()
				self:updateTime()
			end)
			self.timeCDTx:setTime( left_time )
			self.timeCDTx:setVisible(true)
		else
			self.timeCDTx:setVisible(false)
		end
	else
		print('resetCDLabel failed ... ')
	end
end

function LegionWarEntrancePanel:updateNoticePanel()
	-- reset all Label
	self.registerTx:setText('')
	self.contentTx:setText('')
	self.infoTxOne:setText('')
	self.infoTxTwo:setText('')
	-- update
	if self.progress == 'open' then
		-- 修改报名军团不足人数提示
		self.infoTxOne:setText( string.format(LegionConfig:getLegionLocalText('LEGION_REGISTER_NUM_NO_ENOUGH') , 2) )
		self.infoTxTwo:setText( LegionConfig:getLegionLocalText('LEGION_WAR_NO_OPEN_DESC') )
	elseif self.progress == 'register' then
		if self:isFirstTurnDay() then
			self.infoTxOne:setText(LegionConfig:getLegionLocalText('LEGION_BEFORE_ONE_TURN_DESC'))
			self.infoTxTwo:setText(LegionConfig:getLegionLocalText('LEGION_COUNT_DOWN_DESC'))
			self:resetCDLabel( 9 )
		else
			self.infoTxOne:setText(LegionConfig:getLegionLocalText('LEGION_WAR_RUNING_TIME'))
			local turn_1, turn_time = LegionWarEntrancePanel:getTimeStr(9)
			local turn_2 = LegionWarEntrancePanel:getTimeStr(3)
			local turn_3 = LegionWarEntrancePanel:getTimeStr(1)
			-- as : 周五，周六，周日 20:00 -- 21:00
			self.contentTx:setText(turn_1 .. ',' .. turn_2 .. ',' .. turn_3 .. ' ' .. turn_time)
		end
		self.registerTx:setText( LegionConfig:getLegionLocalText( self.register == true and 'LEGION_REGISTER_DESC' or 'LEGION_NO_REGISTER_DESC') )
	elseif self.progress == 'replay' then
		local progress , inwar = self:getProgress()
		local bt = Time.beginningOfWeek()
		local st = UserData:getServerTime()
		if progress == 'register' or progress == 'after_register' then
			self.infoTxOne:setText(LegionConfig:getLegionLocalText('LEGION_BEFORE_ONE_TURN_DESC'))
			self.infoTxTwo:setText(LegionConfig:getLegionLocalText('LEGION_COUNT_DOWN_DESC'))
			self:resetCDLabel( 9 )
		elseif progress == '9' then
			self.infoTxOne:setText(LegionConfig:getLegionLocalText('LEGION_BEFORE_TWO_TURN_DESC'))
			self.infoTxTwo:setText(LegionConfig:getLegionLocalText('LEGION_COUNT_DOWN_DESC'))
			self:resetCDLabel( 3 )
		elseif progress == '3' then
			self.infoTxOne:setText(LegionConfig:getLegionLocalText('LEGION_BEFORE_THREE_TURN_DESC'))
			self.infoTxTwo:setText(LegionConfig:getLegionLocalText('LEGION_COUNT_DOWN_DESC'))
			self:resetCDLabel( 1 )
		elseif progress == '1' then
			self.infoTxOne:setText(LegionConfig:getLegionLocalText('LEGION_WAR_OVER_DESC'))
		end
		if self.register then
			if tonumber(progress) then
				self.registerTx:setText( self.war == true and '' or LegionConfig:getLegionLocalText('LEGION_WEED_OUT_DESC') )
			end
		else
			self.registerTx:setText( LegionConfig:getLegionLocalText( 'LEGION_NO_REGISTER_DESC') )
		end
	elseif tonumber(self.progress) ~= nil then
		if self.progress == '9' then
			self.infoTxOne:setText(LegionConfig:getLegionLocalText('LEGION_ONE_TURN_RUNING_DESC'))
		elseif self.progress == '3' then
			self.infoTxOne:setText(LegionConfig:getLegionLocalText('LEGION_TWO_TURN_RUNING_DESC'))
		elseif self.progress == '1' then
			self.infoTxOne:setText(LegionConfig:getLegionLocalText('LEGION_THREE_TURN_RUNING_DESC'))
		end
		if self.register then
			self.registerTx:setText( self.war == true and '' or LegionConfig:getLegionLocalText('LEGION_WEED_OUT_DESC') )
		else
			self.registerTx:setText( LegionConfig:getLegionLocalText('LEGION_NO_REGISTER_DESC') )
		end
	else
		print('no deal with progress ..... ')
	end
end

function LegionWarEntrancePanel:updateRolePanel()
	local JOB = {'emperor' , 'general' , 'premier'}

	for i = 1 , #self.rolePlArr do
		local rItem = self.rolePlArr[i]
		local nameTx = tolua.cast(rItem:getChildByName('name_tx') , 'UILabel')
		local roleIco = tolua.cast(rItem:getChildByName('big_ico') , 'UIImageView')
		local titleIco = tolua.cast(rItem:getChildByName('crown_ico') , 'UIImageView')

		local jname
		if self.wins[JOB[i]] and self.wins[JOB[i]] ~= 0 then
			jname = self.wins[JOB[i] .. '_name']
			roleIco:setNormal()
		else
			jname = LegionConfig:getLegionLocalText('LEGION_COMING_SOON_DESC')
			roleIco:setGray()
		end
		nameTx:setText(jname)
		roleIco:registerScriptTapHandler(function ()
			LegionWarTipsPanel:showWithData( { name = jname , job = JOB[i] } )
		end)
		titleIco:registerScriptTapHandler(function ()
			LegionWarTipsPanel:showWithData( { name = jname , job = JOB[i] } )
		end)
	end
end

function LegionWarEntrancePanel:updateBtn()
	if self.progress == 'register' then
		if self.register == false then
			self.registBtn:setVisible( true )
		else
			self.registBtn:setVisible(false)
		end
	elseif self.progress == '9' or self.progress == '3' or self.progress == '1' then
		local ico = tolua.cast(self.registBtn:getChildByName('registration_ico') , 'UIImageView')
		ico:setTexture('uires/ui_2nd/com/panel/mainscene/zhandou.png')
		self.registBtn:setVisible(self.war == true)
	else
		self.registBtn:setVisible(false)
	end

	if self.isaward then
		self.rewardBtn:setVisible(true)
		self.plaintIco:stopAllActions()
		self.plaintIco:runAction( shake() )
	else
		self.rewardBtn:setVisible(false)
		self.plaintIco:stopAllActions()
	end
end

function LegionWarEntrancePanel:onclickRegister()
	if self.progress == 'register' then
		if MyLegion.position == 'member' then
			GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_REGISTER_NOTICE_DESC') , COLOR_TYPE.RED)
			return
		end 

		if self:getProgress() ~= 'register' then
			GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_OUT_REGISTER_TIME') , COLOR_TYPE.RED)
			return
		end

		LegionWarController.sendLegionWarRegisterrequest(function (response)
			if response.code == 0 then
				GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_REGISTER_DESC') , COLOR_TYPE.GREEN)
				self.register = true
				self:updateAll()
			end
		end)
	elseif self.progress == '9' or self.progress == '3' or self.progress == '1' then
		LegionWarController.sendLegionWarGetBattleFieldRequest(function ( response )
			if response.code == 0 then
				LegionWarController.show(LegionWarBattlePanel, ELF_SHOW.SLIDE_IN)
			end
		end)
	end
end

function LegionWarEntrancePanel:getReward( data )
	if data.reward then
		UserData.parseAwardJson( json.encode(data.reward) )

		local tab = {}
		for _, v in pairs (data.reward) do
			local str = UserData.makeAwardStr( v )
			table.insert(tab , str)
		end
		-- 个人贡献
		if data.honor and tonumber(data.honor) > 0 then
			table.insert(tab , 'user.legionHonor:' .. data.honor )
			-- 更新军团主界面数据
			local origin_honor = MyLegion:getMyData().honor
			MyLegion:getMyData().honor = origin_honor + tonumber(data.honor)
		end

		local notice 
		local reward_battle = tonumber(self.isaward)
		if reward_battle then
			if reward_battle == 9 then
				notice = LegionConfig:getLegionLocalText('LEGION_GET_REWARD_ONE_TURN_DESC')
			elseif reward_battle == 3 then
				notice = LegionConfig:getLegionLocalText('LEGION_GET_REWARD_TWO_TURN_DESC')
			elseif reward_battle == 1 then
				notice = LegionConfig:getLegionLocalText('LEGION_GET_REWARD_THREE_TURN_DESC')
			end
			genShowTotalAwardsPanel(tab , notice or '')
		end

		self.isaward = false
		self:updateBtn()
	end
end

-- 是否是第一轮当天
function LegionWarEntrancePanel:isFirstTurnDay()
	local firstTurnWeek = LegionWarConfig:getWarScheduleByProgress(9)['StartWeek']
	return tonumber(Time.currentWeek()) == tonumber(firstTurnWeek)
end

-- 获取进行时间字符串 return : 周日 , 15:00 -- 16:00
function LegionWarEntrancePanel:getTimeStr( progress )
	local data = LegionWarConfig:getWarScheduleByProgress( progress )
	if data == nil then
		return nil
	end
	local startStr
	local endStr
	local sHour = math.floor(tonumber(data.StartTime))     --- '15.5' to 15
	local sMin = (tonumber(data.StartTime) - sHour) * 60

	startStr = string.format('%02d:%02d' , sHour , sMin)

	local endTime = tonumber(data.StartTime) + tonumber(data.KeepHour)
	local eHour = math.floor(endTime)
	local eMin =  (endTime - eHour) * 60

	endStr = string.format('%02d:%02d' , eHour , eMin)

	local WEEKSTR = { 
		LegionConfig:getLegionLocalText('MONDAY_DESC'), 
		LegionConfig:getLegionLocalText('TUSEDAY_DESC'), 
		LegionConfig:getLegionLocalText('WEDNESDAY_DESC'), 
		LegionConfig:getLegionLocalText('THURSDAY_DESC'), 
		LegionConfig:getLegionLocalText('FRIDAY_DESC'),
		LegionConfig:getLegionLocalText('SATURDAY_DESC'), 
		LegionConfig:getLegionLocalText('SUNDAY_DESC')}

	local weekStr = WEEKSTR[tonumber(data.StartWeek)]

	local str = startStr .. ' -- ' .. endStr

	return weekStr , str
end

-- return : 当前进度 , 是否战斗中
function LegionWarEntrancePanel:getProgress()
	local conf = GameData:getArrayData('legionwarschedule.dat')
	local bt = Time.beginningOfWeek()
	local st = UserData:getServerTime()
	local oneWeekSecond = 24 * 7 * 3600
	local registerWeek = tonumber(GameData:getMapData('legionwarschedule.dat')['register']['StartWeek'])
	if Time.currentWeek() < registerWeek then
		bt = bt - oneWeekSecond
	elseif Time.currentWeek() == registerWeek then
		local registerStartTime = tonumber(GameData:getMapData('legionwarschedule.dat')['register']['StartTime'])
		local nowTime = tonumber(os.date('%H' , st))
		if nowTime < registerStartTime then
			bt = bt - oneWeekSecond
		end
	end

	for i = 1 , #conf do
		local cv = conf[i]
		local c_st = bt + ((tonumber(cv.StartWeek)-1) * 24 + tonumber(cv.StartTime)) * 3600
		if tonumber(cv.StartWeek) < registerWeek then
			c_st = c_st + oneWeekSecond
		end
		local c_et = c_st + tonumber(cv.KeepHour) * 3600

		local n = i+1
		if n > #conf then 
			n = i 
		end

		local nv = conf[n]

		local n_st = bt + ((tonumber(nv.StartWeek)-1) * 24 + tonumber(nv.StartTime)) * 3600
		if tonumber(nv.StartWeek) < registerWeek then
			n_st = n_st + oneWeekSecond
		end
		local n_et = n_st + tonumber(nv.KeepHour) * 3600

		-- if st < c_st then		-- 本轮开始前
			-- if cv.Progress == 'register' then
			-- 	return 'before_register' , false
			-- else
			-- 	return nil , false
			-- end
		if st >= c_st and st <= c_et then		-- 本轮进行中
			if cv.Progress == 'register' then
				return 'register' , false
			else
				return cv.Progress , true
			end
		elseif st > c_et then	--本轮结束
			if n == i then
				return cv.Progress , false		--最后一轮结束
			else
				if st < n_st then	--下轮开始前
					if cv.Progress == 'register' then
						return 'after_register' , false
					else
						return cv.Progress , false
					end
				end
			end
		end
	end

	print('~~~~~~~~~~~~~ GETPROGRESS ERROE ~~~~~~~~~~~~~~')
	return nil , false
end

function LegionWarEntrancePanel:release()
	LegionView.release(self)

	self.backBtn = nil
	self.rewardBtn = nil
	self.reportBtn = nil
	self.helpBtn = nil
	self.registBtn = nil
	self.legionNameTx = nil
	self.occupyDayTx = nil
	self.plaintIco = nil
	self.registerTx = nil
	self.infoTxOne = nil
	self.infoTxTwo = nil
	self.contentTx = nil
	self.rolePlArr = nil
	self.wins = nil
	self.progress = nil
	self.register = nil
	self.timeCDTx = nil
	self.war = nil
end