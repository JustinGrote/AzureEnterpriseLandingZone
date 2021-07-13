targetScope = 'managementGroup'

@description('Select whether policy to deny public IP should be assigned or not.')
param denyPipForIdentity bool = true

// @maxLength(10)
// @description('Specify the identity management group id to apply policy to')
// param identityManagementGroupId string

// @description('Select whether policy to deny inbound RDP should be assigned or not.')
// param denyRdpForIdentity bool = false

// @description('Select whether policy to deny subnet without NSG should be assigned or not.')
// param denySubnetWithoutNsgForIdentity bool = false



// @description('Select whether policy to enable VM backup should be assigned or not.')
// param enableVmBackupForIdentity bool = false

// module builtin '../builtin.bicep' = {
//   name: 'builtinReferences-DoesNotDeployAnything'
//   scope: tenant()
// }

var policy = json(loadTextContent('../constants/builtin/policy.json'))
var vmSku = json(loadTextContent('../constants/builtin/vmSku.json'))

resource denyPipForIdentityPolicy 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denyPipForIdentity) {
  name: 'denyPipForIdentity'
  properties: {
    policyDefinitionId: policy.Compute_AllowedVirtualMachineSizeSkus
    parameters: {
    }
  }
}

// var roleAssignmentNames = {
//   deployVmBackup: guid('${prefix}identity${policyAssignmentNames.deployVmBackup}')
// }

// resource policyAssignmentNames_deployVmBackup 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (enableVmBackupForIdentity) {
//   name: policyAssignmentNames.deployVmBackup
//   location: deployment().location
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     description: 'Deploy-VM-Backup'
//     displayName: 'Deploy-VM-Backup'
//     policyDefinitionId: policyDefinitions.deployVmBackup
//     scope: scope
//     parameters: {}
//   }
// }

// resource roleAssignmentNames_deployVmBackup 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (enableVmBackupForIdentity) {
//   name: roleAssignmentNames.deployVmBackup
//   properties: {
//     principalType: 'ServicePrincipal'
//     roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${rbacOwner}'
//     principalId: ((enableVmBackupForIdentity) ? toLower(reference('/providers/Microsoft.Authorization/policyAssignments/${policyAssignmentNames.deployVmBackup}', '2018-05-01', 'Full').identity.principalId) : 'na')
//   }
//   dependsOn: [
//     policyAssignmentNames_deployVmBackup
//   ]
// }

// resource policyAssignmentNames_denyPip 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denyPipForIdentity) {
//   name: policyAssignmentNames.denyPip
//   properties: {
//     description: 'Deny-Public-IP'
//     displayName: 'Deny-Public-IP'
//     policyDefinitionId: policyDefinitions.denyPip
//     scope: scope
//   }
// }

// resource policyAssignmentNames_denyRdp 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denyRdpForIdentity) {
//   name: policyAssignmentNames.denyRdp
//   properties: {
//     description: 'Deny-RDP-from-Internet'
//     displayName: 'Deny-RDP-from-Internet'
//     policyDefinitionId: policyDefinitions.denyRdp
//     scope: scope
//   }
// }

// resource policyAssignmentNames_denySubnetWithoutNsg 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denySubnetWithoutNsgForIdentity) {
//   name: policyAssignmentNames.denySubnetWithoutNsg
//   properties: {
//     description: 'Deny-Subnet-Without-Nsg'
//     displayName: 'Deny-Subnet-Without-Nsg'
//     policyDefinitionId: policyDefinitions.denySubnetWithoutNsg
//     scope: scope
//   }
// }
