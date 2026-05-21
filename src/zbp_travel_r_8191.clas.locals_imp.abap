CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
        BEGIN OF travel_status,
        open     TYPE C LENGTH 1 VALUE 'O', "Open
        accepted TYPE C LENGTH 1 VALUE 'A', "Accepted
        rejected TYPE C LENGTH 1 VALUE 'X', "Rejected
        END OF TRAVEL_STATUS.

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

    result = VALUE #( for travel in travels ( %tky = travel-%tky
                                              %field-BookingFee =
                                              cond #( when travel-OverallStatus = travel_status-accepted
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      else if_abap_behv=>fc-f-unrestricted )
                                              %action-acceptTravel =
                                              cond #( when travel-OverallStatus = travel_status-accepted
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )
                                              %action-rejectTravel =
                                              cond #( when travel-OverallStatus = travel_status-rejected
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )
                                              %action-deductDiscount =
                                              cond #( when travel-OverallStatus = travel_status-accepted
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )
                                              %assoc-_Booking =
                                              cond #( when travel-OverallStatus = travel_status-rejected
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )
                                               ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.



  ENDMETHOD.

  METHOD get_global_authorizations.
    data(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).
*Create
    if requested_authorizations-%create eq if_abap_behv=>mk-on.
        if lv_technical_name = 'CB99880008191'.
            result-%create = if_abap_behv=>auth-allowed.
            else.
            result-%create = if_abap_behv=>auth-unauthorized.
            APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_authorized
                                                                severity = if_abap_behv_message=>severity-error )
                            %global = if_abap_behv=>mk-on ) to reported-travel.
        endif.
    ENDIF.
"Delete
    if requested_authorizations-%delete eq if_abap_behv=>mk-on.
        if lv_technical_name = 'CB99880008191'.
            result-%delete = if_abap_behv=>auth-allowed.
            else.
            result-%delete = if_abap_behv=>auth-unauthorized.
            APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_authorized
                                                                severity = if_abap_behv_message=>severity-error )
                            %global = if_abap_behv=>mk-on ) to reported-travel.
        endif.
    ENDIF.
"Update
    if requested_authorizations-%update eq if_abap_behv=>mk-on or
       requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on.
        if lv_technical_name = 'CB99880008191'.
            result-%update = if_abap_behv=>auth-allowed.
            result-%action-Edit = if_abap_behv=>auth-allowed.
            else.
            result-%update = if_abap_behv=>auth-unauthorized.
            result-%action-Edit = if_abap_behv=>auth-unauthorized.
            APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_authorized
                                                                severity = if_abap_behv_message=>severity-error )
                            %global = if_abap_behv=>mk-on ) to reported-travel.
        endif.
    ENDIF.
  ENDMETHOD.

  METHOD acceptTravel.

    "EML
    MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( OverallStatus )
    WITH VALUE #( for key in keys ( %tky = key-%tky
                                    OverallStatus = travel_status-accepted ) ).

    READ ENTITIES OF ztravel_r_8191 in LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( for travel in travels ( %tky = travel-%tky
                                              %param = travel ) ).

  ENDMETHOD.

  METHOD deductDiscount.
  ENDMETHOD.

  METHOD reCalcTotalPrice.



  ENDMETHOD.

  METHOD rejectTravel.
    "EML
    MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( OverallStatus )
    WITH VALUE #( for key in keys ( %tky = key-%tky
                                    OverallStatus = travel_status-rejected ) ).

    READ ENTITIES OF ztravel_r_8191 in LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( for travel in travels ( %tky = travel-%tky
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
    READ ENTITIES OF ztravel_r_8191 in LOCAL MODE
    entity Travel
    FIELDS ( OverallStatus )
    with CORRESPONDING #( keys )
    RESULT DATA(travels).

    delete travels WHERE OverallStatus is not INITIAL.

    check travels is not INITIAL.

   "EML
   MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
   ENTITY Travel
   UPDATE
   FIELDS ( OverallStatus )
   WITH VALUE #( for travel in travels ( %tky = travel-%tky
                                         OverallStatus = travel-OverallStatus ) ).

  ENDMETHOD.

  METHOD setTravelNumber.

    "EML
    READ ENTITIES OF ztravel_r_8191 in LOCAL MODE
    entity Travel
    FIELDS ( TravelID )
    with CORRESPONDING #( keys )
    RESULT DATA(travels).

    delete travels WHERE TravelID is not initial.
    check travels is not initial.

    select single from ztravel_8191_ac
    FIELDS max( travel_id )
    into @DATA(max_TravelID).

    "EML
     MODIFY ENTITIES OF ztravel_r_8191 IN LOCAL MODE
       ENTITY Travel
       UPDATE
       FIELDS ( TravelID )
       WITH VALUE #( for travel in travels INDEX INTO i ( %tky = travel-%tky
                                                          TravelID = max_TravelID + i ) ).

  ENDMETHOD.

  METHOD validateAgency.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateDates.
  ENDMETHOD.

ENDCLASS.
