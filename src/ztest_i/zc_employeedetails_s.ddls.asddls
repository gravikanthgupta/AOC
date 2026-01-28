@EndUserText.label: 'Maintain Employee details Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: {
  headerInfo: {
    typeName: 'EmployeeDetailsAll'
  }
}
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity ZC_EmployeeDetails_S
  provider contract TRANSACTIONAL_QUERY
  as projection on ZI_EmployeeDetails_S
{
  @UI.facet: [ {
    id: 'Transport', 
    purpose: #STANDARD, 
    type: #IDENTIFICATION_REFERENCE, 
    label: 'Transport', 
    position: 1 , 
    hidden: #(HideTransport)
  }, {
    id: 'ZI_EmployeeDetails', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Employee details', 
    position: 2 , 
    targetElement: '_EmployeeDetails'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key SingletonID,
  @UI.hidden: true
  LastChangedAtMax,
  @ObjectModel.text.element: [ 'TransportRequestDescription' ]
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  }, {
    type: #FOR_ACTION, 
    dataAction: 'SelectCustomizingTransptReq', 
    label: 'Select Transport'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  TransportRequestID,
  @UI.hidden: true
  _ABAPTransportRequestText.TransportRequestDescription : localized,
  @UI.hidden: true
  HideTransport,
  _EmployeeDetails : redirected to composition child ZC_EmployeeDetails
}
