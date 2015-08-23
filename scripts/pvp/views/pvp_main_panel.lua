PvpMainPanel = PvpView:new{
	jsonFile = 'panel/pvp_main_panel.json',
	panelName = 'pvp-main-in-lua',
	data,
	isWar = false,
	timeCDTx,

}

function PvpMainPanel:resetCDLabel()
	if self.data.progress == 'rank' then
		local registerWeek = tonumber(GameData:getMapData('serverwarschedule.dat')['rank']['EndWeek'])
		local bt = Time.beginningOfWeek()

		local dt = PvpData:getScheduleByProgress('rank')
		local c_st = bt + tonumber(dt.EndWeek) * 24 * 3600
		local left_time = c_st - UserData:getServerTime()
		-- left_time = 10
		if left_time > 0 then
			self.timeCDTx:registerTimeoutHandler(function ()
				PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
				time = c_st - UserData:getServerTime()
				if time > 0 then
					self.timeCDTx:setTime( time  + 2)
				else
					CloseAllPanels()
					pvpEntrance()
				end
				-- PvpKnockoutPanel:enter1(self.data)
			end)
			self.timeCDTx:setTime( left_time  + 2)
			self.timeCDTx:setVisible(true)
		else
			self.timeInfoIco:setVisible(false)
			self.timeCDTx:setVisible(false)
		end
	end
end

function PvpMainPanel:getPlayerInfo(index)
	local data = PvpController.lastTop32rank
	if data and data[1] then
		for j,k in ipairs(PvpController.lastTop32) do
			if tonumber(k.uid) ==  tonumber(data[index]) then
				local player = k
				return player
			end
		end
	end
end

function PvpMainPanel:updateMainPanel()
	local panel = self.sceneObject:getPanelObj()
	root = panel:GetRawPanel()
	for i=1,3 do
		topIco = tolua.cast(root:getChildByName('top_'..i..'_ico') , 'UIImageView')
		roleImg = tolua.cast(topIco:getChildByName('role_img') , 'UIImageView')
		nameTx = tolua.cast(topIco:getChildByName('name_tx') , 'UILabel')
		areaTx = tolua.cast(topIco:getChildByName('area_tx') , 'UILabel')

		-- self.data.last_top4 = nil
		local player = self:getPlayerInfo(i)
		if player then
			nameTx:setText(player.name)
			areaTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC1'),player.serverid))
			if tonumber(player.uid) < 100000 then
				tab = getMosterInfo(player.headpic)
				roleImg:setTexture(tab.big)
				roleImg:setAnchorPoint( ccp(0.5 , 0) )
			else
				pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject(player.headpic, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
				pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
				iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.BIG)
				roleImg:setTexture(iconRes)
				roleImg:setAnchorPoint( ccp(0.5 , 0) )
			end
		else
			areaTx:setVisible(false)
		end
	end
end

function PvpMainPanel:getAwards()
	local awards = {}
	local awardsData = {}
	local i = 1
	if not self.data then
		return
	end
	if not self.data.awards then
		self.data.awards = {}
		return
	end
	if self.data.awards.day then -- TODO 出现过一次错误
		table.insert(awards,i)
		awards[i] = 1
		table.insert(awardsData,i)
		awardsData[i] = self.data.awards.day
		i = i + 1
	end
	if self.data.awards.last_rank then
		table.insert(awards,i)
		awards[i] = 2
		table.insert(awardsData,i)
		awardsData[i] = self.data.awards.last_rank
		i = i + 1
	end
	if self.data.awards.rank then
		table.insert(awards,i)
		awards[i] = 3
		table.insert(awardsData,i)
		awardsData[i] = self.data.awards.rank
		i = i + 1
	end
	if self.data.awards.support4 then
		table.insert(awards,i)
		awards[i] = 4
		table.insert(awardsData,i)
		awardsData[i] = self.data.awards.support4
		i = i + 1
	end
	if self.data.awards.support1 then
		table.insert(awards,i)
		awards[i] = 5
		table.insert(awardsData,i)
		awardsData[i] = self.data.awards.support1
		i = i + 1
	end

	if #awards > 0 then
		PvpGetAwardsPanel:enter(awards,awardsData)
	end
	self.data.awards = {}
end

function PvpMainPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()
		local MainBgImg = tolua.cast(root:getChildByName('pvp_bg_img') , 'UIImageView')
		local PlayerPl = tolua.cast(root:getChildByName('player_pl') , 'UIPanel')
		local TitleImg = tolua.cast(root:getChildByName('pvp_title_ico') , 'UIImageView')
		local BtnPl = tolua.cast(root:getChildByName('btn_pl') , 'UIPanel')
		local BuzhenBtn = tolua.cast(root:getChildByName('buzhen_btn'), 'UIButton')
		self.timeInfoIco = tolua.cast(root:getChildByName('time_info_ico'), 'UILabel')
		local timeTx = tolua.cast(self.timeInfoIco:getChildByName('time_tx'), 'UILabel')

		local GoWarBtn = tolua.cast(root:getChildByName('go_war_tbtn'), 'UIButton')
		local GoBackBtn = tolua.cast(root:getChildByName('goback_btn'), 'UIButton')
		local WarBtn = tolua.cast(root:getChildByName('war_btn'), 'UIButton')
		local reviewBtn = tolua.cast(root:getChildByName('review_btn'), 'UIButton')
		-- GoWarBtn:setVisible((self.isWar == false) and (PvpController.open ~= 0) and (PvpController.register ~= 0) )
		GoWarBtn:setVisible((self.isWar == false) and (PvpController.open ~= 0) and (self.data.progress ~= PROGRESS.OVER))
		self.timeInfoIco:setVisible((self.isWar == false) and (PvpController.open ~= 0) and (self.data.progress ~= PROGRESS.OVER))
		if self.data.records and #self.data.records == 31 then
			reviewBtn:setVisible(self.isWar == false)
		else
			reviewBtn:setVisible(false)
		end
		-- WarBtn:setTouchEnable(self.isWar == false)
		self:registerButtonWithHandler(root, 'buzhen_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			OpenEmbattleUiforPVP(false)
		end)
		self:registerButtonWithHandler(root, 'goback_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)

		self:registerButtonWithHandler(root, 'help_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			PvpController.show(PvpHelpPanel, ELF_SHOW.SLIDE_IN)
		end)

		self:registerButtonWithHandler(root, 'review_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			PvpKnockoutPanel:enter1(self.data)
		end)

		self:registerButtonWithHandler(root, 'award_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			PvpController.show(PvpAwardPanel, ELF_SHOW.SLIDE_IN)
		end)
		
		self:registerButtonWithHandler(root, 'shop_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			PvpController.show(PvpShopPanel, ELF_SHOW.SLIDE_IN)
		end)

		self:registerButtonWithHandler(root, 'go_war_tbtn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			if PvpController.register == 0 then
				GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC12'), COLOR_TYPE.RED)
			else
				if PvpController.open ~= 0 then
					PvpGoWarPanel:enter()
				else
					GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC14'), COLOR_TYPE.RED)
				end
			end
		end)

		self:registerButtonWithHandler(root, 'rank_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			PvpListPanel:enter()
		end)

		self:registerButtonWithHandler(root, 'war_btn', BUTTON_SOUND_TYPE.CLOSE_EFFECT, function()
			if PvpController.register == 0 then
				GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC13'), COLOR_TYPE.RED)
			elseif self.data.progress == PROGRESS.OVER then
				GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC11'), COLOR_TYPE.RED)
			else
				if PvpController.open ~= 0  and self.isWar ~= true then
					PvpBattleRecordPanel:enter()
				elseif PvpController.open == 0 then
					GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC14'), COLOR_TYPE.RED)
				elseif self.isWar == true then
					GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC11'), COLOR_TYPE.RED)
				end
			end
		end)


		timeTx:setText('')
		self.timeCDTx = UICDLabel:create()
		self.timeCDTx:setFontSize(22)
		self.timeCDTx:setPosition(ccp(0,0))
		self.timeCDTx:setFontColor(ccc3(50, 240, 50))
		self.timeCDTx:setAnchorPoint(ccp(0,0.5))
		timeTx:addChild(self.timeCDTx)
		-- self.timeCDTx:setTime(10000)
		-- 适配
		local winSize = CCDirector:sharedDirector():getWinSize()
		MainBgImg:setPosition(ccp(winSize.width/2,winSize.height/2))
		local PlayerPlSize = PlayerPl:getContentSize()
		PlayerPl:setPosition(ccp(0, winSize.height - PlayerPlSize.height))
		local TitleImgSize = TitleImg:getContentSize()
		TitleImg:setPosition(ccp(winSize.width / 2, winSize.height - TitleImgSize.height / 2))
		local BtnPlSize = BtnPl:getContentSize()
		BtnPl:setPosition(ccp(winSize.width - BtnPlSize.width - 20, winSize.height - BtnPlSize.height ))
		local BuzhenBtnSize = BuzhenBtn:getContentSize()
		BuzhenBtn:setPosition(ccp(BuzhenBtnSize.width / 2 + 20, BuzhenBtnSize.height / 2 + 10))
		local GoWarBtnSize = GoWarBtn:getContentSize()
		GoWarBtn:setPosition(ccp(winSize.width / 2, GoWarBtnSize.height /2 + 10))
		local GoBackBtnSize = GoBackBtn:getContentSize()
		GoBackBtn:setPosition(ccp(winSize.width - GoBackBtnSize.width /2 - 20, GoBackBtnSize.height /2 + 10))

		self:updateMainPanel()
		self:updatePlayerInfo()
		self:resetCDLabel()
		-- self:getAwards()
	end)

	panel:registerOnShowHandler(function()
		self:getAwards()
		self:updatePlayerInfo()
	end)
end

function PvpMainPanel:updatePlayerInfo()
	if not self.sceneObject then
		return
	end
	local panel = self.sceneObject:getPanelObj()
	root = panel:GetRawPanel()
	local playerBgImg = tolua.cast(root:getChildByName('player_bg_img') , 'UIImageView')
	local playerTitleTx = tolua.cast(playerBgImg:getChildByName('player_title_tx') , 'UILabel')
	local playerRankTx = tolua.cast(playerBgImg:getChildByName('player_rank_tx') , 'UILabel')
	local nameTx = tolua.cast(playerBgImg:getChildByName('name_tx') , 'UILabel')
	local playerIco = tolua.cast(playerBgImg:getChildByName('player_ico') , 'UIImageView')
	
	-- self.data.last_rank = 50
	if self.data.last_rank then
		playerTitleTx:setText(GetTextForCfg(PvpData.getRule(self.data.last_rank)))
	else
		playerTitleTx:setText( getLocalStringValue('E_STR_WELFARE_NORANK'))
	end

	playerRankTx:setText(PvpController.rank or getLocalStringValue('E_STR_WELFARE_NORANK'))

	nameTx:setText( PlayerCoreData.getPlayerName())

	roleMap = CLDObjectManager:GetInst():GetNewRoleObject(1)
	playerIco:setTexture(tolua.cast(roleMap,'CLDRoleObject'):GetRoleIcon(2))
end

function PvpMainPanel:enter(res)
	self.data = res.data
	if not self.data.top32 or not self.data.top32[1] then
		self.data.top32 = self.data.last_top32
	end
	self.isWar = false
	PvpController.show(PvpMainPanel, ELF_SHOW.SLIDE_IN)
end

function PvpMainPanel:enter1(res)
	self.data = res
	self.isWar = true
	PvpController.show(PvpMainPanel, ELF_SHOW.SLIDE_IN)
end