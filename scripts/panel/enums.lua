ELF_SHOW = readOnly{
	NORMAL  = 0,
	SLIDE_IN = 1,
	ZOOM_IN  = 2,	
	OUT_IN_SPECIAL1 = 3,
	OUT_IN_SPECIAL2 = 4,
	CLOUD_SPECIAL1 = 5,
	CLOUD_SPECIAL2 = 6,
	SMART = 7
}

ELF_HIDE = readOnly{
	HIDE_NORMAL = 0,
	SLIDE_OUT = 1,
	ZOOM_OUT_FADE_OUT = 2,
	CLOUD_OUT_SPECIAL = 3,
	CLOUD_OUT_SPECIAL2 = 4,
	SMART_HIDE = 5
}

SIGN_MODE = readOnly{
	NONE = 0,			-- 无效模式(当前判定为不可签到:如都已经签满了,或者没有可签到)
	NORMAL = 1,			-- 普通签到
	MAKE_UP = 2,		-- 补签
	VIP_GOT =3			-- VIP补领
}

SCROLLVIEW_DIR = readOnly{
	VERTICAL = 1,
	HORIZONTAL = 2
}

NEWS_TAG = readOnly{
	TAG_ALL = 0,
	TAG_GOLDMINE = 1,
	TAG_ARENA = 2,
	TAG_PLUNDER = 3,
	TAG_LEGION_BATTLE = 4
}