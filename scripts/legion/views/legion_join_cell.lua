LegionJoinCell = LegionCell:new{
	jsonFile = 'panel/legion_join_cell.json',

	junIco = nil,
	nameTx = nil,
	infoTx = nil,
	peopleNumTx = nil,
	lvLimitTx = nil,
	joinBtn = nil,
	lid = nil
}


function LegionJoinCell.createCell(datA)
	local cell = LegionJoinCell:new{data = datA}
	cell:create()
	return cell
end

function LegionJoinCell:init()
	self.junIco = tolua.cast(self.panel:getChildByName('jun_ico'), 'UIImageView')
	self.nameTx = tolua.cast(self.panel:getChildByName('name_tx'), 'UILabel')
	self.infoTx = tolua.cast(self.panel:getChildByName('info_tx'), 'UILabel')
	self.peopleNumTx = tolua.cast(self.panel:getChildByName('people_num_tx'), 'UILabel')
	self.lvLimitTx = tolua.cast(self.panel:getChildByName('lv_limit_tx'), 'UILabel')
	self.joinBtn = tolua.cast(self.panel:getChildByName('join_btn'), 'UITextButton')
	GameController.addButtonSound(self.joinBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	-- 申请加入公会按钮
	self.joinBtn:registerScriptTapHandler(function ()
		print(self.lid)
		if LegionWar:isWaring() then
			GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_CAN_NOT_OPERATE_DURING_WAR') , COLOR_TYPE.RED)
			return
		else
			local isApplicant = false
			for k, v in pairs(MyLegion.applicant_id) do
				if self.lid == tonumber(v) then
					isApplicant = true
				end
			end
			if isApplicant then
				-- 取消申请
				print('取消申请')
				LegionController.sendLegionCancelJoinRequest(self.lid, function (response)
					print(response)
					local code = tonumber(response.code)
					if code == 0 then
						-- 刷新界面
						LegionJoinPage:refreshPanel()
					end 
				end)
			else
				-- 申请加入
				print('申请加入')
				local leaveTime = UserData:getServerTime() - MyLegion.leave_time
				if leaveTime < tonumber(LegionConfig:getValueForKey('JoinTimeLimit')) then
					GameController.showPrompts(string.format(LegionConfig:getLegionLocalText('LEGION_CAN_NOT_JOIN_QUIT_RECENTLY'), tonumber(LegionConfig:getValueForKey('JoinTimeLimit'))/3600), COLOR_TYPE.RED)
				else
					LegionController.sendLegionJoinRequest(self.lid, function (response)
						print(response)
						local code = tonumber(response.code)
						if code == 0 then
							-- 刷新界面
							if MyLegion.lid > 0 then
								LegionController.close(LegionCreateRootPanel, ELF_HIDE.HIDE_NORMAL)
								LegionController.show(LegionMainPanel, ELF_SHOW.NORMAL)
							else
								LegionJoinPage:refreshPanel()
							end
						end 
					end)
				end
			end
		end	
	end)
end

function LegionJoinCell:update(data)
	local badgeResource = 'uires/ui_2nd/com/panel/legion/' .. data.icon .. '_jun.png'
	self.junIco:setTexture(badgeResource)
	self.nameTx:setText(tostring(data.name))
	self.infoTx:setText(data.notice)
	self.peopleNumTx:setText(data.members_count .. '/' .. LegionConfig:getLegionLevelData(data.level).MemberMax)
	self.joinBtn:active()
	if tonumber(data.members_count) == tonumber(LegionConfig:getLegionLevelData(data.level).MemberMax) then
		self.peopleNumTx:setColor(COLOR_TYPE.RED)
		self.joinBtn:disable()
	else
		self.peopleNumTx:setColor(COLOR_TYPE.WHITE)
	end
	self.lvLimitTx:setText(string.format(LegionConfig:getLegionLocalText('LEGION_NEED_MONARCH_LEVEL'), data.level_limit))
	self.lid = data.lid

	local isApplicant = false
	for k, v in pairs(MyLegion.applicant_id) do
		if self.lid == tonumber(v) then
			isApplicant = true
			self.joinBtn:setVisible(true)
	 		self.joinBtn:active()
			self.joinBtn:setText(LegionConfig:getLegionLocalText('LEGION_CANCEL_JOIN'))
			break
		end
	end
	if isApplicant == false then	-- 如果这个军团我没有申请过
		if #MyLegion.applicant_id == 3 then	-- 如果已经申请满3个军团就隐藏其他军团的申请按钮
			self.joinBtn:setVisible(false)
			self.joinBtn:setText(LegionConfig:getLegionLocalText('LEGION_APPLY_JOIN'))
		else
			if tonumber(data.level_limit) > PlayerCoreData.getPlayerLevel() then
				self.joinBtn:disable()
			end
			if tonumber(data.type) == 0 then -- 不需要批准
				self.joinBtn:setText(LegionConfig:getLegionLocalText('LEGION_IMMEDIATELY_JOIN'))
			elseif tonumber(data.type) == 1 then -- 需要批准
				self.joinBtn:setText(LegionConfig:getLegionLocalText('LEGION_APPLY_JOIN'))
			end
			self.joinBtn:setVisible(true)
		end
	end
end

function LegionJoinCell:release()
	LegionCell.release(self)
	self.junIco = nil
	self.nameTx = nil
	self.infoTx = nil
	self.peopleNumTx = nil
	self.lvLimitTx = nil
	self.joinBtn = nil
	self.lid = nil
end