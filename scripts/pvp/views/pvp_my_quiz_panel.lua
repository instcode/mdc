PvpMyQuizPanel = PvpView:new{
	jsonFile = 'panel/my_quiz_panel.json',
	panelName = 'my-quiz-in-lua',
	myPosition,
	myReplays = {}
}

function PvpMyQuizPanel:getSupport()
	if self.data.progress == PROGRESS.SUPPORT4 or self.data.progress == PROGRESS.TO16
	or self.data.progress == PROGRESS.TO8 
	or self.data.progress == PROGRESS.TO4 then
		return MAXPLAYER.FOR
	elseif self.data.progress == PROGRESS.SUPPORT1 
		or self.data.progress == PROGRESS.TO2 
		or self.data.progress == PROGRESS.TO1
		or self.data.progress == 'over' then
		return MAXPLAYER.ONE
	else
		return 0
	end
end

function PvpMyQuizPanel:init()
	local panel = self.sceneObject:getPanelObj()
	panel:setAdaptInfo('my_quiz_bg_img','my_quiz_img')
	panel:registerInitHandler(function()
		root = panel:GetRawPanel()

		closeBtn = tolua.cast(root:getChildByName('close_btn') , 'UIButton')
    	closeBtn:registerScriptTapHandler(function ()
			PvpController.close( self, ELF_HIDE.ZOOM_OUT_FADE_OUT )
		end)
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		helpBtn = tolua.cast(root:getChildByName('help_btn') , 'UIButton')
    	helpBtn:registerScriptTapHandler(function ()
			PvpController.show(PvpMyQuizHelpPanel, ELF_SHOW.SLIDE_IN)
		end)
		GameController.addButtonSound(helpBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

		tab = PvpData.getSupportAward(self:getSupport())
		award1 = UserData:getAward(tab.Award1)
		award2 = UserData:getAward(tab.Award2)
		award3 = UserData:getAward(tab.Award3)
		awards = {award1,award2,award3}
		awardtabs = {tab.Award1,tab.Award2,tab.Award3}
		local myQuiz = {}
		local index = 1
		for i,v in pairs(PvpController.supports) do
			player,index1 = getPlayer(v,self.data)
			if index1%8 == 0 then
				index = index1/8
			else
				index = (index1 - index1%8)/8 + 1
			end
			table.insert(myQuiz,index)
			myQuiz[index] = player
			-- index = index + 1
		end
		player,_ = getPlayer(PvpController.supports1[1],self.data)
		table.insert(myQuiz,5)
		myQuiz[5] = player
		-- for i,v in ipairs(myQuiz) do
		-- 	print(i,v)
		-- end
		for i=1,MAXPLAYER.FOR + 1 do
			str = 'card_'..i..'_pl'
			cardPanel = tolua.cast(root:getChildByName(str) , 'UIPanel')
			serverNumTx = tolua.cast(cardPanel:getChildByName('server_num_tx') , 'UILabel')
			nameTx = tolua.cast(cardPanel:getChildByName('name_tx') , 'UILabel')
			resultImg = tolua.cast(cardPanel:getChildByName('result_img') , 'UIImageView')
			fuTx = tolua.cast(cardPanel:getChildByName('fu_tx') , 'UILabel')
			if myQuiz[i] and type(myQuiz[i]) == 'table' and myQuiz[i].name then
				serverNumTx:setVisible(true)
				nameTx:setVisible(true)
				resultImg:setVisible(true)
				fuTx:setVisible(true)
				serverNumTx:setText(tostring(myQuiz[i].serverid) or '')
				nameTx:setText(tostring(myQuiz[i].name) or '')
				local isOK = false
				if i == 5 then
					if not self.data.records[31] or self.data.records[31] == -1 then
						resultImg:setTexture('uires/ui_2nd/com/panel/pvp/pending.png')
						isOK = true
					elseif tonumber(myQuiz[i].uid) == tonumber(self.data.top32[self.data.records[31] + 1].uid) then
						resultImg:setTexture('uires/ui_2nd/com/panel/pvp/success.png')
						isOK = true
					else
						resultImg:setTexture('uires/ui_2nd/com/panel/pvp/fail.png')
						-- isOK = true
					end			
				else
					for j=25,28 do
						if isOK == false then
							if not self.data.records[j] or self.data.records[j] == -1 then
								resultImg:setTexture('uires/ui_2nd/com/panel/pvp/pending.png')
								isOK = true
							elseif tonumber(myQuiz[i].uid) == tonumber(self.data.top32[self.data.records[j] + 1].uid) then
								resultImg:setTexture('uires/ui_2nd/com/panel/pvp/success.png')
								isOK = true
							else
								resultImg:setTexture('uires/ui_2nd/com/panel/pvp/fail.png')
								-- isOK = true
							end
						end
					end
				end
			else
				serverNumTx:setVisible(false)
				nameTx:setVisible(false)
				resultImg:setVisible(false)
				fuTx:setVisible(false)
			end
		end

		for i=1,3 do
			str = 'award_frame_'..i..'_img'
			photoIco = tolua.cast(root:getChildByName(str) , 'UIImageView')
			awardIco = tolua.cast(photoIco:getChildByName('award_ico') , 'UIImageView')
			numberTx = tolua.cast(photoIco:getChildByName('num_tx') , 'UILabel')
			numberTx:setText(toWordsNumber(tonumber(awards[i].count)))
			awardIco:setTexture(awards[i].icon)
			awardIco:registerScriptTapHandler(function()
				UISvr:showTipsForAward(awardtabs[i])
			end)
		end
	end)
end

function PvpMyQuizPanel:enter(res)
	self.data = res
	PvpController.show(PvpMyQuizPanel, ELF_SHOW.SLIDE_IN)
end