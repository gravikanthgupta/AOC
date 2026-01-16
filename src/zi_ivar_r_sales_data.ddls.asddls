@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_ivar_r_sales_Data as select from zi_ivar_r_sales
association[1] to zi_ivar_r_bpa as _BUSINESSPARTNER on
    $projection.Buyer   = _BUSINESSPARTNER.BpId
    association[1] to zi_ivar_r_product as _PRODUCT on 
    $projection.Product = _PRODUCT.ProductId
{
   
   key zi_ivar_r_sales.OrderId,
   key zi_ivar_r_sales._item.item_id as Itemid,
   zi_ivar_r_sales.OrderNo,
   zi_ivar_r_sales.Buyer,
   @Semantics.amount.currencyCode: 'CurrencyCode'  
   zi_ivar_r_sales.TotalGross,
   zi_ivar_r_sales.CurrencyCode,
   zi_ivar_r_sales.CreatedBy,
   zi_ivar_r_sales.CreatedOn,
   zi_ivar_r_sales.ChangedBy,
   zi_ivar_r_sales.ChangedOn,
   /* Associations */
   /* Associations */
    zi_ivar_r_sales._item.product as Product,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'CurrencyCode'    
    zi_ivar_r_sales._item.gross_amount   as GrossAmount,
    @DefaultAggregation: #SUM
    @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
    zi_ivar_r_sales._item.qty as Quantity,
    zi_ivar_r_sales._item.uom as UnitOfMeasure,
    
    _PRODUCT,
    _BUSINESSPARTNER
    
}
