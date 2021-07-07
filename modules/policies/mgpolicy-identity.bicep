targetScope = 'tenant'

@maxLength(10)
@description('Provide a prefix (max 10 characters, unique at tenant-scope) for the Management Group hierarchy')
param prefix string

@description('Select whether policy to deny inbound RDP should be assigned or not.')
param denyRdpForIdentity bool = false

@description('Select whether policy to deny subnet without NSG should be assigned or not.')
param denySubnetWithoutNsgForIdentity bool = false

@description('Select whether policy to deny public IP should be assigned or not.')
param denyPipForIdentity bool = false

@description('Select whether policy to enable VM backup should be assigned or not.')
param enableVmBackupForIdentity bool = false

var scope = '/providers/Microsoft.Management/managementGroups/${prefix}-identity'
var policyDefinitions = {
  denySubnetWithoutNsg: '/providers/Microsoft.Management/managementGroups/${prefix}/providers/Microsoft.Authorization/policyDefinitions/Deny-Subnet-Without-Nsg'
  denyPip: '/providers/Microsoft.Management/managementGroups/${prefix}/providers/Microsoft.Authorization/policyDefinitions/Deny-PublicIP'
  denyRdp: '/providers/Microsoft.Management/managementGroups/${prefix}/providers/Microsoft.Authorization/policyDefinitions/Deny-RDP-From-Internet'
  deployVmBackup: '/providers/Microsoft.Authorization/policyDefinitions/98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86'
}
var policyAssignmentNames = {
  denySubnetWithoutNsg: 'Deny-Subnet-Without-Nsg'
  denyRdp: 'Deny-RDP-from-internet'
  denyPip: 'Deny-Public-IP'
  deployVmBackup: 'Deploy-VM-Backup'
}
var rbacOwner = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var roleAssignmentNames = {
  deployVmBackup: guid('${prefix}identity${policyAssignmentNames.deployVmBackup}')
}

resource policyAssignmentNames_deployVmBackup 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (enableVmBackupForIdentity) {
  name: policyAssignmentNames.deployVmBackup
  location: deployment().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Deploy-VM-Backup'
    displayName: 'Deploy-VM-Backup'
    policyDefinitionId: policyDefinitions.deployVmBackup
    scope: scope
    parameters: {}
  }
}

resource roleAssignmentNames_deployVmBackup 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (enableVmBackupForIdentity) {
  name: roleAssignmentNames.deployVmBackup
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${rbacOwner}'
    principalId: ((enableVmBackupForIdentity == 'Yes') ? toLower(reference('/providers/Microsoft.Authorization/policyAssignments/${policyAssignmentNames.deployVmBackup}', '2018-05-01', 'Full').identity.principalId) : 'na')
  }
  dependsOn: [
    policyAssignmentNames_deployVmBackup
  ]
}

resource policyAssignmentNames_denyPip 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denyPipForIdentity) {
  name: policyAssignmentNames.denyPip
  properties: {
    description: 'Deny-Public-IP'
    displayName: 'Deny-Public-IP'
    policyDefinitionId: policyDefinitions.denyPip
    scope: scope
  }
}

resource policyAssignmentNames_denyRdp 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denyRdpForIdentity) {
  name: policyAssignmentNames.denyRdp
  properties: {
    description: 'Deny-RDP-from-Internet'
    displayName: 'Deny-RDP-from-Internet'
    policyDefinitionId: policyDefinitions.denyRdp
    scope: scope
  }
}

resource policyAssignmentNames_denySubnetWithoutNsg 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denySubnetWithoutNsgForIdentity) {
  name: policyAssignmentNames.denySubnetWithoutNsg
  properties: {
    description: 'Deny-Subnet-Without-Nsg'
    displayName: 'Deny-Subnet-Without-Nsg'
    policyDefinitionId: policyDefinitions.denySubnetWithoutNsg
    scope: scope
  }
}