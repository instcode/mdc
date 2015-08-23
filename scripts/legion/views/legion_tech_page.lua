LegionTechPage = LegionPage:new{
	jsonFile = 'panel/legion_tech_bg_panel.json',

	sv = nil,
	datas = {},
	cells = {}
}


function LegionTechPage:init()
	self.sv = tolua.cast(self.panel:getChildByName('tech_sv'), 'UIScrollView')
	self.sv:setClippingEnable(true)
	
	self:updateDatas()

	for i = 1, #MyLegion.techs do
		local cell = LegionTechCell.createCell()
		self.sv:addChildToBottom(cell:getPanel())
		table.insert(self.cells, cell)
	end
	self:registerBtnEvent()
	self:updateScrollView(self.datas, self.cells)
	self.sv:scrollToTop()
end

function LegionTechPage:updateScrollView( datas, cells )
	LegionView.updateScrollView(self, datas, cells)
end

function LegionTechPage:release()
	LegionPage.release(self)
	sv =nil
end

function LegionTechPage:onClickUpBtn(index)
	--todo 
--	cclog('LegionTechPage:onClickUpBtn')
	LegionTechUpgradePanel:showWithData( self.datas[index] )
end
function LegionTechPage:registerBtnEvent()
	for i = 1, #self.cells do
		self.cells[i]:getUpBtn():registerScriptTapHandler(function ()
			self:onClickUpBtn( i )
		end)
	end
end
function LegionTechPage:update()
	self:updateDatas()
	LegionTechPage:updateScrollView( self.datas, self.cells )
end

function LegionTechPage:updateDatas()
	self.datas = {}
	table.foreach(MyLegion.techs, function ( id, level )
		local tech = {
			id = id,
			level = level
		}

		table.insert(self.datas, tech)
	end)
end