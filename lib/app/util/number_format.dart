String toThousands(int value) {
  if (value < 1000) {
    return value.toString();
  } else {
    return '${value ~/ 1000}k';
  }
}
String toMillions(int value) {
  if (value < 1000000) {
    return toThousands(value);
  } else {
    return '${value ~/ 1000000}mi';
  }
}

String toBillions(int value) {
  if (value < 1000000000) {
    return toMillions(value);
  } else {
    return '${value ~/ 1000000000}bi';
  }
}

String convertNumbers(int value) {
  return toBillions(value);
}