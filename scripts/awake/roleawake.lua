RoleAwake = {
	BATTLE_EFFECT_TAG = 7300,
	BATTLE_EFFECT_TAG_ALWAYS = 7301,
	EFFECT_ZORDER = 10
}

----------------------------
function RoleAwake:addEffect(node , always , parent)
	local tag = always and self.BATTLE_EFFECT_TAG_ALWAYS or self.BATTLE_EFFECT_TAG
	node:setTag(tag)
	node:setVisible(always or IsFightEffectOn())
	parent:getParent():addChild(node)
end

function RoleAwake:isInValidStr(str)
	if str == nil or str == 'null' or str == '' then
		return true
	end
	return false
end

function RoleAwake:getSkillEffectData(soldier, skill, key)
	local conf = GameData:getArrayData('skilleffect.dat')
	for _, v in pairs (conf) do
		if tonumber(v.Soldier) == tonumber(soldier) and tonumber(v.Skill) == tonumber(skill) then
			return v[key]
		end
	end
	return nil
end

function RoleAwake:showFlyText(anger, damage, tx, ty, host, delay)
	local flyAni = tolua.cast(CDamgeFlyUtil:GenerateAction(anger, 0, damage , ccp( 20, 20 ) , delay) , 'CCNode')
	if flyAni then
		flyAni:setZOrder(1000)
		flyAni:setPosition( ccp( tx , ty ) )
		addEffect(flyAni, true , host)
	end
end
-----------------------------------------------------------------------------------------------
-- 判断是否要先把被觉醒改变的血和怒气还原回去
function checkAwakeStatus(skill)
	if skill == AWAKE_SKILL_ID.LVBU then	-- 吕布
		return AWAKE_INFLUENCE_TYPE.NOT_CHANGE
	elseif skill == AWAKE_SKILL_ID.ZHUGELIANG then	-- 诸葛亮
		return AWAKE_INFLUENCE_TYPE.NOT_CHANGE
	elseif skill == AWAKE_SKILL_ID.LUOSHEN then	-- 洛神
		return AWAKE_INFLUENCE_TYPE.CHANGE_HEALTH
	elseif skill == AWAKE_SKILL_ID.GUANYU then	-- 关羽
		return AWAKE_INFLUENCE_TYPE.CHANGE_HEALTH
	elseif skill == AWAKE_SKILL_ID.ZHAOYUN then	-- 赵云
		return AWAKE_INFLUENCE_TYPE.NOT_CHANGE
	elseif skill == AWAKE_SKILL_ID.ZUOCI then	-- 左慈
		return AWAKE_INFLUENCE_TYPE.NOT_CHANGE
	elseif skill == AWAKE_SKILL_ID.HUATUO then	-- 华佗
		return AWAKE_INFLUENCE_TYPE.NOT_CHANGE
	elseif skill == AWAKE_SKILL_ID.TONGYUAN then	-- 童渊
		return AWAKE_INFLUENCE_TYPE.NOT_CHANGE
	else
		return AWAKE_INFLUENCE_TYPE.NOT_CHANGE
	end
end

-- 判断觉醒技能施放的时机
function checkAwakeTime(skill, roleId, isSelf)
	if skill == AWAKE_SKILL_ID.LVBU then	-- 吕布
		if isSelf then
			return INSERT_AWAKE_TIME.OTHERS
		else
			return INSERT_AWAKE_TIME.END
		end
	elseif skill == AWAKE_SKILL_ID.ZHUGELIANG then	-- 诸葛亮
		return INSERT_AWAKE_TIME.BEFORE_SKILL
	elseif skill == AWAKE_SKILL_ID.LUOSHEN then	-- 洛神
		return INSERT_AWAKE_TIME.END
	elseif skill == AWAKE_SKILL_ID.GUANYU then  -- 关羽
		if isSelf then	
			return INSERT_AWAKE_TIME.OTHERS
		else
			return INSERT_AWAKE_TIME.AFTER_HURT
		end
	elseif skill == AWAKE_SKILL_ID.ZHAOYUN then	-- 赵云
		return INSERT_AWAKE_TIME.START
	elseif skill == AWAKE_SKILL_ID.ZUOCI then	-- 左慈
		return INSERT_AWAKE_TIME.BEFORE_SKILL
	elseif skill == AWAKE_SKILL_ID.HUATUO then	-- 华佗
		return INSERT_AWAKE_TIME.END
	elseif skill == AWAKE_SKILL_ID.TONGYUAN then	-- 童渊
		return INSERT_AWAKE_TIME.BEFORE_SKILL
	else
		return -1
	end
end

-- 施放觉醒
function playAwakeSkill(skill, ishome, role)
	local skillDelay = 0
	local roundDelay = 0
	if skill == AWAKE_SKILL_ID.LVBU then	-- 吕布
		skillDelay, roundDelay = AwakeLvBu:playAwake(ishome, role)
	elseif skill == AWAKE_SKILL_ID.ZHUGELIANG then	-- 诸葛亮
		skillDelay, roundDelay = AwakeZhuGeLiang:playAwake(ishome, role)
	elseif skill == AWAKE_SKILL_ID.LUOSHEN then	-- 洛神
		skillDelay, roundDelay = AwakeLuoShen:playAwake(ishome, role)
	elseif skill == AWAKE_SKILL_ID.GUANYU then	-- 关羽
		skillDelay, roundDelay = AwakeGuanYu:playAwake(ishome, role)
	elseif skill == AWAKE_SKILL_ID.ZHAOYUN then	-- 赵云
		skillDelay, roundDelay = AwakeZhaoYun:playAwake(ishome, role)
	elseif skill == AWAKE_SKILL_ID.ZUOCI then	-- 左慈
		skillDelay, roundDelay = AwakeZuoCi:playAwake(ishome, role)
	elseif skill == AWAKE_SKILL_ID.HUATUO then	-- 华佗
		skillDelay, roundDelay = AwakeHuaTuo:playAwake(ishome, role)
	elseif skill == AWAKE_SKILL_ID.TONGYUAN then	-- 童渊
		skillDelay, roundDelay = AwakeTongYuan:playAwake(ishome, role)
	end
	local delay = skillDelay .. ',' .. roundDelay
	return delay
end