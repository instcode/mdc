require 'ceremony/launchers/runroleinfo' 

local tacticsConf = GameData:getArrayData('tactics.dat')

-- 获取数字图片资源
local function getResPath(num)
    local res_path = string.format('uires/ui_2nd/com/panel/vip/%d.png', num)
    return res_path
end

-- 设置兵法信息
local function artcellInit(soldierLv, people)
    local cellPanel = UIPanel:create()
    cellPanel:setSize(CCSizeMake(430 , 280))
    local slipNum = 1
    for i = 1, #tacticsConf do
        if tonumber(tacticsConf[i].SoldierLv) == soldierLv then
            local artcell = createWidgetByName('panel/art_cell.json')
            local infoTx = tolua.cast(artcell:getChildByName('info_tx'), 'UILabel')
            infoTx:setColor(COLOR_TYPE.ORANGE)

            local peopleIco = tolua.cast(artcell:getChildByName('lv_ico'), 'UIImageView')
            peopleIco:setTexture(getResPath(tonumber(tacticsConf[i].People)))

            local attrIco = tolua.cast(artcell:getChildByName('attr_ico'), 'UIImageView')
            if tacticsConf[i].Attr == 'attack' then
                attrIco:setTexture('uires/ui_2nd/com/panel/common/gongjie_icon.png')
            else
                attrIco:setTexture(Role.GetRoleAttrIco(tacticsConf[i].Attr))
            end 
            attrIco:setAnchorPoint(ccp(0,0.5))

            local addAttrTx = tolua.cast(artcell:getChildByName('attr_add_tx'), 'UILabel')
            local strBuff = '+' .. tacticsConf[i].AttrAdd
            local activationTx = tolua.cast(artcell:getChildByName('activation_tx'), 'UILabel')        
            addAttrTx:setText(strBuff)

            -- 此处判断是否激活
            if people >= tonumber(tacticsConf[i].People) then
                activationTx:setText(getLocalString('E_STR_ACTIVATION'))
                activationTx:setColor(COLOR_TYPE.GREEN)
                addAttrTx:setColor(COLOR_TYPE.GREEN)
            else
                activationTx:setText(getLocalString('E_STR_INACTIVE'))
                activationTx:setColor(COLOR_TYPE.RED)
                addAttrTx:setColor(COLOR_TYPE.RED)
            end  
            cellPanel:addChild(artcell)
            artcell:setPosition(ccp(0, 280 - 70 * slipNum))
            slipNum = slipNum + 1
        end
    end
    return cellPanel
end
 
-- 界面信息设置   
local function SetInfo(infoBgImg)
    local pvInfo
    if nil == pvInfo then
        pvInfo = UIPageView:create()
        pvInfo:setTouchEnable(true)
        pvInfo:setWidgetZOrder(1)
        pvInfo:setPosition(ccp(68,96))
        pvInfo:setSize(CCSizeMake(430 , 280))
        pvInfo:setAnchorPoint(ccp(0,0))
        pvInfo:removeAllChildrenAndCleanUp(true)
        infoBgImg:addChild(pvInfo)
    end

    local rolesTab = {}
    local rolesIdTab = json.decode(PlayerCoreData.getAllRolesId())
    table.foreach(rolesIdTab , function (_ , v)
    local obj = Role:findById(tonumber(v))
    if obj then
        table.insert(rolesTab , obj)
    end
    end)

    local arrPeople = {}
    local arrlvMax = {}
    local curPage = 0
    for i = 1, 4 do
        arrPeople[i] = 0
        arrlvMax[i] = (i - 1) * 4 
    end

    for i = 1, 4 do
        for j = 1, #rolesTab do
            if rolesTab[j]:getSoldier().level > i then
                arrPeople[i] = arrPeople[i] + 1
            end   
        end
    end
    local index = 0
    for i = 1, 4 do    
        for j = 1, #tacticsConf do
            if tonumber(tacticsConf[j].SoldierLv) == i + 1 then
                index = index + 1              
            end      
        end
        arrlvMax[i] = index 
    end   
    
    for i = 1, 4 do
        if (arrPeople[i] >= tonumber(tacticsConf[arrlvMax[i]].People)) then  
            curPage = curPage + 1
        end
    end

    pvInfo:removeAllChildrenAndCleanUp(true)

    local sumPage = tonumber(tacticsConf[#tacticsConf].SoldierLv) - 1
    local subPage = {}

    for i = 1, sumPage do
        local pPage = UIContainerWidget:create()
        local artPanel = artcellInit(i + 1, arrPeople[i])
        pPage:setWidgetTag(i)
        pPage:setActionTag(i)
        artPanel:setPosition(ccp(0, 0))
        pPage:addChild(artPanel)
        pvInfo:addPage(pPage)
        subPage[i] = pPage
    end

    local expBgImg = tolua.cast(infoBgImg:getChildByName('exp_bg_ico'), 'UIImageView')
    local percentTx = tolua.cast(expBgImg:getChildByName('percent_tx'), 'UILabel')  
    local expBar = tolua.cast(expBgImg:getChildByName('exp_bar'), 'UILoadingBar')

    local function scorllPvFn(page)
        local id =subPage[page+1]:getWidgetTag()
        for i = 1, #tacticsConf do
            if tonumber(tacticsConf[i].SoldierLv) == id + 1 then
                local finishTx = tolua.cast(infoBgImg:getChildByName('finish_tx'), 'UILabel')
                finishTx:setText(GetTextForCfg(tacticsConf[i].Desc))
                finishTx:setColor(COLOR_TYPE.ORANGE)
                break
            end
        end

        local lvMax = 0
        for i = 1, #tacticsConf do
            if tonumber(tacticsConf[i].SoldierLv) <= id + 1 then
                lvMax = lvMax + 1
            end        
        end
        local rolesTab = {}
        local rolesIdTab = json.decode(PlayerCoreData.getAllRolesId())
        table.foreach(rolesIdTab , function (_ , v)
        local obj = Role:findById(tonumber(v))
        if obj then
            table.insert(rolesTab , obj)
        end
        end)

        local curPeople = 0
        for i = 1, #rolesTab do
            if rolesTab[i]:getSoldier().level >= id + 1 then
                curPeople = curPeople + 1
            end
        end
        if curPeople > tonumber(tacticsConf[lvMax].People) then
            curPeople = tonumber(tacticsConf[lvMax].People)
        end
        local str = curPeople .. '/' .. tacticsConf[lvMax].People
        percentTx:setText(str)
        local percent = curPeople / tonumber(tacticsConf[lvMax].People) * 100
        expBar:setPercent(percent)
    end

    pvInfo:addScroll2PageEventScript(scorllPvFn)
    
    if curPage >= 4 then
        curPage = 3
    end
    pvInfo:scrollToPage(curPage)

    local leftBtn = tolua.cast(infoBgImg:getChildByName('left_btn'), 'UIButton')
    leftBtn:registerScriptTapHandler(
        function()
            pvInfo:scrollToLeft()    
        end)

    local rightBtn = tolua.cast(infoBgImg:getChildByName('right_btn'), 'UIButton')
    rightBtn:registerScriptTapHandler(
        function()
             pvInfo:scrollToRight()
        end)
    return subPage
end

-- 界面设置
local function ArtOfWarInit(panel, artofwar)
	return function()
		local root = panel:GetRawPanel()
		local artBgImg = tolua.cast(root:getChildByName('art_zhegai_img'), 'UIImageView')
		local artMainImg = tolua.cast(artBgImg:getChildByName('art_bg_img'), 'UIImageView')
		local artTitleImg = tolua.cast(artMainImg:getChildByName('title_ico'), 'UIImageView')

		local closeBtn = tolua.cast(artTitleImg:getChildByName("close_btn"), 'UIButton')
        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
        closeBtn:registerScriptTapHandler(function()
            CUIManager:GetInstance():HideObject(artofwar, ELF_HIDE.ZOOM_OUT_FADE_OUT)
        end)

        local artInfoImg = tolua.cast(artMainImg:getChildByName('art_img'), 'UIImageView')
        SetInfo(artInfoImg)

        local gotoTransferBtn = tolua.cast(artInfoImg:getChildByName('know_btn'), 'UITextButton')
        GameController.addButtonSound(gotoTransferBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        gotoTransferBtn:registerScriptTapHandler(function()
            local curLv = PlayerCoreData.getPlayerLevel()
            local limitLv = getGlobalIntegerValue('TransferLevelLimit')
            if curLv < limitLv then
                local str = string.format(getLocalString('E_STR_GO_OPEN') , limitLv)
                GameController.showPrompts(str, COLOR_TYPE.RED)
            else
                CloseAllPanels()
                genRoleInfoPanelDirect()
            end
        end)
	end
end

function genArtOfWarPanel()
    local artofwar = SceneObjEx:createObj('panel/art_panel.json', 'art-of-war-lua')

    local panel = artofwar:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('art_zhegai_img', 'art_bg_img')

    local artofwarInit = ArtOfWarInit(panel, artofwar)

	panel:registerInitHandler(function()
		artofwarInit()
	end)
    	
    panel:registerOnShowHandler(function()
    end)

    panel:registerOnHideHandler(function()
    end)
    -- Show now
    CUIManager:GetInstance():ShowObject(artofwar, ELF_SHOW.ZOOM_IN)
end