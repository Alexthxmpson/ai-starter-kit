# Resend API — Technical Documentation

## Overview

Resend is a transactional email API built for developers. It focuses on simplicity, reliability, and developer experience. Resend provides a clean REST API, official SDKs, domain verification, audience management, broadcast campaigns, and deep integration with React Email for building HTML emails as JSX components.

It is designed as a direct alternative to SendGrid, Mailgun, and Postmark — optimized for product teams who send transactional emails (password resets, order confirmations, notifications) and marketing emails (newsletters, drip campaigns).

---

## Authentication

All requests require an API key passed as a Bearer token in the Authorization header.

```
Authorization: Bearer re_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

API keys are created in the Resend dashboard under API Keys. Keys can be scoped to specific domains or given full access.

```bash
curl -X POST https://api.resend.com/emails \
  -H "Authorization: Bearer re_xxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "from": "hello@yourdomain.com",
    "to": ["user@example.com"],
    "subject": "Welcome aboard",
    "html": "<p>Thanks for signing up!</p>"
  }'
```

---

## Environment Variable

```bash
RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Base URL

```
https://api.resend.com
```

---

## Core Endpoints

### Emails

#### Send Email
```
POST /emails
```

| Parameter    | Type            | Required | Description                                              |
|--------------|-----------------|----------|----------------------------------------------------------|
| from         | string          | Yes      | Sender address — must be from a verified domain          |
| to           | string[]        | Yes      | Array of recipient email addresses (up to 50)            |
| subject      | string          | Yes      | Email subject line                                       |
| html         | string          | No*      | HTML body of the email                                   |
| text         | string          | No*      | Plain text body (recommended alongside HTML)             |
| replyTo      | string          | No       | Reply-to address                                         |
| cc           | string[]        | No       | CC recipients                                            |
| bcc          | string[]        | No       | BCC recipients                                           |
| attachments  | object[]        | No       | Array of attachment objects (see below)                  |
| headers      | object          | No       | Custom email headers as key-value pairs                  |
| tags         | object[]        | No       | Array of `{ name, value }` tag objects for tracking      |
| scheduledAt  | string (ISO 8601) | No     | Schedule email for future delivery                       |

*Either `html` or `text` is required.

**Response:**
```json
{
  "id": "49a3999c-0ce1-4ea6-ab68-b08a9f49c2db"
}
```

---

#### Retrieve Email Status
```
GET /emails/{id}
```

Returns full email details including delivery status.

**Response:**
```json
{
  "id": "49a3999c-0ce1-4ea6-ab68-b08a9f49c2db",
  "object": "email",
  "to": ["user@example.com"],
  "from": "hello@yourdomain.com",
  "subject": "Welcome aboard",
  "created_at": "2024-01-10T14:00:00.000Z",
  "last_event": "delivered"
}
```

---

#### Update Scheduled Email
```
PATCH /emails/{id}
```

Update the `scheduledAt` time of an email that has not yet been sent.

```json
{
  "scheduledAt": "2024-02-01T09:00:00.000Z"
}
```

---

#### Cancel Scheduled Email
```
POST /emails/cancel
```

Cancel a scheduled email before it is sent.

```json
{
  "id": "49a3999c-0ce1-4ea6-ab68-b08a9f49c2db"
}
```

---

#### Batch Send (up to 100 emails)
```
POST /emails/batch
```

Send up to 100 individual emails in a single API call. Each item in the array accepts the same parameters as `POST /emails`.

```json
[
  {
    "from": "hello@yourdomain.com",
    "to": ["user1@example.com"],
    "subject": "Your invoice #1001",
    "html": "<p>Please find your invoice attached.</p>"
  },
  {
    "from": "hello@yourdomain.com",
    "to": ["user2@example.com"],
    "subject": "Your invoice #1002",
    "html": "<p>Please find your invoice attached.</p>"
  }
]
```

**Response:**
```json
{
  "data": [
    { "id": "aaaa-1111" },
    { "id": "bbbb-2222" }
  ]
}
```

---

### Domains

#### List Verified Domains
```
GET /domains
```

Returns all domains associated with the account and their verification status.

#### Add Domain
```
POST /domains
```

```json
{
  "name": "yourdomain.com",
  "region": "us-east-1"
}
```

Returns DNS records you must add to your domain registrar to verify ownership (SPF, DKIM, DMARC).

#### Remove Domain
```
DELETE /domains/{id}
```

Permanently removes a domain. Emails from that domain will fail after removal.

---

### Audiences (Contact Lists)

#### List Audiences
```
GET /audiences
```

#### Create Audience
```
POST /audiences
```

```json
{
  "name": "Newsletter Subscribers"
}
```

#### Add Contact to Audience
```
POST /audiences/{audience_id}/contacts
```

```json
{
  "email": "subscriber@example.com",
  "first_name": "Jane",
  "last_name": "Doe",
  "unsubscribed": false
}
```

---

### Broadcasts (Email Campaigns)

#### List Broadcasts
```
GET /broadcasts
```

#### Create Broadcast
```
POST /broadcasts
```

```json
{
  "audience_id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
  "from": "hello@yourdomain.com",
  "subject": "Our monthly newsletter",
  "html": "<h1>This month in our product</h1><p>...</p>",
  "name": "February 2026 Newsletter"
}
```

---

## Email Content

### HTML vs Plain Text

Always provide both `html` and `text` for maximum compatibility:
- `html` — Renders in modern email clients.
- `text` — Fallback for plain text clients, improves deliverability, required by some spam filters.

```json
{
  "html": "<h1>Welcome!</h1><p>Thanks for joining.</p>",
  "text": "Welcome!\n\nThanks for joining."
}
```

### Attachments

Attachments are base64-encoded file contents.

```json
{
  "attachments": [
    {
      "filename": "invoice.pdf",
      "content": "JVBERi0xLjQKJeLjz9MK...",
      "content_type": "application/pdf"
    }
  ]
}
```

- `filename` — Name shown to recipient.
- `content` — Base64-encoded file content.
- `content_type` — MIME type (e.g. `application/pdf`, `image/png`).

### Tags

Tags allow you to filter and group emails in the Resend dashboard and webhooks.

```json
{
  "tags": [
    { "name": "category", "value": "password_reset" },
    { "name": "user_id", "value": "usr_12345" }
  ]
}
```

### Scheduling

Set `scheduledAt` to an ISO 8601 datetime string to send an email in the future. Minimum: 5 minutes from now.

```json
{
  "scheduledAt": "2026-03-01T09:00:00.000Z"
}
```

---

## Webhooks

Resend sends HTTP POST events to your configured webhook URL when email lifecycle events occur.

| Event               | Triggered when                                    |
|---------------------|---------------------------------------------------|
| `email.sent`        | Email successfully submitted for delivery         |
| `email.delivered`   | Email confirmed delivered to recipient mailbox    |
| `email.opened`      | Recipient opened the email (requires tracking pixel) |
| `email.clicked`     | Recipient clicked a tracked link                  |
| `email.bounced`     | Delivery failed permanently (hard bounce)         |
| `email.complained`  | Recipient marked email as spam                    |

### Webhook Payload Example

```json
{
  "type": "email.delivered",
  "created_at": "2026-02-27T12:00:00.000Z",
  "data": {
    "email_id": "49a3999c-0ce1-4ea6-ab68-b08a9f49c2db",
    "from": "hello@yourdomain.com",
    "to": ["user@example.com"],
    "subject": "Welcome aboard"
  }
}
```

Configure webhook URLs in the Resend dashboard under Webhooks. Resend signs webhook payloads — verify the `Resend-Signature` header to confirm authenticity.

---

## React Email Integration

React Email is a library of unstyled, accessible JSX components for building HTML emails. Resend maintains it as a companion library.

```bash
npm install @react-email/components react react-dom
```

```jsx
import { Html, Head, Body, Container, Text, Button } from '@react-email/components';

export function WelcomeEmail({ name }) {
  return (
    <Html>
      <Head />
      <Body style={{ fontFamily: 'sans-serif' }}>
        <Container>
          <Text>Hello {name}, welcome to our platform!</Text>
          <Button href="https://yourapp.com/dashboard">Go to Dashboard</Button>
        </Container>
      </Body>
    </Html>
  );
}
```

Render to HTML string:
```javascript
import { render } from '@react-email/render';
import { WelcomeEmail } from './emails/WelcomeEmail';

const html = render(<WelcomeEmail name="Jane" />);
await resend.emails.send({ from: '...', to: '...', subject: '...', html });
```

---

## Node.js SDK

```bash
npm install resend
```

```javascript
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

// Send email
const { data, error } = await resend.emails.send({
  from: 'hello@yourdomain.com',
  to: ['user@example.com'],
  subject: 'Your password reset link',
  html: '<p>Click <a href="https://yourapp.com/reset?token=abc">here</a> to reset your password.</p>',
  text: 'Reset your password: https://yourapp.com/reset?token=abc',
});

if (error) {
  console.error('Failed to send:', error);
} else {
  console.log('Sent with ID:', data.id);
}
```

---

## Python SDK

```bash
pip install resend
```

```python
import resend
import os

resend.api_key = os.environ['RESEND_API_KEY']

params = {
  "from": "hello@yourdomain.com",
  "to": ["user@example.com"],
  "subject": "Order Confirmed",
  "html": "<p>Your order <strong>#10045</strong> has been confirmed.</p>",
  "text": "Your order #10045 has been confirmed."
}

email = resend.Emails.send(params)
print(email["id"])
```

---

## Error Handling

Resend returns standard HTTP status codes and a JSON error body.

| HTTP Status | Meaning                                         |
|-------------|-------------------------------------------------|
| 200/201     | Success                                         |
| 400         | Bad request — invalid or missing parameters     |
| 401         | Unauthorized — invalid or missing API key       |
| 403         | Forbidden — domain not verified or key scoping  |
| 404         | Resource not found                              |
| 422         | Unprocessable — validation error                |
| 429         | Rate limit exceeded                             |
| 500         | Internal server error                           |

```json
{
  "statusCode": 422,
  "name": "validation_error",
  "message": "The 'from' address is not verified."
}
```

---

## Rate Limits

- Default: 10 requests/second.
- Batch endpoint: counts as one request but sends up to 100 emails.
- Rate limit headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.

---

## Domain Setup (Required)

To send emails from your own domain you must verify it:
1. Add the domain in the Resend dashboard.
2. Add the provided SPF, DKIM, and DMARC DNS records to your domain registrar.
3. Wait for propagation (typically 24–48 hours, often faster).
4. Domain status changes to "Verified" in the dashboard.

---

## Useful Links

- Dashboard: https://resend.com/overview
- API reference: https://resend.com/docs/api-reference/introduction
- React Email: https://react.email
- Node.js SDK: https://resend.com/docs/send-with-nodejs
- Python SDK: https://resend.com/docs/send-with-python
- Webhooks: https://resend.com/docs/dashboard/webhooks/introduction
