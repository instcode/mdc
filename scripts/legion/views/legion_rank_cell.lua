LegionRankCell = LegionCell:new{
	jsonFile = 'panel/legion_rank_cell.json',
	panelName = 'LegionRankCell',

	topIco = nil,
	rankTx = nil,
	junIco = nil,
	nameTx = nil,
	peopleTx = nil,
	lvTx = nil
}

function LegionRankCell.createCell(datA)
	local cell = LegionRankCell:new{data = datA}
	cell:create()
	return cell
end

function LegionRankCell:init()
	self.topIco = tolua.cast(self.panel:getChildByName('top_ico'), 'UIImageView')
	self.rankTx = tolua.cast(self.panel:getChildByName('rank_tx'), 'UILabel')
	self.junIco = tolua.cast(self.panel:getChildByName('jun_ico'), 'UIImageView')
	self.nameTx = tolua.cast(self.panel:getChildByName('name_tx'), 'UILabel')
	self.peopleTx = tolua.cast(self.panel:getChildByName('people_tx'), 'UILabel')
	self.lvTx = tolua.cast(self.panel:getChildByName('lv_tx'), 'UILabel')
end

function LegionRankCell:update(data)
	LegionCell.update(self, data)
	if data.rank >0 and data.rank < 4 then
		local texture = 'uires/ui_2nd/com/panel/trena/' .. data.rank .. '.png'
		self.topIco:setTexture(texture)
		self.topIco:setVisible(true)
	else
		self.topIco:setVisible(false)
	end
	local junTexture = 'uires/ui_2nd/com/panel/legion/' .. data.icon .. '_jun.png'
	self.junIco:setTexture(junTexture)
	self.rankTx:setText(tostring(data.rank))
	self.nameTx:setText(data.name)
	local peopleNumStr = string.format(getLocalStringValue('LEGION_MEMBER_COUNT'), data.members_count, LegionConfig:getLegionLevelData( data.level ).MemberMax)
	self.peopleTx:setText(peopleNumStr)
	local levelStr = 'Lv.' .. data.level
	self.lvTx:setText(levelStr)
end

function LegionRankCell:release()
	LegionCell.release(self)
	self.topIco = nil
	self.rankTx = nil
	self.junIco = nil
	self.nameTx = nil
	self.peopleTx = nil
	self.lvTx = nil
end