PvpController = {
	mainData = {},
	lastTop32 = {},
	lastTop32rank = {},
	top32 = {},
	score,
	lastTime,
	matchTimes,
	battleTimes,
	rank,
	lastRank,
	open,
	serverid,
	lookType = 1,
	lastEnemy = {},
	fighted = 1,
	fightForce,
	getRankListTime = 0,
	rankListData,
	supports = {},
	supports1 = {}
}

function PvpController.entrance()
end


function PvpController.show( view, style )
	style = style or ELF_SHOW.NORMAL
	scene = view:create()
	if scene then
		CUIManager:GetInstance():ShowObject(scene, style)
	end
end

function PvpController.close( view, style )
	local objScene = view:getScene()
	if objScene == nil then
		return
	end

	style = style or ELF_HIDE.HIDE_NORMAL
	CUIManager:GetInstance():HideObject(objScene, style)
	view:release()
end

--[[ 获得PVP信息
]]
function PvpController:getPvpInfo(callback)
	Message.sendPost('get', 'serverwar', '{}', function( response )
		cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			self.score = res.data.score or 0
			self.fightForce = res.data.fight_force or 0
			self.lastTime = res.data.server_war.match_time or 0
			self.battleTimes = res.data.server_war.battle or 0
			self.serverid = res.data.serverid or 0
			self.matchTimes = res.data.server_war.match or 0
			self.rank = res.data.rank or getLocalStringValue('E_STR_PVP_WAR_WU')
			self.lastRank = res.data.last_rank or 0
			self.open = res.data.open or 0
			self.register = res.data.register or 0
			self.fighted = res.data.server_war.fighted or self.fighted
			self.lastEnemy = res.data.server_war.matched or nil
			self.supports = res.data.server_war.support.top4
			self.supports1 = res.data.server_war.support.top1
			self.getRankListTime = 0
			self.rankListData = nil
			self.lastTop32rank = res.data.last_top32_rank
			self.lastTop32 = res.data.last_top32
			self.top32 = res.data.top32
			self.supports = {}
			self.supports1 = {}
			local i = 1
			for k,v in pairs(res.data.server_war.support.top4) do
				table.insert(self.supports,i)
				self.supports[i] = k
				i = i + 1
			end
			local j = 1
			for k,v in pairs(res.data.server_war.support.top1) do
				table.insert(self.supports1,j)
				self.supports1[j] = k
				j = j + 1
			end
			if res.data.progress == 'rank' then
				self.top32 = res.data.last_top32
				if callback then callback(res) end
			elseif res.data.progress == 'support4' then
				if callback then callback(res) end
			elseif res.data.progress == '16' then
				if callback then callback(res) end
			elseif res.data.progress == '8' then
				if callback then callback(res) end
			elseif res.data.progress == '4' then
				if callback then callback(res) end
			elseif res.data.progress == 'support1' then
				if callback then callback(res) end
			elseif res.data.progress == '2' then
				if callback then callback(res) end
			elseif res.data.progress == '1' then
				if callback then callback(res) end
			elseif res.data.progress == 'over' then
				if callback then callback(res) end
			else
				GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
			end
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 匹配对手
]]
function PvpController:matchEnemy(callback,cash)
	args = {
		cash = cash
	}
	Message.sendPost('match_enemy', 'serverwar', json.encode(args), function( response )
		cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			self.matchTimes = self.matchTimes + 1
			self.lastEnemy = res.data.enemy or {}
			self.fighted = 0
			if callback then callback(res) end
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 挑战
	uid      玩家UID
	cash     花费元宝
	revenge  是否复仇
]]
function PvpController:rankFight(callback,uid,cash,revenge,replayid)
	args = {
		enemy = uid,
		cash = cash,
		revenge = revenge,
		replayid = replayid
	}
	Message.sendPost('rank_fight', 'serverwar', json.encode(args), function( response )
		cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			self.battleTimes = self.battleTimes + 1
			if callback then callback(res) end
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 排行榜
]]
function PvpController:getRankList(callback)
	Message.sendPost('get_rank_list', 'serverwar', '{}', function( response )
		cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			if callback then callback(res) end
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 战斗记录
]]
function PvpController:getReplayList(callback)
	Message.sendPost('get_replay_list', 'serverwar', '{}', function( response )
		-- cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			if callback then callback(res) end
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 战斗记录
	replayid 回放ID
]]
function PvpController:getReplay(callback,replayid)
	args = {
		id = replayid
	}
	Message.sendPost('get_replay', 'serverwar', json.encode(args), function( response )
		-- cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			if callback then callback(res) end
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 支持玩家
	supportid 支持玩家ID
	top 支持小组赛还是决赛
]]
function PvpController:support(callback,supportid,top)
	args = {
		id = supportid,
		topn = top
	}
	Message.sendPost('support', 'serverwar', json.encode(args), function( response )
		cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			self.supports = {}
			local i = 1
			for k,v in pairs(res.data.support.top4) do
				table.insert(self.supports,i)
				self.supports[i] = k
				i = i + 1
			end			
			self.supports1 = {}
			i = 1
			for k,v in pairs(res.data.support.top1) do
				table.insert(self.supports1,i)
				self.supports1[i] = k
				i = i + 1
			end
			if callback then callback() end
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 保存阵形
]]
function PvpController:saveTeam(callback,team)
	args = {
		team = team
	}
	print(json.encode(args))
	Message.sendPost('save_team', 'serverwar', json.encode(args) , function( response )
		cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			if callback then callback() end
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 获取上一场阵型
	uid 玩家ID
]]
function PvpController:getLastTeam(callback,uid)
	args = {
		uid = uid,
	}
	Message.sendPost('get_last_team', 'serverwar', json.encode(args) , function( response )
		cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			if callback then callback(res) end
		elseif tonumber(res.code) == 101 then
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC21'), COLOR_TYPE.RED)
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 获取上一场阵型
]]
function PvpController:getRecords(callback)
	-- args = {
	-- 	uid = uid,
	-- }
	Message.sendPost('get_records', 'serverwar', '{}' , function( response )
		cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			if callback then callback(res) end
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 获取玩家信息
	uid 玩家ID
]]
function PvpController:getUserInfo(callback, uid)
	args = {
		id = uid,
	}
	Message.sendPost('get_roles', 'serverwar', json.encode(args) , function( response )
		cclog(response)
		local res = json.decode(response)
		if tonumber(res.code) == 0 then
			if callback then callback(res) end
		else
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
		end
	end)
end

--[[ 清空缓存
]]
function PvpController:release()
	self.mainData = nil
	-- self.score = nil,
	-- self.lastTime = nil,
	-- self.battle = nil
end