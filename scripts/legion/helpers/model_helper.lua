ModelHelper = {}

function ModelHelper.updateKeyIfChanged( obj, key, value )
	if value and obj[key] ~= value then
		obj[key] = value
	end
end