@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZZITEST_R_EMPLOYEEEMP'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZZIR_TEST_R_EMPLOYEEEMP
  as select from ZTEST_R_EMPLOYEE
{
  key id as ID,
  name as Name,
  designation as Designation,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
}
