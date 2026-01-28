@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZZITEST_R_EMPLOYEEEMP'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZZIC_TEST_R_EMPLOYEEEMP
  provider contract TRANSACTIONAL_QUERY
  as projection on ZZIR_TEST_R_EMPLOYEEEMP
  association [1..1] to ZZIR_TEST_R_EMPLOYEEEMP as _BaseEntity on $projection.ID = _BaseEntity.ID
{
  key ID,
  Name,
  Designation,
  @Semantics: {
    User.Createdby: true
  }
  LocalCreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  LocalCreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LocalLastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChangedAt,
  _BaseEntity
}
