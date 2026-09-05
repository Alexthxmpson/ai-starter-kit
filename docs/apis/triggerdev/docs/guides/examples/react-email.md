---
source: https://trigger.dev/docs/guides/examples/react-email
scraped: 2026-02-28
---

# Send Emails Using React Email

## Overview

This documentation explains how to integrate Trigger.dev with React Email to send beautifully formatted emails. The example uses Resend as the email provider, though other services like Loops and SendGrid are supported through React Email's integration ecosystem.

## Key Requirements

The task file must be a `.tsx` file to support React components. The implementation requires:
- A Resend API key stored in environment variables
- A verified email address for the sender
- React Email components for template structure

## Core Implementation

The example provides a task structure that:

1. **Defines an Email Template** - Uses React Email components (Body, Button, Container, etc.) to structure the email
2. **Initializes Resend Client** - Connects to the email service with API credentials
3. **Sends Email** - Passes the React component as the email body to Resend's send method
4. **Handles Errors** - Includes logging and error management with detailed feedback

## Testing

The dashboard accepts test payloads with these fields:
- `to` - recipient email address
- `name` - personalization variable
- `message` - email content
- `subject` - email subject line
- `from` (optional) - sender address

## Advanced Example: Welcome Email

A generated welcome email template demonstrates:
- Dark theme styling with custom CSS variables
- Multiple sections with headings, links, and calls-to-action
- Professional formatting with horizontal rules and consistent typography
- Links to documentation and community resources (Discord)

## Troubleshooting

A common error occurs with React DOM server rendering: "reactDOMServer.renderToPipeableStream is not a function." The documentation references a dedicated troubleshooting guide for resolution steps.

## Additional Resources

- [React Email Documentation](https://react.email/docs) - Setup and preview guides
- [Component Library](https://react.email/components) - Pre-built email components
- [Template Gallery](https://react.email/templates) - Ready-to-use email designs
