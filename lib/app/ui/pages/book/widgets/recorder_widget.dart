import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:booksclub/app/ui/pages/book/page_manager/record_manager.dart';
import 'package:booksclub/app/ui/pages/book/pages/send_talk_audio.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:booksclub/app/ui/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class RecorderWidget extends StatefulWidget {
  final String bookId;
  const RecorderWidget({super.key, required this.bookId});

  @override
  _RecorderWidgetState createState() => _RecorderWidgetState();
}

class _RecorderWidgetState extends State<RecorderWidget> {
  final RecorderManager _recorder = RecorderManager();
  String _elapsedTime = '00:00';
  bool _isDone = false;
  bool _isRecording = false;
  bool _isFastForward = false;
  bool _isSubjectEmpty = false;
  bool _isRecordingDone = false;
  final _subjectController =  TextEditingController();
  @override
  void initState() {
    super.initState();
    _recorder.addListener(() {
      setState(() {
        
        _elapsedTime = _recorder.getElapsedTime;
        _isRecording = _recorder.isRecording;
        _isDone = _recorder.isDone;
       
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
                                        height: 600,
                                        alignment: Alignment.center,
                                        color: Colors.grey.shade300,
                                        child: Column(
                                          
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: IconButton(icon: const Icon(Icons.close), 
                                                onPressed: (){
                                                  Navigator.pop(context);
                                                },),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: StatefulBuilder(
                                                builder: (context, setState) => Column(
                                                children: [ CustomTextField(
                                                                    controller: _subjectController,
                                                                    keyboardType: TextInputType.text,
                                                                    maxLength: 140,
                                                                    obscureText: false,
                                                                    errorText: _isSubjectEmpty ? AppLocalizations.of(context).enter_subject : null,
                                                                    hint: AppLocalizations.of(context).enter_subject,
                                                                    suffixIcon: IconButton(
                                                                            icon:  Icon(Icons.send_outlined, color:_isDone ? Colors.grey.shade900 : Colors.grey.shade500,),
                                                                            onPressed: () async {
                                                                              if(_subjectController.text.isEmpty){
                                                                                setState(() {
                                                                                  _isSubjectEmpty = true;
                                                                                });
                                                                              } else {
                                                                                setState(() {
                                                                                  _isSubjectEmpty = false;
                                                                                });
                                                                              }

                                                                              if(!_recorder.isDone){
                                                                                setState(() {
                                                                                  _isRecordingDone = true;
                                                                                });
                                                                              } else {
                                                                                setState(() {
                                                                                  _isRecordingDone = false;
                                                                                });
                                                                              }

                                                                              if(await _recorder.getRecordedFile() != null) {
                                                                                File? audioFileWav = await _recorder.getRecordedFile();
                                                                                if(audioFileWav == null){
                                                                                  CustomSnackbar.show(context, AppLocalizations.of(context).error_ocurred, Colors.redAccent);
                                                                                  return;
                                                                                }
                                                                                String pathaudio = audioFileWav.path;
                                                                                Navigator.push(
                                                                                  context,
                                                                                  PageRouteBuilder(
                                                                                    transitionDuration: const Duration(milliseconds: 500),
                                                                                    transitionsBuilder: (context, animation1, animation2, child) {
                                                                                      return FadeTransition(
                                                                                        opacity: animation1,
                                                                                        child: child,
                                                                                      );
                                                                                    },
                                                                                    pageBuilder: (context, animation1, animation2) {
                                                                                      return SendTalkAudioWidget(subjectTalk: _subjectController.text, pathAudioWav: pathaudio, bookId: widget.bookId);
                                                                                    },
                                                                                  ),
                                                                                );
                                                                                
                                                                                
                                                                        
                                                                              } else {
                                                                                CustomSnackbar.show(context, AppLocalizations.of(context).error_ocurred, Colors.redAccent);
                                                                              }
                                                                              
                                                                            },
                                                                            
                                                                          ),
                                                                  ),
                                                    ])
                                                
                                              ),
                                            ),
                                          const SizedBox(height: 10,),
                                          Text(_elapsedTime, style: TextStyle(color: Colors.grey.shade700, fontSize: 18),),
                                          _isRecordingDone ?  
                                          Padding(
                                            padding:const EdgeInsets.symmetric(vertical: 15), 
                                            child: Text(AppLocalizations.of(context).empty_audio, style: const TextStyle(color: Colors.redAccent, fontSize: 16),)
                                          ) 
                                          : const SizedBox(height: 10,),
                                          
                                          Row(children: [
                                              const Spacer(),
                                              Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade800,
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            ),
                                            child: IconButton(
                                            onPressed: () {
                                              if(_isDone){
                                                _recorder.pause();
                                              } else {
                                                _recorder.pauseRecording();
                                              }
                                            }, 
                                            icon: const Icon(
                                              Icons.pause_outlined, 
                                              size: 20, 
                                              color: Colors.white,),
                                          ),
                                          ),
                                                const Spacer(),
                                                Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade800,
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            ),
                                            child: IconButton(
                                            onPressed: () async {
                                              if(_isDone) {
                                                  
                                                  _recorder.play();
                                                
                                              } else {
                                                _recorder.startRecording();
                                              }
                                            }, 
                                            icon: Icon(
                                              _isDone ? Icons.play_arrow : Icons.mic_outlined, 
                                              size: 54, 
                                              color: Colors.white,),
                                          ),
                                          ),
                                                const Spacer(),
                                                !_isDone ? Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade800,
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              ),
                                              child: IconButton(
                                              onPressed: () async {
                                                  if(!_isDone){
                                                    _recorder.doneRecording();
                                                    if(await _recorder.getRecordedFile() != null) {
                                                      File? audioFileWav = await _recorder.getRecordedFile();
                                                      if(audioFileWav == null){
                                                        CustomSnackbar.show(context, AppLocalizations.of(context).error_ocurred, Colors.redAccent);
                                                      }
                                                      String pathaudio = audioFileWav!.path;
                                                      _recorder.setUri(pathaudio);
                                                    } else {
                                                      CustomSnackbar.show(context, AppLocalizations.of(context).error_ocurred, Colors.redAccent);
                                                    }
                                                  } else {
                                                    setState(() {
                                                      _isRecordingDone = false;
                                                    });
                                                  }
                                              }, 
                                              icon: Icon(
                                                _isDone ? Icons.fast_forward_outlined : Icons.done, 
                                                size: 20, 
                                                color: Colors.white,),
                                            ),
                                            ) : Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade800,
                                      
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                ),
                                                child: ValueListenableBuilder<ButtonSpeed>(
                                                  valueListenable: _recorder.buttonSpeed,
                                                  builder: (_, value, __) {
                                                    switch (value) {
                                                      case ButtonSpeed.speed_1:
                                                        return IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _recorder.setSpeed(ButtonSpeed.speed_1_25);
                                                            _isFastForward = true;
                                                          });
                                                        }, 
                                                        
                                                        icon: const Icon(
                                                          Icons.fast_forward, 
                                                          size: 20, 
                                                          color: Colors.white,),
                                                                                      );
                                                      case ButtonSpeed.speed_1_25:
                                                        return Badge(
                                                          label: const Text('1.25'),
                                                          backgroundColor: Colors.grey.shade600,
                                                          child: IconButton(
                                                              icon: const Icon(Icons.fast_forward, size: 20,  color: Colors.white,),
                                                              onPressed: () {        
                                                                setState(() {
                                                            _recorder.setSpeed(ButtonSpeed.speed_1_5);
                                                            _isFastForward = true;
                                                          });
                                                              }, 
                                                                                
                                                          ),
                                                        );
                                                      case ButtonSpeed.speed_1_5:
                                                        return Badge(
                                                          label: const Text('1.5'),
                                                          backgroundColor: Colors.grey.shade600,
                                                          child: IconButton(
                                                              icon: const Icon(Icons.fast_forward,size: 20,  color: Colors.white,),
                                                              onPressed: () {        
                                                              setState(() {
                                                                _recorder.setSpeed(ButtonSpeed.speed_2);
                                                                _isFastForward = true;
                                                              });
                                                              }, 
                                                                                
                                                          ),
                                                        );
                                                    case ButtonSpeed.speed_2:
                                                        return Badge(
                                                          label: const Text('2'),
                                                          backgroundColor: Colors.grey.shade600,
                                                          child: IconButton(
                                                              icon: const Icon(Icons.fast_forward,size: 20,  color: Colors.white,),
                                                              onPressed: () {        
                                                                setState(() {
                                                                  _recorder.setSpeed(ButtonSpeed.speed_1);
                                                                  _isFastForward = false;
                                                                });
                                                              }, 
                                                                                
                                                          ),
                                                        );
                                                    }
                                                  },
                                                ),
                                                
                                                
                                                
                                              ),
                                                
                                                const Spacer(),
                                          ]),
                                          const SizedBox(height: 10,),
                                        _isDone ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20), 
                                          child: ValueListenableBuilder <ProgressBarState>( 
                                          valueListenable: _recorder.progressNotifier, 
                                          builder: (_, value, __) { 
                                            return ProgressBar ( 
                                              thumbColor: Colors.grey.shade800,
                                              baseBarColor: Colors.grey.shade500,
                                              bufferedBarColor: Colors.black26,
                                              thumbGlowColor: Colors.black26,
                                              progressBarColor: Colors.black54,
                                              timeLabelTextStyle: const TextStyle(
                                                color: Colors.black, 
                                                fontSize: 14,
                                              ),
                                              progress: value.current, 
                                              buffered: value.buffered, 
                                              total: value.total,
                                              onSeek: _recorder.seek,
                                            ); 
                                          }, 
                                        ),
                                        ) : const SizedBox(),

                                          const SizedBox(height: 20,),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade800,
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            ),
                                            child: IconButton(
                                            onPressed: () {
                                              _recorder.clearRecording();
                                              _recorder.removeListener(() {});
                                              setState(() {
                                                _isDone = false;
                                                _isRecording = false;
                                              });
                                            }, 
                                            icon: const Icon(
                                              Icons.close, 
                                              size: 20, 
                                              color: Colors.white,),
                                          ),
                                          ),
                                        
                                        
                                          
                                        ]),
                                        ),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    _recorder.removeListener(() {});
    super.dispose();
  }
}



