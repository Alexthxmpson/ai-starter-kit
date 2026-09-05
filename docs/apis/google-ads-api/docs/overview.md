# API Overview
**Source:** https://developers.google.com/google-ads/api/docs/concepts/overview
**Date:** 2026-03-01

---

> **Note:** This guide is for users who are already familiar with Google Ads. Others may want to check out the Help Center article on account organization first to understand the key components of an account and how they are organized. For more detailed information, the Google Ads basics series is a great resource as well.

The guides in this series provide an overview of the objects, methods, and services available in the Google Ads API. After reading these guides, you will understand the following key concepts:

- How the Google Ads API is structured
- How Google Ads API versioning works
- Which API service to use to modify an object
- Which API service to use to retrieve an object and its performance statistics
- Which API service to use to retrieve API metadata
- How to structure API calls
- How to mutate resources

## Key Concept Areas

### API Structure
The Google Ads API is organized around resources (e.g., Campaign, AdGroup, Ad) that can be retrieved and modified using various services.

### Versioning
The API uses versioned endpoints to ensure backward compatibility while allowing new features to be added.

### Changing Objects
Use the appropriate service's `mutate` method to create, update, or remove objects.

### Retrieving Objects
Use `GoogleAdsService.search` or `GoogleAdsService.searchStream` with GAQL queries to retrieve objects and performance statistics.

### Resource Metadata
Use the `GoogleAdsFieldService` to retrieve metadata about available fields and resources.

### Call Structure
Calls are made via gRPC or REST. Each request must include authentication headers and, where applicable, a customer ID.

### Mutates
Mutations allow you to create, update, or remove multiple resources in a single API call using the relevant service's `mutate` endpoint.

---
*Last updated 2026-02-26 UTC. Content licensed under Creative Commons Attribution 4.0 License.*
