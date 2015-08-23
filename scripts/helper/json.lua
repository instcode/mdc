--[[
	cjson v2.1
	json for lua by c
	路径在utils/cjson
	速度比lua原生的json4lua快几十倍 并解决了空对象会encode成空数组的bug
]]

json = {}

local cjson = require 'cjson'

function json.encode(table)
	return cjson.encode(table)
end

function json.decode(jsonStr)
	return cjson.decode(jsonStr)
end