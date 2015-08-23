FightForce = {
	sceneObj = nil,
	rootImg = nil,
	widget = nil,
	totalForecTx = nil,
	rolecount = nil,
	isShow = false,
	roleInfo = {}
}
local MINHIGHT = 120
local ONEROLEHIGHT = 40
function FightForce:closePanel()
	if self.isShow then
		CUIManager:GetInstance():HideObject(self.sceneObj, ELF_SHOW.NORMAL)
		self.isShow = false
	end
end
function FightForce:getRoleObject()
	self.rolecount = 0
	self.roleInfo = {}
	for i=1,10 do
		roleMap = CLDObjectManager:GetInst():GetNewRoleObject(i)
		if roleMap then
			if roleMap:IsAssigned() then
				self.rolecount = self.rolecount + 1
				table.insert(self.roleInfo,self.rolecount)
				self.roleInfo[self.rolecount] = roleMap
			end
		end
	end
	self.rootImg:setScale9Enable(true)
	size =CCSizeMake(self.rootImg:getContentSize().width,self.rootImg:getContentSize().height+self.rolecount*ONEROLEHIGHT)
	self.rootImg:setScale9Size(size)
end
function FightForce:InitRoleFightForce()
	table.foreach(self.roleInfo , function(i , value)
		-- local pRoleWid =createWidgetByName("panel/zhan_tips_name_panel.json")
		-- local pTxRoleName =tolua.cast(pRoleWid:getChildByName('role_name_tx'), 'UILabel')
		-- local pTxRoleNum =tolua.cast(pRoleWid:getChildByName('role_num_tx'), 'UILabel')
		local strName = tolua.cast(value,'CLDRoleObject'):GetRoleName()
		local fightforce = tostring( tolua.cast(value,'CLDRoleObject'):GetFightForce())
		local color = tolua.cast(value,'CLDRoleObject'):GetRoleNameColor()
		panel = UIPanel:create()
		pTxRoleName = UILabel:create()
		pTxRoleNum = UILabel:create()

		pTxRoleName:setText(strName)
		pTxRoleNum:setText(fightforce)
		pTxRoleName:setFontSize(20)
		pTxRoleNum:setFontSize(20)
		pTxRoleName:setColor(color)
		pTxRoleNum:setColor(color)
		pTxRoleName:setFontName('Aril')
		pTxRoleNum:setFontName('Aril')
		pTxRoleName:setAnchorPoint(ccp(1.0,0.5))
		pTxRoleNum:setAnchorPoint(ccp(0,0.5))
		pTxRoleName:setPosition(ccp(200,self.totalForecTx:getPosition().y-20-i*ONEROLEHIGHT))
		pTxRoleNum:setPosition(ccp(205,self.totalForecTx:getPosition().y-20-i*ONEROLEHIGHT))
		panel:addChild(pTxRoleName)
		panel:addChild(pTxRoleNum)
		self.rootImg:addChild(panel)
		end)
end
function FightForce:createPanel()
	local panel = nil
	local function init()
		self.widget = panel:GetRawPanel()
		self.rootImg = tolua.cast(self.widget:getChildByName('zhan_tips_img'), 'UIImageView')
		bgsize = self.rootImg:getContentSize();
		self.rootImg:setScale9Enable(true)
		self.rootImg:setPosition(ccp(bgsize.width/2,CCDirector:sharedDirector():getWinSize().height - 100))
		size =CCSizeMake(self.rootImg:getContentSize().width,MINHIGHT)
		self.rootImg:setScale9Size(size)

		-- print(self.rootImg:getPosition().x)
		-- print(self.rootImg:getPosition().y)
		self.totalForecTx = tolua.cast(self.widget:getChildByName('player_num_tx'), 'UILabel')
		str = string.format('%d',PlayerCore:getPlayerFightForce())
		self.totalForecTx:setText(str)
		print(self.totalForecTx:getPosition().x)
		print(self.totalForecTx:getPosition().y)
		self:getRoleObject()
		self:InitRoleFightForce()
		-- self.rootImg:setScale9Enable(true)
		-- size =CCSizeMake(self.rootImg:getContentSize().width,self.rootImg:getContentSize().height+3*ONEROLEHIGHT)
		-- self.rootImg:setScale9Size(size)
		-- pRoleWid =createWidgetByName('panel/zhan_tips_name_panel.json')
		-- -- pRoleWid = tolua.cast(pRoleWid:getChildByName('Panel'), 'UIPanel')
		-- pTxRoleName =tolua.cast(pRoleWid:getChildByName('role_name_tx'), 'UILabel')
		-- pTxRoleName:setText("strName")
		-- pTxRoleName:setVisible(true)
		-- pTxRoleNum =tolua.cast(pRoleWid:getChildByName('role_num_tx'), 'UILabel')
		-- pTxRoleNum:setText("fightforce")
		-- pTxRoleNum:setVisible(true)
		-- pRoleWid:setPosition(ccp(100,-100))
		-- -- pTxRoleName:setPosition(ccp(100,-100))
		-- -- pTxRoleNum:setPosition(ccp(150,-100))
		-- -- pRoleWid:setColor(ccc3(255,0,0))
		-- -- pRoleWid:setVisible(true)
		-- -- pRoleWid:setAnchorPoint(ccp(0.5 , 0.5))
		-- a = UIPanel:create()
		-- -- titleTx = UILabel:create()
		-- -- titleTx:setText('12312312')
		-- -- titleTx:setFontSize(26)
		-- -- titleTx:setPosition(ccp(150,-100))
		-- -- a:setPosition(ccp(0,0))
		-- a:addChild(pRoleWid)
		-- a:setPosition(ccp(100,-100))
		-- self.rootImg:addChild(a)
		-- -- self.rootImg:addChild(pRoleWid)
		-- -- pRoleWid:setPosition(self.totalForecTx:getPosition())

	end
	self.sceneObj = SceneObjEx:createObj('panel/zhan_tips_panel.json', 'fight-force-lua')
    panel = self.sceneObj:getPanelObj()

	panel:registerInitHandler(init)
	CUIManager:GetInstance():ShowObject(self.sceneObj, ELF_SHOW.NORMAL)
	self.isShow = true
end