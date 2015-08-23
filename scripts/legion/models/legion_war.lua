-- 军团战数据
LegionWar = {
	progress = nil,
	boss = nil,
	boss_id = nil,
	legions = nil,
	occupy = nil,
	message = nil,
	user = nil,
	near_city = nil
}

function LegionWar:update( data )
	print('------ LegionWar:update -----')
	if data then
		ModelHelper.updateKeyIfChanged(self, 'progress', data.progress)
		ModelHelper.updateKeyIfChanged(self, 'boss', data.boss)
		ModelHelper.updateKeyIfChanged(self, 'boss_id', data.boss_id)
		ModelHelper.updateKeyIfChanged(self, 'legions', data.legions)
		ModelHelper.updateKeyIfChanged(self, 'occupy', data.occupy)	
		ModelHelper.updateKeyIfChanged(self, 'user', data.user)
		ModelHelper.updateKeyIfChanged(self, 'message' , data.message)
		ModelHelper.updateKeyIfChanged(self, 'near_city' , data.near_city)
	end
end

function LegionWar:updateUser(data)
	if data then
		ModelHelper.updateKeyIfChanged(self.user, 'city', data.city)
		ModelHelper.updateKeyIfChanged(self.user, 'move', data.move)
		ModelHelper.updateKeyIfChanged(self.user, 'energy', data.energy)
		ModelHelper.updateKeyIfChanged(self.user, 'score', data.score)
		ModelHelper.updateKeyIfChanged(self.user, 'move_buy', data.move_buy)
		ModelHelper.updateKeyIfChanged(self.user, 'boss_buff', data.boss_buff)
		ModelHelper.updateKeyIfChanged(self.user, 'boss_buff_use', data.boss_buff_use)
		ModelHelper.updateKeyIfChanged(self.user, 'free_revive', data.free_revive)
		ModelHelper.updateKeyIfChanged(self.user, 'cash_revive', data.cash_revive)
	end
end

-- 军团战战斗期间
function LegionWar:isWaring()
	if tonumber(self.progress) then -- 9 , 3 , 1
		return true
	end
	return false

	-- local isWaring = false

	-- local conf = GameData:getArrayData('legionwarschedule.dat')
	-- local bt = Time.beginningOfWeek()
	-- local st = UserData:getServerTime()

	-- for _, v in pairs (conf) do
	-- 	if tonumber(v.Progress) then
	-- 		local c_st = bt + ((tonumber(v.StartWeek)-1) * 24 + tonumber(v.StartTime)) * 3600
	-- 		local c_et = c_st + tonumber(v.KeepHour) * 3600

	-- 		if st >= c_st and st <= c_et then
	-- 			isWaring = true
	-- 		end
	-- 	end
	-- end

	-- return isWaring
end