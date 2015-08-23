
PlayerTips = {
	sceneObj = nil,
	serverTx = nil,
	nameTx = nil,
	levelTx = nil,
	expRateTx = nil,
	expRemainTx = nil,
	isShow = false
}
function getPlayerLevelUpExp(level)
	local curExp = 0
	local prevExp = 0
	local t = GameData:getArrayData('level.dat')
	table.foreach(t, function ( _, v )
		if tonumber(v.Level) == level - 1 then
			prevExp = v.Xp
		end
		if tonumber(v.Level) == level then
			curExp = v.Xp
			return
		end
	end)
	return curExp - prevExp
end
function PlayerTips:closePanel()
	if self.isShow then
		CUIManager:GetInstance():HideObject(self.sceneObj, ELF_SHOW.NORMAL)
		self.isShow = false
	end
end
function PlayerTips:createPanel()
	local panel = nil
	local function updatePanel()
		str = PlayerCore:getServerName()
		serverTx:setText(str)

		plaerNmae = PlayerCoreData.getPlayerName()
		nameTx:setText(plaerNmae)

		pSelf = PlayerCore:getSelfObject()
		level = PlayerCoreData.getPlayerLevel()
		levelUpExp = getPlayerLevelUpExp(level)
		exp = PlayerCoreData.getPlayerExp()
		PlayerCore:JudegeIsReachMaxLevel(level,0)
		if pSelf:IsReachMaxLevelAndFullExp() then
			level = pSelf:GetMaxLevel()
			exp = pSelf:GetMaxLevelUpExp()
			levelUpExp = pSelf:GetMaxLevelUpExp()
		end
		-- buffer = string.format('%d%s',level,getLocalStringValue("level"))
		levelTx:setText(level);

		buffer = string.format('%d/%d',exp,levelUpExp)
		expRateTx:setText(buffer)

		buffer = string.format('%d',levelUpExp - exp)
		expRemainTx:setText(buffer)

		playerIdTx:setPreferredSize(226,1)
		playerIdTx:setText(PlayerCore:getPlayerOpenID())
	end

	local function init()
		widget = panel:GetRawPanel()
		bgImg = tolua.cast(widget:getChildByName('player_info_bg_img'), 'UIImageView')
		local winSize = CCDirector:sharedDirector():getWinSize()
		bgsize = bgImg:getContentSize();
		bgImg:setPosition(ccp(bgsize.width*2/5, winSize.height - bgsize.height*2/5))
		serverTx = tolua.cast(widget:getChildByName('server_name_tx'), 'UILabel')
		nameTx = tolua.cast(widget:getChildByName('player_name_tx'), 'UILabel')
		levelTx = tolua.cast(widget:getChildByName('lv_num_tx'), 'UILabel')
		expRateTx = tolua.cast(widget:getChildByName('exp_num_tx'), 'UILabel')
		expRemainTx = tolua.cast(widget:getChildByName('exp_num_1_tx'), 'UILabel')
		playerIdTx = tolua.cast(widget:getChildByName('player_id_tx'), 'UILabel')
		updatePanel()
	end
	self.sceneObj = SceneObjEx:createObj('panel/player_info_tips_panel.json', 'player-tips-lua')
   	panel = self.sceneObj:getPanelObj()
	-- widget =createWidgetByName("panel/player_info_tips_panel.json")
	panel:registerInitHandler(init)
	
	CUIManager:GetInstance():ShowObject(self.sceneObj, ELF_SHOW.NORMAL)
	self.isShow = true
end
