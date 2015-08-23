function genExchangeCDKeyPanel()
	-- UI
	local cdkey
	local editBox

	-- 兑换cdkey回调
	local function onClickExchangeResponse(jsonData)
		local resData = json.decode(jsonData)
        local code = tonumber(resData.code)
        if code == 0 then
        	local data = resData.data
            local got = data.got
            if got then
                GameController.showPrompts(getLocalString('E_STR_GOT_CDKEY'), COLOR_TYPE.RED)
                CUIManager:GetInstance():HideObject(cdkey, ELF_HIDE.SMART_HIDE)
            else
        		local awards = data.awards
            	if awards then
            		local msgArr = {}
                    for k,v in pairs(awards) do
                        if v[1] ~= 'equip' then
                            local vStr = v[1] .. '.' .. v[2] .. ':' .. v[3]             -- 改成类似user.cash:10的形式
                            local award = UserData:getAward(vStr)
                			local awardname = award.name .. ' X' .. award.count
                			local msgText = string.format(getLocalString('E_STR_GAIN_ANYTHING'),awardname)
                            table.insert(msgArr,msgText)

                        else
                            local Str
                            local equipConf = GameData:getArrayData('equip.dat')
                            print(type(equipConf))
                            for i,j in ipairs(equipConf) do
                                if j.Level == tostring(v[3].level) and v[3].type == 'armor' then
                                    Str = GetTextForCfg(j.ArmorName) .. ' X1'
                                elseif j.Level == tostring(v[3].level) and v[3].type == 'weapon' then
                                    Str = GetTextForCfg(j.WeaponName) .. ' x1'
                                elseif j.Level == tostring(v[3].level) and v[3].type == 'magic' then
                                    Str = GetTextForCfg(j.MagicName) .. ' x1'
                                elseif j.Level == tostring(v[3].level) and v[3].type == 'accessory' then
                                    Str = GetTextForCfg(j.AccessoryName) .. ' x1'
                                end

                            end
                            local msgText = string.format(getLocalString('E_STR_GAIN_ANYTHING'),Str)
                            table.insert(msgArr,msgText)
                        end
                    end
                    UserData.parseAwardJson(json.encode(awards))
                    GameController.showPrompts(msgArr)
                end
               	CUIManager:GetInstance():HideObject(cdkey, ELF_HIDE.SMART_HIDE)
            end
        else
        	GameController.showPrompts(getLocalString('E_STR_CDKEY_NOT_EXIST'), COLOR_TYPE.RED)	-- cdkey格式不对
        end
	end

	-- 点击兑换cdkey
	local function onClickExchange()
		local content = editBox:getText()
		local str = string.gsub(content,'%s','')
		if str == '' then
			GameController.showPrompts(getLocalString('E_STR_CDKEY_INFO'), COLOR_TYPE.RED)	-- cdkey为空
			return
		end
        local cdkey = UserData:getExchangeCDKey(content)
        if cdkey == "" then
        	return
        end
        local cdkeyArr = string.split(cdkey, '|')
        if tonumber(cdkeyArr[1]) == 0 then
        	local exchange_cdkey = {
	        	reward = cdkeyArr[2],
	        	id = cdkeyArr[3],
	        	key = cdkeyArr[4]
	        }
        	Message.sendPost('exchange_cdkey','user',json.encode(exchange_cdkey),onClickExchangeResponse)
        else
        	GameController.showPrompts(getLocalString('E_STR_CDKEY_NOT_EXIST'), COLOR_TYPE.RED)	-- cdkey格式不对
        end
	end

    cdkey = SceneObjEx:createObj('panel/cdkey_panel.json', 'cdkey-lua')
    local panel = cdkey:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('cdkey_bg_img', 'cdkey_img')

	-- init
    panel:registerInitHandler(function ()
    	local root = panel:GetRawPanel()
		local cdkeyBgImg = tolua.cast(root:getChildByName('cdkey_bg_img'),'UIImageView')
		cdkeyImg = tolua.cast(cdkeyBgImg:getChildByName('vip_img'),'UIImageView')

		local okBtn = tolua.cast(cdkeyBgImg:getChildByName('ok_btn'),'UIButton')
		GameController.addButtonSound(okBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		okBtn:registerScriptTapHandler(onClickExchange)

		local closeBtn = tolua.cast(cdkeyBgImg:getChildByName('close_btn'),'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(cdkey, ELF_HIDE.SMART_HIDE)
		end)

		local inputTextImg = tolua.cast(cdkeyBgImg:getChildByName('print_bg_ico'),'UIImageView')
		editBox = tolua.cast(UISvr:replaceUIImageViewByCCEditBox(inputTextImg) , 'CCEditBox')
        editBox:setHAlignment(kCCTextAlignmentLeft)
		editBox:setInputMode(kEditBoxInputModeSingleLine)
        editBox:setFontSize(24)
        editBox:registerScriptEditBoxHandler( function (eventType)
        if eventType == 'ended' then
            editBox:setFontColor(COLOR_TYPE.LIGHT_GREEN)
        elseif eventType == 'began' then
            editBox:setFontColor(COLOR_TYPE.BLACK)
        end
    end)

    end)

    -- onShow
    panel:registerOnShowHandler(function ()
    end)

    -- onHide
    panel:registerOnHideHandler(function ()
    end)
    
    -- Show now
    CUIManager:GetInstance():ShowObject(cdkey, ELF_SHOW.SMART)
end