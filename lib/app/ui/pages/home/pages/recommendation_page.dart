import 'package:booksclub/app/ads/ads_banner.dart';
import 'package:booksclub/app/api.dart';
import 'package:booksclub/app/repositories/recommendations.dart';
import 'package:booksclub/app/ui/pages/book/pages/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});
  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  
  late RecommendationsManager _recommendationsManager;
  late String _urlBooksRecommendation;
  final ScrollController _scrollControllerFeed = ScrollController();
 
  @override
  void initState() {
    
    _urlBooksRecommendation = Api.recommendations;
    _recommendationsManager = RecommendationsManager(_urlBooksRecommendation);
    
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
    
    ),
    
      body: Center(
                  child: RecommendationsBookListWidget(
                    recommedationsManager: _recommendationsManager,
                    urlTalks: _urlBooksRecommendation,
                    scrollControllerFeed: _scrollControllerFeed,
    
                  )
                ),
    );
    
  }
}


class RecommendationsBookListWidget extends StatefulWidget {
  final RecommendationsManager recommedationsManager;
  final String urlTalks;
  final ScrollController scrollControllerFeed;
  const RecommendationsBookListWidget({
    required this.recommedationsManager,
    required this.urlTalks,
    required this.scrollControllerFeed,
    super.key,
  });

  @override
  _RecommendationsBookListWidgetState createState() => _RecommendationsBookListWidgetState();
}

class _RecommendationsBookListWidgetState extends State<RecommendationsBookListWidget>
  with AutomaticKeepAliveClientMixin   {
  
  

  @override
  void initState() {
    super.initState();
    _loadItems();
    widget.scrollControllerFeed.addListener(() {
      if (widget.scrollControllerFeed.position.atEdge &&
          widget.scrollControllerFeed.position.pixels ==
          widget.scrollControllerFeed.position.maxScrollExtent &&
          !widget.recommedationsManager.isLoading
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
    widget.recommedationsManager.items.clear();
    if(mounted){
      setState(() {});
    }
    await widget.recommedationsManager.fetchItems(url: widget.urlTalks);
    if(mounted){
      setState(() {});
    }
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.recommedationsManager.getNextPage();
    if (nextPage != null) {
      await widget.recommedationsManager.fetchItems(url: nextPage);
      if(mounted){
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(widget.recommedationsManager.items.isEmpty){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
        child: Text(
          AppLocalizations.of(context).recommendations_empty,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
        ), 
        )
      );
    }
    return ListView.separated(
      scrollDirection: Axis.vertical,
      controller: widget.scrollControllerFeed,
      itemCount: widget.recommedationsManager.items.length,
      itemBuilder: (context, index) {
        final item = widget.recommedationsManager.items[index];
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
              child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.035),
                borderRadius: BorderRadius.circular(5.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        item.title,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          
                          Expanded(
                            child: Text(
                              '${item.author} • ${item.publication}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.synopsis,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                   Row(
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
                            const Icon(Icons.forum_outlined, size: 16,),
                            const SizedBox(width: 4.0),
                            Text(
                              item.talkCount.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                
                              ),
                            ),
                            const Spacer(),
                            Visibility(
                              visible: item.category != null,
                              child: Container(
                              padding: const EdgeInsets.all(4),
                              color: const Color.fromRGBO(0, 0, 0, 0.05),
                              child: Text(
                              item.category ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                
                              ),
                            ),
                            )
                            )
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