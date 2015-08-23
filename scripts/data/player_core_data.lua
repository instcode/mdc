PlayerCoreData = {}

-- Player's data

--
function PlayerCoreData.getMaxFoodBuyTime()
	return PlayerCore:getMaxFoodBuyTime()
end

-- 获取UID
function PlayerCoreData.getUID()
	return PlayerCore:getPlayerUID()
end

-- 获取openid
function PlayerCoreData.getOpenID()
	return PlayerCore:getPlayerOpenID()
end

-- 获取玩家名字
function PlayerCoreData.getPlayerName()
	return PlayerCore:getPlayerName()
end

-- 获取玩家等级
function PlayerCoreData.getPlayerLevel()
	return PlayerCore:getPlayerLevel()
end

-- 设置玩家等级
function PlayerCoreData.setPlayerLevel( v )
	PlayerCore:setPlayerLevel(v)
end

-- 获取玩家经验
function PlayerCoreData.getPlayerExp()
	return PlayerCore:getPlayerExp()
end

-- 设置玩家经验
function PlayerCoreData.setPlayerExp( v )
	PlayerCore:setPlayerExp(v)
end

-- 增加玩家经验
function PlayerCoreData.addPlayerExp( v )
	PlayerCore:addPlayerExp(v)
end

-- 获取战斗力
function PlayerCoreData.getPlayerFightForce()
	return PlayerCore:getPlayerFightForce()
end

-- 获取玩家VIP等级
function PlayerCoreData.getPlayerVIP()
	return PlayerCore:getPlayerVIP()
end

-- 设置玩家VIP等级
function PlayerCoreData.setPlayerVIP( v )
	PlayerCore:setPlayerVIP(v)
end

-- 获取元宝
function PlayerCoreData.getCashValue()
	return PlayerCore:getCashValue()
end

-- 增加元宝
function PlayerCoreData.addCashDelta( v )
	PlayerCore:addCashDelta(v)
end

-- 获取金币
function PlayerCoreData.getGoldValue()
	return PlayerCore:getGoldValue()
end

-- 增加金币
function PlayerCoreData.addGoldDelta( v )
	PlayerCore:addGoldDelta(v)
end

-- 获取军粮
function PlayerCoreData.getFoodValue()
	return PlayerCore:getFoodValue()
end

-- 设置军粮
function PlayerCoreData.addFoodDelta( v )
	PlayerCore:addFoodDelta(v)
end

-- 获取军功
function PlayerCoreData.getHonorValue()
	return PlayerCore:getHonorValue()
end

-- 设置军功
function PlayerCoreData.addHonorDelta( v )
	PlayerCore:addHonorDelta(v)
end

-- 获取将魂
function PlayerCoreData.getSoulValue()
	return PlayerCore:getSoulValue()
end

-- 设置将魂
function PlayerCoreData.addSoulValue( v )
	PlayerCore:addSoulValue(v)
end

-- 获取卡牌积分
function PlayerCoreData.getScoreValue()
	return PlayerCore:getScoreValue()
end

-- 设置卡牌积分
function PlayerCoreData.setScoreValue( val )
	PlayerCore:setScoreValue(val)
end

-- 设置卡牌积分
function PlayerCoreData.addScoreDelta( v )
	PlayerCore:addScoreDelta(v)
end

-- 设置神玉
function PlayerCoreData.addJadeDelta( v )
	PlayerCore:addJadeDelta(v)
end

-- 获取古币
function PlayerCoreData.getCoinValue()
	return PlayerCore:getCoinValue()
end

-- 设置古币
function PlayerCoreData.addCoinValue( v )
	PlayerCore:addCoinValue(v)
end

-- 获取荣誉令牌
function PlayerCoreData.getTokenValue()
	return PlayerCore:getTokenValue()
end

-- 设置荣誉令牌
function PlayerCoreData.addTokenDelta( v )
	PlayerCore:addTokenDelta(v)
end

-- 设置材料
function PlayerCoreData.addMaterialDelta(id , v)
	PlayerCore:addMaterialDelta(id , v)
end

-- Objects
-- 获取武将
function PlayerCoreData.getRoleById( id )
	return PlayerCore:getRoleObjectByID(id)
end

function PlayerCoreData.getAllRolesId()
	return PlayerCore:getAllRolesId()
end

-- 获取武将卡牌
function PlayerCoreData.getRoleCardById( id )
	return PlayerCore:getRoleCardObjectByID(id)
end

function PlayerCoreData.getRoleCardCount()
	return PlayerCore:getRoleCardCount()
end

function PlayerCoreData.getRoleCardCountById( id )
	return PlayerCore:getRoleCardCountById( id )
end

-- 获取装备
function PlayerCoreData.getEquipById( id )
	return PlayerCore:getEquipObjectByID(id)
end

-- 获取虚拟装备
function PlayerCoreData.getVirtualEquipByTypeAndForgeLv( etype , forgelv )
	return PlayerCore:getEquipObjectByTypeAndForgeLv(etype,forgelv)
end

-- 获取宝石
function PlayerCoreData.getGemById( id )
	return PlayerCore:getGemObjectByID(id)
end

-- 获取材料
function PlayerCoreData.getMaterialById( id )
	return PlayerCore:getMaterialObjectByID(id)
end

-- 获取琳琅商品
function PlayerCoreData.getPawnById( id )
	return PlayerCore:getPawnObjectByID(id)
end

-- 获取琳琅商品
function PlayerCoreData.getPawnCountById( id )
	return PlayerCore:getPawnCountByID(id)
end

-- 获取材料名称
function PlayerCoreData.getMaterialName( id )
	return PlayerCore:getMaterialNameByID(id)
end

-- 获取材料素材
function PlayerCoreData.getMaterialIco( id )
	return PlayerCore:getMaterialIcoByID(id)
end

-- 获取材料颜色
function PlayerCoreData.getMaterialColor( id )
	return PlayerCore:getMaterialNameColor(id)
end

-- 获取材料数量
function PlayerCoreData.getMaterialCount( id )
	return PlayerCore:getMaterialCount(id)
end

-- 获取材料介绍
function PlayerCoreData.getMaterialDesc( id )
	return PlayerCore:getMaterialDesc(id)
end

-- 
function PlayerCoreData.getCashAccumulated()
	return PlayerCore:getCashAccumulated()
end

function PlayerCoreData.getPayTimesForID(id)
	return PlayerCore:getPayTimesForID(id)
end

function PlayerCoreData.getVipBoughtForLevel(level)
	return PlayerCore:getVipBoughtForLevel(level)
end

function PlayerCoreData.markVipBoughtForLevel(level)
	return PlayerCore:markVipBoughtForLevel(level)
end

function PlayerCoreData.getVipBuyTimes(level)
	return PlayerCore:getVipBuyTimes(level)
end

-- integer
function PlayerCoreData.getActiveMonthPlayerLeftDays()
	return PlayerCore:getActiveMonthPlayerLeftDays()
end

-- boolean
function PlayerCoreData.isActiveMonthPlayerDayAwardClaimed()
	return PlayerCore:isActiveMonthPlayerDayAwardClaimed()
end

-- 获取建号时间
function PlayerCoreData.getCreatePlayerTime()
	local selfObj = PlayerCore:getSelfObject()
	if selfObj then
		return selfObj:GetPlayCreateTime()
	end
	return 0
end

-- string 
function PlayerCoreData.getFileData(filename , mode)
	--local chunk = CFileUtil:GetFileData(filename, mode)
	local chunk = mcore.readDataChunk(filename, mode)
	return chunk
end


-- 是否首充
function PlayerCoreData.getFirstPay()
	return PlayerCore:getFirstPay()
end

function PlayerCoreData.setFirstPay(firstPay)
	PlayerCore:setFirstPay(firstPay)
end

function PlayerCoreData.IsSignInOKToday()
	return PlayerCore:IsSignInOKToday()
end


function PlayerCoreData.getHeroDuplicateCount()
	return PlayerCore:getHeroDuplicateCount()
end

function PlayerCoreData.getHeroDuplicateCashCount()
	return PlayerCore:getHeroDuplicateCashCount()
end

function PlayerCoreData.getHonorFreeCount()
	return PlayerCore:getHonorFreeCount()
end

function PlayerCoreData.getHonorRecoveryTime()
	return PlayerCore:getHonorRecoveryTime()
end

function PlayerCoreData.getSoulFreeCount()
	return PlayerCore:getSoulFreeCount()
end

function PlayerCoreData.getSoulRecoveryTime()
	return PlayerCore:getSoulRecoveryTime()
end

-- 得到当前粮草剩余购买次数
function PlayerCoreData.getFoodBuyTimeRemains()
	return PlayerCore:getFoodBuyTimeRemains()
end

-- 得到当前粮草剩余购买次数
function PlayerCoreData.getBuyFoodCashCost()
	return PlayerCore:getBuyFoodCashCost()
end

--跑商次数已满
function PlayerCoreData.isBusinessTimeFull()
	return PlayerCore:IsBusinessTimesFull()
end

--是否有剩余跑商次数
function PlayerCoreData.isBusinessCanDo()
	return PlayerCore:IsBusinessCanDo()
end

--根据ID获取武将是否开启实体化
function PlayerCoreData.getSoldierGodByID( nID )
	return PlayerCore:getSoldierGodByID( nID )
end

--根据ID获取武将实体化素材URl
function PlayerCoreData.getSoldierGodUrlByID( nID )
	return PlayerCore:getSoldierGodUrlByID( nID )
end

--根据ID获取武将类型
function PlayerCoreData.getSoldierTypeByID( nID )
	return PlayerCore:getSoldierTypeByID( nID )
end

function PlayerCoreData.getGoldMineOccFreeTime()
	return PlayerCore:getGoldMineOccFreeTime()
end

function PlayerCoreData.getClientBaseVersion()
	return PlayerCore:getClientBaseVersion()
end