# Lab 02: Deploy a container to Azure App Service

### Estimated Duration : 30 Minutes

## Overview 

In this exercise, you deploy a Linux container image from Azure Container Registry (ACR) to Azure App Service. You configure the web app to use a system-assigned managed identity and the **AcrPull** role so App Service can pull images from your private registry without storing registry credentials in app settings.

## Lab Overview

- **Task 1:** Deploy Azure Container Registry and build a container image using ACR Tasks
- **Task 2:** Deploy an App Service plan for Linux containers
- **Task 3:** Create and configure a Web App for Containers to pull from ACR using managed identity
- **Task 4:** Configure runtime settings and enable container logging
- **Task 5:** Verify the deployment and test the document processing endpoint
.

## Task 1: Deploy Azure Container Registry and build a container image using ACR Tasks

1. On VM select **Visual Studio Code** from the desktop.

    ![](../Images/vsimage.png)

1. Select **File(1)**,then **Open Folder... (2)** in the menu, then choose the folder containing the project files.

    ![](../Images/folderimagea.png)

1. Navigate to **C:\Allfiles (1)**, click on  the **Select folder (2)**.    

    ![](../Images/folderimage-b.png)

1. Once the folder open in VS Code, select **file explorer (1)**, then **azdeploy.ps1 (2)**.

    ![](../Images/powershellscript.png)

1. Navigate to azure portal, and search for **Resource groups (1)** and select **Resource groups (2)**.

    ![](../Images/resgrpimage.png)

1. Note the name of the **Resource group**.

    ![](../Images/grp-name-img.png)
    
1. The project contains deployment scripts for both Bash (*azdeploy.sh*) and PowerShell (*azdeploy.ps1*). Open the appropriate file for your environment and change the two values at the top of the script to meet your needs, then save your changes. 

    - Resource Group name : AI-200-RG02-**<inject key="DeploymentID"></inject>**

    - Region : **<inject key="Region"></inject>**

    ```
    "<your-resource-group-name>" # Resource Group name
    "<your-azure-region>" # Azure region for the resources
    ```
    ![](../Images/powershellrgnaming.png)

    > **Note:** Do not change anything else in the script.

1. Do **Ctrl+S** to save the changes.    

1. In the menu bar select **Terminal > New Terminal** to open a terminal window in VS Code.

    ![](../Images/terminalimage.png)

1. Run the following command.

    ```
    Set-ExecutionPolicy -ExecutionPolicy bypass -Force
    ```
    ![](../Images/runcmd.png)

1. Run the following command to login to your Azure account. Answer the prompts to select your Azure account and subscription for the exercise. Minimize the window.

    ```
    az login
    ```
    ![](../Images/azloginimage.png)

1. On the desktop a pop-up will appear, select the **Work and school account (1)**, the click on **Continue (2)**. 

    ![](../Images/sign-in-1.png)

1. Choose you account **(1)**, click on **Next (2)**.

    ![](../Images/sign-in-2.png)

1. Enter the temporary acces pass, click on **Sign in**.

    ![](../Images/tempass.png)

1. On Sign in to all apps and websites on this device?, then select **No,this app only.**.

    ![](../Images/sign-in-3.png)

1. Navigate back to the terminal.

1. Choose the Subscription, by enter **1**.

    ![](../Images/sign-in-4.png)

### Task 2: Create resources in Azure

In this section you run the deployment script to deploy the necessary services to your Azure subscription.

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

1. When the script is running, enter **1** to launch the **1. Create Azure Container Registry and build container image** option. This option creates the ACR service and uses ACR Tasks to build and push the image to the registry.

    ![](../Images/Lab02-Task1-2.png)

1. When the previous operation is finished, enter **2** to launch the **Create App Service Plan** options. This option creates the App Service plan needed for web app.

    ![](../Images/Lab02-Task1-3.png)

    >**Note:** A file containing environment variables is created after the App Service plan is created. You use these variables throughout the exercise.

1. When the previous operation is finished, enter **4** to exit the deployment script.

    ![](../Images/Lab02-Task1-4.png)

1. Run the appropriate command to load the environment variables into your terminal session from the file created in a previous step.

    **Bash**
    ```bash
    source .env
    ```

    **PowerShell**
    ```powershell
    . .\.env.ps1

    ```
    ![](../Images/Lab02-Task1-5.png)

    >**Note:** Keep the terminal open. If you close it and create a new terminal, you might need to run the command to create the environment variable again.

## Task 3: Create the web app

In this section you create the web app with CLI commands. You then configure the web app with a system-assigned managed identity to give the app access to the image in ACR.

1. Run the following command to create a Web App for Containers configured to pull from your container registry.

    **Bash**
    ```bash
    az webapp create \
        --resource-group $RESOURCE_GROUP \
        --plan $APP_PLAN \
        --name $APP_NAME \
        --container-image-name $ACR_NAME.azurecr.io/docprocessor:v1
    ```

    **PowerShell**
    ```powershell
    az webapp create `
        --resource-group $env:RESOURCE_GROUP `
        --plan $env:APP_PLAN `
        --name $env:APP_NAME `
        --container-image-name "$($env:ACR_NAME).azurecr.io/docprocessor:v1"
    ```

    By default, your Azure Container Registry is private. App Service needs a way to authenticate to ACR before it can pull the image.

    You configure that authentication using a system-assigned managed identity (recommended) instead of storing registry credentials in your app settings.

1. Run the following command to enable a system-assigned managed identity on the web app.

    **Bash**
    ```bash
    az webapp identity assign \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME
    ```

    **PowerShell**
    ```powershell
    az webapp identity assign `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME
    ```

### Assign the AcrPull role to the web app

In this section, you grant the web app permission to pull images from your private registry. Managed identities are Microsoft Entra-backed identities that Azure creates and manages for you. When you enable a system-assigned identity on the web app, App Service can request tokens as that identity.

To enable the web app use that identity to pull images, you assign the built-in **AcrPull** role scoped to your registry. This follows least-privilege access: the web app can download images, but it cannot push or administer the registry.

1. Run the following command to retrieve the principal ID of the web app.

    **Bash**
    ```bash
    PRINCIPAL_ID=$(az webapp identity show \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --query principalId \
        --output tsv)
    ```

    **PowerShell**
    ```powershell
    $PRINCIPAL_ID = az webapp identity show `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME `
        --query principalId `
        --output tsv
    ```
1. Run the following command to retrieve the ID of the ACR.

    **Bash**
    ```bash
    ACR_ID=$(az acr show \
        --resource-group $RESOURCE_GROUP \
        --name $ACR_NAME \
        --query id \
        --output tsv)
    ```

    **PowerShell**
    ```powershell
    $ACR_ID = az acr show `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:ACR_NAME `
        --query id `
        --output tsv
    ```

1. Run the following command to assign the AcrPull role to the web app.

    **Bash**
    ```bash
    az role assignment create \
        --assignee $PRINCIPAL_ID \
        --scope $ACR_ID \
        --role AcrPull
    ```

    **PowerShell**
    ```powershell
    az role assignment create `
        --assignee $PRINCIPAL_ID `
        --scope $ACR_ID `
        --role AcrPull
    ```

    >**Note:** Role assignments can take a minute or two to propagate. If the app still can’t pull the image immediately after this step, wait briefly and try again.

1. Run the following command to configure the web app to use managed identity for registry authentication. This setting tells App Service to use the web app’s managed identity (instead of registry admin credentials) when accessing the container registry.

    **Bash**
    ```bash
    az webapp config set \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --acr-use-identity true \
        --acr-identity [system]
    ```

    **PowerShell**
    ```powershell
    az webapp config set `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME `
        --acr-use-identity true `
        --acr-identity [system]
    ```

1. Run the following command to update the container settings to use the registry with managed identity. This step explicitly sets the image and registry URL that the web app should use. If you later update the image tag, this is where you point the web app to the new version.

    **Bash**
    ```bash
    az webapp config container set \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --container-image-name $ACR_NAME.azurecr.io/docprocessor:v1 \
        --container-registry-url https://$ACR_NAME.azurecr.io
    ```

    **PowerShell**
    ```powershell
    az webapp config container set `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME `
        --container-image-name "$($env:ACR_NAME).azurecr.io/docprocessor:v1" `
        --container-registry-url "https://$($env:ACR_NAME).azurecr.io"
    ```

## Configure runtime settings and enable container logging

In this section you configure runtime settings and enable logging to make the container run more reliably, and help troubleshoot issues.

1. Run the following command to configure the container port. The sample image listens on port 80 (the default), so this step demonstrates the setting without changing behavior.

    **Bash**
    ```bash
    az webapp config appsettings set \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --settings WEBSITES_PORT=80
    ```

    **PowerShell**
    ```powershell
    az webapp config appsettings set `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME `
        --settings WEBSITES_PORT=80
    ```

1. Run the following command to enable persistent storage for processed documents. This setting enables the App Service storage mount (for example, the **/home** path in Linux containers).

    **Bash**
    ```bash
    az webapp config appsettings set \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=true
    ```

    **PowerShell**
    ```powershell
    az webapp config appsettings set `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME `
        --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=true
    ```

1. Run the following command to enable always-on. Always-on helps reduce cold start latency by keeping the app warm.

    **Bash**
    ```bash
    az webapp config set \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --always-on true
    ```

    **PowerShell**
    ```powershell
    az webapp config set `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME `
        --always-on true
    ```

1. Run the following command to enable container logging. This captures stdout/stderr from your container so you can view logs from the CLI.

    **Bash**
    ```bash
    az webapp log config \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --docker-container-logging filesystem
    ```

    **PowerShell**
    ```powershell
    az webapp log config `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME `
        --docker-container-logging filesystem
    ```

## Verify the deployment

In this section you verify the web app is running and responding.

1. Run the following command to retrieve the web app host name.

    **Bash**
    ```bash
    APP_URL=$(az webapp show \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --query defaultHostName \
        --output tsv)

    echo "Application URL: https://$APP_URL"
    ```

    **PowerShell**
    ```powershell
    $APP_URL = az webapp show `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME `
        --query defaultHostName `
        --output tsv

    Write-Host "Application URL: https://$APP_URL"
    ```

1. Open the URL in a browser to verify the application responds. Leave the browser open, you use it later in the exercise. The application should return a response indicating it is running. The first request may take longer as App Service pulls the container image and starts the application.

## Test document processing

In this section you send a request to the API so you can confirm the app is working and that results are being written to persistent storage.

1. Run the following command to submit the *document.txt* file included in the project to the processing endpoint.

    **Bash**
    ```bash
    curl -X POST "https://$APP_URL/process" \
        -H "Content-Type: text/plain" \
        --data-binary @document.txt
    ```

    **PowerShell**
    ```powershell
    $body = Get-Content -Raw -Path "document.txt"
    Invoke-RestMethod -Method Post -Uri "https://$APP_URL/process" -ContentType "text/plain" -Body $body | ConvertTo-Json -Depth 10
    ```

    The API returns mock analysis results including extracted entities, key phrases, and sentiment analysis. Notice that the response indicates whether the result was saved to persistent storage.

1. Run the following command to list all processed documents.

    **Bash**
    ```bash
    curl https://$APP_URL/documents
    ```

    **PowerShell**
    ```powershell
    Invoke-RestMethod -Uri "https://$APP_URL/documents" | ConvertTo-Json -Depth 10
    ```

    If persistent storage is enabled correctly, you should see the document you just processed in the list.

## Stream container logs

In this section you stream container logs to help troubleshoot startup and request processing.

1. Run the following command to view real-time logs from the container.

    **Bash**
    ```bash
    az webapp log tail \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME
    ```

    **PowerShell**
    ```powershell
    az webapp log tail `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME
    ```

1. Generate more requests to the application by refreshing the browser. You should see log entries appear in the stream. Press Ctrl+C to stop streaming.

## Inspect the diagnostic console

In this section you open the SCM (Kudu) site to inspect configuration views and common log locations.

1. Run the following command to print the SCM (Kudu) URL.

    **Bash**
    ```bash
    echo "Kudu URL: https://$APP_NAME.scm.azurewebsites.net"
    ```

    **PowerShell**
    ```powershell
    Write-Host "Kudu URL: https://$($env:APP_NAME).scm.azurewebsites.net"
    ```

1. Open this URL in a browser. In the menu at the top of the page, navigate to:

    1. **Environment** to view environment variables and verify your app settings are present.
    1. **Bash** to open a browser-based shell and file explorer.
    1. In the file explorer, navigate to **/home/LogFiles/** to view log files. Enter `ls` to list the files in the folder.

    >**Tip:** You can also use **Log stream** in the top menu to view logs in the browser, or use the **SSH** option to connect to the app container.

    The SCM site is separate from your app container, so it doesn't provide a complete view of the container's file system or running processes.

## View application settings

In this section you confirm the app settings you configured are present.

1. Run the following command to list application settings.

    **Bash**
    ```bash
    az webapp config appsettings list \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --output table
    ```

    **PowerShell**
    ```powershell
    az webapp config appsettings list `
        --resource-group $env:RESOURCE_GROUP `
        --name $env:APP_NAME `
        --output table
    ```

    Confirm that your settings appear in the list along with system-provided settings.

## Clean up resources

Now that you finished the exercise, you should delete the cloud resources you created to avoid unnecessary resource usage.

1. Run the following command in the VS Code terminal to delete the resource group, and all resources in the group. Replace **\<rg-name>** with the name you choose earlier in the exercise. The command will launch a background task in Azure to delete the resource group.

    ```
    az group delete --name <rg-name> --no-wait --yes
    ```

> **CAUTION:** Deleting a resource group deletes all resources contained within it. If you chose an existing resource group for this exercise, any existing resources outside the scope of this exercise will also be deleted.

## Troubleshooting

If you encounter issues while completing this exercise, try the following troubleshooting steps:

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
- View logs for a specific run (replace **<run-id>** with a value from the previous command):
    - **Bash:** **az acr task logs --registry $ACR_NAME --run-id <run-id>**
    - **PowerShell:** **az acr task logs --registry $env:ACR_NAME --run-id <run-id>**

**Troubleshoot container pull failures (ImagePullBackOff / unauthorized / 403)**
- Confirm the web app has a system-assigned managed identity enabled by running **az webapp identity show**.
- Confirm the web app has the **AcrPull** role assignment scoped to the registry. Role assignments can take a minute or two to propagate after creation.
- Re-run the container configuration step to ensure the image name and registry URL are correct.

**Troubleshoot container startup and application errors**
- Ensure container logging is enabled, then stream logs:
    - **Bash:** **az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME**
    - **PowerShell:** **az webapp log tail --resource-group $env:RESOURCE_GROUP --name $env:APP_NAME**
- If the app returns a 502/503 shortly after deployment, wait a minute and try again. The first start can take longer while App Service pulls and starts the container.

**Verify persistent storage is enabled**

- Confirm the **WEBSITES_ENABLE_APP_SERVICE_STORAGE** setting is present and set to **true**.
- Call the **/documents** endpoint after submitting a document to confirm results are being written to persistent storage.

### Summary



## You have successfully completed the Hands-on Lab!
