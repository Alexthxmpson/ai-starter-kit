# Google Ads API v23 - RPC Reference
**Source:** https://developers.google.com/google-ads/api/reference/rpc/latest
**Redirected to:** https://developers.google.com/google-ads/api/reference/rpc/v23/overview
**Date:** 2026-03-01

---

## Overview

This is the complete gRPC reference for Google Ads API v23. The API is organized into Services and Resources.

Base URL for gRPC: `googleads.googleapis.com`
Base URL for REST: `https://googleads.googleapis.com/v23`

---

## Services

| Service | Description |
|---------|-------------|
| `AccountBudgetProposalService` | A service for managing account-level budgets through proposals. A proposal is a request to create a new budget or make changes to an existing one. Mutates: The CREATE operation creates a new proposal. UPDATE operations aren't supported. The REMOVE operation cancels a pending proposal. |
| `AccountLinkService` | This service allows management of links between Google Ads accounts and other accounts. |
| `AdGroupAdLabelService` | Service to manage labels on ad group ads. |
| `AdGroupAdService` | Service to manage ads in an ad group. |
| `AdGroupAssetService` | Service to manage ad group assets. |
| `AdGroupAssetSetService` | Service to manage ad group asset set. |
| `AdGroupBidModifierService` | Service to manage ad group bid modifiers. |
| `AdGroupCriterionCustomizerService` | Service to manage ad group criterion customizer. |
| `AdGroupCriterionLabelService` | Service to manage labels on ad group criteria. |
| `AdGroupCriterionService` | Service to manage ad group criteria. |
| `AdGroupCustomizerService` | Service to manage ad group customizer. |
| `AdGroupLabelService` | Service to manage labels on ad groups. |
| `AdGroupService` | Service to manage ad groups. |
| `AdParameterService` | Service to manage ad parameters. |
| `AdService` | Service to manage ads. |
| `AssetGenerationService` | Service for generating new assets with generative AI. |
| `AssetGroupAssetService` | Service to manage asset group asset. |
| `AssetGroupListingGroupFilterService` | Service to manage asset group listing group filter. |
| `AssetGroupService` | Service to manage asset groups. |
| `AssetGroupSignalService` | Service to manage asset group signal. |
| `AssetService` | Service to manage assets. Asset types can be created: YoutubeVideoAsset, MediaBundleAsset, ImageAsset. TextAsset should be created with Ad inline. |
| `AssetSetAssetService` | Service to manage asset set assets. |
| `AssetSetService` | Service to manage asset sets. |
| `AudienceInsightsService` | Audience Insights Service helps users find information about groups of people and how they can be reached with Google Ads. Accessible to allowlisted customers only. |
| `AudienceService` | Service to manage audiences. |
| `AutomaticallyCreatedAssetRemovalService` | Service to remove automatically created assets. |
| `BatchJobService` | Service to manage batch jobs. |
| `BenchmarksService` | BenchmarksService helps users compare YouTube advertisement data against industry benchmarks. Accessible to allowlisted customers only. |
| `BiddingDataExclusionService` | Service to manage bidding data exclusions. |
| `BiddingSeasonalityAdjustmentService` | Service to manage bidding seasonality adjustments. |
| `BiddingStrategyService` | Service to manage bidding strategies. |
| `BillingSetupService` | A service for designating the business entity responsible for accrued costs. |
| `BrandSuggestionService` | This service will suggest brands based on a prefix. |
| `CampaignAssetService` | Service to manage campaign assets. |
| `CampaignAssetSetService` | Service to manage campaign asset sets. |
| `CampaignBidModifierService` | Service to manage campaign bid modifiers. |
| `CampaignBudgetService` | Service to manage campaign budgets. |
| `CampaignConversionGoalService` | Service to manage campaign conversion goals. |
| `CampaignCriterionService` | Service to manage campaign criteria. |
| `CampaignCustomizerService` | Service to manage campaign customizer. |
| `CampaignDraftService` | Service to manage campaign drafts. |
| `CampaignGoalConfigService` | Service to manage campaign goal configs. |
| `CampaignGroupService` | Service to manage campaign groups. |
| `CampaignLabelService` | Service to manage labels on campaigns. |
| `CampaignLifecycleGoalService` | Service to configure campaign lifecycle goals. |
| `CampaignService` | Service to manage campaigns. |
| `CampaignSharedSetService` | Service to manage campaign shared sets. |
| `ConversionActionService` | Service to manage conversion actions. |
| `ConversionAdjustmentUploadService` | Service to upload conversion adjustments. |
| `ConversionCustomVariableService` | Service to manage conversion custom variables. |
| `ConversionGoalCampaignConfigService` | Service to manage conversion goal campaign config. |
| `ConversionUploadService` | Service to upload conversions. |
| `ConversionValueRuleService` | Service to manage conversion value rules. |
| `ConversionValueRuleSetService` | Service to manage conversion value rule sets. |
| `CustomAudienceService` | Service to manage custom audiences. |
| `CustomConversionGoalService` | Service to manage custom conversion goals. |
| `CustomInterestService` | Service to manage custom interests. |
| `CustomerAssetService` | Service to manage customer assets. |
| `CustomerAssetSetService` | Service to manage customer asset sets. |
| `CustomerClientLinkService` | Service to manage customer client links. |
| `CustomerConversionGoalService` | Service to manage customer conversion goals. |
| `CustomerCustomizerService` | Service to manage customer customizer. |
| `CustomerLabelService` | Service to manage labels on customers. |
| `CustomerLifecycleGoalService` | Service to configure customer lifecycle goals. |
| `CustomerManagerLinkService` | Service to manage customer-manager links. |
| `CustomerNegativeCriterionService` | Service to manage customer negative criteria. |
| `CustomerService` | Service to manage customers. |
| `CustomerSkAdNetworkConversionValueSchemaService` | Service to manage CustomerSkAdNetworkConversionValueSchema. |
| `CustomerUserAccessInvitationService` | This service manages the access invitation extended to users for a given customer. |
| `CustomerUserAccessService` | This service manages the permissions of a user on a given customer. |
| `CustomizerAttributeService` | Service to manage customizer attributes. |
| `DataLinkService` | This service allows management of data links between a Google Ads customer and another data entity. |
| `ExperimentArmService` | Service to manage experiment arms. |
| `ExperimentService` | Service to manage experiments. |
| `GeoTargetConstantService` | Service to fetch geo target constants. |
| `GoalService` | Service to manage goals. |
| `GoogleAdsFieldService` | Service to fetch Google Ads API fields. |
| `GoogleAdsService` | Service to fetch data and metrics across resources. |
| `IdentityVerificationService` | A service for managing Identity Verification Service. |
| `IncentiveService` | Service to support incentive related operations. |
| `InvoiceService` | A service to fetch invoices issued for a billing setup during a given month. |
| `KeywordPlanAdGroupKeywordService` | Service to manage Keyword Plan ad group keywords. Max 10,000 positive keywords and 1,000 negative keywords per plan. |
| `KeywordPlanAdGroupService` | Service to manage Keyword Plan ad groups. |
| `KeywordPlanCampaignKeywordService` | Service to manage Keyword Plan campaign keywords (negative keywords). |
| `KeywordPlanCampaignService` | Service to manage Keyword Plan campaigns. |
| `KeywordPlanIdeaService` | Service to generate keyword ideas. |
| `KeywordPlanService` | Service to manage keyword plans. |
| `KeywordThemeConstantService` | Service to fetch Smart Campaign keyword themes. |
| `LabelService` | Service to manage labels. |
| `LocalServicesLeadService` | This service allows management of LocalServicesLead resources. |
| `OfflineUserDataJobService` | Service to manage offline user data jobs. |
| `PaymentsAccountService` | Service to provide payments accounts that can be used to set up consolidated billing. |
| `ProductLinkInvitationService` | This service allows management of product link invitations from Google Ads accounts to other accounts. |
| `ProductLinkService` | This service allows management of links between a Google Ads customer and another product. |
| `RecommendationService` | Service to manage recommendations. |
| `RecommendationSubscriptionService` | Service to manage recommendation subscriptions. |
| `RemarketingActionService` | Service to manage remarketing actions. |
| `ShareablePreviewService` | Service to generate Shareable Previews. |
| `SharedCriterionService` | Service to manage shared criteria. |
| `SharedSetService` | Service to manage shared sets. |
| `SmartCampaignSettingService` | Service to manage Smart campaign settings. |
| `SmartCampaignSuggestService` | Service to get suggestions for Smart Campaigns. |
| `ThirdPartyAppAnalyticsLinkService` | This service allows management of links between Google Ads and third party app analytics. |
| `TravelAssetSuggestionService` | Service to retrieve Travel asset suggestions. |
| `UserDataService` | Service to manage user list customer types. |
| `UserListService` | Service to manage user lists. |
| `YouTubeVideoUploadService` | Service to manage YouTube video uploads. |
| `ContentCreatorInsightsService` | Service for content creator insights. |

---

## Key Resources (partial list from v23)

Resources represent entities in Google Ads. All resource names follow the pattern:
`customers/{customer_id}/{resource_type}/{resource_id}`

Key resources include:

| Resource | Description |
|----------|-------------|
| `AccessibleBiddingStrategy` | View of BiddingStrategies owned by and shared with the customer |
| `Ad` | An ad |
| `AdGroup` | An ad group |
| `AdGroupAd` | An ad group ad (links Ad to AdGroup) |
| `AdGroupCriterion` | An ad group criterion (targeting) |
| `BiddingStrategy` | A bidding strategy |
| `Campaign` | A campaign |
| `CampaignBudget` | A campaign budget |
| `CampaignCriterion` | A campaign-level criterion |
| `ConversionAction` | A conversion action |
| `Customer` | A Google Ads customer account |
| `KeywordPlan` | A keyword plan |
| `Label` | A label |
| `UserList` | A user list (audience) |

---

## Common API Endpoints

### GoogleAdsService (most commonly used)
- `Search` — Paginated query
- `SearchStream` — Streaming query

### CampaignService
- `MutateCampaigns` — Create/update/remove campaigns

### AdGroupService
- `MutateAdGroups` — Create/update/remove ad groups

### AdGroupAdService
- `MutateAdGroupAds` — Create/update/remove ads in an ad group

### AdGroupCriterionService
- `MutateAdGroupCriteria` — Manage keywords and other ad group criteria

### CampaignCriterionService
- `MutateCampaignCriteria` — Manage campaign-level targeting

### ConversionUploadService
- `UploadClickConversions` — Upload offline click conversions
- `UploadCallConversions` — Upload offline call conversions

---

## Notes on API Version

- Current version: **v23** (as of 2026-03-01)
- Older versions are deprecated on a schedule — check the sunset dates page
- The `latest` URL alias always redirects to the current production version

---
*Content from: https://developers.google.com/google-ads/api/reference/rpc/v23/overview*
*Licensed under Creative Commons Attribution 4.0 License.*
