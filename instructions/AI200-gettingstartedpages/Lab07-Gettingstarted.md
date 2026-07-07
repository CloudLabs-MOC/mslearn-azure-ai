# Getting Started with your AI-200: Develop AI cloud solutions on Azure

Welcome to your AI-200: Develop AI cloud solutions on Azure workshop! In this lab, you will learn how to configure AKS applications with Kubernetes configuration resources such as ConfigMaps, Secrets, and persistent storage, then validate the deployment using a Python client app.

## Lab 07: Configure apps on Azure Kubernetes Service

### Overall Estimated Timing: 60 Minutes

## Overview

In this hands-on lab, you will provision Azure Container Registry and Azure Kubernetes Service resources, build and deploy a containerized API, then configure Kubernetes ConfigMaps, Secrets, and PersistentVolumeClaims. You will validate the deployed application by applying manifests, exposing the service, and using a Python client app to test health, readiness, secret access, and log retrieval.

## Objectives

1. **Deploy AKS infrastructure:** Provision Azure Container Registry and AKS resources needed to host the containerized API.

2. **Configure Kubernetes resources:** Create ConfigMaps, Secrets, and PersistentVolumeClaims to manage application settings, credentials, and storage.

3. **Update and deploy Kubernetes manifests:** Configure the deployment YAML to use your ACR image and apply the full set of Kubernetes manifests to AKS.

4. **Validate the application with a client app:** Use a Python client application to confirm API health, readiness, secret access, and log retrieval from persistent storage.

## Pre-requisites

- Basic understanding of Azure Kubernetes Service, container images, and Kubernetes manifests.

- Familiarity with Azure CLI commands and terminal usage in PowerShell or Bash.

- Access to an Azure subscription and the provided lab credentials.

- Experience with Visual Studio Code and editing YAML configuration files.

## Architecture

The lab architecture shows a containerized API deployed to AKS using ConfigMaps for non-sensitive settings, Secrets for sensitive data, and PersistentVolumeClaims for durable log storage. The AKS service exposes the API through a LoadBalancer so the client app can interact with it.

1. **Azure Container Registry:** Stores the Docker image used by the AKS deployment.

2. **Azure Kubernetes Service:** Runs the API pods and manages the Kubernetes resources.

3. **ConfigMap and Secret:** Provide configuration data and sensitive credentials to the application.

4. **PersistentVolumeClaim:** Provides durable storage for application logs across pod restarts.

## Architecture Diagram

![pending](../Images/lab7-arch.png)

## Explanation of Components

1. **Azure Container Registry:** Holds the container image that AKS pulls for the deployment.

2. **Azure Kubernetes Service:** Hosts the containerized API and manages pod lifecycle, networking, and scaling.

3. **ConfigMap:** Stores non-sensitive configuration values such as application settings and metadata.

4. **Secret:** Stores sensitive information securely so the application can access credentials without hardcoding them.

## Accessing Your Lab Environment

Once you're ready to dive in, your virtual machine and **Guide** will be right at your fingertips within your web browser.

![Access Your VM and Lab Guide; pending](../Images/lab07-guidetab.png)

## Virtual Machine & Lab Guide

Your virtual machine is your workhorse throughout the workshop. The lab guide is your roadmap to success.

## Exploring Your Lab Resources

To get a better understanding of your lab resources and credentials, navigate to the **Environment** tab.

![Explore Lab Resources; pending](../Images/lab07-envtab.png)

## Managing Your Virtual Machine

Feel free to **Start, Restart, or Stop (2)** your virtual machine as needed from the **Resources (1)** tab. Your experience is in your hands!

![Manage Your Virtual Machine](../Images/resourcetab.png)

## Lab Progress

You can use the **Progress** tab to track your progress while working on the lab. A score will be provided after successful validation.

![](../Images/progresstab.png)

## Utilizing the Split Window Feature

For convenience, you can open the lab guide in a separate window by selecting the **Split Window** button from the top right corner.

![Use the Split Window Feature;pending](../Images/lab07-splittab.png)

## Lab Guide Zoom In/Zoom Out

To adjust the zoom level for the environment page, click the **A↕: 100%** icon located next to the timer in the lab environment.

![pending](../Images/lab07-zoomtab.png)

## Let's Get Started with Azure Portal

1. On your virtual machine, click on the Azure Portal icon as shown below:

   ![Launch Azure Portal](../Images/azureportalicon.png)

1. In the sign-in window, kindly sign in using the provided Azure credentials
   - **Email/Username:** <inject key="AzureAdUserEmail"></inject>

     ![](../Images/sign-in-page.png)

   - **Password:** <inject key="AzureAdUserPassword"></inject>

     ![](../Images/tap-password.png)

1. If prompted to **Stay signed in?**, you can click **No**.

   ![](../Images/Sign-in-no.png)

1. If a **Welcome to Microsoft Azure** pop-up window appears, simply click **Maybe later** to skip the tour.

   ![](../Images/maybelater.png)

## Support Contact

The CloudLabs support team is available 24/7, 365 days a year, via email and live chat to ensure seamless assistance at any time. We offer dedicated support channels explicitly tailored for both learners and instructors, ensuring that all your needs are promptly and efficiently addressed.

Learner Support Contacts:

- Email Support: cloudlabs-support@spektrasystems.com
- Live Chat Support: https://cloudlabs.ai/labs-support

Click on **Next** from the lower right corner to move on to the next page.

![Start Your Azure Journey](../Images/next-page.png)

## Happy Learning !!
