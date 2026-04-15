CLASS lsc_zivar_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zivar_r_travel IMPLEMENTATION.

  METHOD save_modified.
    DATA: travel_log_update TYPE STANDARD TABLE OF /dmo/log_travel,
          final_changes     TYPE STANDARD TABLE OF /dmo/log_travel.

    IF update-travel IS NOT INITIAL.
      travel_log_update = CORRESPONDING #( update-travel MAPPING
                                              travel_id = TravelId
                                          ).
      LOOP AT update-travel ASSIGNING FIELD-SYMBOL(<travel_log_update>).
        ASSIGN travel_log_update[ travel_id = <travel_log_update>-TravelId ]
            TO FIELD-SYMBOL(<travel_log_db>).

        GET TIME STAMP FIELD <travel_log_db>-created_at.

        IF <travel_log_update>-%control-CustomerId = if_abap_behv=>mk-on.
          <travel_log_db>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
          <travel_log_db>-changed_field_name = 'Ivar_Customer'.
          <travel_log_db>-changed_value = <travel_log_update>-customerId.
          <travel_log_db>-changing_operation = 'Change'.
          APPEND <travel_log_db> TO final_changes.
        ENDIF.

        IF <travel_log_update>-%control-AgencyId = if_abap_behv=>mk-on.
          <travel_log_db>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
          <travel_log_db>-changed_field_name = 'Ivar_Agency'.
          <travel_log_db>-changed_value = <travel_log_update>-AgencyId.
          <travel_log_db>-changing_operation = 'Change'.
          APPEND <travel_log_db> TO final_changes.
        ENDIF.
      ENDLOOP.

      INSERT /dmo/log_travel FROM TABLE @final_changes.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS copyTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~copyTravel.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.

    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calculatetotalprice.
    METHODS validateheaderdata FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateheaderdata.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE Travel\_Booking.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    DATA: ls_result LIKE LINE OF result.

    " Step 1: Get the data of my instance
    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
        ENTITY Travel
            FIELDS ( TravelId OverallStatus )
                WITH CORRESPONDING #( keys )
                    RESULT DATA(lt_travel)
                    FAILED DATA(ls_failed).


    " Step 2: Loop at the data
    LOOP AT lt_travel INTO DATA(ls_travel).

      " Step 3: Check if the instance was having status = cancelled
      IF ( ls_travel-OverallStatus = 'X' ).
        DATA(lv_auth) = abap_false.

        " Step 4: Check for authorization in org
        " Right now we dont have authorization object to check so commented the code.
*            authority-check object 'CUSTOM_OBJ'
*                ID '' field
*        IF sy-subrc <> 0.
*          lv_auth = abap_false.
*        ELSE.
*          lv_auth = abap_true.
*        ENDIF.

      ELSE.
        lv_auth = abap_true.
      ENDIF.

      ls_result = VALUE #( TravelId = ls_travel-TravelId
                           %update = COND #( WHEN lv_auth EQ abap_false
                                                  THEN if_abap_behv=>auth-unauthorized
                                                  ELSE if_abap_behv=>auth-allowed
                                            )
                          %action-copyTravel = COND #( WHEN lv_auth EQ abap_false
                                                  THEN if_abap_behv=>auth-unauthorized
                                                  ELSE if_abap_behv=>auth-allowed
                                            )
                         ).
      APPEND ls_result TO result.


      " Step 5: If permission is denied - Role is not added for user, reject the edit
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA: entity        TYPE STRUCTURE FOR CREATE zivar_r_travel,
          travel_id_max TYPE /dmo/travel_id.

    " Step 1: Check Travel Id is not set in instance
    LOOP AT entities INTO entity WHERE travelId IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-travel.
    ENDLOOP.

    DATA(entities_wo_travelid) = entities.
    DELETE entities_wo_travelid WHERE TravelId IS NOT INITIAL.

    " Step 2: Get the Sequence numbers from SNRO
    TRY.
        " Step 3: If there is an exception throw error
        cl_numberrange_runtime=>number_get(
          EXPORTING
*            ignore_buffer     =
            nr_range_nr       = '01'
            object            = '/DMO/TRAVL'
            quantity          = CONV #( lines( entities_wo_travelid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_qty)
        ).

      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        LOOP AT entities_wo_travelid INTO entity .
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %is_draft = entity-%is_draft
                          %msg = lx_number_ranges )
                        TO reported-travel.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %is_draft = entity-%is_draft )
                        TO failed-travel.
        ENDLOOP.
        EXIT.

    ENDTRY.

    CASE number_range_return_code.
      WHEN '1'.
        " Step 4: Handle special cases where number range exceed critical %
        "1 - the returned number is in a critical range (specified under “percentage warning” in the object definition)
        LOOP AT entities_wo_travelid INTO entity .
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %is_draft = entity-%is_draft
                          %msg = NEW /dmo/cm_flight_messages(
                                  textid = /dmo/cm_flight_messages=>number_range_depleted
                                  severity = if_abap_behv_message=>severity-warning ) )
                       TO reported-travel.
        ENDLOOP.
      WHEN '2' OR '3'.
        " Step 5: Number range return last number, or number exhausted
        " 2 - the last number of the interval was returned
        " 3 - if fewer numbers are available than requested,  the return code is 3
        LOOP AT entities_wo_travelid INTO entity .
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %is_draft = entity-%is_draft
                          %msg = NEW /dmo/cm_flight_messages(
                                  textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                                  severity = if_abap_behv_message=>severity-warning ) )
                       TO reported-travel.

          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                           %is_draft = entity-%is_draft
                          %fail-cause = if_abap_behv=>cause-conflict )
                        TO failed-travel.
        ENDLOOP.
        EXIT.

    ENDCASE.

    " Step 6: Final check for all number
    ASSERT number_range_returned_qty = lines( entities_wo_travelid ).

    " Step 7: Loop over the incoming travel data and assign the numbers from number range and return mapped data
    travel_id_max = number_range_key - number_range_returned_qty.

    LOOP AT entities_wo_travelid INTO entity .
      travel_id_max += 1.
      entity-TravelId = travel_id_max.

      APPEND VALUE #( %cid = entity-%cid
                      %is_draft = entity-%is_draft
                      %key = entity-%key )
                    TO mapped-travel.
    ENDLOOP.
  ENDMETHOD.

  " Create by Association
  METHOD earlynumbering_cba_Booking.
*    DATA max_booking_id TYPE /dmo/booking_id.
*
*    " Step 1: get all the travel requests and their booking data
*    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
*    ENTITY travel BY \_Booking
*    FROM CORRESPONDING #( Entities )
*    LINK DATA(bookings).
*
*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_group>) GROUP BY <travel_group>-TravelId.
*      " Step 2: get the highest booking number which is already there
*      LOOP AT bookings INTO DATA(ls_booking) USING KEY entity
*            WHERE source-travelId = <travel_group>-travelID.
*        IF  max_booking_id < ls_booking-target-BookingId.
*          max_booking_id = ls_booking-target-bookingId.
*        ENDIF.
*      ENDLOOP.
*      " Step 3: Get the assigned booking numbers for incoming requests
*      LOOP AT entities INTO DATA(ls_entity) USING KEY entity
*            WHERE travelId = <travel_group>-travelID.
*        LOOP AT ls_entity-%target INTO DATA(ls_target).
*          IF  max_booking_id < ls_target-BookingId.
*            max_booking_id = ls_target-bookingId.
*          ENDIF.
*        ENDLOOP.
*      ENDLOOP.
*
*      " Step 4: Loop over all the entities of travel with same travel id
*      LOOP  AT entities ASSIGNING FIELD-SYMBOL(<fs_travel>) USING KEY entity WHERE travelId = <travel_group>-travelId.
*
*        " Step 5: Assign new booking IDs to the booking entity inside each travel
*        LOOP AT <fs_travel>-%target ASSIGNING FIELD-SYMBOL(<booking_wo_numbers>).
*          APPEND CORRESPONDING #( <booking_wo_numbers> ) TO mapped-booking ASSIGNING FIELD-SYMBOL(<mapped_booking>).
*          IF  <mapped_booking>-bookingId IS INITIAL.
*            max_booking_id += 10.
*            <mapped_booking>-bookingId = max_booking_id.
*          ENDIF.
*        ENDLOOP.
*      ENDLOOP.
*    ENDLOOP.

    DATA: max_booking_id TYPE /dmo/booking_id.

    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
      ENTITY travel BY \_booking
        FROM CORRESPONDING #( entities )
        LINK DATA(bookings).

    " Loop over all unique TravelIDs
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel>) GROUP BY <travel>-travelid.

      " Get highest booking_id from existing bookings belonging to travel
      max_booking_id = REDUCE #( INIT max = CONV /dmo/booking_id( '0' )
                                 FOR  booking IN bookings USING KEY entity WHERE ( source-travelid  = <travel>-travelid )
                                 NEXT max = COND /dmo/booking_id( WHEN booking-target-bookingid > max
                                                                    THEN booking-target-bookingid
                                                                    ELSE max )
                               ).
      " Get highest assigned booking_id from incoming entities, eg from internal operations
      max_booking_id = REDUCE #( INIT max = max_booking_id
                                 FOR  entity IN entities USING KEY entity WHERE ( travelid  = <travel>-travelid )
                                 FOR  target IN entity-%target
                                 NEXT max = COND /dmo/booking_id( WHEN   target-bookingid > max
                                                                    THEN target-bookingid
                                                                    ELSE max )
                               ).

      " Assign new booking-ids if not already assigned
      LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_wo_numbers>).
        APPEND CORRESPONDING #( <booking_wo_numbers> ) TO mapped-booking ASSIGNING FIELD-SYMBOL(<mapped_booking>).
        IF <booking_wo_numbers>-bookingid IS INITIAL.
          max_booking_id += 10 .
          <mapped_booking>-bookingid = max_booking_id .
          <mapped_booking>-%is_draft = <booking_wo_numbers>-%is_draft .
        ENDIF.
      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD copyTravel.
    DATA: travels          TYPE TABLE FOR CREATE zivar_r_travel\\Travel,
          booking_cba      TYPE TABLE FOR CREATE zivar_r_travel\\Travel\_Booking,
          bookingsuppl_cba TYPE TABLE FOR CREATE zivar_r_travel\\Booking\_BookingSupplement.
    " Step 1: Remove the travel instances with initial %cid
    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_initial_cid).
    ASSERT key_with_initial_cid IS INITIAL.

    " Step 2: Read all travel, booking and booking supplement using EML
    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(travel_read_result)
        FAILED failed.

    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
        ENTITY Travel BY \_Booking
        ALL FIELDS WITH CORRESPONDING #( travel_read_result )
        RESULT DATA(book_read_result)
        FAILED failed.

    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
        ENTITY Booking BY \_BookingSupplement
        ALL FIELDS WITH CORRESPONDING #( book_read_result )
        RESULT DATA(booksuppl_read_result)
        FAILED failed.

    " Step 3: Fill travel internal table for travel data creation - %cid
    LOOP AT travel_read_result ASSIGNING FIELD-SYMBOL(<travel>).

      " Travel Data preperation
      APPEND VALUE #( %cid = keys[ KEY entity %tky = <travel>-%tky ]-%cid
                      %data = CORRESPONDING #( <travel> EXCEPT travelId )
                     ) TO travels ASSIGNING FIELD-SYMBOL(<new_travel>).

      <new_travel>-BeginDate = cl_abap_context_info=>get_system_date(  ).
      <new_travel>-EndDate = cl_abap_context_info=>get_system_date(  ) + 30.
      <new_travel>-OverallStatus = 'O'.

      " Step 4: Fill booking internal table for booking data creation - %cid_ref
      APPEND VALUE #( %cid_ref = keys[ KEY entity %tky = <travel>-%tky ]-%cid )
                     TO booking_cba ASSIGNING FIELD-SYMBOL(<bookings_cba>).

      LOOP AT book_read_result ASSIGNING FIELD-SYMBOL(<booking>)  WHERE travelId = <travel>-TravelId.
        APPEND VALUE #( %cid = keys[ KEY entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId
                        %data = CORRESPONDING #( book_read_result[ KEY entity %tky = <booking>-%tky ] EXCEPT TravelId  ) )
          TO <bookings_cba>-%target ASSIGNING FIELD-SYMBOL(<new_booking>).

        <new_booking>-BookingStatus = 'N'.
        " Step 5: Fill booking Supplement internal table for booking Suppl data creation - %cid_ref

        APPEND VALUE #( %cid_ref = keys[ KEY entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId )
                    TO bookingsuppl_cba ASSIGNING FIELD-SYMBOL(<booksuppl_cba>).

        LOOP AT booksuppl_read_result ASSIGNING FIELD-SYMBOL(<booksuppl>)
           USING KEY entity WHERE TravelId = <travel>-TravelId AND
                                  BookingId = <booking>-BookingId.
          APPEND VALUE #( %cid = keys[ KEY entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId && <booksuppl>-BookingSupplementId
                      %data = CORRESPONDING #( <booksuppl> EXCEPT TravelId  BookingId ) )
        TO <booksuppl_cba>-%target.

        ENDLOOP.

      ENDLOOP.



    ENDLOOP.

    " Step 6" EML for modify entity to create new BO instance using exisiting data
    MODIFY ENTITIES OF zivar_r_travel IN LOCAL MODE
        ENTITY travel
            CREATE FIELDS ( AgencyId  CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus )
                WITH travels
                CREATE BY \_Booking FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode )
                    WITH booking_cba
                        ENTITY Booking
                            CREATE BY \_BookingSupplement FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
                                WITH bookingsuppl_cba
          MAPPED DATA(mapped_create).

    mapped-travel = mapped_create-travel.

  ENDMETHOD.

  METHOD get_instance_features.
    " Step 1: Read travel data with status
    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
        ENTITY travel
            FIELDS ( TravelId OverallStatus )
                WITH CORRESPONDING #( keys )
         RESULT DATA(travels)
         FAILED failed.

    " Step 2: Return the result with booking creation possible or not
*    READ TABLE travels INTO DATA(ls_travel) INDEX 1.
*    IF ( ls_travel-OverallStatus = 'X' ).
*      DATA(lv_allow) = if_abap_behv=>fc-o-disabled.
*    ELSE.
*      lv_allow = if_abap_behv=>fc-o-enabled.
*    ENDIF.
*
*    result = VALUE #( FOR travel IN travels
*                      ( %tky = travel-%tky
*                        %assoc-_Booking = lv_allow ) ).

    result = VALUE #( FOR travel IN travels
                       ( %tky                 = travel-%tky
                         %assoc-_booking      = COND #( WHEN travel-OverallStatus = 'X'
                                                            THEN if_abap_behv=>fc-o-disabled
                                                            ELSE if_abap_behv=>fc-o-enabled   )
                      ) ).

  ENDMETHOD.

  METHOD reCalcTotalPrice.

*   Define a structure where we can store all the booking fees & currency code
    TYPES: BEGIN OF ty_amount_per_currency,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currency.

    DATA: amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currency.


*   Read all travel instances, subsequent bookings using EML
    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
        ENTITY travel
        FIELDS ( BookingFee CurrencyCode )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
           ENTITY travel BY \_Booking
           FIELDS ( FlightPrice CurrencyCode )
           WITH CORRESPONDING #( travels )
           RESULT DATA(bookings).

    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
           ENTITY booking BY \_BookingSupplement
           FIELDS ( Price CurrencyCode )
           WITH CORRESPONDING #( bookings )
           RESULT DATA(bookingsupplements).


*   Delete the values with out any currency
    DELETE travels WHERE CurrencyCode IS INITIAL.
    DELETE bookings WHERE CurrencyCode IS INITIAL.
    DELETE bookingsupplements WHERE CurrencyCode IS INITIAL.

*   Total all booking & Supplement amounts which are in common currency
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      " Set the first value for total price by adding the booking fee from header
      amounts_per_currencycode = VALUE #( ( amount        = <travel>-BookingFee
                                            currency_code = <travel>-CurrencyCode ) ).

*   Loop at all amounts & compare with target currency
      LOOP AT bookings INTO DATA(booking) WHERE travelid = <travel>-TravelId.
        COLLECT VALUE ty_amount_per_currency( amount = booking-FlightPrice
                                              currency_code = booking-CurrencyCode ) INTO amounts_per_currencycode.

      ENDLOOP.

      LOOP AT bookingsupplements INTO DATA(bookingsuppl) WHERE travelid = <travel>-TravelId.
        COLLECT VALUE ty_amount_per_currency( amount = bookingsuppl-Price
                                              currency_code = bookingsuppl-CurrencyCode ) INTO amounts_per_currencycode.
      ENDLOOP.

      CLEAR <travel>-TotalPrice.
*   Perform currency conversion
      LOOP AT amounts_per_currencycode INTO DATA(amount_per_currencycode).
        IF amount_per_currencycode-currency_code = <travel>-CurrencyCode.
          <travel>-TotalPrice += amount_per_currencycode-amount.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = amount_per_currencycode-amount
              iv_currency_code_source = amount_per_currencycode-currency_code
              iv_currency_code_target = <travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date(  )
            IMPORTING
              ev_amount               = DATA(lv_amount)
          ).

          <travel>-TotalPrice += lv_amount.

        ENDIF.
      ENDLOOP.
*   Put back total amount

    ENDLOOP.
*   Return the total amount in Mapped so the RAP will modify this data in DB
    MODIFY ENTITIES OF zivar_r_travel IN LOCAL MODE
        ENTITY travel
            UPDATE FIELDS ( TotalPrice )
                WITH CORRESPONDING #( travels ).


  ENDMETHOD.

  METHOD calculateTotalPrice.

   types: ty_travel like liNE OF keys.

   DATA travel_ids TYPE STANDARD TABLE OF ty_travel WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    travel_ids = CORRESPONDING #( keys DISCARDING DUPLICATES  ).

*  Invoke reusable method reCalcTotalPrice using execute in modify
    MODIFY ENTITIES OF zivar_r_travel IN LOCAL MODE
      ENTITY travel
          EXECUTE reCalcTotalPrice
              FROM CORRESPONDING #( travel_ids ).

*    DATA travel_ids LIKE  keys.
*
*    travel_ids = CORRESPONDING #( keys ).
*
*    SORT travel_ids BY TravelId.
*    DELETE ADJACENT DUPLICATES FROM travel_ids COMPARING TravelId.

**  Invoke reusable method reCalcTotalPrice using execute in modify
*    MODIFY ENTITIES OF zivar_r_travel IN LOCAL MODE
*      ENTITY travel
*          EXECUTE reCalcTotalPrice
*              FROM CORRESPONDING #( travel_ids ).

  ENDMETHOD.

  METHOD validateHeaderData.
    READ ENTITIES OF zivar_r_travel IN LOCAL MODE
        ENTITY Travel
            FIELDS ( CustomerId BeginDate EndDate )
                WITH CORRESPONDING #( keys )
                    RESULT DATA(lt_travel).

    " Step 2: Declare a sorted table for holding customer ids
    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    " Stepd 3: Extract the unique customer ids in our table
    customers = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING
                                               customer_id = CustomerId EXCEPT *
                                ).
    DELETE customers WHERE customer_id IS INITIAL.

    " Validation for customer id
    IF customers IS NOT INITIAL.
      SELECT FROM /dmo/customer FIELDS customer_id
          FOR ALL ENTRIES IN @customers
              WHERE customer_id = @customers-customer_id
              INTO TABLE @DATA(lt_cust_db).

    ENDIF.
    LOOP AT lt_travel INTO DATA(ls_travel).
      IF ( ls_travel-CustomerId IS INITIAL OR
           NOT line_exists( lt_cust_db[ customer_id = ls_travel-customerid ] ) ).
        " Inform RAP framework to terminate the create

        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %element-customerid = if_abap_behv=>mk-on
                        %msg = NEW /dmo/cm_flight_messages(
                                          textid                = /dmo/cm_flight_messages=>customer_unkown
                                          customer_id           = ls_travel-customerid
                                          severity              = if_abap_behv_message=>severity-error

                                                           )
                    ) TO reported-travel.
      ENDIF.
*        //  check if begin and end date is empty
*  // end date > begin date
*  // Begin date should be in future
      IF (  ls_travel-BeginDate IS INITIAL OR
            ls_travel-EndDate IS INITIAL OR
            ls_travel-BeginDate > ls_travel-EndDate OR
            ls_travel-BeginDate > cl_abap_context_info=>get_system_date(  )
         ).

        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        IF ls_travel-BeginDAte IS INITIAL.
          APPEND VALUE #( %tky = ls_travel-%tky
                          %element-BeginDate = if_abap_behv=>mk-on
                          %msg = NEW /dmo/cm_flight_messages(
                                            textid                = /dmo/cm_flight_messages=>enter_begin_date
                                            begin_date            = ls_travel-BeginDate
                                            severity              = if_abap_behv_message=>severity-error

                                                             )
                      ) TO reported-travel.
        ENDIF.

        IF ls_travel-EndDAte IS INITIAL.
          APPEND VALUE #( %tky = ls_travel-%tky
                          %element-Enddate = if_abap_behv=>mk-on
                          %msg = NEW /dmo/cm_flight_messages(
                                            textid                = /dmo/cm_flight_messages=>enter_end_date
                                            end_date            = ls_travel-EndDate
                                            severity              = if_abap_behv_message=>severity-error

                                                             )
                      ) TO reported-travel.
        ENDIF.
        IF ls_travel-BeginDate > ls_travel-EndDate.
          APPEND VALUE #( %tky = ls_travel-%tky
                          %element-BeginDate = if_abap_behv=>mk-on
                          %msg = NEW /dmo/cm_flight_messages(
                                            textid                = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                            begin_date            = ls_travel-BeginDate
                                            end_date              = ls_travel-EndDate
                                            severity              = if_abap_behv_message=>severity-error

                                                             )
                      ) TO reported-travel.
        ENDIF.

        IF ls_travel-BeginDate > cl_abap_context_info=>get_system_date(  ).
          APPEND VALUE #( %tky = ls_travel-%tky
                          %element-BeginDate = if_abap_behv=>mk-on
                          %msg = NEW /dmo/cm_flight_messages(
                                            textid                = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                            begin_date            = ls_travel-BeginDate
                                            end_date              = ls_travel-EndDate
                                            severity              = if_abap_behv_message=>severity-error

                                                             )
                      ) TO reported-travel.
        ENDIF.

      ENDIF.

    ENDLOOP.



  ENDMETHOD.

ENDCLASS.
