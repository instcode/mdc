
function genFirstPayPanel()
	-- UI
	local firstPayImg
	local awardBtn
	local payBtn

	local MAX_AWARD_COUNT = 5

	local function onClickAwardCallbacks(jsonData)
		local resData = json.decode(jsonData)
        local code = tonumber(resData.code)
        if code == 0 then
        	local data = resData.data
            if data then
            	local awards = data.awards
                if awards then
                    UserData.parseAwardJson(json.encode(awards))
                    GameController.showPrompts(getLocalStringValue('E_STR_GET_SUCCEED'), COLOR_TYPE.GREEN)
                end
	    		awardBtn:setPressState(WidgetStateDisabled)
	    		awardBtn:setTouchEnable(false)
	    		PlayerCoreData.setFirstPay(2)
            end
        end
	end

	local function checkFirstPay()
    	local flag = PlayerCoreData.getFirstPay()
    	if flag == 0 then              -- Need to recharge first
    		awardBtn:setVisible(false)
    		payBtn:setVisible(true)
    	elseif flag == 1 then          -- Claim rewards
    		awardBtn:setVisible(true)
    		payBtn:setVisible(false)
    	elseif flag == 2 then          -- Already claimed
    		awardBtn:setVisible(true)
    		payBtn:setVisible(false)
    		awardBtn:setPressState(WidgetStateDisabled)
    		awardBtn:setTouchEnable(false)
    	end
    end

	local function setAward()
		local firstPayConf = GameData:getArrayData('firstpayaward.dat')
		for i = 1, MAX_AWARD_COUNT do
			local awardName = 'award_frame_' .. tostring(i)
			local awardFrame = tolua.cast(firstPayImg:getChildByName(awardName),'UIImageView')
			local awardIco = tolua.cast(awardFrame:getChildByName('award_ico'),'UIImageView')
			local awardName = tolua.cast(awardFrame:getChildByName('name_tx'),'UILabel')
			local awardNum = tolua.cast(awardFrame:getChildByName('num_tx'),'UILabel')
			local awardIndex = 'Award' .. tostring(i)
			local awardStr = firstPayConf[1][awardIndex]
			local awardData = UserData:getAward(awardStr)
			awardIco:setTexture(awardData.icon)
			awardFrame:registerScriptTapHandler( function()
				UISvr:showTipsForAward(awardStr)
			end )
			awardName:setPreferredSize(150,1)

			awardName:setText(GetTextForCfg(awardData.name))
			awardNum:setText(tostring(awardData.count))

			-- 如果奖励是S將
			if awardData.type == 'card' then
				local roleCard = PlayerCoreData.getRoleCardById(awardData.id)
				if roleCard then
					if ROLE_QUALITY.SRED == roleCard:GetRoleQuality() then
						awardFrame:setTexture(roleCard:GetIconFrame())
						local light = CUIEffect:create()
						light:Show("yellow_light", 0)
						light:setScale(0.8)
						light:setPosition( ccp(0, 0))
						light:setAnchorPoint(ccp(0.5, 0.5))
						awardFrame:getContainerNode():addChild(light)
						light:setZOrder(100)
					end
				end
			end
		end
	end

	local firstPay = SceneObjEx:createObj('panel/first_pay_award_panel.json', 'first-pay-lua')
    local panel = firstPay:getPanelObj()
    panel:setAdaptInfo('first_pay_bg_img', 'first_pay_img')

    -- init
    panel:registerInitHandler(function ()
    	local root = panel:GetRawPanel()
		local firstPayBgImg = tolua.cast(root:getChildByName('first_pay_bg_img'),'UIImageView')
		firstPayImg = tolua.cast(firstPayBgImg:getChildByName('first_pay_img'),'UIImageView')
		panel:registerScriptTapHandler('close_btn', UiMan.genCloseHandler(firstPay))

		local closeBtn = tolua.cast(firstPayImg:getChildByName('close_btn'),'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(firstPay))
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		awardBtn = tolua.cast(firstPayImg:getChildByName('award_btn'),'UITextButton')
		awardBtn:registerScriptTapHandler(function()
	        Message.sendPost('get_first_pay_reward','activity','{}',onClickAwardCallbacks)
		end)
		GameController.addButtonSound(awardBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		awardBtn:setVisible(false)

		payBtn = tolua.cast(firstPayImg:getChildByName('pay_btn'),'UITextButton')
		payBtn:registerScriptTapHandler(genCashBoard)
		GameController.addButtonSound(payBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)

		local infoTx4 = tolua.cast(firstPayImg:getChildByName('info_tx_4'),'UILabel')
		infoTx4:setColor(ccc3(183,180,180))

		setAward()
		checkFirstPay()
    end)

	-- onShow
    panel:registerOnShowHandler(function()
    end)

    -- onHide
    panel:registerOnHideHandler(function()
    end)

    panel:registerForceUpdateHandler(checkFirstPay)

    -- Show now
    UiMan.show(firstPay)
end