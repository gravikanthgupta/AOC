@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Data'
@Metadata.ignorePropagatedAnnotations: true
//@OData.publish: true
define view entity zi_ivar_r_sales
  as select from zivar_r_so_hdr as _hdr
  association [0..*] to zivar_r_so_item as _item on $projection.OrderId = _item.order_id
{

  key _hdr.order_id             as OrderId,
      _hdr.order_no             as OrderNo,
      _hdr.buyer                as Buyer,
      //@Semantics.amount.currencyCode: 'CurrencyCode'
      //_hdr.gross_amount as GrossAmount,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      sum( _item.gross_amount ) as TotalGross,

      _hdr.currency_code        as CurrencyCode,
      _hdr.created_by           as CreatedBy,
      _hdr.created_on           as CreatedOn,
      _hdr.changed_by           as ChangedBy,
      _hdr.changed_on           as ChangedOn,
      _item

}
group by
  _hdr.order_id,
  _hdr.order_no,
  _hdr.buyer,
  _hdr.currency_code,
  _hdr.created_by,
  _hdr.created_on,
  _hdr.changed_by,
  _hdr.changed_on
