@EndUserText.label: 'Copy Employee details'
define abstract entity ZD_CopyEmployeeDetailsP
{
  @EndUserText.label: 'New ID'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Id' )
  Id : ZIVAR_R_EMP_ID;
}
