require 'ceremony/panel/new_sign_in'

function requestSystemReward(openSignIn)
	-- 如果等级不够则不能打开公告栏
	-- local playerLevel = PlayerCoreData.getPlayerLevel()
	-- local bulletinLevel = GameData:getGlobalValue('BulletinOpenLevel')
	-- if tonumber(playerLevel) < tonumber(bulletinLevel) then
	-- 	if tonumber(openSignIn) == 1 then
	-- 		local singData = GameData:getMapData('activities.dat')
	-- 		local openLevel = singData['signin'].OpenLevel
	-- 		local level = PlayerCoreData.getPlayerLevel()
	-- 		if tonumber(level) >= tonumber(openLevel) then
	-- 			New_SignIn.enter()
	-- 		end
	-- 	end
	-- 	return
	-- end

	-- 服务器时间
	local serverTime = 0

	-- 有奖励的排前面
	local function sortByIsReward(a, b)
		local reward1 = tonumber(a.Reward)
		local reward2 = tonumber(b.Reward)
		if reward1 == reward2 then
			return tonumber(a.Id) > tonumber(b.Id)
		else
			return reward1 > reward2
		end
	end

	-- 按ID由大到小排序
	local function sortById(a, b)
		local id1 = tonumber(a.Id)
		local id2 = tonumber(b.Id)
		return id1 > id2
	end

	-- 打开公告栏界面
	local function genBulletinBoardPanel()
		-- UI
		local bulletin
		local panel
		local root
		local noticeBgImg
		local noticeImg
		local leftSv
		local rightSv
		local awardBtn
		local awardLine
		local awardImg1
		local awardImg2

		-- 存放所有的title按钮
		local titleBtnArr = {}

		-- 点击的消息ID
		local bulletinId = 0

		-- 已领取的奖励id
		local systemRewardData
		-- 已点击过的button
		local clickedBtnArr
		local clickedBtnMap

		-- 常量
		local VERTICAL_INTERVAL = 10    										-- 每条消息之间的间隔
		local TEXTAREA_INTERVAL = 5                     						-- textarea在scrollview里的偏移量
		local RED_ROUND_IMG = 'uires/ui_2nd/com/panel/herohome/red_round.png'	-- button未点击过的提示img
		local FONT_NAME = 'tahoma'
		local FONT_SIZE = 18

		-- 创建各项通知按钮
		local function createTitleBtn()
			-- 已点击过的button的数组
			local clickedBtnStr = GameController.getStringForKey('systemRewardBtns')
			clickedBtnArr = {}
			clickedBtnMap = {}
			if clickedBtnStr ~= '' then
				clickedBtnArr = json.decode(clickedBtnStr)
				for k,v in pairs(clickedBtnArr) do
					clickedBtnMap[tostring(v)] = v
				end
			end
			-- 已领取过奖励的公告，转为map方便检查是否领取过
			systemRewardData = UserData:getSystemRewardData()
			for k,v in pairs(systemRewardData) do
				systemRewardData[tostring(v)] = v
			end
			local firstFlag = false
			local firstFunction
			local index = 0
			local systemRewardJson = GameController.getStringForKey('systemReward')
			local systemReward = {}
			if systemRewardJson ~= '' then
				systemReward = json.decode(systemRewardJson)
			end
			-- 有奖励的排到前面，剩下的按id由大到小排序
			table.sort(systemReward, sortByIsReward)
			local nowTime = UserData:getServerTime()
			if tonumber(nowTime) == 0 then
				nowTime = serverTime
			end
			for k,v in pairs(systemReward) do
				local flag = false
				if tonumber(v.Forever) == 1 then    -- 如果这条公告需要永久显示
					flag = true
				else 	-- 如果不是永久显示那么判断公告是否过了有效期
					flag = tonumber(nowTime) > tonumber(v.StartTime) and tonumber(nowTime) < tonumber(v.EndTime) 
				end
				local clickDis = true
				if tonumber(v.Displayable) == 1 and tonumber(v.Reward) == 0 and clickedBtnMap[tostring(v.Id)] then -- 如果是点击一次就消失，并且已经点击过了，并且不是带奖励的公告
					clickDis = false
				end
				if flag and clickDis and not systemRewardData[tostring(v.Id)] then -- 如果在有效时间范围内，并且不是点击一次就消失的，并且没领过奖那就显示出来吧
					local button = UITextButton:create()
					button:setTextures('uires/ui_2nd/com/common_btn/sharp_btn_1.png',
									   '',
									   '')
					button:setFontSize(FONT_SIZE)
					button:setFontName(FONT_NAME)
					button:setText(v.Button)
					button:setTouchEnable(true)
					GameController.addButtonSound(button, BUTTON_SOUND_TYPE.CLICK_EFFECT)

					local clickHandle = function()
						bulletinId = v.Id
						button:getChildByTag(100):setVisible(false)
						rightSv:removeAllChildrenAndCleanUp(true)
						-- 点击过的button的id存到userdefault里
						if not clickedBtnMap[tostring(v.Id)] then
							clickedBtnMap[tostring(v.Id)] = v.Id
							table.insert(clickedBtnArr, tonumber(v.Id))
							local newClickedBtn = json.encode(clickedBtnArr)
							GameController.setStringForKey('systemRewardBtns',newClickedBtn)
						end
						-- 点击按钮的时候先设所有按钮为正常状态，然后设置点中的按钮为选中状态
						for k2, v2 in pairs(titleBtnArr) do
							v2:setPressState(WidgetStateNormal)
							v2:setTouchEnable(true)
						end
						button:setPressState(WidgetStateSelected)
						button:setTouchEnable(false)

						-- 如果该条通知不包含奖励
						if tonumber(v.Reward) == 0 then
							awardLine:setVisible(false)
							awardBtn:setVisible(false)
							awardImg1:setVisible(false)
							awardImg2:setVisible(false)
							rightSv:setSize(CCSizeMake(500, 340))
							rightSv:setPosition(ccp(-240, -170))
						else
							awardLine:setVisible(true)
							awardBtn:setVisible(true)
							awardImg1:setVisible(true)
							awardImg2:setVisible(true)
							local awardIco1 = tolua.cast(awardImg1:getChildByName('award_ico'),'UIImageView')
							local awardNum1 = tolua.cast(awardImg1:getChildByName('num_tx'),'UILabel')
							local awardName1 = tolua.cast(awardImg1:getChildByName('name_tx'),'UILabel')
							local awardIco2 = tolua.cast(awardImg2:getChildByName('award_ico'),'UIImageView')
							local awardNum2 = tolua.cast(awardImg2:getChildByName('num_tx'),'UILabel')
							local awardName2 = tolua.cast(awardImg2:getChildByName('name_tx'),'UILabel')
							-- awardName1:setPreferredSize(120,1)
							-- awardName2:setPreferredSize(120,1)
							local award1 = v.Award1
							local award2 = v.Award2
							local vStr1 = v.Award1[1] .. '.' .. v.Award1[2] .. ':' .. v.Award1[3]
							local vStr2 = v.Award2[1] .. '.' .. v.Award2[2] .. ':' .. v.Award2[3]
							local awardData1 = UserData:getAward(vStr1)
							local awardData2 = UserData:getAward(vStr2)
							awardIco1:setTexture(awardData1.icon)
							awardIco2:setTexture(awardData2.icon)
							awardNum1:setText(awardData1.count)
							awardNum2:setText(awardData2.count)
							awardName1:setText(awardData1.name)
							awardName2:setText(awardData2.name)
					        rightSv:setSize(CCSizeMake(500, 220))
							rightSv:setPosition(ccp(-240, -48))
							-- 如果领过奖励则按钮不可用
							if systemRewardData[tostring(bulletinId)] then
								awardBtn:setTouchEnable(false)
								awardBtn:setPressState(WidgetStateDisabled)
							else
								awardBtn:setTouchEnable(true)
								awardBtn:setPressState(WidgetStateNormal)
							end
						end

						local noticeContent = v.Content
						noticeContent = string.gsub(noticeContent,'|','<br/>')
						local noticeTx = UILabel:create()
						noticeTx:setAnchorPoint(ccp(0,0))
						noticeTx:setFontSize(20)
						noticeTx:setPreferredSize(480,1)
						noticeTx:setText(noticeContent)
						rightSv:addChildToBottom(noticeTx)
						rightSv:scrollToTop()
					end
					-- 如果是第一个按钮的点击事件
					if not firstFlag then
						firstFlag = true
						firstFunction = clickHandle
					end
					button:registerScriptTapHandler(clickHandle)

					leftSv:addChildToBottom(button)
					button:setPosition(ccp(button:getContentSize().width/2,button:getPosition().y))
					-- 创建每个button上的未点击过的提示
					local promptImg = UIImageView:create()
					promptImg:setTexture(RED_ROUND_IMG)
					local promptTx = UILabel:create()
					promptTx:setFontSize(FONT_SIZE)
					promptTx:setFontName(FONT_NAME)
					promptTx:setText('1')
					promptImg:addChild(promptTx)
					promptTx:setPosition(ccp(-3,2))
					button:addChild(promptImg)
					promptImg:setWidgetTag(100)
					promptImg:setPosition(ccp(-80,10))
					promptImg:setScale(0.7)
					-- 如果该按钮已经点击过则不显示点击提示
					if clickedBtnMap[tostring(v.Id)] then
						promptImg:setVisible(false)
					end
					table.insert(titleBtnArr, button)
					index = index + 1
				end
			end
			leftSv:scrollToTop()
			-- 初始化完后点击第一个按钮
			if firstFunction then
				firstFunction()
			end
		end

		local function onGetRewardCallbacks(jsonData)
			local response = json.decode(jsonData)
			local code = tonumber(response.code)
			if code == 0 then
				local data = response.data
				local awards = data.awards
				local msgs = {}
				for k,v in pairs(awards) do
		            local vStr = v[1] .. '.' .. v[2] .. ':' .. v[3]             -- 改成类似user.cash:10的形式
		            local award = UserData:getAward(vStr)
		            local awardname = award.name .. ' X' .. award.count
        			msg = string.format(getLocalString('E_STR_GAIN_ANYTHING'),awardname)
		            table.insert(msgs, msg)
		        end
		        GameController.showPrompts(msgs)
		        UserData.parseAwardJson(json.encode(awards))
		        -- 领完奖励后按钮不可用
		        awardBtn:setTouchEnable(false)
		        awardBtn:setPressState(WidgetStateDisabled)
		        local sRData = UserData:getSystemRewardData()
		        table.insert(sRData,bulletinId)
		        UserData:setSystemRewardData(json.encode(sRData))
		        systemRewardData[tostring(bulletinId)] = bulletinId
			end
		end

		local function init()
			root = panel:GetRawPanel()
			noticeBgImg = tolua.cast(root:getChildByName('notice_bg_img'),'UIImageView')
			noticeImg = tolua.cast(noticeBgImg:getChildByName('notice_img'),'UIImageView')

			local leftBgImg = tolua.cast(noticeImg:getChildByName('left_bg_img'),'UIImageView')
			leftSv = tolua.cast(leftBgImg:getChildByName('left_sv'),'UIScrollView')
			leftSv:setClippingEnable(true)
			leftSv:setDirection(SCROLLVIEW_DIR_VERTICAL)
			leftSv:setTouchEnable(true)

			local rightBgImg = tolua.cast(noticeImg:getChildByName('right_bg_img'),'UIImageView')
			rightSv = tolua.cast(rightBgImg:getChildByName('right_sv'),'UIScrollView')
			rightSv:setClippingEnable(true)

			awardLine = tolua.cast(rightBgImg:getChildByName('line_img'),'UIImageView')
			awardBtn = tolua.cast(rightBgImg:getChildByName('award_btn'),'UITextButton')
			GameController.addButtonSound(awardBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			-- 领取奖励
			awardBtn:registerScriptTapHandler(function()
				local btnId = {
				    id = bulletinId
				}
				Message.sendPost('get_systemreward','user',json.encode(btnId),onGetRewardCallbacks)
			end)

			awardImg1 = tolua.cast(rightBgImg:getChildByName('award_frame_1'),'UIScrollView')
			awardImg2 = tolua.cast(rightBgImg:getChildByName('award_frame_2'),'UIImageView')

			local closeBtn = tolua.cast(noticeImg:getChildByName('close_btn'),'UIButton')
			GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)
			closeBtn:registerScriptTapHandler(function()
				-- 关闭界面并打开签到
				CUIManager:GetInstance():HideObject(bulletin, ELF_HIDE.HIDE_NORMAL)
				if tonumber(openSignIn) == 1 then
					local singData = GameData:getMapData('activities.dat')
					local openLevel = singData['signin'].OpenLevel
					local level = PlayerCoreData.getPlayerLevel()
					if tonumber(level) >= tonumber(openLevel) then
						New_SignIn.enter()
					end
				end			
			end)

			createTitleBtn()
		end

		local function onShow()

	    end

	    local function onHide()
	    	
	    end

	    bulletin = SceneObjEx:createObj('panel/bulletin_board_panel.json', 'bulletin-board-lua')
	    panel = bulletin:getPanelObj()        --# This is a BasePanelEx object
	    panel:setAdaptInfo('notice_bg_img', 'notice_img')

	    panel:registerInitHandler(init)

	    panel:registerOnShowHandler(onShow)

	    panel:registerOnHideHandler(onHide)
	    
	    -- Show now
	    CUIManager:GetInstance():ShowObject(bulletin, ELF_SHOW.NORMAL)
	end

	-- 请求系统奖励信息
	local sreward = GameController.getStringForKey('systemReward')
	local existRewards = {}
	local pJson = {
	    id = 0,
	    version = 0
	}
	if sreward ~= '' and sreward ~= '[]' then
		existRewards = json.decode(sreward)
		table.sort(existRewards, sortById)
		pJson.id = existRewards[1].Id
		if existRewards[1].Version then
			pJson.version = existRewards[1].Version
		end 
	end

	-- 如果公告栏的内容已经全部看过,登陆的时候就不显示了
	local function isLoginShowBulletin()
		if tonumber(openSignIn) == 1 then -- 如果是登陆时准备打开公告栏，判断是否已经全部看过
			local showFlag = false
			-- 已点击过的button的数组
			local pClickedBtnStr = GameController.getStringForKey('systemRewardBtns')
			local pClickedBtnArr = {}
			local pClickedBtnMap = {}
			if pClickedBtnStr ~= '' then
				pClickedBtnArr = json.decode(pClickedBtnStr)
				for k,v in pairs(pClickedBtnArr) do
					pClickedBtnMap[tostring(v)] = v
				end
			end
			-- 所有的消息
			local nowTime = UserData:getServerTime()
			if tonumber(nowTime) == 0 then
				nowTime = serverTime
			end
			for k, v in pairs(existRewards) do
				local flag = tonumber(nowTime) > tonumber(v.StartTime) and tonumber(nowTime) < tonumber(v.EndTime) 
				if tonumber(v.Displayable) == 1 and flag then
					if not pClickedBtnMap[tostring(v.Id)] then
						showFlag = true
						break
					end
				end
			end

			-- if showFlag then
				genBulletinBoardPanel()
			-- else
				-- 不打开公告栏直接打开登陆界面
				-- local singData = GameData:getMapData('activities.dat')
				-- local openLevel = singData['signin'].OpenLevel
				-- local level = PlayerCoreData.getPlayerLevel()
				-- if tonumber(level) >= tonumber(openLevel) then
				-- 	New_SignIn.enter()
				-- end
			-- end
		else -- 如果是点击公告栏按钮打开，则直接打开
			genBulletinBoardPanel()
		end
	end

	-- 请求公告栏信息的回调
	local function onSystemRewardCallbacks(jsonData)
		local sRewardData = json.decode(jsonData)
		local code = tonumber(sRewardData.code)
		if code == 0 then
			serverTime = sRewardData.serverTime
			local rewards = sRewardData.data.rewards
			if tonumber(sRewardData.data.has_new) == 1 then -- 说明需要清空所有公告重新赋值
				existRewards = {}
			end 
			if rewards then
				for k, v in pairs(rewards) do
					table.insert(existRewards,v)
				end
			end
			local newExistRewards = json.encode(existRewards)
			GameController.setStringForKey('systemReward',newExistRewards)
			-- 如果公告栏的内容已经全部看过,登陆的时候就不显示了
			isLoginShowBulletin()
		end
	end
	Message.sendPost('new_systemreward','user',json.encode(pJson),onSystemRewardCallbacks)
end