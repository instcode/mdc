PvpPlayerInfoPanel = PvpView:new{
	jsonFile = 'panel/player_info_panel.json',
	panelName = 'pvp-player-info-in-lua',
	index,
	stype,
	infoTx,
	zhanNumLa,
	rankingTx,
	winRankingTx,
	loseRankingTx,
	rank,
	myInfo,
	win = 0,
	lose = 0,
	team = {},
	placeTab = {}
}

SoldierIconNames = {
	"dao.png",
	"qiang.png",
	"qi.png",
	"meng.png",
	"red.png"
}

function PvpPlayerInfoPanel:getResult(index)
	if not self.data.replays[index] then
		return false
	end
	local loseTimes = 0
	for i=1,#self.data.replays[index] do
		if self.myPositionTop32 == self.data.replays[index][i].win + 1 then
			self.win = self.win + 1
		else
			self.lose = self.lose + 1
			loseTimes = loseTimes + 1
		end
	end
	if loseTimes >= 3 then
		return false
	end
	return true
end

function PvpPlayerInfoPanel:updatePlayerInfo()
	local index = 1
	if self.myPositionTop32 <= 0 then
		return
	end
	self.isEnd = 0
	local temIndex
	temIndex = (self.myPositionTop32 + self.myPositionTop32 % 2)/2
	top16index = temIndex
	if self:getResult(top16index,1) == false then
		return
	end

	temIndex = (temIndex + temIndex % 2 )/2
	top8index = 16 + temIndex
	if self:getResult(top8index,2) == false then
		return
	end

	temIndex = (temIndex + temIndex % 2 )/2
	top4index = 24 + temIndex
	if self:getResult(top4index,3) == false then
		return
	end

	if self.myPositionTop4 <= 0 then
		return
	end

	top2index = 28 + (self.myPositionTop4 + self.myPositionTop4 % 2 ) /2
	if self:getResult(top2index,4) == false then
		return
	end

	top1index = 31
	if self:getResult(top1index,5) == false then
		return
	end
end

function PvpPlayerInfoPanel:updateEmbattleInfo()
	if self.team then
		self.infoTx:setVisible(false)
		self.buzhenImg:setVisible(true)
	else
		self.infoTx:setVisible(true)
		self.buzhenImg:setVisible(false)
		return
	end
	for i = 1,9 do
		if self.team and self.team[tostring(i - 1)] and self.team[tostring(i - 1)] > 1 then
			self.infoTx:setVisible(false)
			roleInfo = PvpData:getRoleInfo(self.team[tostring(i - 1)])
			if tonumber(roleInfo.Soldier) < 0 or tonumber(roleInfo.Soldier) > 5 then
				self.placeTab[i]:setVisible(false)
			else
				str = string.format('%s%s','uires/ui_2nd/com/panel/pass/',SoldierIconNames[tonumber(roleInfo.Soldier)])
				self.placeTab[i]:setVisible(true)
				self.placeTab[i]:setTexture(str)
			end
		else
			self.placeTab[i]:setVisible(false)
		end
	end
end

function PvpPlayerInfoPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('player_card_bg_img','player_card_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		for i=1,9 do
			str = 'place_'..i..'_img'
			placeImg = tolua.cast(root:getChildByName(str) , 'UIImageView')
			table.insert(self.placeTab,i)
			self.placeTab[i] = placeImg
		end
		
		self.infoTx = tolua.cast(root:getChildByName('info_tx') , 'UILabel')
		self.infoTx:setPreferredSize(300,1)
		self.zhanNumLa = tolua.cast(root:getChildByName('zhan_num_la') , 'UILabelAtlas')
		self.rankingTx = tolua.cast(root:getChildByName('ranking_tx') , 'UILabel')
		self.winRankingTx = tolua.cast(root:getChildByName('win_ranking_tx') , 'UILabel')
		self.loseRankingTx = tolua.cast(root:getChildByName('lose_ranking_tx') , 'UILabel')
		self.serverNumTx = tolua.cast(root:getChildByName('server_num_tx') , 'UILabel')
		self.playerNameTx = tolua.cast(root:getChildByName('player_name_tx') , 'UILabel')
		headpic = tolua.cast(root:getChildByName('head_portrait_img') , 'UIImageView')
		self.buzhenImg = tolua.cast(root:getChildByName('buzhen_img') , 'UIImageView')

		if tonumber(self.myInfo.uid) < 100000 then
			tab = getMosterInfo(self.myInfo.headpic)
			headpic:setTexture(tab.iconRes)
		else
			pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject(self.myInfo.headpic, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
			pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
			iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON)
			headpic:setTexture(iconRes)
		end

		self.zhanNumLa:setStringValue(self.myInfo.force)
		self.serverNumTx:setText(self.myInfo.serverid)
		self.playerNameTx:setText(self.myInfo.name)
		self.rankingTx:setText(self.rank)

		self.win = 0
		self.lose = 0
		self:updateEmbattleInfo()
		self:updatePlayerInfo()

		print(self.win)
		print(self.lose)
		self.winRankingTx:setText(self.win)
		self.loseRankingTx:setText(self.lose)
	end)
end

function PvpPlayerInfoPanel:enter(res,index,stype,page)
	self.data = res
	self.index = index
	print('index ' .. index)
	print('stype ' .. stype)
	self.stype = stype
	self.page = page
	-- _,self.myPositionTop32 = getPlayer(self.data.top32[self.index + (self.page - 1)*8].uid,self.data)
	-- _,self.myPositionTop4 = getPlayerInTop4(self.data.top32[self.index + (self.page - 1)*8].uid,self.data)
	if self.stype == 1 then
		_,self.myPositionTop32 = getPlayer(self.data.top32[self.index + (self.page - 1)*8].uid,self.data)
		_,self.myPositionTop4 = getPlayerInTop4(self.data.top32[self.index + (self.page - 1)*8].uid,self.data)
		self.myInfo = self.data.top32[self.index + (self.page - 1)*8]
		PvpController:getLastTeam(function(res1)
			self.team = res1.data.last_team
			self.rank = res1.data.rank
			PvpController.show(PvpPlayerInfoPanel, ELF_SHOW.SLIDE_IN)
		end,self.myInfo.uid)
	elseif self.stype == 2 then
		self.myPositionTop4 = self.index --getPlayerInTop4(self.data.top32[self.index + (self.page - 1)*8].uid,self.data)
		-- print(self.data.top32[getPlayerInTop4(self.index) + 1].uid)
		print(self.data.top4[self.index] + 1)
		self.myPositionTop32 = self.data.top4[self.index] + 1
		self.myInfo = self.data.top32[self.data.top4[self.index] + 1]
		PvpController:getLastTeam(function(res1)
			self.team = res1.data.last_team
			self.rank = res1.data.rank
			PvpController.show(PvpPlayerInfoPanel, ELF_SHOW.SLIDE_IN)
		end,self.myInfo.uid)
	end
end