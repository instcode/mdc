
local dict = {
	['attack']  = 'uires/ui_2nd/com/panel/common/gongjie_icon.png',
	['defence'] = 'uires/ui_2nd/com/panel/common/defense_icon.png',
	['mdefence'] = 'uires/ui_2nd/com/panel/common/magic_defense_icon.png',
	['health'] = 'uires/ui_2nd/com/panel/common/soldier_icon.png',		--兵力
	['miss']    = 'uires/ui_2nd/com/panel/common/miss_icon.png',
	['block']   = 'uires/ui_2nd/com/panel/common/block_icon.png',
	['unblock'] = 'uires/ui_2nd/com/panel/common/unblock_icon.png',
	['hit']     = 'uires/ui_2nd/com/panel/common/hit_icon.png',
	['critdamage']= 'uires/ui_2nd/com/panel/common/critdamage_icon.png',
	['fortitude'] = 'uires/ui_2nd/com/panel/common/fortitude_icon.png'
}

function toTexName(name)
	if not dict[name] then
		error('no ' .. tostring(name).. ' for attribtues')
	end
	return dict[name]
end
