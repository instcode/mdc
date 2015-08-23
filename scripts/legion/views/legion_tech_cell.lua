LegionTechCell = LegionCell:new{
	jsonFile = 'panel/legion_tech_cell.json',
	panelName = 'LegionTechCell',
	techName = nil,
	techlv = nil,
	techDesc = nil,
	number_tx = nil,
	cellbg = nil,
	tech_ico = nil,
	need_ico = nil,
	datas = nil,
	upgrade_tbtn = nil,
	max_tx = nil,
}

function LegionTechCell.createCell(datA)
	local cell = LegionTechCell:new{data = datA}
	cell:create()
	return cell
end

function LegionTechCell:init()
	self.techName = tolua.cast(self.panel:getChildByName('tech_name_tx'), 'UILabel')
	self.techlv = tolua.cast(self.panel:getChildByName('lv_tx'), 'UILabel')
	self.techDesc = tolua.cast(self.panel:getChildByName('info_ta'), 'UITextArea')
	self.number_tx = tolua.cast(self.panel:getChildByName('number_tx'), 'UILabel')
	self.tech_ico = tolua.cast(self.panel:getChildByName('tech_ico'), 'UIImageView')
	self.need_ico = tolua.cast(self.panel:getChildByName('need_ico'), 'UIImageView')
	self.upgrade_tbtn = tolua.cast(self.panel:getChildByName('upgrade_tbtn'), 'UITextButton')
	self.max_tx = tolua.cast(self.panel:getChildByName('max_lv_tx'), 'UILabel')
	GameController.addButtonSound(self.upgrade_tbtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
end

function LegionTechCell:getUpBtn()
	return self.upgrade_tbtn
end

function LegionTechCell:update(data)
	self.datas =LegionConfig:getTechDataByKeyandLv(data.id,data.level)
	--cclog("LegionTechCell,update")
	--LegionCell.update(self, data)
	self.techName:setText(GetTextForCfg(self.datas.Name))
	self.techlv:setText('Lv' .. self.datas.Level)
	self.number_tx:setText(tostring(self.datas.MaterialNum))
	self.techDesc:setText(GetTextForCfg(self.datas.Desc1))
	local TechUrlResource = 'uires/ui_2nd/image/' .. self.datas.TechUrl
	self.tech_ico:setTexture(TechUrlResource)
	self.need_ico:setTexture('uires/ui_2nd/com/panel/legion/science_stone.png')
	-- TODO: self.techName:setText('xxx')
	--self.upgrade_tbtn:setZOrder(99)


	if tonumber(self.datas.Level) < tonumber(LegionConfig:getTechDataTechLv(self.datas.Id)) then
		self.upgrade_tbtn:setVisible(true)
		self.need_ico:setVisible(true)
		self.number_tx:setVisible(true)
	else
		self.upgrade_tbtn:setVisible(false)
		self.need_ico:setVisible(false)
		self.number_tx:setVisible(false)
	end

	if tonumber(self.datas.Level) < tonumber(MyLegion.level) then
		self.upgrade_tbtn:setTouchEnable(true)
		self.upgrade_tbtn:setPressState(WidgetStateNormal)
	else
		self.upgrade_tbtn:setTouchEnable(false)
		self.upgrade_tbtn:setPressState(WidgetStateDisabled)
	end	

	if MyLegion.position == 'member' then
		self.upgrade_tbtn:setVisible(false)
		self.max_tx:setVisible(false)
	else
		self.max_tx:setVisible(true)
	end	
	
end

function LegionTechCell:release()
	LegionCell.release(self)
	self.panelName = nil
	self.techName = nil
	self.techlv = nil	
	self.techDesc = nil
	self.number_tx = nil	
	self.finish_tbtn = nil
	self.tech_ico = nil
	self.need_ico = nil
	self.datas = nil
end