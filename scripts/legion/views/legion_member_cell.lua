LegionMemberCell = LegionCell:new{
	jsonFile = 'panel/legion_member_cell.json',
	panelName = 'LegionMemberCell',

	lvTx = nil,
	nameTx = nil,
	fightTx = nil,
	passBtn = nil,
	refuseBtn = nil
}


function LegionMemberCell.createCell(datA)
	local cell = LegionMemberCell:new{data = datA}
	cell:create()
	return cell
end

function LegionMemberCell:init()
	self.lvTx = tolua.cast(self.panel:getChildByName('lv_num_tx'), 'UILabel')
	self.nameTx = tolua.cast(self.panel:getChildByName('player_name_tx'), 'UILabel')
	self.fightTx = tolua.cast(self.panel:getChildByName('fighting_num_tx'), 'UILabel')
	self.passBtn = tolua.cast(self.panel:getChildByName('pass_tbtn'), 'UIButton')
	self.refuseBtn = tolua.cast(self.panel:getChildByName('veto_btn'), 'UIButton')

	GameController.addButtonSound(self.passBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	GameController.addButtonSound(self.refuseBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
end


function LegionMemberCell:getPassBtn()
	return self.passBtn
end

function LegionMemberCell:getRefuseBtn()
	return self.refuseBtn
end

function LegionMemberCell:update(data)
	LegionCell.update(self, data)
	self.lvTx:setTextFromInt(data.level)
	self.nameTx:setText(data.name)
	self.fightTx:setTextFromInt(data.fightForce)
end