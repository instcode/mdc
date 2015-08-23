-- Card master main panel.

local CARD_RES = readOnly{
    "uires/ui_2nd/com/panel/card_master/card_dao.png",
    "uires/ui_2nd/com/panel/card_master/card_qiang.png",
    "uires/ui_2nd/com/panel/card_master/card_qi.png",
    "uires/ui_2nd/com/panel/card_master/card_mou.png",
    "uires/ui_2nd/com/panel/card_master/card_hong.png",
    "uires/ui_2nd/com/panel/card_master/card_king.png",
}

local STATUS_RES = readOnly{
    "uires/ui_2nd/com/panel/card_master/ball_blue.png",
    "uires/ui_2nd/com/panel/card_master/ball_blue.png",
    "uires/ui_2nd/com/panel/card_master/ball_blue.png",
    "uires/ui_2nd/com/panel/card_master/ball_purple.png",
    "uires/ui_2nd/com/panel/card_master/ball_purple.png",
    "uires/ui_2nd/com/panel/card_master/ball_yellow.png",
}

local ROUND_RES = readOnly{
    "uires/ui_2nd/com/panel/card_master/round_1.png",
    "uires/ui_2nd/com/panel/card_master/round_2.png",
    "uires/ui_2nd/com/panel/card_master/round_3.png",
    "uires/ui_2nd/com/panel/card_master/round_4.png",
    "uires/ui_2nd/com/panel/card_master/round_5.png",
}

local CARD_BACK_RES = 'uires/ui_2nd/com/panel/card_master/card_back.png'

CardMaster = {}

function CardMaster.isActive()
    local cardData = UserData:getCardMasterData()
    return cardData.count < 3
end

function CardMaster.sendGetRequest()
    Message.sendPost('get', 'cardmaster', '{}', function ( res )
        local resTable = json.decode(res)
        if resTable.code == 0 then
            local currScore = resTable.data.card_score
            PlayerCoreData.setScoreValue(currScore)
            UserData:setCardMasterData(json.encode(resTable.data.card_master))
            CardMaster.showMainPanel()
        end
    end)
end

-- 卡牌大师入口
function CardMaster.enter()
    local cardConfig = GameData:getMapData('activities.dat').card
    local openLv = tonumber(cardConfig.OpenLevel) --tonumber(GameData:getGlobalValue('CardOpenLevel'))
    local playerLv = PlayerCoreData.getPlayerLevel()

    if playerLv < openLv then
        local msg = string.format(getLocalString('E_STR_TRAIN_LIMIT'), openLv)
        GameController.showMessageBox(msg, MESSAGE_BOX_TYPE.OK)
    else
        CardMaster.sendGetRequest()
    end
end

local helpSceneObj

function CardMaster.hideHelpPanel()
    if helpSceneObj then
        CUIManager:GetInstance():HideObject(helpSceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
    end
end

-- 卡牌大师帮助界面
function CardMaster.showHelpPanel()
    helpSceneObj = SceneObjEx:createObj('panel/card_help_panel.json', 'card-master-help-lua')
    local panel = helpSceneObj:getPanelObj()
    panel:setAdaptInfo('card_bg_img', 'card_img')

    panel:registerInitHandler(function()
        local root = panel:GetRawPanel()
        local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
        local knownBtn = tolua.cast(root:getChildByName('know_btn'), 'UIButton')
        
        closeBtn:registerScriptTapHandler(CardMaster.hideHelpPanel)
        knownBtn:registerScriptTapHandler(CardMaster.hideHelpPanel)

        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
        GameController.addButtonSound(knownBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
    end)

    CUIManager:GetInstance():ShowObject(helpSceneObj, ELF_SHOW.ZOOM_IN)
end


-- 卡牌大师积分商铺界面
function CardMaster.showShopPanel()
    local sceneObj = SceneObjEx:createObj('panel/score_shop_panel.json', 'card-master-shop-lua')
    local panel = sceneObj:getPanelObj()
    local scoreLabel
    local scrollView

    local shopConf = GameData:getArrayData('shopexchange.dat')

    panel:setAdaptInfo('score_bg_img', 'score_img')

    local function closePanel()
        CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
    end

    local function sendExchangeRequest( shopid , count )
        local args = {
            id = shopid,
            num = count
        }

        Message.sendPost('exchange','cardmaster', json.encode(args) , function( res )
            local resTable = json.decode(res)
            if resTable.code ~= 0 then
                return
            end

            local data = resTable.data
            if not data then 
                return
            end

            local awards = data.awards
            local awardStr = json.encode(awards)
            UserData.parseAwardJson(awardStr)
            GameController.showPrompts(getLocalStringValue('E_STR_EXCHANGE_SUCCEED'), COLOR_TYPE.GREEN)

            if scoreLabel then
               scoreLabel:setText(toWordsNumber(PlayerCoreData:getScoreValue()))
            end
        end)
    end

    local function genMsScoreCell( conf )
        local exId , exPrice = conf['Id'] , tonumber(conf['Price'])
        local panel = createWidgetByName( 'panel/card_master_score_item.json' )
        if not panel then 
            return 
        end
        local root = tolua.cast(panel:getChildByName( 'background_img' ) , 'UIImageView')
        local itemIcon = tolua.cast(root:getChildByName( 'item_img_icon' ) , 'UIImageView')
        local itemCount = tolua.cast(root:getChildByName( 'item_img_tx' ) , 'UILabel')
        local itemNameTx = tolua.cast(root:getChildByName( 'item_name_tx' ) , 'UILabel')
        local itemPriceTx = tolua.cast(root:getChildByName( 'score_price_tx' ) , 'UILabel')

        local expBtn = tolua.cast(root:getChildByName( 'exchange_btn' ) , 'UIButton')
        GameController.addButtonSound( expBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT )

        local award = UserData:getAward( conf['Award1'] )
        itemIcon:setTexture( award['icon'] )
        itemIcon:setTouchEnable(true)
        itemIcon:registerScriptTapHandler(function()
            local awardStr = conf['Award1']
            UISvr:showTipsForAward(awardStr)
        end)
        itemCount:setText(tostring(award['count']))
        itemNameTx:setText( award['name'] )
        itemNameTx:setColor( award['color'] )
        itemPriceTx:setTextFromInt( exPrice )

        expBtn:registerScriptTapHandler( function ()
            local awardClone = award
            if PlayerCoreData.getScoreValue() < exPrice then
                local s = string.format(getLocalString( 'E_STR_CARD_MASTER_NOT_ENOUGH_SCORE') )
                GameController.showMessageBox( s , MESSAGE_BOX_TYPE.OK )
            else
                --data : id , name , count , color , icon , desc , price(单价) 
                local data = {}
                data['id'] = exId
                data['name'] = awardClone['name']
                data['color'] = awardClone['color']
                data['icon'] = awardClone['icon']
                if awardClone['type'] == 'material' then
                    local materialAward = Material:findById(awardClone['id'])
                    data['count'] = PlayerCoreData.getMaterialCount( tonumber(awardClone['id']) )
                    data['desc'] = PlayerCoreData.getMaterialDesc( tonumber(awardClone['id']) )
                elseif awardClone['type'] == 'user' then
                    if awardClone['id'] == 'food' then
                        data['count'] = PlayerCoreData.getFoodValue()
                    elseif awardClone['id'] == 'gold' then
                        data['count'] = PlayerCoreData.getGoldValue()
                    end
                    data['desc'] = ''
                end
                data['price'] = exPrice
                openScoreShopPanel(data , sendExchangeRequest)
            end
        end )
        return panel
    end

    local function updatePanel()
        scoreLabel:setText(toWordsNumber(PlayerCoreData:getScoreValue()))
        scrollView:removeAllChildrenAndCleanUp(true)
        table.foreach(shopConf , function (_, v)
            if v['Key'] == 'card' then
                scrollView:addChildToRight( genMsScoreCell( v ) )
            end
        end)
    end

    panel:registerInitHandler(function()
        local root = panel:GetRawPanel()
        local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
        
        scoreLabel = tolua.cast(root:getChildByName('score_tx_lb'), 'UILabel')
        m_scoreLabel = scoreLabel
        scrollView = tolua.cast(root:getChildByName('score_sv'), 'UIScrollView')
        scrollView:setClippingEnable(true)
        scrollView:setDirection(SCROLLVIEW_DIR_HORIZONTAL)

        closeBtn:registerScriptTapHandler(closePanel)
        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)

        updatePanel()
    end)

    panel:registerOnShowHandler(function()
        UIScrollView:setScrollViewEnabled(true)
    end)

    CUIManager:GetInstance():ShowObject(sceneObj, ELF_SHOW.ZOOM_IN)
end


-- 卡牌大师主界面
function CardMaster.showMainPanel()
	local cardMaster = SceneObjEx:createObj('panel/card_master_main_panel.json', 'card-master-main-lua')
    local panel = cardMaster:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('card_master_bg_img', 'card_master_img')

    local cashLabel
    local scoreLabel
    local countLabel
    local selectLabel

    local closeBtn
    local refreshBtn
    local shopBtn
    local shufAndFightBtn
    local shufTips
    local helpBtn

    local scrollView

    local cardPanel = {}
    local cardViews = {}
    local statViews = {}

    local selectedCardCount = 0

    local isChoosingCard = false    -- 正在选牌的标志，如果正在播放选牌动画，则不允许进行下一次选牌

    local function initCards()
        local data = UserData:getCardMasterData()
        if data then
            local myCards = UserData:getCardMasterData().cards
            selectedCardCount = 0
            for i = 1, 5 do
                local cardID = tonumber(myCards[tostring(i)])
                if cardID and cardID > 0 then 
                    cardViews[i]:setTexture(CARD_RES[cardID])
                    cardPanel[i]:setTouchEnable(false)
                    cardPanel[i]:setVisible(true)
                    selectedCardCount = selectedCardCount + 1
                end
            end

            if selectedCardCount >= 5 then
                for i = 6, 20 do
                    cardPanel[i]:setVisible(false)
                end
            end

            if selectedCardCount <= 0 then
                local allCard = readOnly{6,5,5,4,4,3,3,3,3,3,2,2,2,2,2,1,1,1,1,1}
                for i = 1, 20 do
                    cardViews[i]:setTexture(CARD_RES[allCard[i]])
                    cardPanel[i]:setVisible(true)
                    cardViews[i]:setTouchEnable(false)
                end
            else
                for i = selectedCardCount + 1, 20 do
                    cardPanel[i]:setTouchEnable(true)
                end
            end
        end
    end

    local function updateMainPanel()
        local cardData = UserData:getCardMasterData()
        local myCards = cardData.cards

        -- Set count value
        cashLabel:setText(toWordsNumber(PlayerCoreData.getCashValue()))
        scoreLabel:setText(toWordsNumber(PlayerCoreData:getScoreValue()))
        local usedCount = cardData.count
        local allCount = tonumber(GameData:getGlobalValue('CardMasterRoundTimes'))
        countLabel:setText(string.format("%d/%d", allCount - usedCount, allCount))

        -- Set select label
        selectedCardCount = 0
        for i = 1, 5 do
            local cardID = tonumber(cardData.cards[tostring(i)])
            if cardID > 0 then
                statViews[i]:setTexture(STATUS_RES[cardID])
                statViews[i]:setVisible(true)
                selectedCardCount = selectedCardCount + 1
            else
                statViews[i]:setVisible(false)
            end
        end

        if selectedCardCount <= 0 then
            refreshBtn:disable()
            
            -- Set count label
            if usedCount > 0 then
                if usedCount >= 3 then
                    shufAndFightBtn:disable()
                else
                    shufAndFightBtn:active()
                end
            else
                shufAndFightBtn:active()
            end

            shufAndFightBtn:setText(getLocalString('E_STR_CARD_SHUFFLE_BTN'))
            shufTips:setVisible(true)
        else
            shufAndFightBtn:disable()
            refreshBtn:active()
            shufTips:setVisible(false)

            if selectedCardCount >= 5 then
                shufAndFightBtn:active()
                shufAndFightBtn:setText(getLocalString('E_STR_CARD_FIGHT_BTN'))
                UIScrollView:setScrollViewEnabled(false)
            end
        end

        for i = 1, 5 do
            if cardData.result[tostring(i)] ~= 2 then
                refreshBtn:disable()
            end
        end

        selectLabel:setText(string.format("%d/5", selectedCardCount))
    end

    local function updateSelect()
        isChoosingCard = false
        if selectedCardCount >= 5 then
            for i = 1, 20 do
                local delay = CCDelayTime:create(0.2)

                local fadeOut = CCFadeOut:create(0.2)
                local cb = CCCallFunc:create(function()
                    scrollView:scrollToLeft()
                    local cards = UserData:getCardMasterData().cards
                    for i = 1, 5 do
                        cardViews[i]:setTexture(CARD_RES[cards[tostring(i)]])
                        cardPanel[i]:runAction(CCFadeIn:create(0.2))
                    end
                    UIScrollView:setScrollViewEnabled(false)
                end)
                local arr = CCArray:create()
                arr:addObject(delay)
                arr:addObject(fadeOut)
                if i == 1 then
                    arr:addObject(cb)
                end
                local seq = CCSequence:create(arr)
                cardPanel[i]:stopAllActions()
                cardPanel[i]:runAction(seq)
            end
        end
    end

    local function updateRefresh()
        local allCard = readOnly{6,5,5,4,4,3,3,3,3,3,2,2,2,2,2,1,1,1,1,1}
        for i = 1, 20 do
            cardPanel[i]:setOpacity(255)
            cardPanel[i]:setVisible(true)
            cardPanel[i]:setTouchEnable(false)
            cardViews[i]:setTexture(CARD_RES[allCard[i]])
        end
        scrollView:scrollToLeft()
        UIScrollView:setScrollViewEnabled(true)
    end

    panel:registerInitHandler(function()
        local root = panel:GetRawPanel()

        -- Init labels
        cashLabel = tolua.cast(root:getChildByName('cash_label'), 'UILabel')
        scoreLabel = tolua.cast(root:getChildByName('score_lb'), 'UILabel')
        countLabel = tolua.cast(root:getChildByName('fight_count_lb'), 'UILabel')
        selectLabel = tolua.cast(root:getChildByName('selected_lb'), 'UILabel')

        -- Init buttons
        closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
        refreshBtn = tolua.cast(root:getChildByName('change_card_btn'), 'UIButton')
        shopBtn = tolua.cast(root:getChildByName('shop_btn'), 'UIButton')
        shufAndFightBtn = tolua.cast(root:getChildByName('shuffle_btn'), 'UITextButton')
        helpBtn = tolua.cast(root:getChildByName('help_btn'), 'UIButton')
        shufTips = tolua.cast(root:getChildByName('click_refresh_tip_icon'), 'UIImageView')

        -- Init scrollView
        scrollView = tolua.cast(root:getChildByName('select_sv'), 'UIScrollView')
        scrollView:setDirection(SCROLLVIEW_DIR.HORIZONTAL)
        scrollView:setClippingEnable(true)
        UIScrollView:setScrollViewEnabled(true)

        -- Init 20 cards
        for i = 1, 20 do
            cardViews[i] = UIImageView:create()
            cardViews[i]:setTexture(CARD_BACK_RES)
            local sz = cardViews[i]:getContentSize()
            cardViews[i]:setPosition(ccp(sz.width / 2, sz.height / 2))
            cardPanel[i] = UIPanel:create()
            cardPanel[i]:setSize(sz)
            cardPanel[i]:addChild(cardViews[i])
            cardPanel[i]:setTouchEnable(false)
            cardPanel[i]:registerScriptTapHandler(function()
                if not isChoosingCard then
                    isChoosingCard = true
                    cardPanel[i]:setTouchEnable(false)
                    Message.sendPost('choose', 'cardmaster', '{}', function( res )
                        local resTable = json.decode(res)
                        if resTable.code == 0 then
                            UserData:setCardMasterData(json.encode(resTable.data.card_master))
                            local gotCardId = resTable.data.card_master.cards[tostring(selectedCardCount + 1)]
                            local arr = CCArray:create()
                            arr:addObject(CCOrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0))
                            arr:addObject(CCCallFunc:create(function()
                                cardViews[i]:setTexture(CARD_RES[gotCardId])
                            end))
                            arr:addObject(CCOrbitCamera:create(0.2, 1, 0, 270, 90, 0, 0))
                            arr:addObject(CCCallFunc:create(updateMainPanel))
                            arr:addObject(CCCallFunc:create(updateSelect))
                            local seq = CCSequence:create(arr)
                            cardViews[i]:runAction(seq)
                        end
                    end)
                end
            end)
            scrollView:addChildToRight(cardPanel[i])
        end
        scrollView:scrollToLeft()

        -- Init status lights.
        for i = 1, 5 do
            local stateParent = tolua.cast(root:getChildByName(string.format("ball_icon_%d", i)), 'UIImageView')
            statViews[i] = UIImageView:create()
            stateParent:addChild(statViews[i])
        end

        -- Set buttons' function
        closeBtn:registerScriptTapHandler(function()
            CUIManager:GetInstance():HideObject(cardMaster, ELF_HIDE.SMART_HIDE)
        end)

        refreshBtn:registerScriptTapHandler(function()
            -- Cash and count validation.
            local freeCount = UserData:getCardMasterData().free
            local cashCost
            local msgStr = ''
            if freeCount <= 0 then
                cashCost = 0
                msgStr = getLocalString('E_STR_TIPS_FREE_COUNT_REFRESH_CARDS')
            else
                local cashCount = UserData:getCardMasterData().cash
                local buyData = GameData:getArrayData('buy.dat')
                cashCost = buyData[cashCount + 1].CashCard
                if cashCost == '' then
                    GameController.showMessageBox(getLocalString('E_STR_CARD_MASTER_NO_CASH_COUNT'), MESSAGE_BOX_TYPE.OK)
                    return
                else
                    msgStr = string.format(getLocalString('E_STR_SPEND_CASH_TO_REPICK_CARD'), cashCost)
                end
            end
            args = json.encode({cash = cashCost})
            GameController.showMessageBox(msgStr, MESSAGE_BOX_TYPE.OK_CANCEL, function()
                Message.sendPost('regret', 'cardmaster', args, function(res)
                    local resTable = json.decode(res)
                    if resTable.code == 0 then
                        UserData.parseAwardJson(json.encode(resTable.data.awards))
                        UserData:setCardMasterData(json.encode(resTable.data.card_master))
                        updateRefresh()
                        updateMainPanel()
                        isChoosingCard = false
                        for i = 1, 20 do
                            cardPanel[i]:stopAllActions()
                            cardPanel[i]:setTouchEnable(false)
                        end
                    end
                end)
            end)
        end)

        shopBtn:registerScriptTapHandler(CardMaster.showShopPanel)

        shufAndFightBtn:registerScriptTapHandler(function()
            if selectedCardCount == 0 then
                -- Shuffle
                UIScrollView:setScrollViewEnabled(false)
                shufAndFightBtn:disable()
                scrollView:scrollToLeft()
                local originPos = {}
                local startPos = {}
                local endPos = {}
                local bigSz = scrollView:getContentSize()
                local smallSz = cardPanel[1]:getContentSize()
                local space = (bigSz.width - smallSz.width) / 20
                local factor = bigSz.width / (2 * space)

                isChoosingCard = false
                for i = 1, 20 do
                    cardPanel[i]:stopAllActions()
                    originPos[i] = cardPanel[i]:getPosition()
                    local newX = bigSz.width / 2 - (factor - i) * space
                    startPos[i] = ccp(newX, originPos[i].y)
                    cardPanel[i]:setVisible(true)
                    cardViews[i]:setTexture(CARD_BACK_RES)
                end

                for i = 1, 20 do
                    endPos[i] = startPos[20 - i + 1]
                    local setStartPos = CCMoveTo:create(0.01, startPos[i])
                    local fixScrollView = CCCallFunc:create(function()
                        scrollView:scrollToLeft()
                    end)
                    local washMove = CCMoveTo:create(0.25, endPos[i])
                    local washReverse = CCMoveTo:create(0.25, startPos[i])
                    local washBack = CCMoveTo:create(0.25, originPos[i])
                    local activeCell = CCCallFunc:create(function()
                        cardPanel[i]:setTouchEnable(true)
                    end)
                    local turnback = CCCallFunc:create(function()
                        cardViews[i]:setTexture(CARD_BACK_RES)
                    end)
                    local afterShuffle = CCCallFunc:create(function()
                        UIScrollView:setScrollViewEnabled(true)
                        shufAndFightBtn:active()
                    end)

                    local arr = CCArray:create()
                    arr:addObject(turnback)
                    arr:addObject(setStartPos)
                    arr:addObject(fixScrollView)
                    arr:addObject(washMove)
                    arr:addObject(washReverse)
                    arr:addObject(washMove)
                    arr:addObject(washReverse)
                    arr:addObject(washBack)
                    arr:addObject(activeCell)
                    if i == 20 then
                        arr:addObject(afterShuffle)
                    end
                    local seq = CCSequence:create(arr)
                    cardPanel[i]:runAction(seq)
                end
            elseif selectedCardCount >= 5 then
                CardMaster.showBattlePanel()
                CUIManager:GetInstance():HideObject(cardMaster, ELF_SHOW.NORMAL)
            end
        end)

        helpBtn:registerScriptTapHandler(CardMaster.showHelpPanel)

        -- Set buttons' effect
        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
        GameController.addButtonSound(refreshBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        GameController.addButtonSound(shopBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        GameController.addButtonSound(shufAndFightBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        GameController.addButtonSound(helpBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)

        initCards()
        updateMainPanel()
    end)
        
    panel:registerOnShowHandler(function()
        updateMainPanel()
    end)

    panel:registerOnHideHandler(function()
        UIScrollView:setScrollViewEnabled(true)
    end)

    -- Show now
    CUIManager:GetInstance():ShowObject(cardMaster, ELF_SHOW.SMART)
end


-- 卡牌大师战斗界面
function CardMaster.showBattlePanel()
    local sceneObj = SceneObjEx:createObj('panel/card_master_battle_panel.json', 'card-master-battle-lua')
    local panel = sceneObj:getPanelObj()
    panel:setAdaptInfo('card_master_battle_bg_img', 'card_master_battle_img')

    local playBtn

    local roundIcon
    local winLabel
    local drawLabel
    local loseLabel

    local enemyIcon
    local enmeyName
    local enmeyCardsNum

    local enmeyStates = {}
    local randomStatsPos = {}

    local myCardPanels = {}
    local myCardImages = {}

    local enemyPos = ccp(111, -3)
    local myPos = ccp(-292, -40)

    local enemyCardPanel
    local enemyCardImage

    local playRound = 0

    local function closePanel()
        CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
    end

    -- 初始化战斗卡牌数据
    local function initBattle()
        local roleArr = GameData:getArrayData('role.dat')
        local randomRole = roleArr[math.random(#roleArr)]
        local res = Role.getResourceByIdAndResType(randomRole.Id, RESOURCE_TYPE.ICON)
        enemyIcon:setTexture(res)
        enmeyName:setText(GetTextForCfg(randomRole.Name))

        local cardData = UserData:getCardMasterData()
        local enemyCards = Array:new()

        for i = 1, 5 do
            enemyCards:push(cardData.enemy_cards[tostring(i)])
        end

        randomStatsPos = Array:new{1,2,3,4,5}:random()
        -- randomStatsPos = Array:new{5,2,3,4,1}
        for i = 1, 5 do
            local randIndex = randomStatsPos[i]
            local enemyCardId = enemyCards[randIndex]
            enmeyStates[i]:setTexture(STATUS_RES[enemyCardId])
        end

        local myCardsData = cardData.cards
        local results = cardData.result
        for i = 1, 5 do
            local myCardId = myCardsData[tostring(i)]
            local roundResult = results[tostring(i)]
            if roundResult == 2 then
                myCardPanels[i]:setVisible(true)
                myCardPanels[i]:setTouchEnable(true)
                myCardImages[i]:setTexture(CARD_RES[myCardId])
            else
                myCardPanels[i]:setVisible(false)
                myCardPanels[i]:setTouchEnable(false)
                playRound = playRound + 1
            end
        end

        roundIcon:setTexture(ROUND_RES[playRound + 1])
    end

    -- 刷新战斗界面
    local function updateBattle()
        -- Update result status.
        local win = 0
        local draw = 0
        local lose = 0

        for i = 1, 5 do
            local randIndex = randomStatsPos[i]
            local roundResult = UserData:getCardMasterData().result[tostring(randIndex)]
            if roundResult == 2 then
                enmeyStates[i]:setNormal()
            else
                enmeyStates[i]:setGray()
                if roundResult == 1 then
                    win = win + 1
                elseif roundResult == -1 then
                    lose = lose + 1
                elseif roundResult == 0 then
                    draw = draw + 1
                end
            end
        end

        winLabel:setText(string.format("%d", win))
        drawLabel:setText(string.format("%d", draw))
        loseLabel:setText(string.format("%d", lose))
        enmeyCardsNum:setText(string.format("X%d", 5 - win - draw - lose))
    end

    local selectCardIndex = 0
    local function onClickCard( index )
        local pos = myCardPanels[index]:getPosition()
        local disable = CCCallFunc:create(function()
            myCardPanels[index]:setTouchEnable(false)
        end)
        local enable = CCCallFunc:create(function()
            myCardPanels[index]:setTouchEnable(true)
        end)

        local arr = CCArray:create()
        arr:addObject(disable)
        if selectCardIndex == index then
            arr:addObject(CCMoveTo:create(0.1, ccp(pos.x, pos.y - 20)))
            selectCardIndex = 0
        else
            arr:addObject(CCMoveTo:create(0.1, ccp(pos.x, pos.y + 20)))
            if selectCardIndex > 0 then
                local lastPos = myCardPanels[selectCardIndex]:getPosition()
                myCardPanels[selectCardIndex]:runAction(CCMoveTo:create(0.1, ccp(lastPos.x, lastPos.y - 20)))
            end
            selectCardIndex = index
        end
        arr:addObject(enable)
        local seq = CCSequence:create(arr)
        myCardPanels[index]:runAction(seq)
    end

    -- 己方卡牌挂逼动画
    local function myCardFly()
        local myArr = CCArray:create()
        myArr:addObject(CCFadeOut:create(0.5))
        myArr:addObject(CCMoveBy:create(0.5, ccp(-500, 100)))
        myArr:addObject(CCRotateBy:create(0.5, -360 * 5))
        return CCSpawn:create(myArr)
    end

    -- 地方卡牌挂逼动画
    local function enemyCardFly()
        local enmeyArr = CCArray:create()
        enmeyArr:addObject(CCFadeOut:create(0.5))
        enmeyArr:addObject(CCMoveBy:create(0.5, ccp(500, 450)))
        enmeyArr:addObject(CCRotateBy:create(0.5, 360 * 5))
        return CCSpawn:create(enmeyArr)
    end

    local function onFightResponse( res )
        local resTable = json.decode(res)
        if resTable.code ~= 0 then
            return
        end

        local function endOfEnemy()
            updateBattle()
            if playRound < 5 then
                enemyCardPanel:setPosition(enemyPos)
                enemyCardImage:setTexture(CARD_BACK_RES)
                myCardPanels[selectCardIndex]:setVisible(false)
                myCardPanels[selectCardIndex]:setTouchEnable(false)
            end
        end

        local function endOfPlaying()
            local allResult = resTable.data.card_master.result
            for i = 1, 5 do
                if allResult[tostring(i)] == 2 then
                    myCardPanels[i]:setTouchEnable(true)
                end
            end

            playBtn:active()

            local finalResult = resTable.data.round_result
            if finalResult == 2 then
                return
            end

            playBtn:disable()

            -- 战斗结果界面
            local resultSceneObj = SceneObjEx:createObj('panel/card_result_panel.json', 'CMResultPanel-lua')
            local resultPanel = resultSceneObj:getPanelObj()
            resultPanel:setAdaptInfo('card_bg_img', 'card_img')

            resultPanel:registerInitHandler(function()
                local root = resultPanel:GetRawPanel()
                local okBtn = tolua.cast(root:getChildByName('ok_btn'), 'UIButton')
                okBtn:registerScriptTapHandler(function()
                    CUIManager:GetInstance():HideObject(resultSceneObj, ELF_HIDE.SLIDE_OUT)
                    CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.SLIDE_OUT)
                    CardMaster.sendGetRequest()
                end)
                GameController.addButtonSound(okBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
                local background = tolua.cast(root:getChildByName('card_bg_img'), 'UIButton')
                background:registerScriptTapHandler(function()
                    CUIManager:GetInstance():HideObject(resultSceneObj, ELF_HIDE.SLIDE_OUT)
                    CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.SLIDE_OUT)
                    CardMaster.sendGetRequest()
                end)

                local titleImage = tolua.cast(root:getChildByName('title_img'), 'UIImageView')
                if finalResult == 1 then
                    titleImage:setTexture('uires/ui_2nd/com/panel/card_master/victory_title.png')
                elseif finalResult == 0 then
                    titleImage:setTexture('uires/ui_2nd/com/panel/card_master/draw_title.png')
                else
                    titleImage:setTexture('uires/ui_2nd/com/panel/card_master/failure_title.png')
                end
                titleImage:setAnchorPoint(ccp(0.5, 0))

                local scoreLb = tolua.cast(root:getChildByName('score_lb'), 'UILabel')
                scoreLb:setText(tostring(resTable.data.awards[1][3]))
            end)
            
            -- 猥琐的方式弹战斗结果界面：延迟1秒
            local arr = CCArray:create()
            arr:addObject(CCDelayTime:create(1))
            arr:addObject(CCCallFunc:create(function()
                CUIManager:GetInstance():ShowObject(resultSceneObj, ELF_SHOW.ZOOM_IN)
            end))
            playBtn:runAction(CCSequence:create(arr))
        end

        local cardData = resTable.data.card_master
        UserData:setCardMasterData(json.encode(cardData))
        playRound = playRound + 1
        local roundResult = cardData.result[tostring(selectCardIndex)]

        local movMyCard = CCMoveTo:create(0.2, myPos)

        local playing = CCCallFunc:create(function()
            local fadeIn = CCFadeIn:create(0.2)
            local turnFont = CCCallFunc:create(function()
                local enemyID = cardData.enemy_cards[tostring(selectCardIndex)]
                local arr = CCArray:create()
                arr:addObject(CCOrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0))
                arr:addObject(CCCallFunc:create(function()
                    enemyCardImage:setTexture(CARD_RES[enemyID])
                end))
                arr:addObject(CCOrbitCamera:create(0.2, 1, 0, 270, 90, 0, 0))
                local seq = CCSequence:create(arr)
                enemyCardImage:runAction(seq)
            end)
            local playEnd = CCCallFunc:create(function()
                local myArr = CCArray:create()
                local enmeyArr = CCArray:create()
                local prompt
                if roundResult == 1 then
                    myArr:addObject(CCDelayTime:create(0.5))
                    myArr:addObject(CCFadeOut:create(0.1))
                    enmeyArr:addObject(enemyCardFly())
                    prompt = CCCallFunc:create(function()
                        GameController.showPrompts(getLocalString('E_STR_CARD_MASTER_WIN'), COLOR_TYPE.GREEN)
                    end)
                elseif roundResult == -1 then
                    myArr:addObject(myCardFly())
                    enmeyArr:addObject(CCDelayTime:create(0.5))
                    enmeyArr:addObject(CCFadeOut:create(0.2))
                    enmeyArr:addObject(CCDelayTime:create(0.2))
                    prompt = CCCallFunc:create(function()
                        GameController.showPrompts(getLocalString('E_STR_CARD_MASTER_LOSE'), COLOR_TYPE.RED)
                    end)
                elseif roundResult == 0 then
                    myArr:addObject(myCardFly())
                    enmeyArr:addObject(enemyCardFly())
                    prompt = CCCallFunc:create(function()
                        GameController.showPrompts(getLocalString('E_STR_CARD_MASTER_DRAW'), COLOR_TYPE.WHITE)
                    end)
                end

                myCardPanels[selectCardIndex]:runAction(CCSequence:create(myArr))
                local arr2 = CCArray:create()
                enmeyArr:addObject(CCCallFunc:create(endOfEnemy))
                enmeyArr:addObject(prompt)
                enmeyArr:addObject(CCCallFunc:create(function()
                    enemyCardPanel:setOpacity(0)
                    endOfPlaying()
                end))
                enmeyArr:addObject(CCCallFunc:create(function()
                    selectCardIndex = 0
                end))
                enmeyArr:addObject(CCCallFunc:create(function()
                    roundIcon:setTexture(ROUND_RES[playRound + 1])
                end))
                enemyCardPanel:runAction(CCSequence:create(enmeyArr))
            end)

            local arr3 = CCArray:create()
            arr3:addObject(fadeIn)
            arr3:addObject(turnFont)
            arr3:addObject(CCDelayTime:create(1))
            arr3:addObject(playEnd)

            enemyCardPanel:runAction(CCSequence:create(arr3))
        end)

        local arr = CCArray:create()
        arr:addObject(movMyCard)
        -- arr:addObject(updateTitle)
        arr:addObject(playing)
        local seq = CCSequence:create(arr)
        myCardPanels[selectCardIndex]:runAction(seq)
    end

    -- Init
    panel:registerInitHandler(function()
        local root = panel:GetRawPanel()
        
        local closeBtn = tolua.cast(root:getChildByName('close_btn'), 'UIButton')
        closeBtn:registerScriptTapHandler(closePanel)
        GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)

        local helpBtn = tolua.cast(root:getChildByName('help_btn'), 'UIButton')
        helpBtn:registerScriptTapHandler(CardMaster.showHelpPanel)
        GameController.addButtonSound(helpBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)

        playBtn = tolua.cast(root:getChildByName('play_tx_btn'), 'UIButton')
        GameController.addButtonSound(playBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        playBtn:registerScriptTapHandler(function()
            if selectCardIndex <= 0 then
                GameController.showMessageBox(getLocalString('E_STR_TIPS_SELECT_A_CARD'), MESSAGE_BOX_TYPE.OK)
                return
            end

            for i = 1, 5 do
                myCardPanels[i]:setTouchEnable(false)
            end
            playBtn:disable()

            Message.sendPost('fight', 'cardmaster', json.encode({pos = selectCardIndex}), function( res )
                onFightResponse(res)
            end)
        end)

        roundIcon = tolua.cast(root:getChildByName('round_img_icon'), 'UIImageView')
        winLabel = tolua.cast(root:getChildByName('result_win_tx'), 'UILabel')
        drawLabel = tolua.cast(root:getChildByName('result_draw_tx'), 'UILabel')
        loseLabel = tolua.cast(root:getChildByName('result_lose_tx'), 'UILabel')

        enemyIcon = tolua.cast(root:getChildByName('enemy_icon'), 'UIImageView')
        enmeyName = tolua.cast(root:getChildByName('enemy_name_tx'), 'UILabel')
        local smallCardIcon = tolua.cast(root:getChildByName('small_card_icon') , 'UIImageView')
        smallCardIcon:setVisible(false)
        enmeyCardsNum = tolua.cast(root:getChildByName('enemy_card_count_tx'), 'UILabel')

        local cardBg = root:getChildByName('fight_bg')
        for i = 1, 5 do
            -- Init myCards
            local bg = cardBg:getChildByName(string.format("my_card_%d_img", i))
            local pos = bg:getPosition()
            local cardPl = UIPanel:create()
            local card = UIImageView:create()
            card:setTexture(CARD_BACK_RES)
            local sz = card:getContentSize()
            cardPl:setSize(sz)
            cardPl:setPosition(pos)
            card:setPosition(ccp(sz.width / 2, sz.height / 2))
            cardPl:addChild(card)
            cardPl:registerScriptTapHandler(function()
                onClickCard(i)
            end)
            bg:getWidgetParent():addChild(cardPl)
            myCardPanels[i] = cardPl
            myCardImages[i] = card

            local str = string.format("card_bg_%d", i)
            local stateBg = root:getChildByName(str)
            enmeyStates[i] = tolua.cast(stateBg:getChildByName('card_ball'), 'UIImageView')
        end

        enemyBg = cardBg:getChildByName('enemy_card_img')
        enemyCardImage = UIImageView:create()
        enemyCardImage:setTexture(CARD_BACK_RES)
        local sz = enemyCardImage:getContentSize()
        enemyCardImage:setPosition(ccp(sz.width / 2, sz.height / 2))
        enemyCardPanel = UIPanel:create()
        enemyCardPanel:setSize(sz)
        enemyCardPanel:addChild(enemyCardImage)
        enemyCardPanel:setPosition(enemyBg:getPosition())
        cardBg:addChild(enemyCardPanel)
        enemyCardPanel:setOpacity(0)

        initBattle()
        updateBattle()
    end)

    panel:registerOnShowHandler(function()
    end)

    panel:registerOnHideHandler(function()
        CardMaster.hideHelpPanel()
    end)

    CUIManager:GetInstance():ShowObject(sceneObj, ELF_SHOW.SLIDE_IN)
end
