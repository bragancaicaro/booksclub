import 'dart:convert';

import 'package:booksclub/app/token/get_token.dart';
import 'package:booksclub/app/ui/widgets/custom_button.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:booksclub/app/ui/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import '../../../../api.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();

}


class _AddBookPageState extends State<AddBookPage> {

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publicationController = TextEditingController();
  final _categoryController = TextEditingController(); 
  final _synopsisController = TextEditingController();

  
  Future addBook() async {
    
    showDialog(
      
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
      final Map<String, Object> body;
      var url = Uri.parse(Api.book);
      if (_categoryController.text.isEmpty) {
        body = {
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'publication': _publicationController.text.trim(),
          'synopsis': _synopsisController.text.trim(),

        };
      } else {
        body = {
            'title': _titleController.text.trim(),
            'author': _authorController.text.trim(),
            'publication': _publicationController.text.trim(),
            'category': {
              "name": _categoryController.text.trim()
            },
            'synopsis': _synopsisController.text.trim(),

        };
      }
      
      final encodedBody = jsonEncode(body);

      var response = await http.post(
        url,  
        headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
        },
        body: encodedBody
      );
      
      print(response.body);
      if(response.statusCode == 201) {
        Navigator.of(context).pop(false);
        CustomSnackbar.show(
          context, 
          AppLocalizations.of(context).book_added, 
          Colors.grey.shade500);
      
      } else if (response.statusCode == 400) {
        Navigator.of(context).pop(false);
        
        CustomSnackbar.show(
          context, 
          AppLocalizations.of(context).book_exists, 
          Colors.redAccent);
        
      } else {
        
        Navigator.of(context).pop(false);
        
        CustomSnackbar.show(
          context, 
          AppLocalizations.of(context).error_ocurred, 
          Colors.redAccent);
      }
    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 60,
        automaticallyImplyLeading: true, // Exibe automaticamente o botão de voltar padrão
        
        actions: [
          Padding(padding: const EdgeInsets.only(right: 16),
          child: Text(
            AppLocalizations.of(context).add_book,
            style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
          ),
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          const SizedBox(height: 14,),
          Column(
              children: [
                CustomTextField(
                  keyboardType: TextInputType.text,
                  controller: _titleController,
                  maxLength: 96,
                  obscureText: false,
                hint: AppLocalizations.of(context).enter_book_title,
                ),
              const SizedBox(height: 18,),
              CustomTextField(
                keyboardType: TextInputType.text,
                controller: _authorController,
                maxLength: 32,
                obscureText: false,
                hint: AppLocalizations.of(context).enter_book_author,
               
              ),
              const SizedBox(height: 18,),
              CustomTextField(
                keyboardType: TextInputType.number,
                controller: _publicationController,
                obscureText: false,
                hint: AppLocalizations.of(context).enter_book_publication,
                maxLength: 4,
              
               
              ),
              const SizedBox(height: 18,),
              CustomTextField(
                keyboardType: TextInputType.text,
                controller: _categoryController,
                maxLength: 16,
                obscureText: false,
                hint:AppLocalizations.of(context).enter_book_category,
                
              ),
              const SizedBox(height: 18,),
              CustomTextField(
                keyboardType: TextInputType.text,
                controller: _synopsisController,
                maxLength: 140,
                obscureText: false,
                maxLines: 3,
               hint: AppLocalizations.of(context).enter_book_synopsis,
              ),
              ],
            ),
          
          
          const SizedBox(
            height: 20,
          ),
          
          CustomButton(
              text: AppLocalizations.of(context).add, 
              onTap: () {
                addBook();
              },),
             
          
          
          
          
          
          
          
        ],
      ),
      ),
      ),
    );
  }

  

}