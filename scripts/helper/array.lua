Array = {}

-- 通过rid查询武将
function Array:new( o )
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Array:push( v )
	table.insert(self, v)
end

function Array:count()
	return #self
end

function Array:size()
	return self:count()
end

function Array:dup()
	local length = #self
	local arr = Array:new()
	for i = 1, length do
		arr[i] = self[i]
	end
	return arr
end

function Array:print()
	for k, v in pairs(self) do
		print(k, v)
	end
end

function Array:random()
	local arr = self:dup()
	local result = Array:new()
	local length = #arr

	for i = 1, length do
		local randIndex = math.random(#arr)
		result:push(arr[randIndex])
		table.remove(arr, randIndex)
	end

	return result
end