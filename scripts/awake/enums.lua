-- now open awake role id -- 
AWAKE_ROLE_ID = readOnly{
	GUANYU = 94,
 	LVBU = 98,
 	ZHUGELIANG = 99,
 	LUOSHEN = 102,
 	ZHAOYUN = 96,
 	ZUOCI = 119,
 	HUATUO = 120,
 	TONGYUAN = 121
}

AWAKE_SKILL_ID = readOnly{
	LVBU = 1001,
	ZHUGELIANG = 1002,
	LUOSHEN = 1003,
	GUANYU = 1004,
	ZHAOYUN = 1005,
	ZUOCI = 1006,
	HUATUO = 1007,
	TONGYUAN = 1008
}

AWAKE_INFLUENCE_TYPE = readOnly{
	NOT_CHANGE = 0,			-- 都不变
	CHANGE_HEALTH = 1,		-- 回合开始前先减掉或加上觉醒技能改变的血量
	CHANGE_POWER = 2,		-- 回合开始前先减掉或加上觉醒技能改变的怒气
	BOTH_CHANGE = 3         -- 回合开始前先减掉或加上觉醒技能改变的血量和怒气
}

DEFENDER_STATE = readOnly{
	IDLE = 0,			-- 无
	DODGE = 2,			-- 闪避
	CRITICAL = 3,		-- 暴击
	BLOCK = 4,			-- 格挡
	REVERSEDAMAGE = 5,	-- 反弹
	IMMUNE = 6			-- 免疫
}

-- 觉醒技能施放的时机
INSERT_AWAKE_TIME = readOnly{
	BEFORE_DELAY = 0,
	BEFORE_MOV = 1,
	BEFORE_HITBACK = 2,
	BEFORE_SKILL = 3,
	BEFORE_HURT = 4,
	BEFORE_DIE = 5,
	BEFORE_ANGER = 6,
	BEFORE_DEBUFF = 7,
	BEFORE_REMOVEBUFF = 8,
	BEFORE_AWAKE = 9,
	AFTER_DELAY = 500,
	AFTER_MOV = 501,
	AFTER_HITBACK = 502,
	AFTER_SKILL = 503,
	AFTER_HURT = 504,
	AFTER_DIE = 505,
	AFTER_ANGER = 506,
	AFTER_DEBUFF = 507,
	AFTER_REMOVEBUFF = 508,
	AFTER_AWAKE = 509,
	START = 1000,
	END = 2000,
	OTHERS = 10000
}