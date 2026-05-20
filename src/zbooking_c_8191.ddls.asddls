@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking consumption entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'BookingID' ]
define view entity ZBOOKING_C_8191
  as projection on zbooking_r_8191
{
  key BookingUUID,
      TravelUUUID,
      @Search.defaultSearchElement: true
      BookingID,
      BookingDate,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer_StdVH',
                                                     element: 'CustomerID'},
                                           useForValidation: true }]
      CustomerID,
       _Customer.LastName as CustomerName,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CarrierName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Flight_StdVH',
                                                    element: 'AirlineID'},
                                           additionalBinding: [{ localElement: 'ConnectionID',
                                                                 element: 'ConnectionID',
                                                                 usage: #RESULT },

                                                                { localElement: 'FlightDate',
                                                                 element: 'FlightDate',
                                                                 usage: #RESULT },

                                                                 { localElement: 'FlightPrice',
                                                                 element: 'Price',
                                                                 usage: #RESULT },

                                                                 { localElement: 'CurrencyCode',
                                                                 element: 'CurrencyCode',
                                                                 usage: #RESULT }],

                                          useForValidation: true }]
      AirlineID,
      _Carrier.Name      as CarrierName,
       @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Flight_StdVH',
                                                   element: 'ConnectionID'},
                                          additionalBinding: [{ localElement: 'AirlineID',
                                                                element: 'AirlineID',
                                                                usage: #FILTER_AND_RESULT },

                                                               { localElement: 'FlightDate',
                                                                element: 'FlightDate',
                                                                usage: #RESULT },

                                                                { localElement: 'FlightPrice',
                                                                element: 'Price',
                                                                usage: #RESULT },

                                                                { localElement: 'CurrencyCode',
                                                                element: 'CurrencyCode',
                                                                usage: #RESULT }],

                                         useForValidation: true }]
      ConnectionID,
       @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Flight_StdVH',
                                                       element: 'FlightDate'},
                                              additionalBinding: [{ localElement: 'AirlineID',
                                                                    element: 'AirlineID',
                                                                    usage: #FILTER_AND_RESULT },

                                                                   { localElement: 'ConnectionID',
                                                                    element: 'ConnectionID',
                                                                    usage: #FILTER_AND_RESULT },

                                                                    { localElement: 'FlightPrice',
                                                                    element: 'Price',
                                                                    usage: #RESULT },

                                                                    { localElement: 'CurrencyCode',
                                                                    element: 'CurrencyCode',
                                                                    usage: #RESULT }],

                                             useForValidation: true }]
      FlightDate,
       @Semantics.amount.currencyCode: 'CurrencyCode'
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Flight_StdVH',
                                                       element: 'Price'},
                                              additionalBinding: [{ localElement: 'AirlineID',
                                                                    element: 'AirlineID',
                                                                    usage: #FILTER_AND_RESULT },

                                                                   { localElement: 'ConnectionID',
                                                                    element: 'ConnectionID',
                                                                    usage: #FILTER_AND_RESULT },

                                                                    { localElement: 'FlightDate',
                                                                    element: 'FlightDate',
                                                                    usage: #FILTER_AND_RESULT },

                                                                    { localElement: 'CurrencyCode',
                                                                    element: 'CurrencyCode',
                                                                    usage: #RESULT }],

                                             useForValidation: true }]
      FlightPrice,
       @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                     element: 'Currency' },
                                           useForValidation: true }]
      CurrencyCode,
       @ObjectModel.text.element: [ 'BookingStatusText' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Booking_Status_VH',
                                                     element: 'BookingStatus'},
                                           useForValidation: true }]
      BookingStatus,
       _BookingStatus._Text.Text as BookingStatusText : localized,
      LocalLastChangedAt,
      
      /* Associations */
      _BookingStatus,
      _BookingSupplement: redirected to composition child ZBKSPPL_C_8191,
      _Carrier,
      _Connection,
      _Customer,
      _Travel : redirected to parent ZTRAVEL_C_8191
}
