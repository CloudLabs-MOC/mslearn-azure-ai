# Lab 03:  Deploy a containerized backend API to Azure Container Apps

### Estimated Duration : 30 Minutes

## Overview 

In this exercise, you deploy a containerized backend API to Azure Container Apps. You use a managed identity to securely pull images from Azure Container Registry and configure secrets as environment variables.

## Lab Overview

- **Task 1:** Download the project starter files and deploy Azure services
- **Task 2:** Deploy the container app and configure secrets
- **Task 3:** Verify the Deployment


## Download project starter files and deploy Azure services

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

    ![](../Images/grp-name-img.png)

1. The project contains deployment scripts for both Bash (*azdeploy.sh*) and PowerShell (*azdeploy.ps1*). Open the appropriate file for your environment and change the two values: **Resource group name** as **<inject key="ResourceGroupName" enableCopy="false"/>** and **Azure Region** as **<inject key="Region" enableCopy="false"/>** at the top of the script to meet your needs.

    ```
    "<your-resource-group-name>" # Resource Group name
    "<your-azure-region>" # Azure region for the resources
    ```

    ![](../Images/powershellrgnaming.png)

    ![](../Images/Lab02-Task2-48.png)

    > **Note:** Do not change anything else in the script.

1. Press **Ctrl+S** to save the changes.

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


1. Run the command **az login (1)** to sign in to your Azure account. Then minimize the VS Code window **(2)** to view the login window that opens in the background.

    ```
    az login
    ```
    ![](../Images/azloginimage.png)

1. A pop-up window will appear on the desktop. Select **Work and school account (1)** and then click **Continue (2)**.

    ![](../Images/sign-in-1.png)

1. In the login window, sign in by using the provided **Azure credentials (1)** and then click **Next (2)**.

    - **Email/Username:** <inject key="AzureAdUserEmail"></inject>

    ![](../Images/sign-in-2.png)

1. Enter the temporary access password and click **Sign in**.

    - **Password:** <inject key="AzureAdUserPassword"></inject>

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

1. Make sure you are in the root directory of the project and run the appropriate command in the terminal to launch the deployment script. The deployment script will deploy ACR and create a file with environment variables needed for exercise.

    **Bash**
    ```bash
    bash azdeploy.sh
    ```

    **PowerShell**
    ```powershell
    ./azdeploy.ps1
    ```
    ![](../Images/Lab02-Task1-1.png)

1. When the script is running, enter **1** to launch the **Create Azure Container Registry and build container image** option. This option creates the ACR service and uses ACR Tasks to build and push the image to the registry.

    ![](../Images/Lab03-Task1-2.png)

1. To verify that the deployment was successful, navigate to the Azure portal. In the search bar, type **Container registries (1)** and select **Container registries (2)** from the search results.

    ![](../Images/Lab02-Task2-4.png)

1. You should see one container registry created.

    ![](../Images/Lab03-Task1-6.png)        

1. When the previous operation is finished, enter **2** to launch the **Create Container Apps environment** options. Creating the environment is necessary before deploying the container.

    ![](../Images/Lab03-Task1-3.png)

    >**Note:** A file containing environment variables is created after the Container Apps environment is created. You use these variables throughout the exercise.

1. To verify that the deployment was successful, navigate to the Azure portal. In the search bar, type **Container Apps Environments (1)** and select **Container Apps Environments (2)** from the search results.

    ![](../Images/Lab03-Task1-7.png)

1. You should see the **Container App Environment** you created.

    ![](../Images/Lab03-Task1-8.png)

1. When the previous operation is finished, enter **4** to exit the deployment script.

    ![](../Images/Lab03-Task1-4.png)

1. Run the appropriate command to load the environment variables into your terminal session from the file created in a previous step.

    **Bash**
    ```bash
    source .env
    ```

    **PowerShell**
    ```powershell
    . .\.env.ps1
    ```
    ![](../Images/Lab03-Task1-5.png)

    >**Note:** Keep the terminal open. If you close it and create a new terminal, you might need to run the command to create the environment variable again.

## Task 2: Deploy the container app and configure secrets

In this section you deploy the API as a container app with external ingress. Because the image is in a private registry, you must configure registry authentication at create time so the first revision can pull the image. You then configure a secret and reference it from an environment variable. This pattern mirrors how AI apps store provider API keys

1. Create the container app with a system-assigned managed identity and configure registry authentication at create time. The **--registry-identity** flag tells Container Apps to use the app's managed identity to pull images from the specified registry. The CLI automatically assigns the **AcrPull** role when you use this flag with an Azure Container Registry.

    **Bash**
    ```azurecli
    az containerapp create \
        --name $CONTAINER_APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --environment $ACA_ENVIRONMENT \
        --image "$ACR_SERVER/$CONTAINER_IMAGE" \
        --ingress external \
        --target-port $TARGET_PORT \
        --env-vars MODEL_NAME=$MODEL_NAME \
        --registry-server "$ACR_SERVER" \
        --registry-identity system
    ```

    **PowerShell**
    ```powershell
    az containerapp create `
        --name $env:CONTAINER_APP_NAME `
        --resource-group $env:RESOURCE_GROUP `
        --environment $env:ACA_ENVIRONMENT `
        --image "$env:ACR_SERVER/$env:CONTAINER_IMAGE" `
        --ingress external `
        --target-port $env:TARGET_PORT `
        --env-vars MODEL_NAME=$env:MODEL_NAME `
        --registry-server "$env:ACR_SERVER" `
        --registry-identity system
    ```
    ![](../Images/Lab03-Task1-9.png)

1. Create a secret and reference it from an environment variable.

    **Bash**
    ```azurecli
    az containerapp secret set -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP \
        --secrets embeddings-api-key=$EMBEDDINGS_API_KEY
    ```

    **PowerShell**
    ```powershell
    az containerapp secret set -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
        --secrets embeddings-api-key=$env:EMBEDDINGS_API_KEY
    ```
    ![](../Images/Lab03-Task1-10.png)

1. Reference the secret from an environment variable. This command creates a new revision, which restarts the app so the secret change takes effect.

    **Bash**
    ```azurecli
    az containerapp update -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP \
        --set-env-vars EMBEDDINGS_API_KEY=secretref:embeddings-api-key
    ```

    **PowerShell**
    ```powershell
    az containerapp update -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
        --set-env-vars EMBEDDINGS_API_KEY=secretref:embeddings-api-key
    ```
    ![](../Images/Lab03-Task1-12.png)

1. Run the following command to list the revisions to confirm a new revision was created.

    ```azurecli
    az containerapp revision list -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP -o table
    ```
    **PowerShell**
    ```powershell
    az containerapp revision list `
    --name $env:CONTAINER_APP_NAME `
    --resource-group $env:RESOURCE_GROUP `
    --output table
    ```
    ![](../Images/Lab03-Task1-13.png)

    The revision name ends with a suffix like `--0000002`, indicating this is the second revision. Container Apps creates a new revision whenever you change environment variables or secrets, which restarts the app with the updated configuration. Old inactive revisions may be pruned over time.

## Task 3: Verify the deployment

You should validate that the app starts and that ingress works. You also use logs to confirm the app is behaving as expected.

1. Run the following command to retrieve the app FQDN and store the result to a variable.

    **Bash**
    ```bash
    FQDN=$(az containerapp show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP \
        --query properties.configuration.ingress.fqdn -o tsv)

    echo "$FQDN"
    ```

    **PowerShell**
    ```powershell
    $FQDN = az containerapp show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
        --query properties.configuration.ingress.fqdn -o tsv

    Write-Output $FQDN
    ```
    ![](../Images/Lab03-Task1-14.png)

1. Run the following command to call the health endpoint. The command should return **{"status": "healthy"}**.

    **Bash**
    ```bash
    curl -s "https://$FQDN/health"
    ```

    **PowerShell**
    ```powershell
    Invoke-RestMethod -Uri "https://$FQDN/health"
    ```
    ![](../Images/Lab03-Task1-15.png)

1. Run the following command to verify the secret is configured by calling the root endpoint. The endpoint returns JSON containing app information including the configured model name and whether the API key secret is configured.

    **Bash**
    ```bash
    curl -s "https://$FQDN/"
    ```

    **PowerShell**
    ```powershell
    Invoke-RestMethod -Uri "https://$FQDN/"
    ```
    ![](../Images/Lab03-Task3-1.png)

1. Run the following command to test the document processing endpoint. The command sends the *document.txt* file to the endpoint. The operation returns JSON with mock data analysis information.

    **Bash**
    ```bash
    curl -s -X POST "https://$FQDN/process" \
        -H "Content-Type: text/plain" \
        -d @document.txt
    ```

    **PowerShell**
    ```powershell
    Invoke-RestMethod -Uri "https://$FQDN/process" `
        -Method Post `
        -ContentType "text/plain" `
        -Body (Get-Content -Raw document.txt)
    ```
    ![](../Images/Lab03-Task3-2.png)

1. Run the following command to review logs for startup and runtime signals. This command shows recent console output only. For historical logs and advanced troubleshooting, logs persist in the Log Analytics workspace associated with your Container Apps environment.

    ```azurecli
    az containerapp logs show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP
    ```

    Look for **gunicorn** startup messages showing workers spawned and listening on port 8000. You should also see HTTP request logs from your curl commands (GET /health, POST /process, etc.).

## Troubleshooting

If you encounter issues while completing this exercise, try the following troubleshooting steps:

**Check deployment status with the script**

- Run the deployment script and select option **3** to check the status of your ACR and Container Apps environment. This verifies the base infrastructure is deployed and the container image exists.

**Verify Azure authentication and environment variables**

- Run **az account show** to confirm you're logged in to the correct Azure subscription.
- Verify your environment variables are set by running **echo $ACR_NAME** (Bash) or **$env:ACR_NAME** (PowerShell).
- If variables are empty, re-run **source .env** (Bash) or **. .\.env.ps1** (PowerShell).

**Verify ACR deployment**

- Navigate to the [Azure portal](https://portal.azure.com) and locate your resource group.
- Confirm that the Azure Container Registry exists and shows a **Provisioning State** of **Succeeded**.
- Run **az acr list --output table** to verify your registry is accessible.

**Troubleshoot build failures**

- The deployment script suppresses verbose **az acr build** output. To troubleshoot failures, check the status and logs of the most recent ACR Task run.
- Verify you're running the deployment script from the project root directory (where the *api* folder is located).
- List recent ACR Task runs:
    - **Bash:** **az acr task list-runs --registry $ACR_NAME --output table**
    - **PowerShell:** **az acr task list-runs --registry $env:ACR_NAME --output table**
- View logs for a specific run (replace **\<run-id>** with a value from the previous command):
    - **Bash:** **az acr task logs --registry $ACR_NAME --run-id \<run-id>**
    - **PowerShell:** **az acr task logs --registry $env:ACR_NAME --run-id \<run-id>**

**Troubleshoot container pull failures (ImagePullBackOff / unauthorized / 403)**

- Confirm the container app has a system-assigned managed identity enabled:
    - **Bash:** **az containerapp identity show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP**
    - **PowerShell:** **az containerapp identity show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP**
- Confirm the container app has the **AcrPull** role assignment scoped to the registry. Role assignments can take a minute or two to propagate after creation.

**Troubleshoot container startup and application errors**

- Stream container logs to diagnose startup issues:
    - **Bash:** **az containerapp logs show -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP --follow**
    - **PowerShell:** **az containerapp logs show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP --follow**
- If the app returns a 502/503 shortly after deployment, wait a minute and try again. The first start can take longer while Container Apps pulls and starts the container.
- Check revision status for provisioning errors:
    - **Bash:** **az containerapp revision list -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP -o table**
    - **PowerShell:** **az containerapp revision list -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP -o table**

**Troubleshoot secret configuration**

- Verify the secret was created:
    - **Bash:** **az containerapp secret list -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP -o table**
    - **PowerShell:** **az containerapp secret list -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP -o table**
- Confirm the environment variable references the secret correctly by calling the root endpoint (**/**), which shows whether the API key is configured.

### Summary



## You have successfully completed the Hands-on Lab!