DiscountShop = {
	
}

function DiscountShop.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	table.foreach(data , function (_ , v)
		if v['Key'] == 'discountshop' then
			conf = v
		end
	end)

	if conf == nil then
		return true
	end

	if tonumber(conf.Normalization) == 0 then -- 非常态活动

		local actyStartTime
        local actyEndTime
        if conf.StartTime ~= nil and conf.StartTime ~= '' then -- 优先判断StartTime字段
            actyStartTime = UserData:convertTime(1, conf.StartTime)
            actyEndTime   = UserData:convertTime(1, conf.EndTime) + (tonumber(conf.DelayDays))*86400 -- 加上奖励的领取延时1天 这两天充值元宝不计
        else
            local serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
            actyStartTime = serverOpenTime + (tonumber(conf.OpenDay) - 1)*86400
            actyEndTime = serverOpenTime + (tonumber(conf.OpenDay) + tonumber(conf.Duration) - 1)*86400
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

function DiscountShop.Enter()
	-- UI
	local sceneObj
	local panel
	local heidianScene
	local heidianPanel
	local cardSv
	local cashTx
	local souls = {}
	local lights = {}

	local discountConf = GameData:getArrayData('discountshop.dat') -- 特惠商店
	local discountData = {}
	local timeCDTx

	local function getPos(i)
		local x = 10 + 290 * ((i-1)%3)
		local y = 0 - ((i-1) - (i-1)%3)/3*150
		return ccp(x,y)
	end

	local function soulSetVisible(i,cardImg)
		if not souls[i] then
			local pSoul = CUIEffect:create()
			pSoul:Show( 'soul' , 0)
			cardImg:getContainerNode():addChild(pSoul)
			table.insert(souls,i)
			souls[i] = pSoul
		end
	end

	local function lightSetVisible(i,cardImg)
		if not lights[i] then
			local light = CUIEffect:create()
			light:Show("yellow_light", 0)
			light:setScale(0.81)
			light:setPosition( ccp(0, 0))
			light:setAnchorPoint(ccp(0.5, 0.5))
			cardImg:getContainerNode():addChild(light)
			light:setZOrder(100)
			table.insert(lights,i)
			lights[i] = light
		end
	end

	local function updateCellPanel(i,view)
		cashTx:setText(toWordsNumber(PlayerCoreData.getCashValue()))

		local frameImg = tolua.cast(view:getChildByName('fram_img') , 'UIImageView')
		local photoIco = tolua.cast(view:getChildByName('photo_ico') , 'UIImageView')
		local numTx = tolua.cast(view:getChildByName('num_tx') , 'UILabel')
		local nameTx = tolua.cast(view:getChildByName('name_tx') , 'UILabel')
		local priceTx = tolua.cast(view:getChildByName('price_tx') , 'UILabel')
		local typeImg = tolua.cast(view:getChildByName('type_img') , 'UIImageView')
		local discountImg = tolua.cast(view:getChildByName('discount_img') , 'UIImageView')

		local data = discountData.discount_shop.count[tostring(i)] or 0
		local tab = discountConf[i]
		local award = UserData:getAward(tab.Award1)

		frameImg:setTexture('uires/ui_2nd/com/panel/common/frame.png')
		typeImg:setTexture('uires/ui_2nd/com/panel/common/cash_icon.png')
		lightSetVisible(i,frameImg)
		lights[i]:setVisible(false)
		local color = tab.Color or 'blue'
		if tostring(color) == 'sred' then
			frameImg:setTexture('uires/ui_2nd/com/panel/common/frame_sred.png')
			lights[i]:setVisible(true)
		elseif tostring(color) == 'red' then
			frameImg:setTexture('uires/ui_2nd/com/panel/common/frame_red.png')
			lights[i]:setVisible(false)
		elseif tostring(color) == 'yellow' then
			frameImg:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
			lights[i]:setVisible(false)
		elseif tostring(color) == 'purple' then
			frameImg:setTexture('uires/ui_2nd/com/panel/common/frame_purple.png')
			lights[i]:setVisible(false)
		end

		nameTx:setText(award.name)
		nameTx:setColor(award.color)
		numTx:setText(toWordsNumber(tonumber(award.count)))
		local nowPrice = 0
		local discount = 9
		if not tab['Cash'..tonumber(data)+1] then
			nowPrice = tonumber(tab['Max'])
			discount = math.ceil(tonumber(tab['Max']) / tonumber(tab.Sell) * 10)
		else
			nowPrice = tonumber(tab['Cash'..tonumber(data)+1])
			discount = math.ceil(tab['Cash'..tonumber(data)+1] / tonumber(tab.Sell) * 10)
		end
		priceTx:setText(toWordsNumber(nowPrice))
		if discount >= 1 and discount <= 9 then
			discountStr = 'uires/ui_2nd/com/panel/shop/discount_'..discount..'.png'
			discountImg:setVisible(true)
			discountImg:setTexture(discountStr)
		else
			discountImg:setVisible(false)
		end

		photoIco:setTouchEnable(true)
		photoIco:setTexture(award.icon)
		photoIco:registerScriptTapHandler(function()
			UISvr:showTipsForAward(tab.Award1)
		end)

		local buyBtn = tolua.cast(view:getChildByName('buy_btn') , 'UITextButton')
		buyBtn:registerScriptTapHandler(function()
			local myCash = PlayerCoreData.getCashValue()
			if myCash < nowPrice then
				GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'), COLOR_TYPE.RED)
				return
			end
			args = {
				id = tonumber(tab.Id)
			}
			Message.sendPost('buy_discount_shop','activity',json.encode(args),function (jsonData)
				print(jsonData)
				local jsonDic = json.decode(jsonData)
				local awards = jsonDic.data.awards
				if tonumber(jsonDic.code) == 0 then
					if tab['Cash'..tonumber(data)+1] then
						if discountData.discount_shop.count[tostring(i)] then
							discountData.discount_shop.count[tostring(i)] = discountData.discount_shop.count[tostring(i)] + 1
						else
							discountData.discount_shop.count[tostring(i)] = 1
						end
					end
					UserData.parseAwardJson(json.encode(awards))
					updateCellPanel(i,view)
					GameController.showPrompts(string.format(getLocalStringValue('E_STR_YOUR_GAIN_MATERIAL'),tonumber(award.count),award.name), COLOR_TYPE.GREEN)
				else
					GameController.showPrompts(getLocalStringValue('E_STR_SHOP_DATA_ERR'))
					Message.sendPost('get_discount_shop','activity','{}',function (jsonData)
						print(jsonData)
						local jsonDic = json.decode(jsonData)
						if tonumber(jsonDic.code) == 0 then
							discountData = jsonDic.data
							updateCellPanel(i,view)
						end
					end)
				end
			end)
		end)
		GameController.addButtonSound(buyBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
	end

	local function createCellPanel()
		for i=1,#discountConf do
			local view = createWidgetByName('panel/shop_discount_cell.json')
			updateCellPanel(i,view)
			cardSv:addChildToBottom(view)
			view:setPosition(getPos(i))
		end
		cardSv:scrollToTop()
	end

	local function updatePanel()
		-- body
		createCellPanel()
	end
	local function init()
		root = panel:GetRawPanel()
    	closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		helpBtn = tolua.cast(root:getChildByName('help_btn') , 'UIButton')
    	helpBtn:registerScriptTapHandler(function ()
			-- createShopHelpPanel()
			helpScene = SceneObjEx:createObj('panel/shop_discount_help_panel.json' , 'discount-shop-help-in-lua')
			helpPanel = helpScene:getPanelObj()
			helpPanel:setAdaptInfo('help_bg_img' , 'help_img')
			helpPanel:registerInitHandler(function ()
				-- inithelp
				local root = helpPanel:GetRawPanel()
				closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
		    	closeBtn:registerScriptTapHandler(function ()
					CUIManager:GetInstance():HideObject(helpScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
				end)
				GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

				helpBgImg = tolua.cast(root:getChildByName('help_bg_img') , 'UIButton')
		    	helpBgImg:registerScriptTapHandler(function ()
					CUIManager:GetInstance():HideObject(helpScene, ELF_HIDE.ZOOM_OUT_FADE_OUT)
				end)

				-- local knowBtn = tolua.cast(root:getChildByName('ok_btn'), 'UITextButton')
		  --       GameController.addButtonSound(knowBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
				-- knowBtn:registerScriptTapHandler(function()
				-- 	CUIManager:GetInstance():HideObject(helpScene, ELF_HIDE.SMART_HIDE)
				-- end)

				-- local sv = tolua.cast(root:getChildByName('system_sv'), 'UIScrollView')
				local infoTx1 = tolua.cast(root:getChildByName('info_1_tx'), 'UILabel')
				infoTx1:setText(getLocalStringValue('E_STR_DISCOUNT_SHOP_HELP_DESC1'))
				infoTx1:setPreferredSize(590,1)
				local infoTx2 = tolua.cast(root:getChildByName('info_2_tx'), 'UILabel')
				infoTx2:setText(getLocalStringValue('E_STR_DISCOUNT_SHOP_HELP_DESC2'))
				infoTx2:setPreferredSize(590,1)
				local infoTx3 = tolua.cast(root:getChildByName('info_3_tx'), 'UILabel')
				infoTx3:setText(getLocalStringValue('E_STR_DISCOUNT_SHOP_HELP_DESC3'))
				infoTx3:setPreferredSize(590,1)
				local infoTx4 = tolua.cast(root:getChildByName('info_4_tx'), 'UILabel')
				infoTx4:setText(getLocalStringValue('E_STR_DISCOUNT_SHOP_HELP_DESC4'))
				infoTx4:setPreferredSize(590,1)
				local infoTx5 = tolua.cast(root:getChildByName('info_5_tx'), 'UILabel')
				infoTx5:setText(getLocalStringValue('E_STR_DISCOUNT_SHOP_HELP_DESC5'))
				infoTx5:setPreferredSize(590,1)
			end)
			UiMan.show(helpScene)
		end)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		cardSv = tolua.cast(root:getChildByName('card_sv') , 'UIScrollView')
		cardSv:setClippingEnable(true)
		cashTx = tolua.cast(root:getChildByName('cash_tx') , 'UILabel')
		timeTx = tolua.cast(root:getChildByName('time_tx') , 'UILabel')
		timeTx:setText('')
		timeCDTx = UICDLabel:create()
		timeCDTx:setFontSize(22)
		timeCDTx:setPosition(ccp(5,0))
		timeCDTx:setFontColor(ccc3(50, 240, 50))
		timeCDTx:setAnchorPoint(ccp(0,0.5))
		timeTx:addChild(timeCDTx)

		local data = GameData:getArrayData('activities.dat')
		table.foreach(data , function (_ , v)
			if v['Key'] == 'discountshop' then
				conf = v
			end
		end)

		timeCDTx:registerTimeoutHandler(function ()
			CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)

		local timeDiff = 1
		if conf ~= nil then
			actyStartTime = UserData:convertTime(1, conf.StartTime)
			nowTime = UserData:getServerTime()
            actyEndTime   = UserData:convertTime(1, conf.EndTime)
            timeDiff = actyEndTime - nowTime
		end
		timeCDTx:setTime(timeDiff)

		updatePanel()
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/shop_discount_panel.json', 'shop-discpont-panel-lua')
	    panel = sceneObj:getPanelObj()
	    panel:setAdaptInfo('shop_bg_img', 'shop_img')

		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end

	Message.sendPost('get_discount_shop','activity','{}',function (jsonData)
		cclog(jsonData)
		local jsonDic = json.decode(jsonData)
		if tonumber(jsonDic.code) == 0 then
			discountData = jsonDic.data
			createPanel()
		end
	end)
end