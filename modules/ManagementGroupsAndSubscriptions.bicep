targetScope = 'tenant'

@description('Provide prefix for the management group structure. This should be the name of your company')
param topLevelManagementGroupPrefix string

@description('These are the landing zone management groups.')
param landingZoneMgs array = [
  'online'
  'corp'
]

resource topLevelMg 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: topLevelManagementGroupPrefix
  properties: {}
}

var enterpriseScaleManagementGroups = {
  platform: '${topLevelManagementGroupPrefix}-platform'
  landingZone: '${topLevelManagementGroupPrefix}-landingzones'
  decommissioned: '${topLevelManagementGroupPrefix}-decommissioned'
  sandboxes: '${topLevelManagementGroupPrefix}-sandboxes'
}

resource platformMg 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: enterpriseScaleManagementGroups.platform
  properties: {
    displayName: enterpriseScaleManagementGroups.platform
    details: {
      parent: topLevelMg
    }
  }
}

resource landingZoneMg 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: enterpriseScaleManagementGroups.landingZone
  properties: {
    displayName: enterpriseScaleManagementGroups.landingZone
    details: {
      parent: topLevelMg
    }
  }
}

resource sandboxesMg 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: enterpriseScaleManagementGroups.sandboxes
  properties: {
    displayName: enterpriseScaleManagementGroups.sandboxes
    details: {
      parent: topLevelMg
    }
  }
}

resource decomissionedMg 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: enterpriseScaleManagementGroups.decommissioned
  properties: {
    displayName: enterpriseScaleManagementGroups.decommissioned
    details: {
      parent: topLevelMg
    }
  }
}

var platformMgs = [
  'management'
  'connectivity'
  'identity'
]

resource platformMgChildren 'Microsoft.Management/managementGroups@2020-05-01' = [for item in platformMgs: if (!empty(platformMgs)) {
  name: '${topLevelManagementGroupPrefix}-${item}'
  properties: {
    displayName: '${topLevelManagementGroupPrefix}-${item}'
    details: {
      parent: platformMg
    }
  }
}]

resource landingZoneMgChildren 'Microsoft.Management/managementGroups@2020-05-01' = [for item in landingZoneMgs: if (!empty(landingZoneMgs)) {
  name: '${topLevelManagementGroupPrefix}-${item}'
  properties: {
    displayName: '${topLevelManagementGroupPrefix}-${item}'
    details: {
      parent: landingZoneMg
    }
  }
}]

@description('The billing account Id, usually the EA enrollment ID ex. 7512131')
param billingAccountId string

@description('The enrollment account Id, usuauly the EA account ID ex: 211011')
param enrollmentAccountId string

var billingScopeId = '/providers/Microsoft.Billing/billingAccounts/${billingAccountId}/enrollmentAccounts/${enrollmentAccountId}'
var subDefaults = {
  workload: 'Production'
  billingScope: billingScopeId
}


// TODO: Make this a loop
// Management Subscription
resource managementSubscription 'Microsoft.Subscription/aliases@2020-09-01' = {
  scope: tenant()
  name: 'NANDPS-management'
  properties: union(subDefaults,{
    displayName: 'NANDPS-management'
  })
}

// Move created EA subscriptions to appropriate management groups
var managementMgName = platformMgChildren[0].name
module moveMgmtSubToMgmtGroup 'MoveSubscriptionToManagementGroup.bicep' = {
  name: '${topLevelManagementGroupPrefix}-management-MoveSubscriptionToManagementGroup'
  params: {
    MgName: managementMgName
    SubscriptionId: managementSubscription.properties.subscriptionId
  }
}
output managementSubscriptionId string = managementSubscription.id


// Connectivity Subscription
resource connectivitySubscription 'Microsoft.Subscription/aliases@2020-09-01' = {
  scope: tenant()
  name: 'NANDPS-connectivity'
  properties: union(subDefaults,{
    displayName: 'NANDPS-connectivity'
  })
}

// Move created EA subscriptions to appropriate connectivity groups
var connectivityMgName = platformMgChildren[1].name
module moveconnectivitySubToMgmtGroup 'MoveSubscriptionToManagementGroup.bicep' = {
  name: '${topLevelManagementGroupPrefix}-connectivity-MoveSubscriptionToManagementGroup'
  params: {
    MgName: connectivityMgName
    SubscriptionId: connectivitySubscription.properties.subscriptionId
  }
}
output connectivitySubscriptionId string = connectivitySubscription.id


// Identity Subscription
resource identitySubscription 'Microsoft.Subscription/aliases@2020-09-01' = {
  scope: tenant()
  name: 'NANDPS-identity'
  properties: union(subDefaults,{
    displayName: 'NANDPS-identity'
  })
}

// Move created EA subscriptions to appropriate identity groups
var identityMgName = platformMgChildren[2].name
module moveidentitySubToMgmtGroup 'MoveSubscriptionToManagementGroup.bicep' = {
  name: '${topLevelManagementGroupPrefix}-identity-MoveSubscriptionsToidentityGroups'
  params: {
    MgName: identityMgName
    SubscriptionId: identitySubscription.properties.subscriptionId
  }
}
output identitySubscriptionId string = identitySubscription.id


// output managementSubscriptionId string = managementSubscription.id

// // Connectivity Subscription
// var connectivityMgName = platformMgChildren[1].name
// resource connectivitySubscription 'Microsoft.Subscription/aliases@2020-09-01' = {
//   name: connectivityMgName
//   properties: union(subDefaults,{
//     displayName: connectivityMgName
//   })
// }
// resource connectivitySubscriptionMoveToMg 'Microsoft.Management/ManagementGroups/subscriptions@2021-04-01' = {
//   name: connectivitySubscription.id
//   parent: platformMgChildren[1]
// }
// output connectivitySubscriptionId string = connectivitySubscription.id

// // Identity Subscription
// var identityMgName = platformMgChildren[2].name
// resource identitySubscription 'Microsoft.Subscription/aliases@2020-09-01' = {
//   name: identityMgName
//   properties: union(subDefaults,{
//     displayName: identityMgName
//   })
// }
// resource identitySubscriptionMoveToMg 'Microsoft.Management/ManagementGroups/subscriptions@2021-04-01' = {
//   name: identitySubscription.id
//   parent: platformMgChildren[2]
// }
// output identitySubscriptionId string = identitySubscription.id
