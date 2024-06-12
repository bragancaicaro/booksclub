import 'package:booksclub/app/ads/ads_banner.dart';
import 'package:booksclub/app/repositories/feeds.dart';
import 'package:booksclub/app/repositories/recommendations_talk.dart';
import 'package:booksclub/app/ui/pages/talk/pages/talk_page.dart';
import 'package:booksclub/app/util/number_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:booksclub/app/api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  late FeedsManager _feedTalksManager;
  late String _urlTalksFeed;
  final ScrollController _scrollControllerFeed = ScrollController();
  
  late RecommendationsTalkManager _recommendationTalksManager;
  late String _urlTalksRecommendation;
  final ScrollController _scrollControllerRecommendation = ScrollController();
  @override
  void initState() {
    
    _urlTalksFeed = Api.returnTalks;
    _feedTalksManager = FeedsManager(_urlTalksFeed);
    
    _urlTalksRecommendation = Api.returnTalksRecommendation;
    _recommendationTalksManager = RecommendationsTalkManager(_urlTalksRecommendation);
    super.initState();
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
            Tab(text: AppLocalizations.of(context).following),
            Tab(text:  AppLocalizations.of(context).for_you),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          unselectedLabelColor: Colors.grey,
        ),
      ),
      
        body: TabBarView(
                children: [
                  // Conteúdo da primeira guia (Tab 1)
                  Center(
                    child: FeedTalkListWidget(
                      feedManager: _feedTalksManager,
                      urlTalks: _urlTalksFeed,
                      scrollControllerFeed: _scrollControllerFeed,

                    )
                  ),
                  // Conteúdo da segunda guia (Tab 2)
                  Center(child: RecommendationsTalkListWidget(
                      recommendationsManager: _recommendationTalksManager,
                      urlTalks: _urlTalksRecommendation,
                      scrollControllerRecommendations: _scrollControllerRecommendation,

                    )),
                   
                  // Conteúdo da terceira guia (Tab 3)
                 
                ],
          
        ),
      )
    );
    
  }
}


// ------------------------------->TALKS FEED  <------------------
class FeedTalkListWidget extends StatefulWidget {
  final FeedsManager feedManager;
  final String urlTalks;
  final ScrollController scrollControllerFeed;
  const FeedTalkListWidget({
    required this.feedManager,
    required this.urlTalks,
    required this.scrollControllerFeed,
    super.key,
  });

  @override
  _FeedTalkListWidgetState createState() => _FeedTalkListWidgetState();
}

class _FeedTalkListWidgetState extends State<FeedTalkListWidget>
  with AutomaticKeepAliveClientMixin   {
  
  

  @override
  void initState() {
    super.initState();
    _loadItems();
    widget.scrollControllerFeed.addListener(() {
      if (widget.scrollControllerFeed.position.atEdge &&
          widget.scrollControllerFeed.position.pixels ==
          widget.scrollControllerFeed.position.maxScrollExtent &&
          !widget.feedManager.isLoading
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
    widget.feedManager.items.clear();
    if(mounted){
      setState(() {});
    }
    await widget.feedManager.fetchItems(url: widget.urlTalks);
    if(mounted){
      setState(() {});
    }
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.feedManager.getNextPage();
    if (nextPage != null) {
      await widget.feedManager.fetchItems(url: nextPage);
      if(mounted){
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(widget.feedManager.items.isEmpty){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
        child: Text(
          AppLocalizations.of(context).follow_empty,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
        ), 
        )
      );
    }
    return ListView.separated(
      scrollDirection: Axis.vertical,
      controller: widget.scrollControllerFeed,
      itemCount: widget.feedManager.items.length,
      itemBuilder: (context, index) {
        final item = widget.feedManager.items[index];
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
                    return TalkPage(itemId: item.id);
                  },       
                ),
              );
             
            },
            child: Container(
              margin: const EdgeInsets.only(left:16.0, right: 16, bottom: 10),
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
                          item.subject,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            
                            const Icon(Icons.favorite_outline, size: 16),
                            const SizedBox(width: 2.0),
                            Text(
                              convertNumbers(item.likeCount),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 8.0),
                            const Icon(Icons.comment_outlined, size: 16),
                            const SizedBox(width: 2.0),
                            Text(
                             convertNumbers(item.commentCount),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                
                              ),
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
                            ),
                          
                            widget.feedManager.isLoading ?
                            Center(
                              child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            margin: const EdgeInsets.all(8.0),
                                            width: 54.0,
                                            height: 54.0,
                                            child: CircularProgressIndicator(color: Colors.grey.shade900),
                                          ),
                            ) : const SizedBox(),
                          
                          ],
                        ),
                     
                      
                      ],
                    ), 
              ),
            ),
          ); 
      },
     separatorBuilder: (context, index) {
       
       return const SizedBox();
     },
    );
  }
  
  @override
  bool get wantKeepAlive => true;


}



// -------------------------------> TALK RECOMMENDATION  <------------------
class RecommendationsTalkListWidget extends StatefulWidget {
  final RecommendationsTalkManager recommendationsManager;
  final String urlTalks;
  final ScrollController scrollControllerRecommendations;
  const RecommendationsTalkListWidget({
    super.key,
    required this.recommendationsManager,
    required this.urlTalks,
    required this.scrollControllerRecommendations,
  });

  @override
  _RecommendationsTalkListWidgetState createState() => _RecommendationsTalkListWidgetState();
}

class _RecommendationsTalkListWidgetState extends State<RecommendationsTalkListWidget>
  with AutomaticKeepAliveClientMixin {
  
  

  @override
  void initState() {
    super.initState();
    _loadItems();
    widget.scrollControllerRecommendations.addListener(() {
      if (widget.scrollControllerRecommendations.position.atEdge &&
          widget.scrollControllerRecommendations.position.pixels ==
          widget.scrollControllerRecommendations.position.maxScrollExtent &&
          !widget.recommendationsManager.isLoading
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
    widget.recommendationsManager.items.clear();
    if(mounted){
      setState(() {});
    }
    await widget.recommendationsManager.fetchItems(url: widget.urlTalks);
    if(mounted){
      setState(() {});
    }
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.recommendationsManager.getNextPage();
    if (nextPage != null) {
      await widget.recommendationsManager.fetchItems(url: nextPage);
      if(mounted){
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(widget.recommendationsManager.items.isEmpty){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
        child: Text(
          AppLocalizations.of(context).follow_empty,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
        ), 
        )
      );
    }
    return ListView.separated(
      scrollDirection: Axis.vertical,
      controller: widget.scrollControllerRecommendations,
      itemCount: widget.recommendationsManager.items.length,
      itemBuilder: (context, index) {
        final item = widget.recommendationsManager.items[index];
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
                    return TalkPage(itemId: item.id);
                  },
                ),
              );
             
            },
            child: Container(
              margin: const EdgeInsets.only(left:16.0, right: 16, bottom: 10),
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
                          item.subject,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            
                            const Icon(Icons.favorite_outline, size: 16),
                            const SizedBox(width: 2.0),
                            Text(
                              convertNumbers(item.likeCount),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 8.0),
                            const Icon(Icons.comment_outlined, size: 16),
                            const SizedBox(width: 2.0),
                            Text(
                             convertNumbers(item.commentCount),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                
                              ),
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
                            ),
                          
                            widget.recommendationsManager.isLoading ?
                            Center(
                              child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            margin: const EdgeInsets.all(8.0),
                                            width: 54.0,
                                            height: 54.0,
                                            child: CircularProgressIndicator(color: Colors.grey.shade900),
                                          ),
                            ) : const SizedBox(),
                          
                          ],
                        ),
                     
                      
                      ],
                    ), 
              ),
            ),
          ); 
      },
     separatorBuilder: (context, index) {
       
       return const SizedBox();
     },
    );
  }
  
  @override
  bool get wantKeepAlive => true;


}