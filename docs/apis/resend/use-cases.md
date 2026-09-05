# Resend — Use Cases

## Overview

This document outlines common use cases for Resend, mapping each to the relevant Resend feature and the implementation difficulty. Difficulty is rated on a three-point scale:

- **Easy** — Single API call, minimal setup, works immediately after domain verification.
- **Medium** — Requires additional logic, templates, or integration with other systems.
- **Hard** — Involves automation pipelines, audience segmentation, sequencing, or complex tracking.

---

## Use Case Table

| Use Case | Feature | Difficulty |
|---|---|---|
| Send password reset emails | `POST /emails` with unique token link | Easy |
| Welcome emails for new signups | `POST /emails` triggered on user creation | Easy |
| Order confirmation emails | `POST /emails` with order data | Easy |
| Broadcast newsletters | Audiences + Broadcasts | Medium |
| Invoice / receipt emails | `POST /emails` with PDF attachment | Medium |
| Automated drip campaigns | Batch send + scheduling (`scheduledAt`) | Hard |
| Transactional notifications | `POST /emails` or `POST /emails/batch` + webhooks | Medium |

---

## Use Case Details

### Send Password Reset Emails

**Feature:** `POST /emails` with unique token link
**Difficulty:** Easy

Send a password reset link to a user when they request it. The email contains a time-limited token embedded in a URL.

```javascript
// Node.js
import { Resend } from 'resend';
const resend = new Resend(process.env.RESEND_API_KEY);

async function sendPasswordReset(email, token) {
  const resetUrl = `https://yourapp.com/reset-password?token=${token}`;

  await resend.emails.send({
    from: 'noreply@yourdomain.com',
    to: [email],
    subject: 'Reset your password',
    html: `
      <p>You requested a password reset.</p>
      <p><a href="${resetUrl}">Click here to reset your password</a></p>
      <p>This link expires in 1 hour. If you did not request this, ignore this email.</p>
    `,
    text: `Reset your password: ${resetUrl}\n\nThis link expires in 1 hour.`,
    tags: [{ name: 'category', value: 'password_reset' }],
  });
}
```

**Requirements:**
- Verified sending domain
- Secure token generation (e.g. `crypto.randomBytes`)
- Token storage with expiry in your database

---

### Welcome Emails for New Signups

**Feature:** `POST /emails` triggered on user creation
**Difficulty:** Easy

Send a branded welcome email when a user completes registration. Typically triggered in your signup API handler or database trigger.

```python
# Python
import resend, os

resend.api_key = os.environ['RESEND_API_KEY']

def send_welcome_email(user):
    resend.Emails.send({
        "from": "welcome@yourdomain.com",
        "to": [user["email"]],
        "subject": f"Welcome to YourApp, {user['first_name']}!",
        "html": f"""
            <h1>Welcome, {user['first_name']}!</h1>
            <p>Your account is ready. Here's how to get started:</p>
            <ul>
              <li>Complete your profile</li>
              <li>Explore the dashboard</li>
              <li>Invite your team</li>
            </ul>
            <a href="https://yourapp.com/dashboard">Get started</a>
        """,
        "text": f"Welcome, {user['first_name']}! Visit https://yourapp.com/dashboard to get started.",
        "tags": [{"name": "category", "value": "welcome"}]
    })
```

**Requirements:**
- Verified sending domain
- Integration point in your user creation flow (API handler, auth hook, database trigger)

---

### Order Confirmation Emails

**Feature:** `POST /emails` with order data
**Difficulty:** Easy

Send a detailed order summary immediately after a purchase is completed. Typically triggered by a payment success webhook (e.g. from Stripe).

```javascript
async function sendOrderConfirmation(order) {
  const itemRows = order.items
    .map(item => `<tr><td>${item.name}</td><td>${item.qty}</td><td>€${item.price}</td></tr>`)
    .join('');

  await resend.emails.send({
    from: 'orders@yourdomain.com',
    to: [order.customerEmail],
    subject: `Order confirmed — #${order.id}`,
    html: `
      <h2>Thank you for your order!</h2>
      <p>Order number: <strong>#${order.id}</strong></p>
      <table>
        <thead><tr><th>Item</th><th>Qty</th><th>Price</th></tr></thead>
        <tbody>${itemRows}</tbody>
      </table>
      <p>Total: <strong>€${order.total}</strong></p>
    `,
    tags: [
      { name: 'category', value: 'order_confirmation' },
      { name: 'order_id', value: String(order.id) }
    ],
  });
}
```

**Requirements:**
- Verified sending domain
- Order data available at send time
- Integration with payment provider (e.g. Stripe webhook)

---

### Broadcast Newsletters

**Feature:** Audiences + Broadcasts
**Difficulty:** Medium

Send the same email to all contacts in an audience (contact list). Resend manages unsubscribes and contact management through the Audiences API.

**Steps:**
1. Create an audience and populate it with contacts via `POST /audiences/{id}/contacts`.
2. Create a broadcast campaign via `POST /broadcasts`.
3. Send (or schedule) the broadcast from the dashboard or API.

```javascript
// Step 1: Add a subscriber to your audience
await resend.audiences.contacts.create('audience_id_here', {
  email: 'subscriber@example.com',
  first_name: 'Jane',
  unsubscribed: false,
});

// Step 2: Create a broadcast
const broadcast = await resend.broadcasts.create({
  audience_id: 'audience_id_here',
  from: 'newsletter@yourdomain.com',
  subject: 'February 2026 Update',
  html: '<h1>This month in our product...</h1>',
  name: 'February 2026 Newsletter',
});
```

**Requirements:**
- Verified sending domain
- Opted-in contact list (GDPR/CAN-SPAM compliance)
- Unsubscribe link in email body (required by law in most regions)

---

### Invoice / Receipt Emails

**Feature:** `POST /emails` with PDF attachment
**Difficulty:** Medium

Attach a generated PDF invoice to a transactional email. The PDF must be base64-encoded before sending.

```javascript
import fs from 'fs';
import { generateInvoicePdf } from './invoiceGenerator';

async function sendInvoiceEmail(order) {
  const pdfBuffer = await generateInvoicePdf(order);
  const pdfBase64 = pdfBuffer.toString('base64');

  await resend.emails.send({
    from: 'billing@yourdomain.com',
    to: [order.customerEmail],
    subject: `Invoice #${order.invoiceNumber}`,
    html: `<p>Please find your invoice for order #${order.id} attached.</p>`,
    text: `Your invoice for order #${order.id} is attached.`,
    attachments: [
      {
        filename: `invoice-${order.invoiceNumber}.pdf`,
        content: pdfBase64,
        content_type: 'application/pdf',
      }
    ],
    tags: [{ name: 'category', value: 'invoice' }],
  });
}
```

**Requirements:**
- PDF generation library (e.g. `pdfkit`, `puppeteer`, `wkhtmltopdf`)
- Verified sending domain
- Base64 encoding of the file buffer

---

### Automated Drip Campaigns

**Feature:** Batch send + `scheduledAt` + external sequencing
**Difficulty:** Hard

Send a sequence of emails over days or weeks after a user signs up or takes an action. Each email is pre-scheduled or queued by your backend.

```javascript
async function enrollInDripCampaign(user) {
  const now = new Date();

  const sequence = [
    { delay: 0,    subject: 'Welcome! Here is how to get started', template: 'welcome' },
    { delay: 2,    subject: 'Tip #1: Set up your first project',    template: 'tip1' },
    { delay: 5,    subject: 'Tip #2: Invite your team',             template: 'tip2' },
    { delay: 10,   subject: 'How is it going? We would love feedback', template: 'check_in' },
    { delay: 14,   subject: 'Upgrade to Pro — unlock all features', template: 'upsell' },
  ];

  const emailPayloads = sequence.map(step => {
    const sendAt = new Date(now);
    sendAt.setDate(sendAt.getDate() + step.delay);

    return {
      from: 'team@yourdomain.com',
      to: [user.email],
      subject: step.subject,
      html: renderTemplate(step.template, user),
      scheduledAt: sendAt.toISOString(),
      tags: [
        { name: 'campaign', value: 'onboarding_drip' },
        { name: 'step', value: step.template }
      ],
    };
  });

  await resend.batch.send(emailPayloads);
}
```

**Requirements:**
- Batch endpoint (up to 100 emails per call, schedule beyond 100 in multiple calls)
- Template rendering system or React Email components
- Cancellation logic if user converts or unsubscribes mid-sequence
- Webhook handler to track `email.opened` / `email.clicked` for conditional branching

---

### Transactional Notifications

**Feature:** `POST /emails` or `POST /emails/batch` + webhooks
**Difficulty:** Medium

Send event-driven notifications for product activity — failed payments, account security alerts, usage warnings, team invitations, and similar system events.

```javascript
// Single notification
async function notifyPaymentFailed(user, invoice) {
  await resend.emails.send({
    from: 'alerts@yourdomain.com',
    to: [user.email],
    subject: 'Action required: Payment failed',
    html: `
      <p>Hi ${user.name},</p>
      <p>We were unable to process your payment of <strong>€${invoice.amount}</strong>.</p>
      <p><a href="https://yourapp.com/billing">Update your payment method</a></p>
    `,
    text: `Payment of €${invoice.amount} failed. Update your payment method: https://yourapp.com/billing`,
    tags: [{ name: 'category', value: 'payment_failed' }],
  });
}

// Bulk notifications (e.g. notify all team members)
async function notifyTeam(members, event) {
  const emails = members.map(member => ({
    from: 'alerts@yourdomain.com',
    to: [member.email],
    subject: `[${event.project}] ${event.title}`,
    html: `<p>${event.description}</p>`,
    tags: [{ name: 'event_type', value: event.type }],
  }));

  await resend.batch.send(emails);
}
```

**Requirements:**
- Event triggers in your application code or infrastructure (payment webhooks, monitoring alerts, etc.)
- Verified sending domain
- Webhook handler for `email.bounced` to handle bad email addresses in your user database

---

## Compliance Notes

Regardless of use case, always ensure:

- **Unsubscribe link**: Required in all commercial and marketing emails (CAN-SPAM, GDPR, CASL).
- **Sender identity**: `from` address must use a verified domain.
- **Data minimization**: Only include personal data in emails that is necessary for that communication.
- **Bounce handling**: Monitor `email.bounced` webhooks and remove invalid addresses from your list.
- **Spam complaints**: Monitor `email.complained` webhooks and unsubscribe complainants immediately.

---

## Difficulty Reference

| Level | What it means |
|-------|---------------|
| Easy | Single API call triggered by a straightforward event; no additional infrastructure |
| Medium | Requires integration with other systems, attachment generation, or audience management |
| Hard | Multi-step sequencing, conditional logic, cancellation handling, or advanced tracking |
