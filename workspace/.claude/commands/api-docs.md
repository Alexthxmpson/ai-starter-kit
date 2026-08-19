# API Docs First

Before integrating any external tool, fetch its real, current API documentation and save it locally. Never code against a guessed API.

## Tool to document

$ARGUMENTS

If empty, ask me which tool or API I want to integrate.

## Your process

1. **Check local first.** Look in `docs/apis/<tool-name>/`. If current docs are already saved there, use them and skip fetching.
2. **Find the official source.** Search for the tool's official API reference (developer docs, OpenAPI spec, or official SDK README). Official sources only, not blog posts or tutorials.
3. **Save what matters.** Create `docs/apis/<tool-name>/` and save as markdown:
   - `overview.md`: base URL, authentication method, rate limits, API version
   - `endpoints.md`: the endpoints relevant to what I am building, with parameters and example responses
   - `gotchas.md`: pagination style, error formats, anything surprising
4. **Summarize.** Tell me in a few sentences: how auth works, which endpoints we need, and anything that changes the plan.

## Rules

- If you cannot find official documentation, say so and stop. Do not fill gaps from memory: APIs change and your memory of them may be stale.
- Note the date and doc version at the top of `overview.md` so future sessions know how fresh the docs are.
- When later coding against this tool, read these saved files first, every time.
