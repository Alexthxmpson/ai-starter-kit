---
source: https://trigger.dev/docs/bulk-actions
scraped: 2026-02-28
---

# Bulk Actions

Bulk actions enable users to perform replay and cancel operations on multiple runs simultaneously. This capability proves particularly valuable when retrying batches of failed runs with updated code or canceling several in-progress runs.

## Creating a New Bulk Action

The process involves nine steps:

1. **Open the bulk action panel** from the top right of the runs page
2. **Filter the runs table** to display the runs you want to action
3. **Alternatively, select individual runs** manually
4. **Choose the runs** for bulk action
5. **Name your bulk action** (optional step)
6. **Select the action type**: replay or cancel
7. **Click the action button** and confirm in the dialog
8. **View bulk action processing** on the dedicated bulk action page
9. **Replay or view runs** from this page

## Important Limitation

"You can only cancel runs that are in states that allow cancellation (like QUEUED or EXECUTING). Runs that are already completed, failed, or in other final states by the time the bulk action process gets to them, cannot be canceled."

This restriction means that only runs in active states are eligible for cancellation through bulk operations.
