local ccclog = function(...)
    local msg = string.format(...)
    if MsgPrinter and MsgPrinter.show then 
        MsgPrinter:show(msg)
    end
end

function require_modules( ... )
	local arg_size = select('#', ...)

	if RELOAD_LUA or true then
		for i = 1, arg_size do
			local file = select(i, ...)
			package.loaded[file] = nil
		end
	end

	for i = 1, arg_size do
		local file = select(i, ...)
		ccclog('[### Requiring File: ' .. file .. ']')
		require(file)
	end
end

function redo_module(file)
	local function loadThis()
		dofile(file)
		ccclog(file .. ' is reloaded')
	end
	pcall( loadThis )
end