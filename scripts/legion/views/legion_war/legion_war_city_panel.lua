LegionWarCityPanel = LegionView:new{
	jsonFile = 'panel/legion_war_city_panel.json',
	panelName = 'legion-war-city-panel',

	cells = nil,
	datas = nil,
	moveBtn = nil,			-- 迁徙按钮
	energyBtn = nil,		-- 领取体力按钮
	photoIco = nil,  		-- 城池图标
	nameTx = nil, 			-- 城池名字
	numberTx = nil, 		-- 防守人数
	legionNameTx = nil, 	-- 所属军团
	sv = nil,				-- 军团member滚动条
	cardNum = nil,			-- 已经加载的cell数量
	canChallenge = nil,		-- 选中的城池是否可以挑战
	freeTimesTx = nil,		-- 复活剩余次数
	maxCashReviveTimes = nil,	-- 最大元宝复活次数
	reviveCashIco = nil,		-- 元宝复活元宝图标	
	reviveCashNumTx = nil,		-- 元宝复活元宝tx
	reviveTimesOverTx = nil,		-- 复活次数已用完
	myMainCityId = nil,		-- 我的主城id
	jiaTx = nil,			-- buff
	haveBoss = nil			-- 这个城池是否有boss
}

function LegionWarCityPanel:showWithData( data )
	self:updateData(data)
	-- TODO: handle data...
	LegionWarController.show(self, ELF_SHOW.ZOOM_IN)
	self:update()
end

function LegionWarCityPanel:updateData(data)
	local members = {}
	for k, v in pairs(data.members) do
		v.uid = k
		table.insert(members, v)
	end
	self.data = data
	self.data.members = members
end

function LegionWarCityPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('buiding_bg_img', 'buiding_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		local buidingBgImg = tolua.cast(root:getChildByName('buiding_bg_img'), 'UIImageView')
		local buidingImg = tolua.cast(buidingBgImg:getChildByName('buiding_img'), 'UIImageView')
		local photoImg = tolua.cast(buidingImg:getChildByName('photo_img'), 'UIImageView')
		self.photoIco = tolua.cast(photoImg:getChildByName('photo_ico'), 'UIImageView')
		
		self.nameTx = tolua.cast(buidingImg:getChildByName('name_tx'), 'UILabel')

		self.numberTx = tolua.cast(buidingImg:getChildByName('number_tx'), 'UILabel')

		self.legionNameTx = tolua.cast(buidingImg:getChildByName('legion_name_tx'), 'UILabel')

		self.jiaTx = tolua.cast(buidingImg:getChildByName('jia_tx'), 'UILabel')
		self.jiaTx:setPreferredSize(180,1)

		self.freeTimesTx = tolua.cast(buidingImg:getChildByName('free_times_tx'), 'UILabel')

		self.reviveCashIco = tolua.cast(buidingImg:getChildByName('cash_ico'), 'UIImageView')

		self.reviveCashNumTx = tolua.cast(buidingImg:getChildByName('cash_num_tx'), 'UILabel')

		self.reviveTimesOverTx = tolua.cast(buidingImg:getChildByName('times_over_tx'), 'UILabel')

		-- 最大元宝复活次数
		local buyConf = GameData:getArrayData('buy.dat')
		self.maxCashReviveTimes = 0
		for _, v in pairs ( buyConf ) do
			if v.CashReviveWar and v.CashReviveWar ~= '' then
				self.maxCashReviveTimes = self.maxCashReviveTimes + 1
			else
				break
			end
		end 

		-- 领取体力
		self.energyBtn = tolua.cast(root:getChildByName('energy_tbtn'), 'UITextButton')
		GameController.addButtonSound(self.energyBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		self.energyBtn:registerScriptTapHandler(function ()
			local isFree = 0
			local maxFreeRevive = tonumber(LegionConfig:getValueForKey('FreeReviveTimes'))
			if tonumber(LegionWar.user.free_revive) >= maxFreeRevive then
				if tonumber(LegionWar.user.cash_revive) < self.maxCashReviveTimes then
					isFree = 1
				else
					return
				end
			end
			if isFree == 1 then	-- 元宝复活
				local cashNum = LegionWarConfig:getPriceByTimes(LegionWar.user.cash_revive,'CashReviveWar')
				if cashNum > PlayerCoreData.getCashValue() then
					GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
					return
				end
				GameController.showMessageBox(string.format(LegionConfig:getLegionLocalText('LEGION_CASH_REVIVE_CONFIRM'), cashNum, self.maxCashReviveTimes-tonumber(LegionWar.user.cash_revive)), MESSAGE_BOX_TYPE.OK_CANCEL, function ()
     				self:sendReviveRequest(isFree)
     			end)
     		else -- 免费复活
     			self:sendReviveRequest(isFree)
			end
		end)

		self.moveBtn = tolua.cast(root:getChildByName('qianxi_tbtn'), 'UITextButton')
		GameController.addButtonSound(self.moveBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		-- 迁徙
		self.moveBtn:registerScriptTapHandler(function ()
			if tonumber(LegionWar.user.move) < 1 then
				GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_MOVE_NOT_ENOUGH'), COLOR_TYPE.RED)
			elseif tonumber(LegionWar.user.energy) == 0 then
				GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_ENERGY_NOT_ENOUGH'), COLOR_TYPE.RED)
			else
				LegionWarController.sendLegionWarMoveRequest(self.data.city, function (res)
					local code = res.code
					if code == 0 then
						LegionWarController.sendLegionWarGetBattleFieldRequest(function ( res )
							local code = res.code
							if code == 0 then
								-- 更新战场主界面
								LegionWarBattlePanel:update()
								-- 更新city界面
								self:requestCityInfo()
							end
						end)
					end
				end)
			end
		end)
		
		self.sv = tolua.cast(root:getChildByName('people_sv'), 'UIScrollView')
		self.sv:setClippingEnable(true)
		self.cells = {}
		self.datas = {}
		self.cardNum = (#self.data.members < 5 and #self.data.members) or 5
		for i = 1, self.cardNum do
			local cell = LegionWarCityCell.createCell()
			self.sv:addChildToBottom(cell:getPanel())
			table.insert(self.cells, cell)
		end
		-- self:bindCellsToScrollView(self.cells, sv, SCROLLVIEW_DIR_VERTICAL)
		self.sv:registerScrollToBottomEvent(function()
			local num = (self.cardNum + 5 < #self.data.members and self.cardNum + 5) or #self.data.members
			print('num = ' .. num)
			print('self.data.members = ' .. #self.data.members)
			for i = self.cardNum + 1, num do
				local cell = LegionWarCityCell.createCell()
				self.sv:addChildToBottom(cell:getPanel())
				table.insert(self.cells, cell)
			end
			if self.cardNum < num then
				print('updateScrollView')
				self:updateScrollView(self.datas, self.cells,self.cardNum + 1)
				self.cardNum = num
			end
		end)
		-- 我的主城id
		for k, v in pairs(LegionWar.legions) do
			if tonumber(k) == MyLegion.lid then
				self.myMainCityId = tonumber(v.city)
				break
			end
		end
	end)
end

function LegionWarCityPanel:update()
	self.datas = self.data.members
	-- 军团长排第一，副团长其次，剩下的按杀敌数排
	table.sort(self.datas, function (a, b)
		return tonumber(a.score) > tonumber(b.score)
	end)
	
	-- 判断是否可以迁徙
	self:canMoveTo()
	-- 判断是否可以领取体力
	self:canGetEnergy()
	for k, v in pairs(self.datas) do
		v.canChallenge = self.canChallenge
		v.isBoss = false
	end
	-- 判断该城池是否有boss
	self:canChallengeBoss()
	self:updateContent()
	self:addOrRemoveCard()
	self:updateScrollView(self.datas, self.cells)
	self.sv:scrollToTop()
end

function LegionWarCityPanel:canChallengeBoss()
	-- 如果我在当前城池
	if LegionWar.user.city == self.data.city then
		local bossData = {}
		local bossConf
		if self.data.city == self.myMainCityId then -- 如果当前城池是我的主城
			bossConf = LegionWarConfig:getLegionBattleBoss(2,LegionWar.legions[tostring(MyLegion.lid)].boss_id)
			bossData.name = GetTextForCfg(bossConf.Name)
			bossData.time = LegionWar.legions[tostring(MyLegion.lid)].boss
			bossData.isBoss = true
			bossData.score = bossConf.Score
			bossData.level = 1
		elseif self.data.city == 7 then -- 如果当前城池是洛阳城池
			bossConf = LegionWarConfig:getLegionBattleBoss(1,LegionWar.boss_id)
			bossData.name = GetTextForCfg(bossConf.Name)
			bossData.time = LegionWar.boss
			bossData.isBoss = true
			bossData.score = bossConf.Score
			bossData.level = 1
		else
			for k, v in pairs(LegionWar.near_city) do
				if self.data.city == tonumber(k) then
					bossData.time = tonumber(v.boss)
					bossConf = LegionWarConfig:getLegionBattleBoss(3,tonumber(v.boss_id))
					bossData.name = GetTextForCfg(bossConf.Name)
					bossData.isBoss = true
					bossData.score = bossConf.Score
					bossData.level = 1
					break
				end
			end
			if not bossData.isBoss then
				bossData = nil
			end
		end
		if bossData then
			self.haveBoss = true
			table.insert(self.datas, 1, bossData)
		else
			self.haveBoss = false
		end
	else
		self.haveBoss = false
	end
end
function LegionWarCityPanel:canMoveTo()
	local fieldCity = LegionWarConfig:getFieldCityByID(LegionWar.user.city)
	local borderFlag = false
	for k, v in pairs(fieldCity.City) do
		if self.data.city == tonumber(v) then
			borderFlag = true
			break
		end
	end
	self.canChallenge = false
	if borderFlag then -- 如果是临近城市
		if tonumber(LegionWar.occupy[tostring(self.data.city)]) == 0 or tonumber(LegionWar.occupy[tostring(self.data.city)]) == MyLegion.lid then -- 如果目标城池是空城或者被我方占领
			self.moveBtn:setVisible(true)
		else -- 如果目标城池被敌方占领
			self.canChallenge = true
			self.moveBtn:setVisible(false)
		end
	else
		self.moveBtn:setVisible(false)
	end
end

function LegionWarCityPanel:canGetEnergy()
	self.freeTimesTx:setVisible(false)
	self.energyBtn:setVisible(false)
	self.reviveCashIco:setVisible(false)
	self.reviveCashNumTx:setVisible(false)
	self.reviveTimesOverTx:setVisible(false)
	-- 当体力用完并且自己在主城里的时候才可以领取体力
	--print('-----------LegionWar.user.energy------------:' .. LegionWar.user.energy)
	if tonumber(LegionWar.user.energy) == 0 then
		if LegionWar.user.city == self.data.city and self.data.city == self.myMainCityId then
			local maxFreeRevive = tonumber(LegionConfig:getValueForKey('FreeReviveTimes'))
			if tonumber(LegionWar.user.free_revive) < maxFreeRevive then	-- 可以免费复活
				self.freeTimesTx:setVisible(true)
				self.freeTimesTx:setText(string.format(LegionConfig:getLegionLocalText('LEGION_REMAIN_TIMES'), maxFreeRevive - tonumber(LegionWar.user.free_revive)))
				self.energyBtn:setVisible(true)
				self.energyBtn:setText(LegionConfig:getLegionLocalText('LEGION_FREE_REVIVE'))
			else
				if tonumber(LegionWar.user.cash_revive) < self.maxCashReviveTimes then	-- 可以元宝复活
					local cashNum = LegionWarConfig:getPriceByTimes(LegionWar.user.cash_revive,'CashReviveWar')
					self.reviveCashIco:setVisible(true)
					self.reviveCashNumTx:setVisible(true)
					self.reviveCashNumTx:setText(tostring(cashNum))
					self.energyBtn:setVisible(true)
					self.energyBtn:setText(LegionConfig:getLegionLocalText('LEGION_CASH_REVIVE'))
				else
					self.reviveTimesOverTx:setVisible(true)
				end
			end
			
		end
	end
end

function LegionWarCityPanel:updateContent()
	local cityInfo = LegionWarConfig:getFieldCityByID(tonumber(self.data.city))
	if tonumber(self.data.city) == self.myMainCityId then --如果是我的主城
		print(LegionConfig:getValueForKey('MainCityAttBuff'))
		self.nameTx:setText(string.format(LegionConfig:getLegionLocalText('LEGION_MYMAINCITY'), GetTextForCfg(cityInfo.Name)))
		self.jiaTx:setText(string.format(LegionConfig:getLegionLocalText('LEGION_ATTACK_BUFF'), tonumber(LegionConfig:getValueForKey('MainCityAttBuff'))))
		self.jiaTx:setColor(COLOR_TYPE.GREEN)
		self.jiaTx:setVisible(true)
	elseif tonumber(self.data.city) == self.myMainCityId + 3 then --如果是我的附城
		self.nameTx:setText(string.format(LegionConfig:getLegionLocalText('LEGION_MYVICECITY'), GetTextForCfg(cityInfo.Name)))
		self.jiaTx:setText(string.format(LegionConfig:getLegionLocalText('LEGION_ATTACK_BUFF'), tonumber(LegionConfig:getValueForKey('ViceCityAttBuff'))))
		self.jiaTx:setColor(COLOR_TYPE.GREEN)
		self.jiaTx:setVisible(true)
	else
		self.nameTx:setText(GetTextForCfg(cityInfo.Name))
		self.jiaTx:setVisible(false)
	end
	
	if self.haveBoss then
		self.numberTx:setText(tostring(#self.data.members - 1))
	else
		self.numberTx:setText(tostring(#self.data.members))
	end
	-- 如果有人
	if LegionWar.legions[tostring(LegionWar.occupy[tostring(self.data.city)])] and tonumber(LegionWar.occupy[tostring(self.data.city)]) > 0 then
		self.legionNameTx:setText(LegionWar.legions[tostring(LegionWar.occupy[tostring(self.data.city)])].name)
	else
		self.legionNameTx:setText(LegionConfig:getLegionLocalText('LEGION_CITY_NO_LEGION'))
	end
	self.photoIco:setTexture(cityInfo.CityIcon)
end

function LegionWarCityPanel:addOrRemoveCard()
	-- 如果当前成员总数量小于5个 并且小于实际的成员数
	if self.cardNum < 5 and self.cardNum < #self.data.members then
		local num = (#self.data.members < 5 and #self.data.members) or 5
		num = #self.data.members
		for i = self.cardNum + 1, num do
			local cell = LegionWarCityCell.createCell()
			self.sv:addChildToBottom(cell:getPanel())
			table.insert(self.cells, cell)
		end
		self.cardNum = num
	elseif self.cardNum > #self.data.members then
		if #self.data.members == 0 then
			self.sv:removeAllChildrenAndCleanUp(true)
			self.cells = {}
		else
			local num  = self.cardNum - #self.data.members
			for i = 1, num do
				local cell = table.remove(self.cells)
				cell:getPanel():removeFromParentAndCleanup(true)
			end
			self.sv:resetChildrensPos()
		end
		self.cardNum = #self.data.members
	end
end

function LegionWarCityPanel:requestCityInfo()
	LegionWarController.sendLegionWarGetBattleFieldCityRequest(self.data.city, function ( res )
		local code = res.code
		if code == 0 then
			-- 更新城池界面
			res.data.city = tonumber(res.args.city)
			self:updateData(res.data)
			self:update()
		end
	end)
end

function LegionWarCityPanel:sendReviveRequest(isFree)
	LegionWarController.sendLegionWarGetEneryRequest(isFree, function ( res )
		local code = res.code
		if code == 0 then
			LegionWarController.sendLegionWarGetBattleFieldRequest(function ( res )
				local code = res.code
				if code == 0 then
					-- 更新战场主界面
					LegionWarBattlePanel:update()
					-- 更新city界面
					self:requestCityInfo()
				end
			end)
		end
	end)
end

function LegionWarCityPanel:release()
	LegionView.release(self)
	self.cells = nil
	self.moveBtn = nil
	self.energyBtn = nil
	self.photoIco = nil
	self.numberTx = nil
	self.legionNameTx = nil
	self.sv = nil
	self.cardNum = nil
	self.datas = nil
	self.canChallenge = nil
	self.freeTimesTx = nil
	self.maxCashReviveTimes = nil
	self.reviveCashIco = nil
	self.reviveCashNumTx = nil
	self.reviveTimesOverTx = nil
	self.myMainCityId = nil
	self.jiaTx = nil
	self.haveBoss = nil
end