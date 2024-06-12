import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class TalkPageManager {


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
  TalkPageManager() {
    _init();
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
  void setUrl(url) async {
    await _audioPlayer.setUrl(
        url,
    );
  
  }
  void play() { 
    _audioPlayer.play(); 
  }
  void pause() { 
    _audioPlayer.pause(); 
    
  }

  void dispose() { 
    _audioPlayer.dispose(); 
  }
  void seek(Duration position) {
    _audioPlayer.seek(position);
  }
  void volume(bool volume) {
    if (volume) {
      _audioPlayer.setVolume(0.0);
    } else {
      _audioPlayer.setVolume(1.0);
    }
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
  paused, playing, loading,
}

enum ButtonSpeed {
    speed_1, speed_1_25, speed_1_5, speed_2,
}

enum TypeTalk {
  audio, text, 
}
