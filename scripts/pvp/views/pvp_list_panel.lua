PvpListPanel = PvpView:new{
	jsonFile = 'panel/pvp_rank_bg_panel.json',
	panelName = 'pvp-rank-bg-in-lua',
	rankSv,
	recordSv,
	contentPl,
	titlePage,
	page = 1,
	leftBtn,
	rightBtn,
	jifenCellsPanel = {},
	bazhuCellsPanel = {},
	lastRankCellsPanel = {},
	panels = {},
	data = {}
}

MAXLIST = 50
MAXTITLE = 7
MAXPAGE = 5

function PvpListPanel:createRulePanel()
	sceneObj = SceneObjEx:createObj('panel/pvp_title_panel_1.json','pvp-title-in-lua')
	local panel = sceneObj:getPanelObj()
	panel:setAdaptInfo('pvp_title_bg_img','pvp_title_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()

		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		helpBtn = tolua.cast(root:getChildByName('help_btn') , 'UIButton')
    	helpBtn:registerScriptTapHandler(function ()
			PvpController.show(PvpRuleHelpPanel, ELF_SHOW.SLIDE_IN)
		end)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		for i=1,MAXTITLE do
			photoIco = tolua.cast(root:getChildByName('top_' .. i .. '_ico'), 'UIImageView')
			topNumTx = tolua.cast(photoIco:getChildByName('top_num_tx'), 'UILabel')
			if PvpData.DayAwardData[i+1] and tonumber(PvpData.DayAwardData[i+1].Rank) - tonumber(PvpData.DayAwardData[i].Rank) == 1 then
				topNumTx:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK'),PvpData.DayAwardData[i].Rank))
			elseif PvpData.DayAwardData[i+1] and tonumber(PvpData.DayAwardData[i+1].Rank) - tonumber(PvpData.DayAwardData[i].Rank) ~= 1 then
				topNumTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC3'),tonumber(PvpData.DayAwardData[i].Rank),tonumber(PvpData.DayAwardData[i+1].Rank)-1))
			else
				topNumTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC4'),tonumber(PvpData.DayAwardData[i].Rank) - 1))
			end

		end
	end)

	UiMan.show(sceneObj)
end

function PvpListPanel:updateTitle(i,titleImg)
	if i == 0 then
		return
	end
	for j,v in ipairs(PvpData.DayAwardData) do
		if i < tonumber(v.Rank) then
			titleImg:setTexture(PvpData.DayAwardData[j - 1 ].Url)
			return
		else
			titleImg:setTexture(PvpData.DayAwardData[j].Url)
		end
	end
end

function PvpListPanel:getLastRank(uid)
	local data = PvpController.lastTop32rank
	for j,k in ipairs(data) do
		if tonumber(k) ==  tonumber(uid) then
			local index = j
			return index
		end
	end
	return 100
end

function PvpListPanel:getPlayerInfo(index)
	local data = PvpController.lastTop32rank
	if data and data[1] then
		for j,k in ipairs(PvpController.lastTop32) do
			if tonumber(k.uid) ==  tonumber(data[index]) then
				local player = k
				return player,0
			end
		end
		return nil,0
	end
	return nil,1
end

function PvpListPanel:updateBazhuCells()
	for i,view in ipairs(self.bazhuCellsPanel) do
		self.rankSv:removeChildReferenceOnly(view)
		local rankingBg = tolua.cast(view:getChildByName('ranking_img') , 'UIImageView')
		if i % 2 == 0 then
			rankingBg:setVisible(true)
		else
			rankingBg:setVisible(false)
		end

		local crownImg = tolua.cast(view:getChildByName('crown_img') , 'UIImageView')
		local rankNumTx = tolua.cast(view:getChildByName('rank_num_tx') , 'UILabel')
		if i + (self.page - 1)*10 == 1 then
			crownImg:setVisible(true)
			crownImg:setTexture('uires/ui_2nd/com/panel/trena/1.png')
			rankNumTx:setVisible(false)
		elseif i + (self.page - 1)*10 == 2 then
			crownImg:setVisible(true)
			crownImg:setTexture('uires/ui_2nd/com/panel/trena/2.png')
			rankNumTx:setVisible(false)
		elseif i + (self.page - 1)*10 == 3 then
			crownImg:setVisible(true)
			crownImg:setTexture('uires/ui_2nd/com/panel/trena/3.png')
			rankNumTx:setVisible(false)
		else
			crownImg:setVisible(false)
			rankNumTx:setVisible(true)
			rankNumTx:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK'),i + (self.page - 1)*10))
		end
		local playerNameTx = tolua.cast(view:getChildByName('player_name_tx') , 'UILabel')
		local serverNameTx = tolua.cast(view:getChildByName('server_num_tx') , 'UILabel')
		local infoTx = tolua.cast(view:getChildByName('info_2_tx') , 'UILabel')
		local titleImg = tolua.cast(view:getChildByName('title_img') , 'UIImageView')
		local xuweiImg = tolua.cast(view:getChildByName('xuwei_txt_img') , 'UIImageView')
		self:updateTitle(i + (self.page - 1)*10,titleImg)

		local player,stype = self:getPlayerInfo(i + (self.page - 1)*10)
		if player then
			self.rankSv:addChildToBottom(self.bazhuCellsPanel[i])
			playerNameTx:setText(player.name)
			serverNameTx:setText(player.serverid)
			xuweiImg:setVisible(false)
			infoTx:setVisible(true)
		-- elseif stype == 1 and i + (self.page - 1)*10 < 33 then
		elseif i + (self.page - 1)*10 < 33 then
			self.rankSv:addChildToBottom(self.bazhuCellsPanel[i])
			xuweiImg:setVisible(true)
			playerNameTx:setVisible(false)
			serverNameTx:setVisible(false)
			infoTx:setVisible(false)
		end
	end
	self.rankSv:scrollToTop()
end

function PvpListPanel:updateJifenCells()
	for i,view in ipairs(self.jifenCellsPanel) do
		self.recordSv:removeChildReferenceOnly(view)
		local palyer = self.data.rank_list[i + (self.page - 1)*10]
		if palyer then
			self.recordSv:addChildToBottom(self.jifenCellsPanel[i])
			rankingBg = tolua.cast(view:getChildByName('ranking_img') , 'UIImageView')
			if i % 2 == 0 then
				rankingBg:setVisible(true)
			else
				rankingBg:setVisible(false)
			end

			crownImg = tolua.cast(view:getChildByName('crown_img') , 'UIImageView')
			rankNumTx = tolua.cast(view:getChildByName('rank_num_tx') , 'UILabel')
			-- rankNumTx:setPreferredSize(80,1)
			if i + (self.page - 1)*10 == 1 then
				crownImg:setVisible(true)
				crownImg:setTexture('uires/ui_2nd/com/panel/trena/1.png')
				rankNumTx:setVisible(false)
			elseif i + (self.page - 1)*10 == 2 then
				crownImg:setVisible(true)
				crownImg:setTexture('uires/ui_2nd/com/panel/trena/2.png')
				rankNumTx:setVisible(false)
			elseif i + (self.page - 1)*10 == 3 then
				crownImg:setVisible(true)
				crownImg:setTexture('uires/ui_2nd/com/panel/trena/3.png')
				rankNumTx:setVisible(false)
			else
				crownImg:setVisible(false)
				rankNumTx:setVisible(true)
				rankNumTx:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK'),i + (self.page - 1)*10))
			end

			playerNameTx = tolua.cast(view:getChildByName('player_name_tx') , 'UILabel')
			-- playerNameTx:setText(PlayerCoreData.getPlayerName())
			playerNameTx:setText(GetTextForCfg(palyer.name))
			serverNameTx = tolua.cast(view:getChildByName('server_num_tx') , 'UILabel')
			serverNameTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC1'),palyer.serverid))

			
			titleImg = tolua.cast(view:getChildByName('title_img') , 'UIImageView')
			-- self:updateTitle(i + (self.page - 1)*10,titleImg)
			self:updateTitle(self:getLastRank(self.data.rank_list[i + (self.page - 1)*10].uid),titleImg)
			-- self:updateTitle(self.data.rank_list[i + (self.page - 1)*10].last_rank or 100,titleImg)

			integralTx = tolua.cast(view:getChildByName('integral_tx') , 'UILabel')
			integralTx:setText(palyer.score)
			
			teamBtn = tolua.cast(view:getChildByName('team_btn') , 'UIButton')
			teamBtn:registerScriptTapHandler(function ()
					-- PvpCheckRolePanel:enter(palyer,i)
					args = {
						id = palyer.uid
					}
					Message.sendPost('get_roles', 'serverwar', json.encode(args) , function( response )
						cclog(response)
						local res = json.decode(response)
						if tonumber(res.code) == 0 then
							genRolePanel(palyer.uid,palyer.name,res,i)
						else
							GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
						end
					end)
				end)
			GameController.addButtonSound(teamBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			frameImg = tolua.cast(view:getChildByName('frame_img') , 'UIImageView')
			headImg = tolua.cast(frameImg:getChildByName('head_img') , 'UIImageView')

			if tonumber(self.data.rank_list[i + (self.page - 1)*10].uid) < 100000 then
				tab = getMosterInfo(palyer.headpic)
				headImg:setTexture(tab.iconRes)
			else
				pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject(palyer.headpic, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
				pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
				iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON)
				headImg:setTexture(iconRes)
			end
		else
			view:setVisible(false)
		end
	end
	self.recordSv:scrollToTop()
end

function PvpListPanel:getMyRank()
	-- self.data.rank_list
	myId = PlayerCoreData.getUID()
	for i=1,#self.data.rank_list do
		if self.data.rank_list[i].uid == myId then
			PvpController.rank = i
		end
	end
end

function PvpListPanel:updatePageBtns()
	self.leftBtn:setNormalButtonGray(self.page == 1)
	self.leftBtn:setTouchEnable(self.page ~= 1)
	-- self.maxPage = MAXPAGE
	self.rightBtn:setNormalButtonGray(self.page >= self.maxPage)
	self.rightBtn:setTouchEnable(self.page < self.maxPage)

	if self.maxPage == 0 then
		self.goBtn:setTouchEnable(false)
	else
		self.goBtn:setTouchEnable(true)
	end
	self.pageNumTx:setText(self.page..'/'..self.maxPage)
end

function PvpListPanel:setBtnStatus(page)
	self.titleBns[self.titlePage]:setPressState(WidgetStateNormal)
	self.titleBns[self.titlePage]:setTouchEnable(true)
	if self.panels[self.titlePage] then
		self.panels[self.titlePage]:setVisible(false)
	end
	self.titlePage = page
	self.titleBns[self.titlePage]:setPressState(WidgetStateSelected)
	self.titleBns[self.titlePage]:setTouchEnable(false)
end

function PvpListPanel:updateCells()
	if self.titlePage == 1 then
		self:updateJifenCells()
	elseif self.titlePage == 2 then
		self:updateBazhuCells()
	end
end

-- function PvpListPanel:createLastRankCells()
-- 	for i=1,10 do
-- 		local view = createWidgetByName('panel/pvp_bazhu_rank_card_panel.json')
-- 		-- self:updateCells(i,view)
-- 		self.rankSv:addChildToBottom(view)
-- 	end
-- 	self.rankSv:scrollToTop()
-- end

-- function PvpListPanel:createlastRankPanel()
-- 	self:setBtnStatus(3)
-- 	if self.panels[self.titlePage] then
-- 		-- self.bazhuPanel:setVisible(true)
-- 		self.panels[self.titlePage]:setVisible(true)
-- 	else
-- 		local lastRankPanel = createWidgetByName('panel/pvp_bazhu_rank_panel.json')
-- 		self.rankSv = tolua.cast(lastRankPanel:getChildByName('rank_sv') , 'UIScrollView')
-- 		self.rankSv:setClippingEnable(true)
-- 		table.insert(self.panels,3)
-- 		self.panels[3] = lastRankPanel
-- 		self:createLastRankCells()
-- 		self.contentPl:addChild(lastRankPanel)
-- 	end
-- end

function PvpListPanel:createBazhuCells()
	self.bazhuCellsPanel = {}
	for i=1,10 do
		local view = createWidgetByName('panel/pvp_bazhu_rank_card_panel.json')
		-- self:updateCells(i,view)
		table.insert(self.bazhuCellsPanel,i)
		self.bazhuCellsPanel[i] = view
		self.rankSv:addChildToBottom(view)
	end
	self:updateBazhuCells()
	self.rankSv:scrollToTop()
end

function PvpListPanel:createbazhuPanel()
	self:setBtnStatus(2)
	if self.panels[self.titlePage] then
		-- self.bazhuPanel:setVisible(true)
		self.panels[self.titlePage]:setVisible(true)
	else
		local bazhuPanel = createWidgetByName('panel/pvp_bazhu_rank_panel.json')
		self.rankSv = tolua.cast(bazhuPanel:getChildByName('rank_sv') , 'UIListView')
		self.rankSv:setClippingEnable(true)
		table.insert(self.panels,2)
		self.panels[2] = bazhuPanel
		self:createBazhuCells()
		self.contentPl:addChild(bazhuPanel)
	end
end

function PvpListPanel:createJifenCells()
	self.jifenCellsPanel = {}
	for i=1,10 do
		local view = createWidgetByName('panel/pvp_jifen_rank_card_panel.json')
		table.insert(self.jifenCellsPanel,i)
		self.jifenCellsPanel[i] = view
		self.recordSv:addChildToBottom(view)
	end
	self:updateJifenCells()
	self.recordSv:scrollToTop()
end

function PvpListPanel:createJifenPanel()
	self:setBtnStatus(1)
	if self.panels[self.titlePage] then
		self.panels[self.titlePage]:setVisible(true)
	else
		local jifenPanel = createWidgetByName('panel/pvp_jifen_rank_panel.json')
		self.recordSv = tolua.cast(jifenPanel:getChildByName('record_sv') , 'UIListView')
		self.recordSv:setClippingEnable(true)

		rankingTx = tolua.cast(jifenPanel:getChildByName('ranking_tx') , 'UILabel')
		
		integralTx = tolua.cast(jifenPanel:getChildByName('integral_tx') , 'UILabel')
		integralTx:setText(self.data.score or getLocalStringValue('E_STR_WELFARE_NORANK'))

		ruleBtn = tolua.cast(jifenPanel:getChildByName('rule_btn') , 'UIButton')
    	ruleBtn:registerScriptTapHandler(function ()
			self:createRulePanel()
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		titleImg = tolua.cast(jifenPanel:getChildByName('title_img') , 'UIImageView')
		self:getMyRank()
		
		if type(PvpController.rank) ~= 'number' or PvpController.rank <= 0 then
			rankingTx:setText(getLocalStringValue('E_STR_PVP_WAR_WU'))
		else
			rankingTx:setText(PvpController.rank)
		end

		if type(PvpController.lastRank) ~= 'number' or PvpController.lastRank <= 0 then
			self:updateTitle(10000 ,titleImg)
		else
			self:updateTitle(PvpController.lastRank,titleImg)
		end

		table.insert(self.panels,1)
		self.panels[1] = jifenPanel
		self:createJifenCells()
		self.contentPl:addChild(jifenPanel)
	end
end

function PvpListPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('rank_bg_img','rank_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()
		
		-- goWarBgImg = tolua.cast(root:getChildByName('go_war_bg_img') , 'UIButton')

		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
    		for i,v in ipairs(self.panels) do
    			self.panels[i] = nil
    		end
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		titleBtn1 = tolua.cast(root:getChildByName('title_1_btn') , 'UIButton')
    	titleBtn1:registerScriptTapHandler(function ()
    		self.maxPage = ((#self.data.rank_list - 1) - (#self.data.rank_list - 1)%10)/10+1
    		self.page = 1
			self:createJifenPanel()
			self:updatePageBtns()
			self:updateCells()
		end)
		GameController.addButtonSound(titleBtn1 , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		titleBtn2 = tolua.cast(root:getChildByName('title_2_btn') , 'UIButton')
    	titleBtn2:registerScriptTapHandler(function ()
    		local page = self.pageEditbox:getTextFromInt()
    		self.maxPage = ((#PvpController.lastTop32rank - 1) - (#PvpController.lastTop32rank - 1)%10)/10+1
    		if self.maxPage <= 0 then
    			self.maxPage = 4
    		end
    		if page > self.maxPage then
    			self.pageEditbox:setTextFromInt(self.maxPage)
    		end
    		self.page = 1
			self:createbazhuPanel()
			self:updatePageBtns()
			self:updateCells()
		end)
		GameController.addButtonSound(titleBtn2 , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		self.titleBns = {titleBtn1, titleBtn2 }
		self.contentPl = tolua.cast(root:getChildByName('content_pl') , 'UIButton')

		self.leftBtn = tolua.cast(root:getChildByName('left_btn') , 'UIButton')
		self.leftBtn:registerScriptTapHandler(function ()
			self.page = self.page - 1
			self:updatePageBtns()
			self:updateCells()
		end)
		GameController.addButtonSound(self.leftBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		self.rightBtn = tolua.cast(root:getChildByName('right_btn') , 'UIButton')
		self.rightBtn:registerScriptTapHandler(function ()
			self.page = self.page + 1
			self:updatePageBtns()
			self:updateCells()
		end)
		GameController.addButtonSound(self.rightBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		self.goBtn = tolua.cast(root:getChildByName('go_btn') , 'UIButton')
		self.goBtn:registerScriptTapHandler(function ()
			self.page = tonumber(self.pageEditbox:getText())
			self:updatePageBtns()
			self:updateCells()
		end)
		GameController.addButtonSound(self.goBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		self.pageNumTx = tolua.cast(root:getChildByName('page_num_tx') , 'UILabel')

		local inputImg = tolua.cast(root:getChildByName('turn_bg_img'), 'UIImageView')
		self.pageEditbox = tolua.cast(UISvr:replaceUIImageViewByCCEditBox(inputImg) , 'CCEditBox')
		self.pageEditbox:setFontSize(24)
		self.pageEditbox:setInputMode(kEditBoxInputModeNumeric)
		self.pageEditbox:setHAlignment(kCCTextAlignmentCenter)
		self.pageEditbox:setTextFromInt(1)
		-- self.pageEditbox:setFontColor(ccc3(255,0,0))
		self.pageEditbox:setAnchorPoint(ccp(0.5,0))
		self.pageEditbox:setPosition(ccp(270,0))
		self.pageEditbox:registerScriptEditBoxHandler( function (eventType)
			if eventType == 'ended' then
				local num = self.pageEditbox:getTextFromInt()
				if num < 1 then
					self.pageEditbox:setTextFromInt(self.page)
				elseif num > self.maxPage then
					if self.maxPage > 0 then
						self.pageEditbox:setTextFromInt(self.maxPage)
					else
						self.pageEditbox:setTextFromInt(1)
					end
				end
			-- elseif eventType == 'began' then
			-- 	-- self.levelNum = self.levelEditbox:getTextFromInt()
			end
		end)

		self.maxPage = ((#self.data.rank_list - 1) - (#self.data.rank_list - 1)%10)/10+1
		print(self.maxPage)
		self.titlePage = 1
		self.page = 1

		self:updatePageBtns()
		self:createJifenPanel()
	end)

	panel:registerOnShowHandler(function()
		-- self:updatePanel()
	end)
end

function PvpListPanel:enter()
	print('PvpListPanel')
	nowTime = UserData:getServerTime()
	if nowTime - PvpController.getRankListTime > 60 or not PvpController.rankListData then
		PvpController:getRankList(function(res)
			self.data = res.data
			if not self.data.rank_list or type(self.data.rank_list) ~= 'table' then
				return
			end
			PvpController.rankListData = self.data
			PvpController.getRankListTime = res.serverTime
			PvpController.show(PvpListPanel, ELF_SHOW.SLIDE_IN)
		end)
	else
		self.data = PvpController.rankListData
		PvpController.show(PvpListPanel, ELF_SHOW.SLIDE_IN)
	end
end