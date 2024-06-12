import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:booksclub/app/repositories/talks_search.dart';
import 'package:booksclub/app/ui/pages/book/widgets/image_list_widget.dart';
import 'package:booksclub/app/ui/pages/book/widgets/recorder_widget.dart';
import 'package:booksclub/app/ui/pages/book/widgets/talk_list_comment_widget.dart';
import 'package:booksclub/app/ui/pages/book/widgets/talk_list_date_widget.dart';
import 'package:booksclub/app/ui/pages/book/widgets/talk_list_like_widget.dart';
import 'package:booksclub/app/ui/pages/book/widgets/talk_list_search_widget.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:booksclub/app/ui/widgets/custom_text_field.dart';
import 'package:booksclub/app/util/number_format.dart';
import 'package:booksclub/app/repositories/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../util/font_size.dart';
import '../../../../util/on_share.dart';
import '../../../../token/get_token.dart';
import '../../../../api.dart';
import '../../../../models/book.dart';
import '../../../../repositories/talks.dart';
import 'package:mime/mime.dart';


import 'package:record/record.dart';

class BookPage extends StatefulWidget {
  final String itemId;
  const BookPage({super.key, required this.itemId});
  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage>{
  final ScrollController _scrollController = ScrollController();
  // CONTROL ACTIONS BAR-------------------------
  bool _isSearchActive = false;
  bool _isAddActive = false;
  bool _isOrderingActive = false;
  bool _isImagesActive = false;
  bool _updatesBook = false;
  late TalksManager _talksDateManager;
  late TalksManager _talksLikeManager;
  late TalksManager _talksCommentManager;
  late TalksSearchManager _talksSearchManager;
  late String _urlTalksDate;
  late String _urlTalksLike;
  late String _urlTalksComment;
  final String _urlTalksSearch = '';
  late ImagesManager _imagesManager;
  Book? dataBook;
  late ValueNotifier<String> _urlTalksNotifier;
  
  // ADD TALK -------------------------
  final _formKey = GlobalKey<FormState>();
  final _searchTalkController = TextEditingController();
  final _subjectController = TextEditingController();

  bool addTalkTypeAudio = false;
  File? audioTalkFile;

  // CONTROL FOLLOW?READ?SAVE -------------------------
  bool _isFollowing = false;
  bool _isRead = false;
  bool _isSaved = false;
  bool _isRating = false;

  
  // SELECTEC BY -------------------------
  int _dropDownselectedValue = 0;
  bool isDate = true;
  bool isLike = false;
  bool isComment = false;
  bool isSearch = false;
  // RECORD AUDIO -------------------------
  bool isRecording = false;
  final record = AudioRecorder();

  String stringSearchTalks = '';
  @override
  void initState() {
	super.initState();
	
   

	_urlTalksNotifier = ValueNotifier(Api.returnTalkByBook + widget.itemId);
	
	_urlTalksDate = Api.returnTalkByBook+widget.itemId;
	_talksDateManager = TalksManager(_urlTalksDate);
	
	_urlTalksLike = Api.returnTalksLikeByBook+widget.itemId;
	_talksLikeManager = TalksManager(_urlTalksLike);
  
	_urlTalksComment = Api.returnTalksCommentByBook+widget.itemId;
	_talksCommentManager = TalksManager(_urlTalksComment);
		
    
    final searchTerm = _searchTalkController.text.toString();
    stringSearchTalks = '${Api.talk}?book=${widget.itemId}&subject=$searchTerm';

    _talksSearchManager = TalksSearchManager(stringSearchTalks);

	  _imagesManager = ImagesManager(Api.imagesBook+widget.itemId);
  }


  Future<void> _loadItems() async {
    _talksDateManager.clear();
    setState(() {});
    await _talksDateManager.fetchItems(url:_urlTalksDate);
    setState(() {});
  }
  
@override
  void dispose() {
	super.dispose();
	
  }
 
  @override
  Widget build(BuildContext context){
	  
	return FutureBuilder(
	  future: fetchBookData(),
	  builder: (context, snapshot) {
	  if(snapshot.hasData){
		dataBook = snapshot.data;
		if (dataBook?.following != null && dataBook?.following.isNotEmpty) {
		  _isFollowing = true;
		} else {
		  _isFollowing = false;
		}
		if (dataBook?.read != null && dataBook?.read.isNotEmpty) {
		  _isRead = true;
		} else {
		  _isRead = false;
		}
		if (dataBook?.saved != null && dataBook?.saved.isNotEmpty) {
		  _isSaved = true;
		} else {
		  _isSaved = false;
		}
		
		return Scaffold(
	  appBar: AppBar(
		backgroundColor: Colors.black,
		iconTheme: const IconThemeData(color: Colors.white),
		elevation: 0.0,
		actions: [
			Text(
				AppLocalizations.of(context).book,
				style: Theme.of(context).textTheme.headlineSmall?.copyWith(
					  color: Colors.white,
					  fontSize: 24,
					),
			  ),
			
			PopupMenuButton(
			  icon: const Icon(Icons.more_vert),
			  itemBuilder: (context) => [
				PopupMenuItem(
				  onTap: () =>  onShare(context, '${Api.baseUrlShareBook}${dataBook?.id}'),
				  value: true, 
				  child: Text(AppLocalizations.of(context).share),
				),
				PopupMenuItem(
				  value: true,
				  child: StatefulBuilder(
					builder: (BuildContext context, StateSetter setState) {
					  return CheckboxListTile(
						title: Text(AppLocalizations.of(context).updates),
						value: _updatesBook,
						onChanged: (updatesBook) {
						  setState(() {
							_updatesBook = updatesBook ?? false;
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
						  title: Text(AppLocalizations.of(context).report_this_book),
						  content: Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context).want_report),),
						  actions: [
							TextButton(
							  onPressed: () {
								Navigator.pop(context); // Fecha o AlertDialog
								sendReport();
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
				),
				
			  ],
			  
			),
		  ],
	  ),
	  body: Column(
		  mainAxisSize: MainAxisSize.min,
		  children: [
		  Container(
			decoration: const BoxDecoration(
			  color: Colors.black,
			),
			padding: const EdgeInsets.only(right:16.0, left: 16.0, bottom: 16.0),
			child: Column(
			  mainAxisAlignment: MainAxisAlignment.center,
			  children: [
			   
				Text(
				  '${dataBook?.title}',
				  maxLines: 2,
				  style: TextStyle(
					color: Colors.white,
					fontSize: fontSize(dataBook?.title),                     
				  ),
				),
				
				Text(
				  '${dataBook?.author} • ${dataBook?.publication}',
				  style: const TextStyle(
					color: Colors.white70,
					fontSize: 14,                  
				  ),
				),
			   
				Visibility(
				  visible: dataBook?.category?.name != null,
				  child: Text(
					'${dataBook?.category?.name}',
					style: const TextStyle(
					  color: Colors.white70,
					  fontSize: 14,
					),
				  ),
				),
	  
	  
			  GestureDetector( onTap: (){
				setState(() {
				  _isRating = !_isRating;
				});
			  },
				child: Row(children: [
				const Spacer(),
				 Text(
				  dataBook!.rating.toString(), 
				  style: const TextStyle(color: Colors.white70),),
				const Icon(
				  Icons.star,
				  size: 24,
				  color: Colors.white24,
				),
				const Spacer(),
			  ],),
			  ),
			  _isRating ?
			  RatingBar(
			  initialRating: dataBook!.rating.toDouble(),
			  direction: Axis.horizontal,
			  itemSize: 30,
			  itemCount: 5,
			  ratingWidget: RatingWidget(
				full:  Icon(
				Icons.star,
				color: Colors.grey.shade500,
			  ),
				half: const Icon(
				Icons.star,
				color: Colors.white24,
			  ),
				empty:  Icon(
				Icons.star,
				color: Colors.grey.shade800,
			  ),
			  ),
			  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
			  onRatingUpdate: (rating) {
				  sendRating(rating);
			  },
			) : 
			const SizedBox(),
				const SizedBox(height: 4,),
				Container(
				  child: RichText(
					textAlign: TextAlign.justify,
					text: TextSpan(
					  style: const TextStyle(
						color: Colors.white,
						fontFamily: 'Noto',
						fontSize: 14,
					  
					  ),
					  children: [
						TextSpan(
						  text: '${dataBook?.synopsis}',
						),
					  ],
					),
					overflow: TextOverflow.ellipsis,
					maxLines: 3,
				  ),
				),
				
				const SizedBox(height: 15,),
					  Row(
						children: [
						  const  Spacer(),
						  InkWell(
							onTap: () {
							  
				
							},
							child: Column (
							  children: [
								Center(
								  child: GestureDetector(
									onTap: (){
									  if (_isFollowing) {
										removeFollow();
									  } else {
										sendFollow();
									  }
									},
									child: Text(
									  AppLocalizations.of(context).following,
									  style: const TextStyle(
											color: Colors.white,
											fontFamily: 'Noto',
											fontSize: 14,
										  ),
									),
								  ),
								),
								Text(
								  convertNumbers(dataBook?.followCount ?? 0),
								  style: 
									const TextStyle(
									  color: Colors.white,
									  fontFamily: 'Noto',
									  fontSize: 14,
									),
								),
							  ],
							),
						  ),
						  const Spacer(),
						  
						 Column(
							children: [
							  Center(
								  child: GestureDetector(
									onTap: (){
									  if (_isRead) {
										removeRead();
									  } else {
										sendRead();
									  }
									},
									child: Text(
									  AppLocalizations.of(context).read,
									  style: const TextStyle(
											color: Colors.white,
											fontFamily: 'Noto',
											fontSize: 14,
										  ),
									),
								  ),
								),
							  Text(
								convertNumbers(dataBook?.readCount ?? 0),
								style: const TextStyle(
								  color: Colors.white,
								  fontFamily: 'Noto',
								  fontSize: 14,
								),
							  ),
							],
						  ),
						  const Spacer(),
						  Column(
							children: [
							  Center(
								  child: GestureDetector(
									onTap: (){
									  if (_isSaved) {
										removeSave();
									  } else {
										sendSave();
									  }
									},
									child: Text(
									  AppLocalizations.of(context).saved,
									  style: const TextStyle(
											color: Colors.white,
											fontFamily: 'Noto',
											fontSize: 14,
										  ),
									),
								  ),
								),
							  Text(
								convertNumbers(dataBook?.saveCount ?? 0),
								style: const TextStyle(
								  color: Colors.white,
								  fontFamily: 'Noto',
								  fontSize: 14,
								),
							  ),
							],
												),
							const Spacer(),
						],
					  ),
					 const SizedBox(height: 8,),
				  Row(
					children: [
					  const Icon(Icons.photo_library_outlined, color: Colors.white70,),
					  const SizedBox(width: 8,),
					  Text(
						convertNumbers(dataBook?.imageCount ?? 0),
						style: const TextStyle(
								  color: Colors.white,
								  fontFamily: 'Noto',
								  fontSize: 14,
								),
						overflow: TextOverflow.ellipsis,
					  ),
					  
					  const Spacer(),
					  IconButton(
						  onPressed: () async {
							
					  
							await selectAndSendImageBook(context);
							
							
						  },
						  icon: const Icon(
							Icons.add_outlined,
							size: 24, 
							color:Colors.white,
						  ),  
						
					  ),
					  IconButton(
						  onPressed: () { 
						  setState(() {
							_isImagesActive = !_isImagesActive;
							
						  });
						},
						  icon: Icon(
							_isImagesActive ?
							Icons.expand_less
							: Icons.expand_more,
							size: 24, 
							color:Colors.white,
						  ),  
						
					  ),
					  
					  
					],
				  ),
				  _isImagesActive ? 
				  Visibility(
					visible: true,
					child: SizedBox(
					  width: double.infinity,
					  height: 120, 
					  child: ImageListWidget(
						imagesManager: _imagesManager,
						itemId: widget.itemId,
					  ),
					)) : const SizedBox(),
				  
				
			   ], 
			  ),
			),
				Row(
				  mainAxisAlignment: MainAxisAlignment.center,
				  children: [
					
					Padding(
					  padding: const EdgeInsets.only(left:16.0, right: 16.0, ),
					  child: Text(
					  
						AppLocalizations.of(context).talks,
					   style: const TextStyle(
						  color: Colors.black,
						 fontFamily: 'Noto',
						 fontSize: 16,
					  
					   ),
					 ),
					),
					
					Center(child: Text(
						convertNumbers(dataBook?.talkCount ?? 0),
					   style: const TextStyle(
						  color: Colors.black,
						 fontFamily: 'Noto',
						 fontSize: 16,
					  
					   ),
					 ),),
					const Spacer(),
					IconButton(
					  padding: const EdgeInsets.only(left:16.0, right: 16.0),
					  onPressed: () { 
						setState(() {
						   _isSearchActive = !_isSearchActive;
               if(_isSearchActive) {
                isDate = false;
                isLike = false;
                isComment = false;
                isSearch = true;
               }
						   _isAddActive = false;
						   _isOrderingActive = false;
						});
					 },
					  icon: const Icon(Icons.search_outlined)
					), 
					IconButton(
					  padding: const EdgeInsets.only(left:16.0, right: 16.0),
					  onPressed: () { 
						setState(() {
						 _isOrderingActive = !_isOrderingActive;
						 _isSearchActive = false;
						 _isAddActive = false;
						});
					 },
					  icon: const Icon(Icons.filter_list_outlined)
					),
					IconButton(
					  padding: const EdgeInsets.only(left:16.0, right: 16.0),
					  onPressed: () { 
						setState(() {
						  _isAddActive = !_isAddActive;
						  _isOrderingActive = false;
						  _isSearchActive = false;
						});
					 },
					  icon: const Icon(Icons.add_outlined)
					),
				  ],
				),
				_isSearchActive ?
				Container(
				  margin: const EdgeInsets.only(bottom: 16),
				  padding: const EdgeInsets.only(left:16.0, right: 16.0),
				  
				  child: CustomTextField(
					controller: _searchTalkController,
				  keyboardType: TextInputType.text,
				  maxLength: 140,
				  obscureText: false,
				  hint:  AppLocalizations.of(context).search_talk,
				  suffixIcon: IconButton(
					  onPressed: () {
              setState(() {
                final searchTerm = _searchTalkController.text.toString();
                stringSearchTalks = '${Api.talk}?book=${widget.itemId}&subject=$searchTerm';
                _talksSearchManager.setUrl(stringSearchTalks);
        
              });
              
					  },
					  icon: const Icon(Icons.search_outlined, color: Colors.black),
					),
				  
			  
			),
				) : const SizedBox(height: 0,),
				_isAddActive 
				? Container(
				  margin: const EdgeInsets.only(bottom: 16),
				  padding: const EdgeInsets.only(left:16.0, right: 16.0),
				  child: CustomTextField(
					controller: _subjectController,
					keyboardType: TextInputType.text,
					maxLength: 140,
					obscureText: false,
					hint: AppLocalizations.of(context).enter_subject,
					suffixIcon: Row(
						mainAxisSize: MainAxisSize.min,
						children: [
						  IconButton(
							icon: Icon(Icons.audio_file_outlined, color:Colors.grey.shade700),
							onPressed: () async {
							 
							  if(!await _checkAndRequestMicrophonePermission()){
								CustomSnackbar.showWithAction(context, "${AppLocalizations.of(context).mic} ${AppLocalizations.of(context).permission_required}", Colors.redAccent, SnackBarAction(label: AppLocalizations.of(context).allow, onPressed: (){ _checkAndRequestMicrophonePermission();}));
								return;
							  }
							  
							 
							  
							 final status = await Permission.audio.status;
              final statusstorage = await Permission.audio.status;
                if (!status.isGranted || !statusstorage.isGranted) {
                final result = await Permission.audio.request();
                final statusstorage = await Permission.audio.request();
                if (result.isGranted || statusstorage.isGranted) {
                  showModalBottomSheet<void>(
								isDismissible: false,
								  context: context,
								  builder: (BuildContext context) {
									
									return RecorderWidget(bookId: dataBook!.id,);
									
								  },
								);
                } 
                }
              }
              ),
						  IconButton(
							icon: Icon(Icons.send_outlined, color: Colors.grey.shade700,),
							onPressed: () {
							  sendTalk();
							},
							
						  )
						  // Adicione mais ícones conforme necessário
						],
					),
				  ),
			): const SizedBox(),
		  _isOrderingActive 
		  ? Center(
		  child: DropdownButton<int>(
			value: _dropDownselectedValue,
			onChanged: (int? talksBy) {
			  setState(() {
				_dropDownselectedValue = talksBy!;
			  });
			  switch (talksBy) {
				case 0:
				
				  setState(() {
					isDate = true;
					isLike = false;
					isComment = false;
          isSearch = false;
					
				  });
				break;
				case 1:
			   
				  setState(() {
				   isDate = false;
					isLike = true;
					isComment = false;
          isSearch = false;
				   
				  });
				break;
				case 2:
				  
				  setState(() {
					isDate = false;
					isLike = false;
					isComment = true;
          isSearch = false;
					
				  });
				break;
				default:
				
				  setState(() {
					isDate = true;
					isLike = false;
					isComment = false;
          isSearch = false;
					
				  });
				break;
	  
				
			  }
			  
			
			  
			},
			items: <DropdownMenuItem<int>>[
			  DropdownMenuItem<int>(
				value: 0,
				child: Text(AppLocalizations.of(context).by_date),
			  ),
			  
			  DropdownMenuItem<int>(
				value: 1,
				child: Text(AppLocalizations.of(context).by_most_liked),
			  ),
			  DropdownMenuItem<int>(
				value: 2,
				child: Text(AppLocalizations.of(context).by_most_commented),
			  ),
			  
			],
			
		  )
	  
		) : const SizedBox(),
	   
		Visibility(
		  visible: isDate,
		  child: Expanded(
		  child: TalkListWidget(
			  talksManager: _talksDateManager,
			  urlTalks: _urlTalksDate,
			  itemId: widget.itemId,
			  scrollController: _scrollController,
	  
		  ),
		)),
		Visibility(
		  visible: isLike,
		  child: Expanded(
		  child: TalkLikeListWidget(
			  talksManager: _talksLikeManager,
			  urlTalks: _urlTalksLike,
			  itemId: widget.itemId,
			  scrollController: _scrollController,
	  
		  ),
		)),
		Visibility(
		  visible: isComment,
		  child: Expanded(
		  child: TalkCommentListWidget(
			  talksManager: _talksCommentManager,
			  urlTalks: _urlTalksComment,
			  itemId: widget.itemId,
			  scrollController: _scrollController,
	  
		  ),
		)),
    Visibility(
		  visible: isSearch,
		  child: Expanded(
		  child: TalkSearchListWidget(
			  talksManager: _talksSearchManager,
			  urlTalks: stringSearchTalks,
			  itemId: widget.itemId,
			  scrollController: _scrollController,
	  
		  ),
		))
		 
		
		
		
		
		
		
		],
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
  Future<Book> fetchBookData() async {
	try {
	  var url = Uri.parse('${Api.book}${widget.itemId}/');
	  final response = await http.get(
		url,
		headers: {
		  'Authorization': (await getToken()) ?? '',
		  'Content-Type': 'application/json; charset=utf-8',
		},
	);

	if (response.statusCode == 200) {


	  final data = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
	  return Book.fromJson(data);
	} else {
	   Navigator.pop(context);
      CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).error_ocurred, 
        Colors.redAccent);
	  throw Exception('Erro na solicitação HTTP: ${response.body}');
	}
	} catch (error) {
	  // Captura e trata qualquer exceção que possa ocorrer durante o processo
	   Navigator.pop(context);
      CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).error_ocurred, 
        Colors.redAccent);
	  rethrow; // Re-lança a exceção para que a função chamadora também possa lidar com ela
	}
  }

  

  Future<void> sendTalk() async {
     showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
            color: Colors.black,
        )
        );
      }
    );
	var url = Uri.parse(Api.talk);

	String book = widget.itemId;
	String subject = _subjectController.text.trim();

	  final bodyt = {
		'book': book,
		'type': 't',
		'subject': subject,
	  }; 
	  
	  http.Response response;
	  
	  final encodedBody = jsonEncode(bodyt);
	  try{
      response = await http.post(
        url,  
        headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json;charset=utf-8', 
        },
        body: encodedBody
      );
      if(response.statusCode == 201){
        _subjectController.text = '';
        Navigator.pop(context);
        _loadItems();
        CustomSnackbar.show(
          context, 
          AppLocalizations.of(context).talk_added, 
          Colors.grey.shade500);
      } else {
        Navigator.pop(context);
        CustomSnackbar.show(
          context, 
          AppLocalizations.of(context).error_ocurred, 
          Colors.redAccent);
      }

	  } catch(error){
		  Navigator.pop(context);
      CustomSnackbar.show(
        context, 
        AppLocalizations.of(context).error_ocurred, 
        Colors.redAccent);
	  }


  }



Future<void> pickImage() async {
  final storagePermissionStatus = await _checkStoragePermission();
  if (storagePermissionStatus == PermissionStatus.denied ||
	  storagePermissionStatus == PermissionStatus.restricted) {
	final result = await _requestStoragePermission();
	if (result == PermissionStatus.granted) {
	  selectAndSendImageBook(context);
	} else {
	  CustomSnackbar.showWithAction(context, "${AppLocalizations.of(context).storage} ${AppLocalizations.of(context).permission_required}", Colors.redAccent, SnackBarAction(label: AppLocalizations.of(context).ok, onPressed: (){_requestStoragePermission(); }));
	}
  } else {
	selectAndSendImageBook(context);
  }
}

Future<PermissionStatus> _checkStoragePermission() async {
  final storagePermissionStatus = await Permission.storage.status;
  return storagePermissionStatus;
}

Future<bool> _requestStoragePermission() async {
  final result = await Permission.manageExternalStorage.request() ;
  final resultStorage = await Permission.storage.request();
  if (result == PermissionStatus.granted && resultStorage == PermissionStatus.granted) {
	return true;
  } else {
	return false;
  }
}


  Future<void> selectAndSendImageBook(context) async {
   
	final picker = ImagePicker();
	final pickedFile = await picker.pickImage(source: ImageSource.gallery);
	showDialog(
		barrierDismissible: false,
		context: context, 
		builder: (context) {
			return const Center(
			child: CircularProgressIndicator(
				backgroundColor: Colors.white,
				color: Colors.black,
			)
			);
		}
		);
	if (pickedFile == null) {
		Navigator.of(context).pop();
		
		return;
  }
  if(!isImage(pickedFile.path)){
	Navigator.of(context).pop();
	
	return;
  }
  File imagem = File(pickedFile.path);

  final url = Uri.parse(Api.image);
  
  var request = http.MultipartRequest('POST', url);

  request.headers.addAll({
	'Authorization': (await getToken() ?? ''),
  });
  
  request.fields['book'] = widget.itemId;

  request.files.add(
	await http.MultipartFile.fromPath(
	  'image',
	  imagem.path,
	  contentType: MediaType('image', getMineType(imagem.path)),
	),
  );
  
  
  request.send().then((response) {
	Navigator.of(context).pop();
	if (response.statusCode == 201) {
	  
		CustomSnackbar.show(
			context, 
			AppLocalizations.of(context).image_sent, 
			Colors.grey.shade500
		);
	  
	} else {
		CustomSnackbar.show(
			context, 
			AppLocalizations.of(context).error_ocurred, 
			Colors.redAccent
		);
	  
	}
  });
}

  Future sendFollow() async{
	var url = Uri.parse(Api.follow);
	String book = widget.itemId;
   
	final body = {
		'book': book,
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
	  setState(() {
		 _isFollowing = true;
	  });
	   
	}
  }
  
  Future removeFollow() async {
	String following = dataBook?.following;
	var url = Uri.parse('${Api.follow}$following/');
   
	
	var response = await http.delete(
	  url, 
	  headers: {
		  'Authorization': (await getToken() ?? ''),
		  'Content-Type': 'application/json; charset=utf-8', 
	  },
	);

	

	if(response.statusCode == 204) {  
	  setState(() {
		 _isFollowing = false;
	  });
	   
	}
  }
  Future sendRead() async{
	var url = Uri.parse(Api.read);
	String book = widget.itemId;
   
	final body = {
		'book': book,
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
	  setState(() {
		 _isRead = true;
	  });
	   
	}
  }
  
  Future removeRead() async {
	String read = dataBook?.read;
	var url = Uri.parse('${Api.read}$read/');
   
	
	var response = await http.delete(
	  url, 
	  headers: {
		  'Authorization': (await getToken() ?? ''),
		  'Content-Type': 'application/json; charset=utf-8', 
	  },
	);

	if(response.statusCode == 204) {  
	  setState(() {
		 _isRead = false;
	  });
	   
	}
  }


  Future sendSave() async{
	var url = Uri.parse(Api.save);
	String book = widget.itemId;
   
	final body = {
		'book': book,
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
	  setState(() {
		 _isSaved = true;
	  });
	   
	}
  }
  
  Future removeSave() async {
	String saved = dataBook?.saved;
	var url = Uri.parse('${Api.save}$saved/');
   
	
	var response = await http.delete(
	  url, 
	  headers: {
		  'Authorization': (await getToken() ?? ''),
		  'Content-Type': 'application/json; charset=utf-8', 
	  },
	);

	if(response.statusCode == 204) {  
	  setState(() {
		 _isSaved = false;
	  });
	   
	}
  }
  


  Future<bool> _checkAndRequestMicrophonePermission() async {
  final status = await Permission.microphone.status;
  if (status.isGranted) {
	return true;
  } else {
	final result = await Permission.microphone.request();
	if (result.isGranted) {
	  return true;
	} else {
	  return false;
	}
  }
}

  Future sendRating(double rating) async {
      var url = Uri.parse(Api.rating);
	String book = widget.itemId;
   
	final body = {
		'book': book,
    'rating': rating.toInt()
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
			AppLocalizations.of(context).rating_sent, 
			Colors.grey.shade500
		);
	   
	}

  }


  Future sendReport() async {
    var url = Uri.parse(Api.report);
    String book = widget.itemId;
   
    final body = {
        'type_report': 'b',
        'book': book,
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




bool isImage(String path) {
  final mimeType = lookupMimeType(path);

  return mimeType?.startsWith('image/') ?? false;
}
bool isAudio(String path) {
  final mimeType = lookupMimeType(path);

  return mimeType?.startsWith('audio/') ?? false;
}
String getMineType(String path) {
  final String? mimeType = lookupMimeType(path);

  return mimeType?.split('/').last ?? '';
}
// TALKS LIST
class ProgressoWidget extends StatelessWidget {
  final double percentUpload;

  const ProgressoWidget({super.key, required this.percentUpload});

  @override
  Widget build(BuildContext context) {
	return Text('Progresso: ${percentUpload.toStringAsFixed(0)}%');
  }
}
