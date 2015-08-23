LegionActivityCell = LegionCell:new{
	jsonFile = 'panel/legion_activity_cell.json',
	activity_btn = nil,
	acitvity_name = nil,
	acitvity_ico = nil,
	activity_limit_tx = nil,
	activity_noti = nil,
	activityDesc1 = nil,
	activityDesc2 = nil,
	activityKuang = nil,
}


function LegionActivityCell.createCell(datA)
	local cell = LegionActivityCell:new{data = datA}
	cell:create()
	return cell
end

function LegionActivityCell:init()
   self.acitvity_ico = tolua.cast(self.panel:getChildByName('photo_ico'),'UIImageView')
   self.acitvity_name = tolua.cast(self.panel:getChildByName('title_txt_ico'),'UIImageView')
   self.acitvity_limit_tx = tolua.cast(self.panel:getChildByName('unlock_tx'),'UITextArea')
   self.acitvity_noti = tolua.cast(self.panel:getChildByName('tips_icon'),'UIImageView')
   self.activity_btn = tolua.cast(self.panel:getChildByName('activity_btn'),'UIButton')
   self.activityDesc1 = tolua.cast(self.panel:getChildByName('info_1_tx'),'UILabel')
   self.activityDesc2 = tolua.cast(self.panel:getChildByName('Label_Clone'),'UILabel')
   GameController.addButtonSound(self.activity_btn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
   self.activityKuang = tolua.cast(self.panel:getChildByName('kuang_ico'),'UIImageView')
   self.activityDesc1:setPreferredSize(210,1)
   self.activityDesc2:setPreferredSize(210,1)
end

function LegionActivityCell:getBtn()
	return self.activity_btn
end

function LegionActivityCell:shake()
    local mov1 = CCRotateBy:create(0.1, 10)
    local mov2 = CCRotateBy:create(0.1, -20)
    local actArr = CCArray:create()
    for i = 1, 3 do
        actArr:addObject(mov1)
        actArr:addObject(mov1:reverse())
        actArr:addObject(mov2)
        actArr:addObject(mov2:reverse())
    end
    actArr:addObject(CCDelayTime:create(0.2))

    return CCRepeatForever:create(CCSequence:create(actArr))
end

function LegionActivityCell:update(data)
	local Urlname ='uires/ui_2nd/com/panel/'.. data.Title
	local UrlIcon ='uires/ui_2nd/com/panel/' .. data.Icon
	self.acitvity_name:setTexture(Urlname)
	self.acitvity_ico:setTexture(UrlIcon)
	self.activityDesc1:setText(GetTextForCfg(data.Des1))
	self.activityDesc2:setText(GetTextForCfg(data.Des2))
	local  str =string.format(LegionConfig:getLegionLocalText('E_STR_LEGION_ACTIVITY_OPEN'), tonumber(data.LegionLevelLimit))
	self.acitvity_limit_tx:setText(str)

	if tonumber(MyLegion.level) < tonumber(data.LegionLevelLimit) then
		self.activity_btn:setTouchEnable(false)
		self.activity_btn:setPressState(WidgetStateDisabled)
		self.acitvity_ico:setGray()
		self.acitvity_limit_tx:setVisible(true)
		self.acitvity_noti:stopAllActions()
		self.acitvity_noti:setVisible(false)
		self.activityKuang:setGray()
		--self.activityDesc1:setGray()
		--self.activityDesc2:setGray()
		self.acitvity_name:setGray()
		--self.acitvity_limit_tx:setGray()
	else
		self.activity_btn:setTouchEnable(true)
		self.activity_btn:setPressState(WidgetStateNormal)
		self.acitvity_limit_tx:setVisible(false)


		self.acitvity_noti:stopAllActions()
		self.acitvity_noti:setRotation(-20)
		self.acitvity_noti:runAction(LegionActivityCell:shake())
		if tonumber(data.Time) > 0 then
			if tostring(data.Key) == 'pray' then
				local remainTimes = 0
				local maxTimes =LegionConfig:getValueForKey('PrayTime')
				local time1 = UserData:convertTime(2 , MyLegion:getMyData().pray_date)
				local time2 = Time.beginningOfToday()

				if time1 < time2 then
					remainTimes = maxTimes
				else
					remainTimes = maxTimes - MyLegion:getMyData().pray_count
				end
				local time =tonumber(remainTimes)
				if remainTimes <= 0 then
					self.acitvity_noti:stopAllActions()
					self.acitvity_noti:setVisible(false)
				end
			end
			if tostring(data.Key) == 'kill' then
				self.acitvity_noti:stopAllActions()
				self.acitvity_noti:setVisible(false)
			end
			--todo timelimit
		else
			self.acitvity_noti:stopAllActions()
			self.acitvity_noti:setVisible(false)
		end
	end

end

function LegionActivityCell:release()
	LegionCell.release(self)
	self.activity_btn = nil
	self.acitvity_name = nil
	self.acitvity_ico = nil
	self.activity_limit_tx = nil
	self.activity_noti = nil
end

