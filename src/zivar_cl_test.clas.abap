CLASS zivar_cl_test DEFINITION
PUBLIC
FINAL
CREATE PUBLIC .


PUBLIC SECTION.
interfaces if_oo_adt_classrun.
PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.


CLASS zivar_cl_test IMPLEMENTATION.

METHOD if_oo_adt_classrun~main.
data connection type ref to lcl_connection.

* Local classes example and how to use the local classes
* Local class returns the class object as returing parameter of same class type

* Debug the method to show that the class returns objects, but that there are different
* objects for the same combination of airline and flight number


connection = lcl_connection=>get_connection( airlineid = 'LH' connectionnumber = '0400' ).


connection = lcl_connection=>get_connection( airlineid = 'LH' connectionnumber = '0400' ).


ENDMETHOD.


ENDCLASS.
