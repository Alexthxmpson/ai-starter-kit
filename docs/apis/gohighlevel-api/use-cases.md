# GoHighLevel API — Use Cases & Practical Guide
Saved: 2026-03-10

---

## What You Can Do

### Free / Always Available
- Read and search contacts
- View conversations and messages
- Check opportunities in pipeline
- Read calendar slots and appointments
- View blog posts, authors, categories
- Fetch invoices and payment history
- Read workflows and surveys
- List social media accounts and scheduled posts

### Write / Automation
- Create and update contacts (+ tags, notes, tasks)
- Send SMS and email through conversations
- Create and update opportunities (move through pipeline)
- Book, update, delete appointments
- Publish and edit blog posts
- Create and send invoices
- Schedule social media posts
- Trigger workflows (via contact/opportunity updates)

---

## Practical Automations

| Idea | Tools Used | Difficulty |
|------|-----------|-----------|
| Add leads from form → GHL contact | `create_contact` | Easy |
| Tag contacts by source/status | `add_contact_tags` | Easy |
| Search contacts and send SMS blast | `search_contacts` + `send_sms` | Easy |
| Create opportunity when contact responds | `create_conversation` → `create_opportunity` | Medium |
| Auto-book discovery call from AI chat | `get_free_slots` → `create_appointment` | Medium |
| Publish blog post from Claude output | `create_blog_post` | Easy |
| Generate and send invoice | `create_invoice` → `send_invoice` | Easy |
| Schedule week of social posts at once | `create_social_post` × N | Medium |
| Pipeline stage mover (CRM automation) | `update_opportunity` status | Easy |
| Pull all unpaid invoices → send reminder | `list_invoices` → `send_email` | Medium |
| Cross-reference contacts with Airtable | GHL `search_contacts` + Airtable MCP | Medium |
| Morning digest: new leads + open opps | `search_contacts` + `search_opportunities` | Easy |

---

## MCP Setup (Claude Code — Already Configured)

```json
{
  "gohighlevel": {
    "type": "http",
    "url": "https://services.leadconnectorhq.com/mcp/",
    "headers": {
      "Authorization": "Bearer pit-YOUR-TOKEN-HERE",
      "locationId": "jkkz9cczD1uyCBjFOXok",
      "Version": "2021-07-28"
    }
  }
}
```

---

## Key Limits & Gotchas

- **Scopes must be enabled** in Private Integration settings — 401 "not authorized for scope" = scope missing
- **`locationId`** is required on almost every endpoint (sub-account level)
- **PIT tokens** are static — no refresh needed, but rotate every 90 days
- **SMS requires** a purchased phone number in the GHL location
- **Blog posts** require a blog site to exist first (`get_blog_sites`)
- **Opportunity pipeline** — you need a pipeline ID (`get_pipelines`) before creating opportunities
- **Calendar free slots** — check availability before booking to avoid conflicts
- **Rate limits** — not publicly documented; stay under ~10 req/sec to be safe

---

## Already Built

- `GHL_VITA_API_KEY` — old legacy JWT (limited, no scope restriction)
- `GHL_PRIVATE_TOKEN` — new PIT token (scoped, use this for everything)
- GHL MCP installed globally in Claude Code (`~/.claude.json`)
- `/company-ghl` skill — creates GHL sub-accounts for new company setups

---

## Next Steps

1. **Enable scopes** — go to GHL → Settings → Integrations → Private Integrations → edit the integration → select all needed scopes
2. **Test connection** — ask Claude: "search my GHL contacts" or "what opportunities do I have?"
3. **Get pipeline IDs** — run `list_pipelines` to get IDs for opportunity automation
