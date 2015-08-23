giveGod = {}

function ParseGodData(jsonData)
	giveGod = json.decode(jsonData)
end

function setGodData(v)
	giveGod = v
end

function getGiveGodData()
	return giveGod
end

function _getGodRoleIfIsOver()
	if giveGod.got_god == nil then
		return true
	end
	local openLevel = getGlobalIntegerValue('RecruitLvBuOpenLevel', 6)
	local giveGodAwardConf = GameData:getArrayData('god.dat')
	local currentLv = PlayerCoreData.getPlayerLevel()
	local isOver = false
	if currentLv < openLevel then
		return true
	else
		local finishFlag = true
		for k, v in pairs(giveGod.got_god) do
			if tonumber(v) == 0 then 
				finishFlag = false
				break
			end
		end
		if finishFlag then -- 如果神将都领完了
			-- 如果三个奖励都领完了
			if tonumber(giveGod.got_reward[1]) == 1 and tonumber(giveGod.got_reward[2]) == 1 and tonumber(giveGod.got_reward[3]) == 1 then
				return true
			else -- 有奖励没有领
				for k, v in pairs(giveGod.got_reward) do
					if tonumber(v) == 0 and tonumber(giveGod.status[k]) == 1 then -- 没有领并且可以领
						return false
					elseif tonumber(v) == 0 and tonumber(giveGod.status[k]) == 0 then -- 没有领并且不能领
						local time = UserData:getServerTime() - PlayerCoreData.getCreatePlayerTime()
						local leftTime = tonumber(giveGodAwardConf[k].AccountCreateTimePass) - time
						if leftTime > 0 then -- 没过期
							return false
						end
					end
				end
				return true
			end
		else
			return false
		end
	end
	return isOver
end

function _getGodRole()
	if giveGod.got_god == nil then
		return ''
	end
	local heroIndex = #giveGod.got_god
	for k, v in pairs(giveGod.got_god) do
		if tonumber(v) == 0 then
			heroIndex = k
			break
		end
	end
	local heroId = GameData:getArrayData('givehero.dat')[heroIndex].GodRid
	return 'uires/ui_2nd/com/panel/mainscene/god_role_' .. heroId .. '.png'
end