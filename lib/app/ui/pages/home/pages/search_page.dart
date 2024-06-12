
import 'package:booksclub/app/ads/ads_banner.dart';
import 'package:booksclub/app/ui/pages/search/pages/add_book.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import '../../../../api.dart';
import '../../../../repositories/search.dart';
import '../../book/pages/book_page.dart';

class SearchPage extends StatefulWidget {
 
  const SearchPage({super.key});
@override
State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchManager searchTitleManager = SearchManager('');
  SearchManager searchAuthorManager = SearchManager('');
  SearchManager searchCategoryManager = SearchManager('');
  final _searchStateTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    return DefaultTabController(length:3, child: Scaffold(
    appBar: AppBar(
      toolbarHeight: 72,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.black,
        flexibleSpace: Column(
          children: [
            const SizedBox(height: 35.0),
            Row(
              children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top:8.0, left: 18, right: 9),
                  
                  child: TextFormField(
                    controller: _searchStateTextController,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 96,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).search,
                      hintStyle: TextStyle(color: Colors.grey.shade700),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                       
                      
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom:14, right:18),
                child: IconButton(
                  onPressed: () {
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
                    return const AddBookPage();
                  },
                ),
              );
                    
                  }, 
                  icon: const Icon(Icons.add_outlined, color: Colors.white,)
                )
              ),
              ],
            )
          ],
        ),
        bottom:  TabBar(
    
          tabs: [
            Tab(text: AppLocalizations.of(context).title),
            Tab(text: AppLocalizations.of(context).author),
            Tab(text: AppLocalizations.of(context).category),
          ],
          
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        children: [
          SearchTitleListWidget(searchTitleManager, _searchStateTextController),
          SearchAuthorListWidget(searchAuthorManager, _searchStateTextController),
          SearchCategoryListWidget(searchCategoryManager, _searchStateTextController),
        ],
      ),
    ),
    );
      
  }
}



class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}


// SEARCH AUTHOR

class SearchAuthorListWidget extends StatefulWidget {
  final SearchManager searchManager;
  final TextEditingController searchController;
  const SearchAuthorListWidget(
    this.searchManager, 
    this.searchController, 
    {super.key}
  );

  @override
  _SearchAuthorWidgetState createState() => _SearchAuthorWidgetState();
}

class _SearchAuthorWidgetState extends State<SearchAuthorListWidget> {
  final ScrollController _scrollController = ScrollController();
  final bool _isLoading = false;
  int typeSearch = 1;


  String _lastSearchText = ''; // Adiciona uma variável para armazenar o último texto conhecido


  @override
  void initState() {
    super.initState();
    if (widget.searchController.text.isNotEmpty) {
      _loadItems(widget.searchController.text);
    }
    widget.searchController.addListener(() {
      if (widget.searchController.text != _lastSearchText) {
        _lastSearchText = widget.searchController.text;
        if (widget.searchController.text.isNotEmpty) {
          _loadItems(widget.searchController.text);
        }
      }
    });
 _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !widget.searchManager.isLoading
        ) { 
          _loadMoreItems();
        }
    });
    // Adiciona um listener para o TextEditingController
    widget.searchController.addListener(() {
      

      if (widget.searchController.text != _lastSearchText) {
          _lastSearchText = widget.searchController.text;
          if(widget.searchController.text.isNotEmpty) {
            _loadItems(widget.searchController.text);
          }
      }
    });
  }


  Future<void> _loadItems(String searchText) async {
    String apiUrl;
    apiUrl = '${Api.book}?author=$searchText';
    try {
      widget.searchManager.clear();
      await widget.searchManager.fetchItems(url:apiUrl);
      if(mounted){
        setState(() {});
      }

    } catch(error) {
    }
    
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.searchManager.getNextPage();
    if (nextPage != null) {
      await widget.searchManager.fetchItems(url: nextPage);
      setState(() {});
    }
  }

  @override
void dispose() {
  _scrollController.removeListener(() {}); // Adicione esta linha
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    if(widget.searchManager.items.isEmpty){
      return Center(
        child: Text(
          AppLocalizations.of(context).search_empty,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
        ), 
      );
    }
    return Scaffold(
      body: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemCount: widget.searchManager.items.length,
        itemBuilder: (context, index) {
          final item = widget.searchManager.items[index];
          if (widget.searchManager.items.isNotEmpty) {
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
                            const SizedBox(width: 2.0),
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
          }
          return null;
        },
        separatorBuilder: (context, index) {
          
          return const SizedBox();
        },
      ),
    );
  }
}


// SEARCH CATEGORY

class SearchCategoryListWidget extends StatefulWidget {
  final SearchManager searchManager;
  final TextEditingController searchController;
  const SearchCategoryListWidget(
    this.searchManager, 
    this.searchController, 
    {super.key}
  );

  @override
  _SearchCategoryWidgetState createState() => _SearchCategoryWidgetState();
}

class _SearchCategoryWidgetState extends State<SearchCategoryListWidget> {
  final ScrollController _scrollController = ScrollController();
  final bool _isLoading = false;
  int typeSearch = 1;


  String _lastSearchText = ''; // Adiciona uma variável para armazenar o último texto conhecido


  @override
  void initState() {
    super.initState();
    
    if (widget.searchController.text.isNotEmpty) {
      _loadItems(widget.searchController.text);
    }
    widget.searchController.addListener(() {
      if (widget.searchController.text != _lastSearchText) {
        _lastSearchText = widget.searchController.text;
        if (widget.searchController.text.isNotEmpty) {
          _loadItems(widget.searchController.text);
        }
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !widget.searchManager.isLoading
        ) { 
          _loadMoreItems();
        }
    });

    // Adiciona um listener para o TextEditingController
    widget.searchController.addListener(() {
      

      if (widget.searchController.text != _lastSearchText) {
          _lastSearchText = widget.searchController.text;
          if(widget.searchController.text.isNotEmpty) {
            _loadItems(widget.searchController.text);
          }
      }
    });
  }


  Future<void> _loadItems(String searchText) async {
    String apiUrl;
    apiUrl = '${Api.book}?category=$searchText';
   
    try {
      widget.searchManager.clear();
      await widget.searchManager.fetchItems(url:apiUrl);
      if(mounted){
        setState(() {});
      }

    } catch(error) {
      CustomSnackbar.show(context, 
      AppLocalizations.of(context).error_ocurred, 
      Colors.redAccent);
    }
    
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.searchManager.getNextPage();
    if (nextPage != null) {
      await widget.searchManager.fetchItems(url: nextPage);
      setState(() {});
    }
  }

  @override
void dispose() {
  _scrollController.removeListener(() {}); // Adicione esta linha
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    if(widget.searchManager.items.isEmpty){
      return Center(
        child: Text(
          AppLocalizations.of(context).search_empty,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
        ), 
      );
    }
    return Scaffold(
      body: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemCount: widget.searchManager.items.length,
        itemBuilder: (context, index) {
          final item = widget.searchManager.items[index];
          if (widget.searchManager.items.isNotEmpty) {
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
          }
          return null;
        },
        separatorBuilder: (context, index) {
          if(index % 5 == 0) {
              return getBanner(context);
          }
          return const SizedBox();
        },
      ),
    );
  }
}




// SEARCH 
class SearchTitleListWidget extends StatefulWidget {
  final SearchManager searchManager;
  final TextEditingController searchController;
  const SearchTitleListWidget(
    this.searchManager, 
    this.searchController, 
    {super.key}
  );

  @override
  _SearchTitleWidgetState createState() => _SearchTitleWidgetState();
}

class _SearchTitleWidgetState extends State<SearchTitleListWidget> {
  final ScrollController _scrollController = ScrollController();
  final bool _isLoading = false;


  String _lastSearchText = ''; // Adiciona uma variável para armazenar o último texto conhecido


  @override
  void initState() {
    super.initState();
    
    if (widget.searchController.text.isNotEmpty) {
      _loadItems(widget.searchController.text);
    }
    widget.searchController.addListener(() {
      if (widget.searchController.text != _lastSearchText) {
        _lastSearchText = widget.searchController.text;
        if (widget.searchController.text.isNotEmpty) {
          _loadItems(widget.searchController.text);
        }
      }
    });
 _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !widget.searchManager.isLoading
        ) { 
          _loadMoreItems();
        }
    });
    // Adiciona um listener para o TextEditingController
    widget.searchController.addListener(() {
      

      if (widget.searchController.text != _lastSearchText) {
          _lastSearchText = widget.searchController.text;
          if(widget.searchController.text.isNotEmpty) {
            _loadItems(widget.searchController.text);
          }
      }
    });
  }


  Future<void> _loadItems(String searchText) async {
    String apiUrl;
    apiUrl = '${Api.book}?title=$searchText';
    try {
      widget.searchManager.clear();
      await widget.searchManager.fetchItems(url:apiUrl);
      if(mounted){
        setState(() {});
      }

    } catch(error) {
      CustomSnackbar.show(context, 
      AppLocalizations.of(context).error_ocurred, 
      Colors.redAccent);
    }
    
  }

  Future<void> _loadMoreItems() async {
    final nextPage = widget.searchManager.getNextPage();
    if (nextPage != null) {
      await widget.searchManager.fetchItems(url: nextPage);
      setState(() {});
    }
  }

  @override
void dispose() {
  _scrollController.removeListener(() {}); // Adicione esta linha
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    if(widget.searchManager.items.isEmpty){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: Text(
            AppLocalizations.of(context).search_empty,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
          ), 
        ),
      );
    }
    return Scaffold(
      body: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemCount: widget.searchManager.items.length,
        itemBuilder: (context, index) {
          final item = widget.searchManager.items[index];
          if (widget.searchManager.items.isNotEmpty) {
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
          }
          return null;
        },
        separatorBuilder: (context, index) {
          if(index % 5 == 0) {
              return getBanner(context);
          }
          return const SizedBox();
        },
      ),
    );
  }
}



