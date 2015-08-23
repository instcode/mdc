-- panel is the IBasePanel object


local   ALTAR_AWARD_COUNT =3
local	timeCDTx
local nCurFightID
local Dirty
local nBid
local nHeroPage =0
local m_nActivateHeros = 0
BattlePointType = readOnly{
	KMAIN 			= 0, 				--主线， 可以扫荡
	KBRANCH 		= 1,				--支线, 可以扫荡
	KHONORMONSTER 	= 2,				--精英士兵	
	KGOLDMINE 		= 3,				--金矿
	KHERO 			= 4,				--英雄祭坛
	KBUSINESS 		= 5,				--跑商
	KGIRL 			= 6,				--
	KROLE 			= 7,				--精英武将
	KBOX  			= 8,				--Box，可以扫荡(其他未注明的均不能扫荡)
	KCHESTBOX 		= 9,				--探宝宝箱
}

BattleStatusType = readOnly{
	E_BATTLE_STATUS_PRO 		= 0,--没打过
	E_BATTLE_STATUS_FIGHTING	= 1,--当前目标
	E_BATTLE_STATUS_PASS		= 2,--已通过
}
    
local altarPanelName = 'altar-in-lua'
--购买表
function getBuyCash( id )
	local buyConf = GameData:getArrayData('buy.dat')
    local cash = tonumber(buyConf[id].CashDuplicate) 
    return cash
end
--英雄祭坛花费元宝挑战
--[[
local function fighthero()
	local cash=getBuyCash(PlayerCoreData.getHeroDuplicateCashCount()+1)
	if tonumber(PlayerCoreData:getCashValue())  < cash  then
		 local strbuff = string.format(getLocalString('E_STR_ARENA_CASH_ENOUCH'), cash)
		  GameController.showPrompts(strbuff,COLOR_TYPE.RED)
		 return
	end
	--花费元宝搞
	GameController.doAttack(nBid, BattlePointType.KHERO, 1,0);
end
]]
--开战
local  function clickfight()
	--todo chickfigh
	local battletype = CBattleAPI:getBattleTypeById(nBid)
	if CBattleAPI:getBattleStatusByID(nBid) == BattleStatusType.E_BATTLE_STATUS_PRO and(battletype == BattlePointType.KROLE or battletype == BattlePointType.KHONORMONSTER) then
			GameController.showMessageBox(getLocalStringValue('E_STR_HERO_NO_OPEN'), MESSAGE_BOX_TYPE.OK)
			return
	end

	if battletype ==BattlePointType.KHERO then

		if (tonumber(PlayerCoreData.getFoodValue()) >= tonumber(getGlobalIntegerValue('DuplicateBossFood', 0))) then 
			GameController.doAttack(nBid,battletype,0,0)
			return
		else 
			local strbuff = string.format(getLocalString('E_STR_ALTAR_FOOD_NOT_ENOUCH'), getGlobalIntegerValue('DuplicateBossFood', 0))
		  	GameController.showPrompts(strbuff,COLOR_TYPE.RED)
		end
		--[[
		local count =CBattleAPI:getHeroAltarAttackCashCount()
		if (count > 0) then
				local cash = getBuyCash(PlayerCoreData.getHeroDuplicateCashCount()+1)
				local strbuff = string.format(getLocalString('E_STR_ARENA_CASH_FIGHT'), cash,count)
				GameController.showMessageBox(strbuff, MESSAGE_BOX_TYPE.OK_CANCEL,fighthero)
			else
				GameController.showMessageBox(getLocalStringValue('E_STR_TODAY_TIMES_OVER'), MESSAGE_BOX_TYPE.OK)
		end
		]]
	elseif battletype ==BattlePointType.KHONORMONSTER then
		local freetimes = PlayerCoreData.getHonorFreeCount()
		local totaltimes = GameData:getGlobalValue("SoldierAttackTimes")
		if tonumber(freetimes) >= tonumber(totaltimes) then
			GameController.showMessageBox(getLocalStringValue('E_STR_CHALLENGING_TIMES_RUN_OUT'), MESSAGE_BOX_TYPE.OK)
			return
		end
		local num = CBattleAPI:getHonorMonsterAttackCount(nBid)
		if num <= 0 then
			GameController.showMessageBox(getLocalStringValue('E_STR_TODAY_TIMES_OVER'), MESSAGE_BOX_TYPE.OK)
			return
		end
	elseif battletype ==BattlePointType.KROLE then
		local freetimes = PlayerCoreData.getSoulFreeCount()
		local totaltimes = GameData:getGlobalValue("GeneralAttackTimes")
		if tonumber(freetimes) >= tonumber(totaltimes) then
			GameController.showMessageBox(getLocalStringValue('E_STR_CHALLENGING_TIMES_RUN_OUT'), MESSAGE_BOX_TYPE.OK)
			return
		end
		local num = CBattleAPI:getBranchBossAttackCount(nBid)
		if num <= 0 then
			GameController.showMessageBox(getLocalStringValue('E_STR_TODAY_TIMES_OVER'), MESSAGE_BOX_TYPE.OK)
			return
		end
	end
	GameController.doAttack(nBid,battletype,0,0)
end
--更新奖励
local function updateBossAward(sub)
	--cclog("altar ---updateBossAward--")
	local arrAward ={}
	for i=1,ALTAR_AWARD_COUNT do
		local straward =getBattleDropDataByIndex(nBid,i)
		local award = UserData:getAward(straward)

		local strBuffer ='photo_'..tostring(i)..'_ico'
		local bg = tolua.cast(sub:getChildByName(strBuffer),'UIImageView')
		arrAward[i] = {}
		arrAward[i].background = bg
		arrAward[i].icon = tolua.cast(bg:getChildByName('award_ico'),'UIImageView')
		arrAward[i].background:registerScriptTapHandler(function ()
			local awardStr = award
			UISvr:showTipsForAward(straward)
		end)
		arrAward[i].name = tolua.cast(bg:getChildByName('award_name_tx'),'UILabel')
		arrAward[i].name:setPreferredSize(135,1)
		arrAward[i].num = tolua.cast(bg:getChildByName('award_num_tx'),'UILabel')
		if string.len(tostring(award) ) ~= 0 then	
			arrAward[i].icon:setTexture(award['icon']);
			arrAward[i].icon:setAnchorPoint(ccp(0, 0));
			arrAward[i].name:setText(award['name']);
			arrAward[i].name:setColor(award['color']);
			arrAward[i].num:setTextFromInt(award['count']);
			arrAward[i].background:setVisible(true);
			arrAward[i].background:setWidgetTag(100 + i);
		else
			arrAward[i].background:setVisible(false);
		end
	end
	--cclog("altar ---updateBossAward--end")
end
--获取兵种Icon
local function GetRoleSoldierIco( bossType)
	if (bossType -1) ==0 then
		return 'uires/ui_2nd/com/panel/common/dao.png'
	elseif (bossType-1) ==1 then
		return 'uires/ui_2nd/com/panel/common/qiang.png'
	elseif (bossType-1) ==2 then
		return 'uires/ui_2nd/com/panel/common/qibing.png'
	elseif (bossType-1) ==3 then
		return 'uires/ui_2nd/com/panel/common/mou.png'
	elseif (bossType-1) ==4 then
		return 'uires/ui_2nd/com/panel/common/hong.png'
	end
end
--标题栏更新
local function updateTitle(sub)
	local	TxTitle = tolua.cast(sub:getChildByName('title_txt_tx') , 'UILabel')
	local battletype = CBattleAPI:getBattleTypeById(nBid)
	if battletype == BattlePointType.KHERO then
		TxTitle:setText(getLocalStringValue("hero_altar"));
	elseif battletype ==BattlePointType.KHONORMONSTER then
		TxTitle:setText(getLocalStringValue("E_STR_ELITE_SOLDIER"));
	elseif battletype ==BattlePointType.KROLE then
		TxTitle:setText(getLocalStringValue("E_STR_ELITE_HERO"));
	end
end
--当前BOSS可打次数
local function updateSingleTime(sub)
	--cclog('updateSingleTime---begin')
	local  	pTxTodayTimes = tolua.cast(sub:getChildByName('today_times_tx') , 'UILabel') 
			pTxTodayTimes:setVisible(true)
	local  	today_info_tx = tolua.cast(sub:getChildByName('today_info_tx') , 'UILabel') 
	-- today_info_tx:setPreferredSize(320,1)
			today_info_tx:setVisible(true)
	local  	today_food_num_tx = tolua.cast(sub:getChildByName('today_food_num_tx') , 'UILabel') 
			today_food_num_tx:setVisible(false)
	local  	todayfood_info_tx = tolua.cast(sub:getChildByName('todayfood_info_tx') , 'UILabel') 
	-- todayfood_info_tx:setPreferredSize(320,1)
			todayfood_info_tx:setVisible(false)
	local  	foodd_ico = tolua.cast(sub:getChildByName('food2_ico') , 'UIImageView') 
			foodd_ico:setVisible(false)
	local battletype =CBattleAPI:getBattleTypeById(nBid) 
	--print(battletype)
	if battletype == BattlePointType.KHERO then
		pTxTodayTimes:setVisible(false)
		today_info_tx:setVisible(false)
		today_food_num_tx:setVisible(true)
		today_food_num_tx:setText(tostring(getGlobalIntegerValue('DuplicateBossFood', 0)))
		todayfood_info_tx:setVisible(true)
		foodd_ico:setVisible(true)
	--	print('KHERO')
	elseif battletype == BattlePointType.KHONORMONSTER then
		local cur = CBattleAPI:getHonorMonsterAttackCount(nBid)
		local sum =0
		if CBattleAPI:isHonorMonsterBoss(nBid) then
			sum = GameData:getGlobalValue("BestSoldier")
		else
			sum =GameData:getGlobalValue("NormalSoldier")
		end
		local buffer = cur .."/"..sum
		pTxTodayTimes:setText(buffer)
	--	print('KHONORMONSTER')
	elseif battletype == BattlePointType.KROLE then
		local cur = CBattleAPI:getBranchBossAttackCount(nBid)
		local sum =0
		if CBattleAPI:isBranceBossBoss(nBid) then
			sum = GameData:getGlobalValue("BestGeneral")
		else
			sum =GameData:getGlobalValue("NormalGeneral")
		end
		local buffer = cur .."/"..sum
		pTxTodayTimes:setText(buffer)
	--	print('KROLE')
	end
	--cclog('updateSingleTime---end')
end
--总次数恢复时间
local function updateTime(sub)
	--todo updata
	local  	pChallengeNum =tolua.cast(sub:getChildByName('challenge_num_tx'),'UILabel')
	local   pChallengeTxt =tolua.cast(sub:getChildByName('challenge_txt_tx'),'UILabel')
	local   food_num_tx =tolua.cast(sub:getChildByName('food_num_tx'),'UILabel')
			food_num_tx:setVisible(false)
	local   food_ico =tolua.cast(sub:getChildByName('food_ico'),'UIImageView')
			food_ico:setVisible(false)
	local freeTimes = 0
	local totalTimes = 0
	local battletype = CBattleAPI:getBattleTypeById(nBid)
	if battletype == BattlePointType.KHERO then
		pChallengeTxt:setVisible(false)
		pChallengeNum:setVisible(false)
		food_num_tx:setVisible(true)
		food_ico:setVisible(true)
		local food = PlayerCoreData.getFoodValue()
		local tx = CStringUtil:numToStr(food)
		food_num_tx:setText(tx)
		--totalTimes = GameData:getGlobalValue("DuplicateFree")
		--freeTimes  =   PlayerCoreData.getHeroDuplicateCount()
		--cclog('DuplicateFree freeTimes ==' .. freeTimes)
	elseif battletype == BattlePointType.KHONORMONSTER then
		totalTimes = GameData:getGlobalValue("SoldierAttackTimes");
		freeTimes  =  PlayerCoreData.getHonorFreeCount()
		--cclog('SoldierAttackTimes freeTimes ==' .. freeTimes)
	elseif battletype == BattlePointType.KROLE then
		totalTimes = GameData:getGlobalValue("GeneralAttackTimes");
		freeTimes  =   PlayerCoreData.getSoulFreeCount()
		--cclog('GeneralAttackTimes freeTimes ==' .. freeTimes)
	end

	
	local textbuffer = (totalTimes-freeTimes) .."/" ..totalTimes
	pChallengeNum:setText(textbuffer)
	pChallengeNum:setColor(COLOR_TYPE.GREEN)
	 --cclog("updata")
end
--当前BOSS基本信息
local function updateRoleInfo(sub)
--	cclog("altar ---updateRoleInfo--")
	local  	pBossName = tolua.cast(sub:getChildByName('role_name_tx') , 'UILabel')
	local  	pBossType = tolua.cast(sub:getChildByName('soldier_type_ico') , 'UIImageView')
	local  	pBossFighting = tolua.cast(sub:getChildByName('zhan_num_tx') , 'UILabel') 
	local	pChallengeBtn =tolua.cast(sub:getChildByName('challenge_btn') , 'UITextButton')
			pChallengeBtn:registerScriptTapHandler( clickfight );
			GameController.addButtonSound(pChallengeBtn, BUTTON_SOUND_TYPE.CLICK_EFFECT)
	local  	 monsterid=BattleData.getDataByIdAndDifficulty(nBid).Boss
	if monsterid ~= nil then
		local 	bossname =loadMonsterProfileString(monsterid,'Name')
		local 	soldier =loadMonsterProfileString(monsterid,'Soldier')
		pBossType:setTexture(GetRoleSoldierIco(soldier))
		pBossType:setAnchorPoint(ccp(0,0))
		pBossName:setText(GetTextForCfg(bossname))
		pChallengeBtn:setText(getLocalStringValue("E_STR_CHALLENGE_BOSS"))
		--pTxHeroIdx:setText(strbuff)
		local nPower = BattleData.getDataByIdAndDifficulty(nBid).FightForce

		pChallengeBtn:setPressState(WidgetStateNormal)
		pChallengeBtn:setTouchEnable(true)
		pBossFighting:setText( nPower )
	end
--	cclog("altar ---updateRoleInfo--end")
end
--倒计时
local function challageTimeVis(sub)
--	cclog("altar ---challageTimeVis")
	local   pChallengeTxt =tolua.cast(sub:getChildByName('recover_txt_tx'),'UILabel')
	print(pChallengeTxt)
	local freeCount =0
	local lefttime =0
	local totalSeconds =0
	local battletype = CBattleAPI:getBattleTypeById(nBid)
	if battletype == BattlePointType.KHERO then
		freeCount  =   PlayerCoreData.getHeroDuplicateCount()
		pChallengeTxt:setVisible(false)
		return
	elseif battletype == BattlePointType.KHONORMONSTER then
		freeCount  =  PlayerCoreData.getHonorFreeCount()
		lefttime   =  PlayerCoreData.getHonorRecoveryTime()
		totalSeconds = GameData:getGlobalValue("SoldierColdDomn");
	elseif battletype == BattlePointType.KROLE then
		freeCount  =   PlayerCoreData.getSoulFreeCount()
		lefttime   =  PlayerCoreData.getSoulRecoveryTime()
		totalSeconds = GameData:getGlobalValue("GeneralColdDomn");
	else
		pChallengeTxt:setVisible(false)
		return false
	end
	--cclog("challageTimeVis freeCount----------" .. freeCount)
	if tonumber(freeCount) == 0 then
		pChallengeTxt:setVisible(false)
		return false
	else
		local resTime = tonumber(lefttime) + tonumber(totalSeconds) -tonumber(UserData:getServerTime())
		if tonumber(resTime) > 0 then
		 pChallengeTxt:setVisible(true)
		 timeCDTx:setTime(resTime)
		else
			GameController.doUpdateTimesRequest(battletype)
		end
	end
	--cclog("altar ---challageTimeVis--end")
	pChallengeTxt:setVisible(true)
	return true
end
--ok
function genAltarboard(bid)
	--cclog("genAltarboard")
	nHeroPage =0
	local pPvHero 
	nBid =bid
	--cclog('genAltarboard id' .. bid)
	--cclog("genAltarboard nbid==" .. nBid)
	if UiMan.isPanelPresent(altarPanelName) then
		return
	end

	local altarPanel = SceneObjEx:createObj('panel/hero_home_panel.json', altarPanelName)

	local _onHide = function()
		cclog('on-hide for altar panel')
	end

	local panel = altarPanel:getPanelObj()		--IBasePanelEx
    panel:setAdaptInfo('hero_home_bg_img', 'hero_home_img')

	panel:registerInitHandler(
		function()
			--cclog('here on-init for altar')
			panel:registerScriptTapHandler('close_btn', UiMan.genCloseHandler(altarPanel))
			panel:registerOnHideHandler(_onHide)
			Dirty = true
			m_nActivateHeros = 0
			local rootWidget = panel:GetRawPanel()
			local hero_home_bgimg = tolua.cast(rootWidget:getChildByName('hero_home_bg_img'),'UIImageView')
			local hero_homeimg = tolua.cast(hero_home_bgimg:getChildByName('hero_home_img'),'UIImageView')
			local  	pChallengeNum =tolua.cast(hero_homeimg:getChildByName('challenge_num_tx'),'UILabel')
			local   pChallengeTxt =tolua.cast(hero_homeimg:getChildByName('recover_txt_tx'),'UILabel')
			local 	closeBtn = tolua.cast(hero_homeimg:getChildByName('close_btn') , 'UIButton')
					GameController.addButtonSound(closeBtn , BUTTON_SOUND_TYPE.CLOSE_EFFECT)
			local hero_home_diimg = tolua.cast(hero_homeimg:getChildByName('hero_home_di_img') , 'UIImageView')
			local   pRoleBg =tolua.cast(hero_home_diimg:getChildByName('role_bg_img'),'UIImageView')
			local  	pTxHeroIdx = tolua.cast(hero_homeimg:getChildByName('role_idx_tx') , 'UILabel') 
			local subPages = {}

			local function updateBossNum()
				pPvHero:removeAllChildrenAndCleanUp(true)
				local subPage = {}
				local battletype = CBattleAPI:getBattleTypeById(nBid)
				local config 
				local cid =BattleData.getDataByIdAndDifficulty(nBid).Battle
				if battletype == BattlePointType.KHERO then
					config = mdata.GetHeroMapConfig()
				elseif battletype == BattlePointType.KHONORMONSTER then
					config = mdata.GetEliteSoldierMapConfig(cid)
				elseif battletype == BattlePointType.KROLE then
					config = mdata.GetEliteHeroMapConfig(cid)
				else
					cclog("config on")
				end

				local sum = 0
				local activateHeros = 0
				local ids = mdata.GetBattleMapIds(config)
				for k, v in pairs(ids) do
					local sub = mdata.GetBattleMapSub(config, v)
					--print('m_nID is ' .. tostring(sub:m_nID()))
					--print('m_strName is ' .. sub:m_strName())
					local   id =tonumber(v)
					if (tonumber(CBattleAPI:getHeroStatusByID(id)) ==tonumber(BattleStatusType.E_BATTLE_STATUS_PRO) and
						battletype == BattlePointType.KHERO) then
						break
					end

					local bossid =BattleData.getDataByIdAndDifficulty(id).Boss
					local 	bossicoUrl =loadMonsterProfileString(bossid,'URL')
					local pRoleIcon = UIImageView:create()
					-- 暂时拼接
					local strUrl = "uires/ui_2nd/image/" .. bossicoUrl
					pRoleIcon:setTexture(strUrl)
					pRoleIcon:setAnchorPoint(ccp(0.5, 0))
					pRoleIcon:setPosition(ccp(166,0))
					pRoleIcon:setScale(0.9)
					
					local pPage = UIContainerWidget:create()
					pPage:setWidgetTag(id)
					pPage:setActionTag(sum)
					pPage:addChild(pRoleIcon)
					pPvHero:addPage(pPage)
					subPage[#subPage+1] = pPage
					if (CBattleAPI:getBattleStatusByID(id) == BattleStatusType.E_BATTLE_STATUS_PRO and
						(battletype == BattlePointType.KROLE or battletype == BattlePointType.KHONORMONSTER)) then
						pRoleIcon:setGray()
					else
						--精英武将和精英士兵中已经激活的武将个数
						if (battletype == BattlePointType.KHONORMONSTER or battletype == BattlePointType.KROLE) then
							activateHeros =activateHeros + 1
							nHeroPage = sum
						end
					end
					sum =sum+1
				end
				return subPage
			end

			--cclog('st init pv-board')
			if nil == pPvHero then
				pPvHero = UIPageView:create()
				pPvHero:setTouchEnable(true)
				pPvHero:setWidgetZOrder(1)
				pPvHero:setPosition(ccp(13,90))
				pPvHero:setSize(CCSizeMake(335 , 350))
				pPvHero:setAnchorPoint(ccp(0,0))
				pPvHero:removeAllChildrenAndCleanUp(true)
				pRoleBg:addChild(pPvHero)
			end

			local scorllPvFn = function ( page )
			--	cclog('scorllPvFn page =====' .. page)
				local pageCount = pPvHero:getPageCount()
				local strbuffer = page+1 .. '/' .. pageCount
				pTxHeroIdx:setText(strbuffer)
				
				if subPages[page+1] ~=nil then
					local id =subPages[page+1]:getWidgetTag()
				--	cclog('scorllPvFn id' .. id)
					if tonumber(id) >0 then
						nBid =id
						updateRoleInfo(hero_homeimg)
						updateBossAward(hero_home_diimg)
						updateTime(hero_homeimg)
						updateSingleTime(hero_homeimg)
					end
				end
			end
			
			--print('done init pv-board')
			local   pRightBt =tolua.cast(pRoleBg:getChildByName('right_btn'),'UIButton')

					pRightBt:registerScriptTapHandler(
						function()
							pPvHero:scrollToRight()
						end
					)
			local   pLeftBt =tolua.cast(pRoleBg:getChildByName('left_btn'),'UIButton')
					pLeftBt:registerScriptTapHandler(
						function()
							pPvHero:scrollToLeft()
						end
					)

			local function scrollToBoss(bid)
				nBid = bid
			--	cclog('scrollToBoss id '.. bid)
				updateRoleInfo(hero_homeimg)
				updateBossAward(hero_home_diimg)
				updateSingleTime(hero_homeimg)
				local container = pPvHero:getChildByTag(bid)
				if container ==nil then
			--		cclog('scrollToBoss nil')
					pPvHero:scrollToPage(0)
					return
				end
				local idx = container:getActionTag()

				if idx < 0 then
					idx =0
				end
				if (idx == 0)	then
					Dirty = true
				else
				--	Dirty = false
				end
			--	cclog('scrollToBoss idx ..' .. idx)
				pPvHero:scrollToPage(idx)
			end
			GameController.addButtonSound(pRightBt , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			GameController.addButtonSound(pLeftBt , BUTTON_SOUND_TYPE.CLICK_EFFECT)
			timeCDTx = UICDLabel:create()
			--cd label
			local function timeOver(dt)
				local battletype = CBattleAPI:getBattleTypeById(nBid)
					GameController.doUpdateTimesRequest(battletype)
			end
			timeCDTx:setFontSize(26)
			timeCDTx:setAnchorPoint(ccp(0,0.5))
			timeCDTx:setPosition(ccp(5,0))
			timeCDTx:setFontColor(COLOR_TYPE.LIGHT_YELLOW)
			timeCDTx:registerTimeoutHandler(timeOver)
			pChallengeTxt:addChild(timeCDTx)
			--init
			local function update()
			    --cclog('here on-update for altar')
				subPages =updateBossNum()
				pPvHero:addScroll2PageEventScript( scorllPvFn )
				updateTime(hero_homeimg)
				--cclog('Dirty ===' .. tostring(Dirty) )
				if Dirty then
					if nHeroPage ~=0  then
				--		cclog('update nHeroPage ===' .. nHeroPage )
						local id =subPages[nHeroPage+1]:getWidgetTag()
						if tonumber(id) >0 then
							--nBid =id
						end
					end
				end
				scrollToBoss(nBid)
				challageTimeVis(hero_homeimg)
				updateTitle(hero_homeimg)
				updateRoleInfo(hero_homeimg)
				updateBossAward(hero_home_diimg)
				updateSingleTime(hero_homeimg)				
					--cclog('here on-onshow for altar --end')
			end
			update()
			panel:registerOnShowHandler(function()
				update()
			end)
		end)

	UiMan.show(altarPanel)
end


-- Process here>>>
-- print('altar is reloaded')

