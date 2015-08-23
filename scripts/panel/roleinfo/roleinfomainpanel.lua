
--Exports to global

local E_RESOURCE_TYPE_BIG = 0
local E_RESOURCE_TYPE_NORMAL = 1
local E_RESOURCE_TYPE_ICON = 2
--Exporting done

local ROLE_SUB_PAGE_INIT_RECT  = CCRectMake(435, 13, 509, 535)
local ROLE_PAGE_VIEW_INIT_RECT = CCRectMake(75, 23, 270, 455)
local ROLE_IMG_INIT_POS = CCPointMake(140, 200)

local selectRoleID = -1
local totPageCount = 0
local currentPageIndex = -1
local roleObjects = {}

local subPageInfo = {}
local shutdownHandler

--exports
function updateRoleMainPanel()
	if subPageInfo.infoPage then
		subPageInfo.infoPage:UpdateRoleInfoPanel()
	end

	if subPageInfo.skillPage then
		subPageInfo.skillPage:UpdatePanel()
	end

	if subPageInfo.trainPage then
		subPageInfo.trainPage:UpdateView()
	end

	if subPageInfo.soulPage then
		subPageInfo.soulPage:UpdatePanel()
	end

	if subPageInfo.awakePage then
		subPageInfo.awakePage:UpdatePanel()
	end

	--Info main panel itself
	if subPageInfo.mainPanelUpdater then
		subPageInfo.mainPanelUpdater(roleObjects[currentPageIndex+1])
	end
end

--Exporting to C++
function _getSelectRoleID()
	return selectRoleID
end

--Exporting to C++
function setSelectRoleID(id)
	selectRoleID = id
end

--Test if (Info), (Culture), (ExSoul) is opened
local function getOpenFuncs()
	local inAll = 4 
	local levelNow = PlayerCoreData.getPlayerLevel()
	local growLevel = getGlobalIntegerValue('FosterOpenLevel')  --25
	local awakeLevel = getGlobalIntegerValue('RoleAwakeOpenLevel')	--40
	local soulLevel = getGlobalIntegerValue('SoulOpenLevel')	--50
	if levelNow < growLevel then inAll = inAll - 1 end
	if levelNow < soulLevel then inAll = inAll - 1 end
	if levelNow < awakeLevel then inAll = inAll - 1 end
	return inAll
end

local function genTitleButtonsUpdater(root, pageView, creators)
	local t1 = tolua.cast(root:getChildByName('title_1_btn'),'UIButton')
	t1:setPressState(WidgetStateSelected)	--Default
	local t2 = tolua.cast(root:getChildByName('title_2_btn'),'UIButton')
	local t3 = tolua.cast(root:getChildByName('title_3_btn'),'UIButton')
	local t4 = tolua.cast(root:getChildByName('title_4_btn'),'UIButton')
	local ts = {t1,t2,t3,t4}

	local function updateButtonState(index)
		local okCount = getOpenFuncs()
		for i=1,#ts do
			local state = WidgetStateNormal
			if i > okCount then
				state = WidgetStateDisabled
			elseif index == i then
				state = WidgetStateSelected
			end
			ts[i]:setPressState(state)
			ts[i]:setTouchEnable(state==WidgetStateNormal)
			--print('state changed for site 1000A for ' .. tostring(i))
		end
	end

	local function genTouch(index)
		return function()
			updateButtonState(index)
			pageView:scrollToPage(index - 1)
			-- Get ready to scroll to target page
		end
	end

	for i=1,#ts do
		ts[i]:registerScriptTapHandler(genTouch(i))
	end

	return function(index)
		updateButtonState(index+1)
		if type(creators[index+1]) == 'function' then
			creators[index+1]()
		end
		if 0 == index then
			UpdateSceneId(GLOBALSCENEID_ROLEINFOMATIONPANEL)
		elseif 1 == index then
			UpdateSceneId(GLOBALSCENEID_ROLETRAININGPANEL)
		elseif 2 == index then
			UpdateSceneId(GLOBALSCENEID_ROLEAWAKEPANEL)
		elseif 3 == index then
			UpdateSceneId(GLOBALSCENEID_ROLEEXSOULPANEL)
		end
	end
end

local function sortRoleFn(a,b)
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

--Return type: Array
local function getRoles()
	local rolesTab = {}
    local rolesIdTab = json.decode(PlayerCoreData.getAllRolesId())
	for _, v in pairs(rolesIdTab) do
		local roleID = tonumber(v)
		--print('this is id ' .. tostring(roleID))
		local obj = Role:findById(roleID)
		if obj then
			rolesTab[#rolesTab + 1] = obj
		end
	end

	table.sort(rolesTab, sortRoleFn)
	if #rolesTab > 0 then
		return rolesTab
	end
	return false
end


--returns:
-- 1. role pageview
-- 2. sub-pages table
local function setupRoleView(parent)
	local rolePv = UIPageView:create()
	parent:addChild(rolePv)

	rolePv:setPosition(ROLE_PAGE_VIEW_INIT_RECT.origin)
	rolePv:setSize(ROLE_PAGE_VIEW_INIT_RECT.size)
	rolePv:setTouchEnable(true)

	local roles = getRoles()
	roleObjects = roles
	assert(type(roles) == 'table', 'must be of table')

	if selectRoleID <= 0 and #roles > 0 then
		selectRoleID = roles[1].id
	end

	totPageCount = #roles     -- In all
	currentPageIndex = 0
	local subPages = {}
	for k,role in pairs(roles) do
		local roleImage = UIImageView:create()
		roleImage:setTexture(role.role:GetRoleIcon(E_RESOURCE_TYPE_BIG))
		roleImage:setAnchorPoint(ccp(0.5,0))
		roleImage:setScale(0.7)
		roleImage:setPosition(ROLE_IMG_INIT_POS)
		roleImage:setName('subpage')
		roleImage:setActionTag(role.role:GetID())
		local container = UIContainerWidget:create()
		container:addChild(roleImage)
		rolePv:addPage(container)
		subPages[#subPages+1] = roleImage
	end

	--左右箭头
	local arrowToPrev = tolua.cast(parent:getChildByName('arrow_1_btn'), 'UIButton')
	arrowToPrev:registerScriptTapHandler(
		function()
			currentPageIndex = currentPageIndex - 1
			if currentPageIndex < 0 then
				currentPageIndex = totPageCount - 1
			end
			rolePv:scrollToPage(currentPageIndex, 2)
		end
	)
	local arrowToNext = tolua.cast(parent:getChildByName('arrow_2_btn'), 'UIButton')
	arrowToNext:registerScriptTapHandler(
		function()
			currentPageIndex = currentPageIndex + 1
			if currentPageIndex >= totPageCount then
				currentPageIndex = 0 
			end
			rolePv:scrollToPage(currentPageIndex, 1)
		end
	)

	--PvRoleScroll2PageByRoleID(pRoleMgr->GetSelectRoleID());
	return rolePv, subPages
end

--TODO
local function genScrollToPage(page)
	return function(pageIndex)

	end
end

local function genInfoPageCreator(container)
	return function()
		if not subPageInfo.infoPage then
			local infoPage = CRoleInfomationPanel:createInst()
			container:addChild(infoPage)
			subPageInfo.infoPage = infoPage
			print('(role-info) info-page created.')
		end
	end
end

local function genSkillPageCreator(container)
	return function()
		if not subPageInfo.skillPage then
			local skillPage = CSkillPanel:createInst()
			container:addChild(skillPage)
			subPageInfo.skillPage = skillPage
			print('(role-info) skill-page created.')
		end
	end
end

local function genTrainPageCreator(container)
	return function()
		-- FosterOpenLevel
			if not subPageInfo.trainPage then
				local trainPage = CTrainingPanel:createInst()

				container:addChild(trainPage)
				subPageInfo.trainPage = trainPage
				print('(role-info) train-page created.')
			end
	end
end

local function genSoulPageCreator(container)
	return function()
		-- SoulOpenLevel
			if not subPageInfo.soulPage then
				local soulPage = CExSoulPanel:createInst()
				container:addChild(soulPage)
				subPageInfo.soulPage = soulPage
				print('(role-info) soul-page created.')
			end
	end
end

local function genAwakePageCreator(container)
	return function()
		-- RoleAwakeOpenLevel
			if not subPageInfo.awakePage then
				local awakePage = RoleAwakePanel:createInst()

				container:addChild(awakePage.panel)
				subPageInfo.awakePage = awakePage
				print('(role-info) awake-page created.')
			end
	end
end

local function setupDivisionView(parent)
	local pv = UIPageView:create()
	pv:setPosition(ROLE_SUB_PAGE_INIT_RECT.origin)
	pv:setSize(ROLE_SUB_PAGE_INIT_RECT.size)
	pv:setTouchEnable(true)
	parent:addChild(pv)

	local levelNow = PlayerCoreData.getPlayerLevel()
	local skillPageContainer = UIContainerWidget:create()
	pv:addPage(skillPageContainer)

	local growLevel = getGlobalIntegerValue('FosterOpenLevel')
	local trainPageContainer
	if levelNow >= growLevel then
		trainPageContainer = UIContainerWidget:create()
		pv:addPage(trainPageContainer)
	end

	local awakeLevel = getGlobalIntegerValue('RoleAwakeOpenLevel')
	local awakePageContainer
	if levelNow >= awakeLevel then
		awakePageContainer = UIContainerWidget:create()
		pv:addPage(awakePageContainer)
	end

	local soulLevel = getGlobalIntegerValue('SoulOpenLevel')
	local soulPageContainer
	if levelNow >= soulLevel then
		soulPageContainer = UIContainerWidget:create()
		pv:addPage(soulPageContainer)
	end

	return pv
		, genInfoPageCreator(skillPageContainer)
		, genSkillPageCreator(skillPageContainer)
		, genTrainPageCreator(trainPageContainer)
		, genAwakePageCreator(awakePageContainer)
		, genSoulPageCreator(soulPageContainer)
end

local function genInfoFrameUpdater(parent)
	local typeIco = tolua.cast(parent:getChildByName('soldier_type_ico'),'UIImageView')
	local nameBg  = tolua.cast(parent:getChildByName('name_bg_ico'), 'UIImageView')
	local roleNameTx=tolua.cast(nameBg:getChildByName('role_name_tx'),'UITextArea')
	local fixIco  = tolua.cast(parent:getChildByName('dao_ico'),'UIImageView')
	local zhanTx  = tolua.cast(parent:getChildByName('zhan_num_tx'), 'UILabel')
	local soulBgIco = parent:getChildByName('soul_num_bg_ico')		--魂背景图标
	local soulTxIco = tolua.cast(parent:getChildByName('soul_txt_ico'), 'UIImageView')
	local soulNuTx  = tolua.cast(parent:getChildByName('soul_num_tx'), 'UILabel')

	local growthTx = tolua.cast(parent:getChildByName('growup_num_tx'), 'UILabel')
	local levelTx  = tolua.cast(parent:getChildByName('lv_num_tx'),'UILabel')
	local expBarBg = tolua.cast(parent:getChildByName('exp_bg_img'), 'UIImage')
	local expLoading=tolua.cast(parent:getChildByName('exp_img'),'UILoadingBar')
	local expTx    = tolua.cast(parent:getChildByName('exp_num_tx'), 'UILabel')

	-- 攻击武器图标
	local attackIco= tolua.cast(parent:getChildByName('attack_ico'), 'UIImageView')
	local attributes = {'attack', 'defense', 'magic_defense', 'soldier'}
	local attributesIco = {}
	local attributesTx  = {}
	for i=1,#attributes do
		local name = attributes[i] .. '_bg_ico'
		local one = parent:getChildByName(name)
		assert(one, 'must be there for bg_icoS')
		attributesIco[i] = one

		local name = attributes[i] .. '_num_tx'
		local one = tolua.cast(parent:getChildByName(name),'UILabel')
		assert(one, 'must be there for num_txS')
		attributesTx[i] = one
	end

	-- Spinning soul
	--m_pImgEffect = CCircleRotate::CreateToTarget(m_pImgSoulTxt,"uires/ui_2nd/com/panel/common/soul_bg_1.png", 360.0f, 3.0f);
	--m_pImgEffect->SetZOrder(3);
	--UpdateSceneId(GLOBALSCENEID_ROLEINFOMATIONPANEL);	
	return function(roleObj)
		print('time to update role info')
		local rObj = roleObj.role
		typeIco:setTexture(rObj:GetRoleSoldierIco())
		typeIco:setAnchorPoint(ccp(0,0))
		roleNameTx:setText(rObj:GetRoleName())
		roleNameTx:setColor(rObj:GetRoleNameColor())
		fixIco:setVisible(rObj:IsAssigned())
		zhanTx:setText(tostring(rObj:GetFightForce()))

		local quality = rObj:GetRoleQuality()
		if E_ROLE_QUALITY_BLUE == quality or 
			E_ROLE_QUALITY_PURPLE == quality then
			soulBgIco:setVisible(false)
		else
			soulBgIco:setVisible(true)
		end

		soulNuTx:setText(tostring(rObj:GetSoulLevel()))
		growthTx:setText(tostring(rObj:GetCurTraining()))
		levelTx:setText(tostring(rObj:GetRoleLevel()))
		local percent = rObj:GetExpPercent() * 100
		expLoading:setPercent(percent)
		expTx:setText(string.format('%.1f%%',percent))
		attackIco:setTexture( rObj:GetWeaponRes() )
		attackIco:setAnchorPoint(ccp(0,0))

		local attrValStr = rObj:GetAttrsStr()
		local attrValues = string.split(attrValStr,',')
		for i=1,#attributes do
			attributesTx[i]:setText(attrValues[i])
		end
	end
end

local roleInfoPanelNameString = 'role-info-panel-x11'
function genRoleInfoPanel(showType, subPage)
	if UiMan.isPanelPresent(roleInfoPanelNameString) then
		return
	end

	subPage = subPage or 0
	local sceneObj = SceneObjEx:createObj('panel/role_main_panel.json',roleInfoPanelNameString)
	local panel = sceneObj:getPanelObj()
	panel:setAdaptInfo('role_bg_img', 'mainframe_img')

	panel:registerInitHandler(
		function()
			panel:registerScriptTapHandler('close_btn', UiMan.genCloseHandler(sceneObj))
			local root = panel:GetRawPanel()
			panel:registerOnShowHandler(
				function()
					updateRoleMainPanel()
					print('role-main-panel on show')
				end
			)
			panel:registerOnHideHandler(
				function()
					--print('role-main-panel on hide')
					-- clean global
					subPageInfo = {}
				end
			)

			-- root
			local mainFrame = tolua.cast(root:getChildByName('mainframe_img'), 'UIImageView')
			local rootFrame = tolua.cast(root:getChildByName('role_bg_img'),'UIImageView')
			local rootTitle = tolua.cast(root:getChildByName('role_title_img'),'UIImageView')
			local decisionBtn = rootFrame:getChildByName('decision_btn')
			decisionBtn:registerScriptTapHandler(showDecisionPanel)

			local roleFrame = tolua.cast(root:getChildByName('role_left_bg_img'),'UIImageView')
			roleFrame:setWidgetZOrder(9)
			local rolePageView, subPages = setupRoleView(roleFrame)

			local infoViewUpdater = genInfoFrameUpdater(roleFrame)
			subPageInfo.mainPanelUpdater = infoViewUpdater		--register to updaters
			rolePageView:addScroll2PageEventScript(
				function(index)
					--print('index is now '..tostring(index))
					local roleID = subPages[index+1]:getActionTag()
					selectRoleID = roleID
					print('now you select ' .. tostring(roleID))
					currentPageIndex = index
					infoViewUpdater(roleObjects[currentPageIndex+1])		--Notification for view-update
					updateRoleMainPanel()
					CRoleMgr:GetInst():SetSelectRoleID(roleID)
				end
			)

			--
			local targetIndex = 0
			for i=1,#roleObjects do
				--print(roleObjects[i])
				if selectRoleID == roleObjects[i].id then
					targetIndex = i - 1
				else
				end
			end
			rolePageView:scrollToPage(targetIndex)
			local pageView, infoCreator, skillCreator, trainCreator, awakeCreator , soulCreator = setupDivisionView(mainFrame)
			local onTouchTitle = genTitleButtonsUpdater(rootTitle, pageView,
					{infoCreator, trainCreator, awakeCreator, soulCreator}
				)
			subPageInfo.skillPageCreator = skillCreator
			pageView:addScroll2PageEventScript(onTouchTitle)

			--First time
			UpdateSceneId(GLOBALSCENEID_ROLEINFOMATIONPANEL)
			if subPage >= 0 then
				pageView:scrollToPage(subPage)
			end
		end
	)
	UiMan.show(sceneObj, showType)
	shutdownHandler = UiMan.genCloseHandler(sceneObj, ELF_HIDE.HIDE_NORMAL)
end

local function switchSubPageOne(showSkill)
	if showSkill then
		if subPageInfo.skillPageCreator then
			subPageInfo.skillPageCreator()
		end
	end

	if subPageInfo.skillPage then
		subPageInfo.skillPage:setVisible(showSkill)
		if showSkill then
			subPageInfo.skillPage:UpdatePanel()
		end
	end

	if subPageInfo.infoPage then
		subPageInfo.infoPage:setVisible(not showSkill)
		if not showSkill then
			subPageInfo.infoPage:UpdateRoleInfoPanel()
		end
	end
end

function switchToSkillSub()
	switchSubPageOne(true)
end

function switchToInfoSub()
	switchSubPageOne(false)
end

--exports
function updateRoleExsoulPanel()
	if subPageInfo.soulPage then
		subPageInfo.soulPage:UpdatePanel()
	end
end

--exports to C++(Protocols, must comform)
function genRoleInfoPanelDirect()
	genRoleInfoPanel(ELF_SHOW.NORMAL)
end

--exports to C++(Like above)
function shutdownRoleInfoPanelDirect()
	if shutdownHandler then
		shutdownHandler()
		shutdownHandler = nil
	end
end

--exports to C++(Like above , like always)
function updateRoleInfoByID(id)
	if id == selectRoleID then
		updateRoleMainPanel()
	end
end

--exports
function runExSoulExpBar(beginExp , endExp , beginLv , endLv)
	if subPageInfo.soulPage then
		subPageInfo.soulPage:RunExpBar(beginExp, endExp, beginLv, endLv)
	end
end