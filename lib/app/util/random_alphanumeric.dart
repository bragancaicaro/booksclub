import 'dart:math';

String generateRandomAlphanumeric(int length) {
  const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
  final Random rnd = Random();

  StringBuffer result = StringBuffer();
  for (int i = 0; i < length; i++) {
    final char = chars[rnd.nextInt(chars.length)];
    result.write(char);
  }

  return result.toString();
}

void main() {
  final randomString = generateRandomAlphanumeric(5);
  print(randomString); // Example output: T2hKN
}