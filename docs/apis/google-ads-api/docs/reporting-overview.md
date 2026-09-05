# Reporting
**Source:** https://developers.google.com/google-ads/api/docs/reporting/overview
**Date:** 2026-03-01

---

Reporting of performance data is an integral part of Google Ads API applications. With the flexible reporting options for this API, you can obtain performance data for all resources. This includes everything from an entire campaign to a set of keywords that triggered your ad.

This guide describes the steps necessary to create and submit a query to the Google Ads API to get back data. For more detailed information about reporting, the Reports reference documentation describes the resources that can be queried in the Google Ads API using `GoogleAdsService.SearchStream` or `GoogleAdsService.Search`.

## Reporting Topics

- Try a quick example — `/google-ads/api/docs/reporting/example`
- Retrieve criteria performance metrics — `/google-ads/api/docs/reporting/criteria-metrics`
- Learn about segmentation — `/google-ads/api/docs/reporting/segmentation`
- Find out how to handle zero metrics — `/google-ads/api/docs/reporting/zero-metrics`
- Learn about using labels to report on your data — `/google-ads/api/docs/reporting/labels`
- Learn about streaming your reporting data — `/google-ads/api/docs/reporting/streaming`
- Learn about paging your data — `/google-ads/api/docs/reporting/paging`
- Learn about mapping UI reports to API usage — `/google-ads/api/docs/reporting/uireports`
- Learn the syntax of the Google Ads Query Language — `/google-ads/api/docs/query/overview`
- Learn about managing data efficiently — `/google-ads/api/docs/productionize/manage-data-efficiently`

## Key Services for Reporting

### GoogleAdsService.Search
Used for paginated queries that return results all at once. Suitable for smaller result sets.

### GoogleAdsService.SearchStream
Used for streaming queries that return results progressively. Better for large result sets as it avoids timeout issues and reduces memory usage.

## Query Structure Summary

A reporting query uses Google Ads Query Language (GAQL):

```sql
SELECT resource.field, metrics.metric_name, segments.segment_name
FROM resource_name
WHERE condition
ORDER BY field
LIMIT n
```

## Report Reference

The Reports reference documentation at `/google-ads/api/fields/v23/overview` covers all queryable resources, their fields, compatible metrics, and valid segments for each resource type.

**Next:** Use case (example query)

---
*Last updated 2026-02-26 UTC. Content licensed under Creative Commons Attribution 4.0 License.*
