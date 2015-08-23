Rankgifs = {
	rankSv = nil 
}	

function Rankgifs:getPCard(data,awardsConf,rankdesc)
	self.rankSv:removeAllChildrenAndCleanUp(true)
	for i = 1 , 10 do
		pCard = createWidgetByName('panel/rankgifs_card_panel.json')
		if not pCard then
			print('failed to create rankgifs_card_panel!!!!!')
		else
			local rankTx = tolua.cast(pCard:getChildByName('top_num_tx'),'UILabel')
			local kingIcon = tolua.cast(pCard:getChildByName('king_ico'),'UIImageView')
			local desctx = tolua.cast(pCard:getChildByName('rechangedesc_tx'),'UILabel')
			desctx:setText(rankdesc)
			if i == 1 or i ==2 or i == 3 then
				rankTx:setVisible(false)
				kingIcon:setVisible(true)
				kingIcon:setTexture('uires/ui_2nd/com/panel/trena/'..i..'.png')
			else
				rankTx:setVisible(true)
				kingIcon:setVisible(false)
				rankTx:setText(string.format(getLocalStringValue('E_STR_ARENA_NRANK') , i))
			end

			local rankName = {}
			rankName[i] = tolua.cast(pCard:getChildByName('name_tx'),'UILabel')
			local ranknum = {}
			ranknum[i] = tolua.cast(pCard:getChildByName('rechangenum_tx'),'UILabel')
			local rankDataDecode = json.decode(data)
			--for i = 1 , #rankDataDecode do
			if i <= #data then
				rankName[i]:setText(data[i]['name'])
				ranknum[i]:setText(data[i]['cash'])
			else
				rankName[i]:setText(getLocalString('E_STR_WELFARE_NORANK1'))
				ranknum[i]:setText('0')
			end

			--从表里读取奖励，放到card里，表中需要Id列
			local awards = {}
			for _,v in pairs(awardsConf) do
				if tonumber(v['Rank']) == tonumber(i) then
					awards = {v['Award1'],v['Award2'],v['Award3'],v['Award4']}
					for j = 1 , #awards do
						local awardTmp = UserData:getAward(awards[j])
						local item = tolua.cast(pCard:getChildByName('photo_'..j..'_ico'),'UIImageView')
						local itemIcon = tolua.cast(item:getChildByName('award_ico'),'UIImageView')
						itemIcon:setTexture(awardTmp.icon)
						local itemNum = tolua.cast(item:getChildByName('number_tx'),'UILabel')
						itemNum:setText(toWordsNumber(tonumber(awardTmp.count)))
						--查看奖励
						item:registerScriptTapHandler(function ()
							UISvr:showTipsForAward(awards[j])
						end)
					end
				end
			end
			pCard:setPosition(ccp(10 , -200-160*i+400))
			pCard:setAnchorPoint(ccp(0.5,0.5))
			self.rankSv:addChild(pCard)
		end
	end
	self.rankSv:scrollToTop()
end
--排行榜界面
function Rankgifs:show(tipRes,data,callbackfunc,awardsConf,rankdesc,mssagedesc,activityname)
	-- 初始化界面

		local sceneObjRank = SceneObjEx:createObj('panel/rankgifs_main_panel.json','rankgifs_main_panel-in-lua')
		local panelRank = sceneObjRank:getPanelObj()
		panelRank:setAdaptInfo('top_ranking_bg_img','top_ranking_img')

		panelRank:registerInitHandler(function ()
			local rootRank = panelRank:GetRawPanel()
			local titleImg = tolua.cast(rootRank:getChildByName('rank_txt_ico'),'UIImageView')
			if tipRes ~= nil then
				titleImg:setTexture(tipRes)
			else
				error('have no tipRes')
			end
			local activitdata = GameData:getArrayData('activities.dat')
			local conf
			table.foreach(activitdata , function (_ , v)
				if v['Key'] == activityname then
					conf = v
				end
			end)


			local closeBtn = tolua.cast(rootRank:getChildByName('close_btn'), 'UIButton')
			closeBtn:registerScriptTapHandler(function()
				if callbackfunc then
					callbackfunc()
				end
				CUIManager:GetInstance():HideObject(sceneObjRank, ELF_SHOW.NORMAL)
				end)
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			local genBtn = tolua.cast(rootRank:getChildByName('get_award_btn'),'UITextButton')
			GameController.addButtonSound(genBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			genBtn:registerScriptTapHandler(function ()
				local timeDiff = UserData:convertTime( 1 , conf.EndTime ) - UserData:getServerTime()
					if timeDiff >= 0 then 
						GameController.showPrompts(getLocalString('E_STR_NOTATTHETIME'),COLOR_TYPE.RED)
						return
					end
					Message.sendPost(tostring(mssagedesc),'activity','{}',function( jsonData )
						cclog(jsonData)
						local jsonDic = json.decode(jsonData)
						if jsonDic.code ~= 0 then
							return
						end
						local data = jsonDic.data
						local awards = data['awards']
					    local awardStr = json.encode(awards)
						GameController.showPrompts(getLocalString('E_STR_GET_SUCCEED'),COLOR_TYPE.GREEN)
						UserData.parseAwardJson(awardStr)
						genBtn:disable()
						genBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
				end)
			end)
			for i= 1 , #data do
				if PlayerCoreData.getUID() == tonumber(data[i]['uid']) then
					if tonumber(data[i]['got']) == 1 then
						genBtn:disable()
						genBtn:setText(getLocalStringValue('E_STR_ARENA_GOT_REWARD'))
					else
						genBtn:active()
						genBtn:setText(getLocalStringValue('E_STR_ARENA_CAN_GET'))
					end
				end
			end
			self.rankSv = tolua.cast(rootRank:getChildByName('card_sv'),'UIScrollView')
			self.rankSv:setClippingEnable(true)
			self.rankSv:setDirection(SCROLLVIEW_DIR_VERTICAL)
			self:getPCard(data,awardsConf,rankdesc)
		end)

		UiMan.show(sceneObjRank)
end