@EndUserText.label: 'Employee details Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZI_EmployeeDetails_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_EMPLOYEEDETAILS'
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_EmployeeDetails as _EmployeeDetails
{
  key 1 as SingletonID,
  _EmployeeDetails,
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
}
where I_Language.Language = $session.system_language
