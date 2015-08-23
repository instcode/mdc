
local equipConf = GameData:getArrayData('equip.dat')
local roleConf = GameData:getArrayData('role.dat')
local gemConf = GameData:getArrayData('gem.dat')
local accessoryConf = GameData:getArrayData('accessory.dat')
local weaponConf = GameData:getArrayData('weapon.dat')
local armorConf = GameData:getArrayData('armor.dat')
local urlPath = 'uires/ui_2nd/image/'
local magicIcoPath = 'uires/ui_2nd/com/panel/common/magic_icon.png'
local roleUid
local SoldierIconNames = {
	"dao.png",
	"qiang.png",
	"qibing.png",
	"mou.png",
	"hong.png"
}

local function getWeaponNameColor(strength)
	if strength < 10 then
		return ccc3(255,255,255)
	end
	if strength < 20 then
		return ccc3(0, 255, 0)
	end
	if strength < 40 then
		return ccc3(0, 156, 255)
	end
	if strength < 60 then
		return ccc3(216, 0, 255)
	end
	if strength < 100000 then
		return ccc3(254, 154, 0)
	end
	return ccc3(255,255,255)
end

local function getResource(resource,stype)
	local dateTab = string.split(resource , '.')
	local url
	if stype == 1 then
		url = resource
	elseif stype == 2 then
		url = dateTab[1]..'_icon.'..dateTab[2]
	end
	return url
end

local function getEquipInfo(level)
	local equip
	for i,v in ipairs(equipConf) do
		if tonumber(v.Level) == tonumber(level) then
			equip = v
			return equip
		end
	end
end

local function getRoleInfo(id)
	local role
	for i,v in ipairs(roleConf) do
		if tonumber(v.Id) == tonumber(id) then
			role = v
			return role
		end
	end
end

local function getGemInfo(id)
	local gem
	for i,v in ipairs(gemConf) do
		if tonumber(v.Id) == tonumber(id) then
			gem = v
			return gem
		end
	end
end

local function getAccessoryInfo(strength,quality)
	local accessory
	local info = 'Purple'
	for i,v in ipairs(accessoryConf) do
		if tonumber(v.Strength) == tonumber(strength) then
			accessory = v
			return accessory[info..quality]
		end
	end
end

local function getWeaponInfo(strength,quality)
	local weapon
	local info = 'Purple'
	for i,v in ipairs(weaponConf) do
		if tonumber(v.Strength) == tonumber(strength) then
			weapon = v
			return weapon[info..quality]
		end
	end
end

local function getArmorInfo(strength,quality)
	local armor
	local info = 'Purple'
	for i,v in ipairs(armorConf) do
		if tonumber(v.Strength) == tonumber(strength) then
			armor = v
			return armor[info..quality]
		end
	end
end

function createEquipPanelByEquip(equip,i)
	local equipScene
	local equipPanel
	local stype = i
	if i == 0 then
		i = 1
	end

	function initEquipPanel(equip,i)
		local allAttack = 0
		local allDefense = 0
		local allMagicDefense = 0
		local allSoldier = 0

		root = equipPanel:GetRawPanel()
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(equipScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local bg = tolua.cast(root:getChildByName('zhegai_bg_img') , 'UIImageView')
		bg:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(equipScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		local tipsBg = tolua.cast(root:getChildByName('tips_bg_img') , 'UIImageView')
		tipsBg:setScale9Enable(true)
		local equipNameTx = tolua.cast(root:getChildByName('equip_name_tx') , 'UILabel')
		equipNameTx:setPreferredSize(300,1)
		local equipLevelTx = tolua.cast(root:getChildByName('level_tx') , 'UILabel')
		local equipImg = tolua.cast(root:getChildByName('equip_img') , 'UIImageView')
		local attackIco = tolua.cast(root:getChildByName('attack_ico') , 'UIImageView')
		local attackNumTx = tolua.cast(attackIco:getChildByName('attack_num_tx') , 'UILabel')
		local defenseIco = tolua.cast(root:getChildByName('defense_ico') , 'UIImageView')
		local defenseNumTx = tolua.cast(defenseIco:getChildByName('defense_num_tx') , 'UILabel')
		local magicDefenseIco = tolua.cast(root:getChildByName('magic_defense_ico') , 'UIImageView')
		local magicDefenseNumTx = tolua.cast(magicDefenseIco:getChildByName('magic_defense_num_tx') , 'UILabel')
		local soldierIco = tolua.cast(root:getChildByName('soldier_ico') , 'UIImageView')
		local soldierNumTx = tolua.cast(soldierIco:getChildByName('soldier_num_tx') , 'UILabel')
		local infoTx = tolua.cast(root:getChildByName('info_tx') , 'UILabel')
		infoTx:setPreferredSize(300,1)

		local gems = json.decode(equip:GetGemsIDJson())
		-- print(gems)
		-- local currWeapon = role.equip[i]
		local strength = tonumber(equip:GetStrengthLevel())
		local level = tonumber(equip:GetLevel())
		local weapon = getEquipInfo(level)
		equipLevelTx:setText(strength)

		for j=1,3 do
			local str = 'photo_'..j..'_ico'
			local photoIco = tolua.cast(tipsBg:getChildByName(str) , 'UIImageView')
			local gemNameTx = tolua.cast(photoIco:getChildByName('gem_name_tx') , 'UILabel')
			local attributeTx = tolua.cast(photoIco:getChildByName('attribute_tx') , 'UILabel')
			local attributeAdd = tolua.cast(photoIco:getChildByName('attribute_add_tx') , 'UILabel')
			local gemIco = tolua.cast(photoIco:getChildByName('gem_ico') , 'UIImageView')
			gemNameTx:setPreferredSize(150,1)
			attributeTx:setPreferredSize(100,1)
			if gems and (gems['1'] or gems['2'] or gems['0']) and (gems['1'] ~= 0 or gems['2'] ~= 0 or gems['0'] ~= 0) then
				photoIco:setVisible(true)
				tipsBg:setScale9Size(CCSizeMake(515, 500))
				local gemId = gems[tostring(j - 1)]
				print(gemId)
				if gemId and gemId ~= 0 then
					local gem = Gem:findById(tonumber(gemId))
					gemNameTx:setText(gem:getName())
					gemNameTx:setColor(gem:getNameColor())
					attributeTx:setText(gem:getAttrName())
					attributeAdd:setText(gem:getAttrValue())
					gemIco:setTexture(gem:getResource())
					gemIco:setAnchorPoint(ccp(0, 0))
					if i == 1 then
						if j == 1 or j == 2 then
							allAttack = allAttack + gem:getAttrValue()
						end
					elseif i == 2 then
						if j == 1 then
							allDefense = allDefense + gem:getAttrValue()
						elseif j == 2 then
							allMagicDefense = allMagicDefense + gem:getAttrValue()
						end
					elseif i == 3 then
						if j == 1 or j == 2 then
							allSoldier = allSoldier + gem:getAttrValue()
						end
					end
				else
					photoIco:setVisible(false)
				end
			else
				photoIco:setVisible(false)
				tipsBg:setScale9Size(CCSizeMake(515, 330))
			end
		end

		if i == 1 then
			defenseIco:setVisible(false)
			magicDefenseIco:setVisible(false)
			soldierIco:setVisible(false)
			attackNumTx:setText(tonumber(getWeaponInfo(strength,level)) + allAttack)
			if stype == 1 then
				equipNameTx:setText(GetTextForCfg(weapon.MagicName))
				equipNameTx:setColor(getWeaponNameColor(strength))
				attackIco:setTexture(magicIcoPath)
				attackIco:setAnchorPoint(ccp(0, 0))
				infoTx:setText(getLocalStringValue('E_STR_WEAR_SOLDIER_MAGIC'))
				equipImg:setTexture(urlPath..getResource(weapon.MagicUrl,1))
			else
				equipNameTx:setText(GetTextForCfg(weapon.WeaponName))
				equipNameTx:setColor(getWeaponNameColor(strength))
				infoTx:setText(getLocalStringValue('E_STR_WEAR_SOLDIER_PHYSICAL'))
				equipImg:setTexture(urlPath..getResource(weapon.WeaponUrl,1))
			end
		elseif i == 2 then
			attackIco:setVisible(false)
			soldierIco:setVisible(false)
			defenseNumTx:setText(tonumber(getArmorInfo(strength,level)) + allDefense)
			magicDefenseNumTx:setText(tonumber(getArmorInfo(strength,level)) + allMagicDefense)
			equipNameTx:setText(GetTextForCfg(weapon.ArmorName))
			equipNameTx:setColor(getWeaponNameColor(strength))
			infoTx:setText(getLocalStringValue('E_STR_WEAR_SOLDIER_ALL'))
			equipImg:setTexture(urlPath..getResource(weapon.ArmorUrl,1))
		elseif i == 3 then
			defenseIco:setVisible(false)
			magicDefenseIco:setVisible(false)
			attackIco:setVisible(false)
			soldierNumTx:setText(tonumber(getAccessoryInfo(strength,level)) + allSoldier)
			equipNameTx:setText(GetTextForCfg(weapon.AccessoryName))
			equipNameTx:setColor(getWeaponNameColor(strength))
			infoTx:setText(getLocalStringValue('E_STR_WEAR_SOLDIER_ALL'))
			equipImg:setTexture(urlPath..getResource(weapon.AccessoryUrl,1))
		end
		equipImg:setAnchorPoint(ccp(0, 0))

		-- local starBG = tolua.cast(root:getChildByName('star_bg_img'), 'UIImageView')
		-- starBG:setVisible(true)
		-- local starNum = UserData:getStarInfo(equip:GetID())
		-- for i = 1 , 10 do
		-- 	local starIco = tolua.cast(starBG:getChildByName('star' .. i .. '_icon'), 'UIImageView')
		-- 	if starNum >= i then
		-- 		starIco:setVisible(true)
		-- 	else
		-- 		starIco:setVisible(false)
		-- 	end
		-- end
	end

	equipScene = SceneObjEx:createObj('panel/equip_tips_panel.json', 'equip-tips-in-lua')
    equipPanel = equipScene:getPanelObj()
    equipPanel:setAdaptInfo('zhegai_bg_img', 'tips_bg_img')

	equipPanel:registerInitHandler(function ()
		initEquipPanel(equip,i)
	end)
	print(equip:GetGemsIDJson())
	UiMan.show(equipScene)
end

function createEquipPanel(equip,i)
	local equipScene
	local equipPanel

	function initEquipPanel(equip,i)
		local allAttack = 0
		local allDefense = 0
		local allMagicDefense = 0
		local allSoldier = 0

		root = equipPanel:GetRawPanel()
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(equipScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local bg = tolua.cast(root:getChildByName('zhegai_bg_img') , 'UIImageView')
		bg:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(equipScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		local tipsBg = tolua.cast(root:getChildByName('tips_bg_img') , 'UIImageView')
		tipsBg:setScale9Enable(true)
		local equipNameTx = tolua.cast(root:getChildByName('equip_name_tx') , 'UILabel')
		local equipLevelTx = tolua.cast(root:getChildByName('level_tx') , 'UILabel')
		local equipImg = tolua.cast(root:getChildByName('equip_img') , 'UIImageView')
		local attackIco = tolua.cast(root:getChildByName('attack_ico') , 'UIImageView')
		local attackNumTx = tolua.cast(attackIco:getChildByName('attack_num_tx') , 'UILabel')
		local defenseIco = tolua.cast(root:getChildByName('defense_ico') , 'UIImageView')
		local defenseNumTx = tolua.cast(defenseIco:getChildByName('defense_num_tx') , 'UILabel')
		local magicDefenseIco = tolua.cast(root:getChildByName('magic_defense_ico') , 'UIImageView')
		local magicDefenseNumTx = tolua.cast(magicDefenseIco:getChildByName('magic_defense_num_tx') , 'UILabel')
		local soldierIco = tolua.cast(root:getChildByName('soldier_ico') , 'UIImageView')
		local soldierNumTx = tolua.cast(soldierIco:getChildByName('soldier_num_tx') , 'UILabel')
		local infoTx = tolua.cast(root:getChildByName('info_tx') , 'UILabel')
		equipNameTx:setPreferredSize(300,1)
		infoTx:setPreferredSize(300,1)

		local gems = equip.gems
		local currWeapon = equip
		local strength = tonumber(currWeapon.strength)
		local level = tonumber(currWeapon.level)
		local weapon = getEquipInfo(level)
		equipLevelTx:setText(strength)

		for j=1,3 do
			local str = 'photo_'..j..'_ico'
			local photoIco = tolua.cast(tipsBg:getChildByName(str) , 'UIImageView')
			local gemNameTx = tolua.cast(photoIco:getChildByName('gem_name_tx') , 'UILabel')
			local attributeTx = tolua.cast(photoIco:getChildByName('attribute_tx') , 'UILabel')
			local attributeAdd = tolua.cast(photoIco:getChildByName('attribute_add_tx') , 'UILabel')
			local gemIco = tolua.cast(photoIco:getChildByName('gem_ico') , 'UIImageView')
			gemNameTx:setPreferredSize(150,1)
			attributeTx:setPreferredSize(100,1)
			if gems and (gems['1'] or gems['2'] or gems['3'])then
				photoIco:setVisible(true)
				tipsBg:setScale9Size(CCSizeMake(515, 500))
				local gemId = gems[tostring(j)]
				if gemId then
					local gem = Gem:findById(tonumber(gemId))
					gemNameTx:setText(gem:getName())
					gemNameTx:setColor(gem:getNameColor())
					attributeTx:setText(gem:getAttrName())
					attributeAdd:setText(gem:getAttrValue())
					gemIco:setTexture(gem:getResource())
					gemIco:setAnchorPoint(ccp(0, 0))
					if i == 1 then
						if j == 1 or j == 2 then
							allAttack = allAttack + gem:getAttrValue()
						end
					elseif i == 2 then
						if j == 1 then
							allDefense = allDefense + gem:getAttrValue()
						elseif j == 2 then
							allMagicDefense = allMagicDefense + gem:getAttrValue()
						end
					elseif i == 3 then
						if j == 1 or j == 2 then
							allSoldier = allSoldier + gem:getAttrValue()
						end
					end
				else
					photoIco:setVisible(false)
				end
			else
				photoIco:setVisible(false)
				tipsBg:setScale9Size(CCSizeMake(515, 330))
			end
		end

		if i == 1 then
			defenseIco:setVisible(false)
			magicDefenseIco:setVisible(false)
			soldierIco:setVisible(false)
			attackNumTx:setText(tonumber(getWeaponInfo(strength,level)) + allAttack)
			if currWeapon and currWeapon.type and currWeapon.type == 'magic' then
				equipNameTx:setText(GetTextForCfg(weapon.MagicName))
				equipNameTx:setColor(getWeaponNameColor(strength))
				attackIco:setTexture(magicIcoPath)
				attackIco:setAnchorPoint(ccp(0, 0))
				infoTx:setText(getLocalStringValue('E_STR_WEAR_SOLDIER_MAGIC'))
				equipImg:setTexture(urlPath..getResource(weapon.MagicUrl,1))
			else
				equipNameTx:setText(GetTextForCfg(weapon.WeaponName))
				equipNameTx:setColor(getWeaponNameColor(strength))
				infoTx:setText(getLocalStringValue('E_STR_WEAR_SOLDIER_PHYSICAL'))
				equipImg:setTexture(urlPath..getResource(weapon.WeaponUrl,1))
			end
		elseif i == 2 then
			attackIco:setVisible(false)
			soldierIco:setVisible(false)
			defenseNumTx:setText(tonumber(getArmorInfo(strength,level)) + allDefense)
			magicDefenseNumTx:setText(tonumber(getArmorInfo(strength,level)) + allMagicDefense)
			equipNameTx:setText(GetTextForCfg(weapon.ArmorName))
			equipNameTx:setColor(getWeaponNameColor(strength))
			infoTx:setText(getLocalStringValue('E_STR_WEAR_SOLDIER_ALL'))
			equipImg:setTexture(urlPath..getResource(weapon.ArmorUrl,1))
		elseif i == 3 then
			defenseIco:setVisible(false)
			magicDefenseIco:setVisible(false)
			attackIco:setVisible(false)
			soldierNumTx:setText(tonumber(getAccessoryInfo(strength,level)) + allSoldier)
			equipNameTx:setText(GetTextForCfg(weapon.AccessoryName))
			equipNameTx:setColor(getWeaponNameColor(strength))
			infoTx:setText(getLocalStringValue('E_STR_WEAR_SOLDIER_ALL'))
			equipImg:setTexture(urlPath..getResource(weapon.AccessoryUrl,1))
		end
		equipImg:setAnchorPoint(ccp(0, 0))

		-- local starBG = tolua.cast(root:getChildByName('star_bg_img'), 'UIImageView')
		-- starBG:setVisible(true)
		-- local starNum = equip.star or 0
		-- for i = 1 , 10 do
		-- 	local starIco = tolua.cast(starBG:getChildByName('star' .. i .. '_icon'), 'UIImageView')
		-- 	if starNum >= i then
		-- 		starIco:setVisible(true)
		-- 	else
		-- 		starIco:setVisible(false)
		-- 	end
		-- end
	end

	equipScene = SceneObjEx:createObj('panel/equip_tips_panel.json', 'equip-tips-in-lua')
    equipPanel = equipScene:getPanelObj()
    equipPanel:setAdaptInfo('zhegai_bg_img', 'tips_bg_img')

	equipPanel:registerInitHandler(function ()
		initEquipPanel(equip,i)
	end)
	UiMan.show(equipScene)
end

function createRolePanel(role,uid)
	print(json.encode(role))
	local roleScene
	local rolePanel
	local weapon
	local armor
	local accessory
	local equipStype
	function initRolePanel(role)
		root = rolePanel:GetRawPanel()
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(roleScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local typeIco = tolua.cast(root:getChildByName('type_ico') , 'UIImageView')
		local roleNameTx = tolua.cast(root:getChildByName('role_name_tx') , 'UILabel')
		local roleImg = tolua.cast(root:getChildByName('role_img') , 'UIImageView')
		local growUpIco = tolua.cast(root:getChildByName('grow_up_ico') , 'UIImageView')
		local growNumTx = tolua.cast(growUpIco:getChildByName('num_tx') , 'UILabel')
		local defenseIco = tolua.cast(root:getChildByName('defense_ico') , 'UIImageView')
		local defenseNumTx = tolua.cast(defenseIco:getChildByName('num_tx') , 'UILabel')
		local magicDefenseIco = tolua.cast(root:getChildByName('magic_defense_ico') , 'UIImageView')
		local magicDefenseNumTx = tolua.cast(magicDefenseIco:getChildByName('num_tx') , 'UILabel')
		local soldierIco = tolua.cast(root:getChildByName('soldier_ico') , 'UIImageView')
		local soldierNumTx = tolua.cast(soldierIco:getChildByName('num_tx') , 'UILabel')
		local attackIco = tolua.cast(root:getChildByName('attack_ico') , 'UIImageView')
		local attackNumTx = tolua.cast(attackIco:getChildByName('num_tx') , 'UILabel')
		local roleImg = tolua.cast(root:getChildByName('role_img') , 'UIImageView')
		local typeIco = tolua.cast(root:getChildByName('type_ico') , 'UIImageView')

		local equipImg1 = tolua.cast(root:getChildByName('equip_1_img') , 'UIImageView')
		local equipIco1 = tolua.cast(equipImg1:getChildByName('equip_ico') , 'UIImageView')
		local equipImg2 = tolua.cast(root:getChildByName('equip_2_img') , 'UIImageView')
		local equipIco2 = tolua.cast(equipImg2:getChildByName('equip_ico') , 'UIImageView')
		local equipImg3 = tolua.cast(root:getChildByName('equip_3_img') , 'UIImageView')
		local equipIco3 = tolua.cast(equipImg3:getChildByName('equip_ico') , 'UIImageView')

		equipIco1:registerScriptTapHandler(function ()
			createEquipPanel(weapon,1)
		end)

		equipIco2:registerScriptTapHandler(function ()
			createEquipPanel(armor,2)
		end)

		equipIco3:registerScriptTapHandler(function ()
			createEquipPanel(accessory,3)
		end)

		if tonumber(uid) < 100000 then
			growNumTx:setText(30)
		else
			growNumTx:setText(role.grouth or 30)
		end
		attackNumTx:setText(role.attack or 0)
		defenseNumTx:setText(role.defence or 0)
		magicDefenseNumTx:setText(role.mdefence or 0)
		soldierNumTx:setText(role.health or 0)

		local roleCard = getRoleInfo(role.id)
		if not roleCard then
			return
		end
		roleNameTx:setText(GetTextForCfg(roleCard.Name))
		local quantity = roleCard.Quantity
		if quantity == 'blue' then
			roleNameTx:setColor(COLOR_TYPE.BLUE)
		elseif quantity == 'purple' then
			roleNameTx:setColor(COLOR_TYPE.PURPLE)
		elseif quantity == 'orange' then
			roleNameTx:setColor(COLOR_TYPE.ORANGE)
		elseif quantity == 'ared' or quantity == 'sred' then
			roleNameTx:setColor(COLOR_TYPE.RED)
		end
		roleImg:setTexture(urlPath..roleCard.Url)
		roleImg:setAnchorPoint(ccp(0.5, 0))
		if tonumber(roleCard.Soldier) == 4 or tonumber(roleCard.Soldier) == 5 then
			attackIco:setTexture(magicIcoPath)
			attackIco:setAnchorPoint(ccp(0, 0))
		end
		str = string.format('%s%s','uires/ui_2nd/com/panel/common/',SoldierIconNames[tonumber(roleCard.Soldier)])
		typeIco:setTexture(str)
		typeIco:setAnchorPoint(ccp(0, 0))

		if role.equip then
			for i,v in ipairs(role.equip) do
				local tab = v
				local stype = tab.type
				if stype then
					if stype == 'magic' then
						weapon = tab
						equipStype = 0
						equipIco1:setTouchEnable(true)
						equipIco1:setTexture(urlPath..getResource(getEquipInfo(tonumber(tab.level)).MagicUrl,2))
					elseif stype == 'weapon' then
						weapon = tab
						equipStype = 1
						equipIco1:setTouchEnable(true)
						equipIco1:setTexture(urlPath..getResource(getEquipInfo(tonumber(tab.level)).WeaponUrl,2))
					elseif stype == 'armor' then
						armor = tab
						-- equipStype = 2
						equipIco2:setTouchEnable(true)
						equipIco2:setTexture(urlPath..getResource(getEquipInfo(tonumber(tab.level)).ArmorUrl,2))
					elseif stype == 'accessory' then
						accessory = tab
						-- equipStype = 3
						equipIco3:setTouchEnable(true)
						equipIco3:setTexture(urlPath..getResource(getEquipInfo(tonumber(tab.level)).AccessoryUrl,2))
					end
				end
			end
		end
	end

	roleScene = SceneObjEx:createObj('panel/role_tips_panel.json', 'role-tips-in-lua')
    rolePanel = roleScene:getPanelObj()
    rolePanel:setAdaptInfo('zhegai_bg_img', 'tips_bg_img')

	rolePanel:registerInitHandler(function ()
		initRolePanel(role)
	end)
	UiMan.show(roleScene)
end

function genRolePanel(uid,name,jsonCode,rank)
	local sceneObj
	local panel
	local allFightForce = 0
	local zhanNumLa
	local data = jsonCode.data
	function updateRoleList()
	end

	function updateAwardsPanel()
		root = panel:GetRawPanel()
		local index = 1
		for i,v in pairs(data.infos) do
			-- index = tonumber(i) + 1
			if index <= 7 and v ~= 0 then

				str = 'role_'..index..'_img'
				print(str)
				roleImg = tolua.cast(root:getChildByName(str) , 'UIImageView')
				roleIco = tolua.cast(roleImg:getChildByName('role_ico') , 'UIImageView')
				roleNameTx = tolua.cast(roleImg:getChildByName('role_name_tx') , 'UILabel')
				zhanNumTx = tolua.cast(roleImg:getChildByName('zhan_num_tx') , 'UILabel')

				local framRes,iconRes,fightforce,strName,color
				if tonumber(uid) < 100000 then
					tab = getMosterInfo(data.infos[i].id)
					framRes = tab.bgRes
					iconRes = tab.iconRes
					strName = tab.name
					color = COLOR_TYPE.BLUE
				else
					pRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject( data.infos[i].id, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
					pRoleCardObj = tolua.cast(pRoleCardObj,'CLDRoleCardObject')
					framRes = pRoleCardObj:GetIconFrame()
					iconRes = pRoleCardObj:GetRoleIcon(RESOURCE_TYPE.ICON)
					strName = pRoleCardObj:GetRoleName()
					color = pRoleCardObj:GetRoleNameColor()
				end
				fightforce =  data.infos[i].fight_force
				roleIco:setTexture(iconRes)
				roleIco:registerScriptTapHandler(function ()
					createRolePanel(data.infos[i],uid)
				end)
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
				allFightForce = allFightForce + fightforce
			end
		end
		zhanNumLa:setStringValue(allFightForce)
	end

	function init()
		root = panel:GetRawPanel()
		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		nameTx = tolua.cast(root:getChildByName('name_tx') , 'UILabel')
		nameTx:setText(name)

		rankingNumTx = tolua.cast(root:getChildByName('ranking_num_tx') , 'UILabel')
		rankTx = tolua.cast(root:getChildByName('rank_tx') , 'UILabel')
		if rank and type(rank) == 'number' then
			rankingNumTx:setText(rank)
			rankingNumTx:setVisible(true)
			rankTx:setVisible(true)
		else
			rankingNumTx:setVisible(false)
			rankTx:setVisible(false)
		end

		zhanNumLa = tolua.cast(root:getChildByName('zhan_num_la') , 'UILabelAtlas')

		allFightForce = 0
		updateAwardsPanel()
	end

    local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/pvp_roles_panel.json', 'check-role-in-lua')
	    panel = sceneObj:getPanelObj()
	    panel:setAdaptInfo('have_role_img', 'have_img')

		panel:registerInitHandler(init)
		UiMan.show(sceneObj)
	end

	createPanel()
end
