SignIn = {}
local signCurrent
local signDay
local signRecords
local signConf = GameData:getArrayData('newsign.dat')

function SignIn.isActive()
return PlayerCoreData.IsSignInOKToday()
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
    end
    SignIn.UI()
    --showPromptMsg()
    --UserData:setSignInData(json.encode(signData))       -- 更新下signData数据
end
end

function SignIn.UI()
-- UI
local root
local calendarImg
local signBtn
local addSignBtn
-- 其他
local signData              -- 签到相关数据
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
    local beginTime = GetTimeByDate(signDay .. ' ' .. '00.00.00')
    local finishTime = beginTime + 2592000
	print(type(finishTime))
    if Time.now() > finishTime then
		local freeFlag = checkFree(sRecords,sCurrent)
	    if freeFlag then
	        mode = SIGN_MODE.MAKE_UP
	    end
	    return mode
    else
    	local a = bit:dleft(1,sCurrent)            -- 左移
    	print('==a==' .. a)
    	local b = bit:dand(a,sRecords)             -- 按位与
    	print('==b==' .. b)
    	if b == 0 then
        	mode = SIGN_MODE.NORMAL
        	print('==1==' .. mode)
    	end

    	local freeFlag = checkFree(sRecords,sCurrent)
    	print(freeFlag)
	    if b~=0 and freeFlag then
	        mode = SIGN_MODE.MAKE_UP
	        print('==2==' .. mode)
	    end
	    print('==3==' .. mode)
	    return mode
    end
end

-- 设置签到和补签按钮是否可点击
local function updateSignButton()
    signMode = checkSignMode()

    signBtn:setPressState(WidgetStateDisabled)
    signBtn:setTouchEnable(false)
    addSignBtn:setPressState(WidgetStateDisabled)
    addSignBtn:setTouchEnable(false)

    local btnStatus1 = bit:dand(SIGN_MODE.NORMAL, signMode)
    local btnStatus2 = bit:dand(SIGN_MODE.MAKE_UP, signMode)

    if btnStatus1 ~= 0 then
        signBtn:setPressState(WidgetStateNormal);
        signBtn:setTouchEnable(true);
    end

    if btnStatus2 ~= 0 then
        addSignBtn:setPressState(WidgetStateNormal);
        addSignBtn:setTouchEnable(true);
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
        for i = 1,30 do
            local a = bit:dleft(1, i - 1)               -- 左移
            local b = bit:dand(a,records)               -- 按位与
            lightUpAtDay(i,b~=0)
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
        local data = resData.data
        if data then
            -- Protocol parsing
            local cashDelta = tonumber(data.cash)
            local records = tonumber(data.records)

            -- Update
            signRecords = records

            -- Decrement yuanbao
            if cashDelta then
                PlayerCoreData.addCashDelta(cashDelta)
            end

            -- And the award is got right now
            promptSignAward = retrieveAwards(data)
            showPromptMsg()

            data.count = data.login_count
            UserData:setSignInData(json.encode(signData))       -- 更新下signData数据
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

-- 花费元宝进行补签
local function onClickMsgSureBtn()
    doRequestSignIn(1)
end

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

-- 点击补签
local function onClickSignInAffix()
    local currentDay = signCurrent

    repeat
        local freeFlag = checkFree(signRecords,currentDay)
        if freeFlag then
            if notEnoughCashAndPrompt() then
                break
            end

            local msg = string.format(getLocalString('5104'),10)
            GameController.showMessageBox(msg, MESSAGE_BOX_TYPE.OK_CANCEL, onClickMsgSureBtn)
            break
        end
        -- 上面一个break都不中, 只能说明“都签到了", 此刻不作提示, 而是刷新UI
        -- The truth is, we should never reach here.
        -- CMessageBox::GetInst()->Open(E_MB_OK, "All signed !");
        updateAll()
    until true
end

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

        local currDay  = bit:dand(bit:dleft(1,currentDay),signRecords)
        if currDay == 0 then
            -- 不是第一天
            print('not first day')
            doRequestSignIn(0)
            break
        end
        -- 上面一个break都不中, 只能说明“都签到了", 此刻不作提示, 而是刷新UI
        -- The truth is, we should never reach here.
        updateAll()
    until true
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
    
end

-- 显示panel
local function showPanel()
    local sign = SceneObjEx:createObj('panel/sign_in_panel.json', 'sign-in-lua')
    local panel = sign:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('sign_in_bg_img', 'sign_in_img')

    -- init
    panel:registerInitHandler(function ()
        root = panel:GetRawPanel()

        local signMainImg = tolua.cast(root:getChildByName('sign_main_img'),'UIImageView')
        signMainImg:setCascadeColorEnabled(true);
        signMainImg:setCascadeOpacityEnabled(true);

        local signTitleIco = tolua.cast(root:getChildByName('sign_in_title_ico'),'UIImageView')
        local closeBtn = tolua.cast(signTitleIco:getChildByName('close_btn'),'UIButton')
        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
        closeBtn:registerScriptTapHandler(function ()
            CUIManager:GetInstance():HideObject(sign, ELF_HIDE.SMART_HIDE)
        end)

        signBtn = tolua.cast(root:getChildByName('sign_in_btn'),'UITextButton')
        GameController.addButtonSound(signBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        signBtn:registerScriptTapHandler(onClickSignIn)

        addSignBtn = tolua.cast(root:getChildByName('add_sign_btn'),'UITextButton')
        GameController.addButtonSound(addSignBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        addSignBtn:registerScriptTapHandler(onClickSignInAffix)

        calendarImg = tolua.cast(signMainImg:getChildByName('calendar_img'),'UIImageView')
        calendarImg:setCascadeColorEnabled(false);
        calendarImg:setCascadeOpacityEnabled(true);

        local awardData = {}
        local index = 1
        local index_1 = 1
        for i = 1, #signConf do
            local award = signConf[i].Award1
            local tips = signConf[i].Tips
            awardData = UserData:getAward(award)
            if tonumber(signConf[i].Displayable) == 1 then
                    local photo = string.format('photo_%d_ico', index)
                    local photoIco = tolua.cast(calendarImg:getChildByName(photo), 'UIImageView')
                    local awardIco = tolua.cast(photoIco:getChildByName('award_ico'), 'UIImageView')
                    local awardNum = tolua.cast(photoIco:getChildByName('award_num_tx'), 'UILabel')
                    awardData = UserData:getAward(award)
                    awardIco:setTexture(awardData['icon'])
                    awardNum:setText(tostring(awardData['count']))
                    photoIco:registerScriptTapHandler(function()
                        local awardStr = award
                        UISvr:showTipsForAward(awardStr)
                        end)
                    if awardData.type == 'card' then
                        local roleCard = PlayerCoreData.getRoleCardById(awardData.id)
                        if roleCard then
                            if ROLE_QUALITY.SRED == roleCard:GetRoleQuality() then
                                photoIco:setTexture(roleCard:GetIconFrame())
                                photoIco:setAnchorPoint(ccp(0.5, 0.5))
                                local light = CUIEffect:create()
                                light:Show("yellow_light", 0)
                                light:setScale(0.8)
                                light:setPosition( ccp(0, 0))
                                light:setAnchorPoint(ccp(0.5, 0.5))
                                photoIco:getContainerNode():addChild(light)
                                light:setZOrder(100)
                            end
                        end
                    end
                    index = index + 1
            elseif tonumber(signConf[i].Displayable) == 2 then
                local box = string.format('box_%d_ico', index_1)
                local boxIco = tolua.cast(calendarImg:getChildByName(box), 'UIImageView')
                boxIco:registerScriptTapHandler(function()
                    local awardStr = tips
                    UISvr:showTipsForAward(awardStr)
                end)
                index_1 = index_1 + 1
            end
        end

        updateAll()
    end)

    -- onShow
    panel:registerOnShowHandler(function ()  
    end)

    -- onHide
    panel:registerOnHideHandler(function ()
        UserData:setSignInData(json.encode(signData))       -- 关闭界面的时候更新下signData数据
    end)

    -- Show now
    CUIManager:GetInstance():ShowObject(sign, ELF_SHOW.SMART)
end


local level = PlayerCoreData.getPlayerLevel();
local activitiesConf = GameData:getMapData('activities.dat')
local openLevel = activitiesConf['signin'].OpenLevel
if  tonumber(level) < tonumber(openLevel) then      -- 如果等级不够
    local msg = string.format(getLocalString('E_STR_TRAIN_LIMIT'),tonumber(openLevel))
    GameController.showMessageBox(msg,MESSAGE_BOX_TYPE.OK)
else
    showPanel()
end
end

local function doRequestClaimAward()
local pJson = {
    times = awardTimes
}
Message.sendPost('get_new_sign','activity','{}',onClaimAwardCallbacks)
end

-- 从这里开始执行SignIn.enter()
function SignIn.enter()
doRequestClaimAward()
end
