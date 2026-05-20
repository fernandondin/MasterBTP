@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel - consumption entity'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
define root view entity ZTRAVEL_C_8191
provider contract transactional_query
  as projection on ZTRAVEL_R_8191
{
  key TravelUUID,
      TravelID,
      AgencyID,
      CustomerID,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
      /* Associations */
      _Agency,
      _Booking: redirected to composition child ZBOOKING_C_8191,
      _Currency,
      _Customer,
      _OverallStatus
}
