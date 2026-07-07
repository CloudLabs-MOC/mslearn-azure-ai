# Getting Started with your AI-200: Develop AI cloud solutions on Azure
 
Welcome to your AI-200: Develop AI cloud solutions on Azure workshop! In this lab, you will build a product similarity search application using Azure Database for PostgreSQL and the pgvector extension. You will deploy the database, create a vector-enabled schema, complete a Flask client app, and run similarity searches against product embeddings.

## Lab 13: Implement vector search with Azure Database for PostgreSQL

### Overall Estimated Timing: 60 Minutes

## Overview

In this hands-on lab, you will provision Azure Database for PostgreSQL, enable the pgvector extension, create a products table with a vector embedding column, and implement a Flask web application that loads sample product data, performs similarity searches, and adds new products. You will validate the solution by querying the database and examining the similarity search results in the web app.

## Objectives

By the end of this lab, you will be able to:

1. **Deploy PostgreSQL and enable pgvector:** Create an Azure Database for PostgreSQL server and configure the pgvector extension for vector storage.

2. **Create a vector-enabled schema:** Build a products table with a vector column and HNSW index to support efficient similarity queries.

3. **Implement a Flask client app:** Add routes that load sample data, perform vector similarity searches, and insert new products.

4. **Validate semantic search results:** Run the Flask application and use the web interface to find similar products based on embeddings.

## Pre-requisites

- Basic familiarity with relational databases and PostgreSQL.
- Experience using Python, Flask, and Azure CLI.
- Access to an Azure subscription and the provided lab credentials.
- Familiarity with running terminal commands in PowerShell or Bash.

## Architecture Diagram

![pending](../Images/lab13-arch.png)

## Architecture

The lab architecture shows a vector search application built on Azure Database for PostgreSQL with pgvector. The backend stores product embeddings and performs similarity searches, while a Flask web app serves as the client interface.

1. **Azure Database for PostgreSQL:** Hosts the managed PostgreSQL instance for storing products and embeddings.

2. **pgvector extension:** Enables vector data types and similarity operators in PostgreSQL.

3. **Products schema:** Uses a vector column to store embeddings and an HNSW index for fast similarity queries.

4. **Flask application:** Provides a web interface to load products, find similar items, and add new products.

## Explanation of Components

1. **Azure Database for PostgreSQL:** Provides a secure, managed relational database with support for Entra authentication and vector extensions.

2. **pgvector extension:** Adds support for vector columns and similarity operators like cosine distance, enabling semantic search.

3. **Products table:** Stores product details and 384-dimensional embeddings used to compute similarity.

4. **Flask client app:** Connects to PostgreSQL, loads sample data, executes vector search queries, and displays results in the browser.


## Accessing Your Lab Environment
 
Once you're ready to dive in, your virtual machine and **Guide** will be right at your fingertips within your web browser.
 
![Access Your VM and Lab Guide; pending](../Images/lab13-vm.png)

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