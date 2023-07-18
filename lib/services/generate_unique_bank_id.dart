import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateUniqueId(String id) {
  // Преобразование ID в байтовый массив
  List<int> bytes = utf8.encode(id);

  // Вычисление хэша MD5
  Digest md5Hash = md5.convert(bytes);

  // Получение первых 16 байт хэша
  List<int> firstSixteenBytes = md5Hash.bytes.sublist(0, 16);

  // Преобразование байтов в число
  BigInt number = bytesToBigInt(firstSixteenBytes);

  // Ограничение числа до 16 цифр
  BigInt finalNumber = number % BigInt.from(10000000000000000);

  // Преобразование числа в строку
  String result = finalNumber.toString();

  // Добавление пробела после каждого четвертого числа
  StringBuffer formattedResult = StringBuffer();
  for (int i = 0; i < result.length; i++) {
    if (i != 0 && i % 4 == 0) {
      formattedResult.write(' ');
    }
    formattedResult.write(result[i]);
  }

  return formattedResult.toString();
}

BigInt bytesToBigInt(List<int> bytes) {
  BigInt result = BigInt.zero;

  for (int i = 0; i < bytes.length; i++) {
    result = result << 8 | BigInt.from(bytes[i]);
  }

  return result;
}
