# PostHog — Capabilities & Use Cases

**API:** PostHog Product Analytics API
**Access:** Project API key (phc_...) for capture, Personal API key (phx_...) for read/write
**Last updated:** 2026-02-28

---

## What You Can Do

### Analytics (Free self-hosted / Paid cloud)
- Track any user action (page views, button clicks, custom events)
- Identify users with properties (email, plan, company)
- Group analytics by company/organization
- Query historical events

### Feature Flags
- Create feature flags and roll out to % of users
- Target flags by user properties (plan, country, etc.)
- A/B test with experiment flags
- Evaluate flags server-side or client-side

### Session Replay
- Watch recordings of real user sessions
- Identify UX friction points

### Funnels & Retention
- Build conversion funnels
- Analyze where users drop off
- Track weekly/monthly retention

### Insights & Dashboards
- Create saved insights programmatically
- Build dashboards with charts
- Share insights with team

---

## Use Cases

| Use Case | PostHog Feature | Difficulty |
|----------|----------------|------------|
| Track signups and conversions | Event capture | Easy |
| A/B test landing page variants | Experiment flags | Medium |
| Roll out feature to 10% of users | Feature flags | Easy |
| Find where users drop off in onboarding | Funnels | Easy |
| Watch sessions of churned users | Session Replay | Easy |
| Identify power users by usage | Person properties + cohorts | Medium |
| Build SaaS usage dashboard | Insights API | Medium |
| Track feature adoption over time | Trends insight | Easy |
| Analyze retention by plan tier | Retention + groups | Medium |
| Auto-disable feature if error rate spikes | Feature flags via API | Hard |
| Export events to data warehouse | Batch export | Medium |
| Capture server-side events | POST /capture | Easy |

---

## SDK Quick Reference

```python
# Python
from posthog import Posthog
posthog = Posthog(project_api_key='phc_...', host='https://app.posthog.com')
posthog.capture('user_123', 'purchase_completed', {'plan': 'pro', 'amount': 99})
posthog.identify('user_123', {'email': 'user@example.com', 'plan': 'pro'})
flag_enabled = posthog.get_feature_flag('new-dashboard', 'user_123')
```

---

## Key Notes
- Free tier: 1M events/month, 15,000 session recordings
- Self-hosted: unlimited events (open source)
- Distinct ID must be consistent for a user across sessions
- Group analytics requires `posthog.group()` call before capture
- Feature flag evaluation is cached — flush/reload for real-time
