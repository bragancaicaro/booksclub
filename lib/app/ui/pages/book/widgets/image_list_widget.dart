
import 'dart:convert';

import 'package:booksclub/app/api.dart';
import 'package:booksclub/app/repositories/images.dart';
import 'package:booksclub/app/token/get_token.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:booksclub/app/ui/widgets/slider_book_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class ImageListWidget extends StatefulWidget {
  final ImagesManager imagesManager;
  final String itemId;
  const ImageListWidget({
    required this.imagesManager,
    required this.itemId,
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
    if (widget.imagesManager.items.isEmpty) {
      await widget.imagesManager.fetchItems(url: Api.imagesBook + widget.itemId);
      setState(() {});
    }
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
    return SingleChildScrollView(
      child: SizedBox(
        height: 145,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.imagesManager.items.length,
          itemBuilder: (context, index) {
            final item = widget.imagesManager.items[index];
            return GestureDetector(
              onLongPress: () {
                showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
                          ),
                          title: Text(AppLocalizations.of(context).report_this_image),
                          content: Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context).want_report),),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Fecha o AlertDialog
                                reportImage(widget.imagesManager.items[index].id);
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
                      }
                      );
                      
                  
                
                
                
              },
              onTap: () {
                
               Navigator.push(
                  context,
                  PageRouteBuilder(
                    barrierDismissible: true,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return SliderImageBook(imagesManager: widget.imagesManager, initialIndex:index);
                    },
                  ),
                );
              },
              child:  Container(
                  width: 100,
                  height: 120,
                  margin: const EdgeInsets.only(right: 10),
                  constraints: const BoxConstraints(maxWidth: 100, maxHeight: 120),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: [
                    Image.network(
                    width: 100,
                          height: 100,
                        item.imageUrl,
                        fit: BoxFit.cover
                        ,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 4),
                        constraints: const BoxConstraints(maxWidth: 90, maxHeight: 20),
                        child: Text(
                          item.userName, 
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14, 
                            color: Colors.white60
                          ),
                          )
                  
                      ),
                     ] )
                )
            );
          }
          
          ),
      )
      
        ); 
      }
      
        Future reportImage(String id) async {
          var url = Uri.parse(Api.report);
        
          final body = {
              'type_report': 'i',
              'image': id,
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
