@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking consumption entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZBOOKING_C_8191
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
      LocalLastChangedAt,
      
      /* Associations */
      _BookingStatus,
      _BookingSupplement: redirected to composition child ZBKSPPL_C_8191,
      _Carrier,
      _Connection,
      _Customer,
      _Travel : redirected to parent ZTRAVEL_C_8191
}
