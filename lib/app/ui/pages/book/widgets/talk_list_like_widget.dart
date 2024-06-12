
import 'package:booksclub/app/ads/ads_banner.dart';
import 'package:booksclub/app/repositories/talks.dart';
import 'package:booksclub/app/ui/pages/talk/pages/talk_page.dart';
import 'package:booksclub/app/util/number_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class TalkLikeListWidget extends StatefulWidget {
  final TalksManager talksManager;
  final String itemId;
  final String urlTalks;
  final ScrollController scrollController;
  const TalkLikeListWidget({
    required this.talksManager,
    required this.urlTalks,
    required this.itemId,
    required this.scrollController,
    super.key,
  });
  
  @override
  _TalkLikeListWidgetState createState() => _TalkLikeListWidgetState();
}

class _TalkLikeListWidgetState extends State<TalkLikeListWidget> with AutomaticKeepAliveClientMixin {
  int _currentPage = 0;
  int _totalItemsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.atEdge &&
          widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent &&
          !widget.talksManager.isLoading) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _loadItems() async {
    widget.talksManager.items.clear();
    if(mounted){
      setState(() {});
    }
    await widget.talksManager.fetchItems(url: widget.urlTalks);
    _totalItemsCount = widget.talksManager.items.length;
    if(mounted){
      setState(() {});
    }
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.talksManager.getNextPage();
    if (nextPage != null) {
      _currentPage++;
      await widget.talksManager.fetchItems(url: nextPage);
      _totalItemsCount = widget.talksManager.items.length;
      if(mounted){
       setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(widget.talksManager.items.isEmpty){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
        child: Text(
          AppLocalizations.of(context).talks_empty,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
        ), 
        )
      );
    }
    return ListView.separated(
      controller: widget.scrollController,
      itemCount: widget.talksManager.items.length,
      itemBuilder: (context, index) {
          final item = widget.talksManager.items[index]; 
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
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.0),
                    
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
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
                            const Icon(Icons.favorite_outline, size: 18),
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
                                const Icon(Icons.play_arrow_outlined, size: 18, color: Colors.black45,)
                                : const Icon(Icons.text_snippet_outlined, size: 18, color: Colors.black45,)
                            )
                          ],
                        ),
                      ],
                    ), 
                  ),
                ),
              );
        }, 
        separatorBuilder: (context, index){
          if(index % 5 == 0){
          return getBanner(context);
          }
          return const SizedBox();
        }
  );
}    
   @override
  bool get wantKeepAlive => true;
}
