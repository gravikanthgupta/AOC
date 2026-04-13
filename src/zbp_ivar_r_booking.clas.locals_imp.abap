CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_Bookingsupplement.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.
    DATA: max_booking_suppl_id TYPE /dmo/booking_supplement_id .

    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
      ENTITY booking BY \_BookingSupplement
        FROM CORRESPONDING #( entities )
        LINK DATA(booking_supplements).

    " Loop over all unique tky (TravelID + BookingID)
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>) GROUP BY <booking>-%tky.

      " Get highest bookingsupplement_id from bookings belonging to booking
      max_booking_suppl_id = REDUCE #( INIT max = CONV /dmo/booking_supplement_id( '0' )
                                       FOR  booksuppl IN booking_supplements USING KEY entity
                                                                             WHERE (     source-travelid  = <booking>-travelid
                                                                                     AND source-bookingid = <booking>-bookingid )
                                       NEXT max = COND /dmo/booking_supplement_id( WHEN   booksuppl-target-bookingsupplementid > max
                                                                          THEN booksuppl-target-bookingsupplementid
                                                                          ELSE max )
                                     ).
      " Get highest assigned bookingsupplement_id from incoming entities
      max_booking_suppl_id = REDUCE #( INIT max = max_booking_suppl_id
                                       FOR  entity IN entities USING KEY entity
                                                               WHERE (     travelid  = <booking>-travelid
                                                                       AND bookingid = <booking>-bookingid )
                                       FOR  target IN entity-%target
                                       NEXT max = COND /dmo/booking_supplement_id( WHEN   target-bookingsupplementid > max
                                                                                     THEN target-bookingsupplementid
                                                                                     ELSE max )
                                     ).


      " Assign new booking_supplement-ids
      LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<booksuppl_wo_numbers>).
        APPEND CORRESPONDING #( <booksuppl_wo_numbers> ) TO mapped-booksuppl ASSIGNING FIELD-SYMBOL(<mapped_booksuppl>).
        IF <booksuppl_wo_numbers>-bookingsupplementid IS INITIAL.
          max_booking_suppl_id += 1 .
          <mapped_booksuppl>-bookingsupplementid = max_booking_suppl_id .
        ENDIF.
      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD calculateTotalPrice.
*    Invoke reusable method reCalcTotalPrice using execute in modify
    MODIFY ENTITIES OF zivar_r_travel IN LOCAL MODE
      ENTITY travel
          EXECUTE reCalcTotalPrice
              FROM CORRESPONDING #( keys ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
