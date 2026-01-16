@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Test CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_ivar_r_bpa
  as select from zivar_r_bpa
  association [1] to I_Country as _country on $projection.Country = _country.Country
{
  key bp_id                                                           as BpId,
      bp_role                                                         as BpRole,
      @EndUserText.label: 'BP Type'
      case bp_role
          when '01' then 'Customer'
          else 'Vendor'
          end                                                         as bp_type,
      company_name                                                    as CompanyName,
      street                                                          as Street,
      country                                                         as Country,
      region                                                          as Region,
      city                                                            as City,
      _country._Text[Language = $session.system_language].CountryName as CountryName
}

// where country = 'IN'
// [Language = $session.system_language]
