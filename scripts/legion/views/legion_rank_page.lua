LegionRankPage = LegionPage:new{
	jsonFile = 'panel/legion_rank_bg_panel.json',
	panelName = 'legion-rank-bg-page',

	sv = nil,
	datas = {},
	cells = {}
}

function LegionRankPage:init()
	self.sv = tolua.cast(self.panel:getChildByName('rank_sv'), 'UIScrollView')
	self.sv:setClippingEnable(true)
	self.sv:removeAllChildrenAndCleanUp(true)

	self.cells = {}
	self.datas = MyLegion.rank_list
	for i = 1, #self.datas do
		local cell = LegionRankCell.createCell()
		self.sv:addChildToBottom(cell:getPanel())
		table.insert(self.cells, cell)
	end
	self:updateScrollView(self.datas, self.cells)
	self.sv:scrollToTop()
end

function LegionRankPage:update()
	self.datas = MyLegion.rank_list
	if #self.datas > #self.cells then
		local addNum = #self.datas - #self.cells
		for i = 1, addNum do
			local cell = LegionRankCell.createCell()
			self.sv:addChildToBottom(cell:getPanel())
			table.insert(self.cells, cell)
		end
	elseif #self.datas < #self.cells then
		local reduceNum = #self.cells - #self.datas
		for i = 1, reduceNum do
			local cell = table.remove(self.cells)
			cell:getPanel():removeFromParentAndCleanup(true)
		end
		self.sv:resetChildrensPos()
	end
	self:updateScrollView(self.datas, self.cells)
	self.sv:scrollToTop()
end

function LegionRankPage:release()
	LegionPage.release(self)
	self.sv = nil
	self.datas = nil
	self.cells = nil
end