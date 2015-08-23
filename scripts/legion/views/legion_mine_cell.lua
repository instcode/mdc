LegionMineCell = LegionCell:new{
	jsonFile = 'panel/legion_me_cell.json',

	fightForceTx = nil,
	LastTimeTx = nil,
	contributeTx = nil,
	lvNumTx = nil,
	nameTx = nil,
	postIco = nil,
	recallBtn = nil,
	resignBtn = nil,
	kickBtn = nil,
	buttonPl = nil,
	numberPl = nil,
	id = nil,
	position = nil
}


function LegionMineCell.createCell(datA)
	local cell = LegionMineCell:new{data = datA}
	cell:create()
	return cell
end

function LegionMineCell:init()
	self.lvNumTx = tolua.cast(self.panel:getChildByName('lv_num_tx'), 'UILabel')
	self.nameTx = tolua.cast(self.panel:getChildByName('name_tx'), 'UILabel')
	-- 职务标志
	self.postIco = tolua.cast(self.panel:getChildByName('post_ico'), 'UIImageView')
	self.numberPl = tolua.cast(self.panel:getChildByName('number_pl'), 'UIPanel')
	-- 战斗力
	self.fightForceTx = tolua.cast(self.numberPl:getChildByName('fightforce_num_tx'), 'UILabel')
	-- 杀敌
	self.LastTimeTx = tolua.cast(self.numberPl:getChildByName('last_time_tx'), 'UILabel')
	self.LastTimeTx:setPreferredSize(120,1)
	-- 贡献
	self.contributeTx = tolua.cast(self.numberPl:getChildByName('contribute_num_tx'), 'UILabel')

	self.buttonPl = tolua.cast(self.panel:getChildByName('button_pl'), 'UIPanel')
	--提升，罢免职务
	self.recallBtn = tolua.cast(self.panel:getChildByName('recall_tbtn'), 'UITextButton')
	GameController.addButtonSound(self.recallBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	self.recallBtn:registerScriptTapHandler(function ()
		local msgboxText = ''
		local position = ''
		if self.position == 'member' then
			local depNum = 0
			for k, v in pairs(MyLegion.members) do
				if v.position == 'deputycommander' then
					depNum = depNum + 1
				end
			end
			if depNum >= tonumber(LegionConfig:getValueForKey('ViceLimit')) then
				GameController.showPrompts(string.format(LegionConfig:getLegionLocalText('LEGION_DEPUTYCOMMANDER_MAX_COUNT'),tonumber(LegionConfig:getValueForKey('ViceLimit'))), COLOR_TYPE.RED)
				return
			end
			msgboxText = string.format(LegionConfig:getLegionLocalText('LEGION_CONFIRM_PROMOTION_DEPUTYCOMMANDER'),self.nameTx:getStringValue())
			position = 'deputycommander'
		elseif self.position == 'deputycommander' then
			msgboxText = string.format(LegionConfig:getLegionLocalText('LEGION_CONFIRM_DEMOTION_DEPUTYCOMMANDER'),self.nameTx:getStringValue())
			position = 'member'
		end
		GameController.showMessageBox(msgboxText, MESSAGE_BOX_TYPE.OK_CANCEL,function ()
			LegionController.sendLegionChangePosition(self.id, position, function (response)
				local code = tonumber(response.code)
				if code == 0 then
					local promptText = ''
					if self.position == 'member' then
						promptText = string.format(LegionConfig:getLegionLocalText('LEGION_PROMOTION_DEPUTYCOMMANDER'),self.nameTx:getStringValue())
					elseif self.position == 'deputycommander' then
						promptText = string.format(LegionConfig:getLegionLocalText('LEGION_DEMOTION_DEPUTYCOMMANDER'),self.nameTx:getStringValue())
					end
					--self.panel:setTouchEnable(true)
					--self.numberPl:setVisible(true)
					self.buttonPl:setVisible(false)
					GameController.showPrompts(promptText, COLOR_TYPE.GREEN)
					LegionMinePage:update()
				end
			end)
		end)
	end)
	-- 禅让
	self.resignBtn = tolua.cast(self.panel:getChildByName('resign_tbtn'), 'UITextButton')
	GameController.addButtonSound(self.resignBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	self.resignBtn:registerScriptTapHandler(function ()
		GameController.showMessageBox(string.format(LegionConfig:getLegionLocalText('LEGION_CONFIRM_PROMOTION_COMMANDER'),self.nameTx:getStringValue()), MESSAGE_BOX_TYPE.OK_CANCEL, function ()
			LegionController.sendLegionTransferRequest(self.id, function (response)
				local code = tonumber(response.code)
				if code == 0 then
					GameController.showPrompts(string.format(LegionConfig:getLegionLocalText('LEGION_CHANGE_COMMANDER_SUCCESS'),self.nameTx:getStringValue()), COLOR_TYPE.GREEN)
					LegionMinePage:update()
					LegionMainPanel:update()
				end
			end)
		end)
	end)
	-- 踢出军团
	self.kickBtn = tolua.cast(self.panel:getChildByName('quit_tbtn'), 'UITextButton')
	GameController.addButtonSound(self.kickBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	self.kickBtn:registerScriptTapHandler(function ()
		if LegionWar:isWaring() then -- 军团战期间不能踢人
			GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_CAN_NOT_OPERATE_DURING_WAR'), COLOR_TYPE.RED)
		else
			local str = string.format( LegionConfig:getLegionLocalText('LEGION_CONFIRM_MEMBER_WILL_KICKED') , tonumber(LegionConfig:getValueForKey('QuitLegionExpPenalty')) , self.nameTx:getStringValue())
			GameController.showMessageBox(str , MESSAGE_BOX_TYPE.OK_CANCEL,function ()
				LegionController.sendLegionKickRequest(self.id,function (response)
					local code = tonumber(response.code)
					if code == 0 then
						GameController.showPrompts(string.format(LegionConfig:getLegionLocalText('LEGION_MEMBER_KICKED'),self.nameTx:getStringValue()), COLOR_TYPE.GREEN)
						LegionMinePage:update()
					end
				end)
			end)
		end
	end)
	self.buttonPl:setVisible(false)
	self.panel:registerScriptTapHandler(function ()
		if tonumber(self.id) == tonumber(PlayerCoreData.getUID()) then

		else
			if self.buttonPl:isVisible() then
				self.buttonPl:setVisible(false)
				--self.numberPl:setVisible(true)
			else
				if MyLegion.position == 'member' then
					return
				elseif MyLegion.position == 'deputycommander' then
					self.recallBtn:setVisible(false)
					self.resignBtn:setVisible(false)
					self.kickBtn:setVisible(true)
					if self.position == 'commander' or self.position == 'deputycommander' then
						return
					end
				elseif MyLegion.position == 'commander' then
					self.recallBtn:setVisible(true)
					self.resignBtn:setVisible(true)
					self.kickBtn:setVisible(true)
				end

				if self.position == 'member' then
					self.recallBtn:setText(LegionConfig:getLegionLocalText('LEGION_PROMOTION'))
				elseif self.position == 'deputycommander' then
					self.recallBtn:setText(LegionConfig:getLegionLocalText('LEGION_DEMOTION'))
				end
				self.buttonPl:setVisible(true)
				--self.numberPl:setVisible(false)
				--self.panel:setTouchEnable(false)
				LegionMinePage:hideOtherCellButton(self.id)
			end
		end
		print('touch me')
	end)
end

local function DayDisPlay(serTime, lastTime)
	local str =''
	if lastTime == nil then
		return str
	else
		if tonumber(lastTime) == 0 then
			return str
		else
			local interval = (tonumber(Time.beginningOfToday() + 3600 * 24 ) - tonumber(lastTime)) / 3600
			-- local interval = (tonumber(serTime) - tonumber(lastTime)) / 3600 
				if interval < 24 then
				str = string.format(getLocalStringValue('E_STR_LAST_TIME_TODAY'), os.date("%H:%M", tonumber(lastTime)))
			elseif interval >= 24 and interval < 48 then
				str = string.format(getLocalStringValue('E_STR_LAST_TIME_YESTERDAY'), os.date("%H:%M", tonumber(lastTime)))
			elseif interval >= 48 and interval < 72 then
				str = string.format(getLocalStringValue('E_STR_LAST_TIME_BEFORE_YESTERDAY'), os.date("%H:%M", tonumber(lastTime)))
			elseif interval >= 72 and interval < 168 then
				str = string.format(getLocalStringValue('E_STR_LAST_TIME_THREE_DAY'))
			elseif interval >= 168 then
				str = string.format(getLocalStringValue('E_STR_LAST_TIME_WEEK'))		
			end
			return str
		end
	end
end

function LegionMineCell:update(data)
	local serverTime = UserData:getServerTime()
	-- 战斗力
	self.fightForceTx:setText(tostring(data.fight_force))
	-- 最后登录
	--self.LastTimeTx:setText(tostring(data.kill))
	self.LastTimeTx:setText(DayDisPlay(serverTime, data.last_login))
	-- 贡献
	self.contributeTx:setText(tostring(data.honor))
	-- 等级
	self.lvNumTx:setText(tostring(data.level))
	-- 名字
	self.nameTx:setText(tostring(data.name))
	-- 军团长图标
	self.postIco:setVisible(true)
	print(self.nameTx:getPosition().x)
	self.postIco:setPosition(ccp(self.nameTx:getPosition().x + self.nameTx:getContentSize().width/2 + 20,self.postIco:getPosition().y))
	if data.position == 'commander' then
		self.postIco:setTexture('uires/ui_2nd/com/panel/legion/president.png')
		self.postIco:setVisible(true)
	elseif data.position == 'deputycommander' then
		self.postIco:setTexture('uires/ui_2nd/com/panel/legion/president_vice.png')
		self.postIco:setVisible(true)
	else
		self.postIco:setVisible(false)
	end
	self.position = data.position
	--self.panel:setTouchEnable(true)
	--self.numberPl:setVisible(true)
	self.buttonPl:setVisible(false)
	self.id = data.id
end

function LegionMineCell:hideButon(id)
	if self.id ~= id then
		--self.numberPl:setVisible(true)
		self.buttonPl:setVisible(false)
		--self.panel:setTouchEnable(true)
	end
end

function LegionMineCell:release()
	LegionCell.release(self)
	self.fightForceTx = nil
	self.LastTimeTx = nil
	self.contributeTx = nil
	self.lvNumTx = nil
	self.nameTx = nil
	self.postIco = nil
	self.recallBtn = nil
	self.resignBtn = nil
	self.kickBtn = nil
	self.buttonPl = nil
	self.numberPl = nil
	self.id = nil
	self.position = nil
end