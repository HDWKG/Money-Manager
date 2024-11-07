# Google Sheets API with Flutter

This project demonstrates how to connect a Flutter-based Money Management application to the Google Sheets API using service account authentication. The app uses Google Sheets to store and manage financial data, such as transactions, categories, and totals. It shows how to fetch, update, and manipulate data in a Google Sheet, providing real-time data management directly from the app.

## Prerequisites

Before you begin, you will need the following:

- A Google Cloud Platform account
- A Google Sheet to interact with

## Step-by-Step Guide

### 1. **Create a Google Cloud Developer Account**

If you don't already have a Google Cloud Platform (GCP) account, follow these steps:

- Visit the [Google Cloud Console](https://console.cloud.google.com/).
- Sign in with your Google account or create a new one.

### 2. **Create a New Google Cloud Project**

1. In the Google Cloud Console, click on **Select a Project** at the top.
2. Click on **New Project**.
3. Name your project and choose the location (parent organization or folder).
4. Click **Create**.

### 3. **Enable Google Sheets API**

1. In the Google Cloud Console, go to **API & Services** > **Library**.
2. Search for **Google Sheets API** and click **Enable**.

### 4. **Create Service Account**

1. On the left panel in the **IAM & Admin** section, go to **Service Accounts**.
2. Click **Create Service Account**.
3. Give it a name (e.g., `gsheets-service-account`) and click **Create**.
4. Select the role **Project > Owner** (or just continue).
5. Click **Done**.

### 5. **Download Service Account Credentials**

1. In the Service Accounts section, click on your newly created service account.
2. Go to the **Keys** tab by clicking on your account and click **Add Key** > **Create New Key**.
3. Choose **JSON** and click **Create**. This will download the JSON credentials file.
4. Save this file securely as it contains sensitive information.

### 6. **Share Your Google Sheet with the Service Account**

1. Open your Google Sheet.
2. Click the **Share** button in the top-right corner.
3. Add the service account email (e.g., `gsheets@excample.iam.gserviceaccount.com`) and grant **Editor** access.
4. Click **Send**.

### 7. **Adding Your Credentials**

1. Open the folder `api/sheets` in your project directory.
2. You will find a file called `config.dart`.
3. In the `config.dart` file, find the comment `INSERT JSON FILE HERE`. 
   - **Copy & paste** the contents of your downloaded JSON key into this section.
4. Next, locate the `INSERT SPREADSHEET ID` section.
   - Replace the placeholder value in the `__spreadsheetId` variable with your actual Google Sheets ID (the part of the Google Sheets URL after `/d/` and before `/edit`). For example:
     - Google Sheets URL: `https://docs.google.com/spreadsheets/d/your-spreadsheet-id/edit`
     - `spreadsheetId = 'your-spreadsheet-id'`

### 8. **Initializing the Project**

1. Create a tab named Settings in your Google Spreadsheet.
2. In cell A1 of the Settings tab, enter the name of the first new tab you want to create, for example, Nov24.