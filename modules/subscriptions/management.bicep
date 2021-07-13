// This represents the configuration of the management subscription
targetScope = 'subscription'

@description('The root name of the infrastructure. For a default deployment it is common to use the same name as your tenant name (e.g. use "me" for "me.onmicrosoft.com")')
param namePrefix string

@description('The region (location) to create the resources in this management group')
param location string

@description('One or more address ranges to include in the associated vnet')
param addressPrefixes array

@description('One or more address ranges to include in the associated vnet')
param bastionSubnet string

@description('Enable Azure Bastion for the Management Subnet')
param enableAzureBastion bool = true


var prefix = '${namePrefix}-management'

resource mgmtrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: prefix
  location: location
}


// if vnetNewOrExisting == 'new', create a new vnet and subnet
resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: '${namePrefix}-management'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetIpPrefix
        }
      }
    ]
  }
}
