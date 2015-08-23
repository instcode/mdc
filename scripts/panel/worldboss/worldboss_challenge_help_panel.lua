genWorldBossChallengeHelpPanel = function ()
	local function getChild( parent , name , ttype )
		return tolua.cast(parent:getChildByName(name) , ttype)
	end

	local function createPanel()
		local sceneObj = SceneObjEx:createObj('panel/boss_challenge_help_panel.json' , 'bossChallengeHelpPanel-in-lua')
		local panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('boss_help_bg_img' , 'boss_help_img')

		panel:registerInitHandler(function ()
			local root = panel:GetRawPanel()
		
			local closeBtn = getChild(root ,'close_btn' , 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
			
			local knowBtn = getChild(root ,'know_btn' , 'UITextButton')
			knowBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
			GameController.addButtonSound(knowBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			
			local awardBg = getChild(root ,'boss_help_bg_img' , 'UIImageView')
			awardBg:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))

			local infoBg = getChild(root ,'boss_help_img' , 'UIImageView')

			local helpSv = getChild(infoBg,'help_sv','UIScrollView')
    		helpSv:setClippingEnable(true)
    		helpSv:scrollToTop()

			local infoTx1 = tolua.cast(infoBg:getChildByName('info_1_tx'), 'UILabel')
			infoTx1:setText(getLocalStringValue('HELP_BOSS_AWARD_1'))
			infoTx1:setPreferredSize(605,1)
			local infoTx2 = tolua.cast(infoBg:getChildByName('info_2_tx'), 'UILabel')
			infoTx2:setText(getLocalStringValue('HELP_BOSS_AWARD_2'))
			infoTx2:setPreferredSize(605,1)
			local infoTx3 = tolua.cast(infoBg:getChildByName('info_3_tx'), 'UILabel')
			infoTx3:setText(getLocalStringValue('HELP_BOSS_AWARD_3'))
			infoTx3:setPreferredSize(605,1)
			local infoTx4 = tolua.cast(infoBg:getChildByName('info_4_tx'), 'UILabel')
			infoTx4:setText(getLocalStringValue('HELP_BOSS_AWARD_4'))
			infoTx4:setPreferredSize(605,1)	
			local infoTx5 = tolua.cast(infoBg:getChildByName('info_5_tx'), 'UILabel')
			infoTx5:setText(getLocalStringValue('HELP_BOSS_AWARD_5'))
			infoTx5:setPreferredSize(605,1)
			local infoTx6 = tolua.cast(infoBg:getChildByName('info_6_tx'), 'UILabel')
			infoTx6:setText(getLocalStringValue('HELP_BOSS_AWARD_6'))
			infoTx6:setPreferredSize(605,1)	
			local infoTx7 = tolua.cast(infoBg:getChildByName('info_7_tx'), 'UILabel')
			infoTx7:setText(getLocalStringValue('HELP_BOSS_AWARD_7'))
			infoTx7:setPreferredSize(605,1)	
		end)

		UiMan.show(sceneObj)
	end
	
	createPanel()
end