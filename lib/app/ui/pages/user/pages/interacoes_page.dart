import 'package:booksclub/app/api.dart';
import 'package:booksclub/app/models/interactions.dart';
import 'package:booksclub/app/repositories/interactions.dart';
import 'package:booksclub/app/token/get_token.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;


class InteractionsPage extends StatefulWidget {
  final int typeInteraction;
  const InteractionsPage({required this.typeInteraction, super.key,});
  @override
  State<InteractionsPage> createState() => _InteractionsPageState();
}

class _InteractionsPageState extends State<InteractionsPage> {
  
  late InteractionsManager interactionsManager;
  final ScrollController _scrollController = ScrollController();
 
  @override
  void initState() {
    
   switch(widget.typeInteraction){
      case 1:
         interactionsManager = InteractionsManager(Api.mFollow);
      break;

      case 2:
         interactionsManager = InteractionsManager(Api.mRead);
       
      break;

      case 3:
         interactionsManager = InteractionsManager(Api.mLike);
       
      break;

      case 4:
         interactionsManager = InteractionsManager(Api.mSave);
      break;

    }
    
    super.initState();
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      toolbarHeight: 72,
      automaticallyImplyLeading: true,
      backgroundColor: Colors.black,
      
     actions: [
     const Spacer(),
     Container(
        padding:const EdgeInsets.only(left: 18, right: 18),
        child:Text(
                widget.typeInteraction == 1 ? AppLocalizations.of(context).following :
                widget.typeInteraction == 2 ? AppLocalizations.of(context).read :
                widget.typeInteraction == 3 ? AppLocalizations.of(context).saved :
                widget.typeInteraction == 4 ? AppLocalizations.of(context).liked : '',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                ),
          ),
          ),
          
     ],
    
    ),
    
      body: Center(
                  child:InteractionsListWidget(
                    interactionsManager: interactionsManager,
                    typeInteraction: widget.typeInteraction,
                    scrollController: _scrollController,
    
                  )
                ),
    );
    
  }
}


class InteractionsListWidget extends StatefulWidget {
  final InteractionsManager interactionsManager;
  final ScrollController scrollController;
  final int typeInteraction;
  const InteractionsListWidget({
    required this.interactionsManager,
    required this.scrollController,
    required  this.typeInteraction,
    super.key, 
  });

  @override
  _InteractionsListWidgetState createState() => _InteractionsListWidgetState();
}

class _InteractionsListWidgetState extends State<InteractionsListWidget>
  with AutomaticKeepAliveClientMixin   {
  
  

  @override
  void initState() {
    super.initState();
    _loadItems();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.atEdge &&
          widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent &&
          !widget.interactionsManager.isLoading
        ) { 
          _loadMoreItems();
        }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _loadItems() async {
    widget.interactionsManager.clear();

      switch(widget.typeInteraction){
      case 1:
        await widget.interactionsManager.fetchItems(url:Api.mFollow);
        setState(() {});
      break;

      case 2:
        await widget.interactionsManager.fetchItems(url:Api.mRead);
        setState(() {});
      break;

      case 3:
        await widget.interactionsManager.fetchItems(url:Api.mSave);
        setState(() {});
      break;

      case 4:
        await widget.interactionsManager.fetchItems(url:Api.mLike);
        setState(() {});
      break;
      
     

    }
    
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.interactionsManager.getNextPage();
    if (nextPage != null) {
      await widget.interactionsManager.fetchItems(url: nextPage);
      if(mounted){
        setState(() {});
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(widget.interactionsManager.items.isEmpty){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
        child: Text(
          AppLocalizations.of(context).place_empty,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
        ), 
        )
      );
    }
    return ListView.separated(
          scrollDirection: Axis.vertical,
          controller: widget.scrollController,
          itemCount: widget.interactionsManager.items.length,
          padding: const EdgeInsets.only(top: 10),
          itemBuilder: (context, index) {
            final item = widget.interactionsManager.items[index];
            return 
                    Container(
                      margin: const EdgeInsets.only(left:20.0, right: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4.0),  
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth:  175),
                          child: Text(
                                            widget.typeInteraction == 4 ? item.talkSubject! : item.bookTitle!,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black38,
                                              fontWeight: FontWeight.w500
                                              
                                            ),
                                          ),
                        ),
                              
                         const Spacer(),
                       IconButton(onPressed: (){
                         
                         showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context).remove),
                              contentPadding: const EdgeInsets.all(18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                              ),
                              content: SizedBox(
                                height: 75,
                                child: Column(
                                  children: <Widget>[
                                  
                                  Row(children: [
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        switch(widget.typeInteraction){
                                          case 1:
                                            removeFollow(item);
                                            setState(() {});
                                          break;

                                          case 2:
                                            removeRead(item);
                                            setState(() {});
                                            
                                          break;

                                          case 3:
                                            removeSave(item);
                                            setState(() {});
                                            
                                          break;

                                          case 4:
                                            removeLike(item);
                                            setState(() {});
                                          break;
                                        
                                        }
                                      },
                                       child: Padding(
                                        padding: const EdgeInsets.all(25),
                                        child: Text(AppLocalizations.of(context).yes, style: const TextStyle(fontSize: 16),),),
                                     ),
                                  
                                     GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                       child: Padding(
                                        padding: const EdgeInsets.all(25),
                                        child: Text(AppLocalizations.of(context).no, style: const TextStyle(fontSize: 16),),),
                                     ),
                                  ],),
                                  
                                    
                                    
                                  ],
                                ),
                            ),
                            );
                          },
                        );
                        
                     }, icon: Icon(Icons.cancel_outlined, size: 22, color: Colors.grey.shade500,),
                    ), 
                      ]
                                      
                    
                    )
             );
          },
         separatorBuilder: (context, index) {

           return const SizedBox(height: 10,);
         },
        );
  }
  
  @override
  bool get wantKeepAlive => true;





Future removeLike(Interactions item) async {
    String like = item.id;
    var url = Uri.parse('${Api.mLike}$like/');
   
    
    var response = await http.delete(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
    );

    if(response.statusCode == 204) { 
       Navigator.pop(context);
      
        _loadItems();
       CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).removed, 
        Colors.redAccent);
    }
  }



  Future removeSave(Interactions item) async {
    String like = item.id;
    var url = Uri.parse('${Api.mSave}$like/');
   
    
    var response = await http.delete(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
    );

    if(response.statusCode == 204) { 
       Navigator.pop(context);
      _loadItems();
       CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).removed, 
        Colors.redAccent);
    }
  }



  Future removeFollow(Interactions item) async {
    String like = item.id;
    var url = Uri.parse('${Api.mFollow}$like/');
   
    
    var response = await http.delete(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
    );

    if(response.statusCode == 204) { 
      Navigator.pop(context);
      _loadItems();
       CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).removed, 
        Colors.redAccent);
    }
  }



  Future removeRead(Interactions item) async {
    String like = item.id;
    var url = Uri.parse('${Api.mRead}$like/');
   
    
    var response = await http.delete(
      url, 
      headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
      },
    );

    if(response.statusCode == 204) { 
       Navigator.pop(context);
       _loadItems();
       CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).removed, 
        Colors.redAccent);
    }
  }
}