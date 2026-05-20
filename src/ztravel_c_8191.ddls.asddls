@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel - consumption entity'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'TravelID' ]
define root view entity ZTRAVEL_C_8191
provider contract transactional_query
  as projection on ZTRAVEL_R_8191
{
  key TravelUUID,
      @Search.defaultSearchElement: true
      TravelID,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Agency_StdVH',
                                                     element: 'AgencyID'},
                                           useForValidation: true }]
      AgencyID,
      _Agency.Name as AgencyName,
      
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer_StdVH',
                                                     element: 'CustomerID'},
                                           useForValidation: true }]
      CustomerID,
      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @EndUserText.label: 'VAT Include'
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEM_SADL_8191'
      virtual PriceWithVat : /dmo/total_price,
      
       @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                     element: 'Currency'},
                                           useForValidation: true }]
      CurrencyCode,
      Description,
      @ObjectModel.text.element: [ 'OverallStatusText' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Overall_Status_VH',
                                                     element: 'OverallStatus'},
                                           useForValidation: true }]
      OverallStatus,
      _OverallStatus._Text.Text as OverallStatusText : localized,
//      _OverallStatus._Text[ 1:Language = $session.system_language].Text as OverallStatusText,
      
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
