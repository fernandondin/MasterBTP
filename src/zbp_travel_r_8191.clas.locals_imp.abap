CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF travel_status,
        open     TYPE c LENGTH 1 VALUE 'O', "Open
        accepted TYPE c LENGTH 1 VALUE 'A', "Accepted
        rejected TYPE c LENGTH 1 VALUE 'X', "Rejected
      END OF travel_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS deductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~deductDiscount RESULT result.

    METHODS reCalcTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~reCalcTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS Resume FOR MODIFY
      IMPORTING keys FOR ACTION Travel~Resume.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS setStatusToOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStatusToOpen.

    METHODS setTravelNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelNumber.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
    "EML
    READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                              %field-BookingFee =
                                              COND #( WHEN travel-OverallStatus = travel_status-accepted
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                                              %action-acceptTravel =
                                              COND #( WHEN travel-OverallStatus = travel_status-accepted
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )
                                              %action-rejectTravel =
                                              COND #( WHEN travel-OverallStatus = travel_status-rejected
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )
                                              %action-deductDiscount =
                                              COND #( WHEN travel-OverallStatus = travel_status-accepted
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )
                                              %assoc-_Booking =
                                              COND #( WHEN travel-OverallStatus = travel_status-rejected
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )
                                               ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA: update_requested TYPE abap_bool,
          update_granted   TYPE abap_bool,
          delete_granted   TYPE abap_bool,
          delete_requested TYPE abap_bool.

    READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( AgencyID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    update_requested = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on
                                OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                                THEN abap_true
                                ELSE abap_false ).

    delete_requested = COND #( WHEN requested_authorizations-%delete = if_abap_behv=>mk-on
                                THEN abap_true
                                ELSE abap_false ).

    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).

    LOOP AT travels INTO DATA(travel).
      "Update
      IF update_requested = abap_true.
        IF lv_technical_name = 'CB99880008191' AND travel-AgencyID NE '70014'.
          update_granted = abap_true.
        ELSE.
          update_granted = abap_false.
          APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                      agency_id = travel-AgencyID
                                                      severity = if_abap_behv_message=>severity-error )
                  %global = if_abap_behv=>mk-on ) TO reported-travel.
        ENDIF.

      ENDIF.
      "Delete
      IF delete_requested = abap_true.
        IF lv_technical_name = 'CB99880008191' AND travel-AgencyID NE '70014'.
          delete_granted = abap_true.
        ELSE.
          delete_granted = abap_false.
          APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                          agency_id = travel-AgencyID
                          severity = if_abap_behv_message=>severity-error )
                          %global = if_abap_behv=>mk-on ) TO reported-travel.
        ENDIF.

      ENDIF.
      "SetResult
      APPEND VALUE #( LET upd_auth = COND #( WHEN update_granted = abap_true
                                             THEN if_abap_behv=>auth-allowed
                                             ELSE if_abap_behv=>auth-unauthorized )
                          del_auth = COND #( WHEN delete_granted = abap_true
                                             THEN if_abap_behv=>auth-allowed
                                             ELSE if_abap_behv=>auth-unauthorized )
                          IN
                          %tky = travel-%tky
                          %update = upd_auth
                          %action-edit = upd_auth
                          %delete = del_auth ) TO result.
    ENDLOOP.


  ENDMETHOD.

  METHOD get_global_authorizations.
    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).
*Create
    IF requested_authorizations-%create EQ if_abap_behv=>mk-on.
      IF lv_technical_name = 'CB99880008191'.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_authorized
                                                            severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDIF.
    "Delete
    IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.
      IF lv_technical_name = 'CB99880008191'.
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_authorized
                                                            severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDIF.
    "Update
    IF requested_authorizations-%update EQ if_abap_behv=>mk-on OR
       requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on.
      IF lv_technical_name = 'CB99880008191'.
        result-%update = if_abap_behv=>auth-allowed.
        result-%action-Edit = if_abap_behv=>auth-allowed.
      ELSE.
        result-%update = if_abap_behv=>auth-unauthorized.
        result-%action-Edit = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_authorized
                                                            severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD acceptTravel.

    "EML
    MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                    OverallStatus = travel_status-accepted ) ).

    READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                              %param = travel ) ).

  ENDMETHOD.

  METHOD deductDiscount.

    data travels_for_update TYPE TABLE FOR UPDATE ztravel_r_8191.
    DATA(keys_discount) = keys.

    LOOP AT keys_discount ASSIGNING FIELD-SYMBOL(<key_discount>)
                          WHERE %param-discount is initial or
                                %param-discount > 100 or
                                %param-discount <= 0.

        APPEND VALUE #( %tky = <key_discount>-%tky ) to failed-travel.

        APPEND VALUE #( %tky = <key_discount>-%tky
                        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>discount_invalid
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-BookingFee = if_abap_behv=>mk-on
                        %op-%action-deductDiscount = if_abap_behv=>mk-on ) TO reported-travel.


    endloop.

    CHECK failed-travel is initial.
    READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BookingFee )
    WITH CORRESPONDING #( keys_discount )
    RESULT DATA(travels).

    DATA percentage TYPE decfloat16.
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
        DATA(discount_percent) = keys_discount[ key id %tky = <travel>-%tky ]-%param-discount.
        percentage = discount_percent / 100.
        data(reduce_fee) = <travel>-BookingFee * ( 1 - percentage ).
        APPEND VALUE #( %tky = <travel>-%tky
                        bookingfee = reduce_fee ) to travels_for_update.
    ENDLOOP.

    MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( BookingFee )
    WITH travels_for_update.

    READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(travels_discount).

    result = VALUE #( FOR travel IN travels_discount ( %tky = travel-%tky
                                                       %param = travel ) ).

  ENDMETHOD.

  METHOD reCalcTotalPrice.

    TYPES: BEGIN OF ty_amount_per_curr,
            amount TYPE /dmo/total_price,
            currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_curr.

DATA: amount_per_curr TYPE STANDARD TABLE OF ty_amount_per_curr.

READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DELETE travels where CurrencyCode Is INITIAL.

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

        amount_per_curr = VALUE #( ( amount = <travel>-BookingFee
                                   currency_code = <travel>-CurrencyCode ) ).
        "Read Bookings
         READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
        ENTITY Travel by \_Booking
        FIELDS ( FlightPrice CurrencyCode )
        WITH Value #( ( %tky = <travel>-%tky ) )
        RESULT DATA(bookings).

        LOOP AT bookings into DATA(booking) WHERE CurrencyCode is not initial.
            COLLECT VALUE ty_amount_per_curr( amount = booking-FlightPrice
                                              currency_code = booking-CurrencyCode ) into amount_per_curr.
        ENDLOOP.

        "Read Bookings supplements
         READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
        ENTITY Booking by \_BookingSupplement
        FIELDS ( Price CurrencyCode )
        WITH Value #( for r_booking in bookings ( %tky = r_booking-%tky ) )
        RESULT DATA(bookingSupplements).

        LOOP AT bookingsupplements into DATA(bookingSupplement) WHERE CurrencyCode is not initial.
            COLLECT VALUE ty_amount_per_curr( amount = bookingsupplement-Price                                              currency_code = bookingsupplement-CurrencyCode ) into amount_per_curr.
        ENDLOOP.

        clear: <travel>-TotalPrice.
        LOOP AT amount_per_curr into DATA(single_amt_per_curr).
            "Currency Conversion
            if single_amt_per_curr-currency_code = <travel>-CurrencyCode.
                <travel>-TotalPrice += single_amt_per_curr-amount.
                else.
                    /dmo/cl_flight_amdp=>convert_currency(
                        EXPORTING
                            iv_amount  = single_amt_per_curr-amount
                            iv_currency_code_source = single_amt_per_curr-currency_code
                            iv_currency_code_target = <travel>-CurrencyCode
                            iv_exchange_rate_date = cl_abap_context_info=>get_system_date(  )
                        IMPORTING
                            ev_amount = DATA(total_booking_price_per_curr)
                     ).
                      <travel>-TotalPrice += total_booking_price_per_curr.
            ENDIF.
        ENDLOOP.

        "Write back the modified total price
        MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
        ENTITY Travel
        UPDATE
        FIELDS ( TotalPrice )
        WITH CORRESPONDING #( travels ).

    ENDLOOP.



  ENDMETHOD.

  METHOD rejectTravel.
    "EML
    MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                    OverallStatus = travel_status-rejected ) ).

    READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                              %param = travel ) ).
  ENDMETHOD.

  METHOD Resume.
  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    EXECUTE reCalcTotalPrice
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD setStatusToOpen.

    "EML
    READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DELETE travels WHERE OverallStatus IS NOT INITIAL.

    CHECK travels IS NOT INITIAL.

    "EML
    MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( OverallStatus )
    WITH VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                          OverallStatus = travel-OverallStatus ) ).

  ENDMETHOD.

  METHOD setTravelNumber.

    "EML
    READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DELETE travels WHERE TravelID IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    SELECT SINGLE FROM ztravel_8191_ac
    FIELDS MAX( travel_id )
    INTO @DATA(max_TravelID).

    "EML
    MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
      ENTITY Travel
      UPDATE
      FIELDS ( TravelID )
      WITH VALUE #( FOR travel IN travels INDEX INTO i ( %tky = travel-%tky
                                                         TravelID = max_TravelID + i ) ).

  ENDMETHOD.

  METHOD validateAgency.
  ENDMETHOD.

  METHOD validateCustomer.

    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY client customer_id.
    "EML
    READ ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    customers = CORRESPONDING #( travels
                                 DISCARDING DUPLICATES MAPPING
                                 customer_id = CustomerID
                                 EXCEPT * ).
    DELETE customers WHERE customer_id IS INITIAL.
    IF customers IS NOT INITIAL.
      SELECT FROM /dmo/customer AS db
          INNER JOIN @customers AS it
          ON db~customer_id = it~customer_id
          FIELDS db~customer_id
          INTO TABLE @DATA(valid_customers).

    ENDIF.

    LOOP AT travels INTO DATA(travel).
      APPEND VALUE #( %tky = travel-%tky
                      %state_area = 'VALIDATE_CUSTOMER' ) TO reported-travel.
      IF travel-CustomerID IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) to failed-travel.

        APPEND VALUE #( %tky = travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>enter_customer_id
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-CustomerID = if_abap_behv=>mk-on ) TO reported-travel.
        ELSEIF not line_exists( valid_customers[ customer_id = travel-CustomerID ] ).
            APPEND VALUE #( %tky = travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>customer_unkown
                                                            customer_id = travel-CustomerID
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-CustomerID = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateDates.
  ENDMETHOD.

ENDCLASS.
