# Lab 04: Diagnose and fix a failing deployment

### Estimated Duration : 30 Minutes

## Overview 

In this lab, you will diagnose and fix a failing container app deployment in Azure Container Apps. You will investigate deployment issues by reviewing revision status, checking application logs, and using the Azure CLI to isolate problems such as missing environment variables and ingress configuration errors. By the end of the lab, you will have practiced the troubleshooting workflow used to keep containerized AI applications healthy and running correctly.

## Lab Overview

- **Task 1:** Deploy Azure Container Registry and Container App Environment
- **Task 2:** Diagnose a missing environment variable error
- **Task 3:** Diagnose an ingress configuration issue
- **Task 4:** Query Log Analytics for historical troubleshooting data

> **Note:** This lab includes deployment scripts for both **PowerShell** and **Bash**. You may choose either scripting language based on your preference or environment. Once you make your choice, use the corresponding commands and script throughout the entire lab, as all subsequent steps provide instructions for both PowerShell and Bash.

## Task 1: Deploy Azure Container Registry and Container App Environment

In this task, you will deploy an Azure Container Registry and a Container Apps environment, which provide the foundation for hosting and troubleshooting the container app.

1. Launch **Visual Studio Code** (VS Code) from desktop.

   ![](../Images/vsimage.png)

1. Select **File Explorer (1)**, then **Open Folder (2)** from the menu.

   ![](../Images/folderimagea.png)

1. Navigate to **C:\Allfiles (1)** and click **Select Folder (2)**.

   ![](../Images/folderimage-b.png)

1. If you see the prompt, **Do you trust the authors of the files in this folder?**, click **Yes, I trust the authors**.

   ![](../Images/vs-trusted.png)

1. Once the folder opens in VS Code, select **Explorer (1)** and then **azdeploy.ps1 (2)**.

   ![](../Images/powershellscript.png)

1. Navigate to the Azure portal and search for **Resource groups (1)**. Then select **Resource groups (2)**.

   ![](../Images/resgrpimage.png)

1. Note the name of the **Resource group**.

   ![](../Images/Lab04-Task1-4.png)

1. The project contains deployment scripts for both Bash (_azdeploy.sh_) and PowerShell (_azdeploy.ps1_). Open the appropriate file for your environment and change the two values: **Resource group name** as **<inject key="ResourceGroupName" enableCopy="false"/>** and **Azure Region** as **<inject key="Region" enableCopy="false"/>** at the top of the script to meet your needs.

   ```
   "<your-resource-group-name>" # Resource Group name
   "<your-azure-region>" # Azure region for the resources
   ```

   ![](../Images/powershellrgnaming.png)

   ![](../Images/Lab02-Task2-48.png)

   > **Note:** Do not change anything else in the script.

1. Press **Ctrl+S** to save the changes in both the scripts.

1. In the menu bar, select **ellipsis (...) (1)**, then **Terminal (2)**, and then **New Terminal (3)** to open a terminal window in VS Code.

   ![](../Images/terminalimage.png)

   > **Note:** If you are using Bash, after the terminal opens, expand the downward arrow icon **(1)** to open a new terminal and select **Git Bash (2)** from the drop-down list. If you are using PowerShell, skip this step.
   >
   > ![](../Images/Lab02-Task2-26.png)

1. Run the following command in the terminal to allow PowerShell scripts to run. This step is required only if you are using PowerShell. If you are using Bash, skip this step.

   ```
   Set-ExecutionPolicy -ExecutionPolicy bypass -Force
   ```

   ![](../Images/runcmd.png)

1. Run the command **az login (1)** to sign in to your Azure account. Then **minimize the VS Code window (2)** to view the login window that opens in the background.

   ```
   az login
   ```

   ![](../Images/azloginimage.png)

1. A pop-up window will appear on the desktop. Select **Work and school account (1)** and then click **Continue (2)**.

   ![](../Images/sign-in-1.png)

1. In the login window, sign in by using the provided **Azure credentials (1)** and then click **Next (2)**.
   - **Email/Username:** <inject key="AzureAdUserEmail" enableCopy="false"></inject>

     ![](../Images/sign-in-2.png)

1. Enter the temporary access password and click **Sign in**.
   - **Password:** <inject key="AzureAdUserPassword" enableCopy="false"></inject>

     ![](../Images/tempass.png)

1. When prompted with **Sign in to all apps and websites on this device?**, select **No, this app only**.

   ![](../Images/sign-in-3.png)

1. Return to the terminal.

1. Choose the subscription by entering **1**.

   ![](../Images/sign-in-4.png)

   > **NOTE:** To confirm you're logged in to the correct Azure subscription, run **az account show**.

1. Run the following command to ensure you have the **containerapp** extension for Azure CLI.

   ```azurecli
   az extension add --name containerapp
   ```

   ![](../Images/Lab03-Task1-1.png)

1. Make sure you are in the root directory of the project and run the appropriate command in the terminal to launch the deployment script. The deployment script will deploy ACR and create a file with environment variables needed.

   **Bash**

   ```bash
   bash azdeploy.sh
   ```

   ![](../Images/Lab03-Task2-1-bash.png)

   **PowerShell**

   ```powershell
   ./azdeploy.ps1
   ```

   ![](../Images/Lab02-Task1-1.png)

1. When the script is running, enter **1** to launch the **Create Azure Container Registry and build container image** option. This option creates the ACR service and uses ACR Tasks to build and push the image to the registry.

   ![](../Images/Lab04-Task1-1.png)

1. To verify that the deployment was successful, navigate to the Azure portal. In the search bar, type **Container registries (1)** and select **Container registries (2)** from the search results.

   ![](../Images/Lab02-Task2-4.png)

1. You should see one **Container registry** created.

   ![](../Images/Lab03-Task1-6.png)

1. When the previous operation is finished, enter **2** to launch the **Create Container Apps environment** options. Creating the environment is necessary before deploying the container.

    ![](../Images/Lab04-Task1-6.png)

1. To verify that the deployment was successful, navigate to the Azure portal. In the search bar, type **Container Apps Environments (1)** and select **Container Apps Environments (2)** from the search results.

   ![](../Images/Lab03-Task1-7.png)

1. You should see the **Container App Environment** you created.

   ![](../Images/Lab03-Task1-8.png)

1. When the previous operation is finished, enter **3** to launch the **Deploy the container app and configure secrets** option.

    ![](../Images/Lab04-Task1-2.png)

    >**Note:** A file containing environment variables is created after the container app is created. You use these variables throughout the exercise.

1. When the previous operation is finished, enter **5** to exit the deployment script.

   ![](../Images/Lab04-Task1-3.png)

1. Run the appropriate command to load the environment variables into your terminal session from the file created in a previous step.

   **Bash**

   ```bash
   source .env
   ```

   ![](../Images/Lab03-Task2-3-bash.png)

   **PowerShell**

   ```powershell
   . .\.env.ps1
   ```

   ![](../Images/Lab03-Task1-5.png)

   > **Note:** Keep the terminal open. If you close it and create a new terminal, you might need to run the command to create the environment variable again.

1. Run the following command to retrieve the app FQDN and store the result to a variable.

    **Bash**
    ```bash
    FQDN=$(az containerapp show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP \
        --query properties.configuration.ingress.fqdn -o tsv)

    echo "$FQDN"
    ```
     ![](../Images/Lab04-Task1-10b.png)

    **PowerShell**
    ```powershell
    $FQDN = az containerapp show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
        --query properties.configuration.ingress.fqdn -o tsv

    Write-Output $FQDN
    ```
    ![](../Images/Lab04-Task1-7.png)

1. Run the following command to call the default endpoint to verify the app is running. The command should return some JSON. Look for the **model.name** field, it should be set to **gpt-4o-mini**.

    **Bash**
    ```bash
    curl -s "https://$FQDN/"
    ```
    ![](../Images/Lab04-Task1-11b.png)

    **PowerShell**
    ```powershell
    Invoke-RestMethod -Uri "https://$FQDN/"
    ```
    ![](../Images/Lab04-Task1-9.png)

> **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
>
> - If you receive a success message, you can proceed to the next task.
> - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
> - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help you out.

<validation step="" />

## Task 2: Diagnose a missing environment variable error

In this task, you will introduce a configuration problem by removing a required environment variable and observing how it affects the container app. You will then diagnose the issue and restore the variable to confirm the fix.

1. Run the following command to update the container app to remove the `MODEL_NAME` environment variable.

    **Bash**
    ```bash
    az containerapp update -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP \
        --remove-env-vars MODEL_NAME
    ```

    ![](../Images/Lab04-Task2-12b.png)

    **PowerShell**
    ```powershell
    az containerapp update -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
        --remove-env-vars MODEL_NAME
    ```
    ![](../Images/Lab04-Task1-8.png)

1. Run the following command to list revisions to confirm a new revision was created. Look for a new revision with a higher suffix number (for example, **ai-api--0000002**) and **TrafficWeight** of **100**, indicating it's now receiving all traffic.

    **Bash**
    ```bash
    az containerapp revision list -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP -o table
    ```

    ![](../Images/Lab04-Task2-13b.png)

    **PowerShell**
    ```powershell
    az containerapp revision list -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP -o table
    ```
    ![](../Images/Lab04-Task2-1.png)

1. Run the following command to check the root endpoint to observe the symptom from the API consumer's perspective. The **model.name** field now shows the default value of **not-configured** instead of the configured value.

    **Bash**
    ```bash
    curl -s "https://$FQDN/" | jq .model
    ```

    ![](../Images/Lab04-Task2-14b.png)

    **PowerShell**
    ```powershell
    (Invoke-RestMethod -Uri "https://$FQDN/").model
    ```

    ![](../Images/Lab04-Task2-4.png)

1. Run the following command to diagnose the root cause by viewing the container app's configuration. Run the following command to confirm the **MODEL_NAME** environment variable is missing.

    **Bash**
    ```bash
    az containerapp show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP \
        --query "properties.template.containers[0].env" -o table
    ```

    ![](../Images/Lab04-Task2-15b.png)

    **PowerShell**
    ```powershell
    az containerapp show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
        --query "properties.template.containers[0].env" -o table
    ```

    ![](../Images/Lab04-Task2-5.png)

1. Run the following command to fix the issue by adding the `MODEL_NAME` environment variable back.

    **Bash**
    ```bash
    az containerapp update -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP \
        --set-env-vars MODEL_NAME=$MODEL_NAME
    ```
    ![](../Images/Lab04-Task2-16b.png)

    **PowerShell**
    ```powershell
    az containerapp update -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
        --set-env-vars MODEL_NAME=$env:MODEL_NAME
    ```
    ![](../Images/Lab04-Task2-6.png)

1. Run the following command to verify the fix by checking the root endpoint again. This confirms the application now behaves correctly from an API consumer's perspective. The response should now show the configured model name.

    **Bash**
    ```bash
    curl -s "https://$FQDN/" | jq .model
    ```
    ![](../Images/Lab04-Task2-17b.png)

    **PowerShell**
    ```powershell
    (Invoke-RestMethod -Uri "https://$FQDN/").model
    ```
    ![](../Images/Lab04-Task2-7.png)

You diagnosed and fixed a missing environment variable. Next, you diagnose a secret an ingress issue.

## Task 3: Diagnose an ingress configuration issue

In this task, you will introduce an ingress-related problem by changing the target port to a value that does not match the application. You will then diagnose the resulting connectivity issue and restore the correct configuration.

1. Run the following command to update the container app to use the wrong target port.

    **Bash**
    ```bash
    az containerapp ingress update -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP \
        --target-port 3000
    ```

    ![](../Images/Lab04-Task3-18b.png)

    **PowerShell**
    ```powershell
    az containerapp ingress update -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
        --target-port 3000
    ```
    ![](../Images/Lab04-Task3-1.png)

1. Run the following command to try to access the health endpoint to observe the symptom from an API consumer's perspective.

    **Bash**
    ```bash
    curl -s "https://$FQDN/health"
    ```

    ![](../Images/Lab04-Task3-19b.png)

    **PowerShell**
    ```powershell
    Invoke-RestMethod -Uri "https://$FQDN/health"
    ```
    ![](../Images/Lab04-Task3-2.png)

    > **Note:** The request fails or times out because Container Apps is routing traffic to port 3000, but the application listens on port 8000.

    > **Note:** Log Analytics data may take **2-5 minutes** to appear.

1. Run the following command to diagnose the root cause by checking the current ingress configuration. Notice the **targetPort** is set to 3000.

    **Bash**
    ```bash
    az containerapp show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP \
        --query "properties.configuration.ingress" -o yaml
    ```

    ![](../Images/Lab04-Task3-20b.png)

    **PowerShell**
    ```powershell
    az containerapp show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
        --query "properties.configuration.ingress" -o yaml
    ```

    ![](../Images/Lab04-Task3-3.png)

1. Run the following command to check the container logs to see if the application is running. You should see gunicorn startup messages indicating the app is listening on port 8000, confirming the mismatch.

    **Bash**
    ```bash
    az containerapp logs show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP
    ```
    ![](../Images/Lab04-Task3-21b.png)

    **PowerShell**
    ```powershell
    az containerapp logs show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP
    ```

    ![](../Images/Lab04-Task3-4.png)

1. Run the following command to fix the ingress configuration by setting the correct target port.

    **Bash**
    ```bash
    az containerapp ingress update -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP \
        --target-port 8000
    ```

    ![](../Images/Lab04-Task3-22b.png)

    **PowerShell**
    ```powershell
    az containerapp ingress update -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
        --target-port 8000
    ```

    ![](../Images/Lab04-Task3-5.png)

1. Run the following command to verify the fix by calling the health endpoint. This confirms the application is accessible from an API consumer's perspective. You should see **{"status":"healthy"}**.

    **Bash**
    ```bash
    curl -s "https://$FQDN/health"
    ```

    ![](../Images/Lab04-Task3-23b.png)

    **PowerShell**
    ```powershell
    Invoke-RestMethod -Uri "https://$FQDN/health"
    ```

    ![](../Images/Lab04-Task3-6.png)

You diagnosed and fixed an ingress configuration issue. Next, you learn how to query historical logs.

## Task 4: Query Log Analytics for historical troubleshooting

In this task, you will use Log Analytics to review historical container logs and investigate issues that may no longer appear in the recent console output. This helps you troubleshoot problems that occurred earlier or after a revision change.

1. Run the following command to get the Log Analytics workspace ID from the Container Apps environment.

    **Bash**
    ```bash
    WORKSPACE_ID=$(az containerapp env show -n $ACA_ENVIRONMENT -g $RESOURCE_GROUP \
        --query properties.appLogsConfiguration.logAnalyticsConfiguration.customerId -o tsv)

    echo "Workspace ID: $WORKSPACE_ID"
    ```

    ![](../Images/Lab04-Task4-24b.png)

    **PowerShell**
    ```powershell
    $WORKSPACE_ID = az containerapp env show -n $env:ACA_ENVIRONMENT -g $env:RESOURCE_GROUP `
        --query properties.appLogsConfiguration.logAnalyticsConfiguration.customerId -o tsv

    Write-Output "Workspace ID: $WORKSPACE_ID"
    ```
    ![](../Images/Lab04-Task4-1.png)

1. Run the following command to query the console logs for your container app. Press **Y** for installing log-analytics extension. This returns the last 20 log entries showing timestamp and message.

    **Bash**
    ```bash
    az monitor log-analytics query -w $WORKSPACE_ID \
        --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == '$CONTAINER_APP_NAME' | project TimeGenerated, Log_s | order by TimeGenerated desc | take 20" \
        -o table
    ```

    ![](../Images/Lab04-Task4-25b.png)

    **PowerShell**
    ```powershell
    az monitor log-analytics query -w $WORKSPACE_ID `
        --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == '$env:CONTAINER_APP_NAME' | project TimeGenerated, Log_s | order by TimeGenerated desc | take 20" `
        -o table
    ```

    ![](../Images/Lab04-Task4-2.png)
    
    > **NOTE:** Log Analytics data may take a few minutes to appear after events occur. If you don't see recent logs, wait a few minutes and try again.

1. Run the following command to query for error-level logs specifically.

    **Bash**
    ```bash
    az monitor log-analytics query -w $WORKSPACE_ID \
        --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == '$CONTAINER_APP_NAME' and Log_s contains 'error' | order by TimeGenerated desc | take 20" \
        -o table
    ```
    ![](../Images/Lab04-Task4-26b.png)


    **PowerShell**
    ```powershell
    az monitor log-analytics query -w $WORKSPACE_ID `
        --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == '$env:CONTAINER_APP_NAME' and Log_s contains 'error' | order by TimeGenerated desc | take 20" `
        -o table
    ```
    ![](../Images/Lab04-Task4-3.png)

These queries help you investigate issues that occurred in the past, even after container restarts or revision changes.

### Summary

In this lab, you diagnosed and resolved common deployment issues in Azure Container Apps by reviewing revision state, inspecting logs, and using the Azure CLI to identify and fix problems. You learned how missing environment variables and incorrect ingress settings can affect application behavior, and how to validate your fixes by testing the app and reviewing troubleshooting data.

## You have successfully completed the Hands-on Lab!
