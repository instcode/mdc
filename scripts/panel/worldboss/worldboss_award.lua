genWorldBossAwardTips = function ()
	local FILENAME = 'worldbossreward.dat'
	local NUM = 5
	local sceneObj
	local root
	local tipsPanel
	local longPressed = false

	local function getChild( parent , name , ttype )
		return tolua.cast(parent:getChildByName(name) , ttype)
	end

	local function getConfData()
		local conf = GameData:getArrayData( FILENAME )
		-- if conf[tonumber(id)] then
		-- 	return conf[tonumber(id)]
		-- end
		-- return nil
		return conf
	end

	-- local function hideAwardTips()
	-- 	if longPressed then 
	-- 		tipsPanel:removeFromParentAndCleanup(true)
	-- 		longPressed = false
	-- 		return
	-- 	end
	-- end

	-- local function onShowTips( id  , parent)
	-- 	local data = getConfData(id)
	-- 	if data == nil then
	-- 		return 
	-- 	end

	-- 	tipsPanel = UIImageView:create()
	-- 	tipsPanel:setTexture('uires/ui_2nd/com/panel/mainscene/zhan_tips.png')
	-- 	tipsPanel:setScale9Enable(true)
	-- 	tipsPanel:setAnchorPoint(ccp(0, 0))

	-- 	-- add award item
	-- 	local keyTab = {'Award1' , 'Award2'}
	-- 	local defaultX = 74
	-- 	local finalX = 0
	-- 	local length = 0
	-- 	for _, v in pairs (keyTab) do
	-- 		if data[v] and data[v] ~= '' then
	-- 			local tab = UserData:getAward( data[v] )

	-- 			local item = GameController.createItem( tab )
	-- 			item:setPosition( ccp( defaultX + length * 110 , 100) )
	-- 			finalX = defaultX + length * 110

	-- 			tipsPanel:addChild(item)

	-- 			length = length + 1
	-- 		end
	-- 	end

	-- 	tipsPanel:setScale9Size(CCSizeMake(finalX + defaultX , 160))

	-- 	tipsPanel:setPosition(ccp(-130 , 50))
	-- 	tipsPanel:setWidgetZOrder(999)
	-- 	parent:addChild(tipsPanel)

	-- 	longPressed = true
	-- end
	local function updateCell(id,rewardVView)
		local cardImg  = getChild(rewardVView ,'card_img' , 'UIImageView')
		local numberTx  = getChild(cardImg ,'number_tx' , 'UILabel')
		local diTx  = getChild(cardImg ,'di_tx' , 'UILabel')
		local mingTx  = getChild(cardImg ,'ming_tx' , 'UILabel')
		local otherTx  = getChild(cardImg ,'other_tx' , 'UILabel')
		local awardImg  = getChild(cardImg ,'award_bg_img' , 'UIImageView')
		local photoIco1  = getChild(awardImg ,'photo_1_ico' , 'UIImageView')
		local awardIco1  = getChild(photoIco1 ,'award_ico' , 'UIImageView')
		local awardNumTx1  = getChild(photoIco1 ,'award_num_tx' , 'UILabel')
		local awardNameTx1  = getChild(photoIco1 ,'award_name_tx' , 'UILabel')
		local photoIco2  = getChild(awardImg ,'photo_2_ico' , 'UIImageView')
		local awardIco2  = getChild(photoIco2 ,'award_ico' , 'UIImageView')
		local awardNumTx2  = getChild(photoIco2 ,'award_num_tx' , 'UILabel')
		local awardNameTx2  = getChild(photoIco2 ,'award_name_tx' , 'UILabel')
		awardNameTx1:setPreferredSize(120,1)
		awardNameTx2:setPreferredSize(150,1)

		local conf = getConfData()
		local data = conf[id]
		if data == nil then
			return 
		end
		local tab1 = UserData:getAward( data['Award1'] )
		awardNumTx1:setText(tonumber(tab1.count))
		awardIco1:setTexture(tab1.icon)
		awardNameTx1:setText(tab1.name)
		awardNameTx1:setColor(tab1.color)
		photoIco1:setTouchEnable(true)
		photoIco1:registerScriptTapHandler(function()
			UISvr:showTipsForAward(data['Award1'])
		end)
		local tab2 = UserData:getAward( data['Award2'] )
		awardNumTx2:setText(tonumber(tab2.count))
		awardIco2:setTexture(tab2.icon)
		awardNameTx2:setText(tab2.name)
		awardNameTx1:setColor(tab2.color)
		photoIco2:setTouchEnable(true)
		photoIco2:registerScriptTapHandler(function()
			UISvr:showTipsForAward(data['Award2'])
		end)
		-- numberTx:setFontSize(50)
		if id == 1 then
			data1 = conf[id + 1]
			if tonumber(data1['HurtRank']) - 1 == tonumber(data['HurtRank']) then
				numberTx:setText(data['HurtRank'])
				diTx:setPosition(ccp(120,80))
				mingTx:setPosition(ccp(170,80))
				else
				numberTx:setText(data['HurtRank']..'~'..(tonumber(data1['HurtRank']) - 1))
				diTx:setPosition(ccp(100,80))
				mingTx:setPosition(ccp(220,80))
			end
			diTx:setVisible(true)
			mingTx:setVisible(true)
			otherTx:setVisible(false)
			elseif id == 2 then
				-- numberTx:setText('2~10')
				data1 = conf[id + 1]
				numberTx:setText(data['HurtRank']..'~'..(tonumber(data1['HurtRank']) - 1))
				diTx:setVisible(true)
				mingTx:setVisible(true)
				otherTx:setVisible(false)
				diTx:setPosition(ccp(90,80))
				mingTx:setPosition(ccp(200,80))
				elseif id ==3 then
					-- numberTx:setText('11~20')
					data1 = conf[id + 1]
					numberTx:setText(data['HurtRank']..'~'..(tonumber(data1['HurtRank']) - 1))
					diTx:setVisible(true)
					mingTx:setVisible(true)
					otherTx:setVisible(false)
					diTx:setPosition(ccp(80,80))
					mingTx:setPosition(ccp(210,80))
					elseif id == 4 then
						-- numberTx:setText('21~50')
						data1 = conf[id + 1]
						numberTx:setText(data['HurtRank']..'~'..(tonumber(data1['HurtRank']) - 1))
						diTx:setVisible(true)
						mingTx:setVisible(true)
						otherTx:setVisible(false)
						diTx:setPosition(ccp(80,80))
						mingTx:setPosition(ccp(210,80))
					else
						-- numberTx:setText('50     ')
						numberTx:setText((tonumber(data['HurtRank']) - 1)..'     ')
						numberTx:setPosition(ccp(100,80))
						diTx:setVisible(false)
						mingTx:setVisible(false)
						otherTx:setVisible(true)
		end
		if id == 1 then
			numberTx:setColor(ccc3(255,255, 0))
			diTx:setColor(ccc3(255,255, 0))
			mingTx:setColor(ccc3(255,255, 0))
		else
			numberTx:setColor(COLOR_TYPE.WHITE)
			diTx:setColor(COLOR_TYPE.WHITE)
			mingTx:setColor(COLOR_TYPE.WHITE)
		end
	end
	local function createCell()
		local sv = getChild(root ,'card_bg_sv' , 'UIScrollView')
		sv:setClippingEnable(true)
    	sv:setDirection(SCROLLVIEW_DIR_VERTICAL)
		for i=1,NUM do
			local rewardVView = createWidgetByName('panel/boss_tips_cell.json')
			-- local rewardPhoto  = getChild(rewardVView ,'item_photo' , 'UIImageView')
			updateCell(i,rewardVView)
			sv:addChildToBottom(rewardVView)
		end
		sv:scrollToTop()
	end
	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/boss_tips.json' , 'worldbossaward-in-lua')
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

			local closeBtn = getChild(tipsbg ,'card' , 'UIButton')
			createCell()
			-- for i = 1 , NUM do
			-- 	local boxItem = getChild(root ,'box_' .. i .. '_ico' , 'UIImageView')
			-- 	boxItem:registerScriptLongPressHandler(function ()
			-- 		onShowTips( i , boxItem)
			-- 	end)
			-- 	boxItem:registerScriptTapHandler( function ()
			-- 		hideAwardTips()
			-- 	end)
			-- 	boxItem:registerScriptCancelHandler(function ()
			-- 		hideAwardTips()
			-- 	end)
			-- end

		end)

		UiMan.show(sceneObj)
	end

	createPanel()
end