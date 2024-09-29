--!strict
--!nolint LocalUnused
--!nolint LocalShadow

export type PageElement<scope, props> = {
	Render: (scope, props) -> Instance,
	Properties: {
		DisplayOrder: number,
		DisplayName: string,
		DisplayIcon: string,

		Enabled: boolean,
		DefaultPage: boolean?
	}
}

return nil
