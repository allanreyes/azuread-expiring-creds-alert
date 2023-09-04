targetScope = 'subscription'

param suffix string
param location string = deployment().location
param daysUntilExpiration string
param emailFrom string
param emailTo string

var resourceGroupName = 'rg-${suffix}'
var appName = 'fn-${suffix}-${uniqueString(rg.id)}'
var storageName = 'sa${uniqueString(rg.id)}'
var logicAppName = 'la-${suffix}-${uniqueString(rg.id)}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module storageAccount './modules/storageAccount.bicep' = {
  name: 'sa-${suffix}'
  scope: rg
  params: {
    location: location
    storageName: storageName
  }
}

module appInsights './modules/appInsights.bicep' = {
  name: 'appInsights-fn-${suffix}'
  scope: rg
  params: {
    appName: 'fn-${suffix}-${uniqueString(rg.id)}'
    location: location
  }
}

module functionApp './modules/functionApp.bicep' = {
  name: 'fn-${suffix}'
  scope: rg
  params: {
    appName: appName
    location: location
    saConnectionString: storageAccount.outputs.saConnectionString
    aiConnectionString: appInsights.outputs.aiConnectionString
    daysUntilExpiration: daysUntilExpiration
    emailTo: emailTo
    sendEmailUrl: logicApp.outputs.logicAppUrl
  }
}

module logicApp './modules/logicApp.bicep' = {
  name: 'la-${suffix}'
  scope: rg
  params: {
    location: location
    emailFrom: emailFrom
    logicAppName: logicAppName
  }
}

output appName string = appName
output resourceGroupName string = resourceGroupName
