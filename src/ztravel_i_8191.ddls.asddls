@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel - Interface entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZTRAVEL_I_8191 
provider contract transactional_interface
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
    
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    LocalLastChangedAt,
    @Semantics.systemDateTime.lastChangedAt: true
    LastChangedAt,
    /* Associations */
    _Agency,
    _Booking : redirected to composition child zbooking_i_8191,
    _Currency,
    _Customer,
    _OverallStatus
}
