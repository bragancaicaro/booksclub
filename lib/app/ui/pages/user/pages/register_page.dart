import 'dart:convert';

import 'package:booksclub/app/ui/pages/user/pages/privacy.dart';
import 'package:booksclub/app/ui/widgets/custom_button.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:booksclub/app/ui/widgets/custom_text_field.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../api.dart';
final dio = Dio();

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();

}


class _RegisterPageState extends State<RegisterPage> {


  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _seePassword = false;
  bool _seePasswordConfirmation = false;
  bool _isAgreePrivacyPolicy = false;
  


  Future singUp() async {
    
    if(_nameController.text.toString().isEmpty) {
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context).enter_name,
       Colors.redAccent
        );
      return;
    }
    if(!_emailController.text.contains('@') || !_emailController.text.contains('.') || _emailController.text.length < 6) {
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context).invalid_email,
       Colors.redAccent
      );
      return;
    }
    if(_passController.text.toString().isEmpty) {
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context).enter_password,
       Colors.redAccent
      );
      return;
    }
    if(_passController.text.toString().length < 6) {
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context).short_password,
       Colors.redAccent
      );
      return;
    }
    if(_confirmPassController.text.toString().isEmpty) {
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context).enter_password_confirmation,
       Colors.redAccent
      );
      return;
    }
    if(_passController.text.toString() != _confirmPassController.text.toString()) {
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context).password_dont_match,
       Colors.redAccent
      );
      return;
    }
    if(!_isAgreePrivacyPolicy) {
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context).agree_privacy_policy,
       Colors.redAccent
      );
      return;
    }
    
     
    var url = Uri.parse(Api.createAccount);
    var body =  {
      'email': _emailController.text.trim().toLowerCase(),
      'password': _passController.text.trim(),
      'name': _nameController.text.trim(),
    } ;
    final encodedBody = jsonEncode(body);
    
      var response = await http.post(
        url,
        headers: {
        'Content-Type': 'application/json; charset=utf-8', 
        },
        body: encodedBody
      );
      
      await FirebaseAnalytics.instance.logSignUp(
        parameters: {
          'name': 'signup',
          'StatusCode': response.statusCode, 
        }, signUpMethod: 'booksclub account'
      );

      if(response.statusCode == 201) {
        CustomSnackbar.show(
          context,
          AppLocalizations.of(context).account_created,
        Colors.grey.shade700
        );
      
        Navigator.pop(context, false);
        
      } else {
        CustomSnackbar.show(
          context,
          AppLocalizations.of(context).invalid_already_exist_email,
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
                AppLocalizations.of(context).join_us,
                style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                ),),
              ),
              const SizedBox(height: 15,),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: CustomTextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  hint: AppLocalizations.of(context).enter_name,
                  obscureText: false,
                  maxLength: 32,
                  prefixIcon: const Icon(Icons.person_2_outlined),
                    
                ),
              ),
              const SizedBox(height: 15,),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: CustomTextField(
                  controller: _emailController,
                  maxLength: 64,
                  obscureText: false,
                  hint: AppLocalizations.of(context).enter_email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.black),          
                ),
              ),

              
              const SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextField(
                maxLength: 128,
                controller: _passController,
                hint: AppLocalizations.of(context).enter_password,
                prefixIcon: const Icon(Icons.lock_outlined, color: Colors.black),
                keyboardType: TextInputType.visiblePassword,
                obscureText: !_seePassword,
                suffixIcon: IconButton(
                    icon: Icon(
                      _seePassword
                      ? Icons.visibility_off_outlined 
                      : Icons.visibility_outlined
                    ), 
                    onPressed: () { 
                        setState(() {
                          _seePassword = !_seePassword;

                        });
                     },

                  ),
              ),
              ),
              const SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextField(
                controller: _confirmPassController,
                keyboardType: TextInputType.visiblePassword,
                hint: AppLocalizations.of(context).enter_password_confirmation,
                maxLength: 128,
                prefixIcon: const Icon(Icons.lock_outlined, color: Colors.black),
                obscureText: !_seePasswordConfirmation,
                suffixIcon: IconButton(
                    icon: Icon(
                      _seePasswordConfirmation 
                      ? Icons.visibility_off_outlined 
                      : Icons.visibility_outlined
                    ), 
                    onPressed: () { 
                        setState(() {
                          _seePasswordConfirmation = !_seePasswordConfirmation;

                        });
                     },

                  ),
              ),
              ),
              const SizedBox(height: 10,),
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                  Checkbox(value: _isAgreePrivacyPolicy, onChanged: (value){
                    setState(() {
                      _isAgreePrivacyPolicy = value!;
                    });
                  }),
                  RichText(
                  text: TextSpan(
                      text: AppLocalizations.of(context).i_agree_with_the,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        
                        const TextSpan(text: " "),
                        TextSpan(
                          text: AppLocalizations.of(context).privacy_policy,
                          style: const TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showDialog(context: context, builder: (context){
                              return PrivacyPolicy();
                            }); // Substitua pela sua URL
                          },
                        ),
                        
                      ],
                    ),
                  ),
                ],
                ),
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  text: AppLocalizations.of(context).create_account,
                  onTap: () {
                     singUp(); 
                  },
                  
                ),
              ),
              const SizedBox(height: 35,),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                  AppLocalizations.of(context).cancel,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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


  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://booksclub.app/privacy.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, webOnlyWindowName: '_blank');
    } else {
      throw 'Não foi possível abrir a URL: $url';
    }
  }
  

}