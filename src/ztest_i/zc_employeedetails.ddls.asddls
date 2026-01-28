@EndUserText.label: 'Maintain Employee details'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZC_EmployeeDetails
  as projection on ZI_EmployeeDetails
{
  key Id,
  Name,
  Designation,
  @Consumption.hidden: true
  SingletonID,
  _EmployeeDetailsAll : redirected to parent ZC_EmployeeDetails_S
}
