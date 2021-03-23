String uploadMutationQuery = r'''
  mutation Upload($input: UploadInput!) {
  upload(input: $input) {
    id
    url
    size
    hash
    creation
    title
    contentType
    language
    base64data
  }
}
''';
 const String setupUserAsExperimentParticipant = r'''
mutation SetupExperimentParticipant($participate:Boolean){
  setupAsExperimentParticipant(participate:$participate)
}
''';

Map<String, dynamic> setupAsExperimentParticipantVariables(
    {bool participate = false}) {
  return <String, dynamic>{'participate': participate};
}


String setCommSettingsMutation = r'''
mutation SetUserCommunicationsSettings($allowWhatsApp: Boolean, $allowTextSMS: Boolean, $allowPush: Boolean, $allowEmail: Boolean) {
  setUserCommunicationsSettings(allowWhatsApp: $allowWhatsApp, allowTextSMS: $allowTextSMS, allowPush: $allowPush, allowEmail: $allowEmail){
    allowWhatsApp
    allowPush
    allowEmail
    allowTextSMS
  }
}
 ''';
 
String uploadMutation = r'''
  mutation Upload($input: UploadInput!) {
  upload(input: $input) {
    id
    url
    size
    hash
    creation
    title
    contentType
    language
    base64data
  }
}
''';