import 'package:booksclub/app/util/number_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../api.dart';
import '../../../../repositories/updates.dart';
import '../../book/pages/book_page.dart';
import 'package:booksclub/app/ui/pages/talk/pages/talk_page.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  late final UpdatesManager _updatesBookManager;
  late final UpdatesManager _updatesTalkManager;
  
  @override
  void initState() {
    super.initState();
    
    

    _updatesBookManager = UpdatesManager(Api.updatesBook);
    _updatesBookManager.clear();
    _updatesBookManager.fetchItems(url:Api.updatesBook);
    _updatesTalkManager = UpdatesManager(Api.updatesTalk);
    _updatesTalkManager.clear();
    _updatesTalkManager.fetchItems(url:Api.updatesTalk);
    
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de guias (tabs)
      child: Scaffold(
        appBar: AppBar(
        toolbarHeight: 72,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.black,
        
       actions: [
       Container(
          padding:const EdgeInsets.only(left: 18, right: 18),
          child:Text(
                   AppLocalizations.of(context).app_name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 28,
                  ),
            ),
            ),
            const Spacer(),
       ],
        bottom: TabBar(
          tabs: [
            Tab(text: AppLocalizations.of(context).books),
            Tab(text:  AppLocalizations.of(context).talks),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          unselectedLabelColor: Colors.grey,
        ),
      ),
        
  
      
        body: TabBarView(
                children: [
                  
                  UpdatesBook(updatesManager: _updatesBookManager),
                  // Conteúdo da segunda guia (Tab 2)
                  UpdatesTalk(updatesManager: _updatesTalkManager)
                  // Conteúdo da terceira guia (Tab 3)
                 
                ],
          
        ),
      )
    );
    
  }
}



// UPDATES BOOK
class UpdatesBook extends StatefulWidget {
  final UpdatesManager updatesManager;
  const UpdatesBook({super.key, required this.updatesManager});

   

  @override
  _UpdatesBookState createState() => _UpdatesBookState();
}

class _UpdatesBookState extends State<UpdatesBook> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  

  @override
  void initState() {
    super.initState();
    
    _loadItems();
    
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !widget.updatesManager.isLoading) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _loadItems() async {
    widget.updatesManager.clear();
    await widget.updatesManager.fetchItems(url:Api.updatesBook);
    setState(() {});
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.updatesManager.getNextPage();
    if (nextPage != null) {
      widget.updatesManager.clear();
      setState(() {});
      await widget.updatesManager.fetchItems(url: nextPage);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(widget.updatesManager.items.isEmpty){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: Text(
            AppLocalizations.of(context).updates_books_empty,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
          ), 
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      itemCount: widget.updatesManager.items.length,
      itemBuilder: (context, index) {
        final item = widget.updatesManager.items[index];
        if(widget.updatesManager.items.isEmpty) {
          return Center(
          child: Text('nothing today', style: TextStyle(fontSize: 18, color: Colors.grey.shade500),),
        );
        }
        if (widget.updatesManager.items.isNotEmpty) {
          return InkWell(
            
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
                    return BookPage(itemId: item.book!);
                  },
                ),
              );
             
            },
            child: Container(
              margin: const EdgeInsets.only(left:16.0, right: 16, top: 16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.035),
                borderRadius: BorderRadius.circular(4.0),
                
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text(
                          item.bookTitle ?? '',
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 135),
                              child:Text(
                              convertNumbers(item.numberUpdates),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                                
                              ),
                            ),
                            ),
                            const SizedBox(width: 4,),
                            Text(
                              item.numberUpdates > 1 ?
                              AppLocalizations.of(context).new_talks 
                              :AppLocalizations.of(context).new_talk,
                              style: const TextStyle(fontSize: 14, color: Colors.black38),
                            ),
                            const Spacer(),
                            
                          ],
                        )
                        
                      ],
                    ), 
              ),
            ),
          );
        }
        return Center(
          child: Text('nothing today', style: TextStyle(fontSize: 18, color: Colors.grey.shade900),),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(width: 8.0);
      },
    );
  }
  @override
  bool get wantKeepAlive => true;
}



// UPDATES TALK
class UpdatesTalk extends StatefulWidget {
  final UpdatesManager updatesManager;
  const UpdatesTalk({super.key, required this.updatesManager});

   

  @override
  _UpdatesTalkState createState() => _UpdatesTalkState();
}

class _UpdatesTalkState extends State<UpdatesTalk> with AutomaticKeepAliveClientMixin{
  final ScrollController _scrollController = ScrollController();
  

  @override
  void initState() {
    super.initState();
    _loadItems();
    
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !widget.updatesManager.isLoading) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _loadItems() async {
    widget.updatesManager.clear();
    await widget.updatesManager.fetchItems(url:Api.updatesTalk);
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.updatesManager.getNextPage();
    if (nextPage != null) {
      
      await widget.updatesManager.fetchItems(url: nextPage);
      
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(widget.updatesManager.items.isEmpty){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: Text(
            AppLocalizations.of(context).updates_talks_empty,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
          ), 
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      itemCount: widget.updatesManager.items.length,
      itemBuilder: (context, index) {
        final item = widget.updatesManager.items[index];
        if (widget.updatesManager.items.isNotEmpty) {
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
                    return TalkPage(itemId: item.talk!);
                  },
                ),
              );
             
            },
            child: Container(
              margin: const EdgeInsets.only(left:16.0, right: 16, top: 16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.035),
                borderRadius: BorderRadius.circular(4.0),
                
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text(
                          item.talkSubject ?? '',
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 135),
                              child:Text(
                              convertNumbers(item.numberUpdates),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                                
                              ),
                            ),
                            ),
                            const SizedBox(width: 4,),
                            Text(
                              item.numberUpdates > 1 ?
                              AppLocalizations.of(context).new_comments 
                              :AppLocalizations.of(context).new_comment,
                              style: const TextStyle(fontSize: 14, color: Colors.black38),
                            ),
                            const Spacer(),
                            
                          ],
                        )
                        
                      ],
                    ), 
              ),
            ),
          );
        }
        return Center(
          child: Text('nothing today', style: TextStyle(fontSize: 18, color: Colors.grey.shade500),),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(width: 8.0);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}