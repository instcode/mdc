PvpData = {
	DayAwardData = {},
	RankAwardData = {},
	maxMatchTimes,
	maxBuyMatch,
	maxBattleTimes,
	maxBuyBattle
}

PROGRESS = {
	RANK = 'rank',
	SUPPORT4 = 'support4',
	TO16 = '16',
	TO8 = '8',
	TO4 = '4',
	SUPPORT1 = 'support1',
	TO2 = '2',
	TO1 = '1',
	OVER = 'over'
}
function PvpData:loadConf()
	self:DayAwardCfg()
	self:RankAwardCfg()
	self:maxTimesCfg()
end
function PvpData:DayAwardCfg()
	local conf = GameData:getArrayData('serverwarglory.dat')
	for _, v in pairs(conf) do
		table.insert(self.DayAwardData , v)
	end
end

function PvpData:RankAwardCfg()
	local conf = GameData:getArrayData('serverwarreward.dat')
	for _, v in pairs(conf) do
		table.insert(self.RankAwardData , v)
	end
end

function PvpData.getRule(rank)
	local conf = GameData:getArrayData('serverwarglory.dat')
	local tab = {}
	for i, v in pairs(conf) do
		if rank < tonumber(v.Rank) then
			return tab.glory
		end
		tab = v
	end
	return conf[7].glory
end

function PvpData.getSupportAward(rank)
	local conf = GameData:getArrayData('serverwarsupport.dat')
	local tab = {}
	for i, v in pairs(conf) do
		if rank == tonumber(v.Rank) then
			tab = v
		end
	end
	return tab
end

function PvpData:getScheduleByProgress( progressID )
	local conf = GameData:getArrayData('serverwarschedule.dat')
	for i, v in pairs(conf) do
		if v.Progress == tostring(progressID) then
			return v
		end
	end
	return nil
end

function PvpData:maxTimesCfg()
	self.maxMatchTimes = getGlobalIntegerValue('ServerWarMatchLimitPerDay')
	self.maxBuyMatch = getGlobalIntegerValue('ServerWarBuyMatchCash')
	self.maxBattleTimes = getGlobalIntegerValue('ServerWarBattleLimitPerDay')
	self.maxBuyBattle = getGlobalIntegerValue('ServerWarBuyBattleCash')
	-- self.maxMatchTimes = getGlobalIntegerValue('ServerWarLevelMin')
end

function PvpData:getRoleInfo(id)
	local conf = GameData:getArrayData('role.dat')
	for i, v in pairs(conf) do
		if id == tonumber(v.Id) then
			return v
		end
	end
	return nil
end