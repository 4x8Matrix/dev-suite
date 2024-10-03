local HttpService = game:GetService("HttpService")

local function encode(object: any, instanceMap: { Instance })
	local objectType = typeof(object)

	if objectType == "Instance" then
		local instanceId = #instanceMap + 1

		table.insert(instanceMap, object)

		return `I{instanceId}`
	end

	return object
end

return function(...)
	local arguments = { ... }
	local instanceMap = {}

	for index, value in arguments do
		arguments[index] = encode(value, instanceMap)
	end

	return HttpService:JSONEncode(arguments) or "<NO DATA>", instanceMap
end
