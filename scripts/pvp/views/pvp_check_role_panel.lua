PvpCheckRolePanel = PvpView:new{
	jsonFile = 'panel/pvp_roles_panel.json',
	panelName = 'pvp-check-role-in-lua',
	fightForce = 0
}

function PvpCheckRolePanel:updateAwardsPanel()
	local panel = self.sceneObject:getPanelObj()
	root = panel:GetRawPanel()
	local index = 1
	for i,v in pairs(self.resData.infos) do
		-- index = tonumber(i) + 1
		if index <= 7 and v ~= 0 then

			str = 'role_'..index..'_img'
			roleImg = tolua.cast(root:getChildByName(str) , 'UIImageView')
			roleIco = tolua.cast(roleImg:getChildByName('role_ico') , 'UIImageView')
			roleNameTx = tolua.cast(roleImg:getChildByName('role_name_tx') , 'UILabel')
			zhanNumTx = tolua.cast(roleImg:getChildByName('zhan_num_tx') , 'UILabel')

			local framRes,iconRes,fightforce,strName,color
			if tonumber(self.data.uid) < 100000 then
				tab = getMosterInfo(self.resData.infos[i].id)
				framRes = tab.bgRes
				iconRes = tab.iconRes
				strName = tab.name
				color = COLOR_TYPE.BLUE
			else
				pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject( self.resData.infos[i].id, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
				pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
				framRes = pRoleCardObj:GetIconFrame()
				iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON)
				strName = pRoleCardObj:GetRoleName()
				color = pRoleCardObj:GetRoleNameColor()
			end
			fightforce =  self.resData.infos[i].fight_force
			roleIco:setTexture(iconRes)
			roleIco:setAnchorPoint(ccp(0,0))
			roleNameTx:setText(GetTextForCfg(strName))
			roleNameTx:setColor(color)
			zhanNumTx:setText(fightforce)

			--  设置光圈
		    local light = CUIEffect:create()
			light:Show("yellow_light",0)
			light:setScale(0.8)
			contentSize = roleImg:getContentSize()
			
			light:setAnchorPoint(ccp(0,0))
			light:setTag(100)
			light:setZOrder(100)
			light:setVisible(true)

			if framRes == 'uires/ui_2nd/com/panel/common/frame_sred.png' then
				roleImg:getContainerNode():addChild(light)
			end
			light:setPosition( ccp(-13 , -13))
			roleImg:setTexture(framRes)
			roleImg:setAnchorPoint(ccp(0,0))
			roleImg:setVisible(true)
			index = index + 1
			self.fightForce = self.fightForce + fightforce
		end
	end
	self.zhanNumLa:setStringValue(self.fightForce)
end

function PvpCheckRolePanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('have_role_img','have_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		nameTx = tolua.cast(root:getChildByName('name_tx') , 'UILabel')
		nameTx:setText(self.data.name)

		rankingNumTx = tolua.cast(root:getChildByName('ranking_num_tx') , 'UILabel')
		rankingNumTx:setText(self.index)

		self.zhanNumLa = tolua.cast(root:getChildByName('zhan_num_la') , 'UILabelAtlas')

		self.fightForce = 0
		self:updateAwardsPanel(panel)
	end)
end

function PvpCheckRolePanel:enter(data,index)
	self.data = data
	self.index = index
	-- PvpController:getUserInfo(function(res)
	-- 	self.resData = res.data
	-- 	PvpController.show(PvpCheckRolePanel, ELF_SHOW.SLIDE_IN)
	-- end,uid)

	PvpController:getUserInfo(function(res)
		self.resData = res.data
		PvpController.show(PvpCheckRolePanel, ELF_SHOW.SLIDE_IN)
	end,self.data.uid)
end