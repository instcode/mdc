genTowerAwardPanel = function (currNum)
	local nowNum =  currNum
	local NUM = 20
	local sceneObj
	local root
	local conf = GameData:getArrayData('tower.dat')

	local function getChild( parent , name , ttype )
		return tolua.cast(parent:getChildByName(name) , ttype)
	end

	local function updateCell(id,view)
		local cardImg  = getChild(view ,'card_img' , 'UIImageView')
		local infoTx1  = getChild(cardImg ,'info_1_tx' , 'UILabel')
		local infoTx2  = getChild(cardImg ,'info_2_tx' , 'UILabel')
		local numTx  = getChild(cardImg ,'num_tx' , 'UILabel')
		local awardImg  = getChild(cardImg ,'award_bg_img' , 'UIImageView')
		local photoIco  = getChild(awardImg ,'photo_ico' , 'UIImageView')
		local awardIco  = getChild(photoIco ,'award_ico' , 'UIImageView')
		local awardNumTx = getChild(photoIco ,'award_num_tx' , 'UILabel')
		local awardNameTx  = getChild(photoIco ,'award_name_tx' , 'UILabel')
		awardNameTx:setPreferredSize(150,1)

		local nowId = id * 5
		local data = conf[nowId]
		numTx:setText(nowId)
		if data == nil then
			return 
		end
		local tab = UserData:getAward(data.Award1)
		awardNumTx:setText(tonumber(tab.count))
		awardIco:setTexture(tab.icon)
		awardNameTx:setText(tab.name)
		awardNameTx:setColor(tab.color)
		awardIco:setTouchEnable(true)
		awardIco:registerScriptTapHandler(function()
			UISvr:showTipsForAward(data.Award1)
		end)
		if nowId <= nowNum then
			infoTx2:setText('('..getLocalStringValue('E_STR_ARENA_AWARD_DESC2')..')')
			infoTx2:setColor(ccc3(0,255,0))
		else
			infoTx2:setText('('..getLocalStringValue('E_STR_ARENA_AWARD_DESC1')..')')
			infoTx2:setColor(ccc3(255,0,0))
		end
	end
	local function createCell()
		local sv = getChild(root ,'card_bg_sv' , 'UIScrollView')
		sv:setClippingEnable(true)
    	sv:setDirection(SCROLLVIEW_DIR_VERTICAL)
		for i=1,NUM do
			local view = createWidgetByName('panel/tower_award_cell.json')
			updateCell(i,view)
			sv:addChildToBottom(view)
		end
		sv:scrollToTop()
	end
	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/tower_award_pane.json' , 'tower-award-in-lua')
		local panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('tips_bg_img' , 'tips_img')

		panel:registerInitHandler(function ()
			root = panel:GetRawPanel()
			local bg = getChild(root ,'tips_bg_img' , 'UIImageView')
			local tipsbg = getChild(bg ,'tips_img' , 'UIImageView')
			local closeBtn = getChild(tipsbg ,'close_btn' , 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
			bg:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			createCell()
		end)

		UiMan.show(sceneObj)
	end

	createPanel()
end