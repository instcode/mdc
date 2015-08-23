LegionMemberPage = LegionPage:new{
	jsonFile = 'panel/legion_member_bg_panel.json',
	panelName = 'legion-member-bg-page',

	sv = nil,
	datas = {},
	cells = {}
}

function LegionMemberPage:init()
	self.sv = tolua.cast(self.panel:getChildByName('info_sv'), 'UIScrollView')
	self.sv:setClippingEnable(true)
	self.sv:removeAllChildrenAndCleanUp(true)

	self.cells = {}
	self.datas = {}

	if MyLegion.applicant_list then
		print('########################## MyLegion.applicant_list ##########################')
		printall(MyLegion.applicant_list)
		print('########################## MyLegion.applicant_list ##########################')
		table.foreach(MyLegion.applicant_list , function (k, v)
			local tab = {}
			tab['uid'] = v.id
			tab['name'] = v.name
			tab['level'] = tonumber(v.level)
			tab['fightForce'] = tonumber(v.fightForce)
			table.insert(self.datas, tab)
		end)
	end

	for i = 1, #self.datas do
		local cell = LegionMemberCell.createCell()
		self.sv:addChildToBottom(cell:getPanel())
		table.insert(self.cells, cell)
	end
	self:updateScrollView(self.datas, self.cells)

	self:registerBtnEvent()
	self.sv:scrollToTop()
end

function LegionMemberPage:registerBtnEvent()
	for i = 1, #self.cells do
		self.cells[i]:getPassBtn():registerScriptTapHandler(function ()
			self:onClickPass( i )
		end)

		self.cells[i]:getRefuseBtn():registerScriptTapHandler(function ()
			self:onClickRefuse( i )
		end)
	end
end

-- 通过申请
function LegionMemberPage:onClickPass( index )
	print(' pass index = ' .. index)

	if LegionWar:isWaring() then
		GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_CAN_NOT_OPERATE_DURING_WAR') , COLOR_TYPE.RED)
		return
	end

	local max = LegionConfig:getLegionLevelData( MyLegion.level ).MemberMax
	local current = #MyLegion.members

	if tonumber(current) >= tonumber(max) then
		GameController.showPrompts(LegionConfig:getLegionLocalText('E_STR_LEGION_PEOPLE_FULL_DESC') , COLOR_TYPE.RED )
		return
	end

	if self.datas[index] == nil then
		return
	end

	LegionController.sendLegionApproveJoinRequest( self.datas[index]['uid'], function () 
		if self:removeItem( index ) then
			GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_PASS_APPLICATION') , COLOR_TYPE.GREEN )
			print('PASS APPLICANT ...')
		end
	end)
end

-- 拒绝申请
function LegionMemberPage:onClickRefuse( index )
	print(' refuse index = ' .. index)
	if self.datas[index] == nil then
		return
	end

	LegionController.sendLegionRejectJoinRequest( self.datas[index]['uid'], function ()
		if self:removeItem( index ) then
			print('REFUSE APPLICANT ...')
		end
	end)
end

function LegionMemberPage:removeItem( index )
	if not self.cells[index] then
		return false
	end

	local count = #self.cells
	self.cells[index]:getPanel():removeFromParentAndCleanup(false)

	table.remove(self.cells , index)
	table.remove(self.datas , index)

	self.sv:resetChildrensPos()
	self:registerBtnEvent()
	if index <= 1 then
		self.sv:scrollToTop()
	elseif count - index <= 4 then
		self.sv:scrollToBottom()
	end
	
	return true
end

function LegionMemberPage:release()
	print('LegionMemberPage release ...')
	LegionPage.release(self)
	self.sv = nil
	self.datas = nil
	self.cells = nil
end