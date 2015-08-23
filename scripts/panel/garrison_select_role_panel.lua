GarrisonSelect = {}
function genSelectPanel(mineId,userInfoData,Date)
	-- body
	local getDate = Date

	--select ui
	local cardWidth = 305
	local roleTab = {}

	local selectScene
	local selectPanel
	local selectRoot 
	local selectBgImg
	local selectRoleImg
	local selectRoleBgSv
	local selectEquipSv
	local cashNumTx 
	local honorNumTx
	local selectCloseBtn
	local titleNameTx
	

	--select role ui
	local roleCardPanel
	local roleSelectBgBtn
	local roleBattleIco
	local roleSoliderTypeIco
	local roleNameTx
	local roleLvIco
	local roleZhanIco
	local roleZhanNumTx
	local roleBgImg 
	local roleImg
	local roleEquipPl
	local roleTrainTx
	local roleSelectTx
	local roleSuiPianTx
	local roleSuiPianNumTx

	local roleTab = {}
	--res
	local RES_DAO = 'uires/ui_2nd/com/panel/common/dao.png'
	local RES_QIANG = 'uires/ui_2nd/com/panel/common/qiang.png'
	local RES_QI = 'uires/ui_2nd/com/panel/common/qibing.png'
	local RES_MOU = 'uires/ui_2nd/com/panel/common/mou.png'
	local RES_HONG = 'uires/ui_2nd/com/panel/common/hong.png'

	--读表
	local patrolBattleConf = GameData:getArrayData('patrolbattle.dat')
	local patrolEventConf = GameData:getArrayData('patrolevent.dat')
	local patrolIntervalConf = GameData:getArrayData('patrolinterval.dat')
	local patrolTypeConf = GameData:getArrayData('patroltype.dat')
	local monsterConf = GameData:getArrayData('monster.dat')
	local materialConf = GameData:getArrayData('material.dat')
	local roleConf = GameData:getArrayData('role.dat')
	local chipConf = GameData:getArrayData('chip.dat')

	--关闭武将界面
	function GarrisonSelect:closeSelectPanel()
		-- body
		CUIManager:GetInstance():HideObject(selectScene,ELF_HIDE.ZOOM_OUT_FADE_OUT)
	end

	--点击武将
	local function onClickRole(roleId,mineId)
		-- body
		genTimeTypePanel(roleId,mineId)
	end

	local function updateRole(roleBgImg,roleSuiPianTx,roleSuiPianNumTx,id)
		-- body
		local roleBgRes,roleImgRes,fightforce,strName,color,roleQuality

		--suipian 
		local total 
		local own 
		local materialId


		pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject( id, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
		pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')

		roleQuality = pRoleCardObj:GetRoleQuality()
		if roleQuality == E_ROLE_QUALITY_BLUE then
			roleBgImg:setTexture('uires/ui_2nd/com/panel/common/blue_bg.png')
			roleSuiPianTx:setText(getLocalStringValue('E_STR_PATROL_NO_CHIP'))
			roleSuiPianTx:setPosition(ccp(225,123))
			roleSuiPianNumTx:setVisible(false)
		elseif roleQuality == E_ROLE_QUALITY_PURPLE then
			roleBgImg:setTexture('uires/ui_2nd/com/panel/common/purple_bg.png')
			roleSuiPianTx:setText(getLocalStringValue('E_STR_PATROL_NO_CHIP'))
			roleSuiPianTx:setPosition(ccp(225,123))
			roleSuiPianNumTx:setVisible(false)
		elseif roleQuality == E_ROLE_QUALITY_ORANGE then
			roleBgImg:setTexture('uires/ui_2nd/com/panel/common/yellow_bg.png')
			roleSuiPianTx:setText(getLocalStringValue('E_STR_PATROL_NO_CHIP'))
			roleSuiPianTx:setPosition(ccp(225,123))
			roleSuiPianNumTx:setVisible(false)
		elseif roleQuality == E_ROLE_QUALITY_ARED or roleQuality == E_ROLE_QUALITY_SRED then

			table.foreach(chipConf,function(_ ,v)
			-- body
			if v['RoleId'] == tostring(id)then
				materialId = v['MaterialId']
			end
			end)
			table.foreach(materialConf,function(_ ,v)
			-- body
			if v['Id'] == tostring(materialId) then
				total = v['MergeNum']
			end
			end)
			local material = Material:findById(materialId)
			own = material:getCount()
			roleSuiPianTx:setVisible(true)
			roleSuiPianNumTx:setText(own .. '/' .. total) 
			roleBgImg:setTexture('uires/ui_2nd/com/panel/common/red_bg.png')
		end
		
	end


	local function orderRoles()
		-- body
		Message.sendPost('patrol_get','activity','{}',function(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end
			getDate = jsonDic.data.patrol
		end)

		local roleTab1 = {}
		local roleTab2 = {}
		for i,v in pairs(userInfoData.infos) do 
			local isIn = false
			for j = 1,GarrisonMine:countTable(getDate) do 
				if getDate[tostring(j)].rid == userInfoData.infos[i].id then
					table.insert(roleTab1,userInfoData.infos[i])
					isIn = true
				end
			end
			if not isIn then
				table.insert(roleTab2,userInfoData.infos[i])
			end
		end

		for i,v in pairs(roleTab1) do 
			table.insert(roleTab2,roleTab1[i])
		end
		return roleTab2
	end 


	--刷新武将选择界面并加载武将
	local function updateRoleSelectPanel()
		-- body
		local index = 1
		for i,v in pairs(roleTab) do
			if index <= 7 and v ~= nil then

				local isPatrol = false 
				for j = 1,GarrisonMine:countTable(getDate) do 
					if getDate[tostring(j)].rid == roleTab[i].id then
						isPatrol = true
					end
				end

				titleNameTx:setText(getLocalStringValue("E_STR_SELECT_ROLE"))
				local roleCardPanel = createWidgetByName('panel/select_role_panel.json')
				roleCardPanel:setPosition(ccp(cardWidth * (i-1), 0))
				selectRoleBgSv:addChild(roleCardPanel)

				roleSelectBgBtn = tolua.cast(roleCardPanel:getChildByName('role_select_bg_btn') , 'UIButton')
				roleSelectBgBtn:registerScriptTapHandler(function()
					-- body
					if isPatrol then
						GameController.showPrompts(getLocalStringValue('E_STR_PATROL_GARRISONED1'), COLOR_TYPE.RED)
						return
					else
						local id = roleTab[i].id
						onClickRole(id,mineId)
					end
				end)
				GameController.addButtonSound(roleSelectBgBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)

				roleBattleIco = tolua.cast(roleSelectBgBtn:getChildByName('battle_ico') , 'UIImageView')

				roleSoliderTypeIco = tolua.cast(roleSelectBgBtn:getChildByName('soldier_type_ico') , 'UIImageView')
				roleNameTx = tolua.cast(roleSelectBgBtn:getChildByName('role_name_tx') , 'UILabel')
				roleNameTx:setPreferredSize(240,1)
				roleLvIco = tolua.cast(roleSelectBgBtn:getChildByName('lv_ico'),'UIImageView')
				roleLvIco:setVisible(false)
				roleZhanIco = tolua.cast(roleSelectBgBtn:getChildByName('zhan_ico'),'UIImageView')
				roleZhanNumTx = tolua.cast(roleZhanIco:getChildByName('zhan_num_tx'),'UILabel')
				roleBgImg = tolua.cast(roleSelectBgBtn:getChildByName('role_bg_ico'),'UIImageView')
				roleImg = tolua.cast(roleSelectBgBtn:getChildByName('role_img'),'UIImageView')
				roleEquipPl = tolua.cast(roleSelectBgBtn:getChildByName('equip_bg_ico'),'UIPanel')
				roleEquipPl:setVisible(false)
				roleTrainTx = tolua.cast(roleSelectBgBtn:getChildByName('train_tx'),'UILabel')
				roleTrainTx:setVisible(false)
				roleSelectTx = tolua.cast(roleSelectBgBtn:getChildByName('select_tx'),'UILabel')
				roleSuiPianTx = tolua.cast(roleSelectBgBtn:getChildByName('sui_pian_tx'),'UILabel')
				roleSuiPianNumTx = tolua.cast(roleSelectBgBtn:getChildByName('sui_pian_num_tx'),'UILabel')
				roleSuiPianTx:setVisible(true)
				roleSuiPianTx:setPreferredSize(200,1)
				roleSuiPianNumTx:setVisible(true)

				if isPatrol then 
					roleSelectTx:setText(getLocalStringValue('E_STR_PATROL_GARRISONED2'))
					roleSelectTx:setColor(COLOR_TYPE.RED)
				end

				updateRole(roleBgImg,roleSuiPianTx,roleSuiPianNumTx,roleTab[i].id)
				table.foreach(roleConf,function(_ , v)
					if tonumber(v['Id']) == roleTab[i].id then
						if v['Soldier'] == tostring(1) then
							roleSoliderTypeIco:setTexture(RES_DAO)
						elseif v['Soldier'] == tostring(2) then
							roleSoliderTypeIco:setTexture(RES_QIANG)
						elseif v['Soldier'] == tostring(3) then
							roleSoliderTypeIco:setTexture(RES_QI)
						elseif v['Soldier'] == tostring(4) then
							roleSoliderTypeIco:setTexture(RES_MOU)
						elseif v['Soldier'] == tostring(5) then
							roleSoliderTypeIco:setTexture(RES_HONG)
						end
					end
				end)
				roleSoliderTypeIco:setAnchorPoint(ccp(0,0))
				roleImgRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.BIG)
				strName = pRoleCardObj:GetRoleName()
				color = pRoleCardObj:GetRoleNameColor()
				fightforce =  roleTab[i].fight_force
				roleImg:setTexture(roleImgRes)
				roleImg:setAnchorPoint(ccp(0.5, 0))

				roleNameTx:setText(strName)
				roleNameTx:setColor(color)
				roleZhanNumTx:setText(fightforce)
				roleImg:setVisible(true)
				index = index + 1
			end
		end

	end



	local function update()
		-- body
		roleTab = orderRoles()
		updateRoleSelectPanel()
	end



	--初始化武将选择界面
	local function initSelect()
		-- body
		selectRoot = selectPanel:GetRawPanel()
		selectBgImg = tolua.cast(selectRoot:getChildByName('role_bg_img'),'UIImageView')

		selectRoleImg = tolua.cast(selectBgImg:getChildByName('role_img'),'UIImageView')
		selectCloseBtn = tolua.cast(selectBgImg:getChildByName('close_btn'),'UIButton')
		selectCloseBtn:registerScriptTapHandler(function()
			-- body
			GarrisonSelect:closeSelectPanel()
		end)
		GameController.addButtonSound(selectCloseBtn,BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		titleNameTx = tolua.cast(selectBgImg:getChildByName('title_name_tx'),'UILabel')
		cashNumTx = tolua.cast(selectBgImg:getChildByName('cash_num_tx'),'UILabel')
		honorNumTx = tolua.cast(selectBgImg:getChildByName('honor_num_tx'),'UILabel')
		cashNumTx:setVisible(false)
		honorNumTx:setVisible(false)
		
		selectRoleBgSv = tolua.cast(selectBgImg:getChildByName('role_bg_sv'),'UIScrollView')
		selectRoleBgSv:setClippingEnable(true)
		selectRoleBgSv:setIgnoreFocusOnBody(false)
		selectRoleBgSv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)

		selectEquipSv = tolua.cast(selectBgImg:getChildByName('equip_sv'),'UIScrollView')
		selectEquipSv:setTouchEnable(false)
		update()
	end

	--创建武将选择界面
	local function createSelectPanel()
		-- body
		selectScene = SceneObjEx:createObj('panel/select_role_bg_panel.json','select-in-lua')
		selectPanel = selectScene:getPanelObj()
		selectPanel:setAdaptInfo('role_bg_img','role_img')
		selectPanel:registerInitHandler(initSelect)
		UiMan.show(selectScene)
	end
	createSelectPanel()
end

