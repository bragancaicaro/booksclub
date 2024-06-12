import 'dart:convert';
import 'dart:async';
import 'package:booksclub/app/ads/ads_banner.dart';
import 'package:booksclub/app/repositories/replies.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:booksclub/app/ui/widgets/custom_text_field.dart';
import 'package:booksclub/app/util/number_format.dart';
import 'package:booksclub/app/util/on_share.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:booksclub/app/api.dart';
import 'package:booksclub/app/util/font_size.dart';
import 'package:booksclub/app/models/update.dart';
import 'package:booksclub/app/token/get_token.dart';
import 'package:booksclub/app/models/talk.dart';
import 'package:booksclub/app/repositories/comments.dart';
import 'package:booksclub/app/util/date_format.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';

import '../page_managers/talk_page_manager.dart';

class TalkPage extends StatefulWidget {
  final String itemId;
  const TalkPage({super.key, required this.itemId});
  
  @override
  State<TalkPage> createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> with AutomaticKeepAliveClientMixin {
  late final TalkPageManager _talkPageManager;
  final ScrollController _scrollController = ScrollController();
  
  bool _updates = false;
  String _updateId = '';
  late Talk? dataTalk;
  bool _isLiked = false;
  String likeId = '';

  //Player
  final player = AudioPlayer(); 
  final bool _isPlay = false;
  bool _isVolume = false;
  final bool _isFastForward = false;
  //endPlayer
  // add commnet
  IconData _iconLike = Icons.favorite_border;

  @override
  void initState() {
    super.initState();
    
    
    _talkPageManager = TalkPageManager();
    
  }

  @override 
void dispose() { 
  
  _talkPageManager.dispose(); 
  super.dispose(); 
}
  @override
  Widget build(BuildContext context){
    super.build(context);
    return FutureBuilder(
      future: fetchTalkData(),
      builder: (context, snapshot) {
      if(snapshot.hasData){
        dataTalk = snapshot.data;
        if (dataTalk?.audioFile != null) {
          _talkPageManager.setUrl('${dataTalk?.audioFile}');
          
        }
        if(dataTalk?.liked != null){
          _isLiked = dataTalk?.liked ?? false;
           if (_isLiked) {
               _iconLike = Icons.favorite;
            } else {
               _iconLike = Icons.favorite_border; 
            }
        }
        if(dataTalk?.update != null){
          _updates = true;
          _updateId = dataTalk?.update ?? '';
        } else {
          _updates = false;
        }  
        
        
        return Scaffold(
          appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Text(
                AppLocalizations.of(context).talk,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
              ),
            
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () =>  onShare(context, '${Api.baseUrlShareTalk}${dataTalk?.id}'),
                  value: true, 
                  child: Text(AppLocalizations.of(context).share),
                ),
                PopupMenuItem(
                  value: true,
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return CheckboxListTile(
                        title: Text(AppLocalizations.of(context).updates),
                        value: _updates,
                        onChanged: (updatesTalk) {
                          
                          update(_updates);
                          setState((){
                            _updates = !_updates;
                          });
                        },
                      );
                    },
                  ),
                ),
                PopupMenuItem(
                  value: true, // Valor da ação de texto
                  child: Text(AppLocalizations.of(context).report),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                          ),
                          title: Text(AppLocalizations.of(context).report_this_talk),
                          content: Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context).want_report),),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Fecha o AlertDialog
                                sendReport();
                              },
                              child: const Text('yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Fecha o AlertDialog
                          
                              },
                              child: const Text('no'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                
              ],
              
            ),
          ],
      ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Column(
                  
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom:8, left:18, right:18),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: double.infinity),
                        child: Text(
                        '${dataTalk?.bookTitle}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,                      
                        ),
                      ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom:18, left:18, right:18),
                      child: Text(
                        '${dataTalk?.subject}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize(dataTalk?.subject),                      
                        ),
                      ),
                    ),
                    
                    dataTalk?.typeTalk == 'a' ?
                    Container(
                      child:Column(
                        children: [ 
                          
                          
                          const SizedBox(height: 18,),
                          Row(
                            children: [
                              const Spacer(),
                              Container(
                                    decoration: const BoxDecoration(
                                      color:Colors.white24,
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child:IconButton(
                                      onPressed: () {
                                          _isVolume = !_isVolume;
                                          _talkPageManager.volume(_isVolume);
                                      }, 
                                      icon: const Icon(
                                        Icons.volume_mute, 
                                        size: 20, 
                                        color: Colors.white,),
                                    ),
                                    
                                  ),
                              const SizedBox(width: 36,),
                              
                              Container(
                                decoration: BoxDecoration(
                                  color: _isPlay ? Colors.white38 : Colors.white24,
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                child: ValueListenableBuilder<ButtonState>(
                                  valueListenable: _talkPageManager.buttonNotifier,
                                  builder: (_, value, __) {
                                    switch (value) {
                                      case ButtonState.loading:
                                        return Container(
                                          padding: const EdgeInsets.all(8.0),
                                          margin: const EdgeInsets.all(8.0),
                                          width: 54.0,
                                          height: 54.0,
                                          child: const CircularProgressIndicator(color: Colors.white54),
                                        );
                                      case ButtonState.paused:
                                        return IconButton(
                                            icon: const Icon(Icons.play_arrow, size: 54, color: Colors.white,),
                                            onPressed: () {        
                                              _talkPageManager.play();
                                            }, 
                                                              
                                        );
                                      case ButtonState.playing:
                                        return IconButton(
                                          icon: const Icon(Icons.pause, size: 54, color: Colors.white,),
                                          iconSize: 32.0,
                                          onPressed: () {_talkPageManager.pause();},
                                        );
                                    }
                                  },
                                ),
                                
                                
                                
                              ),
                              const SizedBox(width: 36,),
                              Container(
                                decoration: BoxDecoration(
                                  color: _isFastForward ?Colors.white38 :  Colors.white24,
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                child: ValueListenableBuilder<ButtonSpeed>(
                                  valueListenable: _talkPageManager.buttonSpeed,
                                  builder: (_, value, __) {
                                    switch (value) {
                                      case ButtonSpeed.speed_1:
                                        return IconButton(
                                        onPressed: () {
                                          _talkPageManager.setSpeed(ButtonSpeed.speed_1_25);
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
                                                _talkPageManager.setSpeed(ButtonSpeed.speed_1_5);
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
                                               _talkPageManager.setSpeed(ButtonSpeed.speed_2);
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
                                                _talkPageManager.setSpeed(ButtonSpeed.speed_1);
                                              }, 
                                                                
                                          ),
                                        );
                                    }
                                  },
                                ),
                                
                                
                                
                              ),
                              
                              
                              const Spacer(),
                            ],
                          
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.only(left: 18, right: 18, top:24, bottom:18), 
                            child: ValueListenableBuilder <ProgressBarState>( 
                            valueListenable: _talkPageManager.progressNotifier, 
                            builder: (_, value, __) { 
                              return ProgressBar ( 
                                thumbColor: Colors.white70,
                                baseBarColor: Colors.white,
                                bufferedBarColor: Colors.black26,
                                thumbGlowColor: Colors.black26,
                                progressBarColor: Colors.black54,
                                timeLabelTextStyle: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 14,
                                ),
                                progress: value.current, 
                                buffered: value.buffered, 
                                total: value.total,
                                onSeek: _talkPageManager.seek,
                              ); 
                            }, 
                          ),
                          ),
                        ]
                      )
                    ) : const SizedBox(),    
                    Container(
                      padding: const EdgeInsets.only(right: 18, left: 18, bottom: 8),
                      child: Row(
                        children: [
                          const Spacer(), 
                          Container(
                            constraints: const BoxConstraints(maxWidth: 105),
                            child: Text(
                              '${dataTalk?.userName}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,                  
                              ),
                            ),
                        ),
                        ]
                      ),
                    ),
                    
                    Container(
                    padding: const EdgeInsets.only(left: 18, right:18),
                    child: Row(
                      children: [
                        GestureDetector(
                        onTap: () {
                          if (_isLiked) {
                            _iconLike = Icons.favorite; // Set color for liked state
                            setState(() {});
                          } else {
                            _iconLike = Icons.favorite_border; // Set color for disliked state
                            setState(() {});
                          }
                            
                          
                          like(_isLiked);
                        
                        },
                        child: Icon(
                            _iconLike, 
                            size: 22, 
                            color: Colors.white70,
                          )
                                                
                                                ),
                      
                      const SizedBox(width: 2,),
                        Text(
                            convertNumbers(dataTalk?.likeCount ?? 0), 
                            style: const TextStyle(
                              fontSize: 16, 
                              color: Colors.white70, 
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        
                        const SizedBox(width: 10,),

                        const Icon(
                            Icons.comment_outlined, 
                            size: 20, 
                            color: Colors.white70,),
                        const SizedBox(width: 2,),
                        Text(
                            convertNumbers(dataTalk?.commentCount ?? 0), 
                            style: const TextStyle(
                              fontSize: 16, 
                              color: Colors.white70, 
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        const Spacer(),
                        
                        
                        const SizedBox(width: 14,),
                        
                        Text(
                            returnDateFormat(dataTalk?.dateCreated ?? ''),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,                  
                            ),
                          ),
                      ],
                    ),),
                  
                    
                    
                  ], 
                  ),
                ),
                  
                const SizedBox(height: 10,),
                
            
              CommentListWidget(
                  itemId: widget.itemId,
                  scrollController: _scrollController,
                ),
            ],
            ),
          ),
        ); 
      } else if (snapshot.hasError) {
        return Text(AppLocalizations.of(context).error_ocurred);
      } else {
        return Center(
                              child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            margin: const EdgeInsets.all(8.0),
                                            width: 54.0,
                                            height: 54.0,
                                            child: CircularProgressIndicator(color: Colors.grey.shade900),
                                          ),
                            );
      }  
    
      
      }
    
    );    
    
  }
  
  Future<Talk> fetchTalkData() async {
    try {
      var url = Uri.parse('${Api.talk}${widget.itemId}/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': (await getToken()) ?? '',
          'Content-Type': 'application/json; charset=utf-8',
        },
    );

    if (response.statusCode == 200) {

      final data = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      return Talk.fromJson(data);
    } else {
      // Se a resposta não for bem-sucedida, você pode lançar uma exceção ou retornar null, dependendo do que faz sentido para o seu caso.
      throw Exception('Erro na solicitação HTTP: ${response.body}');
    }
    } catch (error) {
      // Captura e trata qualquer exceção que possa ocorrer durante o process
      rethrow; // Re-lança a exceção para que a função chamadora também possa lidar com ela
    }
  }

  
  
  Future removeLike() async {
    String like = dataTalk?.likeId;
    var url = Uri.parse('${Api.like}$like/');
   
    
    var response = await http.delete(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
    );

    if(response.statusCode == 204) { 
       
    }
  }
  
  void like(bool isLiked) {
    if(isLiked) {
      removeLike();
    } else {
      sendLike();
    }

  }

  void update(bool isUpdate){
    if(isUpdate) {
      removeUpdate();
    } else {
      sendUpdate();
    }
  }
  
  Future removeUpdate() async {
    String update = _updateId;
    var url = Uri.parse('${Api.update}$update/');
   
    
    var response = await http.delete(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
    );

  
  }
  
  Future sendUpdate() async {
    var url = Uri.parse(Api.update);
    String talk = widget.itemId;
   
    final body = {
        'type_update': 't',
        'talk': talk
    }; 
    var response = await http.post(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
      body: jsonEncode(body)
    );
    final data = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
    Update update = Update.fromJson(data);
    _updateId = update.id;
    
  }
Future sendLike() async {
    var url = Uri.parse(Api.like);
    String talk = widget.itemId;
   
    final body = {
        'talk': talk,
    }; 
    var response = await http.post(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
      body: jsonEncode(body)
    );

    if(response.statusCode == 201) {  
    
    }
  }
  @override
  bool get wantKeepAlive => true;




  Future sendReport() async {
    var url = Uri.parse(Api.report);
    String talk = widget.itemId;
   
    final body = {
        'type_report': 't',
        'talk': talk,
    }; 
    var response = await http.post(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
      body: jsonEncode(body)
    );

    if(response.statusCode == 201) {  
      CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).reported, 
        Colors.redAccent);
    }
  }
}



class CommentListWidget extends StatefulWidget {
  final String itemId;
  final ScrollController scrollController;
  

  const CommentListWidget({
    required this.itemId,
    required this.scrollController,
    super.key, 
  });

  @override
  _CommentListWidgetState createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> with AutomaticKeepAliveClientMixin {
  final _replyController = TextEditingController();


  final _commentController = TextEditingController();

  late CommentsManager _commentsManager;

  @override
  void initState() {
    super.initState();
    
    _commentsManager = CommentsManager('${Api.talkComments}${widget.itemId}');
    _loadItems();
    
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.atEdge &&
          widget.scrollController.position.pixels ==
              widget.scrollController.position.maxScrollExtent &&
          !_commentsManager.isLoading) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _loadItems() async {
    _commentsManager.clear();
    setState(() {});
    await _commentsManager.fetchItems(url:'${Api.talkComments}${widget.itemId}');
    setState(() {});
  }

  Future<void> _loadMoreItems() async {
    final nextPage = _commentsManager.getNextPage();
    if (nextPage != null) {
      
      await _commentsManager.fetchItems(url: nextPage);
      setState(() {});
    }
  }


  void sendReplyComment(String idComment) async {
    
    if(_commentController.text.toString().trim().length > 140) {
      return;
    }
    
    var url = Uri.parse(Api.comment);
    String talk = widget.itemId;
    String reply = _replyController.text.toString().trim();
    
      final body = {
        'talk': talk,
        'parent_comment': idComment,
        'message': reply,
      }; 
       var response = await http.post(
        url, 
        headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
        },
        body: jsonEncode(body)
      );
      
      if(response.statusCode == 201) {
        
       _replyController.text = '';
        
        CustomSnackbar.show(
          context, 
          AppLocalizations.of(context).reply_sent, 
          Colors.grey.shade500
        );
        await _loadItems();
      } else {
        
        CustomSnackbar.show(
          context, 
          AppLocalizations.of(context).error_ocurred, 
          Colors.redAccent
        );
        
      }
  }
  

  
  void sendComment() async {
    
    if(_commentController.text.toString().trim().length > 140) {
      return;
    }
    
    var url = Uri.parse(Api.comment);
    String talk = widget.itemId;
    String comment = _commentController.text.trim();
    
      final body = {
        'talk': talk,
        'message': comment,
      }; 
       var response = await http.post(
        url, 
        headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
        },
        body: jsonEncode(body)
      );
     
      if(response.statusCode == 201) {
        
       _commentController.text = '';
        
        CustomSnackbar.show(
          context, 
          AppLocalizations.of(context).comment_sent, 
          Colors.grey.shade500
        );
        await _loadItems();
      } else {
        
        CustomSnackbar.show(
          context, 
          AppLocalizations.of(context).error_ocurred, 
          Colors.redAccent
        );
        
      }
  }
  


  @override
  Widget build(BuildContext context) {
   super.build(context);

    return SingleChildScrollView(
      child: Column(
        children:[ 
          
          Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    controller: _commentController,
                      keyboardType: TextInputType.text,
                      maxLength: 140,
                      obscureText: false,
                      hint: AppLocalizations.of(context).enter_comment,
                      suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.send_outlined,
                            size: 24,
                            color: Colors.black87,
                        ), 
                        onPressed: () { 
                            sendComment();
                        },

                      ),
                    ),
                    
                ),
                const SizedBox(height: 10,),
                
              Column(
              children: List.generate(
                _commentsManager.items.length,
                (index) {
                  final item = _commentsManager.items[index];
                  return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        children: [ GestureDetector(
                      onLongPress: () {
                      
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context).actions),
                              contentPadding: const EdgeInsets.all(18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                              ),
                              content: SizedBox(
                                height: 135,
                                child: Column(
                                  children: <Widget>[
                                  item.isMe ? 
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding: const EdgeInsets.all(18),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                                            ),
                                            title: Text(AppLocalizations.of(context).delete),
                                            content: Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context).delete),),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Fecha o AlertDialog
                                                  deleteComment(context,item.id);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(AppLocalizations.of(context).yes),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context); // Fecha o AlertDialog
                                                  // Lógica a ser executada quando o segundo botão é pressionado
                                                },
                                                child: Text(AppLocalizations.of(context).no),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      
                                      
                                      
                                    },
                                    child: Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(AppLocalizations.of(context).delete),),
                                      const Spacer(),
                                    ],),
                                  ) : SizedBox(),
                                  const SizedBox(height: 10,),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding: const EdgeInsets.all(18),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                                            ),
                                            title: Text(AppLocalizations.of(context).report_this_comment),
                                            content: Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context).want_report),),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Fecha o AlertDialog
                                                  sendReportComment(context,item.id);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(AppLocalizations.of(context).yes),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context); // Fecha o AlertDialog
                                                  // Lógica a ser executada quando o segundo botão é pressionado
                                                },
                                                child: Text(AppLocalizations.of(context).no),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      
                                      
                                      
                                    },
                                    child: Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(AppLocalizations.of(context).report),),
                                      const Spacer(),
                                    ],),
                                  ),
                                  const SizedBox(height: 10,),
                                  
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding: const EdgeInsets.all(18),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                                            ),
                                            title: Text(AppLocalizations.of(context).block_user),
                                            
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Fecha o AlertDialog
                                                  blockUser(context,item.user);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(AppLocalizations.of(context).yes),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context); // Fecha o AlertDialog
                                                  // Lógica a ser executada quando o segundo botão é pressionado
                                                },
                                                child: Text(AppLocalizations.of(context).no),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      
                                      
                                      
                                    },
                                    child: Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(AppLocalizations.of(context).block),),
                                      const Spacer(),
                                    ],),
                                  ),
                                    
                                  ],
                                ),
                            ),
                            );
                          },
                        );
                      },
                  
                  child: Container(
                    margin: const EdgeInsets.only(left:20.0, right: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4.0),
                      
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                     
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              Row(
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 135),
                                    child:Text(
                                    item.userName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black38,
                                      fontWeight: FontWeight.w500
                                      
                                    ),
                                  ),),
                                  const Spacer(),
                                  Text(
                                    returnDateFormat(item.dateCreated),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black38,
                                      
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                item.message,
                                
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Align(alignment: Alignment.bottomRight,
                              child: GestureDetector(
          onTap: () {
            showModalBottomSheet<void>(
        context: context,
        isDismissible: true,
        isScrollControlled: true, // Permitir rolagem se o conteúdo exceder
        backgroundColor: Colors.transparent, // Fundo transparente
        builder: (context) => GestureDetector( // Encapsule com outro GestureDetector
          onTap: () => Navigator.pop(context), // Fecha o modal ao clicar
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 225, // Ajuste a altura conforme necessário
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5.0), // Cantos arredondados
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).reply,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _replyController,
                        keyboardType: TextInputType.text,
                        maxLength: 140,
                        obscureText: false,
                        hint: AppLocalizations.of(context).enter_reply,
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.send_outlined,
                            size: 24,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            sendReplyComment(item.id);
                            
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
            );
          },
          child: Row(
            children: [
          const Spacer(),
          const Icon(Icons.reply_outlined, size: 15),
          const SizedBox(width: 4),
          Text(
            convertNumbers(item.replyCount),
            style: TextStyle(
              color: Colors.grey.shade700,
              fontFamily: 'Noto',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
              ],
            ),
          ),
                              ),
                              
                            ],
                          ),
                  ),
                ),
                
                item.replyCount > 0 && item.showTextReplies ? 
                GestureDetector(
                  onTap: () {
                    setState(() {
                      
                      item.showReplies = true;
                      item.showTextReplies = false;
                    });
                    
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(AppLocalizations.of(context).view_replies,
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontFamily: 'Noto',
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                ) : const SizedBox(),
                  const SizedBox(height: 10,),
                  item.showReplies ?
                  ReplyListWidget(
                    itemId: item.id,
                  ) : const SizedBox(),
              ]),
            );
          }
         )),
         ])
       );
      }
      
    @override
    bool get wantKeepAlive => true;
    
    Future deleteComment(BuildContext context, String id) async {
    
    var url = Uri.parse('${Api.comment}$id/');
   
    
    var response = await http.delete(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
    );

    if(response.statusCode == 204) { 
      _loadItems();
       CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).deleted, 
        Colors.redAccent);
       Navigator.pop(context);
    }
  }


  }




  class ReplyListWidget extends StatefulWidget {
  final String itemId;
  

  const ReplyListWidget({
    required this.itemId,
    super.key, 
  });

  @override
  _ReplyListWidgetState createState() => _ReplyListWidgetState();
}

class _ReplyListWidgetState extends State<ReplyListWidget> {
    late RepliesManager _repliesManager;
  @override
  void initState() {
    super.initState();
    
    _repliesManager = RepliesManager('${Api.replyComments}${widget.itemId}');
    
    _loadItems();
    
   
  }


  Future<void> _loadItems() async {
    _repliesManager.clear();
    setState(() {});
    await _repliesManager.fetchItems(url:'${Api.replyComments}${widget.itemId}');
    setState(() {});
  }

  Future<void> _loadMoreItems() async {
    final nextPage = _repliesManager.getNextPage();
    if (nextPage != null) {
      
      await _repliesManager.fetchItems(url: nextPage);
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children:[ Column(
          children: List.generate(
            _repliesManager.items.length,
            (index) {
              final item = _repliesManager.items[index];
              return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    children: [ GestureDetector(
                      onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context).actions),
                              contentPadding: const EdgeInsets.all(18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                              ),
                              content: SizedBox(
                                height: 135,
                                child: Column(
                                  children: <Widget>[
                                  item.isMe ? GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding: const EdgeInsets.all(18),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                                            ),
                                            title: Text(AppLocalizations.of(context).delete),
                                            content: Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context).delete),),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Fecha o AlertDialog
                                                  deleteComment(context,item.id);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(AppLocalizations.of(context).yes),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context); // Fecha o AlertDialog
                                                  // Lógica a ser executada quando o segundo botão é pressionado
                                                },
                                                child: Text(AppLocalizations.of(context).no),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      
                                      
                                      
                                    },
                                    child: Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(AppLocalizations.of(context).delete),),
                                      const Spacer(),
                                    ],),
                                  ) : SizedBox(),
                                  const SizedBox(height: 10,),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding: const EdgeInsets.all(18),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                                            ),
                                            title: Text(AppLocalizations.of(context).report_this_comment),
                                            content: Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context).want_report),),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Fecha o AlertDialog
                                                  sendReportComment(context,item.id);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(AppLocalizations.of(context).yes),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context); // Fecha o AlertDialog
                                                  // Lógica a ser executada quando o segundo botão é pressionado
                                                },
                                                child: Text(AppLocalizations.of(context).no),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      
                                      
                                      
                                    },
                                    child: Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(AppLocalizations.of(context).report),),
                                      const Spacer(),
                                    ],),
                                  ),
                                  const SizedBox(height: 10,),
                                  
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            contentPadding: const EdgeInsets.all(18),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                                            ),
                                            title: Text(AppLocalizations.of(context).block_user),
                                            
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Fecha o AlertDialog
                                                  blockUser(context,item.user);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(AppLocalizations.of(context).yes),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context); // Fecha o AlertDialog
                                                  // Lógica a ser executada quando o segundo botão é pressionado
                                                },
                                                child: Text(AppLocalizations.of(context).no),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      
                                      
                                      
                                    },
                                    child: Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(AppLocalizations.of(context).block),),
                                      const Spacer(),
                                    ],),
                                  ),
                                    
                                  ],
                                ),
                            ),
                            );
                          },
                        );
                      },
                  
                  child: Container(
                    margin: const EdgeInsets.only(left:40.0, right: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4.0),
                      
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                     
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              Row(
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 135),
                                    child:Text(
                                    item.userName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black38,
                                      fontWeight: FontWeight.w500
                                      
                                    ),
                                  ),),
                                  const Spacer(),
                                  Text(
                                    returnDateFormat(item.dateCreated),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black38,
                                      
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                item.message,
                                
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              
                              
                            ],
                          ),
                  ),
                ),
                
                
                
              ]),
              
            );
          }
          
         )),
          _repliesManager.getNextPage() != null ?
              GestureDetector(
                onTap: () {
                  _loadMoreItems();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(AppLocalizations.of(context).view_more,
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontFamily: 'Noto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
              ) : const SizedBox(),
         ],
        )
       );
      }
      
   Future deleteComment(BuildContext context, String id) async {
    
    var url = Uri.parse('${Api.reply}$id/');
   
    
    var response = await http.delete(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
    );

    if(response.statusCode == 204) { 
      _loadItems();
       CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).deleted, 
        Colors.redAccent);
       Navigator.pop(context);
    }
  }
      
    
  }
  

Future sendReportComment(BuildContext context, String id) async {
    var url = Uri.parse(Api.report);
    String comment = id;
   
    final body = {
        'type_report': 'c',
        'comment': comment,
    }; 
    var response = await http.post(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
      body: jsonEncode(body)
    );

    

    if(response.statusCode == 201) {  
      CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).reported, 
        Colors.redAccent);
    }
  }

Future blockUser(BuildContext context, String user) async {
    var url = Uri.parse(Api.block);



    final body = {
        'blocked': user,
    }; 
    var response = await http.post(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
      body: jsonEncode(body)
    );

    if(response.statusCode == 201) {  
      CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).blocked, 
        Colors.redAccent);
    }
  }
