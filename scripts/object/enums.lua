-- 资源类型
RESOURCE_TYPE = readOnly{
	BIG = 0,
	NORMAL = 1,
	ICON = 2,
	WEAPON_ICON_SMALL = 3
}

-- 装备位置：武器/护甲/饰品
EQUIP_SITE = readOnly{
	WEAPON = 0,
	ARMOR = 1,
	ACCESSORY = 2
}

-- 装备类型: 武器/扇子/护甲/饰品
EQUIP_TYPE = readOnly{
	PHYSICAL = 0,
	MAGIC = 1,
	ARMOR = 2,
	ACCESSORY = 3
}

--宝石
GEM_TYPE = readOnly{
	ATTACK = 0,
	MAGIC = 1,
	DEFENCE = 2,
	RESIST = 3,
	HEALTH = 4,
	CRIT = 5,
	FORTITUDE = 6,
	BLOCK = 7,
	MORALE = 8
}

--系统颜色值
COLOR_TYPE = readOnly{
	WHITE = ccc3(255,255,255),
	GREEN = ccc3(0,255,0),
	BLUE  = ccc3(0,156,255),
	PURPLE = ccc3(216,0,255),
	ORANGE = ccc3(255,156,0),
	RED = ccc3(255,0,0),
	LIGHT_YELLOW = ccc3(255,255, 204),
	BLACK = ccc3(0,0,0),
	LIGHT_GREEN = ccc3(154,217,86),
	GRAY = ccc3(182, 194, 184)
}

-- 武将品质
ROLE_QUALITY = readOnly{
	WHITE = 0,
	BLUE = 1,
	PURPLE = 2,
	ORANGE = 3,
	ARED = 4,
	SRED = 5
}

-- 武将属性
ROLE_ATTR = readOnly{
	ATTACK = 'attack',
	MAGIC = 'magic',
	DEFENCE = 'defence',
	MDEFENCE = 'mdefence',
	HEALTH = 'health',
	FORTITUDE = 'fortitude',
	HIT = 'hit',
	UNBLOCK = 'unblock',
	BLOCK = 'block',
	CRITDAMAGE = 'critdamage',
	MISS = 'miss',
	ASSAIL = 'assail'
}

-- 奖励品质
AWARD_QUALITY = readOnly{
	WHITE = 'white',
	GREEN = 'green',
	BLUE = 'blue',
	PURPLE = 'purple',
	ORANGE = 'orange',
	RED = 'red',
	ARED = 'ared',
	SRED = 'sred'
}

-- obj 类型
E_OBJECT_TYPE = readOnly{
	OBJECT_TYPE_ERROR = -1,
	OBJECT_TYPE_SELF = 0,
	OBJECT_TYPE_ROLE = 1,
	OBJECT_TYPE_ROLE_CARD = 2,
	OBJECT_TYPE_EQUIP = 3,
	OBJECT_TYPE_MATERIAL = 4,
	OBJECT_TYPE_GEM = 5,
	OBJECT_TYPE_LEAGUE = 6,
	OBJECT_TYPE_PAWNGOODS = 7,
	OBJECT_TYPE_COUNT = 8,
}
--购买界面类型
E_BS_PANEL_TYPE = readOnly{
	E_BS_CONFIRM_TYPE_ERROR = -1,
	E_BS_CONFIRM_ONE = 0, -- 一种货币
	E_BS_CONFIRM_TWO = 1,--两种货币 包括声望
	E_BS_CONFIRM_GOTO = 2,-- 有GOTO的界面
	E_BS_CONFIRM_COUNT = 3,
}