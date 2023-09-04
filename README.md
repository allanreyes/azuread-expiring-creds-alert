# Azure AD Expiring Credentials Alerts
A repository that contains an Azure Function App that sends admins a list of enterprise applications with secrets and certifciates that are expired or expiring within the next X number of days.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/allanreyes/azuread-expiring-creds-alert)

## Table of Contents

## Architecture Diagram

## Features

* You can configure the number of days before a credential expires that is included in the list. For example, if you choose **30** during the deployment, then you will receive a list of all the expired credentials and those that are expiring within 30 days from when the report is generated.

## Azure deployment

The following steps will deploy everything required for the app to run. It creates the services in Azure, assigns API permissions to the managed identity, and finally deploys the function code to the app service. Because the managed identity needs to be given certain Graph API permissions, you'll need to use an Azure AD user account with a Global Administrator or Privileged Role Administrator role.

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

![image](https://github.com/allanreyes/azuread-expiring-creds-alert/assets/15065640/a31a5ee0-39a7-42bd-8979-52a8f8387c48)


4. Wait for the deployment to completef. This should take less than 5 minutes. When you get to this point, do not run the function yet. We'll go back to this prompt after authoprizing the connection to Office 365 Outlook.

![image](https://github.com/allanreyes/azuread-expiring-creds-alert/assets/15065640/6a11e2c3-6be6-4ee5-a354-9faf416c3988)

6. Open a new browser tab or use the current one, and click on the office365 API Connection resource inside the resource groups's overview tab

![image](https://github.com/allanreyes/azuread-expiring-creds-alert/assets/15065640/167e8e65-7819-43b9-8667-5ad5cf553f03)

   
7. Click on the Error message and then the Authorize button. Sign-in to your account that will be sending out emails. Click Save.
   
 ![image](https://github.com/allanreyes/azuread-expiring-creds-alert/assets/15065640/eddfcbb1-01bb-4714-9851-19b3fc5c1165)

![image](https://github.com/allanreyes/azuread-expiring-creds-alert/assets/15065640/3b2d05f2-4e7f-458e-91ea-472a03166405)

![image](https://github.com/allanreyes/azuread-expiring-creds-alert/assets/15065640/d15dffe4-71f2-4fdb-8b17-c0ab1ae93f4f)

8. Go back to the Azure Cloud Shell, type Y and then Enter/return.
![image](https://github.com/allanreyes/azuread-expiring-creds-alert/assets/15065640/66b9f1fc-898e-4464-83c2-1accb368a6d4)

9. In a matter of seconds, you should get an email that looks like this:
![image](https://github.com/allanreyes/azuread-expiring-creds-alert/assets/15065640/33e0ca1b-98f7-4b16-85a9-570997bc2807)

