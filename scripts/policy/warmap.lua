--[[
function deduceStarChonseByPolicy(starNow)
	local rv = 1
	if starNow <= 1 then
		rv = 1
	elseif starNow <= 2 then
		rv = 2
	else
		rv = 3
	end
	return rv
end
]]

function deduceStarChonseByPolicy(starNow)
	local rv = 1
	if starNow < 1 then
		rv = 1
	elseif starNow < 2 then
		rv = 2
	else
		rv = 3
	end
	return rv
end

print('Warmap policy is loaded.')
