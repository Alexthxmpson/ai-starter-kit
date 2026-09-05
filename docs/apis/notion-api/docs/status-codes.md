# Status codes

**Source:** https://developers.notion.com/reference/status-codes
**Date:** 2026-03-01

---

Responses from the API use HTTP response codes to indicate general classes of success and error.

## Success codes

| HTTP status code | Description |
|------------------|-------------|
| 200 | Notion successfully processed the request. |

## Error codes

Error responses contain more detail about the error in the response body, in the `"code"` and `"message"` properties.

| HTTP status code | `"code"` | Description | `"message"` example |
|------------------|----------|-------------|---------------------|
| 400 | `"invalid_json"` | The request body could not be decoded as JSON. | `"Error parsing JSON body."` |
| 400 | `"invalid_request_url"` | The request URL is not valid. | `"Invalid request URL"` |
| 400 | `"invalid_request"` | This request is not supported. | `"Unsupported request: <request name>."` |
| 400 | `"invalid_grant"` | The provided authorization grant (e.g., authorization code, resource owner credentials) or refresh token is invalid, expired, revoked, does not match the redirection URI used in the authorization request, or was issued to another client. See OAuth 2.0 documentation for more information. | `"Invalid code: this code has been revoked."` |
| 400 | `"validation_error"` | The request body does not match the schema for the expected parameters. Check the `"message"` property for more details. | `"body failed validation: body.properties should be defined, instead was undefined."` |
| 400 | `"missing_version"` | The request is missing the required `Notion-Version` header. See Versioning. | `"Notion-Version header failed validation: Notion-Version header should be defined, instead was undefined."` |
| 401 | `"unauthorized"` | The bearer token is not valid. | `"API token is invalid."` |
| 403 | `"restricted_resource"` | Given the bearer token used, the client doesn't have permission to perform this operation. | `"API token does not have access to this resource."` |
| 404 | `"object_not_found"` | Given the bearer token used, the resource does not exist. This error can also indicate that the resource has not been shared with owner of the bearer token. | `"Could not find database with ID: be907abe-510e-4116-a3d1-7ea71018c06f. Make sure the relevant pages and databases are shared with your integration."` |
| 409 | `"conflict_error"` | The transaction could not be completed, potentially due to a data collision. Make sure the parameters are up to date and try again. Also used when File Upload third-party data storage provider has downtime. | `"Conflict occurred while saving. Please try again."` |
| 429 | `"rate_limited"` | This request exceeds the number of requests allowed. Slow down and try again. | `"You have been rate limited. Please try again in a few minutes."` |
| 500 | `"internal_server_error"` | An unexpected error occurred. Reach out to Notion support. | `"Unexpected error occurred."` |
| 502 | `"bad_gateway"` | Notion encountered an issue while attempting to complete this request (e.g., failed to establish a connection with an upstream server). Please try again. | `"Bad Gateway"` |
| 503 | `"service_unavailable"` | Notion is unavailable. This can occur when the time to respond to a request takes longer than 60 seconds, the maximum request timeout. Please try again later. | `"Notion is unavailable, please try again later."` |
| 503 | `"database_connection_unavailable"` | Notion's database is unavailable or is not in a state that can be queried. Please try again later. | `"Notion is unavailable, please try again later."` |
| 504 | `"gateway_timeout"` | Notion timed out while attempting to complete this request. Please try again later. | `"Gateway Timeout"` |
