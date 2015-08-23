RoleAwakePanel = {
	panel = nil
}

function RoleAwakePanel:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

local function createPanel()
	local panel = createWidgetByName('panel/role_awaken_panel.json')
	return panel
end

-- not a instance
function RoleAwakePanel:createInst()
	self.panel = createPanel()
	self:UpdatePanel()
	return self
end

local function getChild( parent , name , ttype )
	return tolua.cast(parent:getChildByName(name) , ttype)
end

local function getRoleAwakeDataById( id )
	local conf = GameData:getArrayData('roleawake.dat')
	for k , v in pairs ( conf ) do
		if tonumber(v.Id) == tonumber(id) then
			return v
		end
	end
	return nil
end

local function getSkillDataById( id )
	local conf = GameData:getArrayData('skill.dat')
	for k , v in pairs ( conf ) do
		if tonumber(v.Soldier) == 0 and tonumber(v.Skill) == tonumber(id) then
			return v
		end
	end
	return nil
end

local function getSkillEffectDataById( id )
	local conf = GameData:getArrayData('skilleffect.dat')
	for k , v in pairs ( conf ) do
		if tonumber(v.Soldier) == 0 and tonumber(v.Skill) == tonumber(id) then
			return v
		end
	end
	return nil
end

function RoleAwakePanel:UpdatePanel()
	local rightImg = getChild(self.panel , 'right_img' , 'UIImageView')
	local awakeNoticeTx = getChild( rightImg , 'awake_notice_tx' , 'UILabel')
	awakeNoticeTx:setPreferredSize(460,1)
	local titlePl = getChild( rightImg , 'title_bg_img' , 'UIImageView')
	local showPl = getChild( rightImg , 'di_img' , 'UIImageView')
	local item_1 = getChild( rightImg , 'card_1_img' , 'UIImageView')
	local item_2 = getChild( rightImg , 'card_2_img' , 'UIImageView')
	local item_3 = getChild( rightImg , 'card_3_img' , 'UIImageView')
	local awakenBtn = getChild( rightImg , 'awaken_btn' , 'UITextButton')
	local finishNoticeTx = getChild( item_3 , 'finish_notice_tx' , 'UILabel')
	finishNoticeTx:setPreferredSize(440,1)
	local container = {titlePl, item_1 , item_2 , item_3 , showPl , awakenBtn}

	local rid = _getSelectRoleID()
	local ridObj = Role:findById( tonumber(rid) )
	local isOpen = true

	assert( ridObj , 'must not be nil ...')

	if ridObj:getQuality() < E_ROLE_QUALITY_SRED then
		isOpen = false
		awakeNoticeTx:setText( getLocalString('E_STR_ONLY_SRED_ROLE_AWAKE') )
	elseif PlayerCoreData.getSoldierGodByID( rid ) <= 0 then
		isOpen = false
		awakeNoticeTx:setText( getLocalString('E_STR_NO_OPEN_THIS_ROLE_AWAKE') )
	end

	awakeNoticeTx:setVisible( not isOpen )
	for _, v in pairs( container ) do
		v:setVisible( isOpen )
	end

	if not isOpen then
		return
	end

	local awakeData = getRoleAwakeDataById( rid )
	assert( awakeData , 'awakeData must not be nil ...')
	local skillData = getSkillDataById( tonumber(awakeData.SkillId) )
	assert( skillData , 'skillData must not be nil ...')
	local skillEffectData = getSkillEffectDataById( tonumber(awakeData.SkillId) )
	assert( skillEffectData , 'skillEffectData must not be nil ...')

	-- item_1
	local skillIco = getChild( item_1 , 'skill_ico' , 'UIImageView')
	local skillNameTx = getChild( item_1 , 'name_tx' , 'UILabel')
	local skillDescTx = getChild( item_1 , 'describe_tx' , 'UILabel')
	skillDescTx:setPreferredSize(160,1)
	
	skillIco:setTexture( 'uires/ui_2nd/image/' .. skillData.SkillUrl )
	skillNameTx:setText( GetTextForCfg(skillData.SkillName) )
	skillNameTx:setColor( ccc3( 255 , 165 , 0 ) )
	skillDescTx:setText( GetTextForCfg(skillEffectData.Desc) )

	local function getPosFromTab( tab , value )
		if type(tab) ~= 'table' then
			return 0
		end
		for k , v in pairs(tab) do
			if tostring(v) == tostring(value) then
				return tonumber(k)
			end
		end
		return 0
	end

	-- item_2
	local attrs = {'attack' , 'defence' , 'mdefence' , 'health' , 'block' , 'fortitude' , 'miss' , 'unblock' , 'critdamage' , 'hit'}
	local attrUrls = {'attack_icon' , 'defense_icon' , 'magic_defense_icon' , 'soldier_icon' , 'block_icon' , 'fortitude_icon' , 'miss_icon' , 'unblock_icon' , 'critdamage_icon' , 'hit_icon'}
	local firstUrl = 'uires/ui_2nd/com/panel/common/'
	for i = 1 , 4 do
		local aItem = getChild( item_2 , 'attr_bg_' .. i .. '_img' , 'UIImageView')
		local attrIco = getChild( aItem , 'attr_ico' , 'UIImageView')
		local valueTx = getChild( aItem , 'add_num_tx' , 'UILabel')
		local attrStr = tostring(awakeData['Attribute' .. i])
		local key = tostring(string.split( attrStr , ':')[1])
		local pos = getPosFromTab(attrs , key)
		local url = attrUrls[pos]
		local value = tonumber(string.split( attrStr , ':')[2])

		valueTx:setText( '+' .. tostring(value) )
		valueTx:setColor( COLOR_TYPE.GREEN )
		attrIco:setTexture( firstUrl .. url .. '.png')

		if key == 'attack' then
			local stype = PlayerCoreData.getSoldierTypeByID( rid )
			if stype <= 3 then
				attrIco:setTexture(firstUrl .. 'attack_icon.png')
			else
				attrIco:setTexture(firstUrl .. 'magic_icon.png')
			end
		end
	end

	-- item_3
	local fragmentNumTx = getChild( item_3 , 'fragment_num_tx' , 'UILabel')
	local soldierTypeTx = getChild( item_3 , 'soldier_type_tx' , 'UILabel')
	local fragItem = getChild( item_3 , 'fragment_bg_img' , 'UIImageView')
	local typeItem = getChild( item_3 , 'rank_bg_img' , 'UIImageView')

	local soldierLv = tonumber(ridObj:getSoldier().level)
	local hopeSoldierLv = tonumber(awakeData.SoldierLevel)

	local mNum = PlayerCoreData.getMaterialCount( tonumber(awakeData.MaterialId) )
	local hopeNeedNum = tonumber(awakeData.MaterialNum)

	local strstr = string.format( getLocalString('E_STR_SOLDIER_LEVEL_AND_SOLDIER_LEVEL') , soldierLv , hopeSoldierLv)
	soldierTypeTx:setText( strstr )
	soldierTypeTx:setColor( soldierLv < hopeSoldierLv and COLOR_TYPE.RED or COLOR_TYPE.GREEN )
	fragmentNumTx:setText( mNum .. '/' .. hopeNeedNum)
	fragmentNumTx:setColor( mNum < hopeNeedNum and COLOR_TYPE.RED or COLOR_TYPE.GREEN )

	--init buttons
	local godLv = ridObj:getGodLevel()
	cclog('godLv = ' .. godLv)

	if godLv > 0 then
		finishNoticeTx:setVisible(true)
		awakenBtn:setVisible(false)
		fragItem:setVisible(false)
		typeItem:setVisible(false)
		fragmentNumTx:setVisible(false)
		soldierTypeTx:setVisible(false)
	else
		finishNoticeTx:setVisible(false)
		awakenBtn:setVisible(true)
		fragItem:setVisible(true)
		typeItem:setVisible(true)
		fragmentNumTx:setVisible(true)
		soldierTypeTx:setVisible(true)
	end

	if awakenBtn:isVisible() then
		awakenBtn:registerScriptTapHandler(function ()
			if soldierLv < hopeSoldierLv then
				GameController.showPrompts( getLocalString('E_STR_NO_ROLE_AWAKE_SOLDIER_LEVEL') , COLOR_TYPE.RED )
				return
			end

			if mNum < hopeNeedNum then
				GameController.showMessageBox(getLocalString('E_STR_NO_ROLE_AWAKE_GOD_FRAGMENT'), MESSAGE_BOX_TYPE.OK )
				return
			end

			local args = { rid = rid }
			Message.sendPost('awake' , 'role' , json.encode(args) , function (jsonData) 
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic['code'] ~= 0 then
					cclog('request error : ' .. jsonDic['desc'])
					return
				end

				local data = jsonDic['data']

				if data['awake'] then
					ridObj:setGodLevel( data['awake'] )
				end

				if data['material'] then
					local mTab = {}
					table.insert(mTab , 'material')
					table.insert(mTab , awakeData.MaterialId)
					table.insert(mTab , data['material'][tostring(awakeData.MaterialId)])
					local mstr = '[' .. json.encode(mTab) .. ']'
					UserData.parseAwardJson( mstr )
				end

				CRoleMgr:GetInst():ShowRoleAwakeEffectPanel()

				self:UpdatePanel()

				updateRoleInfoByID( rid )
			end)
		end)
	end

	local posArr = {}
	posArr[94] = ccp(110 , -5)			-- 关羽
	posArr[96] = ccp(110 , -5)			-- 赵云
	posArr[98] = ccp(110 , -15)			-- 吕布
	posArr[99] = ccp(115 , -5)			-- 诸葛亮
	posArr[102] = ccp(115 , 0)			-- 洛神

	-- init GodShow
	showPl:getValidNode():removeAllChildrenWithCleanup(true)
	local legion = CLegion:create(true)
	legion:updateRoleId( rid )
	legion:updateInitStatus( 1 , 0)
	legion:SetSoliderType( ridObj:getSoldier().stype )
	legion:SetGodType( 1 )
	legion:InitSoldiers( ridObj:getSoldier().level , false )
	legion:setScale( 1.7 )
	
	if posArr[rid] then
		legion:setPosition(posArr[rid])
	else
		legion:setPosition(115 , 0)
	end
	
	showPl:getValidNode():addChild(legion)
end

