// whatsAppUrl
String whatsAppUrl({required String phone, required String message}) =>
    'https://wa.me/$phone/?text=${Uri.parse(message)}';

String selectAPhotoOfMessage(String name) =>
    'Select a photo of $name (Max size 3MB)';

const String unknown = 'Unknown';

const String tooLargeImageError = 'The size of the image is too big. '
    'Please select a smaller sized image and try again.';
