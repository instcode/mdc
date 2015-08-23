UserData = {}

-- 获取签到数据
function UserData:getSignInData()
	local userData = CUserdata:GetInst()
	local dataJson = userData:getSignInJsonData()
	return json.decode(dataJson)
end

function UserData:setSignInData( str )
	CUserdata:GetInst():setSignInJsonData(str)
end

-- 获取连续登陆数据
function UserData:getLoginData()
	local userData = CUserdata:GetInst()
	local dataJson = userData:getLoginJsonData()
	return json.decode(dataJson)
end

function UserData:setLoginData( str )
	CUserdata:GetInst():setLoginJsonData(str)
end

-- 获取活跃度数据
function UserData:getDailyTaskData()
	local userData = CUserdata:GetInst()
	local dataJson = userData:getDailyTaskJsonData()
	return json.decode(dataJson)
end

function UserData:setDailyTaskData( str )
	CUserdata:GetInst():setDailyTaskJsonData(str)
end

-- 获取保护献帝数据
function UserData:getProtectData()
	local userData = CUserdata:GetInst()
	local dataJson = userData:getProtectJsonData()
	return json.decode(dataJson)
end

function UserData:setProtectData( str )
	CUserdata:GetInst():setProtectJsonData(str)
end

-- 获取卡牌大师数据
function UserData:getCardMasterData()
	local userData = CUserdata:GetInst()
	local dataJson = userData:getCardMasterJsonData()
	return json.decode(dataJson)
end

function UserData:getTeam(i)
	local index = CUserdata:GetInst():getTeam(i)
	return index
end

function UserData:setCardMasterData( str )
	CUserdata:GetInst():setCardMasterJsonData(str)
end

-- 获取琳琅当铺数据
function UserData:getPawnData()
	local userData = CUserdata:GetInst()
	local dataJson = userData:getPawnJsonData()
	return json.decode(dataJson)
end

function UserData:setPawnData( str )
	CUserdata:GetInst():setPawnJsonData(str)
end

-- 获取挑战重楼数据
function UserData:getChallengeTowerData()
	local userData = CUserdata:GetInst()
	local dataJson = userData:getChallengeTowerJsonData()
	return json.decode(dataJson)
end

function UserData:setChallengeTowerData( str )
	CUserdata:GetInst():setChallengeTowerJsonData( str )
end

-- 获取SMark数据
function UserData:getMarkData()
	local userData = CUserdata:GetInst()
	local dataJson = userData:getMarkJsonData()
	return json.decode(dataJson)
end

function UserData:setMarkData( str )
	CUserdata:GetInst():setMarkJsonData(str)
end

-- 获取系统奖励数据
function UserData:getSystemRewardData()
	local userData = CUserdata:GetInst()
	local dataJson = userData:getSystemRewardJsonData()
	local systemRewardData = {}
	if dataJson ~= '' then
		systemRewardData = json.decode(dataJson)
	end
	return systemRewardData
end

function UserData:setSystemRewardData( str )
	CUserdata:GetInst():setSystemRewardJsonData(str)
end

function UserData.parseAwardJson( str )
	LD_TOOLS:ParseAwardJson(str)
end

function UserData.makeAwardStr( table )
   local vStr = table[1] .. '.' .. table[2] .. ':' .. table[3]  
   return vStr
end

-- 检验cdkey
function UserData:getExchangeCDKey( str )
	local vStr = CUserdata:GetInst():getExchangeCDKey(str)
	return vStr
end

-- 获取消息数据
function UserData:getNewsData()
	local newsMgr = CNewsMgr:GetInst():GetNewsData()
	local newsData = nil
	if newsMgr then
		newsData = newsMgr:getNewsJsonData()
	end
	return newsData
end

-- 获取系统时间
function UserData:getServerTime()
	local serverTime =  CUserdata:GetInst():getServerTime()
	return serverTime
end

-- 获取武圣争霸时间
function UserData:getOpenServerWarDays()
	return UserData.serverWarTime
end

function UserData:setOpenServerWarDays(jsonData)
	local data = json.decode(jsonData)
	UserData.serverWarTime = tonumber(data.time)
end

-- 获取开服时间
function UserData:getOpenServerDays()
	return UserData.serverTime
end

function UserData:setOpenServerDays(jsonData)
	print('==============')
	print(jsonData)
	print('==============')
	local data = json.decode(jsonData)
	UserData.serverTime = tonumber(data.time)
end

-- 获取mark数据(不通过c++)
function UserData:getLuaMarkData()
	return UserData.mark
end

function UserData:setLuaMarkData(jsonData)
	local data = json.decode(jsonData)
	UserData.mark = data
end

function UserData:getShopData( Category1 , Category2 , Category3 )
	local conf = GameData:getArrayData('shop.dat')
	for _, v in pairs ( conf ) do
		if tostring(v.Category1) == tostring(Category1) and tostring(v.Category2) == tostring(Category2) and tostring(v.Category3) == tostring(Category3) then
			return v
		end
	end
	return nil
end

function UserData:setLuaActivityData(jsonData)
	local data = json.decode(jsonData)
	UserData.activity = data
end

function UserData:getLuaActivityData()
	return UserData.activity
end

-- 时间转换：返回字符串描述的时间的秒数
-- ttype == 1  <------>  timeStr format : 2014:5:22:0:0:0
-- ttype == 2  <------>  timeStr format : 20140522
function UserData:convertTime( ttype , timeStr )
	if ttype == 1 then
		local dateTab = string.split(timeStr , ':')
		local length = #dateTab
		if length < 6 then
			return 0
		end
	    local tab = {}
	    tab['year'] = dateTab[1] or 1970
	    tab['month'] = dateTab[2] or 1
	    tab['day'] = dateTab[3] or 1
	    tab['hour'] = dateTab[4] or 0
	    tab['min'] = dateTab[5] or 0
	    tab['sec'] = dateTab[6] or 0

	    return os.time(tab)
	elseif ttype == 2 then
		if string.len(timeStr) ~= 8 then
			return 0
		end
		local y = tonumber( string.sub(timeStr , 1, 4) )
		local m = tonumber( string.sub(timeStr , 5, 6) )
		local d = tonumber( string.sub(timeStr , 7) )

		return os.time({year = y , month = m , day = d , hour = 0 , min = 0 , sec = 0})
	else
		return 0
	end
end

-- 更新活动提示状态
function UserData:updateActPromptStatus()
	local isShow = false
	local actStatus = {
        protection = {
            status = Protection.isActive()
        },
        card = {
            status = CardMaster.isActive()
        },
        pawn = {
            status = PawnShop.isActive()
        },
       	business = {
            status = PlayerCoreData.isBusinessTimeFull()
        }
    }

    local playerLv = PlayerCoreData.getPlayerLevel()
    local actConf = GameData:getArrayData('activities.dat')

    table.foreach(actConf , function( _, value)
        if actStatus[value.Key] then
        	if playerLv >= tonumber(value.OpenLevel) then
        		if actStatus[value.Key].status then
        			isShow = true
        		end
        	end
        end
    end)
   
    return isShow
end

--awardStr : material.41:4--
--return : count , name , type , color , id , icon --  
function UserData:getAward( awardStr )
	local award = {}
	award['count'] = 0
	award['name'] = ''
	award['type'] = ''
	award['color'] = COLOR_TYPE.WHITE
	award['id'] = ''
	award['icon'] = ''
	award['quality'] = AWARD_QUALITY.WHITE

	if string.len(awardStr) == 0 then return award end
	-- print(awardStr)

	local pos1 = string.find(awardStr , '%.')
	local pos2 = string.find(awardStr , ':')
	local strType = string.sub(awardStr , 1 , pos1 - 1)
	local strId = string.sub(awardStr , pos1 + 1, pos2 -1)
	local count = string.sub(awardStr , pos2 + 1)

	award['type'] = strType
	award['id'] = strId
	award['count'] = tonumber(count)

	if strType == 'material' then
		award['name'] = PlayerCoreData.getMaterialName(tonumber(strId))
		award['icon'] = PlayerCoreData.getMaterialIco(tonumber(strId))
		award['color'] = PlayerCoreData.getMaterialColor(tonumber(strId))
		award['quality'] = GameData:getMapData('material.dat')[strId].Color
	elseif strType == 'gem' then
		local gObj = PlayerCoreData.getGemById(tonumber(strId))
		award['name'] = gObj:GetGemName()
		award['icon'] = gObj:GetResource()
		award['color'] = gObj:GetNameColor()
		award['quality'] = GameData:getMapData('gem.dat')[strId].Color
	elseif strType == 'card' then
		local cObj = PlayerCoreData.getRoleCardById(tonumber(strId))
		award['name'] = cObj:GetRoleName()
		award['icon'] = cObj:GetRoleIcon(RESOURCE_TYPE.ICON)
		award['color'] = cObj:GetRoleNameColor()
		award['quality'] = GameData:getMapData('role.dat')[strId].Quantity
	elseif strType == 'equip' then
		local pos3 = string.find(strId , '%.')
		local eType = string.sub(strId , 1 , pos3 - 1)
		local forgeLevel = string.sub(strId , pos3 + 1)
		local conf = GameData:getMapData('equip.dat')
		local eData
		table.foreach(conf , function (key , value)
			if tonumber(key) == tonumber(forgeLevel) then
				eData = value
			end
		end)
		if eData then
			local firstStr = string.sub(eType , 1 , 1)
			local secondStr = string.sub(eType , 2)
			firstStr = string.upper(firstStr)		-- 首字母转大写
			local typeStr = firstStr .. secondStr	-- Weapon | Magic | Armor | Accessory

			-- convert XXX.png to XXX_icon.png
			local res = "uires/ui_2nd/image/";
			local pointPos = string.find(eData[typeStr .. 'Url'] , '%.')
			local frontStr = string.sub(eData[typeStr .. 'Url'] , 1, pointPos - 1)
			local behindStr = string.sub(eData[typeStr .. 'Url'] , pointPos)
			local combineStr = frontStr .. '_icon' .. behindStr
			res = res .. combineStr
			award['id'] = eType				-- weapon | magic | armor | accessory
			-- award['name'] = eData[typeStr .. 'Name']
			award['name'] = GetTextForCfg(eData[typeStr .. 'Name'])
			award['icon'] = res
			award['quality'] = AWARD_QUALITY.ORANGE
		end
	elseif strType == 'pawngoods' then
		local pObj = PlayerCoreData.getPawnById(tonumber(strId))
		award['name'] = pObj:GetPawnGoodsName()
		award['icon'] = pObj:GetResource()
		award['color'] = pObj:GetPawnGoodsNameColor()
	elseif strType == 'user' then
		if strId == 'cash' then
			award['name'] = getLocalStringValue('E_STR_CASH')
			award['icon'] = getResourcePath('cash_icon')
			award['quality'] = AWARD_QUALITY.SRED
		elseif strId == 'honor' then
			award['name'] = getLocalStringValue('E_STR_HONOR')
			award['icon'] = getResourcePath('honor_icon')
		elseif strId == 'gold' then
			award['name'] = getLocalStringValue('E_STR_GOLD')
			award['icon'] = getResourcePath('gold_icon')
		elseif strId == 'food' then
			award['name'] = getLocalStringValue('E_STR_FOOD')
			award['icon'] = getResourcePath('food_icon')
		elseif strId == 'soul' then
			award['name'] = getLocalStringValue('E_STR_SOUL')
			award['icon'] = getResourcePath('soul_icon')
		elseif strId == 'rep' then
			award['name'] = getLocalStringValue('E_STR_REP')
			award['icon'] = getResourcePath('rep_icon')
		elseif strId == 'card_score' then
			award['name'] = getLocalStringValue('E_STR_SCORE')
			award['icon'] = getResourcePath('score_icon')
		elseif strId == 'coin' then
			award['name'] = getLocalStringValue('E_STR_COIN')
			award['icon'] = getResourcePath('coin_icon')
		elseif strId == 'token' then
			award['name'] = getLocalStringValue('E_STR_TOKEN')
			award['icon'] = getResourcePath('token_icon')
		elseif strId == 'fame' then
			award['name'] = getLocalStringValue('E_STR_FAME')
			award['icon'] = getResourcePath('fame_icon')
		elseif strId == 'jade' then
			award['name'] = getLocalStringValue('E_STR_JADE')
			award['icon'] = getResourcePath('jade_icon')
		elseif strId == 'legionHonor' then
			award['name'] = getLocalStringValue('LEIGON_MY_HONOR_DESC')
			award['icon'] = 'uires/ui_2nd/com/panel/army_war/gong_img.png'
		elseif strId == 'legionExp' then
			award['name'] = getLocalStringValue('LEIGON_EXP_DESC')
			award['icon'] = 'uires/ui_2nd/com/panel/army_war/legionexp_img.png'
		end
	end
	return award
end

--This one means to be static
function UserData.registerProcessor(name, cb)
	CUserdata:GetInst():registerLoginUserProcessor(name, cb)
end

function UserData.registerDupProcessor(name, cb)
	CUserdata:GetInst():registerDuplicateProcessor(name, cb)
end