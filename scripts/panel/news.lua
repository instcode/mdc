function genNewsPanel(tag)
	-- UI
	local messagePl
	-- 消息相关ui
	local msgAllBtn
	local msgGoldBtn
	local msgRankBtn
	local msgPlunderBtn
	local msgLegionBattleBtn
	local msgBtnArr = {}
	local msgScrollView
	-- 消息相关
	local msgNewsData = {}
	local msgType = 'all'
	local msgIndex = 0

	local widgetPoor = {}

	-- 常量
	local FIRST_LOAD_NEWS_COUNT = 5

	-- 排序
	local function sortFn(a, b)
		local dwTimea = a.dwTime
		local dwTimeb = b.dwTime
		return dwTimea > dwTimeb
	end

	local function parseGeneralNews(dataArr, data)
		local len = #data
		for i = 1,len do
			repeat
				if data[i] then
					if data[i].name then
						local pdata = {}
						local strName = data[i].name
						pdata.isFull = data[i].full
						pdata.strType = data[i].type
						pdata.dwTime = data[i].time
						pdata.dwReplay = data[i].replay
						pdata.isReplay = true
						pdata.info = ''
						if i < len then
							local nextData = data[i+1]
							if pdata.strType == nextData.type and pdata.dwTime == nextData.time and strName == nextData.name then
								break
							end
						end

						if pdata.strType == 'mine' then
							local nAtkGold = data[i].atkgold
							local nDefGold = data[i].defgold
							pdata.bySucc = data[i].succ
							local byFlag = data[i].flag
							local gold
							if tonumber(pdata.bySucc) == 0 then
								if tonumber(byFlag) == 0 and tonumber(pdata.isFull) == 0 then
									gold = string.format(getLocalString('E_STR_KEEP_MINE_SUCCESS'), math.abs(tonumber(nDefGold)))
									pdata.info = pdata.info .. strName .. gold
								elseif tonumber(byFlag) == 0 and tonumber(pdata.isFull) == 1 then
									gold = getLocalString('E_STR_KEEP_MINE_SUCCESS_AND_FULL')
									pdata.info = pdata.info .. strName .. gold
								else
									gold = string.format(getLocalString('E_STR_GRAB_MINE_FAILED'), math.abs(tonumber(nAtkGold)))
									pdata.info = pdata.info .. getLocalString('E_STR_YOU_WANT_TO_PLUNDER') .. strName .. gold
								end
							else
								if byFlag == 0 then
									gold = string.format(getLocalString('E_STR_PLUNDER_YOUR_GOLDMINE'), math.abs(tonumber(nDefGold)))
									pdata.info = pdata.info .. strName .. gold
								else
									gold = string.format(getLocalString('E_STR_SNATCHED_GOLD'), math.abs(tonumber(nAtkGold)))
									pdata.info = pdata.info .. getLocalString('E_STR_YOU_PLUNDERED') .. strName .. gold
								end
							end
						elseif pdata.strType == 'rank' then
							pdata.bySucc = data[i].succ
							local byFlag = data[i].flag
							local wRank = data[i].rank
							if tonumber(byFlag) == 0 then
								pdata.info = pdata.info .. strName .. getLocalString('E_STR_CHALLENGE_YOU')
							else
								pdata.info = pdata.info .. getLocalString('E_STR_YOU_CHALLENGE') .. strName
							end
							if tonumber(pdata.bySucc) == tonumber(byFlag) then
								if tonumber(wRank) == 0 then
									pdata.info = pdata.info .. getLocalString('E_STR_YOU_WIN_RANKING_UNCHANGED')
								else
									pdata.info = pdata.info .. getLocalString('E_STR_YOU_WIN_RANK_UP') .. wRank
								end
							else
								if tonumber(wRank) == 0 then
									pdata.info = pdata.info .. getLocalString('E_STR_YOU_DEFEATED_RANKING_UNCHANGED')
								else
									local strtemp = string.format(getLocalString('E_STR_YOU_DEFEATED_RANK_DOWN'), tonumber(wRank))
									pdata.info = pdata.info .. strtemp
								end
							end
						elseif pdata.strType == 'fragment' then
							pdata.iFragmentId = data[i].fid
							pdata.iEnemy = data[i].enemy
							local name = PlayerCoreData.getMaterialName(tonumber(pdata.iFragmentId))
							local strBuff = string.format(getLocalString('E_STR_GRAB_FRAGMENT'), strName,name)
							pdata.info = pdata.info .. strBuff
							pdata.bySucc = 0
						end
						table.insert(dataArr, pdata)
					end
				end
			until true
		end
	end

	local function parseLegionBattleNews(dataArr, data)
		for k, v in pairs(data) do
			local pdata = {}
			local attName = tostring(v[2])
			local isDefeat = tonumber(v[3])
			local costMove = tonumber(v[4])
			local isDead = tonumber(v[5])
			pdata.dwTime = tonumber(v[1])
			pdata.info = ''
			pdata.strType = 'legionbattle'
			pdata.isReplay = false
			if isDefeat == 1 then -- 被打败
				if isDead == 0 then
					pdata.info = string.format(LegionConfig:getLegionLocalText('LEGION_DEFENCE_FAILED_MESSAGE'),attName,costMove)
				elseif isDead == 1 then
					pdata.info = string.format(LegionConfig:getLegionLocalText('LEGION_DEFENCE_FAILED_AND_GOHOME_MESSAGE'),attName,costMove)
				end
			elseif isDefeat == 0 then
				if isDead == 0 then
					pdata.info = string.format(LegionConfig:getLegionLocalText('LEGION_DEFENCE_SUCCEED_MESSAGE'),attName,costMove)
				elseif isDead == 1 then
					pdata.info = string.format(LegionConfig:getLegionLocalText('LEGION_DEFENCE_SUCCEED_AND_GOHOME_MESSAGE'),attName,costMove)
				end
			end
			table.insert(dataArr, pdata)
		end
	end

	-- 解析消息data
	local function parseNewsData(data)
		local dataArr = {}
		if data.newsforlua then
			parseGeneralNews(dataArr, data.newsforlua)
		end

		if data.legionbattlenews then
			parseLegionBattleNews(dataArr, data.legionbattlenews)
		end
		
		table.sort(dataArr, sortFn)
		return dataArr
	end

	local function getWidgetFromPool()
		local poorNum = #widgetPoor
		local widget
		if poorNum > 0 then
			widget = table.remove(widgetPoor)
		else
			widget = createWidgetByName('panel/news_card_panel_1.json')
		end
		return widget
	end

	-- 添加一条消息
	local function genNewsItem()
		local newsLength = #msgNewsData
		local newsDataJson = UserData:getNewsData()
		local newsDataAll = json.decode(newsDataJson)
		local newsDataArr = parseNewsData(newsDataAll)
		local newsJsonLength = #newsDataArr
		-- 每次查找一条符合条件的消息添加到消息面板
		local index = msgIndex
		-- 如果已经添加的消息数小于消息总数 and 最后一条找到的消息的index小于消息总数 
		while newsLength < newsJsonLength and index < newsJsonLength do
			newsLength = newsLength + 1
			index = index + 1
			local newsData = newsDataArr[index]
			if msgType == 'all' or newsData.strType == msgType then
				msgIndex = index
				local newsCardRoot = getWidgetFromPool()
				local newsCardInfo = tolua.cast(newsCardRoot:getChildByName('news_info_tx'), 'UITextArea')
				newsCardInfo:setText(newsData.info)

				local newsCardTime = tolua.cast(newsCardRoot:getChildByName('time_tx'), 'UITextArea')
				local serverTime = UserData:getServerTime()
				local strTime = GameController.timeFormat(serverTime, newsData.dwTime)
				newsCardTime:setText(strTime)

				local newsCardRobBtn = tolua.cast(newsCardRoot:getChildByName('rob_btn'), 'UIButton')
				newsCardRobBtn:setVisible(false)

				local newsCardReplayBtn = tolua.cast(newsCardRoot:getChildByName('replay_btn'), 'UIButton')
				GameController.addButtonSound(newsCardReplayBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
				newsCardReplayBtn:registerScriptTapHandler(function()
					GameController.doReplay(newsData.strType, newsData.dwReplay)
				end)
				newsCardReplayBtn:setVisible(newsData.isReplay)

				msgScrollView:addChildToBottom(newsCardRoot)
				table.insert(msgNewsData,newsCardRoot)
				break
			end
		end
	end

	-- 填充内容
	local function updateMsgContent()
		local newsData = UserData:getNewsData()
		if newsData then
			local newsDataJson = json.decode(newsData)
			if newsDataJson then
				msgScrollView:removeAllChildrenAndCleanUp(false)
				local newsNum = #msgNewsData
				for i=1, newsNum do
					table.insert(widgetPoor, table.remove(msgNewsData))
				end
				-- 打开界面的时候只添加5条
				msgIndex = 0
				for i = 1,FIRST_LOAD_NEWS_COUNT do
					genNewsItem()
				end

				if next(msgNewsData) then
					msgScrollView:scrollToTop()
				end
			end
		end
	end

	-- 打开对应的button所显示的内容
	local function setNewsTag(newsTag)
		if newsTag == NEWS_TAG.TAG_ALL then
			msgAllBtn:disable()
			msgGoldBtn:active()
			msgRankBtn:active()
			msgPlunderBtn:active()
			msgLegionBattleBtn:active()
			msgAllBtn:setPressState(WidgetStateDisabled)
			msgGoldBtn:setPressState(WidgetStateNormal)
			msgRankBtn:setPressState(WidgetStateNormal)
			msgPlunderBtn:setPressState(WidgetStateNormal)
			msgLegionBattleBtn:setPressState(WidgetStateNormal)
			msgType = 'all'
		elseif newsTag == NEWS_TAG.TAG_GOLDMINE then
			msgGoldBtn:disable()
			msgAllBtn:active()
			msgRankBtn:active()
			msgPlunderBtn:active()
			msgLegionBattleBtn:active()
			msgGoldBtn:setPressState(WidgetStateDisabled)
			msgAllBtn:setPressState(WidgetStateNormal)
			msgRankBtn:setPressState(WidgetStateNormal)
			msgPlunderBtn:setPressState(WidgetStateNormal)
			msgLegionBattleBtn:setPressState(WidgetStateNormal)
			msgType = 'mine'
		elseif newsTag == NEWS_TAG.TAG_ARENA then
			msgRankBtn:disable()
			msgAllBtn:active()
			msgGoldBtn:active()
			msgPlunderBtn:active()
			msgLegionBattleBtn:active()
			msgRankBtn:setPressState(WidgetStateDisabled)
			msgAllBtn:setPressState(WidgetStateNormal)
			msgGoldBtn:setPressState(WidgetStateNormal)
			msgPlunderBtn:setPressState(WidgetStateNormal)
			msgLegionBattleBtn:setPressState(WidgetStateNormal)
			msgType = 'rank'
		elseif newsTag == NEWS_TAG.TAG_PLUNDER then
			msgPlunderBtn:disable()
			msgAllBtn:active()
			msgGoldBtn:active()
			msgRankBtn:active()
			msgLegionBattleBtn:active()
			msgPlunderBtn:setPressState(WidgetStateDisabled)
			msgAllBtn:setPressState(WidgetStateNormal)
			msgGoldBtn:setPressState(WidgetStateNormal)
			msgRankBtn:setPressState(WidgetStateNormal)
			msgLegionBattleBtn:setPressState(WidgetStateNormal)
			msgType = 'fragment'
		elseif newsTag == NEWS_TAG.TAG_LEGION_BATTLE then
			msgLegionBattleBtn:disable()
			msgPlunderBtn:active()
			msgAllBtn:active()
			msgGoldBtn:active()
			msgRankBtn:active()
			msgLegionBattleBtn:setPressState(WidgetStateDisabled)
			msgPlunderBtn:setPressState(WidgetStateNormal)
			msgAllBtn:setPressState(WidgetStateNormal)
			msgGoldBtn:setPressState(WidgetStateNormal)
			msgRankBtn:setPressState(WidgetStateNormal)
			msgType = 'legionbattle'
		else
			msgType = 'all'
		end
		-- 填充内容
		updateMsgContent()
	end

	local function initMessage()
		local msgLeftBg = tolua.cast(messagePl:getChildByName('left_bg_img'),'UIImageView')

		msgAllBtn = tolua.cast(msgLeftBg:getChildByName('all_btn'),'UIButton')
		msgAllBtn:setWidgetTag(NEWS_TAG.TAG_ALL)
		GameController.addButtonSound(msgAllBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)

		msgGoldBtn = tolua.cast(msgLeftBg:getChildByName('goldmine_btn'),'UIButton')
		msgGoldBtn:setWidgetTag(NEWS_TAG.TAG_GOLDMINE)
		GameController.addButtonSound(msgGoldBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)

		msgRankBtn = tolua.cast(msgLeftBg:getChildByName('arena_btn'),'UIButton')
		msgRankBtn:setWidgetTag(NEWS_TAG.TAG_ARENA)
		GameController.addButtonSound(msgRankBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)

		msgPlunderBtn = tolua.cast(msgLeftBg:getChildByName('plunder_btn'),'UIButton')
		msgPlunderBtn:setWidgetTag(NEWS_TAG.TAG_PLUNDER)
		GameController.addButtonSound(msgPlunderBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)

		msgLegionBattleBtn = tolua.cast(msgLeftBg:getChildByName('legion_battle_btn'),'UIButton')
		msgLegionBattleBtn:setWidgetTag(NEWS_TAG.TAG_LEGION_BATTLE)
		GameController.addButtonSound(msgLegionBattleBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
		local lab = tolua.cast(msgLegionBattleBtn:getChildByName('label'),'UILabel')
		-- lab:setPreferredSize(175,1)

		table.insert(msgBtnArr,msgAllBtn)
		table.insert(msgBtnArr,msgGoldBtn)
		table.insert(msgBtnArr,msgRankBtn)
		table.insert(msgBtnArr,msgPlunderBtn)
		table.insert(msgBtnArr,msgLegionBattleBtn)

		local index = 0
		for k,v in pairs(msgBtnArr) do
			index = index + 1
			local newsTaq
			if index == 1 then
				newsTaq = NEWS_TAG.TAG_ALL
			elseif index == 2 then
				newsTaq = NEWS_TAG.TAG_GOLDMINE
			elseif index == 3 then
				newsTaq = NEWS_TAG.TAG_ARENA
			elseif index == 4 then
				newsTaq = NEWS_TAG.TAG_PLUNDER
			elseif index == 5 then
				newsTaq = NEWS_TAG.TAG_LEGION_BATTLE
			end
			v:registerScriptTapHandler(function()
				setNewsTag(newsTaq)
			end)
		end
		
		msgScrollView = tolua.cast(messagePl:getChildByName('news_sv'),'UIScrollView')
		msgScrollView:setClippingEnable(true)

		
		msgScrollView:registerScrollToBottomEvent(function()
			for i = 1,FIRST_LOAD_NEWS_COUNT do
				genNewsItem()
			end
		end)
	end

    local news = SceneObjEx:createObj('panel/news_panel.json', 'news-lua')
    local panel = news:getPanelObj()        --# This is a BasePanelEx object
    panel:setAdaptInfo('message_bg_img', 'message_img')

    -- init
    panel:registerInitHandler(function ()
    	local root = panel:GetRawPanel()
		local mesageBgImg = tolua.cast(root:getChildByName('message_bg_img'),'UIImageView')
		local messageImg = tolua.cast(mesageBgImg:getChildByName('message_img'),'UIImageView')

		messagePl = tolua.cast(messageImg:getChildByName('message_pl'),'UIPanel')

		initMessage()

		local closeBtn = tolua.cast(root:getChildByName('close_btn'),'UIButton')
		closeBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(news, ELF_HIDE.HIDE_NORMAL)
		end)
		GameController.addButtonSound(closeBtn, BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		setNewsTag(tag)
    end)

    -- onShow
    panel:registerOnShowHandler(function ()
    end)

    -- onHide
    panel:registerOnHideHandler(function ()
    end)

    panel:registerOnDestroyHandler(function ()
    	-- 手动释放没有addchild到scrollview上的uiwidge
    	for k, v in pairs(widgetPoor) do
    		v:removeFromParentAndCleanup(true)
    	end
    	widgetPoor = {}
    	msgNewsData = {}
    end)
    
    -- Show now
    CUIManager:GetInstance():ShowObject(news, ELF_SHOW.NORMAL)
end