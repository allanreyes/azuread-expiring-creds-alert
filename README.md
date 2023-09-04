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