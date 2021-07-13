// This represents the configuration of the management subscription
targetScope = 'subscription'

@description('The root name of the infrastructure. For a default deployment it is common to use the same name as your tenant name (e.g. use "me" for "me.onmicrosoft.com")')
param namePrefix string

@description('The region (location) to create the resources in this management group')
param location string
