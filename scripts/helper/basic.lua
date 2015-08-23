-- make read-only table.
function readOnly(t)
	assert(type(t) == 'table')
	local proxy = {}
	local mt = {
		__index = t,
		__newindex = function ( t, k, v )
			error('attempt to update a read-only table', 2)
		end
	}

	setmetatable(proxy, mt)
	return proxy
end

function string.split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function string.utf8len(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.normalizePath(str)
	return str:gsub('\\', '/'):gsub('//','/')
end

-- cclog method.
cclog = function(...)
    -- print(string.format(...))

    local msg = string.format(...)
    if MsgPrinter and MsgPrinter.show then 
        MsgPrinter:show(msg)
    end
end

-- print table
printall = function(t)
	if type(t) ~= 'table' then
		print(t)
	else
		for k,v in pairs(t) do
			if type(v) == 'table' then
				print(k .. ':')
				printall(v)
			else
				print(k, v)
			end
		end
	end
end

getLocalString = function( str )
	return getLocalStringValue(str)
end

-- transfer number to chinese
toWordsNumber = function( num )
	str = ""
	if num > 100000000 then
		str = string.format(getLocalString('E_STR_ONE_HUNDRED_MILLION'), math.floor(num / 100000000))
	elseif num > 10000 then
		str = string.format(getLocalString('E_STR_TEN_THOUSAND'), math.floor(num / 10000))
	else
		str = tostring(num)
	end

	return str
end

-- Time methods
Time = {}

function Time.now()
	return os.time()
end

function Time.beginningOfOneDay(t)
	local now = os.date('*t', tonumber(t))
	local beginDay = os.time{year = now.year, month = now.month, day = now.day, hour = 0}
	return beginDay
end

function Time.beginningOfToday()
	local now = os.date('*t', UserData:getServerTime() )
	local beginDay = os.time{year = now.year, month = now.month, day = now.day, hour = 0}
	return beginDay
end

function Time.beginningOfWeek()
	local now = os.date('*t', UserData:getServerTime() )
	local toMonday = now.wday - 2
	-- 表格配置中星期天是一周的最后一天，为7，lua中为一周的开始，wday为1
	-- wday: [1-7] => [Sunday - Saturday]
	if now.wday == 1 then
		toMonday = toMonday + 7
	end

	local beginWeekDay = os.time{year = now.year, month = now.month, day = now.day - toMonday, hour = 0}
	return beginWeekDay
end

function Time.currentWeek()
	local wday = tonumber(os.date('%w', UserData:getServerTime()))
	if wday == 0 then
		wday = 7
	end

	return wday
end