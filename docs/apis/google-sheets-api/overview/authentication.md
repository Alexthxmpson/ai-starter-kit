---
source: https://developers.google.com/sheets/api/scopes
scraped: 2026-03-01
api: google-sheets-api
---

# Google Sheets API Authentication & Authorization

## Authentication Method

The Google Sheets API uses **OAuth 2.0** for authentication and authorization. All requests require a valid OAuth 2.0 token.

## Available OAuth Scopes

| Scope URI | Description | Classification |
|---|---|---|
| `https://www.googleapis.com/auth/spreadsheets` | See, edit, create, and delete all your Google Sheets spreadsheets | Sensitive |
| `https://www.googleapis.com/auth/spreadsheets.readonly` | See all your Google Sheets spreadsheets | Sensitive |
| `https://www.googleapis.com/auth/drive.file` | See, edit, create, and delete only the specific Google Drive files you use with this app | Non-sensitive (Recommended) |
| `https://www.googleapis.com/auth/drive` | See, edit, create, and delete all of your Google Drive files | Restricted |
| `https://www.googleapis.com/auth/drive.readonly` | See and download all your Google Drive files | Restricted |

## Sensitivity Classifications

- **Non-sensitive**: Minimal access; requires basic verification only
- **Sensitive**: Specific user data access; requires additional Google verification
- **Restricted**: Broad access; requires restricted scope verification and potential security assessment if server storage occurs

## Key Limitation

Scopes apply to **spreadsheet files as a whole**, not to individual sheets within a spreadsheet. Use `ProtectedRange` objects to prevent modification of specific sheets.

## Python Quickstart Setup

### Prerequisites
- Python 3.10.7 or greater
- pip package management tool
- Google Cloud project
- Google Account

### Installation
```bash
python3 -m pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
```

### Setup Steps

1. **Enable the API** - Access Google Cloud console and enable the Google Sheets API
2. **Configure OAuth Consent Screen** - Navigate to Authentication settings and configure app name, support email, audience type
3. **Create Desktop Credentials** - Generate OAuth 2.0 Client ID for desktop applications, save downloaded JSON as `credentials.json`

### Basic Code Pattern
```python
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

SCOPES = ["https://www.googleapis.com/auth/spreadsheets.readonly"]
SPREADSHEET_ID = "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"

# Auth flow handles credentials and token.json storage
creds = None
# token.json stores the user's access and refresh tokens
# Created automatically when the authorization flow completes

service = build("sheets", "v4", credentials=creds)
sheet = service.spreadsheets()
result = sheet.values().get(spreadsheetId=SPREADSHEET_ID, range="Class Data!A2:E").execute()
```

## Common Authentication Errors

| Error | Cause | Solution |
|---|---|---|
| "This app isn't verified" | App requests sensitive scopes without verification | Complete Google's verification process; bypass with "Advanced > Go to {Project}" during dev |
| credentials.json not found | Desktop credentials not created | Create OAuth 2.0 Client ID in Google Cloud console, download and rename to credentials.json |
| Token expired/revoked | Access token expired or user revoked access | Implement token refresh logic; check refresh token expiration docs |
| origin_mismatch | Host/port doesn't match authorized JavaScript origins | Verify origin URL matches browser URL |
| idpiframe_initialization_failed | Third-party cookies disabled or invalid domain | Enable cookies or add exception for accounts.google.com |
