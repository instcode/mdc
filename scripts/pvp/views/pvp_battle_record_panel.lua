PvpBattleRecordPanel = PvpView:new{
	jsonFile = 'panel/pvp_battle_record_panel.json',
	panelName = 'pvp-battle-record-in-lua',
	cardSv,
	replays = {},
	replaysBattleData
}

MAXRECORD = 10
local yellowAttack = 'uires/ui_2nd/com/panel/pvp/yellow_attack.png'
local blueAttack = 'uires/ui_2nd/com/panel/pvp/blue_attack.png'
local yellowDefense = 'uires/ui_2nd/com/panel/pvp/yellow_defense.png'
local blueDefense = 'uires/ui_2nd/com/panel/pvp/blue_defense.png'

function PvpBattleRecordPanel:updateImg(i,view)

	stateTxtImg = tolua.cast(view:getChildByName('state_txt_img') , 'UIImageView')
	addNumTx = tolua.cast(view:getChildByName('add_num_tx') , 'UILabel')
	if self.replays[i].attacker == 1 and self.replays[i].win == 1 then
		stateTxtImg:setTexture(yellowAttack)
		addNumTx:setText('+'..self.replays[i].score)
		elseif self.replays[i].attacker == 1 and self.replays[i].win == 0 then
			stateTxtImg:setTexture(blueAttack)
			addNumTx:setText(self.replays[i].score)
			elseif self.replays[i].attacker == 0 and self.replays[i].win == 1 then
				stateTxtImg:setTexture(yellowDefense)
				addNumTx:setText('+'..self.replays[i].score)
			else
				stateTxtImg:setTexture(blueDefense)
				addNumTx:setText(self.replays[i].score)
			end
end

function PvpBattleRecordPanel:rankFight(i,cash)
	PvpController:rankFight(function(res)
		self.replaysBattleData = res.data
		
		if self.replaysBattleData.battle then

			isNeedUpdate = tonumber(self.replaysBattleData.battle.success)
			GameController.clearAwardView()
			PvpController.score = PvpController.score + self.replaysBattleData.score_add

			-- 刷新奖励数据
			rewardData = self.replaysBattleData.awards
			UserData.parseAwardJson(json.encode(rewardData))
			local tmpAwards = {}
			if rewardData and #rewardData > 0 then
			 	for k , v in pairs ( rewardData ) do
			 		table.insert(tmpAwards,v)
			 	end
				
				id = nil
				score = self.replaysBattleData.score_add
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
			GameController.playBattle(json.encode(self.replaysBattleData.battle) , 5)

			self:updatePanel()
		end
	end,self.replays[i].enemy,cash,1,self.replays[i].replayid)
end

function PvpBattleRecordPanel:updatePanel()
	PvpController:getReplayList(function(res)
		self.replays = res.data.replays
		if not self.replays or type(self.replays) ~= 'table' then
			return
		end
		self:createCells()
	end)
end

function PvpBattleRecordPanel:OnGetReplay(i)
	PvpController:getReplay(function(res)
		self.replaysBattleData = res.data
		
		if self.replaysBattleData.battle then
			GameController.clearAwardView()
			GameController.playBattle(json.encode(self.replaysBattleData.battle) , 5)

			self:updatePanel()
		end
	end,self.replays[i].replayid)
end

function PvpBattleRecordPanel:OnRevenge(i)
	if tonumber(PvpController.battleTimes) >= PvpData.maxBattleTimes then
		GameController.showMessageBox(string.format(getLocalStringValue('E_STR_ARENA_NO_FREE_COUNT'),PvpData.maxBuyBattle), MESSAGE_BOX_TYPE.OK_CANCEL,function ()
			self:rankFight(i,PvpData.maxBuyBattle)
		end)
	else
		self:rankFight(i)
	end
end
function PvpBattleRecordPanel:updateCells(i,view)

	rankingBg = tolua.cast(view:getChildByName('record_bg_img') , 'UIImageView')
	if i % 2 == 1 then
		rankingBg:setVisible(true)
	else
		rankingBg:setVisible(false)
	end

	palyerName = tolua.cast(view:getChildByName('player_name_tx') , 'UILabel')
	palyerName:setText(GetTextForCfg(self.replays[i].name))
	
	numberLa = tolua.cast(view:getChildByName('number_la') , 'UILabelAtlas')
	numberLa:setStringValue(self.replays[i].force)

	headImg = tolua.cast(view:getChildByName('head_img') , 'UIImageView')
	if tonumber(self.replays[i].enemy) < 100000 then
		tab = getMosterInfo(self.replays[i].headpic)
		headImg:setTexture(tab.iconRes)
	else
		pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject(self.replays[i].headpic, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
		pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
		iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON)
		headImg:setTexture(iconRes)
	end

	revengeBtn = tolua.cast(view:getChildByName('revenge_btn') , 'UIButton')
	revengeBtn:registerScriptTapHandler(function()
		GameController.showMessageBox(getLocalStringValue('E_STR_PVP_REVENGE_INFO'), MESSAGE_BOX_TYPE.OK_CANCEL,function ()
			self:OnRevenge(i)
		end)
		end)
	revengeBtn:setVisible(self.replays[i].revenged == 0)

	replayBtn = tolua.cast(view:getChildByName('visit_btn') , 'UIButton')
	replayBtn:registerScriptTapHandler(function()
		self:OnGetReplay(i)
		end)
	self:updateImg(i,view)
end

function PvpBattleRecordPanel:createCells()
	self.cardSv:removeAllChildrenAndCleanUp(true)
	MAXRECORD = 10
	if MAXRECORD > #self.replays then
		MAXRECORD = #self.replays
	end
	for i=1,MAXRECORD do
		local view = createWidgetByName('panel/pvp_battle_record_cell.json')
		self:updateCells(i,view)
		self.cardSv:addChildToBottom(view)
	end
	self.cardSv:scrollToTop()
end

function PvpBattleRecordPanel:init()

	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('battle_record_bg_img','battle_record_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()

		self.cardSv = tolua.cast(root:getChildByName('record_sv') , 'UIScrollView')
		self.cardSv:setClippingEnable(true)
		self.cardSv:setTouchEnable(true)
		
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		self:createCells()
	end)

	-- panel:registerOnShowHandler(function ()
	-- 	self:updatePanel()
	-- end)
end

function PvpBattleRecordPanel:enter()
	print('PvpBattleRecordPanel')
	PvpController:getReplayList(function(res)
		self.replays = res.data.replays
		if not self.replays or type(self.replays) ~= 'table' then
			return
		end
		PvpController.show(PvpBattleRecordPanel, ELF_SHOW.SLIDE_IN)
	end)
end