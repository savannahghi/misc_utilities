String formatPhoneNumber(String phoneNumber) {
  String formattedPhoneNumber;

  if (phoneNumber[1] == '1') {
    // US number
    formattedPhoneNumber = '(${phoneNumber.substring(0, 2)}) ${phoneNumber.substring(2, 5)}-${phoneNumber.substring(5, phoneNumber.length)}';
  } else {
    // Other numbers
    formattedPhoneNumber = '(${phoneNumber.substring(0, 4)}) ${phoneNumber.substring(4, 7)}-${phoneNumber.substring(7, phoneNumber.length)}';
  }

  return formattedPhoneNumber;
}
