CLASS zivar_cl_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zivar_cl_factory IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA connection TYPE REF TO lcl_connection.


* Debug the method to show that the class returns objects, but that there are different
* objects for the same combination of airline and flight number

*connection = new #( airlineid = 'LH' connectionnumber = '0400' ).

    connection = lcl_connection=>get_connection( airlineid = 'LH' connectionnumber = '0400' ).


    connection = lcl_connection=>get_connection( airlineid = 'LH' connectionnumber = '0400' ).

*    data(lo_con) =  NEW lcl_connection( airlineid = 'LH' connectionnumber = '0400' fromairport = '10' toairport = '20' ).

    out->write( connection->get_airlineid( ) ).
    out->write( connection->get_connection_id(  ) ).
    out->write( connection->get_from(  ) ).
    out->write( connection->get_to(  ) ).



  ENDMETHOD.
ENDCLASS.
