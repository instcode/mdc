PvpMyReportsPanel = PvpView:new{
	jsonFile = 'panel/my_record_bg_panel.json',
	panelName = 'my-reports-in-lua',
	myPositionTop32,
	myPositionTop4,
	listSv,
	myProgress,
	isEnd = -1,
	bgCount = 0
}

function getPlayer(uid,data)
	local index = 0
	local tab = {}
	for i,v in ipairs(data.top32) do
		if tostring(uid) == tostring(data.top32[i].uid) then
			index = i
			tab = data.top32[i]
		end
	end
	return tab,index
end

function getPlayerInTop4(uid,data)
	local index = 0
	local tab = {}
	for i,v in ipairs(data.top4) do
		if tostring(uid) == tostring(data.top32[data.top4[i] + 1].uid) then
			index = i
			tab = data[i]
		end
	end
	return tab,index
end

function getEnemyIndex(index)
	if index %2 == 0 then 
		index1 = index - 1
	else
		index1 = index + 1
	end
	return index1
end

function getMosterConf(uid)
	pMonCfg = GameData:getArrayData('monster.dat')
	local tab = {}
	for i,v in ipairs(pMonCfg) do
		if tonumber(uid) == tonumber(v.Id) then
			tab = v
		end
	end
	return tab
end
function getMosterInfo(uid)
	local data = {}
	conf = getMosterConf(uid)
	if not conf then
		return
	end
	-- data.bgRes = 'uires/ui_2nd/com/panel/common/frame.png'
	data.frameRes = 'uires/ui_2nd/com/panel/common/frame.png'
	data.iconRes =  'uires/ui_2nd/image/'..string.gsub(conf.URL,'_big','_icon')
	data.big = 'uires/ui_2nd/image/'..conf.URL
	data.name = conf.Name
	return data
end

function PvpMyReportsPanel:getMyEnemyIndex(stype,index)
	if stype == 1 then
		myIndex = self.myPositionTop32
		return getEnemyIndex(myIndex)
	elseif stype == 4 then
		return self.data.top4[getEnemyIndex(index)] + 1
	elseif stype == 5 then
		return self.data.records[getEnemyIndex(28 + (index + index%2)/2)] + 1
	else
		return self.data.records[getEnemyIndex(index)] + 1
	end
end

function PvpMyReportsPanel:updateCellPanel(replayInfo,view,isWin,stype,index)
	resultImg = tolua.cast(view:getChildByName('results_img') , 'UIImageView')
	serverNumTx = tolua.cast(view:getChildByName('server_num_tx') , 'UILabel')
	nameTx = tolua.cast(view:getChildByName('opponent_name_tx') , 'UILabel')
	playTx = tolua.cast(view:getChildByName('play_tx') , 'UILabel')
	reportBtn = tolua.cast(view:getChildByName('report_btn') , 'UIButton')
	if isWin == false then
		resultImg:setTexture('uires/ui_2nd/com/panel/pvp/bai.png')
	end
	-- print(self.data.top32[self.data.records[getEnemyIndex(index)] + 1].name)
	-- print(self.data.top32[self.data.records[getEnemyIndex(index)] + 1].serverid)
	enemyIndex = self:getMyEnemyIndex(stype,index)
	enemy = self.data.top32[enemyIndex]
	serverNumTx:setText(enemy.serverid)
	nameTx:setText(enemy.name)
	-- GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC2'), COLOR_TYPE.RED)
	if stype == 1 then
		playTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC5'),32,16))
	elseif stype == 2 then
		playTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC5'),16,8))
	elseif stype == 3 then
		playTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC5'),8,4))
	elseif stype == 4 then
		playTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC5'),4,2))
	elseif stype == 5 then
		playTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC5'),2,1))
	else
		playTx:setText('')
	end

	reportBtn:registerScriptTapHandler(function ()
		PvpController:getReplay(function(res)
			if res.data.battle then
				GameController.clearAwardView()
				GameController.playBattle(json.encode(res.data.battle) , 5)
			end
		end,replayInfo.rid)
	end)
	GameController.addButtonSound(reportBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
end

function PvpMyReportsPanel:updateLoseInfo()
	if self.isEnd == 1 then
		self.infoTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC6'),32,16))
	elseif self.isEnd == 2 then
		self.infoTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC6'),16,8))
	elseif self.isEnd == 3 then
		self.infoTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC6'),8,4))
	elseif self.isEnd == 4 then
		self.infoTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC6'),4,2))
	elseif self.isEnd == 5 then
		self.infoTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC6'),2,1))
	elseif self.isEnd == 0 then
		if self.data.progress == PROGRESS.SUPPORT4 then
			self.infoTx:setText(getLocalStringValue('E_STR_PVP_WAR_DESC17'))
		elseif self.data.progress == PROGRESS.SUPPORT1 then
			self.infoTx:setText(getLocalStringValue('E_STR_PVP_WAR_DESC18'))
		else
			self.infoTx:setText(getLocalStringValue('E_STR_PVP_WAR_DESC7'))
		end
	elseif self.isEnd == 6 then
		self.infoTx:setText(getLocalStringValue('E_STR_PVP_WAR_DESC10'))
	else
		self.infoTx:setText(getLocalStringValue('E_STR_PVP_WAR_DESC8'))
	end

end

function PvpMyReportsPanel:createCellPanel(index,stype,lastIndex)
	local isOut = false
	local isWin = false
	local loseTime = 0
	local winTime = 0
	if not self.data.replays[index] then
		return false
	end
	for i=1,#self.data.replays[index] do
		self.bgCount = self.bgCount + 1
		if self.myPositionTop32 == self.data.replays[index][i].win + 1 then
			isWin = true
			winTime = winTime + 1
		else
			isWin = false
			loseTime = loseTime + 1
		end
		local view = createWidgetByName('panel/my_record_nei_panel.json')
		self:updateCellPanel(self.data.replays[index][i],view,isWin,stype,lastIndex)
		bgImg = tolua.cast(view:getChildByName('bg_img') , 'UIImageView')
		if self.bgCount % 2 == 1 then
			bgImg:setVisible(false)
		else
			bgImg:setVisible(true)
		end
		self.listSv:addChildToBottom(view)
	end
	self.listSv:scrollToTop()
	if loseTime >= 3 then
		self.isEnd = stype
		return false
	elseif stype == 5 and winTime >= 3 then
		self.isEnd = 6
	end
	return true
end

function PvpMyReportsPanel:updareMainPanel()
	local index = 1
	if self.myPositionTop32 <= 0 then
		return
	end
	self.isEnd = 0
	local temIndex
	temIndex = (self.myPositionTop32 + self.myPositionTop32 % 2)/2
	top16index = temIndex
	if self:createCellPanel(top16index,1) == false then
		return
	end

	temIndex = (temIndex + temIndex % 2 )/2
	top8index = 16 + temIndex
	if self:createCellPanel(top8index,2,top16index) == false then
		return
	end

	temIndex = (temIndex + temIndex % 2 )/2
	top4index = 24 + temIndex
	if self:createCellPanel(top4index,3,top8index) == false then
		return
	end

	if self.myPositionTop4 <= 0 then
		return
	end
	top2index = 28 + (self.myPositionTop4 + self.myPositionTop4 % 2 ) /2
	if self:createCellPanel(top2index,4,self.myPositionTop4) == false then
		return
	end

	top1index = 31
	if self:createCellPanel(top1index,5,self.myPositionTop4) == false then
		return
	end
end

function PvpMyReportsPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('my_record_bg_img','my_record_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()

		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		helpBtn = tolua.cast(root:getChildByName('help_btn') , 'UIButton')
    	helpBtn:registerScriptTapHandler(function ()
			PvpController.show(PvpMyReportsHelpPanel, ELF_SHOW.SLIDE_IN)
		end)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
		
		self.infoTx = tolua.cast(root:getChildByName('info_tx') , 'UILabel')
		self.infoTx:setPreferredSize(740,1)
		self.infoTx:setText(getLocalStringValue('E_STR_PVP_WAR_DESC8'))

		self.listSv = tolua.cast(root:getChildByName('list_sv') , 'UIScrollView')
		self.listSv:setClippingEnable(true)

		self:updareMainPanel()
		self:updateLoseInfo()
	end)
end

function PvpMyReportsPanel:enter(res)
	self.data = res
	_,self.myPositionTop32 = getPlayer(PlayerCoreData.getUID(),self.data)
	_,self.myPositionTop4 = getPlayerInTop4(PlayerCoreData.getUID(),self.data)
	PvpController.show(PvpMyReportsPanel, ELF_SHOW.SLIDE_IN)
end