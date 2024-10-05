opt server_output = "Source/Server/Network.luau"
opt client_output = "Source/Client/Network.luau"
opt remote_scope = "DEBUG_REMOTES"
opt casing = "PascalCase"

type SettingOptions = struct {
    DefaultHotkey: string
}

type RemoteEvenRelay = struct {
    arguments: string,
    instances: Instance[],
    event: Instance,
}

type Log = struct {
    message: string,
	type: string,
	time: u32
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

event ServerRemotesFired = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
    data: RemoteEvenRelay
}

event ServerReportingLogs = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
    data: Log[]
}

event ClientReportingLogs = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
    data: Log[]
}