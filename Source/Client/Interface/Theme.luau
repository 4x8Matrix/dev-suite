local Package = script.Parent.Parent.Parent

local Sift = require(Package.Parent.Sift)

local ICONS = table.freeze({
	MiddleScrollingFrameIcon = `http://www.roblox.com/asset/?id=123032894572732`,
	TopScrollingFrameIcon = `http://www.roblox.com/asset/?id=95175423103608`,
	BottomScrollingFrameIcon = `http://www.roblox.com/asset/?id=135686768300117`,

	DropdownArrowIcon = `http://www.roblox.com/asset/?id=91919367883017`,
	StraightArrowIcon = `http://www.roblox.com/asset/?id=73426420511004`,

	ServerIcon = `http://www.roblox.com/asset/?id=79914132215539`,
	ClientIcon = `http://www.roblox.com/asset/?id=78104343425890`,

	MinimiseIcon = `http://www.roblox.com/asset/?id=103506812514902`,
	DevSuiteIcon = `http://www.roblox.com/asset/?id=133189525814836`,
	DashboardIcon = `http://www.roblox.com/asset/?id=125989547128015`,
	SandboxIcon = `http://www.roblox.com/asset/?id=105644859153667`,
	DatastoresIcon = `http://www.roblox.com/asset/?id=106797143762308`,
	EmbeddedIcon = `http://www.roblox.com/asset/?id=91743480578016`,
	ExplorerIcon = `http://www.roblox.com/asset/?id=116244663538470`,
	InspectorIcon =`http://www.roblox.com/asset/?id=132722856457587`,
	InterceptorIcon = `http://www.roblox.com/asset/?id=82710547910298`,
	LiveEventsIcon = `http://www.roblox.com/asset/?id=89592417172377`,
	LoggingIcon = `http://www.roblox.com/asset/?id=71965170319925`,
	StatisticsIcon = `http://www.roblox.com/asset/?id=105773589734060`,
	PerformanceIcon = `http://www.roblox.com/asset/?id=126479063941214`,
	ActionsIcon = `http://www.roblox.com/asset/?id=139017748369084`,
	AdminIcon = `http://www.roblox.com/asset/?id=94994868951756`,
	DebuggerIcon = `http://www.roblox.com/asset/?id=93413399230396`,
	ScriptHubIcon = `http://www.roblox.com/asset/?id=89767042572716`,

	TabIcon = `http://www.roblox.com/asset/?id=135396811830334`,
	QuestionIcon = `http://www.roblox.com/asset/?id=82261841272265`,
	RepeatIcon = `http://www.roblox.com/asset/?id=117634959424560`,

	PlayIcon = `http://www.roblox.com/asset/?id=123356194161843`,
	RestartIcon = `http://www.roblox.com/asset/?id=128203851153594`,

	EventIcon = `http://www.roblox.com/asset/?id=105282448479805`,
	FunctionIcon = `http://www.roblox.com/asset/?id=91455768893519`,
	PropertyIcon = `http://www.roblox.com/asset/?id=101344281875867`,

	PointerIcon = `http://www.roblox.com/asset/?id=73809779520162`,
	SelectionIcon = `http://www.roblox.com/asset/?id=74544478147788`,

	PropertiesIcon = `http://www.roblox.com/asset/?id=121668548193381`,

	FolderIcon = `http://www.roblox.com/asset/?id=81984538720069`,
	OpenFolderIcon = `http://www.roblox.com/asset/?id=77505221896372`,
})

local FONTS = table.freeze({
	CodeblockFont = Font.fromName(Enum.Font.RobotoMono.Name, Enum.FontWeight.Regular),
	TopbarLabelFont = Font.fromName(Enum.Font.Ubuntu.Name, Enum.FontWeight.ExtraBold),
	BaseLabelFont = Font.fromName(Enum.Font.Ubuntu.Name),
})

local STANDARD_COLORS = table.freeze({
	BaseBackgroundColor3 = Color3.fromHex("#202020"),
	BaseTopbarColor3 = Color3.fromHex("#1b1b1b"),
	BaseSidebarColor3 = Color3.fromHex("#161616"),

	CodeblockBackgroundColor3 = Color3.fromHex("#191919"),
	CodeblockColor3 = Color3.fromHex("#ffffff"),

	UIStrokeThickness = 2,

	TopbarLabelColor3 = Color3.fromHex("#727272"),

	DropdownColor3 = Color3.fromHex("#111111"),

	BaseLabelColor3 = Color3.fromHex("#ffffff"),

	ClientColor3 = Color3.fromHex("#4983ff"),
	ServerColor3 = Color3.fromHex("#03cf44"),

	AccentColor3 = Color3.fromHex("#0b5aaf"),
	ErrorColor3 = Color3.fromHex("#df2121"),

	EventIconColor = Color3.fromHex("#ffff00"),
	FunctionIconColor = Color3.fromHex("#fa98fb"),
	PropertyIconColor = Color3.fromHex("#99cdff"),

	BooleanColor = Color3.fromHex("#ff0000"),
	NumberColor = Color3.fromHex("#ffc600"),
	NilColor = Color3.fromHex("#ffc600"),
	StringColor = Color3.fromHex("#adf195"),
	EnumColor = Color3.fromHex("#00b7ff"),
	InstanceColor = Color3.fromHex("#99cdff"),

	OutputLogColor = Color3.fromHex("#c2c2c2"),
	OutputWarnColor = Color3.fromHex("#ff8e3c"),
	OutputErrorColor = Color3.fromHex("#ff4444"),
	OutputInformationColor = Color3.fromHex("#80d6fe"),
})

local CHRISTMAS_COLORS = table.freeze({
	BaseBackgroundColor3 = Color3.fromHex("#ffffff"),
	BaseTopbarColor3 = Color3.fromHex("#f0f0f0"),
	BaseSidebarColor3 = Color3.fromHex("#f5f5f5"),

	BaseIconColor3 = Color3.fromHex("#b4b4b4"),

	CodeblockBackgroundColor3 = Color3.fromHex("#fafafa"),
	CodeblockColor3 = Color3.fromHex("#000000"),

	UIStrokeThickness = 2,

	TopbarLabelColor3 = Color3.fromHex("#ff8e8e"),

	DropdownColor3 = Color3.fromHex("#f8f8f8"),

	BaseLabelColor3 = Color3.fromHex("#707070"),

	ClientColor3 = Color3.fromHex("#2E8B57"),
	ServerColor3 = Color3.fromHex("#ff8e8e"),

	AccentColor3 = Color3.fromHex("#4CAF50"),
	ErrorColor3 = Color3.fromHex("#ff9999"),

	EventIconColor = Color3.fromHex("#FFD700"),
	FunctionIconColor = Color3.fromHex("#ffb6c1"),
	PropertyIconColor = Color3.fromHex("#1E88E5"),

	BooleanColor = Color3.fromHex("#ffb3b3"),
	NumberColor = Color3.fromHex("#C0962F"),
	NilColor = Color3.fromHex("#C0962F"),
	StringColor = Color3.fromHex("#388E3C"),
	EnumColor = Color3.fromHex("#1976D2"),
	InstanceColor = Color3.fromHex("#0277BD"),

	OutputLogColor = Color3.fromHex("#424242"),
	OutputWarnColor = Color3.fromHex("#EF6C00"),
	OutputErrorColor = Color3.fromHex("#ffb3b3"),
	OutputInformationColor = Color3.fromHex("#0288D1")
})

local HALLOWEEN_COLORS = table.freeze({
	BaseBackgroundColor3 = Color3.fromHex("#1C1C1C"),
	BaseTopbarColor3 = Color3.fromHex("#2A2A2A"),
	BaseSidebarColor3 = Color3.fromHex("#252525"),

	BaseIconColor3 = Color3.fromHex("#FFA500"),

	CodeblockBackgroundColor3 = Color3.fromHex("#292929"),
	CodeblockColor3 = Color3.fromHex("#FFFFFF"),

	UIStrokeThickness = 2,

	TopbarLabelColor3 = Color3.fromHex("#FF7518"),

	DropdownColor3 = Color3.fromHex("#1E1E1E"),

	BaseLabelColor3 = Color3.fromHex("#D3D3D3"),

	ClientColor3 = Color3.fromHex("#8A2BE2"),
	ServerColor3 = Color3.fromHex("#FF4500"),

	AccentColor3 = Color3.fromHex("#FF7518"),
	ErrorColor3 = Color3.fromHex("#E63946"),

	EventIconColor = Color3.fromHex("#FFA500"),
	FunctionIconColor = Color3.fromHex("#FF8C00"),
	PropertyIconColor = Color3.fromHex("#9C27B0"),

	BooleanColor = Color3.fromHex("#FF4500"),
	NumberColor = Color3.fromHex("#FFD700"),
	NilColor = Color3.fromHex("#FFA07A"),
	StringColor = Color3.fromHex("#DA70D6"),
	EnumColor = Color3.fromHex("#FF6347"),
	InstanceColor = Color3.fromHex("#BA55D3"),

	OutputLogColor = Color3.fromHex("#B0B0B0"),
	OutputWarnColor = Color3.fromHex("#FF8C00"),
	OutputErrorColor = Color3.fromHex("#E63946"),
	OutputInformationColor = Color3.fromHex("#9370DB")
})

local NEW_YEARS_COLORS = table.freeze({
	BaseBackgroundColor3 = Color3.fromHex("#FFFFFF"),
	BaseTopbarColor3 = Color3.fromHex("#F2F2F2"),
	BaseSidebarColor3 = Color3.fromHex("#E6E6E6"),

	BaseIconColor3 = Color3.fromHex("#DAA520"),

	CodeblockBackgroundColor3 = Color3.fromHex("#FAFAFA"),
	CodeblockColor3 = Color3.fromHex("#333333"),

	UIStrokeThickness = 2,

	TopbarLabelColor3 = Color3.fromHex("#DAA520"),

	DropdownColor3 = Color3.fromHex("#F2F2F2"),

	BaseLabelColor3 = Color3.fromHex("#444444"),

	ClientColor3 = Color3.fromHex("#FFD700"),
	ServerColor3 = Color3.fromHex("#C0C0C0"),

	AccentColor3 = Color3.fromHex("#FFD700"),
	ErrorColor3 = Color3.fromHex("#FF4500"),

	EventIconColor = Color3.fromHex("#DAA520"),
	FunctionIconColor = Color3.fromHex("#C0C0C0"),
	PropertyIconColor = Color3.fromHex("#F5DEB3"),

	BooleanColor = Color3.fromHex("#FFD700"),
	NumberColor = Color3.fromHex("#E6B800"),
	NilColor = Color3.fromHex("#B0B0B0"),
	StringColor = Color3.fromHex("#A9A9A9"),
	EnumColor = Color3.fromHex("#DAA520"),
	InstanceColor3 = Color3.fromHex("#FFD700"),

	OutputLogColor = Color3.fromHex("#606060"),
	OutputWarnColor = Color3.fromHex("#FFB347"),
	OutputErrorColor = Color3.fromHex("#FF6347"),
	OutputInformationColor = Color3.fromHex("#C0C0C0")
})

local ST_PATRICKS_DAY_COLORS = table.freeze({
	BaseBackgroundColor3 = Color3.fromHex("#0A391D"),
	BaseTopbarColor3 = Color3.fromHex("#114B26"),
	BaseSidebarColor3 = Color3.fromHex("#0E301A"),

	BaseIconColor3 = Color3.fromHex("#FFD700"),

	CodeblockBackgroundColor3 = Color3.fromHex("#1B4D3E"),
	CodeblockColor3 = Color3.fromHex("#FFFFFF"),

	UIStrokeThickness = 2,

	TopbarLabelColor3 = Color3.fromHex("#FFD700"),

	DropdownColor3 = Color3.fromHex("#123821"),

	BaseLabelColor3 = Color3.fromHex("#C0C0C0"),

	ClientColor3 = Color3.fromHex("#32CD32"),
	ServerColor3 = Color3.fromHex("#228B22"),

	AccentColor3 = Color3.fromHex("#FFD700"),
	ErrorColor3 = Color3.fromHex("#FF4500"),

	EventIconColor = Color3.fromHex("#FFD700"),
	FunctionIconColor = Color3.fromHex("#32CD32"),
	PropertyIconColor = Color3.fromHex("#50C878"),

	BooleanColor = Color3.fromHex("#32CD32"),
	NumberColor = Color3.fromHex("#FFD700"),
	NilColor = Color3.fromHex("#FF8C00"),
	StringColor = Color3.fromHex("#9ACD32"),
	EnumColor = Color3.fromHex("#6B8E23"),
	InstanceColor = Color3.fromHex("#2E8B57"),

	OutputLogColor = Color3.fromHex("#C0C0C0"),
	OutputWarnColor = Color3.fromHex("#FFD700"),
	OutputErrorColor = Color3.fromHex("#FF4500"),
	OutputInformationColor = Color3.fromHex("#50C878")
})

local VALENTINES_DAY_COLORS = table.freeze({
	BaseBackgroundColor3 = Color3.fromHex("#FFFAFA"),
	BaseTopbarColor3 = Color3.fromHex("#FFC0CB"),
	BaseSidebarColor3 = Color3.fromHex("#FFD1DC"),

	BaseIconColor3 = Color3.fromHex("#FF69B4"),

	CodeblockBackgroundColor3 = Color3.fromHex("#FFE4E9"),
	CodeblockColor3 = Color3.fromHex("#FF0000"),

	UIStrokeThickness = 2,

	TopbarLabelColor3 = Color3.fromHex("#FF1493"),

	DropdownColor3 = Color3.fromHex("#FFE4E1"),

	BaseLabelColor3 = Color3.fromHex("#B22222"),

	ClientColor3 = Color3.fromHex("#FF69B4"),
	ServerColor3 = Color3.fromHex("#DC143C"),

	AccentColor3 = Color3.fromHex("#FF6347"),
	ErrorColor3 = Color3.fromHex("#FF4500"),

	EventIconColor = Color3.fromHex("#FF69B4"),
	FunctionIconColor = Color3.fromHex("#FFB6C1"),
	PropertyIconColor = Color3.fromHex("#FF1493"),

	BooleanColor = Color3.fromHex("#DC143C"),
	NumberColor = Color3.fromHex("#FF6347"),
	NilColor = Color3.fromHex("#FF7F50"),
	StringColor = Color3.fromHex("#FF69B4"),
	EnumColor = Color3.fromHex("#FF1493"),
	InstanceColor = Color3.fromHex("#FFC0CB"),

	OutputLogColor = Color3.fromHex("#CD5C5C"),
	OutputWarnColor = Color3.fromHex("#FF4500"),
	OutputErrorColor = Color3.fromHex("#B22222"),
	OutputInformationColor = Color3.fromHex("#FF69B4")
})

local function GetCurrentTheme()
	local currentDate = os.date("*t")

	local month = currentDate.month
	local day = currentDate.day
	
	-- Christmas (December 24-25)
	if month == 12 and (day == 24 or day == 25) then
		return CHRISTMAS_COLORS
	end
	
	-- New Years (January 1)
	if month == 1 and day == 1 then
		return NEW_YEARS_COLORS
	end
	
	-- Valentine's Day (February 13-14)
	if month == 2 and day == 14 then
		return VALENTINES_DAY_COLORS
	end
	
	-- St. Patrick's Day (March 17)
	if month == 3 and day == 17 then
		return ST_PATRICKS_DAY_COLORS
	end
	
	-- Halloween (October 30-31)
	if month == 10 and day == 31 then
		return HALLOWEEN_COLORS
	end
	
	return STANDARD_COLORS
end

return Sift.Dictionary.merge(ICONS, FONTS, Sift.Dictionary.merge(STANDARD_COLORS, GetCurrentTheme())) :: typeof(ICONS) & typeof(FONTS) & typeof(STANDARD_COLORS)