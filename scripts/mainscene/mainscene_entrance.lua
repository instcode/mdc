
function enterHeavy()
	print('enterHeavy')
	CThousandFloorMgr:GetInst():Show()
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