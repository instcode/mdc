local friendsData = {}

local kControlerStatus = {
	kApplied = 1,			-- 申请
	kFriends = 2,			-- 好友
	kRecommend = 3			-- 推荐
}

function friendsData:getFriends(  )
	local o = {
		elements = {},
		friends = {},
		applied = {},
		grain = nil
	}

	setmetatable(o, self)
	self.__index = self
	return o
end

function friendsData:getRecommend()
	local o = {
		elements = {},
		recommend = {},
		kSceneObj = nil,
		kFriendsPanel = nil
	}

	setmetatable(o, self)
	self.__index = self
	return o
end

function friendsData:getControlerStatus(  )
	return kControlerStatus
end

return friendsData

