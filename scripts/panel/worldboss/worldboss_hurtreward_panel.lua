genBossHurtRewardPanel = function( enterType )
	-- ui
	local root
	local itemSv
	local timeCDTx
	-- data

	local function getChild( parent , name , ttype )
		return tolua.cast(parent:getChildByName(name) , ttype)
	end

	-- return : 0 , 1 , 2
	local function getRewardStatus()
		if enterType == 'battle' then
			return 0
		else
			local hurt = wBossData:getData().rewards.hurt or 0
			if hurt == 0 then
				local hurtConf = GameData:getArrayData('worldbosshurt.dat')
				local finishOne = false
				local last_hurt = tonumber(wBossData:getData().last_hurt)
				table.foreach(hurtConf , function(key , value)
					if last_hurt >= tonumber(value['Rank']) and not finishOne then
						finishOne = true
					end
				end)

				if finishOne then
					return 1 	-- 可领取
				else
					return 0	-- 未达成
				end
			elseif hurt == 1 then
				return 2 		-- 已领取
			end
			return 0
		end
	end
	
	local function genRewardItem()
		itemSv:removeAllChildrenAndCleanUp(true)

		local last_hurt = 0
		if enterType == 'battle' then
			last_hurt = tonumber(wBossData:getData().battle_info.hurt)
		elseif enterType == 'main' then
			last_hurt = tonumber(wBossData:getData().last_hurt)
		end

		local hurtConf = GameData:getArrayData('worldbosshurt.dat')
		local index = 0
		table.foreach(hurtConf , function(key , value)
			local pItem = createWidgetByName('panel/boss_hurtreward_cell.json')
			if not pItem then
				cclog('failed to create boss_hurtreward_cell!!')
			else
				local numIco = getChild(pItem , 'rank_num_ico' , 'UIImageView')
				local hurtTx = getChild(pItem , 'info_tx' , 'UILabel')
				local hurtBarBg = getChild(pItem , 'exp_bg_img' , 'UIImageView')
				local hurtBar = getChild(hurtBarBg , 'exp_bar' , 'UILoadingBar')
				local hurtBarTx = getChild(hurtBarBg , 'exp_num_tx' , 'UILabel')
				local statusIco = getChild(pItem , 'open_ico' , 'UIImageView')

				numIco:setTexture('uires/ui_2nd/com/panel/boss/award_lv_' .. ( index + 1 ) .. '.png')
				hurtTx:setText(string.format(getLocalString('E_STR_HURT_REACH_VALUE') , tostring(tonumber(value['Rank']) / 10000)))
				local percent = last_hurt / tonumber(value['Rank']) * 100
				if percent > 100 then
					percent = 100
				end
				hurtBar:setPercent( percent )
				local showValue = last_hurt
				if showValue >= tonumber(value['Rank']) then
					showValue = tonumber(value['Rank'])
					statusIco:setTexture('uires/ui_2nd/com/panel/common/checkmark.png')
				else
					statusIco:setTexture('uires/ui_2nd/com/panel/fb/lock.png')
				end
				hurtBarTx:setText(tostring(showValue) .. '/' .. tostring(value['Rank']))

				for i = 1 , 2 do
					local item = getChild(pItem , 'item_photo_' .. i .. '_ico' , 'UIImageView')
					local photo = getChild(item , 'item_ico' , 'UIImageView')
					local numTx = getChild(item , 'num_tx' , 'UILabel')
					local awardStr = value['Award' .. i]
					local award = UserData:getAward( awardStr )
					photo:setTexture( award.icon )
					numTx:setText( toWordsNumber(award.count) )
					photo:registerScriptTapHandler( function ()
						UISvr:showTipsForAward( awardStr )
					end)
				end

				itemSv:addChildToBottom(pItem)
				index = index + 1
			end
		end)
		itemSv:scrollToTop()
	end

	local function update()
		local noticeTx = getChild(root , 'notice_tx' , 'UILabel')
		local cdDescTx = getChild(root , 'time_txt_tx' , 'UILabel')
		local cdParentTx = getChild(root , 'cd_time_tx' , 'UILabel')
		local getRewardBtn = getChild(root , 'get_award_btn' , 'UITextButton')

		noticeTx:setVisible(true)
		cdDescTx:setVisible(true)
		cdParentTx:setVisible(true)
		getRewardBtn:setVisible(true)
		getRewardBtn:active()

		local status = getRewardStatus()
		local progress , leftTime = wBossData:getProgress()

		if enterType == 'battle' then
			noticeTx:setVisible(false)
			getRewardBtn:disable()
			cdDescTx:setText(getLocalString('E_STR_WORLDBOSS_WARING'))
		else
			if status == 0 then			-- 未领取
				noticeTx:setText( getLocalString('E_STR_ACTIVITY_END_DESC') )
				getRewardBtn:disable()
				cdDescTx:setVisible(false)
				cdParentTx:setVisible(false)
			elseif status == 1 then		-- 可领取
				noticeTx:setVisible(false)
				timeCDTx:setTime(leftTime)
				cdDescTx:setText(getLocalString('E_STR_CLEAR_REWARD_CD_DESC'))
			elseif status == 2 then		-- 已领取
				noticeTx:setText( getLocalString('E_STR_ACTIVITY_END_AND_GET_REWARD_DESC') )
				getRewardBtn:setVisible(false)
				cdParentTx:setVisible(false)
				cdDescTx:setVisible(false)
			end
			
		end
	end

	local function updatePanel()
		update()
	end

	local function getRewardRequest()
		local args = {type = 'hurt'}

		Message.sendPost('get_rewards','worldboss',json.encode(args),function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']
			if data['awards'] then
				local tab = {}
				for k , v in pairs ( data['awards'] ) do
					local awardStr = v[1] .. '.' .. v[2] .. ':' .. v[3]
					table.insert(tab , awardStr)
				end
				genShowTotalAwardsPanel(tab , '')
				UserData.parseAwardJson(json.encode(data['awards']))
			end

			if data['ball'] then
				local messages = {}
				for k , v in pairs( data['ball'] ) do
					local newNum = wBossData:getData().dragon_balls[tostring(k)] or 0 + tonumber(v)
					wBossData:getData().dragon_balls[tostring(data['ball'])] = newNum
					local str = string.format( getLocalString('E_STR_EXTRA_GAIN_BALL_DESC') , tonumber(v),k)
					table.insert(messages , str)
				end
				GameController.showPrompts( messages , COLOR_TYPE.GREEN )
			end
		
			wBossData:getData().rewards['hurt'] = 1

			updatePanel()
		end)
	end

	local function createPanel()
		local sceneObj = SceneObjEx:createObj('panel/boss_hurtreward_panel.json' , 'bosshurtrewardpanel-in-lua')
		local panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('di_bg_img' , 'di_img')

		panel:registerInitHandler(function ()
			root = panel:GetRawPanel()
			local bg = getChild(root ,'di_bg_img' , 'UIImageView')
			itemSv = getChild(bg , 'card_sv' , 'UIScrollView')
			itemSv:setClippingEnable(true)

			local closeBtn = getChild(bg ,'close_btn' , 'UIButton')
			closeBtn:registerScriptTapHandler(function()
				CUIManager:GetInstance():HideObject(sceneObj, ELF_SHOW.NORMAL)
				worldboss.enter()
			end)

			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			local getRewardBtn = getChild(root , 'get_award_btn' , 'UITextButton')
			getRewardBtn:registerScriptTapHandler(function ()
				getRewardRequest()
			end)
			GameController.addButtonSound(getRewardBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			local cdParentTx = getChild(root , 'cd_time_tx' , 'UILabel')

			timeCDTx = UICDLabel:create()
			timeCDTx:setFontSize(28)
			timeCDTx:setPosition(ccp(0,0))
			timeCDTx:setFontColor(COLOR_TYPE.WHITE)
			cdParentTx:addChild(timeCDTx)
			timeCDTx:registerTimeoutHandler( function ()
				getRewardBtn:disable()
			end)

			genRewardItem()

			updatePanel()
		end)

		UiMan.show(sceneObj)
	end

	createPanel()
end