LegionWarCityCell = LegionCell:new{
	jsonFile = 'panel/legion_war_city_cell.json',

	nameTx = nil, 			-- 名字
	levelTx = nil,			-- 等级
	tiliTx = nil, 			-- 体力
	jifenTx = nil,			-- 积分
	challengeBtn = nil,		-- 挑战
	uid = nil,
	isBoss = nil,			-- 是否是boss
	bossReviveTime = nil	-- 复活倒计时
}


function LegionWarCityCell.createCell(datA)
	local cell = LegionWarCityCell:new{data = datA}
	cell:create()
	return cell
end

function LegionWarCityCell:init()
	self.nameTx = tolua.cast(self.panel:getChildByName('name_tx'), 'UILabel')
	self.levelTx = tolua.cast(self.panel:getChildByName('lv_tx'), 'UILabel')
	self.tiliTx = tolua.cast(self.panel:getChildByName('tili_tx'), 'UILabel')
	self.jifenTx = tolua.cast(self.panel:getChildByName('jifen_tx'), 'UILabel')
	self.challengeBtn = tolua.cast(self.panel:getChildByName('challenge_tbtn'), 'UITextButton')
	GameController.addButtonSound(self.challengeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	self.challengeBtn:registerScriptTapHandler(function ()
		if self.isBoss then
			self:challengeBoss()
		else
			self:challengePeople()
		end
	end)

	self.bossReviveTime = UICDLabel:create()
	self.bossReviveTime:setFontSize(24)
	self.bossReviveTime:setFontColor(COLOR_TYPE.WHITE)
	self.bossReviveTime:setPosition(self.challengeBtn:getPosition())
	self.panel:addChild(self.bossReviveTime)
	self.bossReviveTime:registerTimeoutHandler(function ()
		self.bossReviveTime:setVisible(false)
		self.challengeBtn:setVisible(true)
	end)
end

function LegionWarCityCell:challengePeople()
	if tonumber(LegionWar.user.energy) <= 0 then --我的体力不足
		GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_ENERGY_NOT_ENOUGH'), COLOR_TYPE.RED)
	elseif tonumber(LegionWar.user.move) < 1 then -- 我的行动力不足
		GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_MOVE_NOT_ENOUGH'), COLOR_TYPE.RED)
	elseif tonumber(self.tiliTx:getStringValue()) == 0 then
		GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_DO_NOT_BEAT_OTHERS'), COLOR_TYPE.RED)
	else
		LegionWarController.sendLegionWarFightRequest(self.uid, function ( res )
			local code = res.code
			if code == 0 then
				-- 先播放战斗然后去get更新军团战场界面，可能会边打边转菊花
				GameController.clearAwardView() -- 清除战斗奖励(用于没有经验和奖励的战斗)
				if res.data.battle then
					GameController.saveOldBattleInfo()
					GameController.playBattle(json.encode(res.data.battle), 5)
				end
				LegionWarController.sendLegionWarGetBattleFieldRequest(function ( res )
					local code = res.code
					if code == 0 then
						-- 更新战场主界面
						LegionWarBattlePanel:update()
						-- 更新city界面
						LegionWarCityPanel:requestCityInfo()
					end
				end)
			end
		end)
	end
end

function LegionWarCityCell:challengeBoss()
	if tonumber(LegionWar.user.energy) <= 0 then --我的体力不足
		GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_ENERGY_NOT_ENOUGH'), COLOR_TYPE.RED)
	elseif tonumber(LegionWar.user.move) < 1 then -- 我的行动力不足
		GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_MOVE_NOT_ENOUGH'), COLOR_TYPE.RED)
	else
		LegionWarController.sendLegionWarFightBossRequest(function ( res )
			local code = res.code
			if code == 0 then
				-- 先播放战斗然后去get更新军团战场界面，可能会边打边转菊花
				GameController.clearAwardView() -- 清除战斗奖励(用于没有经验和奖励的战斗)
				if res.data.battle then
					GameController.saveOldBattleInfo()
					GameController.playBattle(json.encode(res.data.battle), 5)
				end
				LegionWarController.sendLegionWarGetBattleFieldRequest(function ( res )
					local code = res.code
					if code == 0 then
						-- 更新战场主界面
						LegionWarBattlePanel:update()
						-- 更新city界面
						LegionWarCityPanel:requestCityInfo()
					end
				end)
			end
		end)
	end
end

function LegionWarCityCell:update(data)
	self.bossReviveTime:setTime(0)
	self.bossReviveTime:setVisible(false)
	self.nameTx:setText(data.name)
	if data.isBoss then
		if tonumber(data.score) == 0 then
			self.jifenTx:setText(string.format(LegionConfig:getLegionLocalText('LEGION_KILL_BOSS_BUFF_NUMBER'), tonumber(LegionConfig:getValueForKey('BossAttBuff'))))
			self.tiliTx:setText(LegionConfig:getLegionLocalText('LEGION_KILL_BOSS_BUFF'))
		else
			self.jifenTx:setText('+' .. data.score)
			self.tiliTx:setText('')
			self.levelTx:setText('')
		end
		self.nameTx:setColor(COLOR_TYPE.RED)
		self.jifenTx:setColor(COLOR_TYPE.RED)
		self.tiliTx:setColor(COLOR_TYPE.RED)
		local reviveTime = UserData:getServerTime() - tonumber(data.time)
		print('reviveTime = ' .. reviveTime)
		if reviveTime >= tonumber(LegionConfig:getValueForKey('RebornTime')) then
			self.challengeBtn:setVisible(true)
		else
			reviveTime = tonumber(LegionConfig:getValueForKey('RebornTime')) - reviveTime
			self.bossReviveTime:setVisible(true)
			self.bossReviveTime:setTime(reviveTime)
			self.challengeBtn:setVisible(false)
		end
	else
		self.jifenTx:setText(data.score)
		self.nameTx:setColor(COLOR_TYPE.WHITE)
		self.jifenTx:setColor(COLOR_TYPE.WHITE)
		self.tiliTx:setColor(COLOR_TYPE.WHITE)
		self.tiliTx:setText(data.energy)
		self.levelTx:setColor(COLOR_TYPE.WHITE)
		self.levelTx:setText(data.level)
		self.challengeBtn:setVisible(data.canChallenge)
	end
	self.uid = data.uid
	self.isBoss = data.isBoss
end

function LegionWarCityCell:release()
	LegionCell.release(self)
	self.nameTx = nil
	self.tiliTx = nil
	self.jifenTx = nil
	self.challengeBtn = nil
	self.uid = nil
	self.isBoss = nil
	self.bossReviveTime = nil
end