require 'ceremony/panel/exchange_cdkey'

local function onClickCdkey()
    genExchangeCDKeyPanel()
end

local function onFeedbackSent()
	GameController.showPrompts(getLocalStringValue("E_STR_FEEDBACK_SENT"), COLOR_TYPE.WHITE)
end

local musicSlider
local musicLabel
local soundSlider
local soundLabel 

local function updateSlider()
   local percent = GameController.getBGMVolume()
   musicSlider:setSlidBallPercent(percent * 100)
   musicSlider:setProgressBarScale(percent * 100)
   musicLabel:setText(string.format('%d', percent * 100))
   musicLabel:setColor(ccc3(26, 72, 189))

   percent = GameController.SoundVolume()
   soundSlider:setSlidBallPercent(percent * 100)
   soundSlider:setProgressBarScale(percent * 100)
   soundLabel:setText(string.format('%d', percent * 100))
   soundLabel:setColor(ccc3(26, 72, 189))
end

local function onChangeMusicEvent()
	local percent = musicSlider:getPercent();
	if percent > 100 then
 			percent = 100
	elseif percent < 0 then
		percent = 0
	end
	musicSlider:setSlidBallPercent(percent)
	musicSlider:setProgressBarScale(percent)
	musicLabel:setTextFromInt(percent)
	musicLabel:setColor(ccc3(26, 72, 189))         
	GameController.setBGMVolume(percent/100.0)
end

local function onChangeSoundEvent()
	local percent = soundSlider:getPercent()
	if percent > 100 then
		percent = 100
	elseif percent < 0 then
		percent = 0
	end
	soundSlider:setSlidBallPercent(percent)
    soundSlider:setProgressBarScale(percent)
    soundLabel:setTextFromInt(percent)
    soundLabel:setColor(ccc3(26, 72, 189))
    GameController.setSoundVolume(percent/100.0)
end

local function genViewUpdater(panel, setting)
	return function() 
		local root = panel:GetRawPanel()
        local systemBgImg = tolua.cast(root:getChildByName('system_seting_img'), 'UIImageView')
        local systemImg = tolua.cast(systemBgImg:getChildByName('system_main_img'), 'UIImageView')

        local titleBgImg = tolua.cast(systemImg:getChildByName('title_ico'), 'UIImageView')
		local titleTx = tolua.cast(titleBgImg:getChildByName('title_txt_tx'), 'UILabel')
		titleTx:setText(getLocalStringValue('E_STR_SYSTEM'))

		local closeBtn = tolua.cast(titleBgImg:getChildByName('close_btn'), 'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(setting, ELF_HIDE.SMART_HIDE)
		end)

        local settingPl = tolua.cast(systemImg:getChildByName('system_seting_pl'), 'UIPanel')
        settingPl:setVisible(true)
        local bugPl = tolua.cast(systemImg:getChildByName('bug_pl'), 'UIPanel')
        bugPl:setVisible(false)
        -- local bug_info_tx = tolua.cast(bugPl:getChildByName('bug_info_tx'), 'UILabel')
        -- bug_info_tx:setFontSize(30)
        -- bug_info_tx:setPreferredSize(550,0)
        

        local soundBgImg = tolua.cast(settingPl:getChildByName('system_sound_bg_img'), 'UIImageView')

        musicSlider = tolua.cast(soundBgImg:getChildByName('music_slider'), 'UISlider')
        musicSlider:setShowProgressBar(true)
        musicSlider:setProgressBarTextureScale9("uires/ui_2nd/com/panel/systemseting/system_sound_exp.png", 0, 0, 65, 28)
        musicSlider:setSlidBallPercent(100)
        musicSlider:setProgressBarScale(100)
        musicSlider:addPercentChangedScriptHandler(onChangeMusicEvent)

        musicLabel = tolua.cast(soundBgImg:getChildByName('sound_tx'), 'UILabel')
        musicLabel:setTextFromInt(musicSlider:getPercent())
        musicLabel:setColor(ccc3(26, 72, 189))  
        
        soundSlider = tolua.cast(soundBgImg:getChildByName('sound_slider'), 'UISlider')
        soundSlider:setShowProgressBar(true)
        soundSlider:setProgressBarTextureScale9("uires/ui_2nd/com/panel/systemseting/system_sound_exp.png", 0, 0, 65, 28)
        soundSlider:setSlidBallPercent(100)
        soundSlider:setProgressBarScale(100)
        soundSlider:addPercentChangedScriptHandler(onChangeSoundEvent)

        soundLabel = tolua.cast(soundBgImg:getChildByName('vox_tx'), 'UILabel')
        soundLabel:setTextFromInt(soundSlider:getPercent())
        soundLabel:setColor(ccc3(26, 72, 189))
        
        local bugfeedbackBtn = tolua.cast(settingPl:getChildByName('bug_feedback_btn'), 'UITextButton')
        GameController.addButtonSound(bugfeedbackBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        bugfeedbackBtn:registerScriptTapHandler(function ()
        	settingPl:setVisible(false)
        	titleTx:setText(getLocalStringValue('E_STR_SETTING_TITLE'))
        	bugPl:setVisible(true)
        end)

        local cdkeyBtn = tolua.cast(settingPl:getChildByName('back_btn'), 'UITextButton')
        GameController.addButtonSound(cdkeyBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        cdkeyBtn:registerScriptTapHandler(onClickCdkey)
      
      	local bugBgImg = tolua.cast(bugPl:getChildByName('bug_bg_ico'), 'UIImageView')
        local infoSv = tolua.cast(bugBgImg:getChildByName('info_sv'), 'UIScrollView')
        local infoTx = tolua.cast(bugBgImg:getChildByName('info_tx'), 'UILabel')
        infoSv:setClippingEnable(true)
        infoSv:scrollToTop()
        infoTx:setText(getLocalStringValue('E_STR_SETTING_INFO'))
        infoTx:setFontSize(20)
        infoTx:setPreferredSize(540,1)
        -- local editBox = tolua.cast(UISvr:replaceUIImageViewByCCEditBox(bugBgImg) , 'CCEditBox')
        -- editBox:setFontSize(30)
        -- editBox:setFontName('Arial')
        -- editBox:setHAlignment(kCCTextAlignmentLeft)
        -- editBox:setVAlignment(kCCVerticalTextAlignmentTop)
        -- editBox:setInputMode(kEditBoxInputModeEmailAddr) 

        local sendBtn = tolua.cast(bugPl:getChildByName('send_btn'), 'UIButton')
        local btnTx = tolua.cast(sendBtn:getChildByName('btn_tx'), 'UILabel')
        btnTx:setText(getLocalStringValue('E_STR_SETTING_BUT_TX'))
        GameController.addButtonSound(sendBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
        sendBtn:registerScriptTapHandler(function()
        	CUIManager:GetInstance():HideObject(setting, ELF_HIDE.SMART_HIDE)
            local sendStr = string.format(getLocalStringValue('E_STR_SENDTO_LINE'), tostring(PlayerCoreData.getPlayerName()), tostring(PlayerCoreData.getOpenID()))
            local url = 'http://line.me/R/msg/text/?' .. sendStr
            -- Third:Inst():openUrl(url)
        	-- local content = editBox:getText() 
        	-- Message.requestFeedBackPost(content, onFeedbackSent)
        end)

        updateSlider()
	end
end

local function onShow()
    updateSlider()
end

function genSettingPanel()
    local setting = SceneObjEx:createObj('panel/system_seting_zh_panel.json', 'system-seting-lua')

    local panel = setting:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('system_seting_img', 'system_main_img')
    local viewUpdater = genViewUpdater(panel, setting)

	panel:registerInitHandler(function()
		viewUpdater()
	end)
    	
    panel:registerOnShowHandler(onShow)
    panel:registerOnHideHandler(function()
        local bgmPercent = GameController.getBGMVolume()
        local soundPercent = GameController.SoundVolume()
        local percent = bgmPercent .. '|' .. soundPercent
        CCUserDefault:sharedUserDefault():setStringForKey('gameSoundPercent', percent)
    end)
    -- Show now
    CUIManager:GetInstance():ShowObject(setting, ELF_SHOW.SMART)
end
