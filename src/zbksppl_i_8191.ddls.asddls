@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking supplement -Interface entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZBKSPPL_I_8191 as projection on zbksppl_r_8191
{
    key BooksupplUUID,
    TravelUUID,
    BookingUUID,
    BookingSupplementID,
    SupplementID,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    LocalLastChangedAt,
    /* Associations */
    _Booking: redirected to parent zbooking_i_8191,
    _Product,
    _SupplementText,
    _Travel: redirected to ZTRAVEL_I_8191
}
