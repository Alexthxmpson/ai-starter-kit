# Google Ads Query Language
**Source:** https://developers.google.com/google-ads/api/docs/query/overview
**Date:** 2026-03-01

---

> **Tip:** Use the Interactive Query Builder to build and validate your GAQL queries.

## Key Terminology

**Resource** — An entity in Google Ads, such as `campaign` or `ad_group`.

**Segment** — A dimension used to group data, such as `segments.date` or `segments.device`. When segments are included in `SELECT` clause with metrics, metrics are split by segment.

**Metric** — A measurement of performance, such as `metrics.impressions` or `metrics.clicks`.

**Attributed Resource** — A resource that is implicitly joined to the main resource in `FROM` clause, allowing you to select its attributes along with main resource attributes.

## Query for Resource or Metadata Information

The Google Ads Query Language can query the Google Ads API for the following types of information:

- **Resources and their related attributes, segments, and metrics** using `GoogleAdsService` Search or SearchStream: The result from a GoogleAdsService query is a list of `GoogleAdsRow` instances, with each `GoogleAdsRow` representing a resource. If any attributes or metrics are requested, then the row also includes those fields. If any segments are requested, then the response also shows an additional row for each segment-resource tuple.

- **Metadata about available fields and resources** in `GoogleAdsFieldService`: This service provides a catalog of queryable fields with specifics about their compatibility and type. The result is a list of `GoogleAdsField` instances.

For more details on query structure see Query Structure and Google Ads Query Language Grammar.

### Query for Resource Attributes

Example of a basic query for attributes of the campaign resource:

```sql
SELECT campaign.id, campaign.name, campaign.status
FROM campaign
ORDER BY campaign.id
```

This query orders by campaign ID. Each resulting `GoogleAdsRow` represents a `campaign` object populated with the selected fields, including the campaign's `resource_name`.

### Query for Metrics

Alongside selected attributes for a given resource, you can also query for related metrics:

```sql
SELECT campaign.id, campaign.name, campaign.status, metrics.impressions
FROM campaign
WHERE campaign.status = 'PAUSED' AND metrics.impressions > 1000
ORDER BY campaign.id
```

This query filters for only the campaigns that have a status of `PAUSED` and have had greater than 1000 impressions. Each resulting `GoogleAdsRow` would have a `metrics` field populated with the selected metrics.

### Query for Segments

```sql
SELECT campaign.id, campaign.name, campaign.status, metrics.impressions, segments.date
FROM campaign
WHERE campaign.status = 'PAUSED'
  AND metrics.impressions > 1000
  AND segments.date DURING LAST_30_DAYS
ORDER BY campaign.id
```

Segmenting splits the selected metrics, grouping by each segment in the SELECT clause. Each resulting `GoogleAdsRow` represents a tuple of a campaign and the date Segment.

### Query for Attributes of a Related Resource

You can join against attributed resources implicitly by selecting an attribute in your query:

```sql
SELECT campaign.id, campaign.name, campaign.status, bidding_strategy.name
FROM campaign
ORDER BY campaign.id
```

This query not only selects campaign attributes, but also pulls in related attributes from each campaign selected.

## Best Practices

- Select only the fields you need to avoid long response times and timeouts.
- Use `LIMIT` during development and testing to avoid processing large result sets.
- Apply filters in the `WHERE` clause to minimize data transfer and response size.
- Use `GoogleAdsFieldService` to check field compatibility and data types before constructing complex queries.
- Be mindful that some fields, especially those involving large amounts of data or complex calculations, can increase query cost.

## Mutate Based on Query Results

When querying for a given resource, you can immediately take those returned results as objects, modify them, and send them back to the mutate method. Sample workflow:

1. Execute a query for all campaigns that are currently `PAUSED` and have impressions greater than 1000.
2. Get the `Campaign` object from the `campaign` field of each `GoogleAdsRow` in the response.
3. Change the status of each campaign from `PAUSED` to `ENABLED`.
4. Call `CampaignService.MutateCampaigns` with the modified campaigns to update them.

## Field Metadata

Queries sent to `GoogleAdsFieldService` are meant for retrieving field metadata. Typical query:

```sql
SELECT name, category, selectable, filterable, sortable, selectable_with, data_type, is_repeated
WHERE name = "<INSERT_RESOURCE_OR_FIELD>"
```

> **Key Point:** Note that there's no `FROM` clause in this query.

You can replace `<INSERT_RESOURCE_OR_FIELD>` with either a resource (such as `customer` or `campaign`) or field (such as `campaign.id`, `metrics.impressions`, or `ad_group.id`).

## Code Examples

The client libraries have examples of using the Google Ads Query Language in `GoogleAdsService`. The **basic operations** folder has examples such as `GetCampaigns`, `GetKeywords`, and `SearchForGoogleAdsFields`.

**Next:** Query grammar

---
*Last updated 2026-02-26 UTC. Content licensed under Creative Commons Attribution 4.0 License.*
