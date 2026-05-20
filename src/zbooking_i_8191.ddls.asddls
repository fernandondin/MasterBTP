@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking interface entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity zbooking_i_8191 
as projection on zbooking_r_8191
{
    key BookingUUID,
    TravelUUUID,
    BookingID,
    BookingDate,
    CustomerID,
    AirlineID,
    ConnectionID,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    LocalLastChangedAt,
    /* Associations */
    _BookingStatus,
    _BookingSupplement : redirected to composition child ZBKSPPL_I_8191 ,
    _Carrier,
    _Connection,
    _Customer,
    _Travel : redirected to parent ZTRAVEL_I_8191
}
