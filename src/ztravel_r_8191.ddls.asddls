@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel - Root entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZTRAVEL_R_8191 as select from ztravel_8191_ac
//composition of target_data_source_name as _association_name
{
key travel_uuid as TravelUUID,
travel_id as TravelID,
agency_id as AgencyID,
customer_id as CustomerID,
begin_date as BeginDate,
end_date as EndDate,

@Semantics.amount.currencyCode: 'CurrencyCode'
booking_fee as BookingFee,
@Semantics.amount.currencyCode: 'CurrencyCode'
total_price as TotalPrice,
currency_code as CurrencyCode,
description as Description,
overall_status as OverallStatus,

@Semantics.user.createdBy: true
local_created_by as LocalCreatedBy,
@Semantics.systemDateTime.createdAt: true
local_created_at as LocalCreatedAt,
@Semantics.user.localInstanceLastChangedBy: true
local_last_changed_by as LocalLastChangedBy,

// Local ETAg Field --> OData Etaf Manejo de concurrencia
@Semantics.systemDateTime.localInstanceLastChangedAt: true
local_last_changed_at as LocalLastChangedAt,

// Total ETag Field
@Semantics.systemDateTime.lastChangedAt: true
last_changed_at as LastChangedAt
    
//    _association_name // Make association public
}
