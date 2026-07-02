# Exercise 02: Build vector search functions and create the vector-enabled container

### Estimated Duration: 1 Hour

## Scenario

In this exercise, you continue from the Azure Cosmos DB for NoSQL account that you deployed in the previous exercise and move into the Microsoft-authored implementation flow for semantic search. You will stay inside the LabVM, use the starter project that you downloaded earlier, and follow the source markdown exactly for the coding and container-configuration work in Tasks 3 and 4.

## Overview

This exercise is a CloudLabs wrapper for the next two Microsoft tasks in the lab. Use it to stay oriented in the LabVM, confirm your sign-in context, and know when to run the CloudLabs validation. For all task procedures, file edits, commands, and values, continue to use the Microsoft markdown as the source of truth.

## Objectives

- Task 3: Build Python functions for vector similarity search
- Task 4: Create a container with vector embedding and indexing policies

## Task 1: Build Python functions for vector similarity search

In this task, you will continue with the Microsoft lab's Task 3 and build the Python functions used for vector similarity search.

1. If needed, reconnect to the LabVM and sign in to the Azure portal at <https://portal.azure.com> by using `<inject key="AzureAdUserEmail"></inject>` and `<inject key="AzureAdUserPassword"></inject>`.
2. Confirm that you are working in the correct lab context for subscription `<inject key="SubscriptionID"></inject>` and tenant `<inject key="TenantID"></inject>`.
3. Open the project folder that you prepared in the previous exercise in Visual Studio Code on the LabVM.
4. Open the Microsoft source instructions at `instructions/cosmosdb/02-build-semantic-search.md` and continue with **Task 3: Build Python functions for vector similarity search**.
5. Follow the Microsoft task exactly as written to update the Python code, install or use any required Python dependencies, and prepare the vector similarity search logic.
6. Run the commands from the Microsoft markdown from the integrated terminal in Visual Studio Code or from a PowerShell window on the LabVM.

> [!Note]
> CloudLabs provides the LabVM, Visual Studio Code, Azure CLI, Python, pip, Git, and PowerShell. The code changes, package installation steps, and command sequence for this task must come directly from the Microsoft markdown and should not be replaced by this wrapper.

> [!Tip]
> If you need to confirm that Azure CLI authentication is still active, run `az account show` in the terminal before continuing.

## Task 2: Create a container with vector embedding and indexing policies

In this task, you will continue with the Microsoft lab's Task 4 and create the Azure Cosmos DB container that uses vector embedding and vector indexing policies.

1. Stay in the same project folder and continue in the Microsoft source instructions with **Task 4: Create a container with vector embedding and indexing policies**.
2. Follow the Microsoft steps exactly to define the vector embedding policy and the indexing policy for the new container.
3. Ensure you create a **new** container for vector search, as required by the Microsoft guidance for Azure Cosmos DB for NoSQL vector search configuration.
4. Complete the Microsoft task using the same resource names, file names, and commands specified in the source markdown.
5. After the container is created successfully, run the CloudLabs progress validation for this stage.

<validation step="Cosmos DB deployment and vector setup progress"/>

> [!Important]
> Microsoft Learn states that vector search in Azure Cosmos DB for NoSQL is supported only on new containers, and that the vector embedding policy and vector indexing policy must be set when the container is created.

> [!Note]
> Microsoft Learn also notes that the vector index path must match the path defined in the vector embedding policy. Keep the exact paths and property definitions from the Microsoft markdown.

## Summary

In this exercise, you completed the Microsoft flow for building the Python vector similarity functions and creating the vector-enabled Azure Cosmos DB container. You are now ready to continue to the next exercise and use the completed project flow for final testing in the Flask web application.
