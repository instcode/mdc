PvpReportsPanel = PvpView:new{
	jsonFile = 'panel/battle_report_panel_1.json',
	panelName = 'reports-in-lua',
	myPosition,
	index,
	page,
	myReplays = {}
}

function PvpReportsPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('battle_report_bg_img','battle_report_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()

		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		playerNameTx1 = tolua.cast(root:getChildByName('player_1_name_tx') , 'UILabel')
		playerNameTx2 = tolua.cast(root:getChildByName('player_2_name_tx') , 'UILabel')
		-- playerSeverTx1 = tolua.cast(root:getChildByName('player_1_server_num_tx') , 'UILabel')
		-- playerSeverTx2 = tolua.cast(root:getChildByName('player_2_server_num_tx') , 'UILabel')
		playerScoreTx1 = tolua.cast(root:getChildByName('player_1_score_tx') , 'UILabel')
		playerScoreTx2 = tolua.cast(root:getChildByName('player_2_score_tx') , 'UILabel')

		reportSv = tolua.cast(root:getChildByName('report_sv') , 'UIScrollView')
		reportSv:setClippingEnable(true)
		local a = 0
		local b = 0
		local name1 = nil
		local name2 = nil
		local serverid1 = nil 
		local serverid2 = nil
		-- 判断index的取值 超过4 读取的数据位置不同
		local index = self.index
		if index <= 4 then 
			if self.data.replays[index + (self.page - 1)*4] then
				for i=1,#self.data.replays[index + (self.page - 1)*4] do
					local temp = i
					local view = createWidgetByName('panel/battle_report_card_panel.json')
					playerNameTx = tolua.cast(view:getChildByName('player_name_tx') , 'UILabel')
					playerServerNumTx = tolua.cast(view:getChildByName('player_server_num_tx') , 'UILabel')
					playNumTx = tolua.cast(view:getChildByName('play_num_tx') , 'UILabel')
					playNumTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC19'),i))
					local name = nil
					if 2*index-1 + (self.page - 1 )*8 == tonumber(self.data.replays[index + (self.page - 1)*4][i].win) + 1 then
						a = a + 1
						name = self.data.top32[2*index-1 + (self.page - 1 )*8].name
						playerServerNumTx:setText(self.data.top32[2*index-1 + (self.page - 1 )*8].serverid)
					else
						b = b + 1
						name = self.data.top32[2*index-1 + (self.page - 1 )*8 + 1].name
						playerServerNumTx:setText(self.data.top32[2*index-1 + (self.page - 1 )*8 + 1].serverid)
					end
					playerNameTx:setText(name)
					reportSv:addChildToBottom(view)
					replayBtn = tolua.cast(view:getChildByName('playback_btn') , 'UIButton')
					replayBtn:registerScriptTapHandler(function ()
						print('===================')
						print(i)
						print(temp)
						print(self.page)
						print(index + (self.page - 1)*4)
						print(self.data.replays[index + (self.page - 1)*4][i].rid)
						print('===================')
						PvpController:getReplay(function(res)
							if res.data.battle then
								GameController.clearAwardView()
								GameController.playBattle(json.encode(res.data.battle) , 5)
							end
						end,self.data.replays[index + (self.page - 1)*4][i].rid)
					end)
					GameController.addButtonSound(replayBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
				end
				name1 = self.data.top32[2*index-1 + (self.page - 1 )*8].name
				name2 = self.data.top32[2*index-1 + (self.page - 1 )*8 + 1].name
				serverid1 = self.data.top32[2*index-1 + (self.page - 1 )*8].serverid
				serverid2 = self.data.top32[2*index-1 + (self.page - 1 )*8 + 1].serverid
			else
				name1 = self.data.top32[2*index-1 + (self.page - 1 )*8].name or ''
				serverid1 = self.data.top32[2*index-1 + (self.page - 1 )*8].serverid or ''
				name2 = self.data.top32[2*index-1 + (self.page - 1 )*8 + 1].name or ''
				serverid2 = self.data.top32[2*index-1 + (self.page - 1 )*8 + 1].serverid or ''
			end
		elseif index == 5 or index == 6 then
			if self.data.replays[16 + (index - 4) + (self.page - 1) * 2 ] then
				for i=1,#self.data.replays[12 + index + (self.page - 1) * 2 ] do
					local temp = i
					local view = createWidgetByName('panel/battle_report_card_panel.json')
					playerNameTx = tolua.cast(view:getChildByName('player_name_tx') , 'UILabel')
					playerServerNumTx = tolua.cast(view:getChildByName('player_server_num_tx') , 'UILabel')
					playNumTx = tolua.cast(view:getChildByName('play_num_tx') , 'UILabel')
					playNumTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC19'),i))
					local name = nil
					if self.data.records[2*(index - 4)-1 + (self.page - 1)*4] + 1 == tonumber(self.data.replays[16 + (index - 4) + (self.page - 1) * 2 ][i].win) + 1 then
						a = a + 1
						name = self.data.top32[self.data.records[2*(index - 4)-1 + (self.page - 1)*4] + 1].name
						playerServerNumTx:setText(self.data.top32[self.data.records[2*(index - 4)-1 + (self.page - 1)*4] + 1].serverid)
					else
						b = b + 1
						name = self.data.top32[self.data.records[2*(index - 4)-1 + (self.page - 1)*4 + 1] + 1].name
						playerServerNumTx:setText(self.data.top32[self.data.records[2*(index - 4)-1 + (self.page - 1)*4 + 1] + 1].serverid)
					end
					playerNameTx:setText(name)
					reportSv:addChildToBottom(view)
					replayBtn = tolua.cast(view:getChildByName('playback_btn') , 'UIButton')
					replayBtn:registerScriptTapHandler(function ()
						print('===================')
						print(i)
						print(temp)
						print(self.page)
						print(16 + (index - 4) + (self.page - 1) * 2)
						print(self.data.replays[16 + (index - 4) + (self.page - 1) * 2][i].rid)
						print('===================')
						PvpController:getReplay(function(res)
							if res.data.battle then
								GameController.clearAwardView()
								GameController.playBattle(json.encode(res.data.battle) , 5)
							end
						end,self.data.replays[16 + (index - 4) + (self.page - 1) * 2 ][i].rid)
					end)
					GameController.addButtonSound(replayBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
				end
				name1 = self.data.top32[self.data.records[2*(index - 4)-1 + (self.page - 1)*4] + 1].name
				name2 = self.data.top32[self.data.records[2*(index - 4)-1 + (self.page - 1)*4 + 1] + 1].name
				serverid1 = self.data.top32[self.data.records[2*(index - 4)-1 + (self.page - 1)*4] + 1].serverid
				serverid2 = self.data.top32[self.data.records[2*(index - 4)-1 + (self.page - 1)*4 + 1] + 1].serverid
			else
				index1 = self.data.records[2*(index - 4)-1 + (self.page - 1)*4]
				index2 = self.data.records[2*(index - 4)-1 + (self.page - 1)*4 + 1]
				if index1 then
					name1 = self.data.top32[index1 + 1].name or ''
					serverid1 = self.data.top32[index1 + 1].serverid or ''
				end
				if index2 then
					name2 = self.data.top32[index2 + 1].name or ''
					serverid2 = self.data.top32[index2 + 1].serverid or ''
				end
			end
		elseif index == 7 then
			if self.data.replays[24 + (index - 6) + self.page - 1] then
				for i=1,#self.data.replays[24 + (index - 6) + self.page - 1] do
					local temp = i
					local view = createWidgetByName('panel/battle_report_card_panel.json')
					playerNameTx = tolua.cast(view:getChildByName('player_name_tx') , 'UILabel')
					playerServerNumTx = tolua.cast(view:getChildByName('player_server_num_tx') , 'UILabel')
					playNumTx = tolua.cast(view:getChildByName('play_num_tx') , 'UILabel')
					playNumTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC19'),i))
					local name = nil
					if self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16] + 1 == tonumber(self.data.replays[24 + (index - 6) +self.page - 1][i].win) + 1 then
						a = a + 1
						name = self.data.top32[self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16] + 1].name
						playerServerNumTx:setText(self.data.top32[self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16] + 1].serverid)
					else
						b = b + 1
						name = self.data.top32[self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16 + 1] + 1].name
						playerServerNumTx:setText(self.data.top32[self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16 + 1] + 1].serverid)
					end
					playerNameTx:setText(name)
					reportSv:addChildToBottom(view)
					replayBtn = tolua.cast(view:getChildByName('playback_btn') , 'UIButton')
					replayBtn:registerScriptTapHandler(function ()
						print('===================')
						print(i)
						print(temp)
						print(self.page)
						print(24 + (index - 6) + self.page - 1)
						print(self.data.replays[24 + (index - 6) + self.page - 1][i].rid)
						print('===================')
						PvpController:getReplay(function(res)
							if res.data.battle then
								GameController.clearAwardView()
								GameController.playBattle(json.encode(res.data.battle) , 5)
							end
						end,self.data.replays[24 + (index - 6) + self.page - 1][i].rid)
					end)
					GameController.addButtonSound(replayBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
				end
				name1 = self.data.top32[self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16] + 1].name
				name2 = self.data.top32[self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16 + 1] + 1].name
				serverid1 = self.data.top32[self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16] + 1].serverid
				serverid2 = self.data.top32[self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16 + 1] + 1].serverid
			else
				index1 = self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16]
				index2 = self.data.records[2*(index - 6)-1 + (self.page - 1)*2 + 16+ 1]
				if index1 then
					name1 = self.data.top32[index1 + 1].name or ''
					serverid1 = self.data.top32[index1 + 1].serverid or ''
				end
				if index2 then
					name2 = self.data.top32[index2 + 1].name or ''
					serverid2 = self.data.top32[index2 + 1].serverid or ''
				end
			end
		elseif index == 8 or index == 9 then
				if self.data.replays[28 + (index - 7)] then
					for i=1,#self.data.replays[28 + (index - 7)] do
						-- print(index)
						local view = createWidgetByName('panel/battle_report_card_panel.json')
						playerNameTx = tolua.cast(view:getChildByName('player_name_tx') , 'UILabel')
						playerServerNumTx = tolua.cast(view:getChildByName('player_server_num_tx') , 'UILabel')
						playNumTx = tolua.cast(view:getChildByName('play_num_tx') , 'UILabel')
						playNumTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC19'),i))
						local name = nil
						print(tonumber(self.data.replays[28 + (index - 7)][i].win) + 1)
						if self.data.top4[2 * (index - 7) - 1] + 1 == tonumber(self.data.replays[28 + (index - 7)][i].win) + 1 then
							a = a + 1
							name = self.data.top32[self.data.top4[2 * (index - 7) - 1] + 1].name
							playerServerNumTx:setText(self.data.top32[self.data.top4[2 * (index - 7) - 1] + 1].serverid)
						else
							b = b + 1
							name = self.data.top32[self.data.top4[2 * (index - 7)] + 1].name
							playerServerNumTx:setText(self.data.top32[self.data.top4[2 * (index - 7)] + 1].serverid)
						end
						playerNameTx:setText(name)
						reportSv:addChildToBottom(view)
						replayBtn = tolua.cast(view:getChildByName('playback_btn') , 'UIButton')
						replayBtn:registerScriptTapHandler(function ()
							PvpController:getReplay(function(res)
								if res.data.battle then
									GameController.clearAwardView()
									GameController.playBattle(json.encode(res.data.battle) , 5)
								end
							end,self.data.replays[28 + (index - 7)][i].rid)
						end)
						GameController.addButtonSound(replayBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
					end
				end
				name1 = self.data.top32[self.data.top4[2 * (index - 7) - 1] + 1].name
				name2 = self.data.top32[self.data.top4[2 * (index - 7)] + 1].name
				serverid1 = self.data.top32[self.data.top4[2 * (index - 7) - 1] + 1].serverid
				serverid2 = self.data.top32[self.data.top4[2 * (index - 7)] + 1].serverid
		elseif index == 10 then
			if self.data.replays[30 + (index - 9)] then
				for i=1,#self.data.replays[28 + (index - 7)] do
					-- print(index)
					local view = createWidgetByName('panel/battle_report_card_panel.json')
					playerNameTx = tolua.cast(view:getChildByName('player_name_tx') , 'UILabel')
					playerServerNumTx = tolua.cast(view:getChildByName('player_server_num_tx') , 'UILabel')
					playNumTx = tolua.cast(view:getChildByName('play_num_tx') , 'UILabel')
					playNumTx:setText(string.format(getLocalStringValue('E_STR_PVP_WAR_DESC19'),i))
					local name = nil
					print(self.data.replays[30 + (index - 9)][i].rid)
					print(self.data.replays[30 + (index - 9)][i].win)
					if self.data.records[29] + 1 == tonumber(self.data.replays[30 + (index - 9)][i].win) + 1 then
						a = a + 1
						name = self.data.top32[self.data.records[29] + 1].name
						playerServerNumTx:setText(self.data.top32[self.data.records[29] + 1].serverid)
					else
						b = b + 1
						name = self.data.top32[self.data.records[30] + 1].name
						playerServerNumTx:setText(self.data.top32[self.data.records[30] + 1].serverid)
					end
					playerNameTx:setText(name)
					reportSv:addChildToBottom(view)
					replayBtn = tolua.cast(view:getChildByName('playback_btn') , 'UIButton')
					replayBtn:registerScriptTapHandler(function ()
						PvpController:getReplay(function(res)
							if res.data.battle then
								GameController.clearAwardView()
								GameController.playBattle(json.encode(res.data.battle) , 5)
							end
						end,self.data.replays[30 + (index - 9)][i].rid)
					end)
					GameController.addButtonSound(replayBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
				end
			else
				index1 = self.data.records[29]
				index2 = self.data.records[30]
				if index1 then
					name1 = self.data.top32[index1 + 1].name or ''
					serverid1 = self.data.top32[index1 + 1].serverid or ''
				end
				if index2 then
					name2 = self.data.top32[index2 + 1].name or ''
					serverid2 = self.data.top32[index2 + 1].serverid or ''
				end
			end
			name1 = self.data.top32[self.data.records[29] + 1].name
			name2 = self.data.top32[self.data.records[30] + 1].name
			serverid1 = self.data.top32[self.data.records[29] + 1].serverid
			serverid2 = self.data.top32[self.data.records[30] + 1].serverid
		end
		if not name1 or not name2 or not serverid1 or not serverid2 then
			playerNameTx1:setVisible(false)
			playerNameTx2:setVisible(false)
			-- playerSeverTx1:setVisible(false)
			-- playerSeverTx2:setVisible(false)
			GameController.showPrompts(getLocalStringValue('E_STR_PVP_SUPPORT_SUCCESS'), COLOR_TYPE.RED)
			return
		else
			playerNameTx1:setVisible(true)
			playerNameTx2:setVisible(true)
			-- playerSeverTx1:setVisible(true)
			-- playerSeverTx2:setVisible(true)
		end
		local quInfo = string.format(getLocalStringValue('E_STR_GOLDMINE_DISTRICT'),'',serverid1 or 0)
		local quInfo1 = string.format(getLocalStringValue('E_STR_GOLDMINE_DISTRICT'),'',serverid2 or 0)
		playerNameTx1:setText(quInfo..(name1 or ''))
		playerNameTx2:setText((name2 or '')..quInfo1)
		-- playerSeverTx1:setText(serverid1 or '')
		-- playerSeverTx2:setText(serverid2 or '')
		playerScoreTx1:setText(a)
		playerScoreTx2:setText(b)
		reportSv:scrollToTop()
	end)
end

function PvpReportsPanel:isOpen()
	local open
	if self.data.progress == PROGRESS.SUPPORT4 or self.data.progress == PROGRESS.TO16 then
		open = 4
	elseif self.data.progress == PROGRESS.TO8 then
		open = 6
	elseif self.data.progress == PROGRESS.TO4 then
		open = 7
	elseif self.data.progress == PROGRESS.TO2 or self.data.progress == PROGRESS.SUPPORT1 then
		open = 9
	elseif self.data.progress == PROGRESS.TO1 then
		open = 10
	else
		open = 10
	end
	if self.index <= open then
		return true
	else
		return false
	end
end

function PvpReportsPanel:enter(res,index,page)
	self.data = res
	self.index = index
	self.page = page
	if self:isOpen() == true then
		PvpController.show(PvpReportsPanel, ELF_SHOW.SLIDE_IN)
	else
		GameController.showPrompts(getLocalStringValue('E_STR_PVP_WAR_DESC9'), COLOR_TYPE.RED)
	end
end