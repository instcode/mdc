-- 军团战-战斗界面
PATH_COLOR = readOnly{		-- 路径的颜色
	ENABLE = ccc3(75, 243, 255),
	DISABLE = ccc3(184, 184, 184),
	ATTACK = ccc3(255, 29, 36)
}

MAP_COLOR = readOnly{		-- 地图的颜色
	ccc3(20, 173, 28),
	ccc3(57, 45, 222),
	ccc3(214, 24, 27),
	ccc3(77,75,77)
}

LegionWarBattlePanel = LegionView:new{
	jsonFile = 'panel/legion_war_battle_panel.json',
	panelName = 'legion-war-battle-panel',

	embattleBtn = nil,
	rankBtn = nil,
	reportBtn = nil,
	refreshBtn = nil,
	backBtn = nil,

	starPanel = nil,
	killPanel = nil,
	stars = nil,	-- 战场星级的星星
	cities = nil,	-- 战场城池
	paths = nil,	-- 城池之间的路径
	maps = nil,		-- 可占领城池的势力地图

	integralNumTx = nil,  -- 个人积分
	killNumTx = nil,      -- 杀敌
	physicalNumTx = nil,  -- 体力
	powerNumTx = nil,     -- 行动力
	bossBuffTx = nil,     -- boss BUFF

	myMainCityId = nil,
	myLegionBadge = nil,
	remainTime = nil,     -- 倒计时
	refreshTime = nil,
	recoverTime = nil	  -- 恢复行动力倒计时
}

function LegionWarBattlePanel:showWithData( data )
	LegionWarController.show(LegionWarBattlePanel, ELF_SHOW.SLIDE_IN)
end

function LegionWarBattlePanel:fuckingAdapting( root )
	local background = tolua.cast(root:getChildByName('army_img'), 'UIImageView')
	self:adaptChildToScreen(background, LEGION_VIEW_POSITION.MIDDLE_MIDDLE)

	local levelPanel = tolua.cast(root:getChildByName('level_pl'), 'UIPanel')
	self:adaptChildToScreen(levelPanel, LEGION_VIEW_POSITION.TOP_RIGHT)

	local infoPanel = tolua.cast(root:getChildByName('integral_pl'), 'UIPanel')
	self:adaptChildToScreen(infoPanel, LEGION_VIEW_POSITION.TOP_LEFT)

	local killPanel = tolua.cast(root:getChildByName('kill_panel') , 'UIPanel')
	self:adaptChildToScreen(killPanel, LEGION_VIEW_POSITION.TOP_MIDDLE)

	self:adaptChildToScreen(self.embattleBtn, LEGION_VIEW_POSITION.BOTTOM_RIGHT)
	self:adaptChildToScreen(self.backBtn, LEGION_VIEW_POSITION.BOTTOM_LEFT)
end

function LegionWarBattlePanel:initCities( root )
	-- Initial cities.
	self.cities = {}
	for i = 1, 7 do
		local btn = self:registerButtonWithHandler(root, string.format("buiding_%d_btn", i), nil, function()
			self:onClickCity(i)
		end)
		self.cities[i] = btn
	end
end

function LegionWarBattlePanel:initButtons( root )
	self.backBtn = self:registerButtonWithHandler(root, 'return_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
		LegionWarController.close(self, ELF_HIDE.SLIDE_OUT)
	end)

	self.embattleBtn = self:registerButtonWithHandler(root, 'doubtful_btn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
		OpenEmbattleUi()
	end)

	self.rankBtn = self:registerButtonWithHandler(root, 'ranking_btn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
		LegionWarController.sendLegionWarRankRequest( function ( response )
			if response.code == 0 then
				LegionWarFieldRankPanel:showWithData( response.data.score )
			end
		end)
	end)

	self.reportBtn = self:registerButtonWithHandler(root, 'info_btn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
		genNewsPanel(NEWS_TAG.TAG_LEGION_BATTLE)
	end)

	self.refreshBtn = self:registerButtonWithHandler(root, 'new_btn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
		self.refreshTime = self.refreshTime or 0
		local lastTime = UserData:getServerTime() - self.refreshTime
		if lastTime > 0.5 then
			LegionWarController.sendLegionWarGetBattleFieldRequest(function ( res )
				local code = res.code
				if code == 0 then
					self.refreshTime = UserData:getServerTime()
					GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_BATTLE_INFO_REFRESH'),COLOR_TYPE.GREEN)
					self:update()
				end
			end)
		end
	end)
end

function LegionWarBattlePanel:initStars( root )
	self.starPanel = tolua.cast(root:getChildByName('star_pl'), 'UIPanel')
	self.stars = {}
	for i = 1, 3 do
		local str = string.format("star_%d_ico", i)
		table.insert(self.stars, tolua.cast(self.starPanel:getChildByName(str), 'UIImageView'))
	end
	if tonumber(LegionWar.progress) == 1 then
		print('one star')
		self:setStars(3)
	elseif tonumber(LegionWar.progress) == 3 then
		print('two stars')
		self:setStars(2)
	elseif tonumber(LegionWar.progress) == 9 then
		print('three stars')
		self:setStars(1)
	end
end

function LegionWarBattlePanel:initPaths( root )
	-- Initial paths.
	self.paths = {}
	for i = 1, 7 do
		for j = 1, 7 do
			local key
			if i < j then
				key = string.format("%d_%d", i, j)
			else
				key = string.format("%d_%d", j, i)
			end

			if self.paths[key] == nil then
				self.paths[key] = tolua.cast(root:getChildByName(string.format('line_%s_ico', key)), 'UIImageView')
			end
		end
	end
end

function LegionWarBattlePanel:initMaps( root )
	self.maps = {}
	for _, v in pairs({4, 5, 6, 7}) do
		local str = string.format("map_%d_ico", v)
		local map = tolua.cast(root:getChildByName(str), 'UIImageView')
		self.maps[v] = map
	end
end

function LegionWarBattlePanel:initInfo( root )
	local integralPl = tolua.cast(root:getChildByName('integral_pl'), 'UIPanel')
	-- 个人积分
	self.integralNumTx = tolua.cast(integralPl:getChildByName('integral_num_tx'), 'UILabel')
	-- 杀敌
	self.killNumTx = tolua.cast(integralPl:getChildByName('kill_num_tx'), 'UILabel')
	-- 体力
	self.physicalNumTx = tolua.cast(integralPl:getChildByName('physical_num_tx'), 'UILabel')
	-- 行动力
	self.powerNumTx = tolua.cast(integralPl:getChildByName('power_num_tx'), 'UILabel')
	-- boss buff
	self.bossBuffTx = tolua.cast(integralPl:getChildByName('boss_buff_tx'), 'UILabel')
	self.bossBuffTx:setPreferredSize(220,1)
	-- 购买行动力
	local addBtn = tolua.cast(integralPl:getChildByName('add_btn'), 'UIButton')
	GameController.addButtonSound(addBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	addBtn:registerScriptTapHandler(function ()
		local price = LegionWarConfig:getPriceByTimes(LegionWar.user.move_buy,'CashMove')
		if price == 0 then
			GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_BUY_TIMES_OVER'),COLOR_TYPE.RED)
		else
			GameController.showMessageBox(string.format(LegionConfig:getLegionLocalText('LEGION_CONFIRM_BUY_MOVE'), price,tonumber(LegionConfig:getValueForKey('BuyMoveNum'))), MESSAGE_BOX_TYPE.OK_CANCEL, function ()
		 		if PlayerCoreData.getCashValue() < price then -- 元宝不足
		 			GameController.showPrompts(getLocalString("E_STR_CASH_NOT_ENOUGH") , COLOR_TYPE.RED)
		 		else
		 			LegionWarController.sendLegionWarBuyMoveRequest(function ( res )
			 			local code = res.code
			 			if code == 0 then
			 				GameController.showPrompts(getLocalString("E_STR_BUY_SUCCEED") , COLOR_TYPE.GREEN)
			 				self:update()
			 			end
			 		end)
		 		end
		 	end)
		end
	end)
	-- 行动力恢复倒计时
	self.recoverTime = UICDLabel:create()
	self.recoverTime:setFontSize(24)
	self.recoverTime:setFontColor(COLOR_TYPE.WHITE)
	self.recoverTime:setPosition(ccp(185,-8))
	integralPl:addChild(self.recoverTime)
	self.recoverTime:registerTimeoutHandler(function ()
		local rTime = UserData:getServerTime() - LegionWar.user.move_time
		local intervalTime = tonumber(LegionConfig:getValueForKey('ActRestoring')) - MyLegion:getTechEffectByID(6)
		local addTimes = math.floor(rTime/intervalTime)
		local nextPower = tonumber(LegionWar.user.move) + addTimes
		if nextPower <= 0 then
			nextPower = 1
		end
		LegionWar.user.move = nextPower
		self.powerNumTx:setText(tostring(nextPower))
		self.recoverTime:setTime(intervalTime)
	end)
end

function LegionWarBattlePanel:initMyBadge( root )
	local background = tolua.cast(root:getChildByName('army_img'), 'UIImageView')
	self.myLegionBadge = UIImageView:create()
	self.myLegionBadge:setTexture('uires/ui_2nd/com/panel/goldmine/zhan.png')
	self.myLegionBadge:setWidgetZOrder(100)
	background:addChild(self.myLegionBadge)
end

function LegionWarBattlePanel:initRemainTime( root )
	local overTx = tolua.cast(root:getChildByName('over_tx'), 'UILabel')
	overTx:setPreferredSize(200,1)
	self.remainTime = UICDLabel:create()
	self.remainTime:setFontSize(22)
	self.remainTime:setFontColor(COLOR_TYPE.WHITE)
	self.remainTime:setPosition(ccp(65,-2))
	overTx:addChild(self.remainTime)
	self.remainTime:registerTimeoutHandler(function ()
		-- 显示结算等待图片
		LegionController.show(LegionWarTimeoutPanel, ELF_SHOW.NORMAL)
	end)
end

function LegionWarBattlePanel:initKillTx( root )
	self.killPanel = tolua.cast(root:getChildByName('kill_panel') , 'UIPanel')
end

function LegionWarBattlePanel:init()
	local panel = self.sceneObject:getPanelObj()

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:initButtons(root)
		self:initStars(root)
		self:initCities(root)
		self:initPaths(root)
		self:initMaps(root)
		self:initInfo(root)
		self:initMyBadge(root)
		self:initRemainTime(root)
		self:initKillTx(root)

		self:fuckingAdapting(root)

		self:update()
	end)
end

function LegionWarBattlePanel:update()
	self:updateCities()
	self:updateInfo()
	self:updateRemainTimes()
	self:updateMessage()
end

function LegionWarBattlePanel:updateMessage()
	if LegionWar.message then
		local message = LegionWar.message
		local kill_tx = tolua.cast(self.killPanel:getChildByName('kill_message_tx') , 'UILabel')
		kill_tx:setText( string.format(LegionConfig:getLegionLocalText('LEGION_FINISH_KILL_DESC') , message[1] , tonumber(message[2])) )
		self.killPanel:setVisible(true)
	else
		self.killPanel:setVisible(false)
	end
end

function LegionWarBattlePanel:updateCities()
	print('--- updateCities ---')
	print(json.encode(LegionWar.occupy))
	
	local allLegions = {}
	for k, v in pairs(LegionWar.legions) do
		if tonumber(k) == MyLegion.lid then	-- 我的主城id
			self.myMainCityId = tonumber(v.city)
		end
		allLegions[tostring(k)] = tonumber(v.city)
	end
	print('self.myMainCityId = ' .. self.myMainCityId)
	print('MyLegion.lid = ' .. MyLegion.lid)
	-- 设置被占领的城池颜色
	for cityID, legionID in pairs(LegionWar.occupy) do
		--cityID = tonumber(cityID)
		-- if tonumber(legionID) == MyLegion.lid then
		-- 	if self.maps[tonumber(cityID)] ~= nil then
		-- 		self.maps[tonumber(cityID)]:setColor(MAP_COLOR[self.myMainCityId])
		-- 	end
		-- end
		if self.maps[tonumber(cityID)] ~= nil then
			if tonumber(legionID) == 0 then -- 没人占领
				self.maps[tonumber(cityID)]:setColor(MAP_COLOR[4])
			else
				self.maps[tonumber(cityID)]:setColor(MAP_COLOR[allLegions[tostring(legionID)]])
			end
		end
	end
	-- 先將所有的道路颜色置灰
	for k, v in pairs(self.paths) do
		v:setColor(PATH_COLOR.DISABLE)
	end
	-- 设置我所在的城池周围的道路颜色
	print('我所在的城市id = ' .. LegionWar.user.city)
	local fieldCity = LegionWarConfig:getFieldCityByID(LegionWar.user.city)
	for k, v in pairs(fieldCity.City) do
		if LegionWar.occupy[tostring(v)] == MyLegion.lid then
			print('被我们占领了')
			LegionWarBattlePanel:setPathColorByTwoCities( LegionWar.user.city, v, PATH_COLOR.ENABLE )
		elseif LegionWar.occupy[tostring(v)] == 0 then
			print('没人占领')
			LegionWarBattlePanel:setPathColorByTwoCities( LegionWar.user.city, v, PATH_COLOR.ENABLE )
		else
			print('被别人占领了')
			LegionWarBattlePanel:setPathColorByTwoCities( LegionWar.user.city, v, PATH_COLOR.ATTACK )
		end
	end

	-- 设置我的军团徽章的位置
	self.myLegionBadge:setPosition(ccp(self.cities[tonumber(LegionWar.user.city)]:getPosition().x,self.cities[tonumber(LegionWar.user.city)]:getPosition().y + 50))
end

function LegionWarBattlePanel:updateInfo()
	-- 个人积分
	self.integralNumTx:setText(tostring(LegionWar.user.score))
	-- 杀敌
	self.killNumTx:setText(tostring(LegionWar.user.kill))
	-- 体力
	local maxEnergy = MyLegion:getTechEffectByID(5) + tonumber(LegionConfig:getValueForKey('BattleInitPower'))
	self.physicalNumTx:setText(LegionWar.user.energy .. '/' .. maxEnergy)
	-- 行动力
	self.powerNumTx:setText(tostring(LegionWar.user.move))
	-- 恢复行动力倒计时
	local rTime = UserData:getServerTime() - LegionWar.user.move_time
	local intervalTime = tonumber(LegionConfig:getValueForKey('ActRestoring')) - MyLegion:getTechEffectByID(6)
	rTime = math.mod(rTime, intervalTime)
	rTime = intervalTime - rTime
	if rTime <= 0 then
		rTime = intervalTime
	end
	self.recoverTime:setTime(rTime)
	-- buff持续时间
	if LegionWar.user.boss_buff == 1 then
		self.bossBuffTx:setVisible(true)
		print(LegionConfig:getValueForKey('BossAttBuff'))
		print(LegionWar.user.boss_buff_use)
		self.bossBuffTx:setText(string.format(LegionConfig:getLegionLocalText('LEGOIN_BOSS_BUFF_LAST'), tonumber(LegionConfig:getValueForKey('BossAttBuff')),2-tonumber(LegionWar.user.boss_buff_use)))
		self.bossBuffTx:setColor(COLOR_TYPE.GREEN)
	else
		self.bossBuffTx:setVisible(false)
	end
	
end

function LegionWarBattlePanel:updateRemainTimes()
	local remain = Time.beginningOfWeek() + 
				  ((tonumber(LegionWarConfig:getWarScheduleByProgress(LegionWar.progress).StartWeek)-1)*24 + 
				  	tonumber(LegionWarConfig:getWarScheduleByProgress(LegionWar.progress).StartTime) + 
				  	tonumber(LegionWarConfig:getWarScheduleByProgress(LegionWar.progress).KeepHour))*3600 - 
				    UserData:getServerTime()
	self.remainTime:setTime(remain)
end

-- 点击城池的事件
function LegionWarBattlePanel:onClickCity( cityID )
	local data = LegionWarConfig:getFieldCityByID(cityID)
	if data then
		print(string.format('--- on click ID:%d %s ---', cityID, data.Name))
		LegionWarController.sendLegionWarGetBattleFieldCityRequest(cityID, function ( res )
			local code = res.code
			if code == 0 then
				res.data.city = tonumber(res.args.city)
				LegionWarCityPanel:showWithData(res.data)
			end
		end)
	end
end

-- 设置战场星级星星数
function LegionWarBattlePanel:setStars( count )
	local panelSz = self.starPanel:getContentSize()
	table.foreach(self.stars, function ( i, star )
		star:setVisible(false)
	end)

	if count <= 0 or count > #self.stars then return end

	local starSz = self.stars[1]:getContentSize()
	local scale = self.stars[1]:getScale()
	local starSpace = 0 -- 星星之间的间隙
	local insetWidth = starSz.width * scale * count + starSpace * (count - 1)
	local initX = (panelSz.width - insetWidth) / 2
	for i = 1, count do
		local x = (i - 1) * (starSz.width * scale + starSpace) + initX + starSz.width * scale * 0.5
		local y = self.stars[i]:getPosition().y
		self.stars[i]:setPosition(ccp(x, y))
		self.stars[i]:setVisible(true)
	end
end

-- 设置路径的颜色
function LegionWarBattlePanel:setPathColorByTwoCities( city1, city2, color )
	local path = self:findPathFromTwoCities(city1, city2)
	if path then
		path:setColor(color)
	end
end

-- 设置势力地图的颜色
function LegionWarBattlePanel:setMapColorByCity( city, color )
	local map = self.maps[city]
	if map then 
		map:setColor(color)
	end
end

-- 获取两个城池之间的路径
function LegionWarBattlePanel:findPathFromTwoCities( city1, city2 )
	local key
	if city1 < city2 then
		key = string.format("%d_%d", city1, city2)
	else
		key = string.format("%d_%d", city2, city1)
	end

	return self.paths[key]
end

function LegionWarBattlePanel:release()
	LegionView.release(self)
	self.embattleBtn = nil
	self.rankBtn = nil
	self.reportBtn = nil
	self.refreshBtn = nil
	self.backBtn = nil
	self.starPanel = nil
	self.cities = nil
	self.paths = nil
	self.myMainCityId = nil
	self.integralNumTx = nil
	self.killNumTx = nil
	self.physicalNumTx = nil
	self.powerNumTx = nil
	self.myLegionBadge = nil
	self.remainTime = nil
	self.refreshTime = nil
	self.recoverTime = nil
	self.bossBuffTx = nil
end