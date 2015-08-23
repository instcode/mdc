
function enterHeavy()
	print('enterHeavy')
	CThousandFloorMgr:GetInst():Show()
	local id = PlayerCoreData.getCurrentTowerFloor()
	GameController:showPrompts("At floor " .. id .. ", right?", COLOR_TYPE.GREEN)
	--seq=111&uid=2001874&openid=negabox_001597&act=tower&auth_key=9064e653e1&auth_time=1439539475&mod=battle&args={"id":56}&sig=185fe6ad6e&stime=1439540535
	-- Message.sendPost('tower','battle','{"id": ' .. id .. '}', function (jsonData) end)
end

function enterTraining()
	print('enterTraining')
	CTrainMgr:GetInst():ShowTrainPanel()
end

function enterGlodMine()
	print('enterGlodMine')
	GoldMan2:GetInst():OpenSvPanel()
end

function enterArmy()
	print('enterArmy')
	CTechnologyMgr:GetInst():ShowMainPanel()
end

function enterDungeon()
	print('enterDungeon')
	-- CThousandFloorMgr:GetInst():ShowMain()
end

function enterRing()
	print('enterRing')
	arenaChoiceEnter()
end

function enterPavilion()
	print('enterPavilion')
	CTavernMgr:GetInst():ShowGoldTavern()
end

-- ROLE
function enterConmmanders()
	print('enterConmmanders')
	CRoleMgr:GetInst():ShowMainPanel(E_ROLE_SUBPAGE_INFO, false)
end

-- fucking lua styl
function enterBlacksmith()
	print('enterBlacksmith')
	CBlacksmithMgr:GetInst():ShowBlackSmithPanel()
end