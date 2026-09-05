# Supabase — Capabilities & Use Cases

**API:** Supabase REST API (PostgREST) + Auth + Storage + Realtime
**Access:** anon key (public) + service_role key (admin)
**Last updated:** 2026-02-28

---

## What You Can Do

### Database (PostgreSQL via PostgREST)
- Full CRUD on any table via REST API
- Complex filtering, sorting, pagination
- Joins and relationships
- Full-text search
- Stored procedures and RPC calls

### Authentication
- Email/password signup and login
- Social OAuth (Google, GitHub, Discord, etc.)
- Magic link (passwordless email)
- Phone OTP
- JWT-based sessions
- User management (list, update, delete users)

### File Storage
- Upload any file type
- Organize into buckets (public or private)
- Signed URLs for time-limited access
- Image transformations (resize, crop)

### Realtime
- Subscribe to database changes (insert/update/delete) via WebSocket
- Broadcast messages between clients
- Presence (who is online)

### Edge Functions
- Serverless Deno functions
- Trigger via HTTP or database events
- Access environment variables securely

---

## Use Cases

| Use Case | Supabase Feature | Difficulty |
|----------|-----------------|------------|
| User auth for SaaS app | Auth (email + OAuth) | Easy |
| Store and query app data | Database REST API | Easy |
| Upload user profile photos | Storage | Easy |
| Live chat between users | Realtime + Database | Medium |
| Multi-tenant SaaS (per-user data) | RLS (Row Level Security) | Medium |
| Public API without backend code | PostgREST auto-REST | Easy |
| Send welcome email on signup | Auth webhook + Edge Function | Medium |
| Real-time dashboard (auto-refresh) | Realtime subscriptions | Medium |
| Full-text search on content | PostgreSQL FTS | Medium |
| Webhook receiver/processor | Edge Functions | Medium |
| Replace Firebase for existing app | Auth + Database + Storage | Medium |
| Admin dashboard with all user data | service_role key + Dashboard | Easy |

---

## SDK Quick Reference

```javascript
// JavaScript
import { createClient } from '@supabase/supabase-js'
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// Query
const { data } = await supabase.from('users').select('*').eq('active', true)

// Insert
await supabase.from('orders').insert({ user_id: '123', amount: 99 })

// Auth
const { data: { user } } = await supabase.auth.signInWithPassword({ email, password })
```

---

## Key Notes
- anon key = safe for client-side (Row Level Security controls access)
- service_role key = full admin access — NEVER expose in client
- Free tier: 500MB DB, 1GB storage, 50,000 monthly active users
- RLS must be enabled on tables used with anon key
- `SUPABASE_URL` and `SUPABASE_ANON_KEY` are the two env vars needed
