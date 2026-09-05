# Make.com API Documentation

**Source:** https://developers.make.com/api-documentation
**Date Saved:** 2026-03-01
**API Version:** v2

---

## Overview

Make (formerly Integromat) provides a REST API that allows programmatic access to Make data and platform control. The API follows resource-oriented URL design.

---

## Base URLs

| Zone | Base URL |
|------|----------|
| EU1 | `https://eu1.make.com/api/v2` |
| EU2 | `https://eu2.make.com/api/v2` |
| US1 | `https://us1.make.com/api/v2` |
| US2 | `https://us2.make.com/api/v2` |
| Celonis EU1 | `https://eu1.make.celonis.com/api/v2` |
| Celonis US1 | `https://us1.make.celonis.com/api/v2` |

---

## Authentication

### API Token (Primary)
Create an authentication token in your Make account settings.

```http
Authorization: Token your-api-token
```

### OAuth 2.0
Request an OAuth 2.0 client for production integrations.

### Token Scopes
Each endpoint lists its required scope. Common scopes:
- `scenarios:read` / `scenarios:write`
- `teams:read` / `teams:write`
- `connections:read` / `connections:write`
- `team-variables:read` / `team-variables:write`
- `notifications:read` / `notifications:write`
- `organization:read`

---

## Pagination

Standard query parameters for paginated endpoints:

| Parameter | Type | Description |
|-----------|------|-------------|
| `pg[offset]` | integer | Number of records to skip |
| `pg[limit]` | integer | Max records to return |
| `pg[sortBy]` | string | Field to sort by |
| `pg[sortDir]` | string | `asc` or `desc` |
| `pg[returnTotalCount]` | boolean | Include total count in response |

Cursor-based: `pg[last]` — ID/key of last retrieved record.

---

## General

### Ping
**GET** `/ping`

Health check endpoint. Returns plain text on success.

**Auth:** Not required
**Response:** `200 text/plain`

---

## Scenarios

### List Scenarios
**GET** `/scenarios`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `teamId` | integer | Yes | Team ID |
| `organizationId` | integer | No | Filter by org |
| `id[]` | integer[] | No | Filter by scenario IDs |
| `folderId` | integer | No | Filter by folder |
| `isActive` | boolean | No | Filter by active status |
| `concept` | boolean | No | Filter concept scenarios |
| `type` | string | No | `scenario` or `tool` |
| `cols[]` | string[] | No | Fields to return |
| `pg[*]` | various | No | Pagination |

**Response:** `{ scenarios: [...], pg: {...} }`

---

### Create Scenario
**POST** `/scenarios`

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `blueprint` | string | Yes | Scenario blueprint JSON |
| `teamId` | integer | Yes | Team ID |
| `scheduling` | string | Yes | Scheduling config JSON |
| `folderId` | integer | No | Folder ID |
| `basedon` | integer | No | Base scenario ID |

---

### Get Scenario
**GET** `/scenarios/{scenarioId}`

**Response:** Single scenario object.

---

### Update Scenario
**PATCH** `/scenarios/{scenarioId}`

**Body:** `blueprint`, `scheduling`, `folderId`, `name` (all optional)

---

### Delete Scenario
**DELETE** `/scenarios/{scenarioId}`

**Response:** `{ scenario: <id> }`

---

### Activate Scenario
**POST** `/scenarios/{scenarioId}/start`

**Response:** `{ scenario: { id, isActive: true } }`

---

### Deactivate Scenario
**POST** `/scenarios/{scenarioId}/stop`

**Response:** `{ scenario: { id, isActive: false } }`

---

### Run Scenario
**POST** `/scenarios/{scenarioId}/run`

**Body:**

| Field | Type | Description |
|-------|------|-------------|
| `data` | object | Input data for the scenario |
| `responsive` | boolean | Wait for execution and return status (default: false) |
| `callbackUrl` | string | Webhook to call when done |

**Response:** `{ executionId: string, status?: "1"|"2"|"3" }`

Status codes: `1` = success, `2` = warning, `3` = error

---

### Clone Scenario
**POST** `/scenarios/{scenarioId}/clone`

**Query:** `organizationId` (required), `confirmed`, `notAnalyze`

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Clone name |
| `teamId` | integer | Yes | Target team |
| `states` | boolean | Yes | Copy states |
| `account` | object | No | Connection mapping |
| `key` | object | No | Key mapping |
| `hook` | object | No | Hook mapping |
| `device` | object | No | Device mapping |
| `udt` | object | No | Data structure mapping |
| `datastore` | object | No | Data store mapping |

---

### Replay Execution
**POST** `/scenarios/{scenarioId}/replay`

**Body:** `{ executionIds: string[] }`

**Response:** `202 Accepted`

---

### Get Trigger Details
**GET** `/scenarios/{scenarioId}/triggers`

**Response:** `{ id, name, udid, scope, queueCount, queueLimit, typeName, type, url, flags }`

---

### Get Scenario Interface
**GET** `/scenarios/{scenarioId}/interface`

---

### Update Scenario Interface
**PATCH** `/scenarios/{scenarioId}/interface`

**Body:** `{ interface: { input: [...] } }`

---

### Get Scenario Usage
**GET** `/scenarios/{scenarioId}/usage`

**Query:** `organizationTimezone` (boolean)

**Response:** Array of `{ date, operations, dataTransfer, centicredits }`

---

### Buildtime Variables

**List:** `GET /scenarios/{scenarioId}/build-variables`
**Add:** `POST /scenarios/{scenarioId}/build-variables` — Body: `{ input: [{ name, value }] }`
**Update:** `PUT /scenarios/{scenarioId}/build-variables` — Body: `{ input: [{ name, value }] }`
**Delete:** `DELETE /scenarios/{scenarioId}/build-variables?value={name}`

---

## Organizations

### List User Organizations
**GET** `/organizations`

**Query:** `zone`, `externalId`, `cols[]`, `pg[*]`

**Response:** `{ organizations: [...] }`

Fields: `id`, `name`, `serviceName`, `timezoneId`, `license`, `teams`, `scenarios`, `activeScenarios`, `tfaEnforced`

---

### Create Organization
**POST** `/organizations`

**Body:** `name`*, `regionId`*, `timezoneId`*, `countryId`*

---

### Get Organization
**GET** `/organizations/{organizationId}`

---

### Update Organization
**PATCH** `/organizations/{organizationId}`

**Body:** `name`, `timezoneId`, `countryId`

---

### Delete Organization
**DELETE** `/organizations/{organizationId}`

**Query:** `confirmed` (required if active scenarios exist)

---

### Invite User to Organization
**POST** `/organizations/{organizationId}/invite`

**Body:** `usersRoleId`*, `email`*, `name`*, `note`, `teamsId[]`

---

### Organization Variables
**List:** `GET /organizations/{organizationId}/variables`
**Create:** `POST /organizations/{organizationId}/variables` — Body: `typeId`* (1=number, 2=string, 3=boolean, 4=date), `name`*, `value`*
**Update:** `PATCH /organizations/{organizationId}/variables/{variableName}` — Body: `typeId`, `value`
**Delete:** `DELETE /organizations/{organizationId}/variables/{variableName}?confirmed=true`
**History:** `GET /organizations/{organizationId}/variables/{variableName}/history`

---

### Organization Usage
**GET** `/organizations/{organizationId}/usage`

30-day daily metrics: `{ date, operations, dataTransfer, centicredits }`

---

### Subscription Management
**Get Active:** `GET /organizations/{organizationId}/subscription`
**Create:** `POST /organizations/{organizationId}/subscription` — Body: `priceId`*, `couponCode`, `customer` object
**Change Plan:** `PATCH /organizations/{organizationId}/subscription`
**Cancel:** `DELETE /organizations/{organizationId}/subscription`
**Set Free:** `POST /organizations/{organizationId}/subscription-free`

---

### Feature Controls
**List:** `GET /organizations/{organizationId}/feature-controls`
**Update:** `PATCH /organizations/{organizationId}/feature-controls` — Body: `id`*, `enabled`*

---

### TFA Enforcement
**PATCH** `/organizations/{organizationId}/tfa-enforcement`
**Body:** `{ enable: boolean }`

---

### Check Team Permission
**GET** `/organizations/{organizationId}/check-team-permission?teamPermission={permission}`

**Response:** `{ hasPermission: boolean }`

---

## Teams

### List Teams
**GET** `/teams?organizationId={id}`

**Response:** `{ teams: [{ id, name, organizationId, operationsLimit, transferLimit }], pg: {...} }`

**Scope:** `teams:read`

---

### Create Team
**POST** `/teams`

**Body:** `name`*, `organizationId`*, `operationsLimit`

**Scope:** `teams:write`

---

### Get Team
**GET** `/teams/{teamId}`

---

### Delete Team
**DELETE** `/teams/{teamId}?confirmed=true`

Deletes all associated data (scenarios, webhooks, variables).

---

### Team Variables
**List:** `GET /teams/{teamId}/variables`
**Create:** `POST /teams/{teamId}/variables` — Body: `typeId`* (1-4), `name`*, `value`*
**Update:** `PATCH /teams/{teamId}/variables/{variableName}`
**Delete:** `DELETE /teams/{teamId}/variables/{variableName}`
**History:** `GET /teams/{teamId}/variables/{variableName}/history`

---

### Team Usage
**GET** `/teams/{teamId}/usage`

30-day daily metrics per team.

---

### Team LLM Configuration
**Get:** `GET /teams/{teamId}/llm-configuration`
**Update:** `PATCH /teams/{teamId}/llm-configuration`

**Body fields:** `aiMappingAccountId`, `aiMappingModelName`, `aiMappingBuiltinTier`, `aiToolkitAccountId`, `aiToolkitModelName`, `aiToolkitBuiltinTier`

---

### Team Feature Controls
**GET** `/teams/{teamId}/feature-controls`

---

## Connections

### List Connections
**GET** `/connections?teamId={id}`

**Query:** `type[]`, `cols[]` (id, name, accountName, accountLabel, packageName, expire, metadata, teamId, theme, upgradeable, scopesCnt, scoped, accountType, editable, uid, connectedSystemId, organizationId)

---

### Create Connection
**POST** `/connections?teamId={id}`

**Body:** `accountName`, `accountType`*, `scopes[]`

---

### Get Connection
**GET** `/connections/{connectionId}`

---

### Rename Connection
**PATCH** `/connections/{connectionId}`

**Body:** `{ name: string }` (max 128 chars)

---

### Delete Connection
**DELETE** `/connections/{connectionId}?confirmed=true`

---

### Verify Connection
**POST** `/connections/{connectionId}/test`

**Response:** `{ verified: boolean }`

---

### Check Connection Scopes
**POST** `/connections/{connectionId}/scoped`

**Body:** `{ scope: string[] }`

**Response:** `{ connection: { scoped: boolean } }`

---

### Get Editable Parameters
**GET** `/connections/{connectionId}/editable-data-schema`

**Response:** `{ editableParameters: string[] }`

---

### Update Connection Data
**POST** `/connections/{connectionId}/set-data`

**Body:** Dynamic object based on editable-data-schema response.

**Response:** `{ changed: boolean }`

---

## Webhooks (Hooks)

### List Hooks
**GET** `/hooks?teamId={id}`

**Query:** `typeName`, `assigned`, `viewForScenarioId`

---

### Create Hook
**POST** `/hooks`

**Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Max 128 chars |
| `teamId` | string | Yes | Team ID |
| `typeName` | string | Yes | Hook type (e.g. `gateway-webhook`, `gateway-mailhook`) |
| `method` | boolean | Yes | Include HTTP method in body |
| `header` | boolean | Yes | Include headers in body |
| `stringify` | boolean | Yes | Return JSON as strings |

**Response:** Created hook with URL

---

### Get Hook
**GET** `/hooks/{hookId}`

---

### Update Hook
**PATCH** `/hooks/{hookId}`

**Body:** `{ name: string }`

---

### Delete Hook
**DELETE** `/hooks/{hookId}?confirmed=true`

---

### Ping Hook
**GET** `/hooks/{hookId}/ping`

**Response:** `{ address, attached, learning, gone }`

---

### Enable / Disable Hook
**POST** `/hooks/{hookId}/enable`
**POST** `/hooks/{hookId}/disable`

**Response:** `{ success: boolean }`

---

### Hook Learning
**POST** `/hooks/{hookId}/learn-start` — Start learning request structure
**POST** `/hooks/{hookId}/learn-stop` — Stop learning

---

### Set Hook Data
**POST** `/hooks/{hookId}/set-data`

**Body:** Varies by hook type.

**Response:** `{ changed: boolean }`

---

## Data Stores

### List Data Stores
**GET** `/data-stores?teamId={id}`

**Response:** `{ dataStores: [{ id, name, teamId, records, size, maxSize, datastructureId }], pg: {...} }`

---

### Create Data Store
**POST** `/data-stores`

**Body:** `name`* (max 128), `teamId`*, `datastructureId`*, `maxSizeMB`*

---

### Get Data Store
**GET** `/data-stores/{dataStoreId}`

---

### Update Data Store
**PATCH** `/data-stores/{dataStoreId}`

**Body:** `name`, `datastructureId`, `maxSizeMB` (all optional)

---

### Delete Data Stores
**DELETE** `/data-stores?teamId={id}&confirmed=true`

**Body:** `{ ids: [...] }` or `{ all: true, exceptIds: [...] }`

---

## Incomplete Executions (DLQ)

### List Incomplete Executions
**GET** `/dlqs?scenarioId={id}`

**Response:** `{ dlqs: [{ id, reason, created, size, resolved, retry, attempts }] }`

---

### Get Execution Detail
**GET** `/dlqs/{dlqId}`

---

### Retry Execution
**POST** `/dlqs/{dlqId}/retry`

---

### Retry Multiple Executions
**POST** `/dlqs/retry?scenarioId={id}`

**Body:** `{ ids: [...] }` or `{ all: true, exceptIds: [...] }`

---

### Get Failed Blueprint
**GET** `/dlqs/{dlqId}/blueprint`

---

### Get Bundles
**GET** `/dlqs/{dlqId}/bundle`

---

### Get DLQ Logs
**GET** `/dlqs/{dlqId}/logs`

**Query:** `status` (1=success, 2=warning, 3=error), `from`, `to`

---

### Update Incomplete Execution
**PATCH** `/dlqs/{dlqId}`

**Body:** `{ blueprint: string, failer: integer }`

---

### Delete Incomplete Executions
**DELETE** `/dlqs?scenarioId={id}&confirmed=true`

**Body:** `{ ids: [...] }` or `{ all: true }`

---

## Keys (Keychain)

### List Keys
**GET** `/keys?teamId={id}`

**Query:** `typeName`, `cols[]`

---

### List Key Types
**GET** `/keys/types`

**Response:** `{ keysTypes: [{ name, label, parameters, componentType, author, version, theme, icon }] }`

---

### Create Key
**POST** `/keys`

**Body:** `teamId`*, `name`*, `typeName`*, `parameters`*

---

### Get Key
**GET** `/keys/{keyId}`

---

### Update Key
**PATCH** `/keys/{keyId}`

**Body:** `name`, `parameters` (optional)

---

### Delete Key
**DELETE** `/keys/{keyId}?confirmed=true`

---

## Custom Functions

### List Functions
**GET** `/functions?teamId={id}`

---

### Create Function
**POST** `/functions?teamId={id}`

**Body:** `name`* (not a JS reserved word), `description`*, `code`

---

### Validate Function Code
**POST** `/functions/eval?teamId={id}`

**Body:** `{ code: string }`

**Response:** `{ success: boolean, error?: string }`

---

### Get Function
**GET** `/functions/{functionId}`

Includes `scenarios` array showing which scenarios use it.

---

### Update Function
**PATCH** `/functions/{functionId}`

**Body:** `description`, `code` (name cannot be changed)

---

### Delete Function
**DELETE** `/functions/{functionId}?confirmed=true`

---

### Function History
**GET** `/functions/{functionId}/history?teamId={id}`

**Response:** `{ functionHistory: [{ id, previousCode, updatedAt, updatedBy }] }`

---

## Analytics

### Get Organization Analytics
**GET** `/analytics/{organizationId}`

**Requires:** Enterprise plan + Owner role.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `teamId` | integer or array | Filter by team(s) |
| `folderId` | integer or array | Filter by folder(s) |
| `status` | string or array | `active`, `inactive`, `invalid` |
| `timeframe[dateFrom]` | datetime | ISO 8601, default: 1 year ago |
| `timeframe[dateTo]` | datetime | ISO 8601, default: today |
| `pg[*]` | various | Pagination and sorting |

**Sort options:** name, teamName, status, operations, executions, errors, errorRate, executionsChange, operationsChange, errorsChange, errorRateChange

**Response:**
```json
{
  "total": { "executions", "operations", "centicredits", "errors", "errorRate", "...Change%" },
  "analytics": [{ "imtId", "id", "name", "status", "teamId", "teamName", "...metrics" }],
  "pg": { "last", "showLast", "sortBy", "sortDir", "limit", "offset", "totalCount" }
}
```

Data retention: 1 year maximum.

---

## Audit Logs

### List Organization Audit Logs
**GET** `/audit-logs/organization/{organizationId}`

**Requires:** Admin or Owner role.

**Query:** `team`, `dateFrom` (YYYY-MM-DD), `dateTo`, `event`, `author`, `pg[*]`

**Response:** `{ auditLogs: [{ uuid, createdAt, triggeredAt, organizationId, organization, eventName, team, actor, targetId, version }] }`

---

### Get Org Audit Log Filters
**GET** `/audit-logs/organization/{organizationId}/filters`

**Response:** `{ users: [...], teams: [...], events: [...] }`

---

### List Team Audit Logs
**GET** `/audit-logs/team/{teamId}`

**Requires:** Team Admin role.

---

### Get Team Audit Log Filters
**GET** `/audit-logs/team/{teamId}/filters`

---

### Get Audit Log Detail
**GET** `/audit-logs/{organizationId}/{uuid}`

---

## Users

### List Users
**GET** `/users`

**Query:** `organizationId`, `teamId`, `name`, `email`, `teamRoleId`, `organizationRoleId`, `tfaStatus` (0/1/2), `cols[]`, `pg[*]`

---

### Update User
**PATCH** `/users/{userId}`

**Body:** `name`, `language`, `timezoneId`, `localeId`, `countryId`

---

### Update User Email
**PUT** `/users/{userId}/attributes/email`

**Body:** `currentEmailAddress`*, `newEmailAddress`*, `currentPassword`*

---

### Update User Password
**PUT** `/users/{userId}/attributes/password`

**Body:** `currentPassword`*, `newPassword1`*, `newPassword2`*

---

### Password Reset
**POST** `/users/password-reset-demand` — Body: `{ email: string }`
**GET** `/users/password-reset?hash={hash}` — Set reset session
**POST** `/users/password-reset` — Body: `{ newPassword1, newPassword2 }`

---

### Delete Current User
**DELETE** `/users`

**Body:** `deleteConnections`, `currentPassword`, `tfaCode`

---

## Notifications

### List Notifications
**GET** `/notifications`

**Query:** `unreadOnly`, `imtZoneId`, `pg[*]`

**Scope:** `notifications:read`

---

### Get Notification
**GET** `/notifications/{notificationId}?imtZoneId={id}`

---

### Mark All as Read
**POST** `/notifications/mark-as-read?ids=all&imtZoneId={id}`

---

### Delete Notifications
**DELETE** `/notifications?imtZoneId={id}`

**Body:** `{ ids: string[] }`

---

## Error Codes

| Code | Meaning |
|------|---------|
| 400 | Bad Request — invalid parameters |
| 401 | Unauthorized — missing or invalid token |
| 403 | Forbidden — insufficient permissions/scope |
| 404 | Not Found |
| 409 | Conflict |
| 422 | Unprocessable Entity |
| 429 | Rate Limited |
| 500 | Internal Server Error |

---

## Notes

- Endpoint paths are **case-sensitive**
- Pagination uses `pg[offset]`/`pg[limit]` for offset-based and `pg[last]` for cursor-based
- `confirmed=true` is required for destructive operations on resources used by active scenarios
- Variable types: `1` = number, `2` = string, `3` = boolean, `4` = date
- Run scenario `status` codes: `1` = success, `2` = warning, `3` = error
- Analytics data is only available on Enterprise plans
