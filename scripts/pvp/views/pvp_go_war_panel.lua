PvpGoWarPanel = PvpView:new{
	jsonFile = 'panel/pvp_go_war_panel_1.json',
	panelName = 'pvp-go-war-in-lua',
	matchData = {},
	battleData = {},
	challengeBtn,
	isCanFight = false,
	rightRoleImg,
	rightRoleImg1
}

function PvpGoWarPanel:updateRight(root)
	-- local panel = self.sceneObject:getPanelObj()
	-- local root = panel:GetRawPanel()
	rightRoleImg = self.rightRoleImg
	rightRoleImg1 = self.rightRoleImg1
	if PvpController.fighted ~= 0 then
		rightRoleImg:setVisible(false)
		rightRoleImg1:setVisible(true)
	else
		rightRoleImg:setVisible(true)
		rightRoleImg1:setVisible(false)
		local roleInfoBgImg = tolua.cast(rightRoleImg:getChildByName('role_info_bg_img') , 'UIImageView')
		local qunNameTx = tolua.cast(rightRoleImg:getChildByName('qun_name_tx') , 'UILabel')
		local playerNameTx = tolua.cast(rightRoleImg:getChildByName('player_name_tx') , 'UILabel')
		local fightingTxtTx = tolua.cast(rightRoleImg:getChildByName('fighting_txt_tx') , 'UILabel')
		local fightingNumTx = tolua.cast(rightRoleImg:getChildByName('fighting_num_tx') , 'UILabel')
		local jifenTxtTx = tolua.cast(rightRoleImg:getChildByName('jifen_txt_tx') , 'UILabel')
		local jifenNumTx = tolua.cast(rightRoleImg:getChildByName('jifen_num_tx') , 'UILabel')

		if  tonumber(self.matchData.uid) < 100000 then
			tab = getMosterInfo(self.matchData.headpic)
			rightRoleImg:setTexture(tab.big)
			rightRoleImg:setScale(0.9)
		else
			pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject(self.matchData.headpic, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
			pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
			big = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.BIG)
			rightRoleImg:setTexture(big)
			rightRoleImg:setScale(0.9)
		end

		qunNameTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC1'),(self.matchData.serverid or 0)))
		playerNameTx:setText(GetTextForCfg(self.matchData.name) or '')
		fightingNumTx:setText(self.matchData.force or 0)
		jifenNumTx:setText(self.matchData.score or 0)
	end
end

function PvpGoWarPanel:updateLeft(root)

	local leftRoleImg = tolua.cast(root:getChildByName('left_role_img') , 'UIImageView')
	local roleInfoBgImg = tolua.cast(leftRoleImg:getChildByName('role_info_bg_img') , 'UIImageView')
	local qunNameTx = tolua.cast(roleInfoBgImg:getChildByName('qun_name_tx') , 'UILabel')
	local playerNameTx = tolua.cast(leftRoleImg:getChildByName('player_name_tx') , 'UILabel')
	local fightingTxtTx = tolua.cast(leftRoleImg:getChildByName('fighting_txt_tx') , 'UILabel')
	local fightingNumTx = tolua.cast(leftRoleImg:getChildByName('fighting_num_tx') , 'UILabel')
	local jifenTxtTx = tolua.cast(leftRoleImg:getChildByName('jifen_txt_tx') , 'UILabel')
	local jifenNumTx = tolua.cast(leftRoleImg:getChildByName('jifen_num_tx') , 'UILabel')
	-- local timesTx = tolua.cast(root:getChildByName('times_tx') , 'UILabel')

	roleMap = CLDObjectManager:GetInst():GetNewRoleObject(1)
	playerName = PlayerCoreData.getPlayerName()

	leftRoleImg:setTexture(tolua.cast(roleMap,'CLDRoleObject'):GetRoleIcon(0))
	leftRoleImg:setScale(0.9)
	-- qunNameTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC1'),PlayerCore:getPlayerServerID()))
	qunNameTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC1'),PvpController.serverid))
	playerNameTx:setText(playerName)
	-- fightingNumTx:setText(PlayerCoreData.getPlayerFightForce())
	fightingNumTx:setText(PvpController.fightForce)
	jifenNumTx:setText(PvpController.score)

	-- timesTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_BATTLE_TIMES'),PvpController.battle))
end

function PvpGoWarPanel:updateTimes(root)
	
	local panel = self.sceneObject:getPanelObj()
	local root = panel:GetRawPanel()

	local battleTimesTx = tolua.cast(root:getChildByName('battle_times_tx') , 'UILabel')
	if PvpController.battleTimes and PvpData.maxBattleTimes > PvpController.battleTimes then
		times = PvpData.maxBattleTimes - PvpController.battleTimes
	else
		times = 0
	end
	battleTimesTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_BATTLE_TIMES'),times))

	local matchTimesTx = tolua.cast(root:getChildByName('match_times_tx') , 'UILabel')

	if PvpController.matchTimes and PvpData.maxMatchTimes > PvpController.matchTimes then
		times = PvpData.maxMatchTimes - PvpController.matchTimes
	else
		times = 0
	end
	matchTimesTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_MATCH_TIMES'),times))

end

function PvpGoWarPanel:updatePanel()

	local panel = self.sceneObject:getPanelObj()
	local root = panel:GetRawPanel()
	self:updateRight(root)
	self:updateLeft(root)
	self:updateTimes()
end

function PvpGoWarPanel:init()

	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('go_war_bg_img','challenge_tbtn')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()
		
		goWarBgImg = tolua.cast(root:getChildByName('go_war_bg_img') , 'UIButton')

		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		lookBtn = tolua.cast(root:getChildByName('look_tbtn') , 'UIButton')
    	lookBtn:registerScriptTapHandler(function ()
			-- OpenEmbattleUi()
			PvpController.lookType = 1
			OpenEmbattleUiforPVP(true)
		end)
		GameController.addButtonSound(lookBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		self.challengeBtn = tolua.cast(root:getChildByName('challenge_tbtn') , 'UIButton')
    	self.challengeBtn:registerScriptTapHandler(function ()
    		if PvpController.fighted ~= 0 then
    			GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_CANNOT_FIGHT'), COLOR_TYPE.RED)
    		else
				self:OnRankFight()
			end
		end)
		GameController.addButtonSound(self.challengeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		replaceBtn = tolua.cast(root:getChildByName('replace_tbtn') , 'UIButton')
    	replaceBtn:registerScriptTapHandler(function ()
			self:OnReplaceRival()
		end)
		GameController.addButtonSound(replaceBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		-- 适配
		local winSize = CCDirector:sharedDirector():getWinSize()
		goWarBgImg:setPosition(ccp(winSize.width/2,winSize.height/2))
		closeSize = closeBtn:getContentSize()
		closeBtn:setPosition(ccp(winSize.width, winSize.height))

		self.rightRoleImg = tolua.cast(root:getChildByName('right_role_img') , 'UIImageView')
		self.rightRoleImg1 = tolua.cast(root:getChildByName('right_role_img_1') , 'UIImageView')
		self.rightRoleImg1:setScale(0.8)

		self:updatePanel()

		-- if PvpController.fighted ~= 0 and PvpController.matchTimes >= PvpData.maxMatchTimes then
		-- 	self.challengeBtn:setNormalButtonGray(true)
		-- 	self.challengeBtn:setTouchEnable(false)
		-- else
		-- 	self.challengeBtn:setNormalButtonGray(false)
		-- 	self.challengeBtn:setTouchEnable(true)
		-- end
	end)
end

function PvpGoWarPanel:replaceRival(cash)
	-- self.challengeBtn:setNormalButtonGray(false)
	-- self.challengeBtn:setTouchEnable(true)
	PvpController:matchEnemy(function(res)
		self.matchData = res.data.enemy
		PvpController.fighted = 0
		self:updatePanel()
		if cash and cash > 0 then
			PlayerCoreData.addCashDelta( 0 - cash )
		end
	end,cash)
end
function PvpGoWarPanel:OnReplaceRival()
	if tonumber(PvpController.matchTimes) >= PvpData.maxMatchTimes then
		GameController.showMessageBox(string.format(getLocalStringValue('E_STR_PVP_WAR_MATCH_DESC'),PvpData.maxBuyMatch), MESSAGE_BOX_TYPE.OK_CANCEL,function ()
			cash = PvpData.maxBuyMatch
			myCash = PlayerCoreData.getCashValue()
			if myCash < cash then
				GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
			else
				self:replaceRival(cash)
			end
		end)
	else
		self:replaceRival()
	end
end
function PvpGoWarPanel:rankFight(cash)
	PvpController:rankFight(function(res)
		PvpController.fighted = 1
		self.battleData = res.data
		
		if self.battleData.battle then
			isNeedUpdate = tonumber(self.battleData.battle.success)
			GameController.clearAwardView()
			PvpController.score = PvpController.score + self.battleData.score_add
			-- 刷新奖励数据
			rewardData = self.battleData.awards
			UserData.parseAwardJson(json.encode(rewardData))
			local tmpAwards = {}
			if rewardData and #rewardData > 0 then
			 	for k , v in pairs ( rewardData ) do
			 		table.insert(tmpAwards,v)
			 	end
				
				id = nil
				score = self.battleData.score_add
				if score < 0 then
					id = '10000'
				else
					id = '9999'
				end

				tmp = {
					'material',
					id,
					score
				}
				table.insert(tmpAwards,tmp)
				GameController.updateAwardView(json.encode(tmpAwards))
			end
			GameController.playBattle(json.encode(self.battleData.battle) , 5)
		end
		if tonumber(PvpController.matchTimes) < PvpData.maxMatchTimes then
			self:replaceRival()
		else
			self.rightRoleImg:setVisible(false)
			self.rightRoleImg1:setVisible(true)
		-- 	self.challengeBtn:setNormalButtonGray(true)
		-- 	self.challengeBtn:setTouchEnable(false)
		end
		self:updatePanel()

		if cash and cash > 0 then
			PlayerCoreData.addCashDelta( 0 - cash )
		end
	end,self.matchData.uid,cash)
end

function PvpGoWarPanel:OnRankFight()
	if tonumber(PvpController.battleTimes) >= PvpData.maxBattleTimes then
		GameController.showMessageBox(string.format(getLocalStringValue('E_STR_ARENA_NO_FREE_COUNT'),PvpData.maxBuyBattle), MESSAGE_BOX_TYPE.OK_CANCEL,function ()
			cash = PvpData.maxBuyBattle
			myCash = PlayerCoreData.getCashValue()
			if myCash < cash then
				GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
			else
				self:rankFight(cash)
			end
		end)
	else
		self:rankFight()
	end
end

function PvpGoWarPanel:enter()
	if PvpController.lastEnemy and type(PvpController.lastEnemy) == 'table' then
		self.matchData = PvpController.lastEnemy
		PvpController.show(PvpGoWarPanel, ELF_SHOW.SLIDE_IN)
	else
		PvpController:matchEnemy(function(res)
			self.matchData = res.data.enemy
			PvpController.lastEnemy = res.data.enemy
			PvpController.fighted = 0
			PvpController.show(PvpGoWarPanel, ELF_SHOW.SLIDE_IN)
		end)
	end
end