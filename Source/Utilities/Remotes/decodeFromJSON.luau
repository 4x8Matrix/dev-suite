local HttpService = game:GetService("HttpService")

return function(jsonArguments: string, instanceMap: { Instance })
	local arguments = HttpService:JSONDecode(jsonArguments)

	for index, value in arguments do
		local typeofValue = typeof(value)

		if typeofValue == "string" and string.sub(value, 1, 1) == "I" then
			local instanceId = string.match(value, "I(%d+)")

			if not instanceId then
				continue
			end

			instanceId = tonumber(instanceId)

			if not instanceId then
				continue
			end

			if not instanceMap[instanceId] then
				continue
			end

			arguments[index] = instanceMap[instanceId]
		end
	end

	return arguments
end
