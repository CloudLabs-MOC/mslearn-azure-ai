# Exercise 03: Test vector search using a Flask web application

### Estimated Duration: 45 Minutes

## Scenario

You have completed the earlier Microsoft-authored tasks to prepare the semantic search solution, deploy the Azure Cosmos DB for NoSQL environment with vector search capability, and create the required database and container artifacts. In this exercise, you continue with the same Microsoft workflow and complete the final task from `instructions/cosmosdb/02-build-semantic-search.md` by running and testing the Flask web application from the CloudLabs LabVM.

## Overview

In this exercise, you will use the CloudLabs LabVM to sign in to Azure if needed, return to the semantic search project that you prepared in the earlier tasks, and complete the Microsoft instructions for Task 5: testing vector search by using the Flask web application. The Microsoft markdown remains the source of truth for all procedural steps and command sequences.

## Objectives

- Task 1: Open the prepared project and verify your sign-in context
- Task 2: Complete Microsoft Task 5 to test vector search with the Flask web application
- Task 3: Confirm end-to-end lab completion

## Task 1: Open the prepared project and verify your sign-in context

In this task, you will reconnect to the LabVM workspace and confirm that you are ready to continue the final Microsoft task.

1. Connect to the LabVM for **Deployment ID: <inject key="DeploymentID" enableCopy="false"></inject>**.
2. If you are not already signed in, open a browser and sign in to <https://portal.azure.com> with:
   - Username: `<inject key="AzureAdUserEmail"></inject>`
   - Password: `<inject key="AzureAdUserPassword"></inject>`
3. Open **Visual Studio Code** from the LabVM desktop or Start menu.
4. Open the same project folder that you used in the previous Microsoft tasks.
5. Open a terminal in Visual Studio Code and verify that the Azure CLI session is available by running the same sign-in or subscription-check command sequence referenced by the Microsoft markdown.
6. Confirm that your earlier Azure Cosmos DB for NoSQL resources, Python files, and container configuration are still present before you begin the Flask application test.

> [!Note]
> CloudLabs provides the ready-to-use LabVM and developer tools only. Continue to follow the Microsoft markdown for the exact commands, file edits, dependency installation steps, and application test flow.

## Task 2: Complete Microsoft Task 5 to test vector search with the Flask web application

In this task, you will follow the Microsoft-authored Task 5 exactly as written and run the Flask-based semantic search application.

1. In Visual Studio Code, return to `instructions/cosmosdb/02-build-semantic-search.md` or the bookmarked Microsoft instructions provided with the lab.
2. Locate **Task 5: Test vector search using a Flask web application**.
3. Follow the Microsoft instructions in the same order they are written to:
   - open the Flask application files in your project,
   - install any remaining Python dependencies if the instructions require them,
   - configure the application settings that depend on the Azure Cosmos DB for NoSQL resources you created earlier,
   - start the Flask application from the LabVM terminal,
   - and submit one or more test searches through the application interface.
4. Keep the Microsoft-authored command syntax, file names, variable names, and test queries unchanged while you work through the task.
5. As you test, confirm that the application is using the container created for vector search and that your earlier setup from Tasks 2 through 4 is being exercised end to end.

> [!Important]
> Azure Cosmos DB for NoSQL vector search must be configured on a **new container**, and the vector embedding policy plus indexing policy are applied when that container is created. If your Flask test fails because of container configuration, return to the earlier Microsoft tasks and verify that the required container was created exactly as instructed.

> [!Tip]
> Microsoft Learn documents that vector similarity queries in Azure Cosmos DB for NoSQL use the `VectorDistance` system function. If your test results look unexpected, compare your project code and container setup against the Microsoft task flow before rerunning the application.

## Task 3: Confirm end-to-end lab completion

In this task, you will make sure the environment reflects completion of the semantic search lab without changing the Microsoft flow.

1. Verify that the Flask web application starts successfully on the LabVM.
2. Verify that at least one semantic search request can be submitted through the application according to the Microsoft task instructions.
3. Confirm that the Azure Cosmos DB for NoSQL account, database, and vector-enabled container you created earlier are still present in the Azure portal.
4. Save any files modified during the Microsoft workflow in Visual Studio Code.
5. When you are satisfied that the end-to-end task flow is complete, run the lab validation below.

<validation step="Final semantic search completion state"/>

## Summary

In this exercise, you completed the final Microsoft semantic search task from the CloudLabs LabVM by returning to the prepared project, running the Flask web application, and verifying the end-to-end vector search workflow. You should now have a completed learner-created Azure Cosmos DB for NoSQL semantic search environment that aligns to the original Microsoft task order and intent.
