import 'dart:async';
import 'dart:io';

import 'package:booksclub/app/api.dart';
import 'package:booksclub/app/token/get_token.dart';
import 'package:booksclub/app/ui/pages/book/page_manager/converter_audio.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:booksclub/app/util/random_alphanumeric.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class SendTalkAudioWidget extends StatefulWidget {
  final String subjectTalk;
  final String pathAudioWav;
  final String bookId;
  const SendTalkAudioWidget({required this.subjectTalk, required this.pathAudioWav, required this.bookId, super.key});

   @override
  State<SendTalkAudioWidget> createState() => _SendTalkAudioWidgetState();
}
class _SendTalkAudioWidgetState extends State<SendTalkAudioWidget> {
  late Timer _timer;
  int _textIndex = 0;
  AppLocalizations? _localizations;
  List<String> _texts = [];
  @override
  void initState() {
    super.initState();
    
    convertAudioTalk(widget.pathAudioWav);
    
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      setState(() {
        _textIndex = (_textIndex + 1) % _texts.length;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = AppLocalizations.of(context);
    _texts = [
      _localizations!.audio_convert_and_send_1,
      _localizations!.audio_convert_and_send_2,
      _localizations!.audio_convert_and_send_3,
      _localizations!.audio_convert_and_send_4,
      _localizations!.audio_convert_and_send_5,
      // ... add more localized texts
    ];
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
                AppLocalizations.of(context).converting_sending_file,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 24, color: Colors.grey.shade100),
              ),
          ),
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child:Text(
              _texts[_textIndex],
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 20, color: Colors.grey.shade100),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
            child: LinearProgressIndicator(
              value: null, // Set to null for indeterminate progress
              backgroundColor: Colors.grey[200], // Background color (optional)
              color: Colors.grey.shade500, // Color of the progress bar (optional)
            ),
          ),
          
        ],
      ),
    );
  }
  
  Future<String> _getConvertedPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
        if(directory == null) {
          return '';
        }
      final folderPath = '${directory.path}/booksclub';
      final filename = 'booksclub_${generateRandomAlphanumeric(7)}.mp3';
      return '$folderPath/$filename';
      
    }
  
  
convertAudioTalk(String pathaudio) async {

  final WavToMp3Converter converttomp3 = WavToMp3Converter(
      inputPath: pathaudio, output: await _getConvertedPath(), context: context);
  File? filemp3 = await converttomp3.convert(); // Use await here

  if (filemp3 != null) {
    sendAudioFile(filemp3);
  } else {
    CustomSnackbar.show(
        context,
        AppLocalizations.of(context).error_ocurred, // Provide more specific error message
        Colors.redAccent,
      );
      Navigator.of(context).pop();
  }
}

 sendAudioFile(File filemp3) async {
  
  final url = Uri.parse(Api.talk);

  var request = http.MultipartRequest('POST', url);

  request.headers.addAll({
    'Authorization': (await getToken() ?? ''),
  });

  request.fields['book'] = widget.bookId;
  request.fields['subject'] = widget.subjectTalk;
  request.fields['type'] = 'a';

  request.files.add(
    await http.MultipartFile.fromPath(
      'audio_file',
      filemp3.path, // Use widget.pathAudioWav directly
      contentType: MediaType('audio', 'audio/mpeg'),
    ),
  );

  try {
    final response = await request.send();
    Navigator.of(context).pop();
    if (response.statusCode == 201) {
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context).talk_added,
        Colors.grey.shade500,
      );
      Navigator.of(context).pop();
    } else {
      // Handle non-201 response codes (e.g., display an error message)
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context).error_ocurred, // Provide more specific error message
        Colors.redAccent,
      );
      Navigator.of(context).pop();
    }
  } catch (error) {
    // Handle network or other errors
    CustomSnackbar.show(
      context,
      AppLocalizations.of(context).error_ocurred,
      Colors.redAccent,
    );
    Navigator.of(context).pop();
  }
}

  

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }



}
