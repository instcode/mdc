
SummerDays = {}

function SummerDays.isActive()

end

-- TODO: 判断活动是否结束
function SummerDays.isOverTime()
	local data = GameData:getArrayData('activities.dat')
	local conf
	table.foreach(data , function (_ , v)
		if v['Key'] == 'summer_days' then
			conf = v
		end
	end)

	if conf == nil then
		return true
	end

	if tonumber(conf.Normalization) == 0 then -- 非常态活动
        local actyStartTime
        local actyEndTime
        if conf.StartTime ~= nil and conf.StartTime ~= '' then -- 优先判断StartTime字段
            actyStartTime = UserData:convertTime(1, conf.StartTime)
            actyEndTime = UserData:convertTime(1, conf.EndTime)
        else
            local serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
            actyStartTime = serverOpenTime + (tonumber(conf.OpenDay) - 1)*86400
            actyEndTime = serverOpenTime + (tonumber(conf.OpenDay) + tonumber(conf.Duration) - 1)*86400
        end
        local nowTime = UserData:getServerTime()
        if nowTime < actyStartTime or nowTime > actyEndTime then
            return true
        end
    else    -- 常态活动
        if conf.StartTime ~= nil and conf.StartTime ~= '' then
            local time = UserData:getServerTime()
            local startTime = UserData:convertTime(1,conf.StartTime)
            local endTime = UserData:convertTime(1,conf.EndTime)
            if time < startTime or time > endTime then
                return true
            end
        end
    end
    return false
end

function SummerDays.enter()
	-- const
	local SPECIAL_ID = 777			-- 累计充值7天奖励id
	local DAYS = 7
	local FILENAME = 'summerdays.dat'
	-- ui
	local sceneObj
	local panel
	local root
	local payCashTx
	local getRoleBtn
	local progressTx
	local dateDescTx
	local showLight
	-- data
	local payCash			-- 当前充值数量
	local payDays			-- 充值天数
	local got 				-- 领取状态map
	local roleGot = {}		-- 武将是否领取
	local roleData
	local originPoint = {}
	local selectIndex = 1


	local function getChild( parent , name , ttype )
		return tolua.cast(parent:getChildByName(name) , ttype)
	end

	local function getConfData( id )
		local conf = GameData:getArrayData( FILENAME )
		local data
		table.foreach(conf , function (_ , v)
			if tonumber(id) == tonumber(v.Id) then
				data = v
			end
		end)
		return data
	end

	local function makeData( n )
		local tab = {}
		local b
		while n > 0 do
			n , b = math.floor( n / 2) , n % 2
			table.insert(tab , b)
		end
		return tab
	end

	-- 判断活动是否结束
	local function judgeOverTime()
		if SummerDays.isOverTime() then
			GameController.showPrompts(getLocalStringValue('E_STR_ACTIVITY_TIMEOUT_DESC'), COLOR_TYPE.RED)
			return true
		end
		return false
	end

	local function update()
		for i = 1 , DAYS do
			local item = getChild(root , 'tian_' .. i .. '_img', 'UIImageView')
			local cashTx = getChild(item , 'cash_tx' , 'UILabel')
			local getBtn = getChild(item , 'receive_btn' , 'UIButton')
			local rewardTx = getChild(item , 'receive_tx' , 'UILabel')
			local okIcon = getChild(item , 'receive_icon' , 'UIImageView')
			local rechargeTx = getChild(item , 'recharge_tx' , 'UILabel')
			local cashIcon = getChild(item , 'cash_icon' , 'UIImageView')

			getBtn:registerScriptTapHandler(function ()
				if judgeOverTime() then
					return
				end
				local id = i
				local tab = {day = id}
				Message.sendPost('summer_days_gain','activity', json.encode(tab) ,function (jsonData)
					cclog(jsonData)
					local jsonDic = json.decode(jsonData)
					if jsonDic['code'] ~= 0 then
						cclog('request error : ' .. jsonDic['desc'])
						return
					end

					local data = jsonDic['data']
					local awards = data['awards']
					local awardStr = json.encode(awards)
					UserData.parseAwardJson(awardStr)

					GameController.showPrompts(getLocalStringValue('E_STR_GET_SUCCEED'), COLOR_TYPE.GREEN)

					got[id] = 1 	-- 更新状态
					update()
				end)
			end)

			local data = getConfData( i )
			local needCash = tonumber(data['Cash'])

			if payCash < needCash then
				if originPoint[i] == nil then
					originPoint[i] = item:getPosition()
				end
				item:setPosition(ccp(originPoint[i].x - 5 , originPoint[i].y - 17))
				getBtn:setVisible(false)
				okIcon:setVisible(false)
			else
				if got[i] == 1 then
					rewardTx:setVisible(false)
					okIcon:setVisible(true)
					getBtn:setVisible(false)
					rechargeTx:setVisible(false)
					cashIcon:setVisible(false)
					cashTx:setVisible(false)
				else
					okIcon:setVisible(false)
					getBtn:setVisible(true)
				end
			end

			local award = UserData:getAward( tostring( data['Award1']) )
			local awardStr = award.name .. 'x' .. award.count
			rewardTx:setText(awardStr)
			cashTx:setTextFromInt(needCash)
			cashTx:setColor(GameController.getCCColor('orange'))
		end

		payCashTx:setTextFromInt( payCash )
	    payCashTx:setColor(GameController.getCCColor('orange'))
		progressTx:setText( string.format(getLocalString('E_STR_COUNTDAY_DESC'), tostring(payDays .. '/' .. DAYS)) )

		local conf = GameData:getArrayData('activities.dat')
		local data
		table.foreach(conf , function (_ , v)
			if v['Key'] == 'summer_days' then
				data = v
			end
		end)

		dateDescTx:setText('')
		if data then
			local actyStartTime
	        local actyEndTime
	        if data.StartTime ~= nil and data.StartTime ~= '' then -- 优先判断StartTime字段
	            actyStartTime = UserData:convertTime(1, data.StartTime)
	            actyEndTime = UserData:convertTime(1, data.EndTime)
	        else
	            local serverOpenTime = Time.beginningOfOneDay(UserData:getOpenServerDays())
	            actyStartTime = serverOpenTime + (tonumber(data.OpenDay) - 1)*86400
	            actyEndTime = serverOpenTime + (tonumber(data.OpenDay) + tonumber(data.Duration) - 2)*86400
	        end
	        local sTab = os.date('*t', actyStartTime )
	        local eTab = os.date('*t', actyEndTime )
			dateDescTx:setText(string.format(getLocalString('E_STR_ACTIVITY_TIEM_DESC'), tonumber(sTab.month) , tonumber(sTab.day) ,tonumber(eTab.month) , tonumber(eTab.day)))
		end

		local specialData = getConfData( SPECIAL_ID )

		local function updateRolePanelStatus()
			local daysTx = getChild( root , 'pay_days_tx' , 'UILabel')
			local roleNameTx = getChild( root , 'role_name_tx' , 'UILabel')
			local roleItem = getChild( root , 'photo_' .. selectIndex .. '_ico' , 'UIImageView')

			local needDays = getGlobalIntegerValue('GetRoleNeedDays_' .. selectIndex)
			daysTx:setText( tostring(needDays) )
			daysTx:setColor( ccc3(0 , 128 , 0) )

			local roleData = UserData:getAward( specialData['Award' .. selectIndex] )
			roleNameTx:setText( roleData.name )
			roleNameTx:setColor( COLOR_TYPE.RED )

			showLight:setPosition( roleItem:getPosition() )

			getRoleBtn:active()
			if payDays < needDays then
				getRoleBtn:setText(getLocalString('E_STR_GOTO_PAY'))
			else
				if roleGot[selectIndex] == 1 then
					getRoleBtn:setText(getLocalString('E_STR_ARENA_GOT_REWARD'))
					getRoleBtn:disable()
				else
					getRoleBtn:setText( string.format(getLocalString('E_STR_GETAWARD_DESC') , roleData.name) )
				end
			end
		end

		local function updateRolePanel()
			for i = 1 , 3 do
				local roleItem = getChild( root , 'photo_' .. i .. '_ico' , 'UIImageView')
				local ico = getChild( roleItem , 'award_ico' , 'UIImageView')
				roleItem:registerScriptTapHandler(function ()
					if selectIndex ~= i then
						selectIndex = i
						updateRolePanelStatus()
					end
				end)
				local roleData = UserData:getAward( specialData['Award' .. i] )
				ico:setTexture( roleData.icon )
			end
		end

		updateRolePanel()
		updateRolePanelStatus()
	end

	local function init()
		root = panel:GetRawPanel()
		local closeBtn = getChild(root ,'close_btn' , 'UIButton')
		closeBtn:registerScriptTapHandler(UiMan.genCloseHandler(sceneObj))
		GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)

		payCashTx = getChild(root , 'paycash_tx' , 'UILabel')
		getRoleBtn = getChild(root , 'getrole_btn' , 'UITextButton')
		progressTx = getChild(root , 'day_num_tx' , 'UILabel')
		dateDescTx = getChild(root , 'activity_date_tx' , 'UILabel')

		local roleIco = getChild(root , 'role_img' , 'UIImageView')

		local data = getConfData( SPECIAL_ID )
		roleData = UserData:getAward( data.Award1 )
		local url = string.gsub(roleData.icon , '_icon' , '_big')
		roleIco:setTexture(url)

		local sevenImg = getChild( root , 'seven_img' , 'UIImageView')
		showLight = CUIEffect:create()
		showLight:Show('yellow_light' , 0)
		showLight:setScale(0.77)
		showLight:setZOrder( 999 )
		sevenImg:getContainerNode():addChild( showLight )

		getRoleBtn:registerScriptTapHandler(function ()
			if judgeOverTime() then
				return
			end

			local needDays = getGlobalIntegerValue('GetRoleNeedDays_' .. selectIndex)
			if payDays < needDays then
				CUIManager:GetInstance():HideObject(sceneObj, ELF_HIDE.HIDE_NORMAL)
				genCashBoard( ELF_SHOW.SMART)
				return
			end

			local args = { pos = selectIndex }

			Message.sendPost('summer_days_role','activity', json.encode(args), function (jsonData)
				cclog(jsonData)
				local jsonDic = json.decode(jsonData)
				if jsonDic['code'] ~= 0 then
					cclog('request error : ' .. jsonDic['desc'])
					return
				end

				local data = jsonDic['data']
				local awards = data['awards']
				local awardStr = json.encode(awards)
				UserData.parseAwardJson(awardStr)

				GameController.showAwardsFlowText( awards )

				getRoleBtn:setText(getLocalString('E_STR_ARENA_GOT_REWARD'))
				getRoleBtn:disable()
				roleGot[selectIndex] = 1
			end)
		end)

		update()
	end

	local function createPanel()
		sceneObj = SceneObjEx:createObj('panel/summerday_panel.json' , 'SummerDays-in-lua')
		panel = sceneObj:getPanelObj()
		panel:setAdaptInfo('seven_bg_img' , 'seven_img')

		panel:registerInitHandler(init)

		UiMan.show(sceneObj)
	end

	local function getSummerDaysRequest()
		Message.sendPost('summer_days_get','activity','{}',function (jsonData)
			cclog(jsonData)
			local jsonDic = json.decode(jsonData)
			if jsonDic['code'] ~= 0 then
				cclog('request error : ' .. jsonDic['desc'])
				return
			end

			local data = jsonDic['data']['summer_days']
			payCash = tonumber(data.cash) or 0
			payDays = tonumber(data.days) or 0
			if payDays > DAYS then
				payDays = DAYS
			end
		 	roleGot = data['role_got']
			local sgot = tonumber(data.got) or 0
			got = makeData( sgot )

			createPanel()
		end)
	end

	-- 入口
	getSummerDaysRequest()
end