@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Analysis Consumption View'
@Metadata.ignorePropagatedAnnotations: false

define view entity zc_ivar_r_sales_ana as select from zi_ivar_r_sales_Data
{
    key _BUSINESSPARTNER.CompanyName,
    GrossAmount,
    CurrencyCode,
    Quantity,
    UnitOfMeasure

}
