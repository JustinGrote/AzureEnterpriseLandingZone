targetScope = 'tenant'

@maxLength(10)
@description('Provide a prefix (max 10 characters, unique at tenant-scope) for the Management Group hierarchy and other resources created as part of Enterprise-scale.')
param topLevelManagementGroupPrefix string

@allowed([
  'Yes'
  'No'
])
@description('Select whether SQL audit policy should be assigned or not.')
param enableSqlAudit string = 'No'

@allowed([
  'Yes'
  'No'
])
@description('Select whether AKS policy should be assigned or not.')
param enableAksPolicy string = 'No'

@allowed([
  'Yes'
  'No'
])
@description('Select whether AKS privileged policy should be assigned or not.')
param denyAksPrivileged string = 'No'

@allowed([
  'Yes'
  'No'
])
@description('Select whether AKS escalation policy should be assigned or not.')
param denyAksPrivilegedEscalation string = 'No'

@allowed([
  'Yes'
  'No'
])
@description('Select whether AKS ingress policy should be assigned or not.')
param denyHttpIngressForAks string = 'No'

@allowed([
  'Yes'
  'No'
])
@description('Select whether SQL encryption policy should be assigned or not.')
param enableSqlEncryption string = 'No'

@allowed([
  'Yes'
  'No'
])
@description('Select whether VM backup policy should be assigned or not.')
param enableVmBackup string = 'No'

@allowed([
  'Yes'
  'No'
])
@description('Select whether deny RDP inbound policy should be assigned or not.')
param denyRdp string = 'No'

@allowed([
  'Yes'
  'No'
])
@description('Select whether https for storage account policy should be assigned or not.')
param enableStorageHttps string = 'No'

@allowed([
  'Yes'
  'No'
])
@description('Select whether deny IP forwarding policy should be assigned or not.')
param denyIpForwarding string = 'No'

@allowed([
  'Yes'
  'No'
])
@description('Select whether subnet with NSG policy should be assigned or not.')
param denySubnetWithoutNsg string = 'No'

var scope = '/providers/Microsoft.Management/managementGroups/${topLevelManagementGroupPrefix}-landingzones'
var policyDefinitions = {
  deployVmBackup: '/providers/Microsoft.Authorization/policyDefinitions/98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86'
  denySubnetWithoutNsg: '/providers/Microsoft.Management/managementGroups/${topLevelManagementGroupPrefix}/providers/Microsoft.Authorization/policyDefinitions/Deny-Subnet-Without-Nsg'
  denyRdp: '/providers/Microsoft.Management/managementGroups/${topLevelManagementGroupPrefix}/providers/Microsoft.Authorization/policyDefinitions/Deny-RDP-From-Internet'
  denyIpForwarding: '/providers/Microsoft.Authorization/policyDefinitions/88c0b9da-ce96-4b03-9635-f29a937e2900'
  deploySqlEncryption: '/providers/Microsoft.Authorization/policyDefinitions/86a912f6-9a06-4e26-b447-11b16ba8659f'
  deploySqlSecurity: '/providers/Microsoft.Authorization/policyDefinitions/f4c68484-132f-41f9-9b6d-3e4b1cb55036'
  deploySqlAuditing: '/providers/Microsoft.Authorization/policyDefinitions/a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9'
  storageHttps: '/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9'
  deployStorageAtp: '/providers/Microsoft.Authorization/policyDefinitions/361c2074-3595-4e5d-8cab-4f21dffc835c'
  deployAks: '/providers/Microsoft.Authorization/policyDefinitions/a8eff44f-8c92-45c3-a3fb-9880802d67a7'
  denyAksPriv: '/providers/Microsoft.Authorization/policyDefinitions/95edb821-ddaf-4404-9732-666045e056b4'
  denyAksNoPrivEsc: '/providers/Microsoft.Authorization/policyDefinitions/1c6e92c9-99f0-4e55-9cf2-0c234dc48f99'
  denyHttpIngressAks: '/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d'
}
var policyAssignmentNames = {
  deployVmBackup: 'Deploy-VM-Backup'
  denySubnetWithoutNsg: 'Deny-Subnet-Without-Nsg'
  denyRdp: 'Deny-RDP-from-internet'
  denyIpForwarding: 'Deny-IP-forwarding'
  deploySqlEncryption: 'Enforce-SQL-Encryption'
  deploysqlSecurity: 'Deploy-SQL-Security'
  deploySqlAuditing: 'Deploy-SQL-DB-Auditing'
  storageHttps: 'Deny-Storage-http'
  deployStorageAtp: 'Deploy-Storage-ATP'
  deployAks: 'Deploy-AKS-Policy'
  denyAksPriv: 'Deny-Privileged-AKS'
  denyAksNoPrivEsc: 'Deny-Priv-Esc-AKS'
  denyHttpIngressAks: 'Enforce-AKS-HTTPS'
}
var rbacOwner = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var roleAssignmentNames = {
  deployVmBackup: guid('${topLevelManagementGroupPrefix}${policyAssignmentNames.deployVmBackup}')
  deploySqlSecurity: guid('${topLevelManagementGroupPrefix}${policyAssignmentNames.deploysqlSecurity}')
  deploySqlAuditing: guid('${topLevelManagementGroupPrefix}${policyAssignmentNames.deploySqlAuditing}')
  deployStorageAtp: guid('${topLevelManagementGroupPrefix}${policyAssignmentNames.deployStorageAtp}')
  deploySqlEncryption: guid('${topLevelManagementGroupPrefix}${policyAssignmentNames.deploySqlEncryption}')
  deployAks: guid('${topLevelManagementGroupPrefix}${policyAssignmentNames.deployAks}')
}

resource policyAssignmentNames_denyRdp 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denyRdp == 'Yes') {
  name: policyAssignmentNames.denyRdp
  properties: {
    description: 'Deny-RDP-from-Internet'
    displayName: 'Deny-RDP-from-Internet'
    policyDefinitionId: policyDefinitions.denyRdp
    scope: scope
  }
}

resource policyAssignmentNames_deployVmBackup 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (enableVmBackup == 'Yes') {
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

resource roleAssignmentNames_deployVmBackup 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (enableVmBackup == 'Yes') {
  name: roleAssignmentNames.deployVmBackup
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${rbacOwner}'
    principalId: ((enableVmBackup == 'Yes') ? toLower(reference('/providers/Microsoft.Authorization/policyAssignments/${policyAssignmentNames.deployVmBackup}', '2018-05-01', 'Full').identity.principalId) : 'na')
  }
  dependsOn: [
    policyAssignmentNames_deployVmBackup
  ]
}

resource policyAssignmentNames_deploySqlAuditing 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (enableSqlAudit == 'Yes') {
  name: policyAssignmentNames.deploySqlAuditing
  location: deployment().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Deploy-SQL-Audit'
    displayName: 'Deploy-SQL-Audit'
    policyDefinitionId: policyDefinitions.deploySqlAuditing
    scope: scope
  }
}

resource roleAssignmentNames_deploySqlAuditing 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (enableSqlAudit == 'Yes') {
  name: roleAssignmentNames.deploySqlAuditing
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${rbacOwner}'
    principalId: ((enableSqlAudit == 'Yes') ? toLower(reference('/providers/Microsoft.Authorization/policyAssignments/${policyAssignmentNames.deploySqlAuditing}', '2018-05-01', 'Full').identity.principalId) : 'na')
  }
  dependsOn: [
    policyAssignmentNames_deploySqlAuditing
  ]
}

resource policyAssignmentNames_deploySqlEncryption 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (enableSqlEncryption == 'Yes') {
  name: policyAssignmentNames.deploySqlEncryption
  location: deployment().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Deploy-SQL-Security'
    displayName: 'Deploy-SQL-Security'
    policyDefinitionId: policyDefinitions.deploySqlEncryption
    scope: scope
  }
}

resource roleAssignmentNames_deploySqlEncryption 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (enableSqlEncryption == 'Yes') {
  name: roleAssignmentNames.deploySqlEncryption
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${rbacOwner}'
    principalId: ((enableSqlEncryption == 'Yes') ? toLower(reference('/providers/Microsoft.Authorization/policyAssignments/${policyAssignmentNames.deploySqlEncryption}', '2018-05-01', 'Full').identity.principalId) : 'na')
  }
  dependsOn: [
    policyAssignmentNames_deploySqlEncryption
  ]
}

resource policyAssignmentNames_deployAks 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (enableAksPolicy == 'Yes') {
  name: policyAssignmentNames.deployAks
  location: deployment().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Deploy-AKS-Policy'
    displayName: 'Deploy-AKS-Policy'
    policyDefinitionId: policyDefinitions.deployAks
    scope: scope
  }
}

resource roleAssignmentNames_deployAks 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (enableAksPolicy == 'Yes') {
  name: roleAssignmentNames.deployAks
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${rbacOwner}'
    principalId: ((enableAksPolicy == 'Yes') ? toLower(reference('/providers/Microsoft.Authorization/policyAssignments/${policyAssignmentNames.deployAks}', '2018-05-01', 'Full').identity.principalId) : 'na')
  }
  dependsOn: [
    policyAssignmentNames_deployAks
  ]
}

resource policyAssignmentNames_denyAksPriv 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denyAksPrivileged == 'Yes') {
  name: policyAssignmentNames.denyAksPriv
  properties: {
    description: 'Deny-Privileged-Containers-AKS'
    displayName: 'Deny-Privileged-Containers-AKS'
    policyDefinitionId: policyDefinitions.denyAksPriv
    scope: scope
    parameters: {
      effect: {
        value: 'deny'
      }
    }
  }
}

resource policyAssignmentNames_denyAksNoPrivEsc 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denyAksPrivilegedEscalation == 'Yes') {
  name: policyAssignmentNames.denyAksNoPrivEsc
  properties: {
    description: 'Deny-Privileged-Escalations-AKS'
    displayName: 'Deny-Privileged-Escalations-AKS'
    policyDefinitionId: policyDefinitions.denyAksNoPrivEsc
    scope: scope
    parameters: {
      effect: {
        value: 'deny'
      }
    }
  }
}

resource policyAssignmentNames_denyHttpIngressAks 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denyHttpIngressForAks == 'Yes') {
  name: policyAssignmentNames.denyHttpIngressAks
  properties: {
    description: 'Enforce-Https-Ingress-AKS'
    displayName: 'Enforce-Https-Ingress-AKS'
    policyDefinitionId: policyDefinitions.denyHttpIngressAks
    scope: scope
    parameters: {
      effect: {
        value: 'deny'
      }
    }
  }
}

resource policyAssignmentNames_storageHttps 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (enableStorageHttps == 'Yes') {
  name: policyAssignmentNames.storageHttps
  properties: {
    description: 'Enforce-Secure-Storage'
    displayName: 'Enforce-Secure-Storage'
    policyDefinitionId: policyDefinitions.storageHttps
    scope: scope
    parameters: {
      effect: {
        value: 'Deny'
      }
    }
  }
}

resource policyAssignmentNames_denyIpForwarding 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denyIpForwarding == 'Yes') {
  name: policyAssignmentNames.denyIpForwarding
  properties: {
    description: 'Deny-IP-Forwarding'
    displayName: 'Deny-IP-Forwarding'
    policyDefinitionId: policyDefinitions.denyIpForwarding
    scope: scope
  }
}

resource policyAssignmentNames_denySubnetWithoutNsg 'Microsoft.Authorization/policyAssignments@2018-05-01' = if (denySubnetWithoutNsg == 'Yes') {
  name: policyAssignmentNames.denySubnetWithoutNsg
  properties: {
    description: 'Deny-Subnet-Without-Nsg'
    displayName: 'Deny-Subnet-Without-Nsg'
    policyDefinitionId: policyDefinitions.denySubnetWithoutNsg
    scope: scope
  }
}
