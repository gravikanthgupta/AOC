@EndUserText.label: 'Employee details'
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZI_EmployeeDetails
  as select from ZTEST_R_EMP
  association to parent ZI_EmployeeDetails_S as _EmployeeDetailsAll on $projection.SingletonID = _EmployeeDetailsAll.SingletonID
{
  key ID as Id,
  NAME as Name,
  DESIGNATION as Designation,
  1 as SingletonID,
  _EmployeeDetailsAll
}
