// This template deploys the main management group structure and resources at the tenant level

targetScope = 'tenant'
@description('The root name of the infrastructure. For a default deployment it is common to use the same name as your tenant name (e.g. use "me" for "me.onmicrosoft.com")')
param enterpriseScaleCompanyPrefix string

@description('The default region (location) to create resources.')
param location string

@description('Billing Account Id for this tenant')
param BillingAccountId string

@description('Billing Profile Name')
param EnrollmentAccountId string

// Provisions the base management groups and subscriptions under an EA agreement
module mgmtGroupsAndSubs 'modules/ManagementGroupsAndSubscriptions.bicep' = {
  name: '${enterpriseScaleCompanyPrefix}-ManagementGroups'
  params: {
    billingAccountId: BillingAccountId
    enrollmentAccountId: EnrollmentAccountId
    topLevelManagementGroupPrefix: enterpriseScaleCompanyPrefix
  }
}




// module mgPolicy_Identity 'modules/policies/mgpolicy-identity.bicep' = {
//   name: '${enterpriseScaleCompanyPrefix}-identity-policy'
//   scope: managementGroup('${enterpriseScaleCompanyPrefix}-identity') //Because scopes are compile-time, we need to pass the mgmt group name in explicitly
//   params: {
//     identityManagementGroupId: mgmtGroups.outputs.identityMgId //This sets an implicit dependency on mgmtGroups
//     denyPipForIdentity: true
//     denyRdpForIdentity: true
//     denySubnetWithoutNsgForIdentity: true
//     enableVmBackupForIdentity: true
//   }
// }
