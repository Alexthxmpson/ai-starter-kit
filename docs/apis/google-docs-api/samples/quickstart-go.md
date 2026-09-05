---
source: https://developers.google.com/workspace/docs/api/quickstart/go
scraped: 2026-03-01
api: google-docs-api
---

# Quickstart: Go

## Prerequisites

- Latest version of Go
- Latest version of Git
- Google Cloud project
- Google Account

## Setup Steps

### 1. Enable the API

Enable the Google Docs API in Google Cloud Console.

### 2. Configure OAuth Consent Screen

In Google Cloud console > Google Auth platform > Branding:
- Provide app name and support email
- Set audience to "Internal"
- Enter contact email
- Agree to Google API Services User Data Policy

### 3. Create Desktop Application Credentials

In Google Cloud console > Google Auth platform > Clients:
- Click "Create Client"
- Select "Desktop app" as application type
- Provide a credential name
- Download the JSON file as `credentials.json`

## Workspace Preparation

```bash
mkdir quickstart
cd quickstart
go mod init quickstart
go get google.golang.org/api/docs/v1
go get golang.org/x/oauth2/google
```

## Implementation

Create `quickstart.go`:

```go
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"

    "golang.org/x/oauth2"
    "golang.org/x/oauth2/google"
    "google.golang.org/api/docs/v1"
    "google.golang.org/api/option"
)

// Retrieve a token, saves the token, then returns the generated client.
func getClient(config *oauth2.Config) *http.Client {
    tokenFile := "token.json"
    tok, err := tokenFromFile(tokenFile)
    if err != nil {
        tok = getTokenFromWeb(config)
        saveToken(tokenFile, tok)
    }
    return config.Client(context.Background(), tok)
}

// Request a token from the web, then returns the retrieved token.
func getTokenFromWeb(config *oauth2.Config) *oauth2.Token {
    authURL := config.AuthCodeURL("state-token", oauth2.AccessTypeOffline)
    fmt.Printf("Go to the following link in your browser then type the "+
        "authorization code: \n%v\n", authURL)

    var authCode string
    if _, err := fmt.Scan(&authCode); err != nil {
        log.Fatalf("Unable to read authorization code: %v", err)
    }

    tok, err := config.Exchange(context.TODO(), authCode)
    if err != nil {
        log.Fatalf("Unable to retrieve token from web: %v", err)
    }
    return tok
}

// Retrieves a token from a local file.
func tokenFromFile(file string) (*oauth2.Token, error) {
    f, err := os.Open(file)
    if err != nil {
        return nil, err
    }
    defer f.Close()
    tok := &oauth2.Token{}
    err = json.NewDecoder(f).Decode(tok)
    return tok, err
}

// Saves a token to a file path.
func saveToken(path string, token *oauth2.Token) {
    fmt.Printf("Saving credential file to: %s\n", path)
    f, err := os.OpenFile(path, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0600)
    if err != nil {
        log.Fatalf("Unable to cache oauth token: %v", err)
    }
    defer f.Close()
    json.NewEncoder(f).Encode(token)
}

func main() {
    ctx := context.Background()
    b, err := os.ReadFile("credentials.json")
    if err != nil {
        log.Fatalf("Unable to read client secret file: %v", err)
    }

    // If modifying these scopes, delete your previously saved token.json.
    config, err := google.ConfigFromJSON(b,
        "https://www.googleapis.com/auth/documents.readonly")
    if err != nil {
        log.Fatalf("Unable to parse client secret file to config: %v", err)
    }
    client := getClient(config)

    srv, err := docs.NewService(ctx, option.WithHTTPClient(client))
    if err != nil {
        log.Fatalf("Unable to retrieve Docs client: %v", err)
    }

    // Prints the title of a sample document.
    docId := "195j9eDD3ccgjQRttHhJPymLJUCOUjs-jmwTrekvdjFE"
    doc, err := srv.Documents.Get(docId).Do()
    if err != nil {
        log.Fatalf("Unable to retrieve data from document: %v", err)
    }
    fmt.Printf("The title of the doc is: %s\n", doc.Title)
}
```

## Running the Application

```bash
go run quickstart.go
```

First execution:
1. Prints an authorization URL
2. Paste URL in browser, authenticate
3. Copy the authorization code back to terminal
4. Token saved to `token.json` for subsequent runs

## Key Technical Details

- Token caching eliminates repeated authorization prompts
- OAuth2 offline access type enables token refresh
- Read-only scope restricts API permissions appropriately
- Context-based client management for resource cleanup
