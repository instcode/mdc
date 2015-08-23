genRankHighestPanel = function ( cash , myRank , historyRank )

	local function createPanel()

		local function getChild( parent , name , ttype )
			return tolua.cast(parent:getChildByName(name) , ttype)
		end
		
		local sceneObj = SceneObjEx:createObj('panel/rank_highest_panel.json' , 'WbossRewardHelpPanel-in-lua')
		local panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('highest_bg_img' , 'highest_img')

		panel:registerInitHandler(function ()
			local root = panel:GetRawPanel()
		
			local getAwardBtn = getChild(root ,'get_award_btn' , 'UIButton')
			getAwardBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
			GameController.addButtonSound(getAwardBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			local infoBg = getChild(root , 'info_bg_img' , 'UIImageView');
			local historyRankTx = getChild(infoBg , 'history_num_tx' , 'UILabel')
			local myRankTx = getChild(infoBg , 'cur_num_tx' , 'UILabel')
			local addNumTx = getChild(infoBg , 'add_num_tx' , 'UILabel')
			local addCashTx = getChild(infoBg , 'award_num_tx' , 'UILabel')

			historyRankTx:setText( tostring(historyRank) )
			myRankTx:setText( tostring(myRank) )
			addCashTx:setText( tostring(cash) )
			addNumTx:setText( tostring( historyRank - myRank) .. ')')

		end)

		UiMan.show(sceneObj)
	end
	
	createPanel()
end