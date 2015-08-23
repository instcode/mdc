PvpKnockoutPanel = PvpView:new{
	jsonFile = 'panel/pvp_knockout_panel.json',
	panelName = 'pvp-knockout-in-lua',
	data,
	isInRank = false,
	page = 1,
	isMain = false,
	reviewBtn,
	timeCDTx,
	timeInfoTx,
	thirtytwoStrong,
	fourStrong,
	myIndex,
	readyToFightBtn,
	fightIndex = -1,
	nameLabels = {},
	fangdajingIcos = {},
	supportPlayersBtn = {},
	nameLabels1 = {},
	fangdajingIcos1 = {},
	supportPlayersBtn1 = {},
	blueLines32 = {},
	blueLines4 = {},
	myReplays = {},
	groupBtns = {}
}

MAXPLAYER = {
	THIRTYTWO = 32,
	EIGHT = 8,
	FOR = 4,
	TWO = 2,
	ONE = 1
}

function updateEnemyInfo(view)
	PvpKnockoutPanel:updateEnemyInfo(view)
end

function PvpKnockoutPanel:support(index)
	local top = 0
	local uid = -1
	if self.data.progress == PROGRESS.SUPPORT4 then
		top = MAXPLAYER.FOR
		uid = self.data.top32[index + (self.page-1) * 8].uid
	elseif self.data.progress == PROGRESS.SUPPORT1 then
		top = MAXPLAYER.ONE
		uid = self.data.top32[self.data.top4[index] + 1].uid
	else
		GameController.showMessageBox(getLocalStringValue('E_STR_PVP_WAR_DESC2'), MESSAGE_BOX_TYPE.OK)
		return
	end
	GameController.showMessageBox(getLocalStringValue('E_STR_PVP_KNOCKOUT_DESC1'), MESSAGE_BOX_TYPE.OK_CANCEL,function ()
		PvpController:support(function()
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_SUPPORT_SUCCESS'), COLOR_TYPE.GREEN)
			self:updateZan(self.data.progress)
		end,uid,top)
	end)
end

function PvpKnockoutPanel:getMaxPlayer(progress)
	if progress == PROGRESS.SUPPORT4 or progress == PROGRESS.TO16
	or progress == PROGRESS.TO8 
	or progress == PROGRESS.TO4 then
		return MAXPLAYER.THIRTYTWO
	elseif progress == PROGRESS.SUPPORT1
		or progress == PROGRESS.TO2 
		or progress == PROGRESS.TO1 
		or progress == 'over' then
		return MAXPLAYER.FOR
	else
		return 0
	end
end

function PvpKnockoutPanel:getGroup(stype)
	if stype == 1 then
		return 'A'
	elseif stype == 2 then
		return 'B'
	elseif stype == 3 then
		return 'C'
	elseif stype == 4 then
		return 'D'
	elseif stype == 5 then
		return getLocalStringValue('E_STR_PVP_WAR_DESC20')
	end
end
-- (self.myPositionTop32 + self.myPositionTop32 % 2)/2
function PvpKnockoutPanel:getEnemyInfo()
	myUid = PlayerCoreData.getUID()
	_,index = getPlayer(myUid,self.data)
	_,index1 = getPlayerInTop4(myUid,self.data)
	if self.data.progress == PROGRESS.SUPPORT4 then
		return getEnemyIndex(index)
	elseif self.data.progress == PROGRESS.TO16 then
		-- return self.data.top32[getEnemyIndex(index)]
		return getEnemyIndex(index)
	elseif self.data.progress == PROGRESS.TO8 then
		return self.data.records[getEnemyIndex((index + index%2)/2)] + 1
	elseif self.data.progress == PROGRESS.TO4 then
		temIndex = (index - 1 - (index - 1)%4)/4 + 1
		temIndex = 16 + temIndex
		return self.data.records[getEnemyIndex(temIndex)] + 1
	elseif self.data.progress == PROGRESS.SUPPORT1 then
		return self.data.top4[getEnemyIndex(index1)] + 1
	elseif self.data.progress == PROGRESS.TO2 then
		return self.data.top4[getEnemyIndex(index1)] + 1
	elseif self.data.progress == PROGRESS.TO1 then
		return self.data.records[getEnemyIndex(28 + (index1 + index1%2)/2)] + 1
	end
end

function PvpKnockoutPanel:updateEnemyInfo(view)
	local player = PvpController.lastEnemy
	nameTx = tolua.cast(view:getChildByName('name_tx') , 'UILabel')
	zhanNumTx = tolua.cast(view:getChildByName('zhan_num_tx') , 'UILabel')
	serverNumTx = tolua.cast(view:getChildByName('server_num_tx') , 'UILabel')
	honourTx = tolua.cast(view:getChildByName('honour_tx') , 'UILabel')
	groupNameTx = tolua.cast(view:getChildByName('group_name_tx') , 'UILabel')
	headpic = tolua.cast(view:getChildByName('player_head_ico') , 'UIImageView')
	if PvpController.lookType == 1 then
		groupNameTx:setVisible(false)
	else
		str = self:getGroup(PvpController.lookType)
		groupNameTx:setText(str)
		groupNameTx:setVisible(true)
	end

	nameTx:setText(player.name)
	zhanNumTx:setText(player.force)
	serverNumTx:setText(player.serverid)

	if tonumber(player.uid) < 100000 then
		tab = getMosterInfo(player.headpic)
		headpic:setTexture(tab.iconRes)
	else
		pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject(player.headpic, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
		pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
		iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON)
		headpic:setTexture(iconRes)
	end



	for i = 1,9 do
		str = 'place_'..i..'_img'
		place = tolua.cast(view:getChildByName(str) , 'UIImageView')
		if player.team and player.team[tostring(i - 1)] and player.team[tostring(i - 1)] > 1 then
			-- self.infoTx:setVisible(false)
			local roleInfo = nil
			if tonumber(player.team[tostring(i - 1)]) > 1000 then
				roleInfo = getMosterConf(tonumber(player.team[tostring(i - 1)]))
			else
				roleInfo = PvpData:getRoleInfo(player.team[tostring(i - 1)])
			end
			if tonumber(roleInfo.Soldier) < 0 or tonumber(roleInfo.Soldier) > 5 then
				place:setVisible(false)
			else
				str = string.format('%s%s','uires/ui_2nd/com/panel/pass/',SoldierIconNames[tonumber(roleInfo.Soldier)])
				place:setVisible(true)
				place:setTexture(str)
			end
		else
			place:setVisible(false)
		end
	end

	view:setVisible(true)
end

function PvpKnockoutPanel:updateHeadPic(player,stype,clean)
	self.head = tolua.cast(self.playerFrame:getChildByName('head_img') , 'UIImageView')
	if clean == 0 then
		self.head:setTexture('uires/ui_2nd/image/hero/dongzhuo_icon.png')
		self.nameTx:setText(getLocalStringValue('E_STR_WELFARE_NORANK1'))
	else
		pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject(player.headpic, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
		pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
		iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON)
		self.head:setTexture(iconRes)
		self.nameTx:setText(player.name)
	end
end

function PvpKnockoutPanel:updateBlueLines(progress)
	maxPlayer = self:getMaxPlayer(progress)
	self:updateHeadPic(_,_,0)
	for i,v in ipairs(self.blueLines32) do
		v:setVisible(false)
	end
	for i,v in ipairs(self.blueLines4) do
		v:setVisible(false)
	end
	local index = -1
	if maxPlayer == MAXPLAYER.THIRTYTWO then
		for i,v in ipairs(self.data.records) do
			if i > (self.page-1) * 4 and i <= self.page * 4 then
				tem = self.data.records[i]
				if tem ~= -1 then
					index = tem + 1 - (self.page - 1) * 8
					self.blueLines32[index]:setVisible(true)
				end
			elseif i > 16 + (self.page - 1) * 2 and i <= 16 + self.page * 2 then
				tem = self.data.records[i]
				if tem ~= -1 then
					index = tem + 1 - (self.page - 1) * 8
					index = (index + 1 - (index+ 1) %2)/2 + 8
					self.blueLines32[index]:setVisible(true)
				end
			elseif i > 24 + self.page - 1 and i <= 24 + self.page then
				tem = self.data.records[i]
				if tem ~= -1 then
					index = tem + 1 - (self.page - 1) * 8
					if index <= 4 then
						index = 13
					else
						index = 14
					end
					self.blueLines32[index]:setVisible(true)
					self.blueLines32[#self.blueLines32]:setVisible(true)
					self:updateHeadPic(self.data.top32[self.data.records[i] + 1],1)
				end
			end
		end
	elseif maxPlayer == MAXPLAYER.FOR then
		for i,v in ipairs(self.data.records) do
			if i == 29 or i == 30 then
				for j,v in ipairs(self.data.top4) do
					if v == self.data.records[i] then
						self.blueLines4[j]:setVisible(true)
					end
				end
			elseif i == 31 then
				for j,v in ipairs(self.data.top4) do
					if v == self.data.records[i] then
						if j < 3 then
							self.blueLines4[5]:setVisible(true)
						else
							self.blueLines4[6]:setVisible(true)
						end
						self.blueLines4[#self.blueLines4]:setVisible(true)
						self:updateHeadPic(self.data.top32[self.data.records[i] + 1],2)
					end
				end
			end
		end
	end
end

function PvpKnockoutPanel:updatePlayerName(progress)
	maxPlayer = self:getMaxPlayer(progress)
	local myUid = PlayerCoreData.getUID()
	if maxPlayer == MAXPLAYER.THIRTYTWO then
		for i=1,MAXPLAYER.EIGHT do
			self.nameLabels[i]:setColor(ccc3(255, 255, 255))
			self.nameLabels[i]:setText(self.data.top32[i + (self.page - 1 )* 8].name)
			if tonumber(self.data.top32[i + (self.page - 1 )* 8].uid) ==  myUid then
				self.nameLabels[i]:setColor(ccc3(50, 240, 50))
			end
			self.nameLabels[i]:setVisible(true)
		end
		self.fourStrong:setVisible(false)
		self.thirtytwoStrong:setVisible(true)
		self.reviewBtn:setVisible(false)
	elseif  maxPlayer == MAXPLAYER.FOR then
		for i=1,MAXPLAYER.FOR do
			self.nameLabels1[i]:setColor(ccc3(255,255,255))
			self.nameLabels1[i]:setText(self.data.top32[self.data.top4[i] + 1].name)
			if tonumber(self.data.top32[self.data.top4[i] + 1].uid) ==  myUid then
				self.nameLabels1[i]:setColor(ccc3(50, 240, 50))
			end
			self.nameLabels1[i]:setVisible(true)
		end
		self.page = 5
		self.thirtytwoStrong:setVisible(false)
		self.fourStrong:setVisible(true)
		self.finalsBtn:setVisible(false)
		self.reviewBtn:setVisible(true)
	end
end

function PvpKnockoutPanel:updateZan(progress)
	maxPlayer = self:getMaxPlayer(progress)
	for k,n in ipairs(self.supportPlayersBtn) do
		n:setVisible(false)
	end
	for k,n in ipairs(self.supportPlayersBtn1) do
		n:setVisible(false)
	end
	if maxPlayer == MAXPLAYER.THIRTYTWO then
		if #PvpController.supports > 0 then
			for i,v in pairs(PvpController.supports) do
				for j=1,8 do
					if v == tostring(self.data.top32[j + (self.page - 1 )* 8].uid) then
						self.supportPlayersBtn[j]:setVisible(true)
						self.supportPlayersBtn[j]:setTouchEnable(false)
						return
					end
				end
			end
		end
		for i,v in ipairs(self.supportPlayersBtn) do
			if self.data.progress ==  PROGRESS.SUPPORT4 then
				v:setVisible(true)
				v:setTouchEnable(true)
			end
		end
	elseif maxPlayer == MAXPLAYER.FOR then
		if #PvpController.supports1 > 0 then
			for i,v in pairs(PvpController.supports1) do
				for j=1,4 do
					if v == tostring(self.data.top32[self.data.top4[j] + 1].uid) then
						self.supportPlayersBtn1[j]:setVisible(true)
						self.supportPlayersBtn1[j]:setTouchEnable(false)
						return
					end
				end
			end
		end
		for i,v in ipairs(self.supportPlayersBtn1) do
			if self.data.progress ==  PROGRESS.SUPPORT1 then
				v:setVisible(true)
				v:setTouchEnable(true)
			end
		end
	end
end

function PvpKnockoutPanel:getNextProgress(progress)
	if progress == PROGRESS.TO16 then
		return PROGRESS.TO8
	elseif progress == PROGRESS.TO8 then
		return PROGRESS.TO4
	elseif progress == PROGRESS.TO4 then
		return PROGRESS.TO2
	elseif progress == PROGRESS.TO2 then
		return PROGRESS.TO1
	end
end
function PvpKnockoutPanel:getNowProgress(i)
	if self.data.progress == PROGRESS.SUPPORT4 then
		local registerWeek = tonumber(GameData:getMapData('serverwarschedule.dat')[PROGRESS.TO16]['EndWeek'])
		local bt = Time.beginningOfWeek()

		local dt = PvpData:getScheduleByProgress(PROGRESS.TO16)
		local startTime = bt + (tonumber(dt.StartWeek) - 1) * 24 * 3600 + tonumber(dt.StartHour) * 3600
		nowTime = UserData:getServerTime()
		local time = startTime - nowTime
		if time <= 0 then
			time = 1
		end
		return _,startTime - nowTime
	end
	if self.data.progress == PROGRESS.SUPPORT1 then
		local registerWeek = tonumber(GameData:getMapData('serverwarschedule.dat')[PROGRESS.TO2]['EndWeek'])
		local bt = Time.beginningOfWeek()

		local dt = PvpData:getScheduleByProgress(PROGRESS.TO2)
		local startTime = bt + (tonumber(dt.StartWeek) - 1) * 24 * 3600 + tonumber(dt.StartHour) * 3600
		nowTime = UserData:getServerTime()
		local time = startTime - nowTime
		if time <= 0 then
			time = 1
		end
		return _,startTime - nowTime
	end
	if self.data.progress ~= PROGRESS.RANK and self.data.progress ~= PROGRESS.OVER then
		local registerWeek = tonumber(GameData:getMapData('serverwarschedule.dat')[tostring(self.data.progress)]['EndWeek'])
		local bt = Time.beginningOfWeek()

		local dt = PvpData:getScheduleByProgress(self.data.progress)
		local startTime = bt + (tonumber(dt.StartWeek) - 1) * 24 * 3600 + tonumber(dt.StartHour) * 3600
		local endTime = bt + (tonumber(dt.EndWeek) - 1) * 24 * 3600 + tonumber(dt.StartHour) * 3600 + tonumber(dt.Interval) * 5 *60
		nowTime = UserData:getServerTime()
		if nowTime > startTime and nowTime < endTime then
			local diffTime = endTime - nowTime
			per = (diffTime - diffTime % (tonumber(dt.Interval) * 60))/ (tonumber(dt.Interval) * 60)
			local time = (diffTime - 1) % (tonumber(dt.Interval) * 60)
			if time <= 0 then
				time = 1
			end
			if per == 0 then
				time = time + 5*60
			end
			return ( i or 0 ) * (5 - per) / 5, time
 		elseif nowTime > endTime then
 			progress = self:getNextProgress(self.data.progress)
 			if progress then
 				local registerWeek = tonumber(GameData:getMapData('serverwarschedule.dat')[tostring(progress)]['EndWeek'])
				local bt = Time.beginningOfWeek()

				local dt = PvpData:getScheduleByProgress(progress)
				local startTime = bt + (tonumber(dt.StartWeek) - 1) * 24 * 3600 + tonumber(dt.StartHour) * 3600
				local endTime = bt + (tonumber(dt.EndWeek) - 1) * 24 * 3600 + tonumber(dt.StartHour) * 3600 + tonumber(dt.Interval) * 5 *60
				nowTime = UserData:getServerTime()
				local time = startTime - nowTime
				if time <= 0 then
					time = 1
				end
				return i,startTime - nowTime
			end
			return i
		end
	end
	return i
end

function PvpKnockoutPanel:getPerOfTImebar()
	if self.data.progress == PROGRESS.SUPPORT4 then
		return 13
	elseif self.data.progress == PROGRESS.TO16 then
		return 17.5 + self:getNowProgress(13)
	elseif self.data.progress == PROGRESS.TO8 then
		return 34.5 + self:getNowProgress(13)
	elseif self.data.progress == PROGRESS.TO4 then
		return 51.5 + self:getNowProgress(13)
	elseif self.data.progress == PROGRESS.SUPPORT1 then
		return 68.5
	elseif self.data.progress == PROGRESS.TO2 then
		return 68.5 + self:getNowProgress(13)
	elseif self.data.progress == PROGRESS.TO1 then
		return 86 + self:getNowProgress(14)
	else
		return 100
	end

end

function PvpKnockoutPanel:updateProgressLine()
	local panel = self.sceneObject:getPanelObj()
	root = panel:GetRawPanel()
	local timeBarBgImg = tolua.cast(root:getChildByName('time_bar_bg_img') , 'UIImageView')
	timeBar = tolua.cast(timeBarBgImg:getChildByName('time_bar') , 'UILoadingBar')
	per = self:getPerOfTImebar()
	timeBar:setPercent(per)
	timeBar:setVisible(true)
end

function PvpKnockoutPanel:updateTime()
	-- _,time = self:getNowProgress(13)
	_,time = self:updateTimeInfo()
	time = tonumber(time) or 0
	if time <= 0 then
		self.timeInfoTx:setVisible(false)
		self.timeCDTx:setVisible(false)
	else
		self.timeCDTx:setTime(time + 4)
		self.timeCDTx:registerTimeoutHandler(function ()
			PvpController:getRecords(function(res)
				self.data.records = res.data.records
				self.data.replays = res.data.replays
				self.data.progress = res.data.progress
				self:updatePlayerName(self.data.progress)
				self:updateBlueLines(self.data.progress)
				self:updateZan(self.data.progress)
				self:updateProgressLine()
				-- self:updateBtn()
				self:updateTime()
			end)
		end)
	end
end

function PvpKnockoutPanel:updateGroupBtns(progress)
	myUid = PlayerCoreData.getUID()
	_,index = getPlayer(myUid,self.data)
	maxPlayer = self:getMaxPlayer(progress)
	if maxPlayer == MAXPLAYER.THIRTYTWO then
		self.page = ((index - 1) - (index - 1)%8)/8 + 1
		if self.page == 0 then
			self.page = 1
		end
		self.groupBtns[self.page]:setPressState(WidgetStateSelected)
		self.groupBtns[self.page]:setTouchEnable(false)
	elseif maxPlayer == MAXPLAYER.FOR then
		self.page = 5
	end
end

function PvpKnockoutPanel:updateTimeInfo()
	myUid = PlayerCoreData.getUID()
	_,index = getPlayer(myUid,self.data)
	_,index1 = getPlayerInTop4(myUid,self.data)
	self.readyToFightBtn:setVisible(false)
	local time = nil
	local per = nil
	self.fightIndex = -1
	if index > 0 then
		temIndex1 = (index - 1 - (index - 1)%2)/2 + 1
		temIndex2 = 16 + (index - 1 - (index - 1)%4)/4 + 1
		temIndex3 = 24 + (index - 1 - (index - 1)%8)/8 + 1
		temIndex4 = 28 + (index1 - 1 - (index1 - 1)%2)/2 + 1
		temIndex5 = 31
		per,time = self:getNowProgress(13)
		if #self.data.records == 16 then
			if self.data.records[temIndex1] + 1 == 0 then	
				self.readyToFightBtn:setVisible(true)
				self.fightIndex = 0
				self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC1'))
			elseif self.data.records[temIndex1] + 1 == index then
				time = (5 - (per or 13)*5/13) * 5 * 60 + time
				print(time)
				if (per or 13)*5/13 == 5 then
					self.readyToFightBtn:setVisible(true)
					self.fightIndex = 0
				end
				self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC1'))
			else
				self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC2'))
			end
		elseif #self.data.records == 24 then
			if self.data.records[temIndex1] + 1 == index then
				if self.data.records[temIndex2] + 1 == 0 then
					self.readyToFightBtn:setVisible(true)
					self.fightIndex = 0
					self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC1'))
				elseif self.data.records[temIndex2] + 1 == index then
					time = (5 - (per or 13)*5/13) * 5 * 60 + time
					if (per or 13)*5/13 == 5 then
						self.readyToFightBtn:setVisible(true)
						self.fightIndex = 0
					end
					self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC1'))
				else
					self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC2'))
				end
			else
				self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC2'))
			end
		elseif #self.data.records == 28 then
			if self.data.records[temIndex2] + 1 == index then
				if self.data.records[temIndex3] + 1 == 0 then
					self.readyToFightBtn:setVisible(true)
					self.fightIndex = 0
				elseif self.data.records[temIndex3] + 1 == index then
					local per1 = per
					if (per or 13)*5/13 == 4 then
						per1 = 13
					end
					time = (5 -per1) * 5 * 60 + time
					print(time)
					if (per or 13)*5/13 == 5 then
						self.readyToFightBtn:setVisible(true)
						self.fightIndex = 0
					end
					self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC1'))
				else
					self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC2'))
				end
			else
				self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC2'))
			end
		elseif #self.data.records == 30 then
			if self.data.records[temIndex3] + 1 == index then
				if self.data.records[temIndex4] + 1 == 0 then
					self.readyToFightBtn:setVisible(true)
					self.fightIndex = 0
					self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC1'))
				elseif self.data.records[temIndex4] + 1 == index then
					time = (5 - (per or 13)*5/13) * 5 * 60 + time
					if (per or 13)*5/13 == 5 then
						self.readyToFightBtn:setVisible(true)
						self.fightIndex = 0
					end
					self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC1'))
				else
					self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC2'))
				end
			end
		elseif #self.data.records == 31 and self.data.records[31] == -1 then
			if self.data.records[temIndex4] + 1 == index then
				if self.data.records[temIndex5] + 1 == 0 then
					self.readyToFightBtn:setVisible(true)
					self.fightIndex = 0
					self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC1'))
				else
					self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC2'))
				end
			end
		end
	else
		per,time = self:getNowProgress(13)
		self.timeInfoTx1:setText(getLocalStringValue('E_STR_PVP_WAR_TIME_DESC2'))
	end
	return per,time
end

function PvpKnockoutPanel:updateBtn()
	-- myUid = PlayerCoreData.getUID()
	-- _,index = getPlayer(myUid,self.data)
	-- _,index1 = getPlayerInTop4(myUid,self.data)
	-- self.readyToFightBtn:setVisible(false)
	-- self.fightIndex = -1
	-- if index > 0 then
	-- 	temIndex1 = (index - 1 - (index - 1)%2)/2 + 1
	-- 	temIndex2 = 16 + (index - 1 - (index - 1)%4)/4 + 1
	-- 	temIndex3 = 24 + (index - 1 - (index - 1)%8)/8 + 1
	-- 	temIndex4 = 28 + (index - 1 - (index - 1)%16)/16 + 1
	-- 	temIndex5 = 31
	-- 	if #self.data.records == 16 then
	-- 		if self.data.records[temIndex1] + 1 == 0 then
	-- 			self.readyToFightBtn:setVisible(true)
	-- 			self.fightIndex = 0
	-- 		end
	-- 	elseif #self.data.records == 24 then
	-- 		if self.data.records[temIndex1] + 1 == index then
	-- 			if self.data.records[temIndex2] + 1 == 0 then
	-- 				self.readyToFightBtn:setVisible(true)
	-- 				self.fightIndex = 0
	-- 			end
	-- 		end
	-- 	elseif #self.data.records == 28 then
	-- 		if self.data.records[temIndex2] + 1 == index then
	-- 			if self.data.records[temIndex3] + 1 == 0 then
	-- 				self.readyToFightBtn:setVisible(true)
	-- 				self.fightIndex = 0
	-- 			end
	-- 		end
	-- 	elseif #self.data.records == 30 then
	-- 		if self.data.records[temIndex3] + 1 == index then
	-- 			if self.data.records[temIndex4] + 1 == 0 then
	-- 				self.readyToFightBtn:setVisible(true)
	-- 				self.fightIndex = 0
	-- 			end
	-- 		end
	-- 	elseif #self.data.records == 31 and self.data.records[31] == -1 then
	-- 		if self.data.records[temIndex4] + 1 == index then
	-- 			if self.data.records[temIndex5] + 1 == 0 then
	-- 				self.readyToFightBtn:setVisible(true)
	-- 				self.fightIndex = 0
	-- 			end
	-- 		end
	-- 	end
	-- end
end

function PvpKnockoutPanel:getAwards()
	local awards = {}
	local awardsData = {}
	local i = 1
	if self.data.awards.day then
		table.insert(awards,i)
		awards[i] = 1
		table.insert(awardsData,i)
		awardsData[i] = self.data.awards.day
		i = i + 1
	end
	if self.data.awards.last_rank then
		table.insert(awards,i)
		awards[i] = 2
		table.insert(awardsData,i)
		awardsData[i] = self.data.awards.last_rank
		i = i + 1
	end
	if self.data.awards.rank then
		table.insert(awards,i)
		awards[i] = 3
		table.insert(awardsData,i)
		awardsData[i] = self.data.awards.rank
		i = i + 1
	end
	if self.data.awards.support4 then
		table.insert(awards,i)
		awards[i] = 4
		table.insert(awardsData,i)
		awardsData[i] = self.data.awards.support4
		i = i + 1
	end
	if self.data.awards.support1 then
		table.insert(awards,i)
		awards[i] = 5
		table.insert(awardsData,i)
		awardsData[i] = self.data.awards.support1
		i = i + 1
	end

	if #awards > 0 then
		PvpGetAwardsPanel:enter(awards,awardsData)
	end
	self.data.awards = {}
end

function PvpKnockoutPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()
		
		local MainBgImg = tolua.cast(root:getChildByName('32to16_bg_img') , 'UIImageView')
		local titleImg = tolua.cast(root:getChildByName('title_img') , 'UIImageView')
		local helpBtn = tolua.cast(root:getChildByName('help_btn') , 'UIButton')
		local gobackBtn = tolua.cast(root:getChildByName('goback_btn') , 'UIButton')
		local paiweiBtn = tolua.cast(root:getChildByName('paiwei_btn') , 'UIButton')
		local refreshBtn = tolua.cast(root:getChildByName('refresh_btn') , 'UIButton')
		self.finalsBtn = tolua.cast(root:getChildByName('finals_btn') , 'UIButton')
		self.reviewBtn = tolua.cast(root:getChildByName('review_btn') , 'UIButton')
		local myReportBtn = tolua.cast(root:getChildByName('my_report_btn') , 'UIButton')
		local myQuizBtn = tolua.cast(root:getChildByName('my_quiz_btn') , 'UIButton')
		self.readyToFightBtn = tolua.cast(root:getChildByName('ready_to_fight_btn') , 'UIButton')
		self.timeInfoTx = tolua.cast(root:getChildByName('info_bg_img') , 'UILabel')
		self.timeInfoTx1 = tolua.cast(self.timeInfoTx:getChildByName('time_info_tx') , 'UILabel')
		timeTx = tolua.cast(root:getChildByName('time_tx') , 'UILabel')
		timeTx:setText('')
		self.timeCDTx = UICDLabel:create()
		self.timeCDTx:setFontSize(22)
		self.timeCDTx:setPosition(ccp(0,0))
		self.timeCDTx:setFontColor(ccc3(50, 240, 50))
		self.timeCDTx:setAnchorPoint(ccp(0,0.5))
		timeTx:addChild(self.timeCDTx)

		-- self:inRank()
		-- self.readyToFightBtn:setVisible(self.isInRank)
		refreshBtn:setVisible(false)
		self.finalsBtn:setVisible(false)
		-- paiweiBtn:setVisible(self.isMain == false)
		paiweiBtn:setNormalButtonGray(self.isMain == true)
		paiweiBtn:setTouchEnable(self.isMain == false)

		self.nameLabels = {}
		self.fangdajingIcos = {}
		self.supportPlayersBtn = {}
		self.nameLabels1 = {}
		self.fangdajingIcos1 = {}
		self.supportPlayersBtn1 = {}
		self.blueLines32 = {}
		self.blueLines4 = {}
		self.myReplays = {}
		self.groupBtns = {}

		self:registerButtonWithHandler(root, 'goback_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			self.data.progress = self.progress
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		self:registerButtonWithHandler(root, 'help_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			PvpController.show(PvpKnockoutHelpPanel, ELF_SHOW.SLIDE_IN)
			print('help_btn')
		end)
		self:registerButtonWithHandler(root, 'paiwei_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			print('paiwei_btn')
			PvpMainPanel:enter1(self.data)
		end)
		self:registerButtonWithHandler(root, 'my_report_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			print('my_report_btn')
			PvpMyReportsPanel:enter(self.data)
		end)
		self:registerButtonWithHandler(root, 'ready_to_fight_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			print('ready_to_fight_btn')
			print(self.fightIndex)
			if self.fightIndex == -1 then
				OpenEmbattleUiforPVP(false)
			else
				index = self:getEnemyInfo()
				local player = self.data.top32[index]
				print(index)
				print(player.uid)
				PvpController:getLastTeam(function(res1)
					PvpController.lastEnemy = {}
					PvpController.lastEnemy.team = res1.data.last_team
					-- self.rank = res1.data.rank
					PvpController.lastEnemy.name = player.name
					PvpController.lastEnemy.serverid = player.serverid
					PvpController.lastEnemy.force = player.force
					PvpController.lastEnemy.headpic = player.headpic
					PvpController.lastEnemy.uid = player.uid
					PvpController.lookType = 2
					OpenEmbattleUiforPVP(true)
				end,player.uid)
			end
		end)
		self:registerButtonWithHandler(root, 'my_quiz_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			print('my_quiz_btn')
			PvpMyQuizPanel:enter(self.data)
		end)
		self:registerButtonWithHandler(root, 'refresh_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			print('refresh_btn')
			PvpController:getRecords(function(res)
				self.data.records = res.data.records
				self.data.replays = res.data.replays
				self.data.progress = res.data.progress
				self:updatePlayerName(self.data.progress)
				self:updateBlueLines(self.data.progress)
				self:updateZan(self.data.progress)
				self:updateProgressLine()
				-- self:updateBtn()
				self:updateTime()
			end)
		end)
		 for i=1,MAXPLAYER.FOR do
		 	str = string.format('group_'..'%d'..'_btn',i)
			groupBtn = tolua.cast(root:getChildByName(str) , 'UIButton')
		 	table.insert(self.groupBtns,i)
		 	self.groupBtns[i] = groupBtn
		 	self:registerButtonWithHandler(root, str, BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
		 		self.groupBtns[self.page]:setPressState(WidgetStateNormal)
		 		self.groupBtns[self.page]:setTouchEnable(true)
				self.page = i
				self.groupBtns[i]:setPressState(WidgetStateSelected)
				self.groupBtns[i]:setTouchEnable(false)
				self:updatePlayerName(PROGRESS.TO4)
				self:updateZan(PROGRESS.SUPPORT4)
				self:updateBlueLines(PROGRESS.SUPPORT4)
			end)
		 end

		-- 32强到4强赛的按钮
		for i=1,MAXPLAYER.EIGHT do
			self.thirtytwoStrong = tolua.cast(root:getChildByName('32_strong_pl') , 'UIPanel')
		 	str = string.format('zan_'..'%d'..'_img',i)
			zanImg = tolua.cast(self.thirtytwoStrong:getChildByName(str) , 'UIImageView')
	    	zanImg:registerScriptTapHandler(function ()
				self:support(i)
			end)
			table.insert(self.supportPlayersBtn,i)
			self.supportPlayersBtn[i] = zanImg

			str = string.format('name_bg_'..'%d'..'_img',i)
			nameBg = tolua.cast(self.thirtytwoStrong:getChildByName(str) , 'UILabel')
			nameBg:registerScriptTapHandler(function ()
				PvpPlayerInfoPanel:enter(self.data,i,1,self.page)
			end)
			str = string.format('player_'..'%d'..'_name_tx',i)
			playerNameTx = tolua.cast(self.thirtytwoStrong:getChildByName(str) , 'UILabel')
			table.insert(self.nameLabels,i)
			self.nameLabels[i] = playerNameTx
		end

		for i=1,7 do
		 	str = string.format('fangda_'..'%d'..'_ico',i)
			fangdajingIco = tolua.cast(self.thirtytwoStrong:getChildByName(str) , 'UIImageView')
	    	fangdajingIco:registerScriptTapHandler(function ()
	    		if i <= 4 then
					PvpReportsPanel:enter(self.data,i,self.page)
				elseif i == 5 or i == 6 then
					PvpReportsPanel:enter(self.data,i,self.page)
				elseif i == 7 then
					PvpReportsPanel:enter(self.data,i,self.page)
				end
			end)
			table.insert(self.fangdajingIcos,i)
			self.fangdajingIcos[i] = fangdajingIco
		end
		for i=1,15 do
		 	str = string.format('blue_line_'..'%d'..'_img',i)
			blueline = tolua.cast(self.thirtytwoStrong:getChildByName(str) , 'UIImageView')
			blueline:setVisible(false)
			table.insert(self.blueLines32,i)
			self.blueLines32[i] = blueline
		end
		self:registerButtonWithHandler(root, 'finals_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			print('finals_btn')
			self.groupBtns[self.page]:setPressState(WidgetStateNormal)
			self.groupBtns[self.page]:setTouchEnable(true)
			self.page = 5
			self:updatePlayerName(PROGRESS.SUPPORT1)
			self:updateBlueLines(PROGRESS.SUPPORT1)
			self.finalsBtn:setVisible(false)
			self:updateZan(PROGRESS.SUPPORT1)
		end)
		self.playerFrame = tolua.cast(root:getChildByName('player_frame_img') , 'UIImageView')
		self.head = tolua.cast(self.playerFrame:getChildByName('head_img') , 'UIImageView')
		self.nameTx = tolua.cast(self.playerFrame:getChildByName('name_tx') , 'UILabel')

		-- 4强赛的按钮
		self:registerButtonWithHandler(root, 'review_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
				self.reviewBtn:setVisible(false)
				self.page = 1
				self.groupBtns[self.page]:setPressState(WidgetStateSelected)
				self.groupBtns[self.page]:setTouchEnable(false)
				self:updatePlayerName(PROGRESS.SUPPORT4)
				self:updateBlueLines(PROGRESS.SUPPORT4)
				self.finalsBtn:setVisible(true)
				self:updateZan(PROGRESS.SUPPORT4)
		end)
		for i=1,MAXPLAYER.FOR do
			self.fourStrong = tolua.cast(root:getChildByName('4_strong_pl') , 'UIPanel')
		 	str = string.format('zan_'..'%d'..'_img',i)
			zanImg = tolua.cast(self.fourStrong:getChildByName(str) , 'UIImageView')
	    	zanImg:registerScriptTapHandler(function ()
				self:support(i)
			end)
			table.insert(self.supportPlayersBtn1,i)
			self.supportPlayersBtn1[i] = zanImg

			str = string.format('name_bg_'..'%d'..'_img',i)
			nameBg = tolua.cast(self.fourStrong:getChildByName(str) , 'UILabel')
			nameBg:registerScriptTapHandler(function ()
				PvpPlayerInfoPanel:enter(self.data,i,2,self.page)
			end)
			str = string.format('player_'..'%d'..'_name_tx',i)
			playerNameTx = tolua.cast(self.fourStrong:getChildByName(str) , 'UILabel')
			table.insert(self.nameLabels1,i)
			self.nameLabels1[i] = playerNameTx
		end

		for i=1,3 do
		 	str = string.format('fangda_'..'%d'..'_ico',i)
			fangdajingIco = tolua.cast(self.fourStrong:getChildByName(str) , 'UIImageView')
	    	fangdajingIco:registerScriptTapHandler(function ()
				PvpReportsPanel:enter(self.data,7 + i,self.page)
			end)
			table.insert(self.fangdajingIcos1,i)
			self.fangdajingIcos1[i] = fangdajingIco
		end
		for i=1,7 do
		 	str = string.format('blue_line_'..'%d'..'_img',i)
			blueline = tolua.cast(self.fourStrong:getChildByName(str) , 'UIImageView')
			blueline:setVisible(false)
			table.insert(self.blueLines4,i)
			self.blueLines4[i] = blueline
		end
		-- self.playerFrame4 = tolua.cast(self.fourStrong:getChildByName('player_frame_img') , 'UIImageView')
		-- self.head4 = tolua.cast(self.playerFrame4:getChildByName('head_img') , 'UIImageView')
		-- self.nameTx4 = tolua.cast(self.playerFrame4:getChildByName('name_tx') , 'UILabel')

		-- -- 适配 
		local winSize = CCDirector:sharedDirector():getWinSize()
		MainBgImg:setPosition(ccp(winSize.width/2,winSize.height/2))
		local titleImgSize = titleImg:getContentSize()
		titleImg:setPosition(ccp(winSize.width/2,winSize.height - titleImgSize.height/2 + 10))
		local helpBtnSize = helpBtn:getContentSize()
		helpBtn:setPosition(ccp(helpBtnSize.width, winSize.height - helpBtnSize.height))
		
		local myQuizBtnSize = myQuizBtn:getContentSize()
		myQuizBtn:setPosition(ccp(myQuizBtnSize.width - 20, myQuizBtnSize.height*2 + 20))
		local myReportBtnSize = myReportBtn:getContentSize()
		myReportBtn:setPosition(ccp(myReportBtnSize.width - 20, myReportBtnSize.height + 10))
		
		local paiweiBtnSize = paiweiBtn:getContentSize()
		paiweiBtn:setPosition(ccp(winSize.width - paiweiBtnSize.width /2 - 30, winSize.height - paiweiBtnSize.height))
		local refreshBtnSize = refreshBtn:getContentSize()
		refreshBtn:setPosition(ccp(winSize.width - paiweiBtnSize.width /2 - 30, winSize.height - paiweiBtnSize.height*2 - 5))
		local finalsBtnSize = self.finalsBtn:getContentSize()
		-- self.finalsBtn:setPosition(ccp(winSize.width - paiweiBtnSize.width /2 - 30, winSize.height - paiweiBtnSize.height*3 - 10))
		-- self.reviewBtn:setPosition(ccp(winSize.width - paiweiBtnSize.width /2 - 30, winSize.height - paiweiBtnSize.height*3 - 10))
		self.finalsBtn:setPosition(ccp(winSize.width - paiweiBtnSize.width /2 - 30, winSize.height - paiweiBtnSize.height*2 - 5))
		self.reviewBtn:setPosition(ccp(winSize.width - paiweiBtnSize.width /2 - 30, winSize.height - paiweiBtnSize.height*2 - 5))

		local gobackBtnSize = gobackBtn:getContentSize()
		gobackBtn:setPosition(ccp(winSize.width - gobackBtnSize.width /2 - 30, gobackBtnSize.height - 30))

		self:updateGroupBtns(self.data.progress)

		self:updatePlayerName(self.data.progress)
		self:updateZan(self.data.progress)
		self:updateBlueLines(self.data.progress)
		self:updateProgressLine()
		-- self:updateTime()
		-- self:updateBtn()
		self:updateTime()
		-- self:getAwards()
	end)
	panel:registerOnShowHandler(function()
		self:getAwards()
	end)
end

function PvpKnockoutPanel:enter(res)
	self.data = res.data
	self.isMain = false
	PvpController.show(PvpKnockoutPanel, ELF_SHOW.SLIDE_IN)
end

function PvpKnockoutPanel:enter1(res)
	self.data = res
	self.progress = self.data.progress
	self.data.progress = PROGRESS.OVER
	self.isMain = true
	PvpController.show(PvpKnockoutPanel, ELF_SHOW.SLIDE_IN)
end

function PvpKnockoutPanel:release()

end