---
source: https://trigger.dev/docs/guides/frameworks/supabase-authentication
scraped: 2026-02-28
---

# Authenticating Supabase Tasks: JWTs and Service Roles

## Overview

Trigger.dev supports two authentication methods for Supabase operations: JWT-based authentication and service role keys.

## JWT Authentication (Recommended)

JWTs are recommended for user-specific operations. A JWT (JSON Web Token) is a string-formatted data container that typically stores user identity and permissions data.

To implement JWT authentication:

1. Add the `SUPABASE_JWT_SECRET` environment variable (found in Supabase project settings under `Data API`)
2. Sign a JWT token for the user with an expiration time
3. Initialize the Supabase client with the token in the Authorization header

**Key advantages:** JWTs respect Row Level Security policies, maintain user-specific audit trails, and follow the principle of least privileged access.

```typescript
const jwtSecret = process.env.SUPABASE_JWT_SECRET;
if (!jwtSecret) {
  throw new Error("SUPABASE_JWT_SECRET is not defined in environment variables");
}

const token = jwt.sign({ sub: user_id }, jwtSecret, { expiresIn: "1h" });

const supabase = createClient(
  process.env.SUPABASE_URL as string,
  process.env.SUPABASE_ANON_KEY as string,
  {
    global: {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  }
);
```

## Service Role Key (Admin Access)

Service role keys provide unlimited access but bypass all security checks. Use only when admin-level privileges are necessary and never expose client-side.

```typescript
const supabase = createClient<Database>(
  process.env.SUPABASE_PROJECT_URL as string,
  process.env.SUPABASE_SERVICE_ROLE_KEY as string
);
```

## Additional Resources

- Edge function hello world guide
- Database webhooks guide
- Supabase authentication guide
- Supabase database operations examples
- Supabase Storage upload examples
