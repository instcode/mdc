require 'ceremony/panel/beautiesz'

function genGetBeautiesPanel(girlId)
	local root
	local getGirlImg
	local getGirlBg
	local zhanIco
	local clickEnable = false

	local function showRoleEnd()
		clickEnable = true
	end

	local function shakyEnd()
		root:getContainerNode():setGrid(nil)
		zhanIco:setVisible(true)
		zhanIco:setScale(2.5)
		local pScaleSmall = CCScaleTo:create(0.2, 1, 1)
		local fadeIn = CCFadeIn:create(0.2)
		local spa = CCSpawn:createWithTwoActions(pScaleSmall,fadeIn)
		local actArr = CCArray:create()
        actArr:addObject(spa)
        actArr:addObject(CCCallFunc:create(showRoleEnd))
		local seq = CCSequence:create(actArr)
		zhanIco:runAction(seq)
	end

	local function roleActionEnd()
		--粒子特效
		local pSnow1  =  CCParticleSystemQuad:create("particles/success1.plist")
		local pSnow2  =  CCParticleSystemQuad:create("particles/success2.plist")
		pSnow1:setPosition(ccp(220,340))
		pSnow2:setPosition(ccp(220,240))
		getGirlImg:getValidNode():addChild(pSnow1, 0)
		getGirlImg:getValidNode():addChild(pSnow2, 0)
		--背景光转起来
		local actionRotate = CCRotateBy:create(7.5, 360)
		getGirlBg:runAction(CCRepeatForever:create(actionRotate))
		getGirlBg:setVisible(true)

		local shaky = CCShaky3D:create(0.2, CCSizeMake(15,10), 6, false)
		local actArr = CCArray:create()
        actArr:addObject(shaky)
        actArr:addObject(CCCallFunc:create(shakyEnd))
		local seq = CCSequence:create(actArr)
		root:runAction(seq)
	end

	local sceneObj = SceneObjEx:createObj('panel/get_beauty_panel.json', 'get-beauty-lua')
	local panel = sceneObj:getPanelObj()
	panel:setAdaptInfo('get_girl_bg_img', 'get_girl_img')

	panel:registerInitHandler(function()
		local girlConf = GameData:getMapData('girl.dat')
		local girlskillConf = GameData:getMapData('girlskill.dat')
		root = panel:GetRawPanel()

		local getGirlBgImg = tolua.cast(root:getChildByName('get_girl_bg_img'), 'UIImageView')
		getGirlBgImg:registerScriptTapHandler(function()
			if clickEnable then
    			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.SMART_HIDE)
    			genBeautyPanelZ(girlId)
    		end
    	end)

    	getGirlBg = tolua.cast(getGirlBgImg:getChildByName('get_girl_bg'), 'UIImageView')
    	getGirlBg:setVisible(false)

		local infoTx = tolua.cast(root:getChildByName('info_tx'), 'UILabel')
		infoTx:setText(string.format(getLocalStringValue('E_STR_CONGRATULATION_GET_BEAUTY'), GetTextForCfg(girlConf[tostring(girlId)].Name)))
		getGirlImg = tolua.cast(root:getChildByName('get_girl_img'), 'UIImageView')
		local roleImg = tolua.cast(getGirlImg:getChildByName('role_img'), 'UIImageView')
		roleImg:setTexture(girlConf[tostring(girlId)].FullBody)

		local attrBgImg = tolua.cast(getGirlImg:getChildByName('attr_bg_img'), 'UIImageView')
		local attackNumBgIco = tolua.cast(attrBgImg:getChildByName('attack_num_bg_ico'), 'UIImageView')
		local defenseNumBgIco = tolua.cast(attrBgImg:getChildByName('defense_num_bg_ico'), 'UIImageView')
		local magicDefenseNumBgIco = tolua.cast(attrBgImg:getChildByName('magic_defense_num_bg_ico'), 'UIImageView')
		local soldierNumBgIco = tolua.cast(attrBgImg:getChildByName('soldier_num_bg_ico'), 'UIImageView')
		local attackNumTx = tolua.cast(attackNumBgIco:getChildByName('attack_num_tx'), 'UILabel')
		local attack = tonumber(string.split(girlskillConf[tostring(girlId)].Attribute1,':')[2])
		attackNumTx:setText('+' .. attack)
		attackNumTx:setColor(COLOR_TYPE.GREEN)
		local defenseNumYx = tolua.cast(defenseNumBgIco:getChildByName('defense_num_tx'), 'UILabel')
		local defense = tonumber(string.split(girlskillConf[tostring(girlId)].Attribute2,':')[2])
		defenseNumYx:setText('+' .. defense)
		defenseNumYx:setColor(COLOR_TYPE.GREEN)
		local magicDefenseNumTx = tolua.cast(magicDefenseNumBgIco:getChildByName('magic_defense_num_tx'), 'UILabel')
		local magicDefense = tonumber(string.split(girlskillConf[tostring(girlId)].Attribute3,':')[2])
		magicDefenseNumTx:setText('+' .. magicDefense)
		magicDefenseNumTx:setColor(COLOR_TYPE.GREEN)
		local soldierNumTx = tolua.cast(soldierNumBgIco:getChildByName('soldier_num_tx'), 'UILabel')
		local soldier = tonumber(string.split(girlskillConf[tostring(girlId)].Attribute4,':')[2])
		soldierNumTx:setText('+' .. soldier)
		soldierNumTx:setColor(COLOR_TYPE.GREEN)

		zhanIco = tolua.cast(getGirlImg:getChildByName('zhan_ico'), 'UIImageView')
		local zhanNumTx = tolua.cast(zhanIco:getChildByName('zhan_num_tx'), 'UILabel')
		local fightForce = tonumber(PlayerCoreData.getPlayerFightForce()) - tonumber(getTempValue('fightForce'))
		zhanNumTx:setText('+' .. fightForce)
		zhanNumTx:setColor(COLOR_TYPE.GREEN)
		zhanIco:setVisible(false)

		-- do action
		roleImg:setScale(2.5)
		local pScaleSmall = CCScaleTo:create(0.2, 1.0, 1.0)
		local fadeIn = CCFadeIn:create(0.2)
		local spa = CCSpawn:createWithTwoActions(pScaleSmall,fadeIn)
		local actArr = CCArray:create()
        actArr:addObject(spa)
        actArr:addObject(CCCallFunc:create(roleActionEnd))
		local seq = CCSequence:create(actArr)
		roleImg:runAction(seq)
		clickEnable = false
	end)
	UiMan.show(sceneObj, ELF_SHOW.NORMAL)
end