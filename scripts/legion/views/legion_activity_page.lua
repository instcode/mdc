LegionActivityPage = LegionPage:new{
	jsonFile = 'panel/legion_activity_bg_panel.json',

	sv = nil,
	datas = {},
	cells = {}
}


function LegionActivityPage:init()
	self.sv = tolua.cast(self.panel:getChildByName('activity_sv'), 'UIScrollView')
	self.sv:setClippingEnable(true)
	local count = LegionConfig:getActivitiesCount()
	for i = 1, tonumber(count) do
		self.datas[i] = {}
		self.datas[i] = LegionConfig:getactivitiesDataByKey(i)
		--printall(LegionConfig:getactivitiesDataByKey(i))
		local cell = LegionActivityCell.createCell()
		self.sv:addChildToRight(cell:getPanel())
		self.sv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
		table.insert(self.cells, cell)
	end

	self:registerBtnEvent()
	self:updateScrollView(self.datas, self.cells)
	self.sv:scrollToTop()
end

function LegionActivityPage:onClickgoBtn(index)
	if LegionConfig:getactivitiesDataByKey(index).Key == 'pray' then
		LegionController.show(LegionPrayingPanel, ELF_SHOW.SLIDE_IN)
	elseif LegionConfig:getactivitiesDataByKey(index).Key == 'battle' then
		LegionWarController.enter()
	elseif LegionConfig:getactivitiesDataByKey(index).Key == 'kill' then
        KillRole.enter()
	end
end
function LegionActivityPage:registerBtnEvent()
	for i = 1, #self.cells do
		self.cells[i]:getBtn():registerScriptTapHandler(function ()
			self:onClickgoBtn( i )
		end)
	end
end

function LegionActivityPage:release()
	LegionPage.release(self)

	self.sv = nil
end
function LegionActivityPage:update()
	self:updateScrollView(self.datas, self.cells)
end