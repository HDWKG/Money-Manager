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

# Project Setup

## 7. **Adding Your Credentials**

To connect your application to Google Sheets, you will need to add your Google service account credentials and the Google Sheets ID.

### Steps:

1. **Create the `config.dart` File:**
   - Navigate to the folder `lib/api/sheets` in your project directory.
   - Create a new file named `config.dart`.

2. **Add the `Config` Class:**
   - Copy and paste the following code into `config.dart`:

     ```dart
     class Config {
       static const String credentials = r'''
       INSERT YOUR JSON CREDENTIALS FILE HERE
       ''';
       static const String spreadsheetId = "INSERT YOUR SPREADSHEET ID HERE";
     }
     ```

3. **Insert Your JSON Credentials:**
   - In the `config.dart` file, find the comment `INSERT YOUR JSON CREDENTIALS FILE HERE`.
   - Copy the contents of your downloaded **Google Service Account JSON key** and paste it in place of the comment. The JSON should look similar to this:

     ```json
     {
       "type": "service_account",
       "project_id": "your-project-id",
       "private_key_id": "your-private-key-id",
       "private_key": "your-private-key",
       ...
     }
     ```

4. **Insert Your Google Sheets ID:**
   - Find the comment `INSERT YOUR SPREADSHEET ID HERE` in the `config.dart` file.
   - Replace it with your actual **Google Sheets ID**. You can find the ID in the URL of your Google Sheets document:

     - Example URL: `https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit`
     - Extract the ID (the part between `/d/` and `/edit`), and replace the placeholder with it like so:

     ```dart
     static const String spreadsheetId = "YOUR_SPREADSHEET_ID";
     ```

5. **Keep `config.dart` Secure:**
   - Since this file contains sensitive information (like your service account credentials), you should **never** commit it to a public repository. Make sure to add it to your `.gitignore` file to prevent accidental uploads to GitHub.

---

### 8. **Additional steps to the Project**

1. Create a tab named Settings in your Google Spreadsheet.
2. In cell A1 of the Settings tab, enter the name of the first new tab you want to create, for example, Nov24.

## Additional Notes:

- If you need to regenerate your Google service account credentials, follow the [official Google Cloud documentation](https://cloud.google.com/docs/authentication/getting-started) to create a new service account and download the JSON key.
- You can update the `spreadsheetId` if you need to switch to a different Google Sheets document.
