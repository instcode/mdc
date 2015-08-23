wBossData = {
	data = {}
}

wBossData.BEFORE_WAR = 0		--boss战前
wBossData.WARING = 1			--boss战中
wBossData.AFTER_WAR = 2			--boss战后

-- return : status , lefttime
function wBossData:getProgress()
	local st = getGlobalIntegerValue('WorldBossStartTime')

	local nowTime = UserData:getServerTime()
	local startTime = Time.beginningOfToday() + st * 3600
	local endTime = startTime + getGlobalIntegerValue('WorldBossContinueTime') - 20 -- 服务器提前20秒结束

	if nowTime < startTime then
		return wBossData.BEFORE_WAR , startTime - nowTime
	elseif nowTime >= startTime and nowTime < endTime then
		return wBossData.WARING , endTime - nowTime
	else
		return wBossData.AFTER_WAR , startTime + 86400 - nowTime
	end
end

function wBossData:getBuyCostByKeyAndTimes( key , buytimes )
	local resetTab = {}

	local conf = GameData:getArrayData('buy.dat')
	for _, v in pairs ( conf ) do
		if v[key] and v[key] ~= '' then
			table.insert(resetTab , tonumber(v[key]) )
		end
	end

	local length = #resetTab
	local nextTimes = buytimes + 1
	if nextTimes > length then
		nextTimes = length
	end

	return tonumber(resetTab[nextTimes]) , length - buytimes
end

local function getRankRage( rank )
	local conf = GameData:getArrayData('worldbossreward.dat')

	local tab = {}

	for _ , v in pairs (conf) do
		if tonumber( v.HurtRank ) then
			table.insert( tab , tonumber( v.HurtRank) )
		end
	end

	local len = #tab

	for index = 1 , len do
		local nextIndex = index + 1
		if nextIndex > len then
			nextIndex = len
		end

		if tonumber(rank) >= tab[index] and tonumber(rank) < tab[nextIndex] then
			return tab[index]
		end
	end

	return tab[len]
end

function wBossData:getConfData( rank )
	if rank == 'kill' then
		return GameData:getMapData('worldbossreward.dat')['kill']
	elseif rank == 'dragonbox' then
		return GameData:getMapData('worldbossreward.dat')['dragonbox']
	else
		local conf = GameData:getArrayData('worldbossreward.dat')
		local keyRank = getRankRage( rank )
		for _, v in pairs (conf) do
			if tonumber(v.HurtRank) == tonumber(keyRank) then
				return v
			end
		end
		return nil
	end
end

function wBossData:isHaveDragonBoxReward()
	local n = 0
	for _, v in pairs (wBossData.data.dragon_balls) do
		if tonumber(v) >= 1 then
			n = n + 1
		end
	end
	return n >= 7
end

function wBossData:updateData( data )
	-- data = {}
	-- data.rewards = {}
	-- data.rewards.join = 0
	-- data.rewards.kill = 0
	-- data.rewards.hurt = 0
	-- data.killer = {name = 'zzx1' , uid = 111000}
	-- data.dragon_ball = {}
	-- data.dragon_ball[1] = 1
	-- data.dragon_ball[2] = 4
	-- data.dragon_ball[3] = 16
	-- data.dragon_ball[4] = 7
	-- data.dragon_ball[5] = 1
	-- data.dragon_ball[6] = 9
	-- data.dragon_ball[7] = 0
	-- data.last_top5 = {}
	-- table.insert(data.last_top5 , 'zzx1')
	-- table.insert(data.last_top5 , 'zzx2')
	-- table.insert(data.last_top5 , 'zzx3')
	-- table.insert(data.last_top5 , 'zzx4')
	-- table.insert(data.last_top5 , 'zzx5')
	-- data.last_hurt = 0
	-- data.last_rank = 0
	-- data.buy_times = 0

	-- data.boss = {}
	-- data.boss.id = 1
	-- data.boss.blood = 100
	-- data.boss.health = 50
	-- data.battle_info = {}
	-- data.battle_info.rank = 1
	-- data.battle_info.attacks = 10
	-- data.battle_info.inspire_add = 0
	-- data.battle_info.hurt = 50
	-- data.inspire = {}
	-- data.inspire.gold = 5
	-- data.inspire.cash = 5
	-- data.death_time = 0

	wBossData.data = data
end

function wBossData:getData()
	return wBossData.data
end