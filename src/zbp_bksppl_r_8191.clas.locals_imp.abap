CLASS lhc_BookingSupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR BookingSupplement RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR BookingSupplement RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookingSupplement~calculateTotalPrice.

    METHODS setBookSupplNumber FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookingSupplement~setBookSupplNumber.

    METHODS validateCurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR BookingSupplement~validateCurrency.

    METHODS validatePrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR BookingSupplement~validatePrice.

    METHODS validateSupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR BookingSupplement~validateSupplement.

ENDCLASS.

CLASS lhc_BookingSupplement IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD calculateTotalPrice.
  ENDMETHOD.

  METHOD setBookSupplNumber.
  ENDMETHOD.

  METHOD validateCurrency.
  ENDMETHOD.

  METHOD validatePrice.
  ENDMETHOD.

  METHOD validateSupplement.
  ENDMETHOD.

ENDCLASS.
