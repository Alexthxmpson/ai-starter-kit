# Twilio — Use Cases

## Overview

This document outlines common use cases for Twilio, mapping each to the relevant Twilio service and the implementation difficulty. Difficulty is rated on a three-point scale:

- **Easy** — A few API calls, minimal setup, works out of the box.
- **Medium** — Requires some configuration, webhook handling, or flow logic.
- **Hard** — Involves multiple services, stateful logic, or custom infrastructure.

---

## Use Case Table

| Use Case | Service | Difficulty |
|---|---|---|
| Send SMS notifications / alerts | SMS API (`POST /Messages.json`) | Easy |
| WhatsApp messaging automation | WhatsApp via Messages API | Easy |
| Phone number verification (OTP) | Verify API | Easy |
| Build an IVR phone menu | Voice + TwiML `<Gather>` | Medium |
| Receive and respond to inbound SMS | SMS Webhooks + TwiML | Medium |
| Two-way WhatsApp chatbot | WhatsApp Webhooks + Studio or custom webhook handler | Hard |
| Appointment reminders | SMS or WhatsApp API + scheduling layer (cron/queue) | Medium |

---

## Use Case Details

### Send SMS Notifications / Alerts

**Service:** SMS API — `POST /Messages.json`
**Difficulty:** Easy

Send one-way SMS alerts to users — order updates, shipping confirmations, system alerts, or any time-sensitive notification.

```javascript
// Node.js
const client = require('twilio')(accountSid, authToken);

await client.messages.create({
  to: '+31612345678',
  from: process.env.TWILIO_PHONE_NUMBER,
  body: 'Your shipment has been dispatched. Tracking: TRK-998812.',
});
```

**Requirements:**
- Twilio account with a phone number
- E.164 formatted recipient numbers
- Opt-in compliance depending on country/region

---

### WhatsApp Messaging Automation

**Service:** WhatsApp via Messages API
**Difficulty:** Easy

Send templated or session-based WhatsApp messages to users who have opted in. Use the same `/Messages.json` endpoint with `whatsapp:` prefixed numbers.

```python
# Python
message = client.messages.create(
    to='whatsapp:+31612345678',
    from_='whatsapp:+14155238886',
    body='Your appointment is confirmed for tomorrow at 10:00 AM.'
)
```

**Requirements:**
- WhatsApp-enabled Twilio number (or Sandbox for testing)
- For outbound messages outside 24h session: approved message template
- Users must have WhatsApp installed

---

### Phone Number Verification (OTP)

**Service:** Verify API
**Difficulty:** Easy

Send a one-time password to a user's phone number to verify ownership. Twilio handles code generation, delivery, expiry, and rate limiting.

```javascript
// Send OTP
await client.verify.v2.services(verifySid).verifications.create({
  to: '+31612345678',
  channel: 'sms',
});

// Check OTP
const check = await client.verify.v2.services(verifySid).verificationChecks.create({
  to: '+31612345678',
  code: userEnteredCode,
});

if (check.status === 'approved') {
  // Mark phone number as verified
}
```

**Requirements:**
- Verify Service SID (created once in Console)
- No phone number needed — Twilio manages delivery numbers

---

### Build an IVR Phone Menu

**Service:** Voice API + TwiML
**Difficulty:** Medium

Create an automated phone menu where callers press digits to reach departments, hear information, or leave a voicemail.

```xml
<!-- TwiML returned by your webhook -->
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather numDigits="1" action="/ivr/handle-key" method="POST">
    <Say voice="Polly.Joanna">
      Thank you for calling. Press 1 for Sales. Press 2 for Support.
    </Say>
  </Gather>
  <Redirect>/ivr/welcome</Redirect>
</Response>
```

**Requirements:**
- Public HTTPS endpoint for your webhook
- Logic to handle each digit pressed
- Twilio number configured with a Voice URL

---

### Receive and Respond to Inbound SMS

**Service:** SMS Webhooks + TwiML Messaging Response
**Difficulty:** Medium

Automatically reply to inbound SMS messages. Twilio POSTs to your webhook URL when a message arrives; you return TwiML or use the REST API to send a reply.

```javascript
// Express.js webhook handler
app.post('/sms/inbound', (req, res) => {
  const { Body, From } = req.body;
  const twiml = new twilio.twiml.MessagingResponse();

  if (Body.toLowerCase() === 'stop') {
    twiml.message('You have been unsubscribed. Reply START to resubscribe.');
  } else {
    twiml.message(`Thanks for your message: "${Body}"`);
  }

  res.type('text/xml').send(twiml.toString());
});
```

**Requirements:**
- Public HTTPS endpoint
- Twilio number with SMS webhook URL configured
- Compliance with STOP/HELP opt-out handling

---

### Two-Way WhatsApp Chatbot

**Service:** WhatsApp Webhooks + Studio or custom webhook handler
**Difficulty:** Hard

Build a conversational WhatsApp bot that holds stateful multi-turn conversations, routes users through flows, and integrates with your backend (CRM, booking system, etc.).

**Architecture options:**
1. **Twilio Studio** — No-code flow builder with conditional branching and HTTP request widgets.
2. **Custom webhook** — Full control via your own handler; store conversation state in a database.
3. **Flex** — Twilio's contact center product; add human agent handoff.

**Key considerations:**
- WhatsApp requires template messages for outbound conversations (outside 24h window)
- Must handle session management and conversation state
- WhatsApp Business Policy compliance required

---

### Appointment Reminders

**Service:** SMS or WhatsApp API + external scheduling layer
**Difficulty:** Medium

Send automated reminders before appointments, events, or subscription renewals. Twilio handles delivery; you handle the scheduling logic.

```javascript
// Example: schedule via a job queue (e.g. BullMQ, cron)
async function scheduleReminder(appointment) {
  const sendAt = new Date(appointment.datetime - 24 * 60 * 60 * 1000); // 24h before

  reminderQueue.add(
    { to: appointment.phone, name: appointment.name, time: appointment.time },
    { delay: sendAt - Date.now() }
  );
}

// Worker
reminderQueue.process(async (job) => {
  await client.messages.create({
    to: job.data.to,
    from: process.env.TWILIO_PHONE_NUMBER,
    body: `Reminder: Your appointment is tomorrow at ${job.data.time}. Reply CANCEL to cancel.`,
  });
});
```

**Requirements:**
- Scheduling infrastructure (cron job, job queue, or serverless functions)
- Opt-in records and opt-out handling
- Time zone awareness for accurate delivery

---

## Compliance Notes

Regardless of use case, always ensure:

- **Opt-in**: Recipients have explicitly consented to receive messages.
- **Opt-out**: STOP/UNSUBSCRIBE is honored immediately.
- **TCPA compliance** (US): Required for SMS marketing and automated calls.
- **WhatsApp Business Policy**: Required for all WhatsApp usage.
- **GDPR** (EU): Store and process phone numbers lawfully.

---

## Difficulty Reference

| Level | What it means |
|-------|---------------|
| Easy | Single API call, no webhook required, minimal config |
| Medium | Requires webhook endpoint, some state or flow logic |
| Hard | Multi-service, stateful conversations, compliance-heavy, or custom infrastructure |
