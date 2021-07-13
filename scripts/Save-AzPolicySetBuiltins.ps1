$destinationDir = Resolve-Path modules/constants
function Resolve-AzPolicyName ($PolicyItem) {
    $baseDisplayName = $PolicyItem.properties.displayname -replace '[^\s\w]',''
    $category = $PolicyItem.properties.metadata.category -replace '\s',''
    $name = (Get-Culture).TextInfo.ToTitleCase($baseDisplayName) -replace '\s',''
    $category + "_" + $name
}

# Policies
$policyDefinitionMap = [Collections.Generic.SortedDictionary[String,String]]::new()
$policyCategories = 'Compute','Storage','Tags','KeyVault','Backup'
Get-AzPolicyDefinition |
    Where-Object {$_.properties.metadata.category -in $policyCategories} |
    Where-Object {$_.properties.PolicyType -match 'BuiltIn|Static'} |
    Foreach-Object {
        $Name = Resolve-AzPolicyName $PSItem
        $policyDefinitionMap[$Name] = $PSItem.PolicyDefinitionId
    }
$policyJson = $policyDefinitionMap | ConvertTo-Json
if (131072 -lt ([char[]]$policyJson).count) {throw 'Bicep only allows a json file to be 131072 characters. Please select less policies via category'}
$policyJson | Out-File $destinationDir/builtin/policy.json

# Policy Sets
$policySetDefinitionMap = [Collections.Generic.SortedDictionary[String,String]]::new()
Get-AzPolicySetDefinition |
    Where-Object {$_.properties.PolicyType -match 'BuiltIn|Static'} |
    Foreach-Object {
        $Name = Resolve-AzPolicyName $PSItem
        $policySetDefinitionMap[$Name] = $PSItem.PolicySetDefinitionId
    }
$policySetDefinitionMap | ConvertTo-Json | Out-File $destinationDir/builtin/policySet.json

# VM Sizes
$sizeMap = [Collections.Generic.SortedDictionary[String,String]]::new()
Get-AzVMSize -Location westus2 |
    Foreach-Object {
        $sizeMap[$_.Name] = $_.Name
    }
$sizeMap | ConvertTo-Json | Out-File $destinationDir/builtin/vmSku.json