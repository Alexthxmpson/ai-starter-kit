# Twilio API — Full Technical Reference

**Source:** https://www.twilio.com/docs/sms/api | https://www.twilio.com/docs/whatsapp/api | https://www.twilio.com/docs/voice/api
**Date Compiled:** 2026-02-27

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Base URL & Request Format](#2-base-url--request-format)
3. [SMS API — Messages Resource](#3-sms-api--messages-resource)
4. [SMS Webhooks](#4-sms-webhooks)
5. [WhatsApp API](#5-whatsapp-api)
6. [Voice API — Calls Resource](#6-voice-api--calls-resource)
7. [TwiML Reference](#7-twiml-reference)
8. [Verify API (OTP)](#8-verify-api-otp)
9. [Conversations API](#9-conversations-api)
10. [Phone Number Provisioning](#10-phone-number-provisioning)
11. [Error Codes](#11-error-codes)
12. [Pricing](#12-pricing)

---

## 1. Authentication

### Account SID + Auth Token (HTTP Basic Auth)

Every request to the Twilio API requires HTTP Basic Authentication using your Account SID as the username and your Auth Token as the password.

```
Username: ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   (Account SID)
Password: your_auth_token
```

**cURL example:**
```bash
curl -X POST https://api.twilio.com/2010-04-01/Accounts/ACxxxxx/Messages.json \
  -u "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:your_auth_token" \
  -d "To=%2B14155551234" \
  -d "From=%2B14155550000" \
  -d "Body=Hello+World"
```

### API Keys (Recommended for Production)

API Keys are scoped credentials that do not expose your master Auth Token. Create them in the Twilio Console under Settings > API Keys.

```
Username: SKxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   (API Key SID)
Password: your_api_key_secret
```

API Keys can be restricted to specific subaccounts or given read-only scopes, making them safer for deployment.

### Environment Variables (Best Practice)

```bash
export TWILIO_ACCOUNT_SID="ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export TWILIO_AUTH_TOKEN="your_auth_token"
```

```javascript
// Node.js
const client = require('twilio')(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);
```

---

## 2. Base URL & Request Format

```
Base URL:  https://api.twilio.com/2010-04-01
```

- All API requests must use **HTTPS**.
- Request bodies use `application/x-www-form-urlencoded` format (NOT JSON).
- Responses are returned as **JSON** (append `.json` to the resource path).
- Phone numbers must use **E.164 format**: `+[country code][number]` (e.g., `+14155551234`).

### Request Structure

```
POST /2010-04-01/Accounts/{AccountSid}/Messages.json
Host: api.twilio.com
Authorization: Basic base64(AccountSid:AuthToken)
Content-Type: application/x-www-form-urlencoded

To=%2B14155551234&From=%2B14155550000&Body=Hello
```

---

## 3. SMS API — Messages Resource

### Endpoint

```
POST https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages.json
```

### Request Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `To` | string | Yes | Destination phone number in E.164 format |
| `From` | string | Yes* | Twilio phone number or Messaging Service SID to send from |
| `MessagingServiceSid` | string | Yes* | Use instead of `From` to leverage a Messaging Service |
| `Body` | string | Yes** | Text body of the message (up to 1,600 characters) |
| `MediaUrl` | string | No | URL(s) of media to include (MMS). Up to 10 URLs |
| `StatusCallback` | string | No | Webhook URL Twilio posts status updates to |
| `ApplicationSid` | string | No | SID of a TwiML Application; overrides StatusCallback |
| `MaxPrice` | decimal | No | Maximum price to charge for this message (in USD) |
| `ProvideFeedback` | boolean | No | Whether to confirm delivery with Twilio |
| `Attempt` | integer | No | Number of attempts already made; used for retry tracking |
| `ValidityPeriod` | integer | No | How long (seconds) to retry if message fails. Max 14400 |
| `ForceDelivery` | boolean | No | Reserved |
| `ContentRetention` | string | No | `retain` or `discard` |
| `AddressRetention` | string | No | `retain` or `obfuscate` |
| `SmartEncoded` | boolean | No | Use smart encoding (replaces Unicode with GSM-7) |
| `PersistentAction` | string | No | Actions to take during the message lifecycle |
| `ShortenUrls` | boolean | No | URL shortening |
| `ScheduleType` | string | No | `fixed` — required for scheduled messages |
| `SendAt` | datetime | No | ISO 8601 datetime for scheduled send |
| `SendAsMms` | boolean | No | Force SMS to send as MMS |
| `ContentSid` | string | No | SID of a Content API template |
| `ContentVariables` | string | No | JSON of variable substitutions for Content templates |
| `RiskCheck` | string | string | `enable` or `disable` fraud detection |

*Either `From` or `MessagingServiceSid` is required.
**`Body` is required unless `MediaUrl` or `ContentSid` is provided.

### Response Fields

```json
{
  "sid": "SMxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "date_created": "Thu, 27 Feb 2026 20:22:31 +0000",
  "date_updated": "Thu, 27 Feb 2026 20:22:31 +0000",
  "date_sent": null,
  "account_sid": "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "to": "+14155551234",
  "from": "+14155550000",
  "messaging_service_sid": null,
  "body": "Hello World",
  "status": "queued",
  "num_segments": "1",
  "num_media": "0",
  "direction": "outbound-api",
  "api_version": "2010-04-01",
  "price": null,
  "price_unit": "USD",
  "error_code": null,
  "error_message": null,
  "uri": "/2010-04-01/Accounts/ACxxx/Messages/SMxxx.json",
  "subresource_uris": {
    "media": "/2010-04-01/Accounts/ACxxx/Messages/SMxxx/Media.json"
  }
}
```

### Message Status Values

| Status | Meaning |
|---|---|
| `queued` | Message accepted by Twilio and waiting to send |
| `sending` | In the process of being dispatched |
| `sent` | Sent to upstream carrier |
| `delivered` | Confirmed delivery by carrier (where supported) |
| `undelivered` | Carrier reported delivery failure |
| `failed` | Message failed to send (no charge) |
| `canceled` | Scheduled message was canceled |

### Message Direction Values

| Direction | Meaning |
|---|---|
| `inbound` | Received by your Twilio number |
| `outbound-api` | Sent via REST API |
| `outbound-call` | Sent during a voice call |
| `outbound-reply` | Auto-reply to an inbound message |

### Fetch a Specific Message

```
GET https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages/{MessageSid}.json
```

### List Messages

```
GET https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages.json
```

Optional query parameters: `To`, `From`, `DateSent` (exact), `DateSent>` (after), `DateSent<` (before), `PageSize` (max 1000), `Page`.

### Delete a Message

```
DELETE https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages/{MessageSid}.json
```

### Redact Message Body (Update)

```
POST https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages/{MessageSid}.json
Body=
```

Sending an empty `Body` redacts the message content.

### Full cURL Example — Send SMS

```bash
curl -X POST https://api.twilio.com/2010-04-01/Accounts/ACxxxxxxxx/Messages.json \
  -u "ACxxxxxxxx:your_auth_token" \
  --data-urlencode "Body=Your verification code is 123456" \
  --data-urlencode "From=+14155550000" \
  --data-urlencode "To=+14155551234" \
  --data-urlencode "StatusCallback=https://yourapp.com/sms/status"
```

### Node.js SDK Example

```javascript
const twilio = require('twilio');
const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

async function sendSMS() {
  const message = await client.messages.create({
    body: 'Your order #1234 has shipped!',
    from: '+14155550000',
    to: '+14155551234',
    statusCallback: 'https://yourapp.com/sms/status'
  });

  console.log(message.sid);    // SMxxxxxxxxxxxxxxxxxxxxxxxx
  console.log(message.status); // queued
}

sendSMS();
```

### Send MMS (with Media)

```javascript
const message = await client.messages.create({
  body: 'Check out this image!',
  from: '+14155550000',
  to: '+14155551234',
  mediaUrl: ['https://yourapp.com/images/receipt.png']
});
```

---

## 4. SMS Webhooks

### Incoming Message Webhook

When a message arrives at your Twilio number, Twilio sends an HTTP POST to your configured webhook URL with `application/x-www-form-urlencoded` body.

**Configure webhook URL:** Twilio Console > Phone Numbers > [Your Number] > Messaging > "A Message Comes In"

### Incoming Message Webhook Parameters

| Parameter | Description |
|---|---|
| `MessageSid` | Unique SID for this message |
| `SmsSid` | Same as MessageSid (legacy field) |
| `AccountSid` | Your Twilio Account SID |
| `MessagingServiceSid` | If used via a Messaging Service |
| `From` | Sender's phone number (E.164) |
| `To` | Your Twilio phone number |
| `Body` | Text content of the message |
| `NumMedia` | Number of media attachments |
| `MediaUrl0` | URL of first media item (if any) |
| `MediaContentType0` | MIME type of first media item |
| `FromCity` | Sender's city (best effort) |
| `FromState` | Sender's state/region |
| `FromZip` | Sender's postal code |
| `FromCountry` | Sender's country (ISO 3166-1 alpha-2) |
| `ToCity` | City of your Twilio number |
| `ToState` | State of your Twilio number |
| `ToZip` | Postal code of your Twilio number |
| `ToCountry` | Country of your Twilio number |

### Replying to an Incoming SMS (TwiML)

Your webhook handler must return TwiML in the HTTP response:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Message>Thanks for texting us! We'll reply shortly.</Message>
</Response>
```

**Express.js example:**
```javascript
const express = require('express');
const { twiml: { MessagingResponse } } = require('twilio');

const app = express();
app.use(express.urlencoded({ extended: false }));

app.post('/sms/incoming', (req, res) => {
  const twiml = new MessagingResponse();
  twiml.message(`You said: ${req.body.Body}`);

  res.type('text/xml');
  res.send(twiml.toString());
});
```

### Status Callback Webhook Parameters

| Parameter | Description |
|---|---|
| `MessageSid` | The message SID |
| `MessageStatus` | Current status: `sent`, `delivered`, `undelivered`, `failed` |
| `SmsSid` | Legacy alias for MessageSid |
| `SmsStatus` | Legacy alias for MessageStatus |
| `To` | Destination number |
| `From` | Sending number |
| `ErrorCode` | Error code if delivery failed (e.g., 30001) |
| `RawDlrDoneDate` | Carrier-provided delivery timestamp |

### Validating Twilio Webhook Signatures

Twilio signs every webhook request using HMAC-SHA1. Validate the `X-Twilio-Signature` header to confirm requests come from Twilio:

```javascript
const twilio = require('twilio');

function validateTwilioRequest(req, res, next) {
  const twilioSignature = req.headers['x-twilio-signature'];
  const url = `https://yourapp.com${req.originalUrl}`;
  const params = req.body;
  const authToken = process.env.TWILIO_AUTH_TOKEN;

  const isValid = twilio.validateRequest(authToken, twilioSignature, url, params);

  if (isValid) {
    next();
  } else {
    res.status(403).send('Forbidden');
  }
}
```

---

## 5. WhatsApp API

Twilio's WhatsApp API uses the same Programmable Messaging API endpoint but prefixes phone numbers with `whatsapp:`.

### Endpoint

```
POST https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages.json
```

### Key Difference from SMS

```
From: whatsapp:+14155550000
To:   whatsapp:+14155551234
```

Your `From` number must be a WhatsApp-enabled Twilio number or Messaging Service.

### Send a Freeform WhatsApp Message (within 24-hour window)

```bash
curl -X POST https://api.twilio.com/2010-04-01/Accounts/ACxxxxxxxx/Messages.json \
  -u "ACxxxxxxxx:your_auth_token" \
  --data-urlencode "From=whatsapp:+14155550000" \
  --data-urlencode "To=whatsapp:+14155551234" \
  --data-urlencode "Body=Hello! Your package is on its way."
```

```javascript
const message = await client.messages.create({
  from: 'whatsapp:+14155550000',
  to: 'whatsapp:+14155551234',
  body: 'Hello! Your package is on its way.'
});
```

### WhatsApp 24-Hour Customer Service Window

- A customer service window opens when a user messages your WhatsApp number.
- Within this 24-hour window, you can send freeform text and media.
- **Outside** this window, you must use approved Message Templates.

### Sending WhatsApp Media (within session window)

```javascript
const message = await client.messages.create({
  from: 'whatsapp:+14155550000',
  to: 'whatsapp:+14155551234',
  body: 'Here is your receipt:',
  mediaUrl: ['https://yourapp.com/receipts/1234.pdf']
});
```

Supported media types: images (JPEG, PNG), PDFs, audio (MP3, OGG), video (MP4), documents.

### WhatsApp Message Templates (Business-Initiated Notifications)

Templates must be pre-approved by Meta/WhatsApp. Create them using the Twilio Content Template Builder.

**Content API Endpoint:**
```
POST https://content.twilio.com/v1/Content
```

**Send a Template Message:**
```javascript
const message = await client.messages.create({
  from: 'whatsapp:+14155550000',
  to: 'whatsapp:+14155551234',
  contentSid: 'HXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
  contentVariables: JSON.stringify({
    '1': 'John',
    '2': 'your order #5678',
    '3': 'January 31st'
  }),
  messagingServiceSid: 'MGxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
});
```

### Content API — Create a Template

```
POST https://content.twilio.com/v1/Content
Authorization: Basic base64(AccountSid:AuthToken)
Content-Type: application/json
```

```json
{
  "friendly_name": "order_shipped_notification",
  "language": "en",
  "variables": {
    "1": "Customer name",
    "2": "Order reference",
    "3": "Delivery date"
  },
  "types": {
    "twilio/text": {
      "body": "Hi {{1}}, your {{2}} has shipped and will arrive by {{3}}."
    }
  }
}
```

### Content API — List Templates

```
GET https://content.twilio.com/v1/Content
```

### Content API — Fetch a Template

```
GET https://content.twilio.com/v1/Content/{ContentSid}
```

### Template Approval Status Values

| Status | Meaning |
|---|---|
| `pending` | Submitted to WhatsApp for review |
| `approved` | Approved; ready to send |
| `rejected` | Rejected by WhatsApp |

Template approval typically takes 5 minutes to 24 hours.

### WhatsApp Incoming Message Webhook

Same parameters as SMS webhooks, but `From` and `To` include the `whatsapp:` prefix.

---

## 6. Voice API — Calls Resource

### Endpoint — Make an Outbound Call

```
POST https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Calls.json
```

### Request Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `To` | string | Yes | Phone number, SIP address, or client identifier to call |
| `From` | string | Yes | Caller ID — must be a Twilio number or verified caller ID |
| `Url` | string | Yes* | URL Twilio fetches TwiML from to control the call |
| `ApplicationSid` | string | Yes* | TwiML Application SID (use instead of `Url`) |
| `Twiml` | string | Yes* | Raw TwiML string to execute (use instead of `Url`) |
| `Method` | string | No | HTTP method for TwiML fetch: `GET` or `POST` (default: POST) |
| `FallbackUrl` | string | No | URL to fetch TwiML if primary URL fails |
| `FallbackMethod` | string | No | HTTP method for fallback URL |
| `StatusCallback` | string | No | URL for call status updates |
| `StatusCallbackMethod` | string | No | HTTP method for status callback |
| `StatusCallbackEvent` | list | No | Events to send: `initiated`, `ringing`, `answered`, `completed` |
| `Timeout` | integer | No | Seconds to wait for answer (default: 60, max: 600) |
| `Record` | boolean | No | Record the call (default: false) |
| `RecordingChannels` | string | No | `mono` or `dual` (default: mono) |
| `RecordingStatusCallback` | string | No | URL for recording status updates |
| `MachineDetection` | string | No | `Enable` or `DetectMessageEnd` for AMD |
| `AsyncAmd` | boolean | No | Asynchronous answering machine detection |
| `AsyncAmdStatusCallback` | string | No | Webhook for async AMD result |
| `SipAuthUsername` | string | No | SIP authentication username |
| `SipAuthPassword` | string | No | SIP authentication password |
| `TimeLimit` | integer | No | Max call duration in seconds (default: 14400 / 4 hours) |
| `Trim` | string | No | `trim-silence` or `do-not-trim` for recordings |
| `CallerId` | string | No | Caller ID to use for the call |
| `CallReason` | string | No | Caller's reason for initiating the call |
| `SendDigits` | string | No | DTMF digits to send when call connects |
| `IfMachine` | string | No | Behavior if answering machine detected: `Continue`, `Hangup` |

*One of `Url`, `ApplicationSid`, or `Twiml` is required.

### Response Fields

```json
{
  "sid": "CAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "date_created": "Thu, 27 Feb 2026 20:00:00 +0000",
  "date_updated": "Thu, 27 Feb 2026 20:00:00 +0000",
  "parent_call_sid": null,
  "account_sid": "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "to": "+14155551234",
  "to_formatted": "(415) 555-1234",
  "from": "+14155550000",
  "from_formatted": "(415) 555-0000",
  "phone_number_sid": "PNxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "status": "queued",
  "start_time": null,
  "end_time": null,
  "duration": null,
  "price": null,
  "price_unit": "USD",
  "direction": "outbound-api",
  "answered_by": null,
  "api_version": "2010-04-01",
  "annotation": null,
  "forwarded_from": null,
  "group_sid": null,
  "caller_name": null,
  "queue_time": "0",
  "trunk_sid": null,
  "uri": "/2010-04-01/Accounts/ACxxx/Calls/CAxxx.json",
  "subresource_uris": {}
}
```

### Call Status Values

| Status | Meaning |
|---|---|
| `queued` | Ready to dial |
| `ringing` | Destination is ringing |
| `in-progress` | Call is active |
| `canceled` | Canceled before answer |
| `completed` | Call finished normally |
| `busy` | Destination returned busy |
| `no-answer` | Timed out without answer |
| `failed` | Could not connect |

### Node.js SDK — Make a Call

```javascript
const call = await client.calls.create({
  url: 'https://yourapp.com/voice/twiml',
  to: '+14155551234',
  from: '+14155550000',
  record: true,
  statusCallback: 'https://yourapp.com/voice/status',
  statusCallbackEvent: ['initiated', 'answered', 'completed']
});

console.log(call.sid); // CAxxxxxxxxxxxxxxxxxx
```

### Make a Call with Inline TwiML

```javascript
const call = await client.calls.create({
  twiml: '<Response><Say>Hello, your appointment is tomorrow at 10am.</Say></Response>',
  to: '+14155551234',
  from: '+14155550000'
});
```

### Fetch a Call

```
GET https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Calls/{CallSid}.json
```

### List Calls

```
GET https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Calls.json
```

Optional filters: `To`, `From`, `Status`, `StartTime`, `EndTime`, `PageSize`.

### Modify an In-Progress Call

```
POST https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Calls/{CallSid}.json
```

```javascript
// Redirect a live call to new TwiML
await client.calls(callSid).update({
  url: 'https://yourapp.com/voice/new-twiml',
  method: 'POST'
});

// Hang up a call
await client.calls(callSid).update({ status: 'completed' });
```

---

## 7. TwiML Reference

TwiML (Twilio Markup Language) is XML that controls how Twilio handles calls and messages.

### Voice TwiML Verbs

#### `<Say>` — Text-to-Speech

```xml
<Response>
  <Say voice="Polly.Joanna" language="en-US">
    Hello, please press 1 for sales or 2 for support.
  </Say>
</Response>
```

| Attribute | Values | Default | Description |
|---|---|---|---|
| `voice` | `man`, `woman`, `alice`, `Polly.*` | `man` | Voice to use |
| `language` | BCP-47 language tag | `en` | Language and locale |
| `loop` | integer | `1` | Number of times to repeat |

Amazon Polly voices (e.g., `Polly.Joanna`, `Polly.Matthew`) support neural TTS.

#### `<Gather>` — Collect DTMF or Speech Input

```xml
<Response>
  <Gather input="dtmf speech" numDigits="1" timeout="5" action="/ivr/handle-input" method="POST">
    <Say>Press 1 for sales, 2 for support, or say your department name.</Say>
  </Gather>
  <Say>We did not receive your selection. Goodbye.</Say>
</Response>
```

| Attribute | Values | Default | Description |
|---|---|---|---|
| `input` | `dtmf`, `speech`, `dtmf speech` | `dtmf` | Input type |
| `action` | URL | current URL | Webhook to POST gathered input |
| `method` | `GET`, `POST` | `POST` | HTTP method for action |
| `timeout` | integer | `5` | Seconds of silence before timeout |
| `finishOnKey` | string | `#` | Key that ends input |
| `numDigits` | integer | — | Exact number of digits to collect |
| `speechTimeout` | `auto` or integer | — | Seconds of silence after speech |
| `language` | BCP-47 | `en-US` | Speech recognition language |
| `hints` | string | — | Comma-separated speech recognition hints |
| `profanityFilter` | `true`/`false` | `true` | Filter profanity from speech |
| `enhanced` | `true`/`false` | `false` | Use enhanced speech model |

#### `<Play>` — Play an Audio File

```xml
<Response>
  <Play loop="2">https://yourapp.com/audio/hold-music.mp3</Play>
</Response>
```

Supported formats: MP3, WAV, AIFF, GSM, ulaw. Max file size: 40MB.

#### `<Dial>` — Connect to Another Party

```xml
<Response>
  <Dial callerId="+14155550000" record="record-from-answer" timeout="30">
    +14155559999
  </Dial>
</Response>
```

`<Dial>` sub-nouns: `<Number>`, `<Sip>`, `<Client>`, `<Conference>`, `<Queue>`.

**Conference Call:**
```xml
<Response>
  <Dial>
    <Conference startConferenceOnEnter="true" endConferenceOnExit="false">
      MyConferenceRoom
    </Conference>
  </Dial>
</Response>
```

#### `<Record>` — Record Audio

```xml
<Response>
  <Say>Please leave a message after the beep.</Say>
  <Record maxLength="60" transcribe="true" transcribeCallback="/transcription" action="/recording-done" />
</Response>
```

#### `<Redirect>` — Redirect to Another TwiML URL

```xml
<Response>
  <Redirect method="POST">https://yourapp.com/voice/next-step</Redirect>
</Response>
```

#### `<Pause>` — Insert Silence

```xml
<Response>
  <Say>Please hold.</Say>
  <Pause length="3" />
  <Say>Connecting you now.</Say>
</Response>
```

#### `<Hangup>` — End the Call

```xml
<Response>
  <Say>Goodbye!</Say>
  <Hangup />
</Response>
```

### IVR Example — Full Phone Tree

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather input="dtmf" numDigits="1" action="/ivr/department" method="POST" timeout="10">
    <Say voice="Polly.Joanna">
      Welcome to Acme Corporation.
      For Sales, press 1.
      For Support, press 2.
      For Billing, press 3.
      To repeat this menu, press 9.
    </Say>
  </Gather>
  <Redirect>/ivr/welcome</Redirect>
</Response>
```

**Express.js handler for `/ivr/department`:**
```javascript
app.post('/ivr/department', (req, res) => {
  const digit = req.body.Digits;
  const twiml = new VoiceResponse();

  switch (digit) {
    case '1':
      twiml.say('Connecting you to Sales.');
      twiml.dial('+14155551111');
      break;
    case '2':
      twiml.say('Connecting you to Support.');
      twiml.dial('+14155552222');
      break;
    case '3':
      twiml.say('Connecting you to Billing.');
      twiml.dial('+14155553333');
      break;
    default:
      twiml.redirect('/ivr/welcome');
  }

  res.type('text/xml');
  res.send(twiml.toString());
});
```

---

## 8. Verify API (OTP)

### Prerequisites

1. Create a Verify Service in the Twilio Console (or via API).
2. Note the `Verify Service SID` (starts with `VA`).

### Create a Verify Service

```
POST https://verify.twilio.com/v2/Services
```

```bash
curl -X POST https://verify.twilio.com/v2/Services \
  -u "ACxxxxxxxx:your_auth_token" \
  --data-urlencode "FriendlyName=MyApp Verification" \
  --data-urlencode "CodeLength=6"
```

### Step 1 — Send a Verification Code

**Endpoint:**
```
POST https://verify.twilio.com/v2/Services/{ServiceSid}/Verifications
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `To` | string | Yes | Phone number or email to verify (E.164 format) |
| `Channel` | string | Yes | `sms`, `call`, `whatsapp`, `email`, `sna`, `auto` |
| `CustomMessage` | string | No | Custom SMS text (must include `{{code}}` placeholder) |
| `SendDigits` | string | No | DTMF digits to send for call verification |
| `Locale` | string | No | Language code (e.g., `en`, `es`, `fr`) |
| `CustomCode` | string | No | Override the generated OTP with a custom code |
| `Amount` | string | No | Amount for payment channels |
| `PaymentType` | string | No | Payment type for payment channels |
| `RateLimits` | object | No | Custom rate limit configuration |

```bash
curl -X POST https://verify.twilio.com/v2/Services/VAxxxxxxxx/Verifications \
  -u "ACxxxxxxxx:your_auth_token" \
  --data-urlencode "To=+14155551234" \
  --data-urlencode "Channel=sms"
```

**Response:**
```json
{
  "sid": "VExxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "service_sid": "VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "account_sid": "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "to": "+14155551234",
  "channel": "sms",
  "status": "pending",
  "valid": false,
  "date_created": "2026-02-27T20:00:00Z",
  "date_updated": "2026-02-27T20:00:00Z",
  "lookup": { "carrier": { "name": "T-Mobile USA, Inc." } },
  "amount": null,
  "payee": null,
  "send_code_attempts": [{ "time": "2026-02-27T20:00:00Z", "channel": "sms", "attempt_sid": "..." }],
  "url": "https://verify.twilio.com/v2/Services/VAxxx/Verifications/VExxx"
}
```

### Step 2 — Check the Verification Code

**Endpoint:**
```
POST https://verify.twilio.com/v2/Services/{ServiceSid}/VerificationCheck
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `To` | string | Yes | The phone number being verified |
| `Code` | string | Yes | The OTP code the user entered |

```bash
curl -X POST https://verify.twilio.com/v2/Services/VAxxxxxxxx/VerificationCheck \
  -u "ACxxxxxxxx:your_auth_token" \
  --data-urlencode "To=+14155551234" \
  --data-urlencode "Code=123456"
```

**Response:**
```json
{
  "sid": "VExxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "service_sid": "VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "account_sid": "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "to": "+14155551234",
  "channel": "sms",
  "status": "approved",
  "valid": true,
  "date_created": "2026-02-27T20:00:00Z",
  "date_updated": "2026-02-27T20:00:05Z"
}
```

`status` will be `approved` (correct code) or `pending` (wrong code or expired).

### Node.js SDK — Full Verify Flow

```javascript
const client = require('twilio')(accountSid, authToken);
const VERIFY_SERVICE_SID = process.env.TWILIO_VERIFY_SERVICE_SID;

// Step 1: Send OTP
async function sendOTP(phoneNumber) {
  const verification = await client.verify.v2
    .services(VERIFY_SERVICE_SID)
    .verifications.create({ to: phoneNumber, channel: 'sms' });

  return verification.status; // "pending"
}

// Step 2: Verify OTP
async function checkOTP(phoneNumber, code) {
  const check = await client.verify.v2
    .services(VERIFY_SERVICE_SID)
    .verificationChecks.create({ to: phoneNumber, code });

  return check.status === 'approved'; // true or false
}
```

---

## 9. Conversations API

The Conversations API provides a unified messaging layer across SMS, MMS, WhatsApp, Facebook Messenger, and Chat (web/mobile SDK).

### Base URL

```
https://conversations.twilio.com/v1
```

### Create a Conversation

```
POST https://conversations.twilio.com/v1/Conversations
```

```bash
curl -X POST https://conversations.twilio.com/v1/Conversations \
  -u "ACxxxxxxxx:your_auth_token" \
  --data-urlencode "FriendlyName=Customer Support Thread"
```

**Response:**
```json
{
  "sid": "CHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "account_sid": "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "friendly_name": "Customer Support Thread",
  "date_created": "2026-02-27T20:00:00Z",
  "date_updated": "2026-02-27T20:00:00Z",
  "state": "active",
  "attributes": "{}",
  "timers": {},
  "url": "https://conversations.twilio.com/v1/Conversations/CHxxx",
  "links": {
    "participants": "https://conversations.twilio.com/v1/Conversations/CHxxx/Participants",
    "messages": "https://conversations.twilio.com/v1/Conversations/CHxxx/Messages"
  }
}
```

### Add a Participant (SMS)

```
POST https://conversations.twilio.com/v1/Conversations/{ConversationSid}/Participants
```

```javascript
await client.conversations.v1
  .conversations(conversationSid)
  .participants.create({
    'messagingBinding.address': '+14155551234',
    'messagingBinding.proxyAddress': '+14155550000'
  });
```

### Add a Participant (WhatsApp)

```javascript
await client.conversations.v1
  .conversations(conversationSid)
  .participants.create({
    'messagingBinding.address': 'whatsapp:+14155551234',
    'messagingBinding.proxyAddress': 'whatsapp:+14155550000'
  });
```

### Send a Message in a Conversation

```
POST https://conversations.twilio.com/v1/Conversations/{ConversationSid}/Messages
```

```javascript
await client.conversations.v1
  .conversations(conversationSid)
  .messages.create({
    body: 'Hello! How can I assist you today?',
    author: 'support-agent'
  });
```

### Conversations Webhooks

Configure at the Service or Account level to receive events for:
- `onMessageAdded` — new message in a conversation
- `onParticipantAdded` / `onParticipantRemoved`
- `onConversationStateUpdated`
- `onDeliveryUpdated` — delivery status per participant

---

## 10. Phone Number Provisioning

### Search Available Numbers

```
GET https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/AvailablePhoneNumbers/{CountryCode}/Local.json
```

Query parameters: `AreaCode`, `Contains` (pattern match), `SmsEnabled` (boolean), `VoiceEnabled` (boolean), `MmsEnabled` (boolean), `NearLatLong`, `NearNumber`, `Distance`, `InPostalCode`, `InRegion`, `InRateCenter`, `PageSize`.

```bash
# Search for US numbers with SMS + Voice in area code 415
curl "https://api.twilio.com/2010-04-01/Accounts/ACxxxxxxxx/AvailablePhoneNumbers/US/Local.json?AreaCode=415&SmsEnabled=true&VoiceEnabled=true" \
  -u "ACxxxxxxxx:your_auth_token"
```

**Response:**
```json
{
  "available_phone_numbers": [
    {
      "friendly_name": "(415) 555-0001",
      "phone_number": "+14155550001",
      "lata": "722",
      "rate_center": "SNFC CNTRL",
      "latitude": "37.773972",
      "longitude": "-122.431297",
      "region": "CA",
      "postal_code": "94102",
      "iso_country": "US",
      "address_requirements": "none",
      "beta": false,
      "capabilities": {
        "voice": true,
        "SMS": true,
        "MMS": true,
        "fax": false
      }
    }
  ]
}
```

### Buy (Provision) a Phone Number

```
POST https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/IncomingPhoneNumbers.json
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `PhoneNumber` | string | Yes* | E.164 phone number to purchase |
| `AreaCode` | string | Yes* | Area code to search and purchase from (US/CA only) |
| `FriendlyName` | string | No | Display name (up to 64 characters) |
| `SmsUrl` | string | No | Webhook URL for incoming SMS |
| `SmsMethod` | string | No | `GET` or `POST` for SMS webhook |
| `VoiceUrl` | string | No | Webhook URL for incoming calls |
| `VoiceMethod` | string | No | `GET` or `POST` for voice webhook |
| `StatusCallback` | string | No | Webhook for call status changes |
| `VoiceFallbackUrl` | string | No | Fallback URL if VoiceUrl fails |
| `SmsApplicationSid` | string | No | TwiML App SID for SMS handling |
| `VoiceApplicationSid` | string | No | TwiML App SID for voice handling |
| `AddressSid` | string | No | Address SID (required for some countries) |
| `BundleSid` | string | No | Regulatory Bundle SID |

*One of `PhoneNumber` or `AreaCode` is required.

```bash
curl -X POST https://api.twilio.com/2010-04-01/Accounts/ACxxxxxxxx/IncomingPhoneNumbers.json \
  -u "ACxxxxxxxx:your_auth_token" \
  --data-urlencode "PhoneNumber=+14155550001" \
  --data-urlencode "FriendlyName=My App Number" \
  --data-urlencode "SmsUrl=https://yourapp.com/sms/incoming" \
  --data-urlencode "VoiceUrl=https://yourapp.com/voice/incoming"
```

### List Your Phone Numbers

```
GET https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/IncomingPhoneNumbers.json
```

### Release a Phone Number

```
DELETE https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/IncomingPhoneNumbers/{PhoneNumberSid}.json
```

---

## 11. Error Codes

### HTTP Status Codes

| Code | Meaning |
|---|---|
| `200` | Success |
| `201` | Created |
| `204` | No Content (successful DELETE) |
| `400` | Bad Request — invalid parameters |
| `401` | Unauthorized — invalid credentials |
| `403` | Forbidden — account not authorized |
| `404` | Not Found |
| `429` | Too Many Requests — rate limit exceeded |
| `500` | Internal Server Error |

### Common Twilio Error Codes

| Code | Description |
|---|---|
| `10001` | Account not active |
| `20003` | Authenticate |
| `20404` | Resource not found |
| `21211` | Invalid `To` phone number |
| `21608` | `From` number is not capable of SMS |
| `21610` | Attempt to send to unsubscribed recipient |
| `21614` | `To` number is not a mobile number |
| `30001` | Queue overflow |
| `30002` | Account suspended |
| `30003` | Unreachable destination handset |
| `30004` | Message blocked |
| `30005` | Unknown destination handset |
| `30006` | Landline or unreachable carrier |
| `30007` | Carrier violation |
| `30008` | Unknown error |
| `32017` | A2P 10DLC registration required |

### Error Response Format

```json
{
  "code": 21211,
  "message": "The 'To' number +15005550001 is not a valid phone number.",
  "more_info": "https://www.twilio.com/docs/errors/21211",
  "status": 400
}
```

---

## 12. Pricing

All prices are in USD. Carrier surcharges are additional.

### SMS Pricing (United States)

| Type | Twilio Rate | Notes |
|---|---|---|
| Outbound SMS | $0.0079/message | + carrier surcharges |
| Inbound SMS | $0.0079/message | |
| Outbound MMS | $0.0200/message | + carrier surcharges |
| Inbound MMS | $0.0100/message | |
| US carrier surcharge (AT&T/T-Mobile) | ~$0.0025–$0.003/SMS | |
| US carrier surcharge (Verizon) | ~$0.004–$0.0065/SMS | |
| US carrier surcharge MMS (T-Mobile) | ~$0.01/MMS | |

A2P 10DLC (US) requires brand registration ($4 one-time) and campaign fees (carrier-mandated, ongoing).

### WhatsApp Pricing

| Type | Rate |
|---|---|
| Twilio per-message fee | $0.005 inbound or outbound |
| First 1,000 conversations/month | Free |
| Meta utility conversation | Varies by country |
| Meta authentication conversation | Varies by country |
| Meta marketing conversation | Varies by country |

### Voice Pricing (United States)

| Type | Rate |
|---|---|
| Outbound (per minute) | $0.0140 |
| Inbound (per minute) | $0.0085 |
| Recording storage (per minute) | $0.0025 |
| Transcription (per minute) | $0.05 |

### Verify Pricing

| Type | Rate |
|---|---|
| Per successful verification | $0.05 |
| Standard SMS/call rates | Additional |

### Phone Numbers

| Type | Monthly Cost |
|---|---|
| Local US/Canada | ~$1.00/month |
| Toll-free US/Canada | ~$2.00/month |
| Short code | ~$1,000/month |

### Conversations API

| Type | Rate |
|---|---|
| Per active monthly user | $0.05 |
| Media storage | Per GB/month |
| Plus standard SMS/WhatsApp rates | Additional |

---

*Documentation sourced from: https://www.twilio.com/docs/sms/api, https://www.twilio.com/docs/whatsapp/api, https://www.twilio.com/docs/voice/api*
*Compiled: 2026-02-27*
