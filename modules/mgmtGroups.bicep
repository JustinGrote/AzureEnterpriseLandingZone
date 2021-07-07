targetScope = 'tenant'

@description('Provide prefix for the management group structure. This should be the name of your company')
param topLevelManagementGroupPrefix string

@description('Management groups for platform specific purposes, such as management, networking, identity etc.')
param platformMgs array = [
  'management'
  'connectivity'
  'identity'
]

@description('These are the landing zone management groups.')
param landingZoneMgs array = [
  'online'
  'corp'
]

var enterpriseScaleManagementGroups = {
  platform: '${topLevelManagementGroupPrefix}-platform'
  landingZone: '${topLevelManagementGroupPrefix}-landingzones'
  decommissioned: '${topLevelManagementGroupPrefix}-decommissioned'
  sandboxes: '${topLevelManagementGroupPrefix}-sandboxes'
}

resource topLevelMg 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: topLevelManagementGroupPrefix
  properties: {}
}

resource enterpriseScaleManagementGroups_platform 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: enterpriseScaleManagementGroups.platform
  properties: {
    displayName: enterpriseScaleManagementGroups.platform
    details: {
      parent: {
        id: topLevelMg.id
      }
    }
  }
}

resource enterpriseScaleManagementGroups_landingZone 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: enterpriseScaleManagementGroups.landingZone
  properties: {
    displayName: enterpriseScaleManagementGroups.landingZone
    details: {
      parent: {
        id: topLevelMg.id
      }
    }
  }
}

resource enterpriseScaleManagementGroups_sandboxes 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: enterpriseScaleManagementGroups.sandboxes
  properties: {
    displayName: enterpriseScaleManagementGroups.sandboxes
    details: {
      parent: {
        id: topLevelMg.id
      }
    }
  }
}

resource enterpriseScaleManagementGroups_decommissioned 'Microsoft.Management/managementGroups@2020-05-01' = {
  name: enterpriseScaleManagementGroups.decommissioned
  properties: {
    displayName: enterpriseScaleManagementGroups.decommissioned
    details: {
      parent: {
        id: topLevelMg.id
      }
    }
  }
}

resource topLevelManagementGroupPrefix_platformMgs 'Microsoft.Management/managementGroups@2020-05-01' = [for item in platformMgs: if (!empty(platformMgs)) {
  name: '${topLevelManagementGroupPrefix}-${item}'
  properties: {
    displayName: '${topLevelManagementGroupPrefix}-${item}'
    details: {
      parent: {
        id: enterpriseScaleManagementGroups_platform.id
      }
    }
  }
}]

resource topLevelManagementGroupPrefix_landingZoneMgs 'Microsoft.Management/managementGroups@2020-05-01' = [for item in landingZoneMgs: if (!empty(landingZoneMgs)) {
  name: '${topLevelManagementGroupPrefix}-${item}'
  properties: {
    displayName: '${topLevelManagementGroupPrefix}-${item}'
    details: {
      parent: {
        id: enterpriseScaleManagementGroups_landingZone.id
      }
    }
  }
}]

output landingZoneMgName string = enterpriseScaleManagementGroups_landingZone.name
output identityMgName string = topLevelManagementGroupPrefix_platformMgs[2].name
