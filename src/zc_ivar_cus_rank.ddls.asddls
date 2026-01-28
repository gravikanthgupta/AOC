@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer rank'
@Metadata.ignorePropagatedAnnotations: true
define view entity zc_ivar_cus_rank as select from zivar_r_tf
{
    key company_name,
    @Semantics.amount.currencyCode: 'currency_code'
    total_sales,
    currency_code,
    customer_rank
}
