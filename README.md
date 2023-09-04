# Azure AD Expiring Credentials Alerts
A repository that contains an Azure Function App that sends admins a list of enterprise applications with secrets and certifciates that are expired or expiring within the next X number of days.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/allanreyes/azuread-expiring-creds-alert)

## Table of Contents

## Architecture Diagram

## Features

* You can configure the number of days before a credential expires that is included in the list. For example, if you choose **30** during the deployment, then you will receive a list of all the expired credentials and those that are expiring within 30 days from when the report is generated.

## Azure deployment

The following steps will deploy everything required for the app to run. It creates the services in Azure, assigns API permissions to the managed identity, and finally deploys the function code to the app service.

> **IMPORTANT:** In order for the logic app to connect to Office 365 Outlook and send email notifications, you need to authorize the connection from within the portal. Follow the instructions and screenshots below.

1. Go to the <a href="https://portal.azure.com" target="_blank">Azure Portal</a> and start a new Azure Cloud Shell session (PowerShell)

![image](https://github.com/allanreyes/azuread-expiring-creds-alert/assets/15065640/76ccd6c7-2b41-4f83-9b94-784c72dba34f)

2. Clone this repository, navigate inside the newly cloned directory, and run the deploy.ps1 file

```
git clone https://github.com/allanreyes/azuread-expiring-creds-alert.git
cd azuread-expiring-creds-alert
.\deploy.ps1
```

3. Provide new values for each prompt or use the default values by hitting Enter/return
   

4. Wait for the deployment to complete

5. Open a new browser tab or use the current one, and click on the office365 API Connection resource
   
6. Click on the Error message and then the Authorize button. Sign-in to your account, the one that will be sending out emails. Click Save.
   
 
