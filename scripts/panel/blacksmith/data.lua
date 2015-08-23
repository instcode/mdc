local blacksmithData = {}

function blacksmithData:mainPanel(  )
	local o = {
		elements = {}
	}

	setmetatable(o, self)
	self.__index = self
	return o
end

function blacksmithData:getRecommend()
	local o = {

	}

	setmetatable(o, self)
	self.__index = self
	return o
end

return blacksmithData

