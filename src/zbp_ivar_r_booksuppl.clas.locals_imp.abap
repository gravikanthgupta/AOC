CLASS lhc_booksuppl DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookSuppl~calculateTotalPrice.

ENDCLASS.

CLASS lhc_booksuppl IMPLEMENTATION.

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
