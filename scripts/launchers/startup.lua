

------------------------------
-- Startup
-- Clean cache
pcall(
	function()
		GameData:purge()
	end
)

pcall(
	function()
		local file = 'ceremony/dependencies'
		package.loaded[file] = nil
		require(file)
	end
)

function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    -- on testin execute...
    onLuaException(tostring(msg), debug.traceback())
    cclog("----------------------------------------")
end

--
--require 'ceremony/dependencies'
require 'ceremony/policy/all'
require 'ceremony/legion/models/legion'
require 'ceremony/legion/models/legion_config'

-- standard routine
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)

local function _preprocess()
	UserData.registerProcessor('god', ParseGodData)
	UserData.registerDupProcessor('girl_fight', CallbackGirlFight)
	UserData.registerProcessor('legion', initLegionID)
	UserData.registerProcessor('legion_war' , initLegionBuff)
	UserData.registerProcessor('server_open_time' , function (json)
		UserData:setOpenServerDays(json)
	end)
	UserData.registerProcessor('mark' , function (json)
		UserData:setLuaMarkData(json)
	end)
	UserData.registerProcessor('server_war_open_time' , function (json)
		UserData:setOpenServerWarDays(json)
	end)
	UserData.registerProcessor('activity',function(json)
	print(json)
		UserData:setLuaActivityData(json)
	end)
end

-- AVbody follows here>>
xpcall(_preprocess, __G__TRACKBACK__)
print('startup done.')
