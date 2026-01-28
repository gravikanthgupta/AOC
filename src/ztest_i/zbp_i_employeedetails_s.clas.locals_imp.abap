CLASS LHC_ZI_EMPLOYEEDETAILS_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PUBLIC SECTION.
    CONSTANTS:
      CO_ENTITY TYPE abp_entity_name VALUE `ZI_EMPLOYEEDETAILS_S`,
      CO_TRANSPORT_OBJECT TYPE mbc_cp_api=>indiv_transaction_obj_name VALUE `ZEMPLOYEEDETAILS`,
      CO_AUTHORIZATION_ENTITY TYPE abp_entity_name VALUE `ZI_EMPLOYEEDETAILS`.

  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR EmployeeDetailsAll
        RESULT result,
      SELECTCUSTOMIZINGTRANSPTREQ FOR MODIFY
        IMPORTING
          KEYS FOR ACTION EmployeeDetailsAll~SelectCustomizingTransptReq
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR EmployeeDetailsAll
        RESULT result,
      EDIT FOR MODIFY
        IMPORTING
          KEYS FOR ACTION EmployeeDetailsAll~edit.
ENDCLASS.

CLASS LHC_ZI_EMPLOYEEDETAILS_S IMPLEMENTATION.
  METHOD GET_INSTANCE_FEATURES.
  mbc_cp_api=>rap_bc_api( )->get_instance_features(
    transport_object   = co_transport_object
    entity             = co_entity
    keys               = REF #( keys )
    requested_features = REF #( requested_features )
    result             = REF #( result )
    failed             = REF #( failed )
    reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD SELECTCUSTOMIZINGTRANSPTREQ.
  mbc_cp_api=>rap_bc_api( )->select_transport_action(
    entity   = co_entity
    keys     = REF #( keys )
    result   = REF #( result )
    mapped   = REF #( mapped )
    failed   = REF #( failed )
    reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
    entity                   = co_authorization_entity
    requested_authorizations = REF #( requested_authorizations )
    result                   = REF #( result )
    reported                 = REF #( reported ) ).
  ENDMETHOD.
  METHOD EDIT.
  mbc_cp_api=>rap_bc_api( )->get_default_transport_request(
    transport_object = co_transport_object
    entity           = co_entity
    keys             = REF #( keys )
    mapped           = REF #( mapped )
    failed           = REF #( failed )
    reported         = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZI_EMPLOYEEDETAILS_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION.
ENDCLASS.

CLASS LSC_ZI_EMPLOYEEDETAILS_S IMPLEMENTATION.
  METHOD SAVE_MODIFIED.
  mbc_cp_api=>rap_bc_api( )->record_changes(
    transport_object = lhc_ZI_EmployeeDetails_S=>co_transport_object
    entity           = lhc_ZI_EmployeeDetails_S=>co_entity
    create           = REF #( create )
    update           = REF #( update )
    delete           = REF #( delete )
    reported         = REF #( reported ) ).
  mbc_cp_api=>rap_bc_api( )->update_last_changed_date_time(
    maintenance_object = 'ZEMPLOYEEDETAILS'
    entity             = lhc_ZI_EmployeeDetails_S=>co_authorization_entity
    create             = REF #( create )
    update             = REF #( update )
    delete             = REF #( delete )
    reported           = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_EMPLOYEEDETAILS DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PUBLIC SECTION.
    CONSTANTS:
      CO_ENTITY TYPE abp_entity_name VALUE `ZI_EMPLOYEEDETAILS`.

  PRIVATE SECTION.
    METHODS:
      VALIDATEDATACONSISTENCY FOR VALIDATE ON SAVE
        IMPORTING
          KEYS FOR EmployeeDetails~ValidateDataConsistency,
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR EmployeeDetails
        RESULT result,
      COPY FOR MODIFY
        IMPORTING
          KEYS FOR ACTION EmployeeDetails~Copy,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR EmployeeDetails
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR EmployeeDetails
        RESULT result,
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS_EMPLOYEEDETAILSALL FOR EmployeeDetailsAll~ValidateTransportRequest
          KEYS_EMPLOYEEDETAILS FOR EmployeeDetails~ValidateTransportRequest.
ENDCLASS.

CLASS LHC_ZI_EMPLOYEEDETAILS IMPLEMENTATION.
  METHOD VALIDATEDATACONSISTENCY.
  mbc_cp_api=>rap_bc_api( )->check_consistency(
    entity   = co_entity
    keys     = REF #( keys )
    failed   = REF #( failed )
    reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_FEATURES.
  mbc_cp_api=>rap_bc_api( )->get_global_features(
    transport_object   = lhc_ZI_EmployeeDetails_S=>co_transport_object
    entity             = co_entity
    requested_features = REF #( requested_features )
    result             = REF #( result )
    reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD COPY.
  mbc_cp_api=>rap_bc_api( )->copy_by_association(
    entity   = co_entity
    keys     = REF #( keys )
    mapped   = REF #( mapped )
    failed   = REF #( failed )
    reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
    entity                   = lhc_ZI_EmployeeDetails_S=>co_authorization_entity
    requested_authorizations = REF #( requested_authorizations )
    result                   = REF #( result )
    reported                 = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_INSTANCE_FEATURES.
  mbc_cp_api=>rap_bc_api( )->get_action_features(
    entity             = co_entity
    keys               = REF #( keys )
    requested_features = REF #( requested_features )
    result             = REF #( result )
    failed             = REF #( failed )
    reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD VALIDATETRANSPORTREQUEST.
  mbc_cp_api=>rap_bc_api( )->validate_transport_request(
    transport_object = lhc_ZI_EmployeeDetails_S=>co_transport_object
    entity           = lhc_ZI_EmployeeDetails_S=>co_entity
    validation_keys  = VALUE #( ( REF #( keys_EmployeeDetailsAll ) )
                                ( REF #( keys_EmployeeDetails ) ) )
    failed           = REF #( failed )
    reported         = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
