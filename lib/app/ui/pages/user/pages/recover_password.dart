import 'dart:convert';

import 'package:booksclub/app/ui/widgets/custom_button.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:booksclub/app/ui/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../api.dart';

class RecoverPassword extends StatefulWidget {
  const RecoverPassword({super.key});

  @override
  State<RecoverPassword> createState() => _RecoverPasswordState();

}


class _RecoverPasswordState extends State<RecoverPassword> {

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _haveCode = false;
  bool _seePassword = false;
  bool _seePasswordConfirmation = false;


  Future sendEmail() async {
    
    if(!_emailController.text.contains('@') || !_emailController.text.contains('.') || _emailController.text.toString().length < 6) {
        CustomSnackbar.show(
          context,
          AppLocalizations.of(context).invalid_email,
        Colors.redAccent
        );
        return;
    }
    
     
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
    var url = Uri.parse(Api.recoverAccount);
    var body =  {
      'email': _emailController.text.trim(),    
    };
    final encodedBody = jsonEncode(body);
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8', 
      },
      body: encodedBody
    );
    Navigator.pop(context);
    if(response.statusCode == 200) {
      CustomSnackbar.show(
          context,
          AppLocalizations.of(context).email_sent,
        Colors.grey.shade700
        );
    
      setState(() {
        _haveCode = true;
      });
        
      } else {
        
        CustomSnackbar.show(
          context,
          AppLocalizations.of(context).invalid_email,
        Colors.redAccent
        );
        
      }
  }
   Future recoverPass() async {
    if(_codeController.text.isEmpty || _codeController.text.length != 9) {
      return;
    }   

    if(_passController.text != _confirmPassController.text) {
      showDialog(
        barrierDismissible: true,
        context: context, 
        builder:  (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
            ),
            title: Center(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  AppLocalizations.of(context).password_dont_match,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    
                  ),
                ),
              ),
            )
          );
        
        }
      );
      return;
    }
     

      var url = Uri.parse(Api.recoverAccountConfirm);
      var body =  {
          'token': _codeController.text.trim(),
          'password': _passController.text.trim(),
        } ;
    final encodedBody = jsonEncode(body);
    
      var response = await http.post(
        url,
        headers: {
        'Content-Type': 'application/json; charset=utf-8', 
        },
        body: encodedBody
      );
      if(response.statusCode == 200) {
        CustomSnackbar.show(
          context,
          AppLocalizations.of(context).password_changed,
        Colors.grey.shade700
        );
        Navigator.pop(context, false);
        
      } else {
      
        CustomSnackbar.show(
          context,
          AppLocalizations.of(context).invalid_code,
        Colors.redAccent
        );
        
        
      }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ 
              Center(
                
                child: Text(
                 AppLocalizations.of(context).app_name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 48,
                    ),),
              ), 
              const SizedBox(height: 15,),
              Center(
                child: Text(
                AppLocalizations.of(context).recover_password,
                style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                ),),
              ),
              const SizedBox(height: 15,),
              
              const SizedBox(height: 10,),
              !_haveCode ?
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: CustomTextField(
                    controller: _emailController, 
                    hint: AppLocalizations.of(context).enter_email, 
                    obscureText: false, 
                    maxLength: 64,
                    keyboardType: TextInputType.emailAddress
                                   ),
                 ) : Column(
                
                children: [
                  const SizedBox(height: 10,),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 20,),
                 child: CustomTextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      hint: AppLocalizations.of(context).enter_code,
                      obscureText: false,
                      maxLength: 9,
                      prefixIcon: const Icon(Icons.lock_open_outlined),
                    ),
                  ),
                  
                const SizedBox(height: 10,),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20,),
                 child: CustomTextField(
                      controller: _passController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !_seePassword,
                      hint: AppLocalizations.of(context).enter_new_password,
                      maxLength: 64,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          icon: Icon(
                            _seePassword 
                            ? Icons.visibility_off_outlined 
                            : Icons.visibility_outlined,
                            color: Colors.black54,
                          ), 
                          onPressed: () { 
                              setState(() {
                                _seePassword = !_seePassword;

                              });
                          },

                        ),
                      
                      
                  ),
                ),
                const SizedBox(height: 10,),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20,),
                 child: CustomTextField(
                      controller: _confirmPassController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !_seePasswordConfirmation,
                      maxLength: 64,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          icon: Icon(
                            _seePasswordConfirmation 
                            ? Icons.visibility_off_outlined 
                            : Icons.visibility_outlined,
                            color: Colors.black54,
                          ), 
                          onPressed: () { 
                              setState(() {
                                _seePasswordConfirmation = !_seePasswordConfirmation;

                              });
                          },

                        ),
                      hint: AppLocalizations.of(context).enter_new_password,
                      
                  ),
                ),
              ]),
              const SizedBox(height: 20,),
              _haveCode ?
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20,),
                 child: CustomButton(
                    text:  AppLocalizations.of(context).send_code,
                    onTap: (){
                        recoverPass();
                        
                    },
                  ),
                ) :
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20,),
                 child: CustomButton(
                    text:  AppLocalizations.of(context).send_code,
                    onTap: (){
                        sendEmail();
                        
                    },
                  ),
                ),
              
              const SizedBox(height: 25,),
              !_haveCode ? Container(
                margin: const EdgeInsets.only(right: 20, left: 20),
                child:Align(
                  
                  alignment: Alignment.centerRight,
                  child: GestureDetector( 
                    onTap: () {
                      setState(() {
                      _haveCode = true;
                    });
                    },
                    child: Text(
                    AppLocalizations.of(context).have_verification_code,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ) : const SizedBox(),
              
              const SizedBox(height: 35,),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                  AppLocalizations.of(context).cancel,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                    ),
                  ),
                )
              ),

            ],


          ),
          )
    );
  }

  

}