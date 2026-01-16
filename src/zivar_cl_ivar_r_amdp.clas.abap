CLASS zivar_cl_ivar_r_amdp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb .
    INTERFACES if_oo_adt_classrun .

    CLASS-METHODS: add_numbers AMDP OPTIONS  READ-ONLY CLIENT INDEPENDENT
      IMPORTING VALUE(a)   TYPE i
                VALUE(b)   TYPE i
      EXPORTING VALUE(res) TYPE i.
    CLASS-METHODS: get_sales AMDP OPTIONS READ-ONLY CDS SESSION CLIENT DEPENDENT
      IMPORTING VALUE(orderid) TYPE zivar_r_dte_id
      EXPORTING VALUE(gross)   TYPE zivar_r_so_item-gross_amount.

   class-methods: get_cus_rank for tabLE FUNCTION zivar_r_tf.

  PROTECTED SECTION .
  PRIVATE SECTION.
ENDCLASS.



CLASS zivar_cl_ivar_r_amdp IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    zivar_cl_ivar_r_amdp=>add_numbers(
      EXPORTING
        a   = 1
        b   = 2
      IMPORTING
        res = DATA(lv_res)
    ).
    out->write( |Result:  { lv_res }|   ).

    zivar_cl_ivar_r_amdp=>get_sales(
      EXPORTING
        orderid = 'FEE7E67524AE1FD0BC8D566338B6318E'
      IMPORTING
        gross   = data(lv_gross)
    ).
    out->write( |Gross amount: { lv_gross } 'INR'| ).

  ENDMETHOD.



  METHOD add_numbers BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY.
    deCLARE c inteGER;
    declaRE d inTEGER;

    c := :a;
    d := :b;
    res := :c + :d;

  ENDMETHOD.

  METHOD get_sales BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY USING zi_ivar_r_sales_data.

    declare lv_gross bigint = 0;
    declare lv_count integer;
    declare i integer;
    lt_data = select  orderid,grossamount from zi_ivar_r_sales_data where orderid = :orderid;
    lv_count := record_count( :lt_data );
    for i in 1..:lv_count do
      lv_gross := :lt_data.grossamount[i] + :lv_gross;
    end for;
    gross := :lv_gross;


  ENDMETHOD.

  METHOD get_cus_rank by dATABASE funCTION FOR HDB LANGUAGE SQLSCRIPT oPTIONS reAD-ONLY
                      uSING zivar_r_bpa zivar_r_so_hdr zivar_r_so_item.

    return select
      bpa.client,
      bpa.company_name,
      sum(item.gross_amount) as total_sales,
      item.currency_code as currency_code,
      RANK ( ) OVER ( order by sum ( item.gross_amount ) desc ) as customer_rank
      fROM zivar_r_bpa as bpa
      inner join zivar_r_so_hdr as hdr
      on bpa.bp_id = hdr.buyer
      inner join zivar_r_so_item as item
      on hdr.order_id = item.order_id
      group by bpa.client,
      bpa.company_name,
      item.currency_code;
*      liMIT 3;

  ENDMETHOD.

ENDCLASS.
