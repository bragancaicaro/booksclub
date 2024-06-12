import 'dart:io';
import 'package:booksclub/app/util/random_alphanumeric.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecorderManager with ChangeNotifier {
  final _record = AudioRecorder();
  String _recordingPath = '';
  bool _isRecording = false;
  bool _isDone = false;
  final Stopwatch _stopwatch = Stopwatch();
  final int _maxRecordingDuration = 3540;
  int _recordedSeconds = 0;
  String _elapsedTime = '00:00';
  String _elapsedTimeFinal = '';

  String getFinalRecordingPath() => _recordingPath;


  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  final buttonSpeed = ValueNotifier<ButtonSpeed>(ButtonSpeed.speed_1);
  var url;
  late AudioPlayer _audioPlayer;
  final ButtonSpeed _selectedSpeed = ButtonSpeed.speed_1; // Valor inicial

  ValueNotifier<ButtonSpeed> get selectedSpeedNotifier => ValueNotifier(_selectedSpeed);

  RecorderManager() {
    _init();
  }
  Future<void> _getRecordingPath() async {

    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if(directory == null) {
      return;
    }
    final folderPath = '${directory.path}/booksclub';
      // Crie o diretório se não existir
      await Directory(folderPath).create(recursive: true);
      final filename = 'booksclub_record_${generateRandomAlphanumeric(5)}.wav';
      _recordingPath = '$folderPath/$filename';

  }

  bool get isRecording => _isRecording;
  bool get isDone => _isDone;
  Future<void> startRecording() async {
    if (_isRecording) return;
      
      final hasPermission = await _record.hasPermission();
    if (!hasPermission) {
      print('erro solicitar permissao');
      return;
    }

      await _getRecordingPath();
      print(_recordingPath);
      await _record.start(
      const RecordConfig(
        sampleRate: 44100, // Ajustar taxa de amostragem se necessário
        bitRate: 128000,
        encoder: AudioEncoder.wav,
      ),
      path: _recordingPath,
      ).onError((error, stackTrace) => startRecording());
      



      _isRecording = true;
    _stopwatch.start();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      _recordedSeconds = _stopwatch.elapsedMilliseconds ~/ 1000;
      if (_recordedSeconds >= _maxRecordingDuration) {
        stopRecording();
      }
      notifyListeners(); // Notify UI about recording and elapsed time
      return _isRecording;
    });
    }
    
    //await _record.start(const RecordConfig(bitRate:128000, encoder:AudioEncoder.pcm16bits), path: _recordingPath);


  Future<void> pauseRecording() async {
    if (!_isRecording) return;

    await _record.pause();
    _isRecording = false;
    _stopwatch.stop();
    _elapsedTimeFinal = getElapsedTime;
    notifyListeners();
  }
  Future<void> doneRecording() async {
    if (!_isRecording) return;
    _recordedSeconds = _stopwatch.elapsedMilliseconds ~/ 1000;
    if(_recordedSeconds < 10) {
      return;
    }
    _isRecording = false;
    _isDone = true;
    _elapsedTimeFinal = getElapsedTime;
    _stopwatch.stop();
    await _record.stop();
    
    notifyListeners();
  }
  Future<File?> getRecordedFile() async {
    if(_recordingPath.isEmpty){
      print('recorder path is null');
      return null;
    }
    return File(_recordingPath);
}
  Future<void> resumeRecording() async {
    if (!_isRecording) return;

    await _record.resume();
    _isRecording = true;
    _stopwatch.start();
    notifyListeners();
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    await _record.stop();
    _isRecording = false;
    _recordedSeconds = _stopwatch.elapsedMilliseconds ~/ 1000;
    _stopwatch.stop();
    notifyListeners(); // Notify UI about recording stop and elapsed time
  }

  

  String get getElapsedTime {
    final minutes = (_recordedSeconds ~/ 60).floor();
    final seconds = (_recordedSeconds % 60).floor();
    _elapsedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return _elapsedTime;
  }
  Future<void> clearRecording() async {
    _isRecording = false;
    _isDone = false;
    _recordedSeconds = 0;
    _stopwatch.reset();
    _elapsedTime = '00:00';
    _elapsedTimeFinal = '00:00';
    _record.cancel();
    notifyListeners();
  }



  @override
  void dispose() {
    _record.dispose();
    _audioPlayer.dispose(); 
    super.dispose();
  }



  void _init() async {
  
  //AUDIO TALK
  _audioPlayer = AudioPlayer();

  _audioPlayer.playerStateStream.listen((playerState) {
  final isPlaying = playerState.playing;
  final processingState = playerState.processingState;
  if (processingState == ProcessingState.loading ||
      processingState == ProcessingState.buffering) {
    buttonNotifier.value = ButtonState.loading;
  } else if (!isPlaying) {
    buttonNotifier.value = ButtonState.paused;
  } else if (processingState != ProcessingState.completed) {
    buttonNotifier.value = ButtonState.playing;
  } else { // completed
    _audioPlayer.seek(Duration.zero);
    _audioPlayer.pause();
  }
  });
  _audioPlayer.positionStream.listen((position) {
    final oldState = progressNotifier.value;
    progressNotifier.value = ProgressBarState(
      current: position,
      buffered: oldState.buffered,
      total: oldState.total,
    );
  });
  _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
    final oldState = progressNotifier.value;
    progressNotifier.value = ProgressBarState(
      current: oldState.current,
      buffered: bufferedPosition,
      total: oldState.total,
    );
  });
  _audioPlayer.durationStream.listen((totalDuration) {
    final oldState = progressNotifier.value;
    progressNotifier.value = ProgressBarState(
      current: oldState.current,
      buffered: oldState.buffered,
      total: totalDuration ?? Duration.zero,
    );
  });
  
  }
  
  void play() { 
    _audioPlayer.play(); 
  }
  void pause() { 
    _audioPlayer.pause(); 
    
  }
  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

void setUri(String localFile) async {
    if(!_isDone) return;
    if(localFile.isEmpty) return;
    //await _audioPlayer.setAsset(localAsset);
    await _audioPlayer.setAudioSource(AudioSource.file(localFile)).onError((error, stackTrace) => null);
    await _audioPlayer.load().onError((error, stackTrace) => null);
  }

  void speed(double speed) {
    _audioPlayer.setSpeed(speed);
  }
  void setSpeed(ButtonSpeed newSpeed) {
    switch(newSpeed) {
      case ButtonSpeed.speed_1:
        buttonSpeed.value = ButtonSpeed.speed_1;
        speed(1.0);
      case ButtonSpeed.speed_1_25:
        buttonSpeed.value = ButtonSpeed.speed_1_25;
        speed(1.25);
      case ButtonSpeed.speed_1_5:
         buttonSpeed.value = ButtonSpeed.speed_1_5;
        speed(1.5);
      case ButtonSpeed.speed_2:
         buttonSpeed.value = ButtonSpeed.speed_2;
        speed(2.0);
      default:
         buttonSpeed.value = ButtonSpeed.speed_1;
        speed(1.0);
    }
    
  }


  


}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState {
  paused, recording, playing, loading,
}

enum ButtonSpeed {
    speed_1, speed_1_25, speed_1_5, speed_2,
}