-- 显示神将放送的礼包panel
local function genGiveGodAwardPanel()
	-- 配置文件
	local giveGodAwardConf
	local giveheroConf

	-- 神将放送数据
	local giveGodData

	-- 数组
	local awardBtnType = {}
	local awardBtnArr = {}
	local timeTxArr = {}
	local leftTimeLabelArr = {}
	local infoTxArr = {}
	local itemPhotoIcoArr = {}

	local function setAwardBtnType()
		for i = 1, 3 do
			if tonumber(giveGodData.status[i]) == 0 then
				awardBtnType[i] = 0
			elseif tonumber(giveGodData.status[i]) == 1 then
				if tonumber(giveGodData.got_reward[i]) == 0 then
					awardBtnType[i] = 1
				else
					awardBtnType[i] = 2
				end
			end
		end
	end

	local function upDatePanel()
		setAwardBtnType()
		local roleCard = Role.getDataById(giveheroConf[1].GodRid)
		
		local itemPohtoIndex = 0
		for i = 1, 3 do
			local time = UserData:getServerTime() - PlayerCoreData.getCreatePlayerTime()
			local leftTime = tonumber(giveGodAwardConf[i].AccountCreateTimePass) - time
			if leftTime < 0 then
				leftTime = 0
				timeTxArr[i]:setVisible(false)
			end
			leftTimeLabelArr[i]:setTime(leftTime)
			leftTimeLabelArr[i]:setFontColor(ccc3(255,255,204))
			local day = tonumber(giveGodAwardConf[i].AccountCreateTimePass)/3600/24
			local level = 0
			local info
			local status
			if tonumber(giveGodAwardConf[i].RoleLevelLimit) == 0 then
				level = tonumber(giveGodAwardConf[i].SoldierLevelLimit)
				info = getLocalStringValue('E_STR_GET_GOD_ROLE_LIMIT_TWO')
			else
				level = tonumber(giveGodAwardConf[i].RoleLevelLimit)
				info = getLocalStringValue('E_STR_GET_GOD_ROLE_LIMIT_ONE')
			end
			if tonumber(giveGodData.status[i]) == 0 then
				if leftTime == 0 then
					status = getLocalStringValue('E_STR_GET_GOD_ROLE_FALIUE')
				else
					status = getLocalStringValue('E_STR_GOD_ROLE_ING')
				end
			elseif tonumber(giveGodData.status[i]) == 1 then
				status = getLocalStringValue('E_STR_GOD_ROLE_OVER')
			end
			local strBuff = string.format(info, day, GetTextForCfg(roleCard.Name), level, status)
			infoTxArr[i]:setText(strBuff)

			for j = 1, 4 do
				itemPohtoIndex = itemPohtoIndex + 1
				local award = UserData:getAward(giveGodAwardConf[i]['Award' .. j])
				local itemIco = tolua.cast(itemPhotoIcoArr[itemPohtoIndex]:getChildByName('item_ico'),'UIImageView')
				local itemNameTx = tolua.cast(itemPhotoIcoArr[itemPohtoIndex]:getChildByName('item_name_tx'),'UILabel')
				local itemNumTx = tolua.cast(itemPhotoIcoArr[itemPohtoIndex]:getChildByName('item_num_tx'),'UILabel')
				itemNameTx:setText(GetTextForCfg(award.name))
				itemNameTx:setColor(award.color)
				itemNumTx:setText(toWordsNumber(tonumber(award.count)))
				itemIco:setTexture(award.icon)
				if award.color.r == COLOR_TYPE.RED.r and award.color.g == COLOR_TYPE.RED.g and award.color.b == COLOR_TYPE.RED.b then
					itemPhotoIcoArr[itemPohtoIndex]:setTexture('uires/ui_2nd/com/panel/common/frame_red.png')
				elseif award.color.r == COLOR_TYPE.WHITE.r and award.color.g == COLOR_TYPE.WHITE.g and award.color.b == COLOR_TYPE.WHITE.b then
					itemPhotoIcoArr[itemPohtoIndex]:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
				elseif award.color.r == COLOR_TYPE.PURPLE.r and award.color.g == COLOR_TYPE.PURPLE.g and award.color.b == COLOR_TYPE.PURPLE.b then
					itemPhotoIcoArr[itemPohtoIndex]:setTexture('uires/ui_2nd/com/panel/common/frame_purple.png')
				elseif award.color.r == COLOR_TYPE.ORANGE.r and award.color.g == COLOR_TYPE.ORANGE.g and award.color.b == COLOR_TYPE.ORANGE.b then
					itemPhotoIcoArr[itemPohtoIndex]:setTexture('uires/ui_2nd/com/panel/common/frame_yellow.png')
				end
			end

			if awardBtnType[i] == 0 then
				awardBtnArr[i]:setText(getLocalStringValue('LS_CLAIM_REWARD'))
				awardBtnArr[i]:setTouchEnable(false)
				awardBtnArr[i]:setNormalButtonGray(true)
			elseif awardBtnType[i] == 1 then
				awardBtnArr[i]:setText(getLocalStringValue('LS_CLAIM_REWARD'))
				awardBtnArr[i]:setTouchEnable(true)
				awardBtnArr[i]:setNormalButtonGray(false)
			elseif awardBtnType[i] == 2 then
				awardBtnArr[i]:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
				awardBtnArr[i]:setTouchEnable(false)
				awardBtnArr[i]:setNormalButtonGray(true)
			end
		end
	end

	local function getAwardResponse(jsonData)
		local response = json.decode(jsonData)
		local code = tonumber(response.code)
		if code == 0 then
			giveGodData = response.data.god
			setGodData(response.data.god)
			local awards = response.data.awards
			local awardStr = json.encode(awards)
			UserData.parseAwardJson(awardStr)
			GameController.showPrompts(getLocalStringValue('E_STR_REWARD_SUCCEED'), COLOR_TYPE.GREEN)
			upDatePanel()
		end
	end

	local giveGodAward = SceneObjEx:createObj('panel/god_role_award_panel.json', 'god-role-award-lua')
    local panel = giveGodAward:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('god_role_award_bg_img', 'god_role_award_img')

    -- init
    panel:registerInitHandler(function ()
    	giveGodAwardConf = GameData:getArrayData('god.dat')
    	giveheroConf = GameData:getArrayData('givehero.dat')
		giveGodData = getGiveGodData()

		local root = panel:GetRawPanel()
		local godRoleAwardBgImg = tolua.cast(root:getChildByName('god_role_award_bg_img'),'UIImageView')
		local godRoleAwardImg = tolua.cast(godRoleAwardBgImg:getChildByName('god_role_award_img'),'UIImageView')
		local titleIco = tolua.cast(godRoleAwardImg:getChildByName('title_ico'),'UIImageView')
		local closeBtn = tolua.cast(titleIco:getChildByName('close_btn'),'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(giveGodAward, ELF_HIDE.SMART_HIDE)
		end)

		for i = 1, 3 do
			local strBuff = 'card_' .. i .. '_ico'
			local cardIco = tolua.cast(godRoleAwardImg:getChildByName(strBuff),'UIImageView')
			local infoTx = tolua.cast(cardIco:getChildByName('info_tx'),'UILabel')
			table.insert(infoTxArr, infoTx)
			local getAwrardBtn = tolua.cast(cardIco:getChildByName('get_awrard_btn'),'UITextButton')
			GameController.addButtonSound(getAwrardBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
			getAwrardBtn:registerScriptTapHandler(function ()
				if awardBtnType[i] == 1 then
					local pJson = {
					    id = i
					}
					Message.sendPost('get_reward','god',json.encode(pJson),getAwardResponse)
				end
			end)
			table.insert(awardBtnArr, getAwrardBtn)
			local timeTx = tolua.cast(cardIco:getChildByName('time_tx'),'UILabel')
			local leftTimeLabel = UICDLabel:create()
			leftTimeLabel:setFontSize(25)
			leftTimeLabel:setFontColor(COLOR_TYPE.WHITE)
			leftTimeLabel:setPosition(ccp(80, 0))
			timeTx:addChild(leftTimeLabel)
			table.insert(timeTxArr, timeTx)
			table.insert(leftTimeLabelArr, leftTimeLabel)
			for j = 1, 4 do
				local photoIcoName = 'item_photo_' .. j .. '_ico'
				local itemPhotoIco = tolua.cast(cardIco:getChildByName(photoIcoName),'UIImageView')
				local awardStr = giveGodAwardConf[i]['Award' .. j]
				itemPhotoIco:registerScriptTapHandler(function()
					UISvr:showTipsForAward(awardStr)
				end)
				table.insert(itemPhotoIcoArr, itemPhotoIco)
			end
		end
		upDatePanel()
    end)
	
	-- onShow
    panel:registerOnShowHandler(function ()
    end)

    -- onHide
    panel:registerOnHideHandler(function ()
    end)

    -- Show now
    CUIManager:GetInstance():ShowObject(giveGodAward, ELF_SHOW.SMART)
end

-- 显示神将放送panel
local function genGiveGodPanel()
	-- 神将放送数据
	local giveGodData

	-- 配置文件
	local roleLevelConf = GameData:getArrayData('rolelevel.dat')
	local giveGodConf = GameData:getArrayData('god.dat')
	local giveheroConf = GameData:getArrayData('givehero.dat')

	-- UI
	local giveGod
	local panel
	local roleImg
	local roleNameIco
	local roleStarTx
	local gotoBtn
	local redQuanIco
	local percentTx
	local expBar
	local starInfoTx

	-- 常量
	local MAX_ATTR_COUNT = 4

	-- 数组
	local attrIcoArr = {}
	local attrTxArr = {}
	local dayTxArr = {}
	local dayInfoArr = {}

	-- 更新panel
	local function updatePanel()
		local heroIndex = #giveGodData.got_god
		for k, v in pairs(giveGodData.got_god) do
			if tonumber(v) == 0 then
				heroIndex = k
				break
			end
		end
		local maxStar = tonumber(giveheroConf[heroIndex].GodRequiredStar)
		local currStar = (tonumber(giveGodData.star) >= maxStar and maxStar) or tonumber(giveGodData.star)
		if heroIndex == #giveGodData.got_god and tonumber(giveGodData.got_god[heroIndex]) == 1 then -- 如果是最后一个神将并且已经领过了
			gotoBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
			gotoBtn:setTouchEnable(false)
			gotoBtn:setNormalButtonGray(true)
			starInfoTx:setVisible(false)
		else
			if tonumber(giveGodData.star) >= maxStar then -- 如果已经满足可以领神将的条件
				starInfoTx:setVisible(false)
				gotoBtn:setText(getLocalStringValue('E_STR_BS_GET_ROLE_SUCCESS'))
			else -- 还不能领取
				starInfoTx:setVisible(true)
				gotoBtn:setText(getLocalStringValue('E_STR_GODROLE_GO_TO_FIGHT'))
			end
			gotoBtn:setTouchEnable(true)
			gotoBtn:setNormalButtonGray(false)
		end

		local roleId = tonumber(giveheroConf[heroIndex].GodRid)
		local roleCard = Role.getDataById(roleId)
		roleNameIco:setTexture(giveheroConf[heroIndex].NameIco)
		roleStarTx:setText(tostring(giveheroConf[heroIndex].GodRequiredStar))

		roleNameIco:setAnchorPoint(ccp(0,0))
		roleImg:setTexture(Role.getResourceByIdAndResType(roleId, RESOURCE_TYPE.BIG))

		for i = 1, 4 do
			local attackNum = 0
			if i == 1 then
				attackNum = roleCard.Attack
				attrIcoArr[1]:setTexture(Role.getResourceByIdAndResType(roleId, RESOURCE_TYPE.WEAPON_ICON_SMALL))
			elseif i == 2 then
				attackNum = roleCard.Defence
			elseif i == 3 then
				attackNum = roleCard.MagicDefence
			else
				attackNum = roleLevelConf[1]['Soldier' .. roleCard.Soldier]
			end
			attrTxArr[i]:setText(toWordsNumber(tonumber(attackNum)))
			attrTxArr[i]:setColor(COLOR_TYPE.RED)
		end

		percentTx:setText(currStar .. '/' .. maxStar)
		expBar:setPercent(currStar/maxStar * 100)
		local strBuff = string.format(getLocalStringValue('E_STR_GET_GOD_DEC'), currStar, maxStar-currStar, GetTextForCfg(roleCard.Name))
		starInfoTx:setText(strBuff)
		redQuanIco:setVisible(false)

		for i = 1, 3 do
			local day = giveGodConf[i].AccountCreateTimePass/3600/24
			local dayTx = string.format(getLocalStringValue('E_STR_DAY_NUM'), day)
			dayTxArr[i]:setText(dayTx)
			dayTxArr[i]:setColor(ccc3(255,153,0))
			dayInfoArr[i]:setText(GetTextForCfg(giveGodConf[i].Des))
			if i == 1 then
				dayInfoArr[i]:setColor(COLOR_TYPE.PURPLE)
			elseif i == 2 then
				dayInfoArr[i]:setColor(COLOR_TYPE.ORANGE)
			else
				dayInfoArr[i]:setColor(COLOR_TYPE.RED)
			end
			if tonumber(giveGodData.status[i]) == 1 and tonumber(giveGodData.got_reward[i]) == 0 then
				redQuanIco:setVisible(true)
			end
		end
	end

	local function getGodResponse(jsonData)
		local response = json.decode(jsonData)
		local code = tonumber(response.code)
		if code == 0 then
			giveGodData = response.data.god
			setGodData(response.data.god)
			local awards = response.data.awards
			local awardStr = json.encode(awards)
			UserData.parseAwardJson(awardStr)
			-- 显示招到的武将
			local heroIndex = #giveGodData.got_god
			for k, v in pairs(giveGodData.got_god) do
				if tonumber(v) == 1 then
					heroIndex = k
				end
			end
			CPublicPanelMgr:GetInst():ShowGodRoleLua(tonumber(giveheroConf[heroIndex].GodRid), true)
			updatePanel()
		end
	end

	-- 点击前往征战或领取奖励
	local function onClickGoto()
		local heroIndex = #giveGodData.got_god
		for k, v in pairs(giveGodData.got_god) do
			if tonumber(v) == 0 then
				heroIndex = k
				break
			end
		end
		local maxStar = tonumber(giveheroConf[heroIndex].GodRequiredStar)
		if tonumber(giveGodData.star) >= maxStar then -- 领取奖励
			Message.sendPost('get_god','god','{}',getGodResponse)
		else -- 去征战
			if tonumber(giveGodData.star) >= 60 and tonumber(giveGodData.star) < 147 then
				CCopySceneMgr:getInst():showWarMap(2)
			elseif tonumber(giveGodData.star) >= 147 and tonumber(giveGodData.star) < 228 then
				CCopySceneMgr:getInst():showWarMap(3)
			elseif tonumber(giveGodData.star) >= 228 then
				CCopySceneMgr:getInst():showWarMap(4)
			else
				CCopySceneMgr:getInst():showWarMap(1)
			end
		end
	end

	local function init()
		CUIManager:GetInstance():updateSceneId(30093)				-- 神将放送
		
		giveGodData = getGiveGodData()
		local root = panel:GetRawPanel()
		local godRoleBgImg = tolua.cast(root:getChildByName('god_role_bg_img'),'UIImageView')
		local godRoleImg = tolua.cast(godRoleBgImg:getChildByName('god_role_img'),'UIImageView')
		local titleIco = tolua.cast(godRoleImg:getChildByName('title_ico'),'UIImageView')

		local closeBtn = tolua.cast(titleIco:getChildByName('close_btn'),'UIButton')
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
		closeBtn:registerScriptTapHandler(function ()
			CUIManager:GetInstance():HideObject(giveGod, ELF_HIDE.SMART_HIDE)
		end)

		local roleBgImg = tolua.cast(godRoleImg:getChildByName('role_bg_img'),'UIImageView')
		roleImg = tolua.cast(roleBgImg:getChildByName('role_img'),'UIImageView')

		for i = 1, MAX_ATTR_COUNT do
			local attrImgName = 'attr_bg_' .. i .. '_ico'
			local attrBgIco = tolua.cast(roleBgImg:getChildByName(attrImgName),'UIImageView')
			local attrIco = tolua.cast(attrBgIco:getChildByName('attr_1_ico'),'UIImageView')
			local attrTx = tolua.cast(attrBgIco:getChildByName('attr_num_tx'),'UILabel')
			table.insert(attrIcoArr, attrIco)
			table.insert(attrTxArr, attrTx)
		end

		local awardBgImg = tolua.cast(roleBgImg:getChildByName('award_bg_img'),'UIImageView')
		local startBgImg = tolua.cast(roleBgImg:getChildByName('star_bg_img'),'UIImageView')
		roleNameIco = tolua.cast(startBgImg:getChildByName('name_ico'),'UIImageView')
		roleStarTx = tolua.cast(startBgImg:getChildByName('number_tx'),'UILabel')

		gotoBtn = tolua.cast(startBgImg:getChildByName('goto_btn'),'UITextButton')
		GameController.addButtonSound(gotoBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		gotoBtn:registerScriptTapHandler(onClickGoto)

		local awardBtn = tolua.cast(startBgImg:getChildByName('award_btn'),'UITextButton')
		GameController.addButtonSound(awardBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		awardBtn:registerScriptTapHandler(function ()
			-- 查看礼包
			genGiveGodAwardPanel()
		end)

		redQuanIco = tolua.cast(awardBtn:getChildByName('red_quan_ico'),'UIImageView')
		local expBgIco = tolua.cast(startBgImg:getChildByName('exp_bg_ico'),'UIImageView')
		percentTx = tolua.cast(expBgIco:getChildByName('percent_tx'),'UILabel')
		expBar = tolua.cast(expBgIco:getChildByName('exp_bar'),'UILoadingBar')
		expBar:setPercent(100)

		starInfoTx = tolua.cast(startBgImg:getChildByName('star_info_tx'),'UILabel')

		for i = 1, 3 do
			local dayName = 'day_' .. i ..'_tx'
			local dayInfoName = 'day_info_' .. i .. '_tx'
			local dayTx = tolua.cast(roleBgImg:getChildByName(dayName),'UILabel')
			local dayInfo = tolua.cast(roleBgImg:getChildByName(dayInfoName),'UILabel')
			table.insert(dayTxArr, dayTx)
			table.insert(dayInfoArr, dayInfo)
		end	
		updatePanel()
	end

	giveGod = SceneObjEx:createObj('panel/god_role_panel.json', 'god-role-lua')
    panel = giveGod:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('god_role_bg_img', 'god_role_img')

    panel:registerInitHandler(init)

    local firstOpen = true
    panel:registerOnShowHandler(function ()
    	if firstOpen then
    		firstOpen = false
    	else
    		Message.sendPost('get','god','{}',function(jsonData)
    			local response = json.decode(jsonData)
				local code = tonumber(response.code)
				if code == 0 then
					giveGodData = response.data.god
					setGodData(response.data.god)
					updatePanel()
				end
    		end)
    	end
    end)
    panel:registerOnHideHandler(function ()
    	-- body
    end)

    -- Show now
    CUIManager:GetInstance():ShowObject(giveGod, ELF_SHOW.SMART)
end

local function getGiveGodResponse(jsonData)
	local response = json.decode(jsonData)
	local code = tonumber(response.code)
	if code == 0 then
		setGodData(response.data.god)
		genGiveGodPanel()
	end
end

function requestGiveGod()
	Message.sendPost('get','god','{}',getGiveGodResponse)
end