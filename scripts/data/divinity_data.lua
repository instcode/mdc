

local currentDivinity={
	id = 0,			--当前出战美人
	skill = 0
}

function CallbackGirlFight(str)
	local xt = json.decode(str)
	currentDivinity = {
		id    = xt.id,
		skill = xt.skill
	}
	--[[
	print('*********************************************************')
	print('*********************************************************')
	print('*********************************************************')
	print('Now is for ' .. tostring(xt.id))
	--]]
end

function getDivinityState()
	return currentDivinity.id, currentDivinity.skill
end

function setDivinityState(id, skill)
	currentDivinity = {
		id = id,
		skill = skill
	}
end