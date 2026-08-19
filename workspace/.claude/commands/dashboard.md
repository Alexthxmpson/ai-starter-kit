# Dashboard

Turn data I have into a clean, live dashboard on a real URL.

## My data / request

$ARGUMENTS

If empty, ask me: what data (a file, a spreadsheet export, an Airtable, numbers I will paste), and what decisions I want the dashboard to help me make.

## Your process

1. **Understand the data.** Look at the actual data first. List the columns/fields you found and confirm what the 3 to 5 most decision-relevant numbers are. A dashboard is for decisions, not decoration.
2. **Build a single-file dashboard.** One `index.html` in a new folder under `projects/`:
   - Clean, modern, mobile-friendly. Dark and light support if quick.
   - Summary numbers at the top, charts below, details last.
   - No build step, no framework install: plain HTML, CSS, and a charting library loaded from a CDN (or inline SVG).
3. **Wire the data.** Small datasets can be embedded directly in the file. For living data (Airtable, an API), fetch at load time and tell me clearly which keys or tokens are needed, stored in environment variables, never hardcoded.
4. **Put it live.** Deploy with Vercel (`npx vercel --yes --prod` from the project folder). If I am not logged into Vercel yet, walk me through the one-time login first.
5. **Prove it.** Give me the live URL and a one-line summary of what each section shows.

## Rules

- Ship the simplest version first, then ask if I want more. Do not build six charts when two answer the question.
- If the data has obvious quality problems (duplicates, gaps, mixed formats), tell me before charting over them.
