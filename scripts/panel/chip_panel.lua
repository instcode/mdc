


function openChipPanel()
	local sceneObj
	local panel
	local cardSv
	local getCardSv
	local getScene
	local getPanel
	local views = {}
	local getViews = {}
	local confList = {}
	local confListNotMerge = {}
	local open = {}
	local notOpen = {}
	local lights = {}

	local conf = GameData:getArrayData('chip.dat')
	local dropConf = GameData:getArrayData('chipdrop.dat')
	local materialConf = GameData:getArrayData('material.dat')
	local roleConf = GameData:getArrayData('role.dat')
	local path = 'uires/ui_2nd/image/'

	local function getPos(i)
		local x = 7 + 445 * ((i-1)%2)
		local y = 200 - ((i-1) - (i-1)%2)/2*130
		-- print(x..'                 '..y)
		return ccp(x,y)
	end


	local function getColor( color )
		if color == 'blue' then
			return COLOR_TYPE.BLUE
		elseif color == 'purple' then
			return COLOR_TYPE.PURPLE
		elseif color == 'orange' then
			return COLOR_TYPE.ORANGE
		elseif color == 'sred' or color == 'ared' or color == 'red' then
			return COLOR_TYPE.RED
		end
		return COLOR_TYPE.BLUE
	end

	local function getChipMaterialInfo(id)
		local chip = {}
		for i,v in ipairs(materialConf) do
			-- print(i,v)
			if tonumber(id) == tonumber(v.Id) then
				chip = v
				return chip
			end
		end
	end

	local function getChipRoleInfo(id)
		local chip = {}
		for i,v in ipairs(roleConf) do
			-- print(i,v)
			if tonumber(id) == tonumber(v.Id) then
				chip = v
				return chip
			end
		end
	end

	local function lightSetVisible(i,frameImg)
		if not lights[i] then
			local light = CUIEffect:create()
			light:Show("yellow_light", 0)
			light:setScale(0.81)
			light:setPosition( ccp(0, 0))
			light:setAnchorPoint(ccp(0.5, 0.5))
			frameImg:getContainerNode():addChild(light)
			light:setZOrder(100)
			table.insert(lights,i)
			lights[i] = light
		end
	end

	local function updateGetList(tab)
		open = {}
		notOpen = {}
		for i,v in ipairs(dropConf) do
			local data = v
			if tonumber(tab[tostring(dropConf[i].Drop)]) ~= 1 then
				table.insert(notOpen,#notOpen + 1)
				notOpen[#notOpen] = data
			else
				table.insert(open,#open + 1)
				open[#open] = data
			end
		end
		-- for i,v in ipairs(notOpen) do
		-- 	local data = v
		-- 	table.insert(open,#open + 1)
		-- 	open[#open] = data
		-- end
	end

	local function updateGetCell(tab)
		
		for i,v in ipairs(getViews) do
			local view = getViews[i]
			if open[i] then
				local isOpen = false
				local infoTx = tolua.cast(view:getChildByName('info_tx') , 'UILabel')
				infoTx:setPreferredSize(480,1)
				local frameImg = tolua.cast(view:getChildByName('frame_img') , 'UIImageView')
				local photoIco = tolua.cast(view:getChildByName('photo_ico') , 'UIImageView')
				local descImg = tolua.cast(view:getChildByName('desc_img') , 'UIImageView')
				local gotoImg = tolua.cast(view:getChildByName('goto_img') , 'UIImageView')
				local openImg = tolua.cast(view:getChildByName('open_img') , 'UIImageView')
				local gotoBtn = tolua.cast(view:getChildByName('goto_btn') , 'UIButton')
				infoTx:setText(GetTextForCfg(open[i].Desc))
				local role = RoleCard:findById(tonumber(tab.RoleId))
				frameImg:setTexture(role:getCardIcoBgImg())
				photoIco:setTexture(open[i].Icon)
				descImg:setTexture(open[i].Url)

				local level = PlayerCoreData.getPlayerLevel()
				local openLevel = tonumber(open[i].Level)
				if open[i].Drop == 'BlackShop' then
					gotoBtn:registerScriptTapHandler(function ()
						if level >= openLevel then
							openShopHeidianPanel()
						else
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_OPEN_LEVEL'),openLevel), COLOR_TYPE.RED)
						end
					end)
				elseif open[i].Drop == 'Altar' then
					gotoBtn:registerScriptTapHandler(function ()
						local battleId = tonumber(tab.Drop)
						if CBattleAPI:getBattleStatusByID(battleId) <= 0 then
							GameController.showMessageBox(getLocalString('E_STR_NOT_OPEN_BOSS'), MESSAGE_BOX_TYPE.OK)
							return
						end

						if level >= openLevel then
							genAltarboard(tonumber(tab.Drop))
						else
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_OPEN_LEVEL'),openLevel), COLOR_TYPE.RED)
						end
					end)
				elseif open[i].Drop == 'PvpShop' then
					gotoBtn:registerScriptTapHandler(function ()
						local openTime = UserData:getOpenServerWarDays()
						local nowTime = UserData:getServerTime()
			    		if not openTime or openTime > nowTime then
			    			GameController.showPrompts(getLocalStringValue('E_STR_PVP_NOT_OPEN'), COLOR_TYPE.RED)
						elseif level >= openLevel then
							require_modules('ceremony/pvp/pvp_dep')
							PvpController.show(PvpShopPanel, ELF_SHOW.SLIDE_IN)
						else
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_OPEN_LEVEL'),openLevel), COLOR_TYPE.RED)
						end
					end)
				elseif open[i].Drop == 'God' then	
					gotoBtn:registerScriptTapHandler(function ()
						if level >= openLevel then
							GodMain.giveGodMain()
						else
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_OPEN_LEVEL'),openLevel), COLOR_TYPE.RED)
						end
					end)
				elseif open[i].Drop == 'Sign' then	
					gotoBtn:registerScriptTapHandler(function ()
						if level >= openLevel then
							New_SignIn.enter()
						else
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_OPEN_LEVEL'),openLevel), COLOR_TYPE.RED)
						end
					end)
				elseif open[i].Drop == 'PawnShop' then	
					gotoBtn:registerScriptTapHandler(function ()
						if level >= openLevel then
							PawnShop.enter(1)
						else
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_OPEN_LEVEL'),openLevel), COLOR_TYPE.RED)
						end
					end)
				elseif open[i].Drop == 'Wheel' then	
					gotoBtn:registerScriptTapHandler(function ()
						if level >= openLevel then
							Wheel.enter()
						else
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_OPEN_LEVEL'),openLevel), COLOR_TYPE.RED)
						end
					end)
				elseif open[i].Drop == 'LuckyCircle' then	
					gotoBtn:registerScriptTapHandler(function ()
						if LuckRunner.isOverTime() == true then
							GameController.showPrompts(getLocalStringValue('E_STR_ACTIVITY_END_DESC'), COLOR_TYPE.RED)
							return
						end
						if level >= openLevel then
							LuckRunner.enter()
						else
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_OPEN_LEVEL'),openLevel), COLOR_TYPE.RED)
						end
					end)
				elseif open[i].Drop == 'LegionShop' then	
					gotoBtn:registerScriptTapHandler(function ()
						if level >= openLevel then
							require_modules('ceremony/legion/legion_dep')
							LegionController.entrance(4)
						else
							GameController.showPrompts(string.format(getLocalStringValue('E_STR_OPEN_LEVEL'),openLevel), COLOR_TYPE.RED)
						end
					end)
				end
				GameController.addButtonSound(gotoBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

				if tonumber(tab[tostring(open[i].Drop)]) == 1 and level > openLevel then
					gotoBtn:setNormalButtonGray(false)
					gotoBtn:setTouchEnable(true)
					openImg:setVisible(false)
					gotoImg:setVisible(true)
				else
					gotoBtn:setNormalButtonGray(true)
					gotoBtn:setTouchEnable(false)
					openImg:setVisible(true)
					gotoImg:setVisible(false)
				end
			else
				getCardSv:removeChildReferenceOnly(view)
			end
		end
	end

	local function createGetCell(tab)
		getViews = {}
		getCardSv:removeAllChildrenAndCleanUp(true)
		for i=1,#dropConf do
			local view = createWidgetByName('panel/chip_goto_cell.json')
			-- updateGetCell(i,view,tab)
			table.insert(getViews,i)
			getViews[i] = view
			getCardSv:addChildToBottom(view)
		end
		updateGetList(tab)
		updateGetCell(tab)
		getCardSv:scrollToTop()
	end

	local function initGetPanel(tab,currCount,name,color)
		root = getPanel:GetRawPanel()
		local getBGImg = tolua.cast(root:getChildByName('chip_get_bg_img') , 'UIImageView')
		getBGImg:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(getScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(getScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local frameImg = tolua.cast(root:getChildByName('frame_img') , 'UIImageView')
		local photoIco = tolua.cast(root:getChildByName('photo_ico') , 'UIImageView')
		local nameTx = tolua.cast(root:getChildByName('name_tx') , 'UILabel')
		local numTx = tolua.cast(root:getChildByName('num_tx') , 'UILabel')

		nameTx:setText(name)
		nameTx:setColor(color)
		numTx:setText(currCount)
		local chip = Material:findById(tonumber(tab.MaterialId))
		local role = RoleCard:findById(tonumber(tab.RoleId))
		frameImg:setTexture(role:getCardIcoBgImg())
		photoIco:setTexture(chip:getResource())
		getCardSv = tolua.cast(root:getChildByName('card_sv') , 'UIListView')
		getCardSv:setClippingEnable(true)
		createGetCell(tab)
	end

	local function createGetPanel(tab,currCount,name,color)
		getScene = SceneObjEx:createObj('panel/chip_goto_panel.json' , 'chip-get-in-lua')
		getPanel = getScene:getPanelObj()
		getPanel:setAdaptInfo('chip_get_bg_img' , 'chip_get_img')
		getPanel:registerInitHandler(function()
			initGetPanel(tab,currCount,name,color)
		end )
		UiMan.show(getScene)
	end

	local function updateList()
		confList = {}
		confListNotMerge = {}
		for i,v in ipairs(conf) do
			local data = v
			local chip = Material:findById(tonumber(conf[i].MaterialId))
			local currCount = tonumber(chip:getCount())
			local totalCount = tonumber(chip:GetMergeNum())
			if currCount < totalCount then
				table.insert(confListNotMerge,#confListNotMerge + 1)
				confListNotMerge[#confListNotMerge] = data
			else
				table.insert(confList,#confList + 1)
				confList[#confList] = data
			end
		end
		for i,v in ipairs(confListNotMerge) do
			local data = v
			table.insert(confList,#confList + 1)
			confList[#confList] = data
		end
	end

	local function updateChipCell()
		for i,v in ipairs(views) do
			local view = v
			local cardImg = tolua.cast(v:getChildByName('card_img') , 'UIImageView')
			local frameImg = tolua.cast(v:getChildByName('fram_img') , 'UIImageView')
			local photoIco = tolua.cast(v:getChildByName('photo_ico') , 'UIImageView')
			-- local frameImg = tolua.cast(v:getChildByName('fram_img') , 'UIImageView')
			local typeImg = tolua.cast(v:getChildByName('type_img') , 'UIImageView')
			local barBgImg = tolua.cast(cardImg:getChildByName('bar_bg_img') , 'UIImageView')
			local chipBar = tolua.cast(barBgImg:getChildByName('chip_bar') , 'UILoadingBar')
			local numTx = tolua.cast(barBgImg:getChildByName('num_tx') , 'UILabel')
			local nameTx = tolua.cast(cardImg:getChildByName('name_tx') , 'UILabel')
			local mergeBtn = tolua.cast(cardImg:getChildByName('merge_btn') , 'UITextButton')
			local chip = Material:findById(tonumber(confList[i].MaterialId))
			local role = RoleCard:findById(confList[i].RoleId)
			local currCount = tonumber(chip:getCount())
			local totalCount = tonumber(chip:GetMergeNum())
			local name = chip:getName()
			local color = chip:getNameColor()
			frameImg:setTexture(role:getCardIcoBgImg())
			photoIco:setTexture(chip:getResource())
			numTx:setText(currCount..'/'..totalCount)
			nameTx:setText(name)
			nameTx:setColor(color)
			typeImg:setTexture(role:getSoldierType())
			lightSetVisible(i,frameImg)
			lights[i]:setVisible(false)

			local quantity = tonumber(role:getQuantity())
			if quantity == 5 then
				lights[i]:setVisible(true)
			end

			chipBar:setPercent(currCount/totalCount*100)
			if currCount < totalCount then
				mergeBtn:setText(getLocalStringValue('E_STR_GOTO_GET'))
			else
				mergeBtn:setText(getLocalStringValue('E_STR_BAG_TO_COMBINE'))
			end

			mergeBtn:registerScriptTapHandler(function ()
				local currCount = tonumber(chip:getCount())
				local totalCount = tonumber(chip:GetMergeNum())
				if currCount < totalCount then
					createGetPanel(confList[i],currCount,name,color)
				else
					args = {
						id = tonumber(confList[i].MaterialId),
						num = tonumber(chip:GetMergeNum()),
						rid = tonumber(confList[i].RoleId)
					}
					Message.sendPost('use','inventory',json.encode(args),function (jsonData)
						print(jsonData)
						local jsonDic = json.decode(jsonData)
						local awards = jsonDic.data.awards
						if tonumber(jsonDic.code) == 0 then
							local awardsData = json.encode(awards)
							UserData.parseAwardJson(awardsData)

							local vStr
							local tab = {}
							if awards then
								local index = 1
								for k,v in pairs(awards) do
									if tonumber(v[3]) > 0 then
										vStr = v[1]..'.'..v[2]..':'..v[3]
										table.insert(tab , vStr)
										tab[index] = vStr
										index = index + 1
									end
								end
								genShowTotalAwardsPanel(tab,'')
							end
							updateList()
							updateChipCell()
							-- addToBottom()
						end
					end)
				end
			end)
		end
	end

	local function createChipCell()
		views = {}
		for i=1,#conf do
			local view = createWidgetByName('panel/chip_cell.json')
			cardSv:addChildToBottom(view)
			table.insert(views,i)
			views[i] = view
			-- getPos(i)
			view:setPosition(getPos(i))
		end
		cardSv:scrollToTop()
		updateList()
		updateChipCell()
		-- addToBottom()
	end

	local function init()
		local root = panel:GetRawPanel()
    	closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		cardSv = tolua.cast(root:getChildByName('card_sv') , 'UIScrollView')
		cardSv:setClippingEnable(true)
		createChipCell()
	end

	local function createChipPanel()
		sceneObj = SceneObjEx:createObj('panel/chip_panel.json','chip-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('chip_bg_img','chip_img')
		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end
	createChipPanel()
end