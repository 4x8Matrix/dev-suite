local Package = script.Parent.Parent.Parent.Parent.Parent

local FusionTypes = require(Package.Types.Fusion)
local PageTypes = require(Package.Types.Page)
local SignalTypes = require(Package.Types.Signal)

local ImageButton = require(Package.Client.Interface.Components.ImageButton)
local ImageLabel = require(Package.Client.Interface.Components.ImageLabel)
local TextButton = require(Package.Client.Interface.Components.TextButton)
local TextLabel = require(Package.Client.Interface.Components.TextLabel)
local UICorner = require(Package.Client.Interface.Components.UICorner)
local UIPadding = require(Package.Client.Interface.Components.UIPadding)

local Theme = require(Package.Client.Interface.Theme)

local Fusion = require(Package.Parent.Fusion)

local Embedded = {}

Embedded.DisplayName = `Admin`
Embedded.DisplayOrder = 12
Embedded.DisplayIcon = Theme.AdminIcon
Embedded.Enabled = true

function Embedded.Render(scope: Scope, props: Props)
	return scope:New("Frame")({
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Fusion.Children] = {
			UIPadding = UIPadding(scope, {
				paddingHeight = UDim.new(0, 10),
				paddingWidth = UDim.new(0, 10)
			}),

			PlayerList = scope:New("Frame")({
				Size = UDim2.fromScale(0.4, 1),
				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 10),
						paddingWidth = UDim.new(0, 10)
					}),

					TitleLabel = TextLabel(scope, {
						Size = UDim2.fromScale(1, 0.08),
						Text = "Players",
						TextTransparency = 0.75
					}),

					ScrollingFrame = scope:New("ScrollingFrame")({
						Size = UDim2.fromScale(1, 0.92),
						Position =  UDim2.fromScale(0, 0.08),
						BackgroundTransparency = 1,
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.fromScale(0, 0),
						ClipsDescendants = true,
						MidImage = Theme.MiddleScrollingFrameIcon,
						TopImage = Theme.TopScrollingFrameIcon,
						BottomImage = Theme.BottomScrollingFrameIcon,
						ScrollBarImageColor3 = Theme.AccentColor3,
						ScrollBarThickness = 3,

						[Fusion.Children] = scope:Computed(function(use)
							local players = use(props.admin.players)
							local children = {
								UIPadding = UIPadding(scope, {
									paddingHeight = UDim.new(0, 10),
									paddingWidth = UDim.new(0, 0)
								}),
							}

							for index, player in players do
								table.insert(children, scope:New("Frame")({
									Size = UDim2.new(1, 0, 0, 28),
									BackgroundColor3 = Theme.BaseSidebarColor3,
									Position = UDim2.new(0, 0, 0, (25 + 7.5) * (index - 1)),

									[Fusion.Children] = {
										UICorner = UICorner(scope, {
											level = 1,
										}),

										UIPadding = UIPadding(scope, {
											paddingHeight = UDim.new(0, 0),
											paddingWidth = UDim.new(0, 10)
										}),

										Icon = ImageLabel(scope, {
											Size = UDim2.fromScale(0.1, 1),
											BackgroundTransparency = 1,
											Image = `rbxthumb://type=AvatarHeadShot&id={player.id}&w=352&h=352`
										}),

										Name = TextLabel(scope, {
											TextXAlignment = Enum.TextXAlignment.Left,
											Size = UDim2.fromScale(0.5, 1),
											Position = UDim2.fromScale(0.13, 0),
											Text = player.isAdmin and `<b>{player.name}</b>` or player.name,
											TextTruncate = Enum.TextTruncate.AtEnd,
											TextColor3 = player.isAdmin and Theme.AccentColor3 or Theme.BaseTextColor3,
											TextTransparency = 0.25,

											[Fusion.Children] = {
												UIPadding = UIPadding(scope, {
													paddingHeight = UDim.new(0, 16),
													paddingWidth = UDim.new(0, 0)
												}),
											}
										}),

										RemoveUser = ImageButton(scope, {
											Size = UDim2.fromScale(0.1, 0.7),
											Position = UDim2.fromScale(0.67, 0.25),
											Image = Theme.RemoveUserIcon,
											ImageTransparency = 0.5,

											[Fusion.OnEvent("Activated")] = function()
												props.signals.admin.kickUser:Fire(player.id)
											end,
										}),

										BanUser = ImageButton(scope, {
											Size = UDim2.fromScale(0.1, 0.5),
											Position = UDim2.fromScale(0.785, 0.25),
											Image = Theme.BanUserIcon,
											ImageTransparency = 0.5,

											[Fusion.OnEvent("Activated")] = function()
												props.signals.admin.banUser:Fire(player.id)
											end,
										}),

										AdminUser = ImageButton(scope, {
											Size = UDim2.fromScale(0.1, 0.5),
											Position = UDim2.fromScale(0.9, 0.25),
											Image = Theme.AdminUserIcon,
											ImageTransparency = player.isAdmin and 0 or 0.5,

											[Fusion.OnEvent("Activated")] = function()
												props.signals.admin.adminUser:Fire(player.id)
											end,
										})
									}
								}))
							end

							return children
						end)
					})
				}
			}),

			ServerActions = scope:New("Frame")({
				Size = UDim2.fromScale(0.6, 0.275),
				Position = UDim2.new(0.4, 5, 0, 0),
				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = {
					UICorner = UICorner(scope, {}),
					UIPadding = UIPadding(scope, {
						paddingHeight = UDim.new(0, 10),
						paddingWidth = UDim.new(0, 10)
					}),

					TitleLabel = TextLabel(scope, {
						Size = UDim2.fromScale(1, 0.3),
						Text = "Server",
						TextTransparency = 0.75
					}),

					RejoinServerButton = TextButton(scope, {
						Size = UDim2.fromScale(0.95, 0.3),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.325),
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.BaseSidebarColor3,
						Text = `Rejoin Server`,

						[Fusion.OnEvent("Activated")] = function()
							props.signals.admin.rejoinServer:Fire()
						end,

						[Fusion.Children] = {
							UICorner = UICorner(scope, {}),
							UIPadding = UIPadding(scope, {
								paddingHeight = UDim.new(0, 10),
								paddingWidth = UDim.new(0, 10)
							}),
						}
					}),

					ShutServerDownButton = TextButton(scope, {
						Size = UDim2.fromScale(0.95, 0.3),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.685),
						BackgroundTransparency = 0.5,
						BackgroundColor3 = Theme.AccentColor3,
						Text = `Shut Server Down`,

						[Fusion.OnEvent("Activated")] = function()
							props.signals.admin.shutServerDown:Fire()
						end,

						[Fusion.Children] = {
							UICorner = UICorner(scope, {}),
							UIPadding = UIPadding(scope, {
								paddingHeight = UDim.new(0, 10),
								paddingWidth = UDim.new(0, 10)
							}),
						}
					})
				}
			}),

			Configuration = scope:New("Frame")({
				Size = UDim2.fromScale(0.6, 0.7),
				Position = UDim2.new(0.4, 5, 0.275, 5),
				BackgroundColor3 = Theme.BaseTopbarColor3,

				[Fusion.Children] = scope:Computed(function(use)
					local childCount = 0
					local children = {
						UICorner = UICorner(scope, {}),
						UIPadding = UIPadding(scope, {
							paddingHeight = UDim.new(0, 10),
							paddingWidth = UDim.new(0, 10)
						}),

						TitleLabel = TextLabel(scope, {
							Size = UDim2.fromScale(1, 0.1),
							Text = "Config",
							TextTransparency = 0.75
						})
					}

					for configurationName, configurationValue in {
						["Open/Close Keybind"] = props.configuration.openCloseKey,
						["Persistent UI"] = props.configuration.persistentUI,
						["Max Cached Entries"] = props.configuration.maxCachedEntries,
						["Debug Sandbox"] = props.configuration.shouldDebugSandbox,
						["Debug Script Hub"] = props.configuration.shouldDebugScriptHub,
					} do
						local value = use(configurationValue)
						local valueString

						if typeof(value) == "EnumItem" then
							valueString = value.Name
						else
							valueString = tostring(value)
						end

						childCount += 1
						
						children[configurationName] = scope:New("Frame")({
							Size = UDim2.new(1, 0, 0, 25),
							Position = UDim2.new(0, 0,  0.15, 25 * (childCount - 1)),

							BackgroundTransparency = 1,

							[Fusion.Children] = {
								Label = TextLabel(scope, {
									Size = UDim2.fromScale(0.6, 1),
									Text = configurationName,
									TextXAlignment = Enum.TextXAlignment.Left,

									[Fusion.Children] = {
										UIPadding = UIPadding(scope, {
											paddingHeight = UDim.new(0, 15),
											paddingWidth = UDim.new(0, 10)
										}),
									}
								}),

								Value = TextLabel(scope, {
									Size = UDim2.fromScale(0.2, 0.9),
									Position = UDim2.fromScale(0.8, 0.05),
									BackgroundTransparency = 0,
									BackgroundColor3 = Theme.BaseSidebarColor3,
									Text = string.upper(valueString),

									[Fusion.Children] = {
										UICorner = UICorner(scope, {}),
										UIPadding = UIPadding(scope, {
											paddingHeight = UDim.new(0, 12),
											paddingWidth = UDim.new(0, 0)
										}),
									}
								}),
							}
						})
					end

					return children
				end)
			})
		}
	})
end

type Scope = FusionTypes.Scope
type Props = {
	configuration: {
		openCloseKey: FusionTypes.Value<Enum.KeyCode>,
		persistentUI: FusionTypes.Value<boolean>,
		maxCachedEntries: FusionTypes.Value<number>,
		shouldDebugSandbox: FusionTypes.Value<boolean>,
		shouldDebugScriptHub: FusionTypes.Value<boolean>,
	},

	admin: {
		players: FusionTypes.Value<{
			name: string,
			id: string,
			isAdmin: boolean
		}>,
	},

	signals: {
		admin: {
			kickUser: SignalTypes.Signal<string>,
			banUser: SignalTypes.Signal<string>,
			adminUser: SignalTypes.Signal<string>,
			rejoinServer: SignalTypes.Signal<()>,
			shutServerDown: SignalTypes.Signal<()>,
		},
	},
}

return {
	Render = Embedded.Render,
	Properties = {
		DisplayOrder = Embedded.DisplayOrder,
		DisplayName = Embedded.DisplayName,
		DisplayIcon = Embedded.DisplayIcon,

		Enabled = Embedded.Enabled,
	}
} :: PageTypes.PageElement<Scope, Props>
