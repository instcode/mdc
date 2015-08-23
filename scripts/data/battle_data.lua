BATTLE_DIFFICULTY = readOnly {
	NORMAL = 1,
	HARD = 2,
	HELL = 3
}

BattleData = {}

function BattleData.getDataByIdAndDifficulty( bid, diffculty )
	--cclog('=== Input id: ' .. bid)
	--cclog('=== Input diffculty: ' .. diffculty)
	diffculty = diffculty or BATTLE_DIFFICULTY.NORMAL

	if diffculty < 1 or diffculty > 3 then
		cclog('--- Invalid diffculty ---')
		return nil
	end

	if #BattleData <= 0 then
		local dataFiles = {'battle.dat', 'battle2.dat', 'battle3.dat'}
		for i, v in ipairs(dataFiles) do
			BattleData[i] = GameData:getArrayData(v)
		end
	end

	for _, v in pairs(BattleData[diffculty]) do
		if bid == tonumber(v.Id) then
			return v
		end
	end

	return nil
end
