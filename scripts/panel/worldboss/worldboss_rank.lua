genWorldBossRankPanel = function()
	-- const
	local NUM = 8
	-- ui
	local root
	-- data
	local rankData
	local bossBlood
	local curPage = 1

	local function getChild( parent , name , ttype )
		return tolua.cast(parent:getChildByName(name) , ttype)
	end

	local function updatePageBtn()
		local totalPage = math.floor(#rankData / NUM) + 1

		local leftBtn = getChild(root , 'left_btn' , 'UIButton')
		local rightBtn = getChild(root , 'right_btn' , 'UIButton')
		local pageTx = getChild(root , 'turning_tx' , 'UILabel')

		leftBtn:active()
		rightBtn:active()

		if curPage <= 1 then
			leftBtn:disable()
		end
		if curPage >= totalPage then
			rightBtn:disable()
		end

		pageTx:setText( curPage .. '/' .. totalPage )
	end

	local function updatePage()
		for i = 1 , NUM do
			local item = getChild(root , 'item_' .. i , 'UIPanel')
			local rankTx = getChild( item , 'rank_tx' , 'UILabel')
			local nameTx = getChild( item , 'name_tx' , 'UILabel')
			local hurtBar = getChild( item , 'hurt_bar' , 'UILoadingBar')
			local hurtTx = getChild( hurtBar , 'hurt_tx' , 'UILabel')
			hurtTx:setFontSize(19)

			local curIndex = (curPage - 1) * NUM + i
			if rankData[curIndex] then
				item:setVisible(true)
				rankTx:setText( tostring(curIndex) )
				nameTx:setText( rankData[curIndex]['name'] or '')

				local percent = nil
				if rankData[1]['hurt'] == 0 then
					percent = 0
				else
					percent = tonumber(rankData[curIndex]['hurt']) / rankData[1]['hurt'] * 100
				end
				
				local perStr = '0.00'
				if percent > 0 then
					perStr = string.format( '%0.2f' , percent)
					if tonumber(perStr) < 0.01 then
						perStr = '0.01'
					end
					if tonumber(perStr) == 100 and tonumber(rankData[curIndex]['hurt']) < rankData[1]['hurt'] then
						perStr = tostring(100.00 - (#rankData - 1) * 0.01)
					end
				end

				hurtBar:setPercent( percent )
				hurtTx:setText(rankData[curIndex]['hurt'])
			else
				item:setVisible(false)
			end
		end
	end

	local function updatePanel()
		updatePage()
		updatePageBtn()
	end

	local function createPanel()
		local sceneObj = SceneObjEx:createObj('panel/boss_hurtrank_panel.json' , 'bosshurtrankpanel-in-lua')
		local panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('challenge_bg_img' , 'challenge_img')

		panel:registerInitHandler(function ()
			root = panel:GetRawPanel()
			local bg = getChild(root ,'challenge_bg_img' , 'UIImageView')
			local bossbg = getChild(bg ,'challenge_img' , 'UIImageView')
			local Titlebg = getChild(bossbg ,'title_img' , 'UIImageView')
			local closeBtn = getChild(Titlebg ,'close_btn' , 'UIButton')
			closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
			GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

			local leftBtn = getChild(bossbg , 'left_btn' , 'UIButton')
			local rightBtn = getChild(bossbg , 'right_btn' , 'UIButton')
			leftBtn:registerScriptTapHandler(function ()
				curPage = curPage - 1
				updatePanel()
			end)
			rightBtn:registerScriptTapHandler(function ()
				curPage = curPage + 1
				updatePanel()
			end)
			GameController.addButtonSound(leftBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			GameController.addButtonSound(rightBtn , BUTTON_SOUND_TYPE.CLICK_EFFECT)

			updatePanel()
		end)

		UiMan.show(sceneObj)
	end

	local function getWorldBossRankRequest()
		Message.sendPost('get_ranks','worldboss',json.encode('{}'),function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']
			rankData = data.ranks
			bossBlood = tonumber(data.boss_blood)

			createPanel()
		end)
	end

	getWorldBossRankRequest()
end