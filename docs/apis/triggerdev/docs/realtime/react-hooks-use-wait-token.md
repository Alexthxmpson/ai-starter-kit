---
source: https://trigger.dev/docs/realtime/react-hooks/use-wait-token
scraped: 2026-02-28
---

# useWaitToken

## Overview

The `useWaitToken` hook enables React components to complete a wait token through a Public Access Token, facilitating communication between frontend and backend.

## Backend Setup

Create a wait token on your backend:

```ts
import { wait } from "@trigger.dev/sdk";

const token = await wait.createToken({
  timeout: "10m",
});

return {
  tokenId: token.id,
  publicToken: token.publicAccessToken,
};
```

The system automatically generates a public access token that expires after one hour.

## Frontend Implementation

Use the hook in your React component:

```tsx
import { useWaitToken } from "@trigger.dev/react-hooks";

export function MyComponent({ publicToken, tokenId }: { publicToken: string; tokenId: string }) {
  const { complete } = useWaitToken(tokenId, {
    accessToken: publicToken,
  });

  return <button onClick={() => complete({ foo: "bar" })}>Complete</button>;
}
```

Pass the token ID and public token from your backend to the component, then invoke the `complete` function with your desired payload.
