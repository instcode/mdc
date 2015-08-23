
-- AVbody follows this
-- coded by eminem
-- June. 2o14

local function getActRes()
    return {
        -- signin = {
        --     title = 'uires/ui_2nd/com/panel/activity/sign_in_txt.png',
        --     icon = 'uires/ui_2nd/com/panel/activity/sign_in_icon.png',
        --     enter = New_SignIn.enter
        -- },
        protection = {
            title = 'uires/ui_2nd/com/panel/activity/protect_vip_txt.png',
            icon = 'uires/ui_2nd/com/panel/activity/protect_vip_icon.png',
            status = Protection.isActive(),
            enter = Protection.enter
        },
        -- card = {
        --     title = 'uires/ui_2nd/com/panel/activity/card_master_txt.png',
        --     icon = 'uires/ui_2nd/com/panel/activity/card_master_icon.png',
        --     status = CardMaster.isActive(),
        --     enter = CardMaster.enter
        -- },
        luckycard = {
            title = 'uires/ui_2nd/com/panel/activity/lucky_card_txt.png',
            icon = 'uires/ui_2nd/com/panel/activity/lucky_card_icon.png',
            enter = LuckyCard.enter,
            --isOverTime = LuckyCard.isOverTime()
        },
        pawn = {
            title = 'uires/ui_2nd/com/panel/activity/pawn_shop_txt.png',
            icon = 'uires/ui_2nd/com/panel/activity/pawn_shop_icon.png',
            status = PawnShop.isActive(),
            enter = PawnShop.enter
        },
        wheel = {
            title = 'uires/ui_2nd/com/panel/activity/dextiny_wheel_txt.png',
            icon = 'uires/ui_2nd/com/panel/activity/dextiny_wheel_icon.png',
            enter = Wheel.enter
        },
        tower = {
            title = 'uires/ui_2nd/com/panel/activity/chonglou_txt.png',
            icon = 'uires/ui_2nd/com/panel/activity/chonglou_icon.png',
            enter = ChallengeTower.enter,
            --isOverTime = ChallengeTower.isOverTime()
        },
        summer_days = {
            title = 'uires/ui_2nd/com/panel/activity/summerday_txt.png',
            icon = 'uires/ui_2nd/com/panel/activity/summerday_icon.png',
            enter = SummerDays.enter,
            --isOverTime = SummerDays.isOverTime()
        },
        business = {
            title = 'uires/ui_2nd/com/panel/activity/trade_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/biao_icon.png',
            status = PlayerCoreData.isBusinessTimeFull(),
            enter = showBusinessPanel,
        },
        oneride = {
            title = 'uires/ui_2nd/com/panel/activity/oneride_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/oneride_icon.png',
            enter = OneRide.enter
        },
		accumulatepay = {
            title = 'uires/ui_2nd/com/panel/activity/accpay_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/accpay_icon.png',
            --isOverTime = Accumulatepay.isOverTime(),
            status = Accumulatepay.isActive(),
            enter = Accumulatepay.enter
        },
        nationalday = {
            title = 'uires/ui_2nd/com/panel/activity/nationalday_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/nationday_icon.png',
            --isOverTime = NationalDay.isOverTime(),
            status= NationalDay.isActive(),
            enter = NationalDay.enter
        },
        worldboss = {
            title = 'uires/ui_2nd/com/panel/activity/boss_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/boss_icon.png',
            status= worldboss.isActive(),
            enter = worldboss.enter
        },
        grave = {
            title = 'uires/ui_2nd/com/panel/activity/tomb_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/tomb_ico.png',
            status= Grave.isActive(),
            enter = Grave.enter
        },
        allgift = {
            title = 'uires/ui_2nd/com/panel/activity/welfare_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/welfare_icon.png',
            status= Welfare.isActive(),
            enter = Welfare.enter
        },
        allgift1 = {
            title = 'uires/ui_2nd/com/panel/activity/welfare_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/welfare_icon.png',
            enter = Welfare1.enter
        },
        thxgiving = {
            title = 'uires/ui_2nd/com/panel/activity/thanksgiving_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/accpay_icon.png',
            status= Thxgiving.isActive(),
            enter = Thxgiving.enter
        },
        lucky_circle = {
            title = 'uires/ui_2nd/com/panel/activity/luck_runner_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/luck_runner.png',
            enter = LuckRunner.enter
        },
        paycarnival = {
            title = 'uires/ui_2nd/com/panel/activity/recharge_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/caishen_icon.png',
            enter = Recharge.enter
        },
        borrowarrow = {
            title = 'uires/ui_2nd/com/panel/activity/avborrowarrow_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/avborrowarrow_icon.png',
            status= Avborrowarrow.isActive(),
            enter = Avborrowarrow.enter

        },
        payceremony = {
            title = 'uires/ui_2nd/com/panel/activity/avpay_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/accpay_icon.png',
            enter = Avpay.enter
        },
        patrol = {
            title = 'uires/ui_2nd/com/panel/activity/patrol_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/mine.png',
            status= GarrisonMine.isActive(),
            enter = GarrisonMine.enter
        },
	   luckyroll = {
            title = 'uires/ui_2nd/com/panel/activity/luckyroll_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/luckyroll_icon.png',
            enter = Avluckyroll.enter
        },
        avfood = {
            title = 'uires/ui_2nd/com/panel/activity/avfood_txt.png',
            icon  = 'uires/ui_2nd/com/panel/activity/avfood_icon.png',
            status= Avfood.isActive(),
            enter = Avfood.enter
        }
        -- fragment = {
        --     title = 'uires/ui_2nd/com/panel/activity/fragment_txt.png',
        --     icon  = 'uires/ui_2nd/com/panel/activity/fragment_icon.png',
        --     status= Fragment.isActive(),
        --     enter = Fragment.enter
        -- }
    }
end

local function setupUi(counter)

    local function shake()
        local mov1 = CCRotateBy:create(0.1, 10)
        local mov2 = CCRotateBy:create(0.1, -20)
        local actArr = CCArray:create()
        for i = 1, 3 do
            actArr:addObject(mov1)
            actArr:addObject(mov1:reverse())
            actArr:addObject(mov2)
            actArr:addObject(mov2:reverse())
        end
        actArr:addObject(CCDelayTime:create(0.2))

        return CCRepeatForever:create(CCSequence:create(actArr))
    end

    local function isNotOpen(conf)
        if conf.Key == 'tower' then                 -- 如果是挑战重楼
            return ChallengeTower.isOverTime()
        else 
            if tonumber(conf.Normalization) == 0 then -- 非常态活动
                 local actyStartTime
                local actyEndTime
                if conf.StartTime ~= nil and conf.StartTime ~= '' then -- 优先判断StartTime字段
                    actyStartTime = UserData:convertTime(1, conf.StartTime)
                    actyEndTime   = UserData:convertTime(1, conf.EndTime) + (tonumber(conf.DelayDays))*86400 -- 加上奖励的领取延时1天 这两天充值元宝不计
                else
                    local serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
                    actyStartTime = serverOpenTime + (tonumber(conf.OpenDay) - 1)*86400
                    actyEndTime = serverOpenTime + (tonumber(conf.OpenDay) + tonumber(conf.Duration) - 1)*86400 + tonumber(conf.DelayDays)*86400
                end
                local nowTime = UserData:getServerTime()
                if nowTime < actyStartTime or nowTime > actyEndTime then
                    return true
                end

            else    -- 常态活动
                 if conf.StartTime ~= nil and conf.StartTime ~= '' then
                    local time = UserData:getServerTime()
                    local startTime = UserData:convertTime(1,conf.StartTime)
                    local endTime = UserData:convertTime(1,conf.EndTime)

                    if time < startTime or time > endTime then
                        return true
                    end
                end
            end
            local openServerTime = UserData:getOpenServerDays()
            local beginTimeOfOpenServerTime = Time.beginningOfOneDay(openServerTime)
            local nowTime = UserData:getServerTime()
            local diffDay = (nowTime - beginTimeOfOpenServerTime)/86400 + 1
            if diffDay < tonumber(conf.OpenDay) then
                return true
            end
            return false
        end
    end

    local function addActivity( conf, actRes )
        if isNotOpen(conf) then
            return
        end

        local actPanel = counter("panel/activity_btn_panel.json", actRes.enter, conf.Key)
        local actBtn = tolua.cast(actPanel:getChildByName('activity_btn'), 'UIButton')
        local actStateImg = tolua.cast(actPanel:getChildByName('tips_icon'), 'UIImageView')
        local title = tolua.cast(actPanel:getChildByName('title_txt_ico'), 'UIImageView')
        local icon = tolua.cast(actPanel:getChildByName('title_icon_ico'), 'UIImageView')
        local descTx1 = tolua.cast(actPanel:getChildByName('info_1_tx'), 'UILabel')
        local descTx2 = tolua.cast(actPanel:getChildByName('info_2_tx'), 'UILabel')
        local unlockTx = tolua.cast(actPanel:getChildByName('unlock_tx') , 'UITextArea')
        local kuangIcon = tolua.cast(actPanel:getChildByName('txt_kuang_ico') , 'UIImageView')
        descTx1:setPreferredSize(260,1)
        descTx2:setPreferredSize(265,1)

        if title then
            title:setTexture(actRes.title)
        end

        if icon then
            icon:setTexture(actRes.icon)
        end

        if descTx1 and descTx2 then
            descTx1:setText(GetTextForCfg(conf.Desc1))
            descTx2:setText(GetTextForCfg(conf.Desc2))
        end

        actStateImg:stopAllActions()
        actStateImg:setRotation(-20)
        actStateImg:runAction(shake())
        if PlayerCoreData.getPlayerLevel() < tonumber(conf.OpenLevel) then
            actBtn:setTouchEnable(false)
            local s = string.format(getLocalStringValue("E_STR_ACTIVITY_UNLOCK_DESC") , tonumber(conf.OpenLevel))
            unlockTx:setText(s)
            actStateImg:setVisible(false)
            title:setGray()
            icon:setVisible(false)
            kuangIcon:setGray()
        else
            actBtn:setTouchEnable(true)
            unlockTx:setText('')
            actStateImg:setVisible(actRes.status or false)
            title:setNormal()
            icon:setVisible(true)
            kuangIcon:setNormal()
        end
    end

    local actConf = GameData:getArrayData('activities.dat')
    local actResMap = getActRes()
    table.foreach(actConf , function(key , value)
        if actResMap[value.Key] then
            addActivity(value, actResMap[value.Key])
        end
    end)
end

function genActivityHall()
	local actObj = SceneObjEx:createObj('panel/activity_panel.json', 'activity_master_hall_panel')
    local panel = actObj:getPanelObj()
    panel:setAdaptInfo('activity_bg_img', 'activity_img')

    
    local function genContainer()
    	local container = {}
    	local root = panel:GetRawPanel()
    	local sv = tolua.cast(root:getChildByName('bottom_sv'),'UIScrollView')
    	sv:setClippingEnable(true)
    	sv:setDirection(SCROLLVIEW_DIR_HORIZONTAL)

    	return function(jsonPrototype, handler, name)
    		local widget = createWidgetByName(jsonPrototype)
            widget:setName(name)
    		sv:addChildToRight(widget)
    		widget:getChildByName('activity_btn'):registerScriptTapHandler(handler)
    		return widget
    	end
    end

    panel:registerInitHandler(
    	function()
			local root = panel:GetRawPanel()
			panel:registerScriptTapHandler('close_btn', UiMan.genCloseHandler(actObj))
			setupUi(genContainer())
		end
	)

    panel:registerOnShowHandler(
        function ()
            local root = panel:GetRawPanel()
            local sv = tolua.cast(root:getChildByName('bottom_sv'),'UIScrollView')
            local actResMap = getActRes()
            table.foreach(actResMap , function (key , value)
                local child = sv:getChildByName(key)
                local actConf = GameData:getMapData('activities.dat')[key]
                if child and actConf then
                    local actStateImg = tolua.cast(child:getChildByName('tips_icon'), 'UIImageView')
                    if PlayerCoreData.getPlayerLevel() < tonumber(actConf.OpenLevel) then
                        actStateImg:setVisible(false)
                    else
                        actStateImg:setVisible(value.status or false)
                    end
                end
            end)
        end
    )

    UiMan.show(actObj)
end