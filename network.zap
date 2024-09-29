opt server_output = "Source/Server/Network.luau"
opt client_output = "Source/Client/Network.luau"
opt remote_scope = "DEBUG_REMOYES"
opt casing = "PascalCase"

type SettingOptions = struct {
    DefaultHotkey: string
}

funct AuthenticateRequested = {
    call: Async,
    rets: enum { Accepted, Rejected },
}

funct FetchSettingsRequested = {
    call: Async,
    rets: SettingOptions,
}

event ServerSettingsUpdated = {
	from: Server,
	type: Reliable,
	call: SingleAsync,
    data: SettingOptions
}