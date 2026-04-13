CLASS zivar_cl_test DEFINITION
PUBLIC
FINAL
CREATE PUBLIC .


  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zivar_cl_test IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA connection TYPE REF TO lcl_connection.

* Local classes example and how to use the local classes
* Local class returns the class object as returing parameter of same class type

* Debug the method to show that the class returns objects, but that there are different
* objects for the same combination of airline and flight number


    connection = lcl_connection=>get_connection( airlineid = 'LH' connectionnumber = '0400' ).


    connection = lcl_connection=>get_connection( airlineid = 'LH' connectionnumber = '0400' ).


*SELECT  FROM /dmo/connection FIELDS airport_from_id, airport_to_id
*inTO table @data(lt_n) uP TO 100 rows.

*cl_salv_table=>factory(
*  IMPORTING r_salv_table = DATA(lo_alv)
*  CHANGING  t_table      = lt_n ).
*lo_alv->display( ).

* Test append syntax
    TYPES: BEGIN OF ty_amount_per_currency,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currency.

    DATA: amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currency.

    amounts_per_currencycode = VALUE #( ( amount        = '100.00'
                                            currency_code = 'USD' ) ).

    COLLECT VALUE ty_amount_per_currency( amount = '200.00'
                                                  currency_code = 'USD' ) INTO amounts_per_currencycode.

    COLLECT VALUE ty_amount_per_currency( amount = '300.00'
                                                  currency_code = 'EUR' ) INTO amounts_per_currencycode.

    amounts_per_currencycode = VALUE #( ( amount        = '100.00'
                                              currency_code = 'USD' ) ).

                                              out->write(
                                                EXPORTING
                                                  data   = amounts_per_currencycode
*                                                  name   =
*                                                RECEIVING
*                                                  output =
                                              ).
  ENDMETHOD.
ENDCLASS.
