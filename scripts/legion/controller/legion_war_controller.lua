LegionWarController = {
	
}

function LegionWarController.show( view, style )
	LegionController.show( view, style )
end

function LegionWarController.close( view, style )
	LegionController.close( view, style )
end

-- 军团战的入口
function LegionWarController.enter()
	-- LegionWarController.show(LegionWarHelpPanel, ELF_SHOW.ZOOM_IN)
	LegionWarController.sendLegionWarGetRequest(function ( response ) 
		LegionWarEntrancePanel:showWithData( response.data )
	end)
end


--[[ 军团战get数据的请求
]]
function LegionWarController.sendLegionWarGetRequest( callback )
	Message.sendPost('get', 'legionwar', '{}', function( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			LegionWar:update( res.data )
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战报名
]]
function LegionWarController.sendLegionWarRegisterrequest(callback)
	Message.sendPost('register', 'legionwar', '{}', function( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战获取战场数据
	response:
			cities :{cityId:{legion:,time:}} 城市占领情况
			user：{city：,score:,energy:,} 玩家数据
			legions:{legion:score} 玩家所在战场各个军团积分
			message :{{name,kill}某某连斩,{atkName,defName,kill}某某破xx连斩}
			move 剩余行动力
			last_fight_time 上次进攻的时间
]]
function LegionWarController.sendLegionWarGetBattleFieldRequest(callback)
	Message.sendPost('get_battle_field', 'legionwar', '{}', function( response )
		cclog(response)

		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			LegionWar:update( res.data )
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战获取战场某个城市的数据
	response:
			cities :{cityId:{legion:,time:}} 城市占领情况
			user：{city：,score:,energy:,} 玩家数据
			legions:{legion:score} 玩家所在战场各个军团积分
			message :{{name,kill]某某连斩,{atkName,defName,kill}某某破xx连斩}
			move 剩余行动力
			last_fight_time 上次进攻的时间
			members {uid：{kill：score：name：energy：}}
			move 用户背包里可获取的行动力
]]
function LegionWarController.sendLegionWarGetBattleFieldCityRequest(cityID, callback)
	local args = { city = cityID }
	Message.sendPost('get_city', 'legionwar', json.encode(args), function( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战战斗
	response:
			battle 对象
			energy 扣除的体力
			move 扣除的行动力

]]
function LegionWarController.sendLegionWarFightRequest(uid, callback)
	local args = { target = tonumber(uid) }
	Message.sendPost('fight', 'legionwar', json.encode(args), function( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			LegionWar:updateUser(res.data)
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战迁徙
]]
function LegionWarController.sendLegionWarMoveRequest(cityID, callback)
	local args = { city = cityID }
	Message.sendPost('move', 'legionwar', json.encode(args), function( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			LegionWar:updateUser(res.data)
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战获取体力
	response:
			energy_got 获得体力
]]
function LegionWarController.sendLegionWarGetEneryRequest(isfree, callback)
	local args = { cash = isfree }
	Message.sendPost('revive', 'legionwar', json.encode(args), function( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			LegionWar:updateUser(res.data)
			if res.data.cash then
				PlayerCoreData.addCashDelta(res.data.cash)
			end
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战结算 (暂时没有这个接口)
	response:
			user {name: score:}
			legions [{legion: score: promotion：}]

]]
function LegionWarController.sendLegionWarEndWarrequest(callback)
	Message.sendPost('end_war', 'legionwar', '{}', function( response )
		cclog(response)
		local res = json.decode(response)
		if callback then callback(res) end
	end)
end

--[[ 军团战购买行动力
	response:
			cash 花费元宝
]]
function LegionWarController.sendLegionWarBuyMoveRequest(callback)
	Message.sendPost('buy_move', 'legionwar', '{}', function( response )
		cclog(response)
		local res = json.decode(response)

		if ControllerHelper.handleErrorCode(res.code) then
			LegionWar:updateUser(res.data)
			PlayerCoreData.addCashDelta(res.data.cash)
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战获取战报 (暂时没有这个接口)
	response:
			report:[{name:,time：,succ:energy:score:replay:}] 
]]
-- function LegionWarController.sendLegionWarGetReportrequest(callback)
-- 	Message.sendPost('get_report', 'legionwar', '{}', function( response )
-- 		cclog(response)
-- 		local res = json.decode(response)
-- 		if callback then callback(res) end
-- 	end)
-- end

--[[ 军团战获取回放 (暂时没有这个接口)
	respones:
			battle 对象
]]
-- function LegionWarController.sendLegionWarGetReplyRequest(id, callback)
-- 	local args = { id = id }
-- 	Message.sendPost('get_replay', 'legionwar', json.encode(args), function( response )
-- 		cclog(response)
-- 		local res = json.decode(response)
-- 		if callback then callback(res) end
-- 	end)
-- end

--[[ 军团战获取奖励
	response:
			awards
]]
function LegionWarController.sendLegionWarGetRewardrequest(callback)
	Message.sendPost('get_reward', 'legionwar', '{}', function( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战排行榜 
]]
function LegionWarController.sendLegionWarRankRequest( callback )
	Message.sendPost('battle_field_rank', 'legionwar', '{}', function ( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战挑战城里BOSS
	response:
			score 积分
			boss_buff
			boss_buff_move
			boss_time  BOSS新的被打时间
]]
function LegionWarController.sendLegionWarFightBossRequest(callback)
	Message.sendPost('fight_boss', 'legionwar', '{}', function( response )
		cclog(response)
		local res = json.decode(response)
		if ControllerHelper.handleErrorCode(res.code) then
			LegionWar:updateUser(res.data)
			if callback then callback(res) end
		end
	end)
end

--[[ 军团战赛况
]]
function LegionWarController.sendLegionWarInfoRequest( callback )
	Message.sendPost('my_win', 'legionwar', '{}', function( response )
		cclog(response)
		local res = json.decode(response)
		if callback then callback(res) end
	end)
end
