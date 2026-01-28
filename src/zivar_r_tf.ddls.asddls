@EndUserText.label: 'Table Function Demo - Total Sales per customer Ranked'
@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
define table function zivar_r_tf
//with parameters @Environment.systemField: #CLIENT
//p_clnt: abap.clnt
returns {
 key client : abap.clnt;
 key company_name : abap.char(256);
  total_sales : abap.curr(15,2);
  currency_code: abap.cuky(5);
  customer_rank : abap.int4;
  
}
implemented by method zivar_cl_ivar_r_amdp=>get_cus_rank;