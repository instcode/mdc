function genTimeTypePanel(roleId,mineId)
	-- body
	--time ui
	local timeScene
	local timePanel 
	local timeRoot
	local timeBgImg
	local timeImg 
	local timeTitleImg
	local timeCloseBtn
	local timeRoleNameTx
	local timeOkBtn
	--驻守时间
	local timeCardImg
	local timeCardTimeTx
	--时间数组
	local timeHourTxArray = {}
	--时间单选数组
	local timeHourClickImgArray = {}
	--驻守方式
	local timeTypeCardImg
	local typeTx
	--方式单选数组
	local typeClickImgArray = {}
	--方式描述数组
	local typeTxArray = {}
	--方式花费数组
	local typeCashNumTxArray = {}
	--方式获奖时间数组
	local typeTimeTxArray = {}

	local time1Clicked = true
	local tiem2Clicked = false

	local type1Clicked = true
	local type2Clicked = false 
	local timeChoose = {}
	local typeChoose = {}
	local timePanel = {}
	local typePanel = {}


	--读表
	local patrolBattleConf = GameData:getArrayData('patrolbattle.dat')
	local patrolEventConf = GameData:getArrayData('patrolevent.dat')
	local patrolIntervalConf = GameData:getArrayData('patrolinterval.dat')
	local patrolTypeConf = GameData:getArrayData('patroltype.dat')
	local monsterConf = GameData:getArrayData('monster.dat')
	local materialConf = GameData:getArrayData('material.dat')
	local roleConf = GameData:getArrayData('role.dat')


	--时间选择
	local function onClickTimeImg(id)
		-- body
		if id == 1 then 
			time1Clicked = true
			time2Clicked = false
			timeHourClickImgArray[1]:setTexture('uires/ui_2nd/com/checkbox/click_2.png')
			timeHourClickImgArray[2]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
			timeHourClickImgArray[3]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
		elseif id == 2 then
			time1Clicked = false
			time2Clicked = true
			timeHourClickImgArray[1]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
			timeHourClickImgArray[2]:setTexture('uires/ui_2nd/com/checkbox/click_2.png')
			timeHourClickImgArray[3]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
		elseif id == 3 then
			time1Clicked = false
			time2Clicked = false
			timeHourClickImgArray[1]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
			timeHourClickImgArray[2]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
			timeHourClickImgArray[3]:setTexture('uires/ui_2nd/com/checkbox/click_2.png')
		end
	end

	--方式选择
	local function onClickTypeImg(id)
		-- body
		if id == 1 then 
			type1Clicked = true
			type2Clicked = false
			typeClickImgArray[1]:setTexture('uires/ui_2nd/com/checkbox/click_2.png')
			typeClickImgArray[2]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
			typeClickImgArray[3]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
		elseif id == 2 then
			type1Clicked = false
			type2Clicked = true
			typeClickImgArray[1]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
			typeClickImgArray[2]:setTexture('uires/ui_2nd/com/checkbox/click_2.png')
			typeClickImgArray[3]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
		elseif id == 3 then
			type1Clicked = false
			type2Clicked = false
			typeClickImgArray[1]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
			typeClickImgArray[2]:setTexture('uires/ui_2nd/com/checkbox/click_1.png')
			typeClickImgArray[3]:setTexture('uires/ui_2nd/com/checkbox/click_2.png')
		end
	end


	--刷新时间选择界面
	local function updateTimePanel(roleId,mineId)
		-- body
		local selectRoleCardObj = CLDObjectManager:GetInst():GetOrCreateObject( roleId, E_OBJECT_TYPE.OBJECT_TYPE_ROLE_CARD)
		selectRoleCardObj = tolua.cast(selectRoleCardObj,'CLDRoleCardObject')

		timeRoleNameTx:setText(selectRoleCardObj:GetRoleName())
		timeRoleNameTx:setColor(selectRoleCardObj:GetRoleNameColor())

		for i = 1,3 do
			table.foreach(patrolTypeConf,function(_ ,v)
				if v['Id'] == tostring(i) then 
					timeChoose[i] = i
					timeHourTxArray[i]:setText(string.format(getLocalStringValue('E_STR_PATROL_TIME1'),v['Duration']))
				end
			end)

			table.foreach(patrolIntervalConf,function(_ ,v)
				if v['Id'] == tostring(i) then
					typeChoose[i] = i
					typeCashNumTxArray[i]:setText(v['Cash']) 
					typeTimeTxArray[i]:setText(string.format(getLocalStringValue('E_STR_PATROL_TIME2'),v['Interval']))
				end
			end)
		end

	end

	local function sendMessage(args,costCash)
		-- body

		Message.sendPost('patrol_occupy','activity',json.encode(args),function(jsonData)
			-- body
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then 
				cclog('request error : ' .. jsonDic['desc'])
				return
			end
			PlayerCoreData.addCashDelta(-costCash)
			CUIManager:GetInstance():HideObject(timeScene,ELF_HIDE.ZOOM_OUT_FADE_OUT)
			GarrisonSelect:closeSelectPanel()
			GarrisonMinePanel:updateMinePanel()
		end)
	end

	local function onClickOKBtn()
		-- bodylocal args
		local timeV 
		local intervalV
		if time1Clicked then
			timeV = timeChoose[1]
		elseif time2Clicked then
			timeV = timeChoose[2]
		else
			timeV = timeChoose[3]
		end

		if type1Clicked then
			intervalV = typeChoose[1]
		elseif type2Clicked then
			intervalV = typeChoose[2]
		else
			intervalV = typeChoose[3]
		end

		local costCash = 0
		table.foreach(patrolIntervalConf,function(_ , v)
			-- body
			if v['Id'] == tostring(intervalV) then 
				costCash = tonumber(v['Cash'])
			end
		end)

		if PlayerCoreData.getCashValue() < costCash then 
			GameController.showPrompts(getLocalStringValue('E_STR_CASH_NOT_ENOUGH'),COLOR_TYPE.RED)
			return
		end
		args = {id = mineId,
				type = timeV,
				interval = intervalV,
				rid = roleId
		}
		sendMessage(args,costCash)
	end

	--初始化时间界面
	local function initTimePanel(roleId,mineId)
		-- body

		time1Clicked = true
		tiem2Clicked = false

		type1Clicked = true
		type2Clicked = false 

		timeRoot = timePanel:GetRawPanel()
		timeBgImg = tolua.cast(timeRoot:getChildByName('garrison_time_bg_img'),'UIImageView') 
		timeImg = tolua.cast(timeBgImg:getChildByName('garrison_time_img'),'UIImageView')
		
		timeTitleImg = tolua.cast(timeImg:getChildByName('title_img'),'UIImageView')
		timeCloseBtn = tolua.cast(timeTitleImg:getChildByName('close_btn'),'UIButton')
		timeCloseBtn:registerScriptTapHandler(function()
			CUIManager:GetInstance():HideObject(timeScene,ELF_HIDE.ZOOM_OUT_FADE_OUT)
		end)
		GameController.addButtonSound(timeCloseBtn,BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		timeRoleNameTx = tolua.cast(timeImg:getChildByName('role_name_tx'),'UILabel')
		timeOkBtn = tolua.cast(timeImg:getChildByName('ok_btn'),'UITextButton')
		timeOkBtn:registerScriptTapHandler(function()
			-- body
			onClickOKBtn()
		end)
		GameController.addButtonSound(timeOkBtn,BUTTON_SOUND_TYPE.CLICK_EFFECT)

		timeCardImg = tolua.cast(timeImg:getChildByName('time_card_img'),'UIImageView')
		timeCardTimeTx = tolua.cast(timeCardImg:getChildByName('time_tx'),'UILabel')

		timeTypeCardImg = tolua.cast(timeImg:getChildByName('typecard_img'),'UIImageView')
		typeTx = tolua.cast(timeTypeCardImg:getChildByName('type_tx'),'UILabel')
		for i = 1,3 do 
			timeHourTxArray[i] = tolua.cast(timeCardImg:getChildByName('hour_tx_' .. i),'UILabel')
			timeHourClickImgArray[i] = tolua.cast(timeCardImg:getChildByName('hour_click_img_' .. i),'UIImageView')
			timePanel[i] = tolua.cast(timeCardImg:getChildByName('time_' .. i .. '_pl'),'UIPanel')
			timePanel[i]:registerScriptTapHandler(function()
				-- body
				onClickTimeImg(i)
			end)

			typeClickImgArray[i] = tolua.cast(timeTypeCardImg:getChildByName('type_' .. i .. '_click_img'),'UIImageView')
			typePanel[i] = tolua.cast(timeTypeCardImg:getChildByName('type_' .. i .. '_pl'),'UIPanel')
			typePanel[i]:registerScriptTapHandler(function()
				-- body
				onClickTypeImg(i)
			end)

			typeTxArray[i] = tolua.cast(timeTypeCardImg:getChildByName('type_' .. i ..'_tx'),'UILabel')
			typeCashNumTxArray[i] = tolua.cast(timeTypeCardImg:getChildByName('type_' .. i .. '_cash_num_tx'),'UILabel')
			typeTimeTxArray[i] = tolua.cast(timeTypeCardImg:getChildByName('time_' .. i ..'_tx'),'UILabel')
		end
		updateTimePanel(roleId,mineId)

	end

	--创建时间选择界面
	local function createTimePanel(roleId)
		-- body
		timeScene = SceneObjEx:createObj('panel/garrison_time_panel_1.json','garrison-time-lua')
		timePanel = timeScene:getPanelObj()
		timePanel:setAdaptInfo('garrison_time_bg_img','garrison_time_img')
		timePanel:registerInitHandler(function ()
			initTimePanel(roleId,mineId)
		end)
		UiMan.show(timeScene)
	end

	createTimePanel(roleId,mineId)
end