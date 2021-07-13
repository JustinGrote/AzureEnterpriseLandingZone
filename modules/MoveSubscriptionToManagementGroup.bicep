// This is an annoying hack required because the "move" child resource action requires their names at runtime and the subscription is not yet known at the runtime of the "main" deployment.
targetScope = 'tenant'

@description('The management subscription ID')
param SubscriptionId string

@description('The parent management group ID')
param MgName string

resource managementGroup 'Microsoft.Management/managementGroups@2021-04-01' existing = {
  name: MgName
}

resource managementSubscriptionMoveToMg 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = {
  name: SubscriptionId
  parent: managementGroup
}
