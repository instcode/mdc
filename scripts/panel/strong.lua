function genStrongPanel(stype)
	local isVisible = false
	local PRE_PAGE = 6
	local isRoleActive =0
	local CHANNEL = 
	{	
		EquipStrengthen = 1,		-- 装备强化
		HeroQuality = 2,			-- 武将品质
		EquipForge = 3,			-- 装备打造
		HeroLev = 4,				-- 武将等级
		HeroSkill = 5,			-- 武将技能
		StoneLevUp = 6,			-- 宝石升级
		HeroTrain = 7,			-- 武将培养
		HeroTransfer = 8,			-- 武将转职
		HeroSoul = 9,				-- 武将炼魂
		SoldierTech = 10         -- 兵种科技
	}
	
	local MATERIAL = 
	{
		21,
		22,
		23,
		24,
		25
	}
	-- ui
	local sceneObj
	local panel
	local root
	local roleSv
	local roleBtnArr
	local roleWidgetArr
	local roleFightTx
	local roleFightExpectTx
	local roleFightingBar
	local channelPV				-- 变强途径容器
	local pointImageArr	= {}		
	-- data
	local curRoleId
	local curId
	local isInit = false
	local rolesTab = {}
	local newRolesTab = {}
	local sortIdTab = {}			-- 排序后的渠道编号
	local cellMap = {}
	local sumChannel				-- 渠道个数
	local needMoney = 1000000000   -- 强化需要的最低花费 低于这个值就更新
	local isCanForge = false
	local level = PlayerCoreData.getPlayerLevel()
	local conf = GameData:getArrayData('strengthen.dat')
	local grouthConf = GameData:getArrayData('grouth.dat')
	local needFood = getGlobalIntegerValue('DuplicateBossFood')
	local equipConf = GameData:getArrayData('equip.dat')
	local soldierLevel = {}
	local needSign = {}
	local lights = {}

	local function getShopPrice(id,stype1,stype2)
		local shopConf = GameData:getArrayData('shop.dat')
		local price = 0
		for i,v in ipairs(shopConf) do
			if tonumber(v.Category3) == id and v.Category2 == stype1 and v.Currency == stype2 then
				price = tonumber(v.Price)
				return price
			end
		end
		return price
	end

	local function getNeedMoney(id,strengthLevel)
		local money = 0
		if strengthLevel >= level then
			return
		end

		if id == 0 then
			money = tonumber(conf[strengthLevel].WeaponCost) or 0
		elseif id == 1 then
			money = tonumber(conf[strengthLevel].ArmorCost) or 0
		elseif id == 2 then
			money = tonumber(conf[strengthLevel].AccessoryCost) or 0
		end
		if money ~= 0 and needMoney > money then
			needMoney = money
		end
	end

	local function getCanForge(id,forgeLevel)
		local materialId1 = 0
		local materialId2 = 0
		local num1 = 0 
		local num2 = 0
		local price
		local food = PlayerCoreData.getFoodValue()
		local fame = PlayerCore:getFameValue()
		-- local conf = getStrengthConf(strengthLevel)
		if forgeLevel > #equipConf then
			return
		end

		if id == 0 then
			materialId1 = tonumber(equipConf[forgeLevel].WeaponMaterialType1)
			materialId2 = tonumber(equipConf[forgeLevel].WeaponMaterialType2)
			num1 = tonumber(equipConf[forgeLevel].WeaponMaterial1)
			num2 = tonumber(equipConf[forgeLevel].WeaponMaterial2)
			price = getShopPrice(materialId1,'material','fame')
		elseif id == 1 then
			materialId1 = tonumber(equipConf[forgeLevel].ArmorMaterialType1)
			materialId2 = tonumber(equipConf[forgeLevel].ArmorMaterialType2)
			num1 = tonumber(equipConf[forgeLevel].ArmorMaterial1)
			num2 = tonumber(equipConf[forgeLevel].ArmorMaterial2)
			price = getShopPrice(materialId1,'material','fame')
		elseif id == 2 then
			materialId1 = tonumber(equipConf[forgeLevel].AccessoryMaterialType1)
			materialId2 = tonumber(equipConf[forgeLevel].AccessoryMaterialType2)
			num1 = tonumber(equipConf[forgeLevel].AccessoryMaterial1)
			num2 = tonumber(equipConf[forgeLevel].AccessoryMaterial2)
			price = getShopPrice(materialId1,'material','fame')
		end
		local material1 = Material:findById(materialId1)
		local material2 = Material:findById(materialId2)
		local count1 = material1:getCount()
		local count2 = material2:getCount()
		if fame >= (num1 - count1)*price and (count2 >= num2 or food > needFood) then
			isCanForge = true
		end
	end

	-- 获得各项渠道的评分
	local function getChannelGrade( channelId )
		-- print(curRoleId)
		local roleObj = Role:findById( curRoleId )
		if roleObj == nil then
			return 0
		end

		local playerLv = PlayerCoreData.getPlayerLevel()
		local roleLv = tonumber(roleObj:getLevel())
		local value = 0

		if channelId == CHANNEL.EquipStrengthen then 	-- 装备强化
			needMoney = 1000000000
			local average = 0
			for i = 0, 2 do
				local equipObj = roleObj:getEquipBySite(i)
				if equipObj then
					local lv = tonumber(equipObj:getStrengthLevel())
					getNeedMoney(i,lv)
					average = average + lv
				else
					needMoney = 1
				end
			end
			average = average / 3
			value = average / playerLv
		elseif channelId == CHANNEL.HeroQuality then 	-- 英雄品质
			local quality = tonumber(roleObj:getQuality())
			value = quality / ROLE_QUALITY.ARED
		elseif channelId == CHANNEL.EquipForge then     -- 装备打造
			isCanForge = false
			local average = 0
			for i = 0, 2 do
				local equipObj = roleObj:getEquipBySite(i)
				if equipObj then
					local lv = tonumber(equipObj:getLevel())
					getCanForge(i,lv)
					average = average + lv
				else
					isCanForge = true
				end
			end
			local hopeData = getStrongHopeData( playerLv )
			if hopeData then
				local hope = tonumber(hopeData.HopeEquipForgeLevel)  -- 期望装备锻造等级
				average = average / 3
				value = average / hope
			end
		elseif channelId == CHANNEL.HeroLev then 		-- 武将等级
			value = roleLv / playerLv
		elseif channelId == CHANNEL.HeroSkill then 		-- 英雄技能
			local average = 0
			local count = 0			-- 装备技能个数(包含被动)

			-- 主动技能
			local curSkillId = tonumber(roleObj:getCurrActiveSkill())
			local curSkillLv = tonumber(roleObj:getCurSkillLevel( curSkillId ))
			if curSkillLv ~= 0 then
				average = average + curSkillLv
				count = count + 1
			end
			-- 被动技能
			for i = 1 , 5 do
				if i == 2 or i == 4 then
					local skillOpenLv = roleObj:getSkillOpenLevel( i )
					if roleLv > skillOpenLv then
						local skillLv = tonumber(roleObj:getCurSkillLevel( i ))
						average = average + skillLv
						count = count + 1
					end
				end
			end
			average = average / count

			local hopeData = getStrongHopeData( playerLv )
			if hopeData then
				local hope = tonumber(hopeData.HopeSkillLevel)  -- 期望技能等级
				value = average / hope
			end
		elseif channelId == CHANNEL.StoneLevUp then 		-- 宝石升级
			local stoneLv = 0
			for i = 0 , 2 do
				local equipObj = roleObj:getEquipBySite(i)
				if equipObj then
					local gems = equipObj:getGemsID()
					table.foreach(gems , function (_,v)
						stoneLv = stoneLv + LD_TOOLS:getGemLevel(v)
					end)
				end		
			end
			local hopeData = getStrongHopeData( playerLv )
			if hopeData then
				local hope = tonumber(hopeData.HopeGemLevel)  -- 期望宝石等级
				value = stoneLv / hope
			end
		elseif channelId == CHANNEL.HeroTrain then 		-- 英雄培养
			local hope = 0
			local growth = tonumber(roleObj:getGrowth())
			local hopeData = getStrongHopeData( playerLv )
			local quality = tonumber(roleObj:getQuality())
			if hopeData then
				if quality == ROLE_QUALITY.BLUE then
					hope = tonumber(hopeData.HopeBlueGrowth)
				elseif quality == ROLE_QUALITY.PURPLE then
					hope = tonumber(hopeData.HopePurpleGrowth)
				elseif quality == ROLE_QUALITY.ORANGE then
					hope = tonumber(hopeData.HopeOrangeGrowth)
				elseif quality == ROLE_QUALITY.ARED then
					hope = tonumber(hopeData.HopeARedGrowth)
				elseif quality == ROLE_QUALITY.SRED then
					hope = tonumber(hopeData.HopeSRedGrowth)
				end
				value = growth / hope
			end
		elseif channelId == CHANNEL.HeroTransfer then		-- 英雄转职
			local hopeData = getStrongHopeData( playerLv )
			if hopeData then
				local transfer = roleObj:getSoldier().level      -- 兵种等级
				local hope = tonumber(hopeData.HopeSoldierLevel)		-- 期望转职等级
				value = transfer / hope
			end
		elseif channelId == CHANNEL.HeroSoul then 			-- 英雄炼魂
			local hopeData = getStrongHopeData( playerLv )
			if hopeData then
				local soulLv = tonumber(roleObj:getSoulLevel())
				local hope = tonumber(hopeData.HopeSoulLevel)
				value = soulLv / hope
			end
		elseif channelId == CHANNEL.SoldierTech then 		-- 兵种科技
			local tech = LD_TOOLS:calcTechScore( tonumber( roleObj:getSoldier().stype ) )
			value = tech / 5
		else
			value = 0
		end

		if value > 1 then
			value = 1
		end

		if tostring(value) == 'nan' then
			value = 0
		end

		return value
	end

	-- 获得各项渠道的性价比
	local function getChannelProprePrice( channelId )
		local playerLv = PlayerCoreData.getPlayerLevel()

		local data = getPropretyPriceData(playerLv)
		if data == nil then
			return 0
		end

		local factor = 0

		if tonumber(channelId) == CHANNEL.EquipStrengthen then
			factor = tonumber(data.EquipPrice)
		elseif tonumber(channelId) == CHANNEL.HeroQuality then
			factor = tonumber(data.RoleQualityPrice)
		elseif tonumber(channelId) == CHANNEL.EquipForge then
			factor = tonumber(data.EquipForgePrice)
		elseif tonumber(channelId) == CHANNEL.HeroLev then
			factor = tonumber(data.LevelPrice)
		elseif tonumber(channelId) == CHANNEL.HeroSkill then
			factor = tonumber(data.SkillPrice)
		elseif tonumber(channelId) == CHANNEL.StoneLevUp then
			factor = tonumber(data.GemLevelPrice)
		elseif tonumber(channelId) == CHANNEL.HeroTrain then
			factor = tonumber(data.GrowthPrice)
		elseif tonumber(channelId) == CHANNEL.HeroTransfer then
			factor = tonumber(data.JobPrice)
		elseif tonumber(channelId) == CHANNEL.HeroSoul then
			factor = tonumber(data.SoulLevelPrice)
		elseif tonumber(channelId) == CHANNEL.SoldierTech then
			factor = tonumber(data.GranConsejoPrice)
		else 
			factor = 0
		end

		local value = getChannelGrade( tonumber(channelId) )

		-- (1-各个模块的进度百分比)*性价比系数
		local progrePrice =  (1 - value) * factor
		return progrePrice
	end

	local function sortRoleFn(a, b)
		local i = a:isAssigned() and 1 or 0
		local j = b:isAssigned() and 1 or 0
		if i > j then
			return true
		end
		if i < j then
			return false
		end
		return a:getFightForce() > b:getFightForce()
	end

	local function initNewRolesData()
		newRolesTab = {}
		local tab = {}
		for i,v in ipairs(rolesTab) do
			local data = v
			if needSign[i] == true and data:isAssigned() == true then
				table.insert(newRolesTab,#newRolesTab + 1)
				newRolesTab[#newRolesTab] = data
				needSign[#newRolesTab] = true
			else
				table.insert(tab,#tab + 1)
				tab[#tab] = {data,needSign[i]}
			end
			
		end
		for i,v in ipairs(tab) do
			local data = v
			table.insert(newRolesTab,#newRolesTab + 1)
			newRolesTab[#newRolesTab] = data[1]
			needSign[#newRolesTab] = data[2]
		end

		if #newRolesTab > 0 and not curRoleId then
			curRoleId = newRolesTab[1].id
		end

		if not curId then
			curId = 1
		end

		rolesTab = newRolesTab
		local isIn = false
		for i,v in ipairs(newRolesTab) do
			if curRoleId == v.id then
				isIn = true
			end
		end
		if isIn == false then
			curRoleId = newRolesTab[1].id
			curId = 1
		end
	end

	local function initRolesData()
		rolesTab = {}
    	local rolesIdTab = json.decode(PlayerCoreData.getAllRolesId())
    	table.foreach(rolesIdTab , function (_ , v)
    		local obj = Role:findById(tonumber(v))
    		if obj then
    			table.insert(rolesTab , obj)
    		end
    	end)

    	if #rolesTab > 0 then
    		table.sort(rolesTab , sortRoleFn)
    		
    		return true
    	end
    	return false
	end

	local function sortChannelFn(a , b)
		return a.value > b.value
	end

	local function resetAllBtnStatus()
		table.foreach(roleBtnArr , function (_, v)
			GameController.addButtonSound(v , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			v:setPressState(WidgetStateNormal);
			v:setIgnoreFocusOnBody(true);
		end)
	end

	local function updateRoleFightTx()
		-- 当前选中武将战力
		roleFightTx:setTextFromInt(PlayerCoreData.getRoleById(curRoleId):GetFightForce())
		local playerLv = PlayerCoreData.getPlayerLevel()
		local data = getStrongHopeData(playerLv)
		if data == nil then
			return
		end
		-- 期望战力
		roleFightExpectTx:setText(toWordsNumber(tonumber(data.HopeFightForce)))
	end

	local function updateLoadingBar()
		local curFight = PlayerCoreData.getRoleById(curRoleId):GetFightForce()
		local playerLv = PlayerCoreData.getPlayerLevel()
		local data = getStrongHopeData(playerLv)
		if data == nil then
			return
		end
		local expectFight = tonumber(data.HopeFightForce)
		roleFightingBar:setPercent(curFight / expectFight * 100)
	end

		-- 设置变强渠道的表示页的点
	local function setStrongerChannnelPointImage( page )
		local image = tolua.cast(root:getChildByName('right_bg_img') , 'UIImageView')
		if image then
			local pageNum = math.ceil(sumChannel / PRE_PAGE)
			local imageWidth = 12 * pageNum    -- 点图片的总宽度
			local size = image:getContentSize()
			local midPos = ccp((size.width - imageWidth) / 2 , size.height / 25)

			for i = 0 , pageNum-1 do
				local point
				if pointImageArr[i] == nil then
					point = UIImageView:create()
					pointImageArr[i] = point
				else
					point = pointImageArr[i]
				end
				if point then
					image:addChild(point)
					point:setPosition(ccp(midPos.x + i * 18 , midPos.y ))
					point:setTexture('uires/ui_2nd/com/common_btn/p1.png')
				end
			end
			
			if pointImageArr[page-1] then
				pointImageArr[page-1]:setTexture('uires/ui_2nd/com/common_btn/p2.png')
			end
		end
	end
	local function getStrengthLevel( ... )
		-- body
	end
	local function scorllPvFn( page )
		setStrongerChannnelPointImage( page + 1 )
	end

	local function getStatus(id , percent)
		local gold = PlayerCoreData.getGoldValue()
		local food = PlayerCoreData.getFoodValue()
		local level = PlayerCoreData.getPlayerLevel()
		if tonumber(id) == tonumber(CHANNEL.EquipStrengthen) then
			if needMoney ~= 0 and gold > needMoney and math.floor(percent * 100) <= 80 then
				return true,true
			end
		elseif tonumber(id) == tonumber(CHANNEL.EquipForge) then
			local forgeLevel = tonumber(GameData:getGlobalValue('ForgeOpenLevel'))
			if isCanForge == true and math.floor(percent * 100) <= 80 and level >= forgeLevel then
				return true,true
			end
		elseif tonumber(id) == tonumber(CHANNEL.HeroTrain)  then
			local forgeLevel = tonumber(GameData:getGlobalValue('FosterOpenLevel'))
			local isCanGrouth = false
			if sLevel then
				local roleObj = Role:findById( curRoleId )
				local quality = roleObj:getQuality()
				local materialId = MATERIAL[sLevel]
				local foster = Material:findById(materialId)
				local myGrouth = tonumber(grouthConf[quality]['Max'..sLevel])
				local count = foster:getCount()
				if roleObj:getGrowth() < myGrouth and count > 0 then
					isCanGrouth = true
				end
				if isCanGrouth == true and math.floor(percent * 100) <= 80 and level >= forgeLevel then
					return true,true
				end
			end
		end
		return false
	end
	-- 设置变强渠道的ScrollView
	local function updateChannelSV()
		local playerLv = PlayerCoreData.getPlayerLevel()

		-- 对变强渠道进行排序
		sortIdTab = {}
		for k , v in pairs( CHANNEL ) do
			local tab = {}
			tab['id'] = tonumber(v)
			tab['value'] = tonumber(getChannelProprePrice(v))
			table.insert(sortIdTab , tab)
		end
		table.sort(sortIdTab , sortChannelFn)

		if nil == channelPV then
			channelPV = UIPageView:create()
			channelPV:setTouchEnable(true)
			channelPV:setWidgetZOrder(1)
			channelPV:setPosition(ccp(10,28))
			channelPV:setSize(CCSizeMake(596 , 408))
			channelPV:setAnchorPoint(ccp(0,0))
			channelPV:addScroll2PageEventScript( scorllPvFn )
			channelPV:removeAllChildrenAndCleanUp(true)

			local image = tolua.cast(root:getChildByName('right_bg_img') , 'UIImageView')
			if image then
				image:addChild(channelPV)
			end
		end

		local count = 0		-- 在外面初始for里面的变量
		local point = {}
		local page
		local channelSize = channelPV:getContentSize()

		local hideSoulFlag = false
		for i, v in pairs( sortIdTab ) do
			local sLevel = nil
			if v.id == CHANNEL.HeroSoul then
				local roleObj = Role:findById( curRoleId )
				if roleObj then
					local quality = tonumber(roleObj:getQuality())
					if quality < ROLE_QUALITY.ORANGE then
						hideSoulFlag = true
					end
				end
			end
			local roleObj = Role:findById( curRoleId )
			if roleObj then
				sLevel = roleObj:getSoldier().level
			end
			local data = getStrongData( v.id )
			if ((v.id == CHANNEL.HeroSoul and hideSoulFlag == false) or (v.id ~= CHANNEL.HeroSoul)) 
				and data and playerLv >= tonumber(data.OpenLevel) then
				local cell
				if cellMap[count] == nil then
					cell = createWidgetByName("panel/strong_card_panel.json")
					cell:setAnchorPoint(ccp(0,0))
					point.x = math.mod(count,2) * cell:getContentSize().width
					point.y = (channelSize.height - cell:getContentSize().height) - math.floor((math.mod(count,6) / 2)) * cell:getContentSize().height
					cell:setPosition(ccp(point.x , point.y))
					
					if math.mod(count , PRE_PAGE) == 0 then
						page = UIContainerWidget:create()
						page:setWidgetTag(count / PRE_PAGE + 1)
						channelPV:addPage(page)
					end
					if page == nil then
						page = channelPV:getChildByTag(count / PRE_PAGE + 1)
					end
					page:addChild(cell)

					cellMap[count] = cell
				else
					cell = cellMap[count]
					cell:setVisible(true)
				end
				local redwaring = tolua.cast(cell:getChildByName('red_quan_img') , 'UIImageView')
				local btn = tolua.cast(cell:getChildByName('strong_card_btn') , 'UIButton')
				btn:setScale9Enable(true)
				btn:setScale9Size(CCSizeMake(299,136))
				GameController.addButtonSound(btn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
				btn:registerScriptTapHandler(function ()
					local tag = tonumber(btn:getWidgetTag())
					if tag == CHANNEL.EquipStrengthen then
						CBlacksmithMgr:GetInst():ShowBlackSmithPanel(curRoleId, EQUIP_SITE.WEAPON, 0)
					elseif tag == CHANNEL.HeroQuality then
						CTavernMgr:GetInst():ShowGoldTavern()
					elseif tag == CHANNEL.EquipForge then
						CBlacksmithMgr:GetInst():ShowBlackSmithPanel(curRoleId, EQUIP_SITE.WEAPON, 1)
					elseif tag == CHANNEL.HeroLev then
						CTrainMgr:GetInst():ShowTrainPanel()
					elseif tag == CHANNEL.HeroSkill then
						CRoleMgr:GetInst():SetSelectRoleID(curRoleId)
						CRoleMgr:GetInst():ShowMainPanel(E_ROLE_SUBPAGE_INFO, false)
					elseif tag == CHANNEL.StoneLevUp then
						CBlacksmithMgr:GetInst():ShowBlackSmithPanel(curRoleId, EQUIP_SITE.WEAPON, 2)
					elseif tag == CHANNEL.HeroTrain then
						CRoleMgr:GetInst():SetSelectRoleID(curRoleId)
						CRoleMgr:GetInst():ShowMainPanel(E_ROLE_SUBPAGE_TRAINING, false)
					elseif tag == CHANNEL.HeroTransfer then
						CRoleMgr:GetInst():SetSelectRoleID(curRoleId)
						CRoleMgr:GetInst():ShowMainPanel(E_ROLE_SUBPAGE_INFO, false)
					elseif tag == CHANNEL.HeroSoul then
						CRoleMgr:GetInst():SetSelectRoleID(curRoleId)
						CRoleMgr:GetInst():ShowMainPanel(3, false)
					elseif tag == CHANNEL.SoldierTech then
						CTechnologyMgr:GetInst():ShowMainPanel()
					end
				end)
				btn:setWidgetTag(v.id)
				-- 设置图标
				local icon = tolua.cast(cell:getChildByName('item_ico') , 'UIImageView')
				icon:setTexture(data.Pic)
				-- 设置名字
				local nameTx = tolua.cast(cell:getChildByName('item_name_tx') , 'UILabel')
				nameTx:setPreferredSize(130,1)
				nameTx:setText(GetTextForCfg(data.StrongName))
				-- 设置进度条
				local percentTx = tolua.cast(cell:getChildByName('percent_tx') , 'UILabel')
				local percent = getChannelGrade( v.id )
				percentTx:setText(math.floor(percent * 100) .. '%')

				local bar = tolua.cast(cell:getChildByName('exp_bar') , 'UILoadingBar')
				bar:setPercent(percent * 100)

				local recommendIco = tolua.cast(cell:getChildByName('recommend_ico') , 'UIImageView')
				recommendIco:setVisible(count < 3)
				--满足一定条件出发感叹号
				-- redwaring:setVisible(false)
				local status,_ = getStatus(tonumber(v.id),percent)
				redwaring:setVisible(status)
				-- local gold = PlayerCoreData.getGoldValue()
				-- local food = PlayerCoreData.getFoodValue()
				-- if tonumber(v.id) == tonumber(CHANNEL.EquipStrengthen) then
				-- 	if needMoney ~= 0 and gold > needMoney and math.floor(percent * 100) <= 80 then
				-- 		redwaring:setVisible(true)
				-- 	end
				-- elseif tonumber(v.id) == tonumber(CHANNEL.EquipForge) then
				-- 	if isCanForge == true and math.floor(percent * 100) <= 80 then
				-- 		redwaring:setVisible(true)
				-- 	end
				-- elseif tonumber(v.id) == tonumber(CHANNEL.HeroTrain)  then
				-- 	local isCanGrouth = false
				-- 	if sLevel then
				-- 		local roleObj = Role:findById( curRoleId )
				-- 		local quality = roleObj:getQuality()
				-- 		local materialId = MATERIAL[sLevel]
				-- 		local foster = Material:findById(materialId)
				-- 		local myGrouth = tonumber(grouthConf[quality]['Max'..sLevel])
				-- 		local count = foster:getCount()
				-- 		if roleObj:getGrowth() < myGrouth and count > 0 then
				-- 			isCanGrouth = true
				-- 		end
				-- 		if isCanGrouth == true and math.floor(percent * 100) <= 80 then
				-- 			redwaring:setVisible(true)
				-- 		end
				-- 	end
				-- end
				count = count + 1
			end
		end

		-- 如果选中的是橙色一下的武将并且玩家等级大于炼魂开启的等级，那么隐藏一个面板
		local heroSoulOpenLevel = 35
		local sData = getStrongData(CHANNEL.HeroSoul)
		heroSoulOpenLevel = tonumber(sData.OpenLevel)
		
		local cellLength = 0
		table.foreach(cellMap , function (k,v)
			cellLength = cellLength + 1
		end)
		local sortLength = 0
		table.foreach(sortIdTab , function (k,v)
			sortLength = sortLength + 1
		end)

		if hideSoulFlag and playerLv >= heroSoulOpenLevel and cellLength == sortLength then
			local lastKey = cellLength - 1
			if lastKey >= 0 and cellMap[lastKey] then
				cellMap[lastKey]:setVisible(false)
			end 
		end

		sumChannel = count
	end



	local function updateRoleSv()
		table.foreach(roleWidgetArr , function (i, v)
			local roleId = rolesTab[i].id
			if roleId >= 1 then
				local roleObj = Role:findById(roleId)
				if roleObj then
					local fightForceTx = tolua.cast(v:getChildByName('zhan_num_tx') , 'UILabel')
					fightForceTx:setTextFromInt(roleObj:getFightForce())
				end
			end
		end)
	end

	local function getAllRoleStatus()
		needSign = {}
		isVisible = false
		local temCurRoleId = curRoleId
		for i,role in ipairs(rolesTab) do
			local sLevel
			local roleId = rolesTab[i].id
			if roleId >= 1 then
				local roleObj = Role:findById(roleId)
				if roleObj then
					sLevel = roleObj:getSoldier().level
				end
			end
			curRoleId = role.id
			local isNeed = false
			for k , v in pairs( CHANNEL ) do
				local tab = {}
				local id = tonumber(v)
				local value = tonumber(getChannelGrade(id))

				local status,status1 = getStatus(id,value)
				if status then
					isNeed = status
				end
				if status1 then
					isVisible = status1
				end
				-- local gold = PlayerCoreData.getGoldValue()
				-- local food = PlayerCoreData.getFoodValue()
				-- if tonumber(id) == tonumber(CHANNEL.EquipStrengthen) then
				-- 	if needMoney ~= 0 and gold > needMoney and math.floor(value * 100) <= 80 then
				-- 		isNeed = true
				-- 		isVisible = true
				-- 	end
				-- elseif tonumber(id) == tonumber(CHANNEL.EquipForge) then
				-- 	if isCanForge == true and math.floor(value * 100) <= 80 then
				-- 		isNeed = true
				-- 		isVisible = true
				-- 	end
				-- elseif tonumber(id) == tonumber(CHANNEL.HeroTrain)  then
				-- 	local isCanGrouth = false
				-- 	if sLevel then
				-- 		local roleObj = Role:findById( role.id )
				-- 		local quality = roleObj:getQuality()
				-- 		local materialId = MATERIAL[sLevel]
				-- 		local foster = Material:findById(materialId)
				-- 		local myGrouth = tonumber(grouthConf[quality]['Max'..sLevel])
				-- 		local count = foster:getCount()
				-- 		if roleObj:getGrowth() < myGrouth and count > 0 then
				-- 			isCanGrouth = true
				-- 		end
				-- 		if isCanGrouth == true and math.floor(value * 100) <= 80 then
				-- 			isNeed = true
				-- 			isVisible = true
				-- 		end
				-- 	end
				-- end
			end
			
			local redwaring = tolua.cast(roleWidgetArr[i]:getChildByName('red_quan_img') , 'UIImageView')
			redwaring:setVisible(isNeed)

			table.insert(needSign,i)
			needSign[i] = isNeed
		end
		setStrongVisible(isVisible)
		curRoleId = temCurRoleId
	end

	local function getAllRoleStatusForMainScene()
		local temTab = {}
		needSign = {}
		isVisible = false
		local temCurRoleId = curRoleId
		for i,role in ipairs(rolesTab) do
			local sLevel
			local roleId = rolesTab[i].id
			if roleId >= 1 then
				local roleObj = Role:findById(roleId)
				if roleObj then
					sLevel = roleObj:getSoldier().level
				end
			end
			curRoleId = role.id
			for k , v in pairs( CHANNEL ) do
				local tab = {}
				local id = tonumber(v)
				local value = tonumber(getChannelGrade(id))

				local _,status1 = getStatus(id,value)
				if status1 then
					isVisible = status1
				end
				-- local gold = PlayerCoreData.getGoldValue()
				-- local food = PlayerCoreData.getFoodValue()
				-- if tonumber(id) == tonumber(CHANNEL.EquipStrengthen) then
				-- 	if needMoney ~= 0 and gold > needMoney and math.floor(value * 100) <= 80 then
				-- 		isVisible = true
				-- 	end
				-- elseif tonumber(id) == tonumber(CHANNEL.EquipForge) then
				-- 	if isCanForge == true and math.floor(value * 100) <= 80 then
				-- 		isVisible = true
				-- 	end
				-- elseif tonumber(id) == tonumber(CHANNEL.HeroTrain)  then
				-- 	local isCanGrouth = false
				-- 	if sLevel then
				-- 		local roleObj = Role:findById( role.id )
				-- 		local quality = roleObj:getQuality()
				-- 		local materialId = MATERIAL[sLevel]
				-- 		local foster = Material:findById(materialId)
				-- 		local myGrouth = tonumber(grouthConf[quality]['Max'..sLevel])
				-- 		local count = foster:getCount()
				-- 		if roleObj:getGrowth() < myGrouth and count > 0 then
				-- 			isCanGrouth = true
				-- 		end
				-- 		if isCanGrouth == true and math.floor(value * 100) <= 80 then
				-- 			isVisible = true
				-- 		end
				-- 	end
				-- end
			end
		end
		curRoleId = temCurRoleId
	end

	local function updateAllRoleSv()
		local size = roleSv:getContentSize()
		local i = 0
		table.foreach(newRolesTab , function (j, v)
			local widget = roleWidgetArr[j]
			widget:setAnchorPoint(ccp(0,0))
			widget:setPosition(ccp(0, size.height - (i + 1) * widget:getContentSize().height))
			widget:setIgnoreFocusOnBody(true)
			widget:setActionTag(v.id)
			roleSv:addChild(widget)

			local redwaring = tolua.cast(widget:getChildByName('red_quan_img') , 'UIImageView')
			redwaring:setVisible(needSign[j])
			roleBtnArr[j]:setNormalTexture("uires/ui_2nd/com/panel/gem/select_gem_1.png")
			roleBtnArr[j]:setPressedTexture("uires/ui_2nd/com/panel/gem/select_gem_2.png")
			roleBtnArr[j]:setScale9Enable(true)
			roleBtnArr[j]:setScale9Size(CCSizeMake(272 , 135))

			if roleBtnArr[j] then
				roleBtnArr[j]:registerScriptTapHandler(function ()
					resetAllBtnStatus()

					if curRoleId ~= roleBtnArr[j]:getWidgetTag() then
						curId = j
						curRoleId = v.id
						updateRoleFightTx()
						updateLoadingBar()
						updateChannelSV()
					end
					roleBtnArr[j]:setPressState(WidgetStateSelected);
					roleBtnArr[j]:setIgnoreFocusOnBody(true);
				end)
				roleBtnArr[j]:setWidgetTag(v.id)
				if curRoleId == tonumber(v.id) then
					roleBtnArr[j]:setPressState(WidgetStateSelected)
				end
			end
			GameController.addButtonSound(roleBtnArr[j] , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			local headIco = tolua.cast(widget:getChildByName('role_ico') , 'UIImageView')
			headIco:setTexture(v:getResource(RESOURCE_TYPE.ICON))

			local frame = tolua.cast(widget:getChildByName('role_photo_ico') , 'UIImageView')
			if frame then
				frame:setTexture(Role.GetRoleIcoBgImg(v:getQuality()))
				if v:getQuality() == ROLE_QUALITY.SRED then
					lights[j]:setVisible(true)
				else
					lights[j]:setVisible(false)
				end
			end

			local nameTx = tolua.cast(widget:getChildByName('role_name_tx') , 'UILabel')
			nameTx:setText(v:getName())
			nameTx:setColor(v:getNameColor())

			local fightTx = tolua.cast(widget:getChildByName('zhan_num_tx') , 'UILabel')
			fightTx:setTextFromInt(v:getFightForce())

			local isAssignIco = tolua.cast(widget:getChildByName('ifwar_ico') , 'UIImageView')
			isAssignIco:setWidgetZOrder(100)
			isAssignIco:setVisible(v:isAssigned())
			i = i + 1
		end)

		roleSv:scrollToTop()
		if #newRolesTab > 4 then
			if curId > #newRolesTab then
				curId = 1
			end
			if curId > 3 and curId <= #newRolesTab - 4 then
				local one = tolua.cast(roleSv:getChildren():objectAtIndex(curId), 'UIWidget')
				if one ~= nil then
					local pos = one:getRelativeBottomPos()
					roleSv:moveChildren(-pos + 135)
				end
			elseif curId > #newRolesTab - 4 then
				local one = tolua.cast(roleSv:getChildren():objectAtIndex(#newRolesTab - 1), 'UIWidget')
				if one ~= nil then
					local pos = one:getRelativeBottomPos()
					roleSv:moveChildren(-pos)
				end
			end
		end
	end

	local function initRoleSv()
		roleBtnArr = {}
		roleWidgetArr = {}
		local size = roleSv:getContentSize()
		roleSv:removeAllChildrenAndCleanUp(true)
		local i = 0
		table.foreach(rolesTab , function (j, v)
			local widget = createWidgetByName('panel/strong_role_card_panel.json')
			local btn = tolua.cast(widget:getChildByName('role_card_btn') , 'UIButton')
			
			local frame = tolua.cast(widget:getChildByName('role_photo_ico') , 'UIImageView')
			if frame then
				frame:setTexture(Role.GetRoleIcoBgImg(v:getQuality()))
				local light = CUIEffect:create()
				light:Show('yellow_light' , 0)
				light:setScale(0.8)
				light:setPosition(ccp(0,0))
				light:setAnchorPoint(ccp(0.5 ,0.5))
				frame:getContainerNode():addChild(light)
				light:setZOrder(50)

				table.insert(lights,j)
				lights[j] = light
				light:setVisible(false)
			end

			table.insert(roleBtnArr , btn)
			table.insert(roleWidgetArr , widget)
			i = i + 1
		end)

		roleSv:scrollToTop()
	end

	local function onshow()
		if isInit == false then
			resetAllBtnStatus()
			initRolesData()
			initRoleSv()
			updateRoleSv()
			getAllRoleStatus()
			initNewRolesData()
			-- updateChannelSV()
			updateAllRoleSv()
			updateChannelSV()
			updateRoleFightTx()
			updateLoadingBar()
		end
		isInit = false
	end

	local function init()
		curRoleId = nil
		root = panel:GetRawPanel()
		local closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		
		-- set money
		local moneyTx = tolua.cast(root:getChildByName('gold_num_tx') , 'UILabel')
		local goldIcon = tolua.cast(root:getChildByName('gold_ico') , 'UIImageView')
		moneyTx:setVisible(false)
		goldIcon:setVisible(false)

		-- set roleSv
		roleSv = tolua.cast(root:getChildByName('role_sv') , 'UIScrollView')
		roleSv:setClippingEnable(true)
		roleSv:setDirection(SCROLLVIEW_DIR_VERTICAL)
		roleSv:setTouchEnable(true)

		roleFightTx = tolua.cast(root:getChildByName('role_fighting_num_tx') , 'UILabel')
		roleFightExpectTx = tolua.cast(root:getChildByName('recommend_num_tx') , 'UILabel')

		roleFightingBar = tolua.cast(root:getChildByName('fighting_exp_bar') , 'UILoadingBar')

		if initRolesData() then
			-- initNewRolesData()
			initRoleSv()
			updateRoleSv()
			getAllRoleStatus()
			initNewRolesData()
			updateChannelSV()
			updateAllRoleSv()
			updateRoleFightTx()
			updateLoadingBar()
			isInit = true
		end
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/strong_panel.json' , 'strong-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('strong_bg_img' , 'strong_img')

		panel:registerInitHandler(init)
		panel:registerOnShowHandler(onshow)

		UiMan.show(sceneObj)
	end

	if stype == 1 then
		initRolesData()
		getAllRoleStatusForMainScene()
		return isVisible
	else
		createPanel()
	end
end