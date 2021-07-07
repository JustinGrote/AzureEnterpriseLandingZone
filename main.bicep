@description('The root name of the infrastructure')
param namePrefix string

module rbac 'modules/wellKnownRBAC.bicep' = {
  name: 'rbac'
}


module mgmtGroups 'modules/mgmtGroups.bicep' = {
  name: 'ManagementGroups'
  scope: tenant()
  params: {
    topLevelManagementGroupPrefix: namePrefix
  }
}

module mgpolicyidentity 'modules/policies/mgpolicy-identity.bicep' = {
  name: '${namePrefix}-identity-policy'
  scope: tenant()
  params: {
    topLevelManagementGroupPrefix: namePrefix
    denyPipForIdentity: true
    denyRdpForIdentity: true
    denySubnetWithoutNsgForIdentity: true
    enableVmBackupForIdentity: true
  }
}

var test = {
  MyTest: 5
}
