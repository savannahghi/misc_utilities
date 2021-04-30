// whatsAppUrl
String whatsAppUrl({required String phone, required String message}) =>
    'https://wa.me/$phone/?text=${Uri.parse(message)}';

String selectAPhotoOfMessage(String name) => 'Select a photo of $name';
