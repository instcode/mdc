LegionMinePage = LegionPage:new{
	jsonFile = 'panel/legion_me_panel.json',
	panelName = 'legion-me-panel',

	datas = nil,
	cells = nil,
	infoSv = nil,
	cardNum = nil,
	tempButtonPl = nil,
	tempNumberPl = nil,
	tempMemberInfo = nil
}

function LegionMinePage:init()
	self.datas = {}
	self.cells = {}

	local infoBigBgImg = tolua.cast(self.panel:getChildByName('info_big_bg_img'), 'UIImageView')
	
	local playerInfoBgImg = tolua.cast(infoBigBgImg:getChildByName('player_info_bg_img'), 'UIImageView')
	self.infoSv = tolua.cast(playerInfoBgImg:getChildByName('info_sv'), 'UIScrollView')
	self.infoSv:setClippingEnable(true)
	self.infoSv:setDirection(SCROLLVIEW_DIR_VERTICAL)

	self.cardNum = (#MyLegion.members < 5 and #MyLegion.members) or 5
	for i = 1, self.cardNum do
		local cell = LegionMineCell.createCell()
		self.infoSv:addChildToBottom(cell:getPanel())
		table.insert(self.cells, cell)
	end
	
	self.infoSv:registerScrollToBottomEvent(function()
		local num = (self.cardNum + 5 < #MyLegion.members and self.cardNum + 5) or #MyLegion.members
		print('num = ' .. num)
		print('MyLegion.members = ' .. #MyLegion.members)
		for i = self.cardNum + 1, num do
			local cell = LegionMineCell.createCell()
			self.infoSv:addChildToBottom(cell:getPanel())
			table.insert(self.cells, cell)
		end
		if self.cardNum < num then
			print('updateScrollView')
			self:updateScrollView(self.datas, self.cells,self.cardNum + 1)
			self.cardNum = num
		end
	end)
end

function LegionMinePage:update()
	-- if #self.datas ~= #MyLegion.members then
		self.datas = MyLegion.members
	-- end
	-- 军团长排第一，副团长其次，剩下的按杀敌数排
	table.sort(self.datas, function (a, b)
		if a.position == 'commander' then
			return true
		else
			if b.position == 'commander' then
				return false
			else
				if a.position == 'deputycommander' then
					if b.position == 'deputycommander' then
						return false
					else
						return true
					end
				else
					if b.position == 'deputycommander' then
						return false
					else
						return tonumber(a.kill) > tonumber(b.kill)
					end
				end
			end
		end
	end)
	LegionMinePage:addOrRemoveCard()
	self:updateScrollView(self.datas, self.cells)
	self.infoSv:scrollToTop()
end

function LegionMinePage:hideOtherCellButton(id)
	for k, v in pairs(self.cells) do
		v:hideButon(id)
	end
end

function LegionMinePage:addOrRemoveCard()
	print('self.cardNum = ' .. self.cardNum)
	print('#MyLegion.members = ' .. #MyLegion.members)
	-- 如果当前成员总数量小于5个 并且小于实际的成员数
	if self.cardNum < 5 and self.cardNum < #MyLegion.members then
		local num = (#MyLegion.members < 5 and #MyLegion.members) or 5
		num = #MyLegion.members
		for i = self.cardNum + 1, num do
			local cell = LegionMineCell.createCell()
			self.infoSv:addChildToBottom(cell:getPanel())
			table.insert(self.cells, cell)
		end
		self.cardNum = num
	elseif self.cardNum > #MyLegion.members then
		if #MyLegion.members == 0 then
			self.infoSv:removeAllChildrenAndCleanUp(true)
			self.cells = {}
		else
			local num  = self.cardNum - #MyLegion.members
			for i = 1, num do
				local cell = table.remove(self.cells)
				cell:getPanel():removeFromParentAndCleanup(true)
			end
			self.infoSv:resetChildrensPos()
		end
		self.cardNum = #MyLegion.members
	end
end

function LegionMinePage:release()
	LegionPage:release(self)
	self.datas = nil
	self.cells = nil
	self.infoSv = nil
	self.cardNum = nil
	self.tempButtonPl = nil
	self.tempNumberPl = nil
	self.tempMemberInfo = nil
end