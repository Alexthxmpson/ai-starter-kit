# Supabase — Technical Documentation

## Overview

Supabase is an open-source Backend-as-a-Service (BaaS) built on PostgreSQL. It provides a complete backend stack including a relational database, authentication, file storage, realtime subscriptions, and serverless edge functions — all exposed through REST, GraphQL, and WebSocket interfaces. It is commonly described as an open-source alternative to Firebase.

Core components:
- **Database**: Managed PostgreSQL with full SQL support
- **Auth**: User management, OAuth, magic links, and JWTs
- **Storage**: S3-compatible file storage with access policies
- **Realtime**: WebSocket subscriptions to database changes
- **Edge Functions**: Deno-based serverless functions
- **REST API**: Auto-generated from your PostgreSQL schema via PostgREST

---

## Authentication

Supabase uses two types of API keys, both found in Project Settings > API:

| Key | Prefix | Purpose |
|---|---|---|
| `anon` / public key | `eyJ...` (JWT) | Safe to use in client-side code; respects Row Level Security |
| `service_role` key | `eyJ...` (JWT) | Admin-level access; bypasses RLS; server-side only |

### Request Headers

```http
# Public (client-side) access
apikey: your-anon-key
Authorization: Bearer your-anon-key

# Authenticated user access (after login)
apikey: your-anon-key
Authorization: Bearer user-jwt-token

# Admin / service role access (server-side only)
apikey: your-service-role-key
Authorization: Bearer your-service-role-key
```

Both the `apikey` header and `Authorization: Bearer` header must be present on REST API requests.

---

## Base URL

```
https://[project-ref].supabase.co
```

The `project-ref` is a unique identifier found in your project's dashboard URL and in Project Settings. All service endpoints are subpaths of this base URL:

| Service | Base Path |
|---|---|
| REST API | `/rest/v1/` |
| Auth | `/auth/v1/` |
| Storage | `/storage/v1/` |
| Edge Functions | `/functions/v1/` |
| Realtime | `wss://[project-ref].supabase.co/realtime/v1/` |

---

## SDKs

### JavaScript / TypeScript

```bash
npm install @supabase/supabase-js
```

```js
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://your-project-ref.supabase.co',
  'your-anon-key'
)
```

### Python

```bash
pip install supabase
```

```python
from supabase import create_client, Client

url = "https://your-project-ref.supabase.co"
key = "your-anon-key"
supabase: Client = create_client(url, key)
```

---

## REST API (PostgREST)

Supabase auto-generates a full REST API from your PostgreSQL schema using PostgREST. Every table and view in the `public` schema gets CRUD endpoints automatically.

### Select Rows

```http
GET /rest/v1/users?select=id,email,created_at
```

```js
const { data, error } = await supabase
  .from('users')
  .select('id, email, created_at')
```

### Insert Rows

```http
POST /rest/v1/users
Content-Type: application/json
Prefer: return=representation

{"email": "user@example.com", "name": "Jane Doe"}
```

```js
const { data, error } = await supabase
  .from('users')
  .insert({ email: 'user@example.com', name: 'Jane Doe' })
  .select()
```

### Update Rows

```http
PATCH /rest/v1/users?id=eq.123
Content-Type: application/json
Prefer: return=representation

{"name": "Jane Smith"}
```

```js
const { data, error } = await supabase
  .from('users')
  .update({ name: 'Jane Smith' })
  .eq('id', 123)
  .select()
```

### Delete Rows

```http
DELETE /rest/v1/users?id=eq.123
```

```js
const { error } = await supabase
  .from('users')
  .delete()
  .eq('id', 123)
```

### Upsert

```js
const { data, error } = await supabase
  .from('profiles')
  .upsert({ id: 'user-uuid', username: 'janedoe' })
  .select()
```

---

## Filters

Filters are applied as query string parameters on the REST API, or chained methods in the SDK.

| Filter | REST Parameter | SDK Method | Description |
|---|---|---|---|
| Equal | `col=eq.value` | `.eq('col', value)` | Exact match |
| Not equal | `col=neq.value` | `.neq('col', value)` | Excludes value |
| Greater than | `col=gt.value` | `.gt('col', value)` | Greater than |
| Less than | `col=lt.value` | `.lt('col', value)` | Less than |
| Greater or equal | `col=gte.value` | `.gte('col', value)` | Greater than or equal |
| Less or equal | `col=lte.value` | `.lte('col', value)` | Less than or equal |
| Like (case-sensitive) | `col=like.val*` | `.like('col', 'val%')` | Pattern match |
| Like (case-insensitive) | `col=ilike.val*` | `.ilike('col', 'val%')` | Case-insensitive pattern |
| In list | `col=in.(a,b,c)` | `.in('col', ['a','b','c'])` | Matches any value in list |
| Is null / boolean | `col=is.null` | `.is('col', null)` | Null or boolean check |
| Not | `col=not.eq.value` | `.not('col', 'eq', value)` | Negation of any filter |
| Or | `or=(col1.eq.a,col2.eq.b)` | `.or('col1.eq.a,col2.eq.b')` | Logical OR |
| And | (default, chain filters) | Chain multiple methods | Logical AND (default) |

### Prefer Headers

```http
Prefer: return=representation    # Return inserted/updated rows
Prefer: count=exact              # Include exact total count in Content-Range header
Prefer: return=minimal           # Return no body (faster)
```

### Ordering and Pagination

```http
GET /rest/v1/posts?order=created_at.desc&limit=20&offset=40
```

```js
const { data, count } = await supabase
  .from('posts')
  .select('*', { count: 'exact' })
  .order('created_at', { ascending: false })
  .range(40, 59)
```

---

## Auth API

### Sign Up

```http
POST /auth/v1/signup
Content-Type: application/json

{"email": "user@example.com", "password": "securepassword"}
```

```js
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'securepassword',
})
```

### Sign In (Email + Password)

```http
POST /auth/v1/token?grant_type=password
Content-Type: application/json

{"email": "user@example.com", "password": "securepassword"}
```

```js
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'securepassword',
})
```

### Get Current User

```http
GET /auth/v1/user
Authorization: Bearer user-jwt-token
```

```js
const { data: { user } } = await supabase.auth.getUser()
```

### Sign Out

```http
POST /auth/v1/logout
Authorization: Bearer user-jwt-token
```

```js
await supabase.auth.signOut()
```

### OAuth (Social Login)

```js
await supabase.auth.signInWithOAuth({
  provider: 'github', // google, facebook, twitter, discord, etc.
  options: { redirectTo: 'https://example.com/callback' }
})
```

### Magic Link

```js
await supabase.auth.signInWithOtp({ email: 'user@example.com' })
```

### Session Refresh

The JS SDK handles token refresh automatically. The session includes `access_token` (JWT, 1 hour default) and `refresh_token`.

---

## Storage API

### Upload a File

```http
POST /storage/v1/object/{bucket}/{path}
Authorization: Bearer token
Content-Type: image/png

[binary data]
```

```js
const { data, error } = await supabase.storage
  .from('avatars')
  .upload('user-id/avatar.png', file, {
    contentType: 'image/png',
    upsert: true,
  })
```

### Download a File

```js
const { data, error } = await supabase.storage
  .from('avatars')
  .download('user-id/avatar.png')
```

### Get Public URL

```js
const { data } = supabase.storage
  .from('avatars')
  .getPublicUrl('user-id/avatar.png')

// data.publicUrl = "https://[project-ref].supabase.co/storage/v1/object/public/avatars/user-id/avatar.png"
```

### Create a Signed URL (Time-Limited Access)

```js
const { data, error } = await supabase.storage
  .from('documents')
  .createSignedUrl('private-doc.pdf', 3600) // expires in 1 hour
```

### List Files

```js
const { data, error } = await supabase.storage
  .from('avatars')
  .list('user-id/', { limit: 100, offset: 0 })
```

### Delete Files

```js
const { data, error } = await supabase.storage
  .from('avatars')
  .remove(['user-id/avatar.png'])
```

Storage buckets can be **public** (anyone can read) or **private** (requires auth or signed URLs). Access is further controlled by Storage policies (similar to RLS).

---

## Realtime

Supabase Realtime streams database changes over WebSockets. Available change types: `INSERT`, `UPDATE`, `DELETE`.

### Subscribe to Table Changes

```js
const channel = supabase
  .channel('public:messages')
  .on(
    'postgres_changes',
    { event: '*', schema: 'public', table: 'messages' },
    (payload) => {
      console.log('Change received!', payload)
    }
  )
  .subscribe()
```

### Filter Realtime Events

```js
supabase
  .channel('room-updates')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'messages',
      filter: 'room_id=eq.42',
    },
    (payload) => console.log(payload)
  )
  .subscribe()
```

### Broadcast (Client-to-Client)

```js
const channel = supabase.channel('cursor-positions')
channel.on('broadcast', { event: 'cursor' }, (payload) => {
  console.log(payload)
})
channel.subscribe((status) => {
  if (status === 'SUBSCRIBED') {
    channel.send({ type: 'broadcast', event: 'cursor', payload: { x: 100, y: 200 } })
  }
})
```

Realtime requires the `supabase_realtime` publication to include your tables. Enable per-table in the Supabase Dashboard under Database > Replication.

---

## Edge Functions

Edge Functions are Deno-based serverless functions deployed at Supabase's edge nodes.

### Invoke a Function

```http
POST /functions/v1/my-function
Authorization: Bearer anon-key
Content-Type: application/json

{"name": "world"}
```

```js
const { data, error } = await supabase.functions.invoke('my-function', {
  body: { name: 'world' },
})
```

### Example Function (Deno)

```ts
// supabase/functions/hello/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { name } = await req.json()
  return new Response(JSON.stringify({ message: `Hello ${name}` }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

Deploy with the Supabase CLI: `supabase functions deploy hello`

---

## Row Level Security (RLS)

RLS is a PostgreSQL feature that restricts which rows a user can read, insert, update, or delete — enforced at the database level.

### Enabling RLS

```sql
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
```

### Example Policies

```sql
-- Users can only read their own posts
CREATE POLICY "Users can view own posts"
ON posts FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own posts
CREATE POLICY "Users can insert own posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Admins can do everything (using a custom claim)
CREATE POLICY "Admins have full access"
ON posts
USING (auth.jwt() ->> 'role' = 'admin');
```

`auth.uid()` returns the UUID of the currently authenticated user. When using the `anon` key without a user JWT, `auth.uid()` returns `null`, so policies using `auth.uid()` will deny unauthenticated requests automatically.

---

## PostgreSQL Features

Because Supabase is built on PostgreSQL, you have access to the full relational feature set:

- **Joins**: Use `select('*, related_table(*)')` in the SDK or `?select=*,related_table(*)` in REST
- **Views**: Expose computed or joined data as a REST endpoint automatically
- **Stored Procedures / RPC**: Call PostgreSQL functions via `/rest/v1/rpc/function_name`
- **Triggers**: Run server-side logic on insert/update/delete
- **Full-text search**: Use PostgreSQL `tsvector` and `to_tsquery` for search

### Calling a Stored Procedure

```http
POST /rest/v1/rpc/get_user_stats
Content-Type: application/json

{"user_id": "uuid-here"}
```

```js
const { data, error } = await supabase.rpc('get_user_stats', {
  user_id: 'uuid-here',
})
```

---

## Error Handling

The JavaScript SDK returns `{ data, error }` tuples. Always check `error` before using `data`.

```js
const { data, error } = await supabase.from('posts').select('*')

if (error) {
  console.error('Error code:', error.code)
  console.error('Message:', error.message)
  console.error('Details:', error.details)
}
```

Common PostgREST error codes:

| Code | Meaning |
|---|---|
| `PGRST116` | Row not found |
| `PGRST204` | No content |
| `42501` | RLS policy denied the request |
| `23505` | Unique constraint violation |
| `23503` | Foreign key constraint violation |
