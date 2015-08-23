New_SignIn = {
    canGet
}

function New_SignIn.enter(stype)
    -- UI
    local new_sign
    local panel
    local root
    local signMainImg
    local calendarImg
    local closeBtn
    local helpBtn
    local getAwardBtn
    local signBtn
    local addSignBtn
    local calendarImg

    local signCurrent
    local signDay
    local signRecords
    local signVipGot
    local signConf = GameData:getArrayData('newsign.dat')
    -- 其他
    local signMode
    local msgArr = {}
    local isSupplement = 0;     -- 是否是补签
    -- 常量
    local MAXSIGNDAY = 30
    local ROW = 5
    local COLUMN = 7
    local STARTX = 18
    local STARTY = 32
    local C_WIDTH = 500
    local C_HEIGHT = 335
    local TAG_SIGN_START = 400
    local HORIZONTAL_SPAN = C_WIDTH / COLUMN
    local VERTICAL_SPAN = C_HEIGHT/ ROW
    local QUANIMG = 'uires/ui_2nd/com/panel/signin/quan.png'
    local RES_GOLD_ICON_ITEM = 'uires/ui_2nd/image/item/gold_icon.png'
    local RES_HONOR_ICON_ITEM = 'uires/ui_2nd/image/item/honor_icon.png'
    local RES_CASH_ICON_ITEM = 'uires/ui_2nd/image/item/cash_icon.png'
    local dayTab={}
    local light = {} 
    local photoIco = {}
    local awardIco = {}
    ------------------------------------------------
    -- functions
    ------------------------------------------------

    function split(str, pat)
       local t = {}  -- NOTE: use {n = 0} in Lua-5.0
       local fpat = "(.-)" .. pat
       local last_end = 1
       local s, e, cap = str:find(fpat, 1)
       while s do
          if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
          end
          last_end = e+1
          s, e, cap = str:find(fpat, last_end)
       end
       if last_end <= #str then
          cap = str:sub(last_end)
          table.insert(t, cap)
       end
       return t
    end

    -- 日期转秒"2014-06-06 00:00:00"
    function GetTimeByDate(r)
        local a = split(r, " ")
        local b = split(a[1], "-")
        local c = split(a[2], ":")
        local t = os.time({year=b[1],month=b[2],day=b[3], hour=c[1], min=c[2], sec=c[3]})

        return t
    end

    -- 签到帮助界面
    function New_SignIn_Help()
        signin_help = SceneObjEx:createObj('panel/new_sign_in_help_panel.json', 'new-sign-in-help-lua')
        local panel = signin_help:getPanelObj()
        panel:setAdaptInfo('sign_bg_img', 'sign_img')

        panel:registerInitHandler(function()
            local root = panel:GetRawPanel()
            local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
            local knownBtn = tolua.cast(root:getChildByName('know_btn'), 'UITextButton')
            local background = tolua.cast(root:getChildByName('sign_bg_img'), 'UIImageView')
            local helpImg = tolua.cast(background:getChildByName('sign_img'), 'UIImageView')

            local infoTx1 = tolua.cast(helpImg:getChildByName('info_1_tx'), 'UILabel')
            infoTx1:setText(getLocalStringValue('HELP_SIGN_1'))
            local infoTx2 = tolua.cast(helpImg:getChildByName('info_2_tx'), 'UILabel')
            infoTx2:setText(getLocalStringValue('HELP_SIGN_2'))
            infoTx1:setPreferredSize(530,1)
            infoTx2:setPreferredSize(530,1)
            
            closeBtn:registerScriptTapHandler(function()
                 CUIManager:GetInstance():HideObject(signin_help, ELF_HIDE.SMART_HIDE)
            end)
            knownBtn:registerScriptTapHandler(function()
                 CUIManager:GetInstance():HideObject(signin_help, ELF_HIDE.SMART_HIDE)
            end)
            background:registerScriptTapHandler(function()
                 CUIManager:GetInstance():HideObject(signin_help, ELF_HIDE.SMART_HIDE)
            end)

            GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
            GameController.addButtonSound(knownBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
        end)

        CUIManager:GetInstance():ShowObject(signin_help, ELF_SHOW.ZOOM_IN)
        
    end

    -- 系统奖励信息放入数组中
    local function appendMsg(msg)
        table.insert(msgArr,msg)
    end

    -- 清空消息数组
    local function clearPromptMsg()
        msgArr = {}
    end

    -- 显示奖励信息(多条)
    local function showPromptMsg()
        GameController.showPrompts(msgArr)
        clearPromptMsg()
    end

    -- 获取奖励信息
    local function gotMaterialMsg(awd)
        local award = UserData:getAward(awd)
        local awardname = award.name .. ' X' .. award.count
        local msgText = string.format(getLocalString('E_STR_GAIN_ANYTHING'),awardname)
        appendMsg(msgText)
    end

    local function checkFree(records,current)
        local exists = false;
        for i = 0, current do
            local operate = bit:dand(bit:dleft(1,i),records)
            if operate == 0 then
                exists = true
    			break
            end
        end
        return exists
    end

    -- 判断当前是否可以签到或者补签
    local function checkSignMode()
        local mode = SIGN_MODE.NONE
        local sCurrent = signCurrent
        local sRecords = signRecords

    	local a = bit:dleft(1,sCurrent)            -- 左移
    	local b = bit:dand(a,sRecords)             -- 按位与
        print("signVipGot == " .. signVipGot)
    	if b == 0 then
        	mode = SIGN_MODE.NORMAL
    	end

    	local freeFlag = checkFree(sRecords,sCurrent)
        if b~=0 and freeFlag then
            mode = SIGN_MODE.MAKE_UP
        end

        return mode
    end

    local function isSignIn()
        local mode = false
        local sCurrent = signCurrent
        local sRecords = signRecords

        local a = bit:dleft(1,sCurrent)            -- 左移
        local b = bit:dand(a,sRecords)             -- 按位与
        if b == 0 then
            mode = true
        else
            mode = false
        end
        return mode
    end

    -- 设置签到和补签按钮是否可点击
    local function updateSignButton()
        signMode = checkSignMode()

        signBtn:setPressState(WidgetStateDisabled)
        signBtn:setTouchEnable(false)

        local btnStatus1 = bit:dand(SIGN_MODE.NORMAL, signMode)

        if btnStatus1 ~= 0 then
            signBtn:setPressState(WidgetStateNormal)
            signBtn:setText(getLocalString('E_STR_TODAY_SIGN'))
            signBtn:setTouchEnable(true);
        end
    end

    -- 设置签到和补签按钮是否可点击
    local function getSignStatus()
        signMode = checkSignMode()

        local btnStatus1 = bit:dand(SIGN_MODE.NORMAL, signMode)

        if btnStatus1 ~= 0 then
            return true
        else
            return false
        end
    end

    -- 返回每个勾的位置
    local function getPositionFor(day)
        local r = (ROW-1) - ((day-1) / COLUMN)
        local c = (day-1) % COLUMN
        local x = STARTX + (math.floor(c) + 0.5) * HORIZONTAL_SPAN
        local y = STARTY + (math.ceil(r) + 0.5) * VERTICAL_SPAN
        return ccp(x,y)
    end

    -- 打钩
    local function lightUpAtDay(day,flag)
        local pos = getPositionFor(day);
        local check = calendarImg:getChildByTag(TAG_SIGN_START+day)
        if flag then
            table.insert(dayTab, day)
            if not check then
                local vi = UIImageView:create()
                vi:setTexture(QUANIMG)
                vi:setTouchEnable(true)
                vi:setActionTag(TAG_SIGN_START)
                check = vi
                vi:setAnchorPoint(ccp(0.5,0.5))
                vi:setPosition(pos)
                vi:setScale(0.8)
                calendarImg:addChild(vi)
                vi:setWidgetZOrder(100)
            end
        end
        if check then
            check:setVisible(flag)
        end
    end

    -- 跟新签到的情况
    local function updateCalendar()
        local records = signRecords
		print('rscords type = ' .. type(records))
        for i = 1,30 do
            local a = bit:dleft(1, i - 1)               -- 左移
            local b = bit:dand(a,records)               -- 按位与
            lightUpAtDay(i,b~=0)
        end
        for i=1, #(dayTab) do  
            photoIco[dayTab[i]]:setGray()
            awardIco[dayTab[i]]:setGray() 
            if light[dayTab[i]] ~= nil then
                light[dayTab[i]]:setVisible(false)
            end
        end 
    end

    -- 更新界面
    local function updateAll()
        updateCalendar()                                    -- 更新签到的情况
        updateSignButton()
    end

    -- 加钱，加元宝，material放到背包里
    local function retrieveAwards(data)
        local gotAward = false
        clearPromptMsg()
        local msgText = getLocalString('5110')

        local awards = data.awards
        if awards then
            for k,v in pairs(awards) do
                local vStr = v[1] .. '.' .. v[2] .. ':' .. v[3]             -- 改成类似user.cash:10的形式
                gotMaterialMsg(vStr)
            end
            UserData.parseAwardJson(json.encode(awards))
        end

        return gotAward
    end

    local function onSignCallbacks(jsonData)
        local promptSignAward = false
        print(jsonData)
        local resData = json.decode(jsonData)
        local code = tonumber(resData.code)

        if code == 0 then
            New_SignIn.canGet = false
            local data = resData.data
            if data then
                -- Protocol parsing
                local cashDelta = tonumber(data.cash)
                local records = tonumber(data.records)
                signVipGot = tonumber(data.vip_got)
                -- Update
                signRecords = records

                -- Decrement yuanbao
                if cashDelta then
                    PlayerCoreData.addCashDelta(cashDelta)
                end

                -- And the award is got right now
                promptSignAward = retrieveAwards(data)
                showPromptMsg()
            end

            if root then
                updateAll()
            end

            local code = resData.code
            if code ~= 0 then
                -- 说明签到失败
                clearPromptMsg()
            end

            if promptSignAward then
                showPromptMsg()
            end
        end
    end

    local function onVipgotCallbacks(jsonData)
        local promptSignAward = false
        print(jsonData)
        local resData = json.decode(jsonData)
        local code = tonumber(resData.code)

        if code == 0 then
            local data = resData.data
            if data then

                signVipGot = tonumber(data.vip_got)

                promptSignAward = retrieveAwards(data)
                showPromptMsg()
            end

            if root then
                updateAll()
            end

            local code = resData.code
            if code ~= 0 then
                -- 说明签到失败
                clearPromptMsg()
            end

            if promptSignAward then
                showPromptMsg()
            end
        end
    end

    -- 向服务器发送签到的请求
    local function doRequestSignIn(cashSpent)
        isSupplement = cashSpent
        local pJson = {
            cash = cashSpent
        }
        Message.sendPost('new_sign','activity',json.encode(pJson),onSignCallbacks)
    end

    local function doRequestVipgot()
        Message.sendPost('new_sign_reward', 'activity', '{}', onVipgotCallbacks)
    end

    -- -- 花费元宝进行补签
    -- local function onClickMsgSureBtn()
    --     doRequestSignIn(1)
    -- end

    --  如果金币不足 提示花费%d元宝补签，当前元宝不足
    local function notEnoughCashAndPrompt()
        local currentCash = PlayerCoreData.getCashValue()
        local cashNeed = tonumber(GameData:getGlobalValue('NewSignOnceCash'))
        local notEnough = currentCash < cashNeed or false
        if notEnough then
            local strbuff = string.format(getLocalString('E_STR_REPAIR_SIGNIG'), cashNeed)
            GameController.showMessageBox(strbuff, MESSAGE_BOX_TYPE.OK)
        end
        return notEnough
    end

    -- -- 点击补签
    -- local function onClickSignInAffix()
    --     local currentDay = signCurrent

    --     repeat
    --         local freeFlag = checkFree(signRecords,currentDay)
    --         if freeFlag then
    --             if notEnoughCashAndPrompt() then
    --                 break
    --             end

    --             local msg = string.format(getLocalString('5104'),10)
    --             GameController.showMessageBox(msg, MESSAGE_BOX_TYPE.OK_CANCEL, onClickMsgSureBtn)
    --             break
    --         end
    --         -- 上面一个break都不中, 只能说明“都签到了", 此刻不作提示, 而是刷新UI
    --         -- The truth is, we should never reach here.
    --         -- CMessageBox::GetInst()->Open(E_MB_OK, "All signed !");
    --         updateAll()
    --     until true
    -- end

    -- 点击签到
    local function onClickSignIn()
        local currentDay = signCurrent
        repeat
            if currentDay == 0 then
                -- 第一天
                print('first day')
                doRequestSignIn(0)
                break
            end

            if isSignIn() then
                local currDay  = bit:dand(bit:dleft(1,currentDay),signRecords)
                if currDay == 0 then
                -- 不是第一天
                print('not first day')
                doRequestSignIn(0)
                break
                end
            else
                local vipGot = bit:dand(bit:dleft(1,currentDay),signVipGot)
                if vipGot == 0 then
                print('vip got')
                doRequestVipgot()
                break
                end
            end



            -- 上面一个break都不中, 只能说明“都签到了", 此刻不作提示, 而是刷新UI
            -- The truth is, we should never reach here.
            updateAll()
        until true
    end

    local function onShow()
        -- print('here on-show for sign-in')
    end

    local function onHide()

    end


    local function getAwardConfDataByKey( key )
    for k , v in pairs (signConf)   do
        if(v['Id'] == key) then
            return v
        end
    end
    return nil
    end

    local function init()
        root = panel:GetRawPanel()

        signMainImg = tolua.cast(root:getChildByName('sign_main_img'),'UIImageView')
        signMainImg:setCascadeColorEnabled(true);
        signMainImg:setCascadeOpacityEnabled(true);

        local signTitleIco = tolua.cast(root:getChildByName('sign_in_title_ico'),'UIImageView')
        closeBtn = tolua.cast(signTitleIco:getChildByName('close_btn'),'UIButton')
        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
        closeBtn:registerScriptTapHandler(function()
            CUIManager:GetInstance():HideObject(new_sign, ELF_HIDE.SMART_HIDE)
        end)

        helpBtn = tolua.cast(signTitleIco:getChildByName('help_btn'),'UIButton')
        GameController.addButtonSound(helpBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        helpBtn:registerScriptTapHandler(New_SignIn_Help)

        signBtn = tolua.cast(root:getChildByName('sign_in_btn'),'UITextButton')
        GameController.addButtonSound(signBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        signBtn:registerScriptTapHandler(onClickSignIn)

        addSignBtn = tolua.cast(root:getChildByName('add_sign_btn'),'UITextButton')
        GameController.addButtonSound(addSignBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        -- addSignBtn:registerScriptTapHandler(onClickSignInAffix)
        addSignBtn:setVisible(false)
        
        calendarImg = tolua.cast(signMainImg:getChildByName('calendar_img'),'UIImageView')
        calendarImg:setCascadeColorEnabled(false);
        calendarImg:setCascadeOpacityEnabled(true);

        local awardData = {}
        local boxawardData = {}
        local index = 1   
        for i = 1, #signConf do
            local award = signConf[i].Award1
            local tips = signConf[i].Tips
            local eff = signConf[i].Eff 
            awardData = UserData:getAward(award)
            if tonumber(signConf[i].Displayable) == 1 then
                    local photo = string.format('photo_%d_ico', index)
                    photoIco[index] = tolua.cast(calendarImg:getChildByName(photo), 'UIImageView')
                    awardIco[index] = tolua.cast(photoIco[index]:getChildByName('award_ico'), 'UIImageView')
                    local awardNum = tolua.cast(photoIco[index]:getChildByName('award_num_tx'), 'UILabel')
                    local vipBgIco = tolua.cast(photoIco[index]:getChildByName('vip_bg_ico'), 'UIImageView')
                    local vipLvTx = tolua.cast(vipBgIco:getChildByName('vip_lv_tx'), 'UILabel')
                    if tonumber(signConf[i].VipLevel) > 0 then 
                        local strbuff = string.format(getLocalString('E_STR_NEW_SIGN_VIP_DOUBLE'), signConf[i].VipLevel)
                        vipLvTx:setText(strbuff)
                        vipBgIco:setVisible(true)
                    else
                        vipBgIco:setVisible(false)
                    end
                    awardData = UserData:getAward(award)
                    awardIco[index]:setTexture(awardData['icon'])         
                    awardNum:setText(tostring(awardData['count']))
                    local color = awardData['color']
                    if color.r == COLOR_TYPE.RED.r and color.g == COLOR_TYPE.RED.g and color.b == COLOR_TYPE.RED.b then
                        photoIco[index]:setTexture('uires/ui_2nd/com/panel/common/frame_red.png')
                    elseif color.r == COLOR_TYPE.WHITE.r and color.g == COLOR_TYPE.WHITE.g and color.b == COLOR_TYPE.WHITE.b then
                        photoIco[index]:setTexture('uires/ui_2nd/com/panel/common/frame.png')
                    elseif color.r == COLOR_TYPE.PURPLE.r and color.g == COLOR_TYPE.PURPLE.g and color.b == COLOR_TYPE.PURPLE.b then
                        photoIco[index]:setTexture('uires/ui_2nd/com/panel/common/frame_purple.png')
                    elseif color.r == COLOR_TYPE.ORANGE.r and color.g == COLOR_TYPE.ORANGE.g and color.b == COLOR_TYPE.ORANGE.b then
                        photoIco[index]:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
                    elseif color.r == COLOR_TYPE.BLUE.r and color.g == COLOR_TYPE.BLUE.g and color.b == COLOR_TYPE.BLUE.b then
                        photoIco[index]:setTexture('uires/ui_2nd/com/panel/common/frame.png')
                    end
                    if awardData.type == 'card' then
                        local roleCard = PlayerCoreData.getRoleCardById(awardData.id)
                        if roleCard then
                            if ROLE_QUALITY.SRED == roleCard:GetRoleQuality() then
                                photoIco[index]:setTexture(roleCard:GetIconFrame())
                            end
                        end
                    end
                    photoIco[index]:registerScriptTapHandler(function()
                        local awardStr = award
                        UISvr:showTipsForAward(awardStr)
                        end)     
            elseif tonumber(signConf[i].Displayable) == 2 then
                boxawardData = UserData:getAward(tips)
                local photo = string.format('photo_%d_ico', index)
                photoIco[index] = tolua.cast(calendarImg:getChildByName(photo), 'UIImageView')
                awardIco[index] = tolua.cast(photoIco[index]:getChildByName('award_ico'), 'UIImageView')
                local awardNum = tolua.cast(photoIco[index]:getChildByName('award_num_tx'), 'UILabel')
                local vipBgIco = tolua.cast(photoIco[index]:getChildByName('vip_bg_ico'), 'UIImageView')
                local vipLvTx = tolua.cast(vipBgIco:getChildByName('vip_lv_tx'), 'UILabel')
                if tonumber(signConf[i].VipLevel) > 0 then 
                    local strbuff = string.format(getLocalString('E_STR_NEW_SIGN_VIP_DOUBLE'), signConf[i].VipLevel)
                    vipLvTx:setText(strbuff)
                    vipBgIco:setVisible(true)
                else
                    vipBgIco:setVisible(false)
                end
                awardIco[index]:setTexture(boxawardData['icon'])
                awardNum:setText(tostring(boxawardData['count']))
                local color = boxawardData['color']
                if color.r == COLOR_TYPE.RED.r and color.g == COLOR_TYPE.RED.g and color.b == COLOR_TYPE.RED.b then
                    photoIco[index]:setTexture('uires/ui_2nd/com/panel/common/frame_red.png')
                elseif color.r == COLOR_TYPE.WHITE.r and color.g == COLOR_TYPE.WHITE.g and color.b == COLOR_TYPE.WHITE.b then
                    photoIco[index]:setTexture('uires/ui_2nd/com/panel/common/frame.png')
                elseif color.r == COLOR_TYPE.PURPLE.r and color.g == COLOR_TYPE.PURPLE.g and color.b == COLOR_TYPE.PURPLE.b then
                    photoIco[index]:setTexture('uires/ui_2nd/com/panel/common/frame_purple.png')
                elseif color.r == COLOR_TYPE.ORANGE.r and color.g == COLOR_TYPE.ORANGE.g and color.b == COLOR_TYPE.ORANGE.b then
                    photoIco[index]:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
                elseif color.r == COLOR_TYPE.BLUE.r and color.g == COLOR_TYPE.BLUE.g and color.b == COLOR_TYPE.BLUE.b then
                    photoIco[index]:setTexture('uires/ui_2nd/com/panel/common/frame.png')
                end
                photoIco[index]:registerScriptTapHandler(function()
                    local awardStr = tips
                    UISvr:showTipsForAward(awardStr)
                end) 
            end
           if tonumber(eff) == 1 then
            photoIco[index]:setAnchorPoint(ccp(0.5, 0.5))
            light[index] = CUIEffect:create()  
            light[index]:Show("yellow_light", 0)
            light[index]:setScale(0.8)
            light[index]:setPosition( ccp(0, 0))
            light[index]:setAnchorPoint(ccp(0.5, 0.5))
            photoIco[index]:getContainerNode():addChild(light[index])
            light[index]:setZOrder(100)
            end 
            index = index + 1
        end
        updateAll()
    end
    -- 显示panel
    local function showPanel()
        new_sign = SceneObjEx:createObj('panel/new_sign_in_panel.json', 'new-sign-in-lua')
        panel = new_sign:getPanelObj()        --# This is a BasePanelEx object
        panel:setAdaptInfo('sign_in_bg_img', 'sign_in_img')

        panel:registerInitHandler(init)

        panel:registerOnShowHandler(onShow)

        panel:registerOnHideHandler(onHide)

        -- Show now
        CUIManager:GetInstance():ShowObject(new_sign, ELF_SHOW.SMART)
    end

    local function onClaimAwardCallbacks(jsonData)
    print(jsonData)
    local resData = json.decode(jsonData)
    local code = tonumber(resData.code)

    	if code == 0 then
    		local data = resData.data
    		if data then
    			printall(data)
    			local newsign = data.new_sign
    			signCurrent = tonumber(newsign.current)
    			signDay = newsign.day
    			signRecords = tonumber(newsign.records)
                signVipGot = tonumber(newsign.vip_got)
    		end
    		showPanel()
    		--showPromptMsg()
    	end
    end

    local function doRequestClaimAward()
    local pJson = {
        times = awardTimes
    }
    Message.sendPost('get_new_sign','activity','{}',onClaimAwardCallbacks)
    end

    -- 从这里开始执行SignIn.enter()
    local function getNewSign()
    	doRequestClaimAward()
    end

    if stype == 1 then
        if New_SignIn.canGet == nil then
            local level = PlayerCoreData.getPlayerLevel();
            local openLevel = GameData:getGlobalValue( "AllTargetOpenLevel" )
            if  tonumber(level) < tonumber(openLevel) then      -- 如果等级不够
                return
            end
            Message.sendPost('get_new_sign','activity','{}',function (jsonData)
                local resData = json.decode(jsonData)
                local code = tonumber(resData.code)
                if code == 0 then
                    local data = resData.data
                    if data then
                        printall(data)
                        local newsign = data.new_sign
                        signCurrent = tonumber(newsign.current)
                        signDay = newsign.day
                        signRecords = tonumber(newsign.records)
                        signVipGot = tonumber(newsign.vip_got)
                    end
                    New_SignIn.canGet = getSignStatus()
                    setSignVisible(New_SignIn.canGet)
                end
            end)
        else
            setSignVisible(New_SignIn.canGet)
        end
    else
        local level = PlayerCoreData.getPlayerLevel();
        local openLevel = GameData:getGlobalValue( "AllTargetOpenLevel" )
        if  tonumber(level) < tonumber(openLevel) then      -- 如果等级不够
            local msg = string.format(getLocalString('E_STR_TRAIN_LIMIT'),tonumber(openLevel))
            GameController.showMessageBox(msg,MESSAGE_BOX_TYPE.OK)
        else
            getNewSign()
        end
    end
end

