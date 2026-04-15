CLASS lhc_booksuppl DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookSuppl~calculateTotalPrice.

ENDCLASS.

CLASS lhc_booksuppl IMPLEMENTATION.

  METHOD calculateTotalPrice.

*    DATA travel_ids TYPE STANDARD TABLE OF /DMO/I_BookSuppl_M  WITH UNIQUE HASHED KEY key COMPONENTS travel_id booking_id booking_supplement_id.
*
*    travel_ids = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING travel_id = TravelId booking_id = BookingId booking_supplement_id = BookingSupplementId ).

    TYPES: ty_travel LIKE LINE OF keys.

    DATA travel_ids TYPE STANDARD TABLE OF ty_travel WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    travel_ids = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId %is_draft = %is_draft ).

*    Invoke reusable method reCalcTotalPrice using execute in modify
    MODIFY ENTITIES OF zivar_r_travel IN LOCAL MODE
      ENTITY travel
          EXECUTE reCalcTotalPrice
              FROM CORRESPONDING #( travel_ids ).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
