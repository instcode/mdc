-- 军团主界面背景

LegionMainPanel = LegionView:new{
	jsonFile = 'panel/legion_main_bg_panel.json',
	panelName = 'legion-main-bg-panel',

	tags = { 'left_1_tbtn', 'left_2_tbtn', 'left_3_tbtn', 'left_4_tbtn', 'left_5_tbtn' ,'left_6_tbtn'},
	pages = { LegionMinePage, LegionTechPage, LegionActivityPage, LegionShopPage, LegionRankPage, LegionMemberPage},
	honorIco = nil,
	honorTx = nil,
	badgeIcon = nil,
	lvBg = nil,
	lvPanel = nil,
	peopleBg = nil,
	noticeBg = nil,
	memberPanel = nil,
	noticePanel = nil,
	leftBtnSv = nil,

	curTags = ''
}

local function showLegionInfoPanel()
	LegionController.show(LegionInfoPanel , ELF_SHOW.SMART)
end

function LegionMainPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('legion_bg_img', 'legion_img')

	panel:registerInitHandler(function()
		local root = panel:GetRawPanel()
		self:registerButtonWithHandler(root, 'close_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			LegionController.close(self, ELF_HIDE.SLIDE_OUT)
		end)

		self.helpBtn = self:registerButtonWithHandler(root, 'help_btn', BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
			LegionController.show(LegionHelpPanel, ELF_SHOW.ZOOM_IN)
		end)

		local donateBtn = tolua.cast(root:getChildByName('donate_btn') , 'UIButton')
		self.badgeIcon = tolua.cast(root:getChildByName('legion_badge_ico') , 'UIImageView')
		local legionNameTx = tolua.cast(root:getChildByName('title_tx') , 'UILabel')

		self.lvBg = tolua.cast(root:getChildByName('lv_bg_ico') , 'UIImageView')
		self.lvPanel = tolua.cast(root:getChildByName('lv_pl'), 'UIPanel')
		self.peopleBg = tolua.cast(root:getChildByName('people_bg_ico') , 'UIImageView')
		self.noticeBg = tolua.cast(root:getChildByName('bulletin_bg_img') , 'UIImageView')
		self.memberPanel = tolua.cast(root:getChildByName('member_pl'), 'UIPanel')
		self.noticePanel = tolua.cast(root:getChildByName('bulletin_pl'), 'UIPanel')

		self.leftBtnSv = tolua.cast(root:getChildByName('left_btn_sv'), 'UIScrollView')
		self.leftBtnSv:setClippingEnable(true)

		self.lvBg:registerScriptTapHandler(function ()
			showLegionInfoPanel()
		end)
		self.peopleBg:registerScriptTapHandler(function ()
			showLegionInfoPanel()
		end)
		self.noticeBg:registerScriptTapHandler(function ()
			showLegionInfoPanel()
		end)

		donateBtn:registerScriptTapHandler(function ()
			LegionController.show(LegionDonatePanel , ELF_SHOW.SMART)
		end)
		
		self.badgeIcon:registerScriptTapHandler(function ()
			LegionController.show(LegionInfoPanel , ELF_SHOW.SMART)
		end)

		table.foreach(self.tags, function ( i, v )
			self.tags[i] = self:registerButtonWithHandler(root, v, BUTTON_SOUND_TYPE.CLICK_EFFECT, function()
				if v == 'left_6_tbtn' then	-- 成员申请
					LegionController.sendLegionApplicantListRequest( function ()
						self:switchPage(i)
					end)
				elseif v == 'left_5_tbtn' then	-- 军团排行
					LegionController.sendLegionRankListRequest( function ()
						self:switchPage(i)
					end)
				else
					self:switchPage(i)
				end
				
				self.curTags = v
			end)
		end)

		self.container = tolua.cast(root:getChildByName('container_pl'), 'UIPanel')
		self.honorIco = tolua.cast(root:getChildByName('price_ico'), 'UIImageView')
		self.honorIco:setTexture(MyLegion:getHonorIcon())
		self.honorTx = tolua.cast(root:getChildByName('price_num_tx') , 'UILabel')

		legionNameTx:setText(MyLegion.name)

		self:switchPage(1)
		self.curTags = 'left_1_tbtn'

		self:update()
	end)

	panel:registerOnShowHandler(function()
		self:update()
	end)
end

function LegionMainPanel:update()
	self.badgeIcon:setTexture(MyLegion:getLegionBadge())
	if self.curTags == 'left_2_tbtn' then
		self.honorTx:setText(tostring(MyLegion.order))
	else
		self.honorTx:setText(tostring(MyLegion:getMyData().honor))
	end

	local lvTx = tolua.cast(self.lvPanel:getChildByName('lv_num_tx') , 'UILabel')
	local peopleTx = tolua.cast(self.memberPanel:getChildByName('people_num_tx') , 'UILabel')
	local noticeTx = tolua.cast(self.noticePanel:getChildByName('bulletin_ta') , 'UITextArea')
	lvTx:setText(tostring(MyLegion.level))
	local legionLevelConf = GameData:getArrayData('legionlevel.dat')
	peopleTx:setText(#MyLegion.members .. '/' .. legionLevelConf[tonumber(MyLegion.level)].MemberMax)
	noticeTx:setText(MyLegion.notice)

	local count = self.leftBtnSv:getChildren():count()
	-- 设置成员申请权限
	if MyLegion.position ~= 'member' then -- 副军团长以上职位应该显示6个按钮
		if count < 6 then
			self.leftBtnSv:scrollToTop()
			self.leftBtnSv:removeAllChildrenAndCleanUp(false)
			for i = 1, 6 do
				self.leftBtnSv:addChild(self.tags[i])
			end
		end
	else
		if count > 5 then
			self.leftBtnSv:scrollToTop()
			self.leftBtnSv:removeAllChildrenAndCleanUp(false)
			for i = 1, 5 do 	-- 普通成员看不到成员申请按钮
				self.leftBtnSv:addChild(self.tags[i])
			end
		end
	end
end

function LegionMainPanel:release()
	local count = self.leftBtnSv:getChildren():count()
	if count < 6 then
		for i = count + 1, 6 do
			self.tags[i]:removeFromParentAndCleanup(true)
		end
	end
	LegionView.release(self)

	self.honorIco = nil
	self.honorTx = nil
	self.badgeIcon = nil
	self.lvBg = nil
	self.lvPanel = nil
	self.peopleBg = nil
	self.noticeBg = nil
	self.leftBtnSv = nil
end

-- Override this method to move text on button.
-- 点击后要把文字放在按钮的正中间，资源和按钮的状态都很奇葩只能这么玩
function LegionMainPanel:switchPage( index )
	LegionView.switchPage(self, index)

	local oriX = 88
	for i, v in ipairs(self.tags) do
		local btnText = tolua.cast(self.tags[i]:getChildByName('Label'), 'UILabel')
		btnText:setPreferredSize(180,1)
		if i == index then
			btnText:setPosition(ccp(oriX + 20, 0))
		else
			btnText:setPosition(ccp(oriX, 0))
		end
	end

	if index == 2 then -- 如果切换到科技就显示科技图标
		self.honorIco:setTexture('uires/ui_2nd/com/panel/legion/science_stone.png')
		self.honorTx:setText(tostring(MyLegion.order))
	else	-- 否则显示贡献图标
		self.honorIco:setTexture(MyLegion:getHonorIcon())
		self.honorTx:setText(tostring(MyLegion:getMyData().honor))
	end
end