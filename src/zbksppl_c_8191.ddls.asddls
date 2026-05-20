@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking supplement -consumption entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZBKSPPL_C_8191 as projection on zbksppl_r_8191
{
    key BooksupplUUID,
    TravelUUID,
    BookingUUID,
    BookingSupplementID,
    SupplementID,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LocalLastChangedAt,
    /* Associations */
    _Booking: redirected to parent ZBOOKING_C_8191,
    _Product,
    _SupplementText,
    _Travel: redirected to ZTRAVEL_C_8191
}
