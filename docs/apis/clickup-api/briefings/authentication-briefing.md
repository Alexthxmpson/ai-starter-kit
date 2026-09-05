# Authentication & Data Model — Briefing

**Coverage: 98% | Status: COMPLETE**

## Quick Facts

- **Two auth methods only:** Personal token (`pk_` prefix) and OAuth 2.0
- **Personal token header:** `Authorization: pk_xxx` — NO Bearer prefix
- **OAuth token header:** `Authorization: Bearer {access_token}`
- **Personal tokens:** Never expire until manually regenerated
- **OAuth tokens:** Currently no expiry (documented as subject to change)
- **OAuth scopes:** None (workspace-level, inherits user's role)

## Auth Decision Tree

```
Single workspace, internal automation → Personal Token
Public app / multi-user → OAuth 2.0
```

## OAuth Flow (4 Steps)

1. Create app: Settings → ClickUp API → Create an App
2. Redirect user: `https://app.clickup.com/api?client_id={id}&redirect_uri={uri}&state={csrf}`
3. Receive code at redirect URI
4. Exchange: `POST /api/v2/oauth/token` with `{client_id, client_secret, code}`

## Hierarchy & IDs

```
Workspace (team_id: numeric int)
  └── Space (space_id: numeric int)
        ├── Folder (folder_id: numeric int)
        │     └── List (list_id: numeric int)
        │           └── Task (task_id: short string "9hz")
        └── List [folderless]
```

Critical: `team_id` in v2 = Workspace ID (legacy naming). `group_id` = user group.

## Get Started

```python
headers = {"Authorization": "pk_YOUR_TOKEN", "Content-Type": "application/json"}
workspaces = requests.get("https://api.clickup.com/api/v2/team", headers=headers).json()
team_id = workspaces["teams"][0]["id"]
```

## Role Numbers

| Role | Value |
|------|-------|
| Owner | 1 |
| Admin | 2 |
| Member | 3 |
| Guest | 4 |

## Key OAuth Error Codes

| ECODE | Meaning |
|-------|---------|
| OAUTH_019, OAUTH_021, OAUTH_077 | Token not found (revoked) — re-auth required |
| OAUTH_023, OAUTH_026, OAUTH_027 | Workspace not authorized |
| OAUTH_007 | Redirect URI mismatch |

## Sources

- https://developer.clickup.com/docs/authentication
- https://developer.clickup.com/docs/faq
- https://developer.clickup.com/docs/common_errors
