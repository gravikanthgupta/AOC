CLASS zivar_cl_new_syn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS : s1_using_key_expression.
    CLASS-METHODS : s1_constructor_expression.
    CLASS-METHODS : s1_table_expression EXPORTING im_err TYPE string
                                                  im_res TYPE /dmo/booking.
    CLASS-METHODS : s1_inline_declaration.
    CLASS-METHODS : s1_value_expression.
    CLASS-METHODS : s1_corresponding_data.
    CLASS-METHODS : s1_cond_conv_exp.
    CLASS-METHODS : s1_loop_with_grouping.
    CLASS-METHODS : s1_loop_with_single_line.
    CLASS-METHODS : s1_loop_reduce_statement.
    CLASS-METHODS:  s1_let_example.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA im_flight_price TYPE /dmo/flight_price.
    CLASS-DATA im_total TYPE p.
    TYPES: BEGIN OF ty_final_booking.
             INCLUDE TYPE /dmo/booking.
    TYPES:   booking_tx TYPE p LENGTH 10 DECIMALS 2,
           END OF ty_final_booking,
           tt_final_booking TYPE TABLE OF ty_final_booking WITH DEFAULT KEY.
    CLASS-DATA im_final_booking TYPE tt_final_booking.
    CLASS-DATA im_grp_book TYPE TABLE OF /dmo/booking.
    CLASS-DATA im_res TYPE c.

    TYPES: BEGIN OF ty_game2,
             lead  TYPE c LENGTH 10,
             scrum TYPE c LENGTH 10,
             goals TYPE i,
           END OF ty_game2,
           tt_game2 TYPE TABLE OF ty_game2 WITH DEFAULT KEY.
    CLASS-DATA im_game2 TYPE tt_game2.

    TYPES: BEGIN OF ty_game,
             captain TYPE c LENGTH 10,
             team    TYPE c LENGTH 10,
             score   TYPE i,
           END OF ty_game,
           tt_game TYPE TABLE OF ty_game WITH DEFAULT KEY.
    CLASS-DATA im_game TYPE tt_game.
ENDCLASS.



CLASS zivar_cl_new_syn IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    zivar_cl_new_syn=>s1_using_key_expression(   ).

    zivar_cl_new_syn=>s1_constructor_expression(  ).


    zivar_cl_new_syn=>s1_table_expression(
      IMPORTING
        im_err = DATA(lv_error)
        im_res = DATA(ls_booking)
    ).
    IF lv_error IS NOT INITIAL.
      out->write( lv_error ).
    ELSE.
      out->write( ls_booking ).
      out->write( im_flight_price ).
    ENDIF.

    zivar_cl_new_syn=>s1_inline_declaration(  ).

    zivar_cl_new_syn=>s1_value_expression(  ).
    out->write( im_game ).

    zivar_cl_new_syn=>s1_corresponding_data(  ).
    out->write( im_game2 ).

    zivar_cl_new_syn=>s1_cond_conv_exp(  ).
    out->write( im_res ).

    zivar_cl_new_syn=>s1_loop_with_grouping(  ).
    out->write( im_grp_book ).

    zivar_cl_new_syn=>s1_loop_with_single_line(  ).
    out->write( im_final_booking ).

    zivar_cl_new_syn=>s1_loop_reduce_statement(  ).
    out->write( im_total ).

  ENDMETHOD.

  METHOD s1_cond_conv_exp.
    DATA: lv_numc TYPE n LENGTH 4 VALUE '0060',
          lv_num  TYPE i,
          lv_res  TYPE c.

    lv_num = CONV #( lv_numc ).

* Here LET is to declare local  variables in inline
* Variables declared with LET are strictly local to the expression in which they are defined
* (e.g., within a VALUE or FOR expression). They cannot be accessed statically outside that specific expression.
    lv_res = COND #( LET val = 800 IN
                     WHEN lv_num > val THEN 'X'
                     ELSE '' ).

    im_res = lv_res.



  ENDMETHOD.

  METHOD s1_constructor_expression.

    DATA(lo_obj) = NEW /dmo/cm_flight_messages(
      textid                = VALUE #( msgid = 'SY' msgno = 499 )
      severity              = if_abap_behv_message=>severity-error

       ).

    DATA: lo_obj1 TYPE REF TO /dmo/cm_flight_messages.
    CREATE OBJECT lo_obj1
      EXPORTING
        textid   = VALUE #( msgid = 'SY' msgno = 499 )
        severity = if_abap_behv_message=>severity-error.


* Difference between new and value
    TYPES: BEGIN OF ty_line,
             id   TYPE i,
             name TYPE string,
           END OF ty_line,
           tty_table TYPE STANDARD TABLE OF ty_line WITH EMPTY KEY.

    " Using VALUE: Creates and assigns the actual table data
    DATA(lt_value) = VALUE tty_table( ( id = 1 name = 'Alpha' ) ( id = 2 name = 'Beta' ) ).

    " Using NEW: Creates a data reference to the table data
    DATA(lr_new) = NEW tty_table( ( id = 1 name = 'Alpha' ) ( id = 2 name = 'Beta' ) ).
    " To access the actual data, you must dereference it using ->*
    DATA(lt_table) = lr_new->* .

*    data: lr_t1 tyPE reF TO tty_table.
*    lr_t1 = NEW tty_table( ( id = 1 name = 'Alpha' ) ( id = 2 name = 'Beta' ) ).

  ENDMETHOD.

  METHOD s1_corresponding_data.
    TYPES: BEGIN OF ty_game,
             captain TYPE c LENGTH 10,
             team    TYPE c LENGTH 10,
             score   TYPE i,
           END OF ty_game,

*           BEGIN OF ty_game2,
*             lead  TYPE c LENGTH 10,
*             scrum TYPE c LENGTH 10,
*             goals TYPE i,
*           END OF ty_game2,

           tt_game TYPE TABLE OF ty_game WITH DEFAULT KEY.
*           tt_game2 TYPE TABLE OF ty_game2 WITH DEFAULT KEY.

    DATA: lt_game2 TYPE tt_game2.

    DATA(lt_game) = VALUE tt_game( ( captain = 'Dhoni'
                                      team = 'CSK'
                                      score = 100 )
                                    ( captain = 'Virat'
                                      team = 'RCB'
                                      score = 100 )
                                    ( captain = 'Rohit'
                                      team = 'MI'
                                      score = 100 )
                                    ).


* Both target and source are different field names. If you want to map these fields
* then map individually. we can also use except. Those fields will not copy
    lt_game2 = CORRESPONDING #( lt_game MAPPING
                                    lead = captain
                                    scrum = team
                                    goals = score ).
    im_game2 = CORRESPONDING tt_game2( lt_game2 ).


  ENDMETHOD.

  METHOD s1_inline_declaration.
*    lv_uuid = cl_uuid_factory=>create_system_uuid(  )->convert_uuid_c32(
*       imPORTING
*        uuid     = lv_uuid
*    ).


  ENDMETHOD.

  METHOD s1_loop_reduce_statement.
    TYPES: tt_bookings TYPE TABLE OF /dmo/booking WITH DEFAULT KEY.

    DATA: lv_total TYPE p DECIMALS 2.

    SELECT * FROM /dmo/booking INTO TABLE @DATA(lt_bookings) UP TO 100 ROWS.

* Loop all records and total the price in single statement using FOR
    lv_total = REDUCE #( INIT x = CONV #( 0 )
                          FOR ls_bookings IN lt_bookings
                          NEXT x = x + ls_bookings-flight_price
      ).

    im_total = lv_total.

  ENDMETHOD.

  METHOD s1_loop_with_grouping.
    TYPES: tt_bookings TYPE TABLE OF /dmo/booking WITH DEFAULT KEY.
    DATA: lv_total TYPE p DECIMALS 2.

    SELECT * FROM /dmo/booking INTO TABLE @DATA(lt_bookings) UP TO 100 ROWS.

* Initialize the new internal table with blank records
    DATA(lt_grp_book) = VALUE tt_bookings(  ).

* Outer loop is used by group by. No need of sort. Compiler will take care of sorting
    LOOP AT lt_bookings INTO DATA(ls_bookings) GROUP BY ls_bookings-travel_id.

* Inner loop to get all item details based on header record
      LOOP AT GROUP ls_bookings INTO DATA(ls_child_rec).
        lt_grp_book = VALUE #( BASE lt_grp_book ( ls_child_rec ) ).
      ENDLOOP.
    ENDLOOP.
    im_grp_book = CORRESPONDING tt_bookings( lt_grp_book ).

  ENDMETHOD.

  METHOD s1_loop_with_single_line.
    TYPES: tt_bookings TYPE TABLE OF /dmo/booking WITH DEFAULT KEY.
    DATA: lv_total TYPE p DECIMALS 2.

    TYPES: BEGIN OF ty_final_booking.
             INCLUDE TYPE /dmo/booking.
    TYPES:   booking_tx TYPE p LENGTH 10 DECIMALS 2,
           END OF ty_final_booking,
           tt_final_booking TYPE TABLE OF ty_final_booking WITH DEFAULT KEY.

    DATA: lv_gst TYPE p DECIMALS 2.
    lv_gst = '1.12'.

    SELECT * FROM /dmo/booking INTO TABLE @DATA(lt_bookings) UP TO 100 ROWS.

    DATA(lt_final_booking) = VALUE tt_final_booking( FOR wa IN lt_bookings (
                                               travel_id = wa-travel_id
                                               booking_id = wa-booking_id
                                               flight_price = wa-flight_price
                                               booking_tx = COND #( WHEN wa-flight_price > 600
                                                   THEN wa-flight_price * lv_gst
                                                   ELSE wa-flight_price ) ) ).

    im_final_booking = CORRESPONDING tt_final_booking( lt_final_booking ).
  ENDMETHOD.

  METHOD s1_table_expression.
    DATA: itab TYPE TABLE OF /dmo/booking WITH DEFAULT KEY.

    SELECT * FROM /dmo/booking INTO TABLE @itab UP TO 100 ROWS.

* Either use line_exists or use optional based on logic
    " Read table itab
*    IF NOT line_exists( itab[ travel_id = '00000001' ] ).
*      im_err = 'Record not found'.
*      EXIT.
*    ENDIF.

    DATA(wa) = VALUE #( itab[ travel_id = '00000001' carrier_id = 'AA' ] OPTIONAL ).
    im_flight_price = VALUE #( itab[ travel_id = '00000001' carrier_id = 'AA' ]-flight_price OPTIONAL ).
    im_res = wa.
  ENDMETHOD.

  METHOD s1_value_expression.


    DATA(lt_game) = VALUE tt_game( ( captain = 'Dhoni'
                               team = 'CSK'
                               score = 100 )
                             ( captain = 'Virat'
                               team = 'RCB'
                               score = 100 )
                             ( captain = 'Rohit'
                               team = 'MI'
                               score = 100 )
                             ).
    im_game = CORRESPONDING tt_game( lt_game ).


  ENDMETHOD.

  METHOD s1_using_key_expression.
    DATA: itab TYPE SORTED TABLE OF /dmo/booking
          WITH UNIQUE KEY travel_id booking_id
          WITH NON-UNIQUE SORTED KEY cus_key COMPONENTS carrier_id connection_id.

    SELECT *  FROM /dmo/booking INTO TABLE @itab UP TO 100 ROWS.

    " Table expression
    " use key for better practise cus_key for secondary key which we declared in declaration
    DATA(wa) = itab[ KEY cus_key carrier_id = 'AA' connection_id = 0322 ].

    " In loops also use key
    LOOP AT itab INTO wa USING KEY cus_key WHERE carrier_id = 'AA'.
    ENDLOOP.

  ENDMETHOD.

  METHOD s1_let_example.
  DATA: itab TYPE TABLE OF /dmo/booking WITH DEFAULT KEY.
  TYPES: BEGIN OF ty_final_booking.
             INCLUDE TYPE /dmo/booking.
    TYPES:   booking_tx TYPE p LENGTH 10 DECIMALS 2,
           END OF ty_final_booking,
           tt_final_booking TYPE TABLE OF ty_final_booking WITH DEFAULT KEY.

    SELECT * FROM /dmo/booking INTO TABLE @DATA(lt_bookings) UP TO 100 ROWS.

    DATA(lt_final_booking) = VALUE tt_final_booking( FOR wa IN lt_bookings
                                                       LET lv_price = wa-flight_price * '0.5' IN (
                                                       travel_id = wa-travel_id
                                                       booking_id = wa-booking_id
                                                       flight_price = lv_price
                                                       booking_tx = wa-flight_price + lv_price ) ).

  ENDMETHOD.

ENDCLASS.
