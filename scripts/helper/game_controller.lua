MESSAGE_BOX_TYPE = readOnly{
	OK = 0,
	CANCEL = 1,
	OK_CANCEL = 2
}

BUTTON_SOUND_TYPE = readOnly{
	CLICK_EFFECT = 100,
	CLOSE_EFFECT = 110
}

GameController = {}

-- 消息框
function GameController.showMessageBox( str, mtype, cb )
	local box = CMessageBox:GetInst()
	mtype = mtype or MESSAGE_BOX_TYPE.OK
	cb = cb or function() end
	box:Open2(mtype, str, cb)
end

-- 显示系统提示, default color is COLOR_TYPE.WHITE
-- Usage 1: GameController.showPrompts('msg1', 'msg2', ..., COLOR_TYPE.GREEN)
-- Usage 2: local messages = {'msg1', 'msg2', 'msg3', ...}; GameController.showPrompts(messages, COLOR_TYPE.GREEN)
function GameController.showPrompts( ... )
	local size = select('#', ...)
	local prompt = CPrompt:GetInst()
	for i = size, 1, -1 do
		local msg = select(i, ...)
		if type(msg) == 'string' then
			prompt:AddPromt(msg)
		elseif type(msg) == 'table' then
			local count = #msg
			for i = count, 1, -1 do
				prompt:AddPromt(msg[i])
			end
		end
	end

	local lastArg = select(size, ...)
	local color
	if type(lastArg) == 'userdata' then
		color = lastArg
	else
		color = COLOR_TYPE.WHITE
	end

	prompt:ShowPanel(color)
end

-- 添加按钮声音
function GameController.addButtonSound( btn, effect )
	Snd:addSoundIdToButton(btn, effect)
end

-- 保存上一场战斗数据
function GameController.saveOldBattleInfo()
	BattleMan:GetInst():SaveOldBattleInfo()
end

-- 清除战斗奖励(用于没有经验和奖励的战斗)
function GameController.clearAwardView()
	CBattleData:getInst():clearAwardView()
end

-- 刷新奖励
function GameController.updateAwardView(json)
	CBattleData:getInst():updateAwardView(json)
end

-- 开始战斗
function GameController.playBattle(json, JumpTpye, from)
	if from == nil then
		from = 999			-- BattlePlace::FromOthers = 999
	end
	LoadBattleForLuaPlay(json, JumpTpye, from)
end

-- 转换字符串为frame
function GameController.getColorFrame( str )
	str = string.lower(str)
	if str == 'red' or str == 'ared'then
		return 'uires/ui_2nd/com/panel/common/frame_red.png'
	elseif str == 'orange' then
		return 'uires/ui_2nd/com/panel/common/frame_yellow.png'
	elseif str == 'purple' then
		return 'uires/ui_2nd/com/panel/common/frame_purple.png'
	elseif str == 'blue' then
		return 'uires/ui_2nd/com/panel/common/frame.png'
	elseif str == 'sred' then
		return 'uires/ui_2nd/com/panel/common/frame_sred.png'
	else
		return 'uires/ui_2nd/com/panel/common/frame.png'
	end
end

-- 转换字符串颜色
function GameController.getCCColor( str )
	str = string.lower(str)
	if str == 'red' then
		return COLOR_TYPE.RED
	elseif str == 'orange' then
		return COLOR_TYPE.ORANGE
	elseif str == 'purple' then
		return COLOR_TYPE.PURPLE
	elseif str == 'blue' then
		return COLOR_TYPE.BLUE
	elseif str == 'green' then
		return COLOR_TYPE.GREEN
	elseif str == 'white' then
		return COLOR_TYPE.WHITE
	else
		return nil
	end
end

-- 格式化显示时间
function GameController.timeFormat(time1, time2)
	local timeStr = CTimeFormatUtil:TimeFormat(time1, time2)
	return timeStr
end

-- 抢夺残卷
function GameController.doRobFragment(fragID, enemy)
	CRoleMgr:GetInst():DoRobFragment(fragID, enemy)
end

-- 战斗回放
function GameController.doReplay(place, id)
	CCopySceneMgr:getInst():doReplay(place, id)
end

-- 本地存储(为了区分不同账号，所有key加上唯一标示uid)
function GameController.setStringForKey(key, value)
	local uid =  PlayerCoreData.getUID()
	key = uid .. key
	CCUserDefault:sharedUserDefault():setStringForKey(key, value)
end

function GameController.getStringForKey(key)
	local uid =  PlayerCoreData.getUID()
	key = uid .. key
	local v = CCUserDefault:sharedUserDefault():getStringForKey(key)
	return v
end

-- 获取BGMVolume
function GameController.getBGMVolume()
	return SimpleAudioEngine:sharedEngine():getBackgroundMusicVolume()
end

-- 设置BGMVolume
function GameController.setBGMVolume(vol)
	SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(vol)
end

-- 获取SoundVolume
function GameController.SoundVolume()
	return SimpleAudioEngine:sharedEngine():getEffectsVolume()
end

-- 设置SoundVolume
function GameController.setSoundVolume(vol)
	SimpleAudioEngine:sharedEngine():setEffectsVolume(vol)
end

-- 更新时间
function GameController.doUpdateTimesRequest(type)
	CCopySceneMgr:getInst():doUpdateTimesRequest(type)
end

-- 开战
function GameController.doAttack(id, battlePointType, cash , star)
	CCopySceneMgr:getInst():doAttack(id, battlePointType, cash, star)
end

-- 显示奖励飘字
function GameController.showAwardsFlowText( awards )
	local msgBox = {}
	for _, v in pairs ( awards ) do
		local atype = tostring(v[1])
		local id = tostring(v[2])
		local count = tonumber(v[3]) or 0
		if count > 0 then
			local str = ''
			if atype == 'user' then
				if id == 'gold' then
					str = string.format(getLocalStringValue('E_STR_GAIN_GOLD_DESC') , count)
				elseif id == 'food' then
					str = string.format(getLocalStringValue('E_STR_GAIN_FOOD_DESC') , count)
				elseif id == 'cash' then
					str = string.format(getLocalStringValue('E_STR_GAIN_CASH_DESC') , count)
				elseif id == 'honor' then
					str = string.format(getLocalStringValue('E_STR_GAIN_HONOR_DESC') , count)
				elseif id == 'soul' then
					str = string.format(getLocalStringValue('E_STR_GAIN_SOUL_DESC') , count)
				elseif id == 'legion_honor' or id == 'legionHonor' then
					str = string.format(getLocalStringValue('LEIGON_GAIN_MY_HONOR_DESC') , count)
				elseif id == 'legion_exp' or id == 'legionExp' then
					str = string.format(getLocalStringValue('LEIGON_GAIN_EXP_DESC') , count)
				end

				if string.len(str) > 0 then
					table.insert(msgBox , str)
				end
			else
				local s = atype .. '.' .. id .. ':' .. count
				local award = UserData:getAward(s)
				str = string.format(getLocalStringValue('E_STR_YOUR_GAIN_MATERIAL') , award.count , award.name)
				table.insert(msgBox , str)
			end
		end
	end

	if #msgBox > 0 then
		GameController.showPrompts( msgBox )
	end
end

-- 创建一个奖励显示框
function GameController.createItem( award )
	local di_img = UIImageView:create()
	di_img:setAnchorPoint(ccp(0.5,0.5))
	di_img:setTexture('uires/ui_2nd/com/panel/common/frame.png')

	local photo = UIImageView:create()
	photo:setAnchorPoint(ccp(0.5,0.5))
	photo:setTexture(award.icon)
	photo:setPosition(ccp(1,1))

	local numTx = UILabel:create()
	numTx:setAnchorPoint(ccp(1 , 0.5))
	numTx:setFontSize(16)
	numTx:setText( tostring(award.count) )
	numTx:setPosition( ccp(31 , -21) )

	local nameTx = UILabel:create()
	nameTx:setPreferredSize(140,1)
	nameTx:setAnchorPoint( ccp(0.5 , 0.5) )
	nameTx:setFontSize(20)
	nameTx:setText( award.name )
	nameTx:setPosition( ccp(1 , -64) )

	di_img:addChild(photo)
	di_img:addChild(numTx)
	di_img:addChild(nameTx)

	return di_img
end