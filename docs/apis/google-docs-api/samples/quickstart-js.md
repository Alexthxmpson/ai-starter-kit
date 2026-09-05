---
source: https://developers.google.com/workspace/docs/api/quickstart/js
scraped: 2026-03-01
api: google-docs-api
---

# Quickstart: JavaScript (Browser)

## Prerequisites

- Node.js & npm installed
- Google Cloud project created
- Google Account

## Setup Steps

### 1. Enable the API
Enable the Google Docs API in Google Cloud Console.

### 2. Configure OAuth Consent Screen
Navigate to Cloud Console > Google Auth platform > Branding:
- Enter app name and support email
- Select "Internal" audience
- Add contact information
- Accept Google API Services User Data Policy

### 3. Create OAuth 2.0 Client ID
In Cloud Console > Google Auth platform > Clients:
- Create Web application credential
- Add authorized JavaScript origins (domains for API requests)
- Note the Client ID (client secrets not required for web apps)

### 4. Generate API Key
In Cloud Console > APIs & Services > Credentials:
- Create API key
- Optionally restrict usage by API and location

## Required Configuration

Replace placeholder values in `index.html`:
- `YOUR_CLIENT_ID`: OAuth client ID from step 3
- `YOUR_API_KEY`: API key from step 4

## Key Constants

| Constant | Value |
|----------|-------|
| Discovery doc | `https://docs.googleapis.com/$discovery/rest?version=v1` |
| Scope | `https://www.googleapis.com/auth/documents.readonly` |

## Libraries Required

```html
<script src="https://apis.google.com/js/api.js"></script>
<script src="https://accounts.google.com/gsi/client"></script>
```

## Core Functions

```javascript
const CLIENT_ID = 'YOUR_CLIENT_ID';
const API_KEY = 'YOUR_API_KEY';
const DISCOVERY_DOC = 'https://docs.googleapis.com/$discovery/rest?version=v1';
const SCOPES = 'https://www.googleapis.com/auth/documents.readonly';

let tokenClient;
let gapiInited = false;
let gisInited = false;

function gapiLoaded() {
    gapi.load('client', initializeGapiClient);
}

async function initializeGapiClient() {
    await gapi.client.init({
        apiKey: API_KEY,
        discoveryDocs: [DISCOVERY_DOC],
    });
    gapiInited = true;
}

function gisLoaded() {
    tokenClient = google.accounts.oauth2.initTokenClient({
        client_id: CLIENT_ID,
        scope: SCOPES,
        callback: '',
    });
    gisInited = true;
}

function handleAuthClick() {
    tokenClient.callback = async (resp) => {
        if (resp.error !== undefined) throw resp;
        await listDocuments();
    };
    if (gapi.client.getToken() === null) {
        tokenClient.requestAccessToken({ prompt: 'consent' });
    } else {
        tokenClient.requestAccessToken({ prompt: '' });
    }
}

function handleSignoutClick() {
    const token = gapi.client.getToken();
    if (token !== null) {
        google.accounts.oauth2.revoke(token.access_token);
        gapi.client.setToken('');
    }
}

async function printDocTitle() {
    let response;
    try {
        response = await gapi.client.docs.documents.get({
            documentId: 'DOCUMENT_ID',
        });
    } catch (err) {
        document.getElementById('content').innerText = err.message;
        return;
    }
    const doc = response.result;
    document.getElementById('content').innerText = `Title: ${doc.title}`;
}
```

## Running the Application

```bash
npm install http-server
npx http-server -p 8000
```

Navigate to `http://localhost:8000` and authorize access.
