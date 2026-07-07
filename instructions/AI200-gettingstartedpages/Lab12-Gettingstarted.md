# Getting Started with your AI-200: Develop AI cloud solutions on Azure
 
Welcome to your AI-200: Develop AI cloud solutions on Azure workshop! In this lab, you will provision Azure Database for PostgreSQL with Microsoft Entra authentication, design a relational schema for agent memory and task checkpoints, and implement Python tool functions that let an AI agent store conversation history and resume interrupted workflows.

## Lab 12: Build an agent tool backend on Azure Database for PostgreSQL

### Overall Estimated Timing: 30 Minutes

## Overview

In this hands-on lab, you will provision Azure Database for PostgreSQL, create a database schema for agent memory and task checkpoints, and implement Python functions that allow an AI agent to save conversation history and resume work. You will validate the workflow by running a test script and querying the persisted agent data.

## Objectives

By the end of this lab, you will be able to:

1. **Deploy PostgreSQL backend services:** Provision Azure Database for PostgreSQL with Microsoft Entra authentication and configure access for your lab environment.

2. **Design agent memory schema:** Create tables for conversations, messages, and task checkpoints to persist agent state and context.

3. **Build agent tool functions:** Implement Python functions that create conversations, store messages, save task checkpoints, and retrieve conversation history.

## Pre-requisites

- Basic knowledge of relational databases and PostgreSQL.
- Experience using Python, Azure CLI, and Visual Studio Code.
- Access to an Azure subscription and the provided lab credentials.
- Familiarity with running scripts in PowerShell or Bash.

## Architecture

The lab architecture demonstrates an AI agent tool backend built on Azure Database for PostgreSQL. The backend stores conversation sessions, message history, and task checkpoint state so the agent can maintain memory and resume interrupted workflows.

1. **Azure Database for PostgreSQL:** Hosts the relational database for agent memory storage.

2. **Agent memory schema:** Uses tables for conversations, messages, and task checkpoints.

3. **Python tool functions:** Provide the agent interface for creating sessions, storing messages, and saving task status.

4. **Test workflow script:** Verifies that the agent backend works end-to-end by creating conversations, storing messages, and querying stored data.

## Architecture Diagram

![pending](../Images/lab12-arch.png)

## Explanation of Components

1. **Azure Database for PostgreSQL:** Provides a managed relational database for agent session state and conversation context.

2. **Conversations table:** Stores agent session metadata and links related messages.

3. **Messages table:** Records user, system, assistant, and tool messages in chronological order.

4. **Task checkpoints:** Persist task state so an agent can resume interrupted tasks and track progress.

## Accessing Your Lab Environment
 
Once you're ready to dive in, your virtual machine and **Guide** will be right at your fingertips within your web browser.
 
![Access Your VM and Lab Guide; pending](../Images/lab12-vm.png)

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