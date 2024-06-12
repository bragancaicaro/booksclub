import 'dart:convert';
import 'dart:io';
import 'package:booksclub/app/ads/ads_banner.dart';
import 'package:booksclub/app/ui/pages/user/pages/interacoes_page.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:booksclub/app/api.dart';
import '../../../../models/user.dart';
import '../../../../token/get_token.dart';
import '../../../widgets/slider_book_image.dart';
import '../../user/pages/account_page.dart';
import '../../book/pages/book_page.dart';
import '../../talk/pages/talk_page.dart';
import '../../../../repositories/talks.dart';
import '../../../../repositories/books.dart';
import '../../../../repositories/images.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

@override
State<ProfilePage> createState() => _ProfilePageState();
}

  

class _ProfilePageState extends State<ProfilePage>{
  //UserData dataUser = UserData();
  late User? dataUser;
  late BooksManager _booksManager;
  late TalksManager _talksManager;
  late ImagesManager _imagesManager;
  @override
  void initState() {
    banner.load();
    super.initState();
    _booksManager = BooksManager(Api.mBooks);
    _talksManager = TalksManager(Api.mTalks);
    _imagesManager = ImagesManager(Api.mImages);
  }
  






  final BannerAd banner = BannerAd(
    size: AdSize.banner, 
    adUnitId: Platform.isAndroid
          ? 'ca-app-pub-5630239568507479/8921031221'
          : 'ca-app-pub-5630239568507479/4255063562', 
    request: const AdRequest(),
    listener: const BannerAdListener(), 
    );
  @override
  Widget build(BuildContext context){
    return FutureBuilder(
      future: fetchUserData(),
      builder: (context, snapshot) {
      if(snapshot.hasData){
        dataUser = snapshot.data;
      return Scaffold(
        
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 60,
        automaticallyImplyLeading: true, // Exibe automaticamente o botão de voltar padrão
        actions: [
          Padding(padding: const EdgeInsets.only(left: 4),
            child: IconButton(
                      icon: const Icon(
                        Icons.manage_accounts_outlined,
                        size: 24,
                        color: Colors.white70,
                    ), 
                    onPressed: () { 
                         Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 250),
                  transitionsBuilder: (context, animation1, animation2, child) {
                    return FadeTransition(
                      opacity: animation1,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation1, animation2) {
                    return const AccountPage();
                  },
                ),
              );
                        
                        
                
                     },

                  ),),
          Padding(padding: const EdgeInsets.only(left: 4),
          
          child:Container(
                  constraints: const BoxConstraints(
                    maxWidth: 125,
                  ),
                  child:Text(
                      '${dataUser?.name}',
                      overflow: TextOverflow.ellipsis,
                     maxLines: 1,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        
                      ),
                    ),),),


          
          
                  const Spacer(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context).app_name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 32,
                ),
          ),
          )
          
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          
          children: [
          
            
           Padding(
            
            padding: const EdgeInsets.all(15.0), 
            child:  Row(
              
             
              children: [
                 Text(AppLocalizations.of(context).interactions,
            
            style: const TextStyle(
                          
                          fontSize: 18,
                          color: Colors.black45,
                          fontWeight: FontWeight.w400

                        ),
          ),
            ],
            ),
          ),
          
          GestureDetector(
            onTap: (){
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
                    return const InteractionsPage(typeInteraction: 1,);
                  },
                ),
              );
              
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:20.0, vertical: 8.0), 
              child: Row(
                
                children: [
                  Text(
                    AppLocalizations.of(context).following,
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                  const Spacer(),
                  Text('${dataUser?.following.toString()}',style: const TextStyle(fontWeight: FontWeight.w300),),
              ],
              ),
            ),
          ),
           GestureDetector(
            onTap: (){
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
                    return const InteractionsPage(typeInteraction: 2,);
                  },
                ),
              );
              
            },
             child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:20.0, vertical: 8.0), 
              child: Row(
                
                children: [
                  Text(AppLocalizations.of(context).read,style: const TextStyle(fontWeight: FontWeight.w300),),
                  const Spacer(),
                  Text('${dataUser?.read.toString()}',style: const TextStyle(fontWeight: FontWeight.w300),),
              ],
              ),
                       ),
           ),
          GestureDetector(
            onTap: (){
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
                    return const InteractionsPage(typeInteraction: 3,);
                  },
                ),
              );
            },
            child:  Padding(
            padding: const EdgeInsets.symmetric(horizontal:20.0, vertical: 8.0), 
            child: Row(
             
              children: [
                Text(AppLocalizations.of(context).saved,style: const TextStyle(fontWeight: FontWeight.w300),),
                const Spacer(),
                Text('${dataUser?.saved.toString()}',style: const TextStyle(fontWeight: FontWeight.w300),),
            ],
            ),
          ),),
           GestureDetector(
            onTap: (){
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
                    return const InteractionsPage(typeInteraction: 4,);
                  },
                ),
              );
            },
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:20.0, vertical: 8.0), 
            child: Row(
            
              children: [
                Text(AppLocalizations.of(context).liked,style: const TextStyle(fontWeight: FontWeight.w300),),
                const Spacer(),
                Text('${dataUser?.liked.toString()}',style: const TextStyle(fontWeight: FontWeight.w300),),
            ],
            ),
          ),),
          const SizedBox(height: 16,),
          Padding(
            
            padding: const EdgeInsets.all(15.0),
            child: Row(
              
              children: [
                Text(
            AppLocalizations.of(context).created,
            style: const TextStyle(
                          
                          fontSize: 18,
                          color: Colors.black45,
                          fontWeight: FontWeight.w400
                        ),
          ),
            ],
            ),
          ),
          
           Padding(
            padding: const EdgeInsets.symmetric(horizontal:20.0, vertical: 8.0), 
            child: Row(
              
              children: [
                Text(
                  AppLocalizations.of(context).books,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Spacer(),
                Text('${dataUser?.numberBooks.toString()}',style: const TextStyle(fontWeight: FontWeight.w300),),
            ],
            ),
          ),
          
          Visibility(
            visible: dataUser!.numberBooks >= 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                child: SizedBox(
                  width: double.infinity,
                  height: 105, 
                  child: BookListWidget(
                    booksManager: _booksManager,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:20.0, vertical: 8.0), 
            child: Row(
              
              children: [
                Text(
                  AppLocalizations.of(context).talks,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300, 
                    
                  ),
                ),
                const Spacer(),
                Text('${dataUser?.numberTalks.toString()}',style: const TextStyle(fontWeight: FontWeight.w300),),
            ],
            ),
          ),
         
           
         
          Visibility(
            visible: dataUser!.numberTalks >= 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                width: double.infinity,
                height: 90, 
                child: TalkListWidget(
                  talksManager: _talksManager,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:20.0, vertical: 8.0), 
            child: Row(
              
              children: [
                Text(
                  AppLocalizations.of(context).images,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300, 
                    
                  ),
                ),
                const Spacer(),
                Text(
                  '${dataUser?.numberImages.toString()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w300
                  ),
                ),
            ],
            ),
          ),
          
          
          Visibility(
            visible: dataUser!.numberImages >= 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                width: double.infinity,
                height: 125, 
                child: ImageListWidget(
                  imagesManager: _imagesManager,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          getBanner(context),
                      
              
        ],
      ),
      )
    );
      } else if (snapshot.hasError) {
        return Text('Erro ao carregar dados: ${snapshot.error}');
      } else {
        return const CircularProgressIndicator();
      }  
    
      
      }
    
    );  
      

    
}





}




  Future<User> fetchUserData() async {
    try {
      var url = Uri.parse(Api.userData);
      final response = await http.get(
        url,
        headers: {
          'Authorization': (await getToken()) ?? '',
          'Content-Type': 'application/json; charset=utf-8',
        },
    );

    if (response.statusCode == 200) {

      final data = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      return User.fromJson(data);
    } else {
      // Se a resposta não for bem-sucedida, você pode lançar uma exceção ou retornar null, dependendo do que faz sentido para o seu caso.
      throw Exception('Erro na solicitação HTTP: ${response.body}');
    }
    } catch (error) {
      // Captura e trata qualquer exceção que possa ocorrer durante o processo
      rethrow; // Re-lança a exceção para que a função chamadora também possa lidar com ela
    }
  }


// BOOKS LIST

class BookListWidget extends StatefulWidget {
  final BooksManager booksManager;

  const BookListWidget({
    required this.booksManager,
    super.key,
  });

  @override
  _BookListWidgetState createState() => _BookListWidgetState();
}

class _BookListWidgetState extends State<BookListWidget> {
  final ScrollController _scrollController = ScrollController();
  

  @override
  void initState() {
    super.initState();
    _loadItems();
    
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !widget.booksManager.isLoading) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _loadItems() async {
    widget.booksManager.clear();
    setState(() {});
    await widget.booksManager.fetchItems(url:Api.mBooks);
    setState(() {});
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.booksManager.getNextPage();
    if (nextPage != null) {
      
      await widget.booksManager.fetchItems(url: nextPage);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(left: 16),
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: widget.booksManager.items.length,
      itemBuilder: (context, index) {
        final item = widget.booksManager.items[index];
        if (widget.booksManager.items.isNotEmpty) {
          return GestureDetector(
            onTap: () {
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
                    return BookPage(itemId: item.id);
                  },
                ),
              );
             

              
            },
            onLongPress: () {
              showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                          ),
                          title: Text(AppLocalizations.of(context).delete_this_book),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Fecha o AlertDialog
                                deleteBook(item.id);
                              },
                              child: const Text('yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Fecha o AlertDialog
                                // Lógica a ser executada quando o segundo botão é pressionado
                              },
                              child: const Text('no'),
                            ),
                          ],
                        );
                      },
                    );
            },
            child: Container(
              width: 175,
              
              constraints: const BoxConstraints(maxWidth: 175),
              
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.035),
                borderRadius: BorderRadius.circular(5.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity, // Garante que o contêiner ocupe toda a largura disponível
                      child: Text(
                        item.title,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2,),
                    SizedBox(
                      width: double.infinity, // Garante que o contêiner ocupe toda a largura disponível
                      child: Text(
                        '${item.author} • ${item.publication}',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2,),
                    SizedBox(
                      width: double.infinity, // Garante que o contêiner ocupe toda a largura disponível
                      child: Text(
                        item.synopsis,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                      const SizedBox(height: 2,),
                    Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.star_outlined, size: 16, color: Colors.grey.shade600,),
                                const SizedBox(width: 2.0),
                                Text(
                                  item.rating.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    
                                  ),
                                ),
                            const SizedBox(width: 8.0,),
                                
                                const Icon(
                                  Icons.forum_outlined,
                                  size: 16,
                                ),
                                const SizedBox(width: 2,),
                                Text(
                                  item.talkCount.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            )
                          ),
                          
                  ],
                ),
              ),
            ),
          );
        }
        return null;
        
      },
      separatorBuilder: (context, index) {
        return const SizedBox(width: 8.0);
      },
    );
  }



  Future<void> deleteBook(String id) async {
   
    var url = Uri.parse('${Api.book}$id/');
   
    
    var response = await http.delete(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
    );
    _loadItems();
    CustomSnackbar.show(
      context, 
      AppLocalizations.of(context).deleted, 
      Colors.redAccent);

  }
}

//TALKS LIST ----

class TalkListWidget extends StatefulWidget {
  final TalksManager talksManager;

  const TalkListWidget({
    required this.talksManager,
    super.key,
  });

  @override
  _TalkListWidgetState createState() => _TalkListWidgetState();
}

class _TalkListWidgetState extends State<TalkListWidget> {
  final ScrollController _scrollController = ScrollController();
  

  @override
  void initState() {
    super.initState();
    _loadItems();
    setState(() {});
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !widget.talksManager.isLoading) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _loadItems() async {
    widget.talksManager.clear();
    setState(() {});
    await widget.talksManager.fetchItems(url:Api.mTalks);
    setState(() {});
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.talksManager.getNextPage();
    if (nextPage != null) {
      
      await widget.talksManager.fetchItems(url: nextPage);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
      padding: const EdgeInsets.only(left: 16),
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: widget.talksManager.items.length,
      itemBuilder: (context, index) {
        final item = widget.talksManager.items[index];
        if (widget.talksManager.items.isNotEmpty) {
          return GestureDetector(
            onTap: () {

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
                    return  TalkPage(itemId: item.id);
                  },
                ),
              );
            },
            onLongPress: () {
              showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                          ),
                          title: Text(AppLocalizations.of(context).delete_this_talk),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Fecha o AlertDialog
                                deleteTalk(item.id);
                              },
                              child: const Text('yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Fecha o AlertDialog
                                // Lógica a ser executada quando o segundo botão é pressionado
                              },
                              child: const Text('no'),
                            ),
                          ],
                        );
                      },
                    );
            },
            child: Container(
             
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.035),
                borderRadius: BorderRadius.circular(4.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: 175,
                height: 175,
                constraints: const BoxConstraints(maxWidth: 175),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                       SizedBox(
                      width: double.infinity, // Garante que o contêiner ocupe toda a largura disponível
                      child: Text(
                          item.subject,
                        
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                         
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),),
                      const SizedBox(height: 4,),
                      SizedBox(
                      width: double.infinity, // Garante que o contêiner ocupe toda a largura disponível
                      child:Text(
                                item.bookTitle,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),),
                      
                      const SizedBox(height: 4,),
                      Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.favorite_outline, size: 16,),
                                  const SizedBox(width: 2.0),
                                  Text(
                                    item.likeCount.toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 8,),
                                  const Icon(Icons.comment_outlined, size: 16,),
                                  const SizedBox(width: 2.0),
                                  Text(
                                    item.commentCount.toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Container(
                              padding: const EdgeInsets.all(4),        
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(0, 0, 0, 0.05),
                                borderRadius: BorderRadius.circular(4.0),
                                
                              ),
                              
                              child: item.typeTalk == 'a' ?
                                const Icon(Icons.play_arrow_outlined, size: 16, color: Colors.black45,)
                                : const Icon(Icons.text_snippet_outlined, size: 16, color: Colors.black45,)
                            )
                                ],
                              )
                            ),
                    
                          widget.talksManager.isLoading ?
                         Center(child:  CircularProgressIndicator(color: Colors.grey.shade700),)
                          : const SizedBox(),
                    
                    
                     
                    ],
                  ),
                ),
              )
            ),
          );
        }
        return null;
        
      },
      separatorBuilder: (context, index) {
        return const SizedBox(width: 8.0);
      },
    )
    );
  }
  
  Future<void> deleteTalk(String id) async {
   
    var url = Uri.parse('${Api.talk}$id/');
   
    
    var response = await http.delete(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
    );
    _loadItems();
    CustomSnackbar.show(
      context, 
      AppLocalizations.of(context).deleted, 
      Colors.redAccent);

  }
  
}


//IMAGES LIST ----

class ImageListWidget extends StatefulWidget {
  final ImagesManager imagesManager;

  const ImageListWidget({
    required this.imagesManager,
    super.key,
  });

  @override
  _ImageListWidgetState createState() => _ImageListWidgetState();
}

class _ImageListWidgetState extends State<ImageListWidget> {
  final ScrollController _scrollController = ScrollController();
  

  @override
  void initState() {
    super.initState();
    _loadItems();
    setState(() {});
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !widget.imagesManager.isLoading) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _loadItems() async {
    
    await widget.imagesManager.fetchItems(url:Api.mImages);
    setState(() {});
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.imagesManager.getNextPage();
    if (nextPage != null) {
      
      await widget.imagesManager.fetchItems(url: nextPage);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
      padding: const EdgeInsets.only(left: 16),
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: widget.imagesManager.items.length,
      itemBuilder: (context, index) {
        var item = widget.imagesManager.items[index];
        if (widget.imagesManager.items.isNotEmpty) {
          return GestureDetector(
            onTap: () {
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
                    return SliderImageBook(imagesManager: widget.imagesManager, initialIndex:index);
                  },
                ),
              );
              
            },
            child: Container(
             
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.035),
                borderRadius: BorderRadius.circular(4.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: 125,
                height: 125,
                constraints: const BoxConstraints(maxWidth: 175),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        image: NetworkImage(item.imageUrl),
                      ),
                ),
              )
            ),
          );
        }
        return null;
        
      },
      separatorBuilder: (context, index) {
        return const SizedBox(width: 8.0);
      },
    )
    );
  }
}
