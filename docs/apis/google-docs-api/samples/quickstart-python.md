---
source: https://developers.google.com/workspace/docs/api/quickstart/python
scraped: 2026-03-01
api: google-docs-api
---

# Quickstart: Python

## Prerequisites

- Python 3.10.7 or greater
- pip package management tool
- Google Cloud project
- Google Account

## Setup Steps

### 1. Enable the API

Access Google Cloud Console and activate the Google Docs API.

### 2. Configure OAuth Consent Screen

Navigate to Google Cloud console > Auth platform > Branding:
- Enter app name and support email
- Select "Internal" for audience type
- Provide contact information
- Agree to the Google API Services User Data Policy

### 3. Create Desktop Application Credentials

In Google Cloud console > Auth platform > Clients:
- Create OAuth 2.0 Client ID for Desktop Application
- Download the JSON credentials file
- Save as `credentials.json` in your working directory

## Installation

```bash
python3 -m pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
```

## Implementation

Create `quickstart.py`:

```python
import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/documents.readonly"]

# The ID of a sample document.
DOCUMENT_ID = "195j9eDD3ccgjQRttHhJPymLJUCOUjs-jmwTrekvdjFE"

def main():
    """Shows basic usage of the Docs API.
    Prints the title of a sample document.
    """
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists("token.json"):
        creds = Credentials.from_authorized_user_file("token.json", SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                "credentials.json", SCOPES
            )
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open("token.json", "w") as token:
            token.write(creds.to_json())

    try:
        service = build("docs", "v1", credentials=creds)

        # Retrieve the documents contents from the Docs service.
        document = service.documents().get(documentId=DOCUMENT_ID).execute()

        print(f"The title of the document is: {document.get('title')}")
    except HttpError as err:
        print(err)

if __name__ == "__main__":
    main()
```

## Execution

```bash
python3 quickstart.py
```

On first execution:
1. App opens browser for authentication
2. Sign into Google Account
3. Accept permission prompt
4. Authorization details cached in `token.json` for subsequent runs

## Next Steps

- Change the `SCOPES` variable to access more document data
- Explore the `documents.batchUpdate` method for write operations
- See the samples for practical implementations
