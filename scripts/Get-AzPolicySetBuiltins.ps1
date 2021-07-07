
[ScriptBlock]$PolicyNameResolver = {
    $baseDisplayName = $PSItem.properties.displayname -replace '[^\s\w]',''
    $category = $PSItem.properties.metadata.category -replace '\s',''
    $name = (Get-Culture).TextInfo.ToTitleCase($baseDisplayName) -replace '\s',''
    $category + "_" + $name
}

Get-AzPolicySetDefinition |
    Where-Object {$_.properties.PolicyType -match 'BuiltIn|Static'} |
    Select-Object @{N='Name';E=$PolicyNameResolver}, PolicyDefinitionId |
    Sort-Object Name |
    Foreach-Object {
        "{0}: {1}" -f $_.Name,$_.PolicyDefinitionId
    }
