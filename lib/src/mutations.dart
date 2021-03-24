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
