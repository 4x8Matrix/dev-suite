local HttpService = game:GetService("HttpService")

local function tostring(object)
	local objectType = typeof(object)

	if objectType == "Instance" then
		return `Instance<'{object:GetFullName()}'>`
	elseif objectType == "string" then
		return `"{object}"`
	elseif objectType == "table" then
		if select(1, object) == nil then
			return "{ }"
		end

		local objectMap = "{ "

		for key, value in object do
			objectMap ..= `[{tostring(key)}] = {tostring(value)},`
		end

		return `{objectMap} }`
	end

	return object
end

return function(...)
	local arguments = { ... }

	for index, value in arguments do
		arguments[index] = tostring(value)
	end

	return HttpService:JSONEncode(arguments) or "<NO DATA>"
end
