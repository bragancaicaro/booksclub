import 'dart:io';

import 'package:booksclub/app/util/random_alphanumeric.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class WavToMp3Converter {
  /// Path to the input WAV file
  final String inputPath;
  final String output;
  final BuildContext context;
  /// Constructor to initialize the converter
  WavToMp3Converter({
    required this.inputPath,
    required this.output,
    required this.context,
  });
   
  Future<String> _getConvertedPath() async {
    print('_getConvertedPath');
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
        if(directory == null) {
          return '';
        }
      final folderPath = '${directory.path}/booksclub';
      final filename = 'booksclub_${generateRandomAlphanumeric(7)}.mp3';
      String newPath = '$folderPath/$filename';
      
      final fileMP3 = File(newPath);
      print(fileMP3.path);
      if (!await fileMP3.exists()) {
        await fileMP3.create();
      }
      print('path mp3 $newPath');
      return newPath;
    }
    
  Future<File?> convert() async {
  final storagePermissionStatus = await _checkStoragePermission();
  // ... código de permissão (opcional)

  try {
    if (await File(inputPath).exists()) {
      final fileMP3 = File(output);

      if (!await fileMP3.exists()) {
        await fileMP3.create();
      }
      print('path mp3 in conversor ----------> $output');

      final session = await FFmpegKit.execute(
          '-i $inputPath -acodec libmp3lame -vn -ar 44100 -ac 2 -b:a 192k -y $output -metadata album="booksclub"');
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('sucess convert-----------------------<<<');
        if (await fileMP3.exists()) {
          return fileMP3; // Retorna o arquivo convertido
        } else {
          return null; // Erro inesperado (arquivo não criado)
        }
      } else {
        return null; // Erro na conversão (código de retorno diferente de sucesso)
      }
    } else {
      return null; // Arquivo de entrada não existe
    }
  } on PlatformException {
    return null;
  } on Exception {
    return null;
  }
}

  
Future<PermissionStatus> _checkStoragePermission() async {
  final storagePermissionStatus = await Permission.storage.status;
  return storagePermissionStatus;
}

Future<bool> _requestStoragePermission() async {
  final result = await Permission.manageExternalStorage.request();
  final resultStorage = await Permission.storage.request();
  if (result == PermissionStatus.granted || resultStorage == PermissionStatus.granted) {
	return true;
  } else {
	return false;
  }
}


}

