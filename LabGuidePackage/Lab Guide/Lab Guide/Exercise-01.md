# Exercise 01: Prepare the starter project and deploy Azure Cosmos DB vector search

### Estimated Duration: 1 Hour

## Scenario

In this exercise, you will use the CloudLabs Azure LabVM to begin the Microsoft semantic search lab exactly as authored in `instructions/cosmosdb/02-build-semantic-search.md`. You will complete the first two Microsoft tasks by downloading the starter files, configuring the deployment script, and deploying an Azure Cosmos DB for NoSQL account with vector search capability.

## Overview

This exercise is a wrapper for the first two tasks in the Microsoft lab. CloudLabs provides the LabVM, browser, Visual Studio Code, Azure CLI, Python, Git, and PowerShell. You must follow the Microsoft markdown for the detailed procedure and keep the same task order.

## Objectives

- Task 1: Download project starter files and configure the deployment script
- Task 2: Deploy an Azure Cosmos DB for NoSQL account with vector search capability

## Task 1: Download project starter files and configure the deployment script

In this task, you will sign in to Azure from the LabVM, open the Microsoft semantic search lab instructions, and complete Task 1 from the Microsoft markdown without changing the provided procedure.

1. On the LabVM, open a browser and sign in to the Azure portal at <https://portal.azure.com> using the following credentials:
   - Username: <inject key="AzureAdUserEmail"></inject>
   - Password: `<inject key="AzureAdUserPassword"></inject>`
2. Confirm that you are working in subscription `<inject key="SubscriptionID"></inject>` and tenant `<inject key="TenantID"></inject>`.
3. Record the CloudLabs deployment identifier for this lab session: **Deployment ID: `<inject key="DeploymentID" enableCopy="false"></inject>`**.
4. Open Visual Studio Code from the LabVM.
5. Open PowerShell or Windows Terminal on the LabVM.
6. Verify the workstation tools that you will use during the Microsoft lab are available:

   ```powershell
   az version
   python --version
   pip --version
   git --version
   $PSVersionTable.PSVersion
   ```

7. Open the Microsoft source instructions for this lab: `instructions/cosmosdb/02-build-semantic-search.md`.
8. In that Microsoft markdown, complete **Task 1: Download project starter files and configure the deployment script** exactly as written.
9. Keep the downloaded starter project and any edited deployment script files in the working folder you will continue to use for the rest of the lab.

> [!Note]
> CloudLabs supplies the workstation environment only. Do not look for precreated semantic search project files on the VM image. Download the starter files from the Microsoft-provided location inside the source markdown.

> [!Tip]
> If Azure CLI prompts you to authenticate in the terminal, sign in with the same lab credentials used for the Azure portal.

<validation step="LabVM readiness and task 1 prerequisites"/>

## Task 2: Deploy an Azure Cosmos DB for NoSQL account with vector search capability

In this task, you will continue directly with the Microsoft markdown and complete the Azure Cosmos DB deployment flow for vector search.

1. Return to `instructions/cosmosdb/02-build-semantic-search.md`.
2. In the same document, complete **Task 2: Deploy an Azure Cosmos DB for NoSQL account with vector search capability** exactly as written.
3. When the Microsoft instructions require Azure portal navigation, use the Azure Cosmos DB account resource page and the **Settings > Features** area as described in Microsoft Learn for enabling vector search for the NoSQL API.
4. When the Microsoft instructions require Azure CLI, run the commands from the LabVM terminal in your working project folder.
5. Wait for the deployment and vector search capability update to finish before moving to the next exercise.
6. Verify that your Azure Cosmos DB for NoSQL account is visible in the Azure portal and that the deployment completed successfully.

> [!Important]
> Azure Cosmos DB vector search capability enablement can take several minutes to become active after the account update request is submitted. If the Microsoft instructions tell you to wait, allow the feature registration time to complete before proceeding.

> [!Note]
> Do not rename resources only to match this guide. Use the values and naming choices required by the Microsoft markdown and your edited deployment script.

<validation step="Cosmos DB deployment and vector setup progress"/>

## Summary

In this exercise, you used the CloudLabs LabVM to start the Microsoft semantic search lab, verified the required tools, completed the starter-file download and deployment-script configuration, and deployed an Azure Cosmos DB for NoSQL account with vector search capability. In the next exercise, you will continue with the remaining Microsoft tasks in the same source markdown.
