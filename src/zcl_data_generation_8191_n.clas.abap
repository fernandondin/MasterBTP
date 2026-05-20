CLASS zcl_data_generation_8191_n DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_data_generation_8191_n IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM ztravel_8191_ac.
    INSERT ztravel_8191_ac FROM (
        SELECT FROM /dmo/travel
        FIELDS
        "client
        uuid( ) AS travel_uuid,
        travel_id,
        agency_id,
        customer_id,
        begin_date,
        end_date,
        booking_fee,
        total_price,
        currency_code,
        description,
        CASE status WHEN 'B' THEN 'A'
        WHEN 'P' THEN 'O'
        WHEN 'N' THEN 'O'
        ELSE 'X' END AS overall_status,
        createdby AS local_created_by,
        createdat AS local_created_at,
        lastchangedby AS local_last_changed_by,
        lastchangedat AS local_last_changed_at,
        lastchangedat AS last_changed_at ).
        out->write( 'Adding Booking data' ).

        DELETE FROM zbooking_8191_ac.
        INSERT zbooking_8191_ac FROM (
        SELECT
            FROM /dmo/booking
            JOIN ztravel_8191_ac ON /dmo/booking~travel_id = ztravel_8191_ac~travel_id
            JOIN /dmo/travel ON /dmo/travel~travel_id = /dmo/booking~travel_id
            FIELDS "Client
                uuid( ) AS booking_uuid,
                ztravel_8191_ac~travel_uuid AS parent_uuid,
                /dmo/booking~booking_id,
                /dmo/booking~booking_date,
                /dmo/booking~customer_id,
                /dmo/booking~carrier_id,
                /dmo/booking~connection_id,
                /dmo/booking~flight_date,
                /dmo/booking~flight_price,
                /dmo/booking~currency_code,
                CASE /dmo/travel~status wHEN 'P' THEN 'N'
                                                 ELSE /dmo/travel~status end as booking_status,
                ztravel_8191_ac~last_changed_at as local_last_changed_at ).

         DELETE FROM zbksppl_8191_ac.
         out->write( 'Adding Booking Supplements data' ).
         INSERT zbksppl_8191_ac FROM (
           SELECT FROM /dmo/book_suppl AS supp
                   JOIN ztravel_8191_ac AS trvl ON trvl~travel_id = supp~travel_id
                   JOIN zbooking_8191_ac AS book ON book~parent_uuid = trvl~travel_uuid
                   AND book~booking_id = supp~booking_id
                   FIELDS
                   uuid( )  AS booksuppl_uuid,
                   trvl~travel_uuid AS root_uuid,
                   book~booking_uuid AS parent_uuid,
                   supp~booking_supplement_id,
                   supp~supplement_id,
                   supp~price,
                   supp~currency_code,
                   trvl~last_changed_at AS local_last_changed_at ).
  ENDMETHOD.

ENDCLASS.
