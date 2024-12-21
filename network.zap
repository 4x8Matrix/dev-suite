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

type EncodedActionArgument = struct {
	type: string,
	value: string,
}

type ActionArgument = struct {
	type: string,
	name: string,
	default: string?
}

type Action = struct {
	path: string[],
	name: string,
	description: string,
	uuid: string,
	
	arguments: ActionArgument[]
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

event FetchActionsRequested = {
	from: Client,
	type: Reliable,
	call: ManyAsync
}

event ServerReportingActions = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
    data: Action[]
}

event ExecuteServerActionRequested = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
    data: struct {
		actionUuid: string,
		arguments: EncodedActionArgument[]
	}
}

event ExecuteServerScriptRequested = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
    data: string
}

funct HttpGetRequest = {
    call: Sync,
    args: string,
    rets: string
}