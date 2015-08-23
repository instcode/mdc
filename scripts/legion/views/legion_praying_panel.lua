LegionPrayingPanel = LegionView:new{
	jsonFile 				= 'panel/legion_praying_panel.json',
	panelName 				= 'legion-praying-panel',
	prayplbg 				= nil,    		-- 祈福转盘界面
	prayleftnum_tx 			= nil,	  		-- 祈福剩余次数
	prayneedlghonor_tx 		= nil,    		-- 祈福所需军团贡献
	praycurhavelghonor_tx	= nil,    		-- 当前所拥有的军团贡献
	praymayaward 			= {},	  		-- 转盘上的8个奖励
	prayArrow				= nil,    		-- 转盘箭头
	praycloseBtn			= nil,    		-- 祈福界面关闭按钮
	prayplBtn				= nil,			-- 祈福按钮
	scheduleId 				= nil,			-- scheduleScriptFunc id
	millisecond 			= nil,
	speedByTime 			= nil,			-- 箭头转动的速度
	endRotation 			= nil,			-- 最终转动的圈数
	endRotate 				= nil,			-- 最终转动的角度
	beadPos 				= 1,			-- 此次戳到的奖励
	beadOriginPos			= nil,
	PRAY_AWARD_COUNT		= 8,			--转盘上奖励个数
	awardStr                = nil,			--实际得到奖励
	allawards				= {},			--关闭界面时得到的总奖励
	praytimes				= 0,			--抽奖次数
	times					= nil,			--祈福次数
	speed                   = nil,
}
--设置数据
function LegionPrayingPanel:parytitaninit(num,needlghonor,curlghonor)
	self.prayleftnum_tx:setText(num)
	self.prayneedlghonor_tx:setText(needlghonor)
	self.praycurhavelghonor_tx:setText(curlghonor)
end
--初始化奖励
function LegionPrayingPanel:paryinit(straward)
	for i=1,self.PRAY_AWARD_COUNT do
		--local straward =getBattleDropDataByIndex(nBid,i)
		local award = UserData:getAward(straward[i])

		local strBuffer ='photo_'..tostring(i)..'_ico'
		local bg = tolua.cast(self.prayplbg:getChildByName(strBuffer),'UIImageView')
		self.praymayaward[i] = {}
		self.praymayaward[i].background = bg
		self.praymayaward[i].icon = tolua.cast(bg:getChildByName('thing_ico'),'UIImageView')
		self.praymayaward[i].background:registerScriptTapHandler(function ()
			--local awardStr = award
			UISvr:showTipsForAward(straward[i])
		end)
		--arrAward[i].name = tolua.cast(bg:getChildByName('award_name_tx'),'UILabel')
		self.praymayaward[i].num = tolua.cast(bg:getChildByName('number_tx'),'UILabel')
		if string.len(tostring(award) ) ~= 0 then	
			self.praymayaward[i].icon:setTexture(award['icon']);
			self.praymayaward[i].icon:setAnchorPoint(ccp(0.5, 0.5));
			self.praymayaward[i].namestr=(award['name'])
			self.praymayaward[i].numstr=(award['count'])
			self.praymayaward[i].awardsstr =straward[i]
			--arrAward[i].name:setColor(award['color']);
			self.praymayaward[i].num:setTextFromInt(award['count']);
			self.praymayaward[i].background:setVisible(true);
			self.praymayaward[i].background:setWidgetTag(100 + i);
		else
			self.praymayaward[i].background:setVisible(false);
		end
	end
end
--刷新状态
function LegionPrayingPanel:update()
	local remainTimes =0
	local maxTimes =LegionConfig:getValueForKey('PrayTime')
	local time1 = UserData:convertTime(2 , MyLegion:getMyData().pray_date)
	local time2 = Time.beginningOfToday()
	if tonumber(time1) == 0 or tonumber(time1) ~= tonumber(time2) then
		remainTimes = maxTimes
	else

		remainTimes = maxTimes - MyLegion:getMyData().pray_count
	end
	local cost = tonumber(LegionConfig:getValueForKey('HonorPray'))
	local honor = MyLegion:getMyData().honor
	LegionPrayingPanel:parytitaninit(remainTimes,cost,honor)
	local award={}
	local praydate =LegionConfig:getPrayData(1)
	for i =1, self.PRAY_AWARD_COUNT do
		award[i] ={}
		award[i] =praydate['Award' .. i]
	end
	LegionPrayingPanel:paryinit(award)
end
--锁定按钮
function LegionPrayingPanel:lockPanel()
	self.prayplBtn:setTouchEnable(false)
	self.prayplBtn:setPressState(WidgetStateDisabled)
	self.praycloseBtn:setTouchEnable(false)
	self.praycloseBtn:setPressState(WidgetStateDisabled)
	for i=1,self.PRAY_AWARD_COUNT do
		self.praymayaward[i].background:setTouchEnable(false)
	end
end
--解锁按钮
function LegionPrayingPanel:unlockPanel()
	self.prayplBtn:setTouchEnable(true)
	self.prayplBtn:setPressState(WidgetStateNormal)
	self.praycloseBtn:setTouchEnable(true)
	self.praycloseBtn:setPressState(WidgetStateNormal)
	for i=1,self.PRAY_AWARD_COUNT do
		self.praymayaward[i].background:setTouchEnable(true)
	end
end
function LegionPrayingPanel:showAward()

	GameController.showPrompts(self.awardStr,COLOR_TYPE.GREEN)
end
local function showAd()
	LegionPrayingPanel:showAward()
end
--动作结束
function LegionPrayingPanel:ActionEnd()
	if self.scheduleId ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = nil
	end
	self.prayArrow:stopAllActions()

	local actionOver = CCCallFunc:create(showAd)
	local arr = CCArray:create()
	arr:addObject(actionOver)
	local seq = CCSequence:create(arr)
	self.prayArrow:runAction(seq)
	LegionPrayingPanel:unlockPanel()
end

function LegionPrayingPanel:turnWheel()
	local rotation = self.prayArrow:getRotation()
	rotation = rotation/360
	self.millisecond = self.millisecond + 0.1
	if rotation < 3 then
		self.speedByTime = self.millisecond*self.millisecond*0.3
	elseif rotation >= 3 and rotation < 8 then
		self.speedByTime = 2.5
	elseif rotation >= 8 and rotation < self.endRotate/360 then
		self.speedByTime = self.endRotation - rotation
	end
	self.speed = self.prayArrow:getActionByTag(100)
	if self.speedByTime ~= nil then
	--	print(type(self.speedByTime))
		self.speed:setSpeed(self.speedByTime)
	end
	if rotation > self.endRotate/360 then
		LegionPrayingPanel:ActionEnd()
	end
end
local function actionend()
 	LegionPrayingPanel:ActionEnd()
end
local function turnwl()
	LegionPrayingPanel:turnWheel()
end
--旋转
function LegionPrayingPanel:Rotation()
	LegionPrayingPanel:lockPanel()
	self.endRotate = 3600 + 45 * (self.beadPos-1)
	local rotate = CCRotateBy:create(8, self.endRotate)
	self.endRotation = self.endRotate/360 + 0.1
	local actionOver = CCCallFunc:create(actionend)
		local arr = CCArray:create()
	arr:addObject(rotate)
	arr:addObject(actionOver)
	local seq = CCSequence:create(arr)
	self.speed = CCSpeed:create(seq, 1)
	self.speed:setTag(100)
	self.prayArrow:runAction(self.speed)
	self.millisecond = 1
	self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(turnwl,0.1,false)
	turnwl()
end
--点击祈福
function LegionPrayingPanel:ClickBtn()
	local time = tonumber(LegionConfig:getValueForKey('PrayTime')) -tonumber(MyLegion:getMyData()['pray_count'])
	local cost = tonumber(LegionConfig:getValueForKey('HonorPray'))
	local honor = MyLegion:getMyData().honor
	if honor < cost then
	 	GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_PRAY_NO_HONOR'),COLOR_TYPE.RED)
	else
		if MyLegion:isCanPrayToday() then
			LegionController.sendLegionPrayRequest(function (response)
				printall(response)
				local code = tonumber(response.code)
				if tonumber(code) == 0 then
					LegionPrayingPanel:responseDate(response)
					LegionPrayingPanel:update()
				end
			end)

		else
			GameController.showPrompts(LegionConfig:getLegionLocalText('LEGION_PRAY_NO_TIMES'),COLOR_TYPE.RED)
		end

	end
end
function LegionPrayingPanel:responseDate(response)
	local awards = response.data.awards
	self.beadPos  =response.data.award_id
	if awards ~= nil then
		local award = UserData:getAward(UserData.makeAwardStr(awards[1]))
		self.awardStr =award['name'] ..'x' ..award['count']
		self.praytimes =self.praytimes +1
		self.allawards[self.praytimes] ={}
		self.allawards[self.praytimes] =UserData.makeAwardStr(awards[1])
		self.prayArrow:setRotation(0)
		LegionPrayingPanel:Rotation()
	end
end
function LegionPrayingPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('qifu_bg_img', 'qifu_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		local prayjitanbg_pl =tolua.cast(root:getChildByName('jitan_pl'), 'UIPanel')
		local titleimg =tolua.cast(root:getChildByName('title_img'), 'UIImageView')
		self.prayleftnum_tx =tolua.cast(prayjitanbg_pl:getChildByName('remain_number_tx'), 'UILabel')
		self.prayneedlghonor_tx =tolua.cast(prayjitanbg_pl:getChildByName('number_tx'), 'UILabel')
		self.praycurhavelghonor_tx =tolua.cast(titleimg:getChildByName('number_tx'), 'UILabel')
		self.praycloseBtn =tolua.cast(root:getChildByName('close_btn'), 'UIButton')
		self.prayplBtn=tolua.cast(root:getChildByName('qifu_tbtn'), 'UIButton')

		self.prayplbg =tolua.cast(root:getChildByName('pan_pl'), 'UIPanel')
		self.prayArrow =tolua.cast(self.prayplbg:getChildByName('arrow_ico'),'UIImageView')

		local parynumdesc =tolua.cast(prayjitanbg_pl:getChildByName('remain_tx'), 'UILabel')
		parynumdesc:setColor(ccc3(245,236,179))
		local paryjitantitle =tolua.cast(prayjitanbg_pl:getChildByName('jitan_tx'), 'UILabel')
		paryjitantitle:setColor(ccc3(238,185,8))

		self:registerButtonWithHandler(root, 'qifu_tbtn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
			LegionPrayingPanel:ClickBtn()
		end)
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.SLIDE_OUT)
			--cclog(self.allawards)
			if self.praytimes >0 then
				printall(self.allawards)
				genShowTotalAwardsPanel(self.allawards,getLocalStringValue('E_STR_PRAY_TOTAL_AWARD') )
				LegionActivityPage:update()
				self.praytimes =0
			end
		end)
		self.praytimes =0
		LegionPrayingPanel:update()
	end)
	panel:registerOnShowHandler(function()
		LegionPrayingPanel:update()
	end)
end
function LegionPrayingPanel:release()
	LegionPage.release(self)

	self.prayplbg 				= nil
	self.prayleftnum_tx 		= nil
	self.prayneedlghonor_tx 	= nil
	self.praycurhavelghonor_tx	= nil
	self.prayArrow				= nil
	self.praycloseBtn			= nil
	self.prayplBtn				= nil
	self.scheduleId 			= nil
	self.millisecond 			= nil
	self.endRotation 			= nil
	self.endRotate 				= nil
	self.beadPos 				= 1
	self.beadOriginPos			= nil
	self.PRAY_AWARD_COUNT		= 8
	self.awardStr               = nil
	self.times					= nil
	self.speed                  = nil
end