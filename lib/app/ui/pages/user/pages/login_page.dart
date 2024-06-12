import 'dart:convert';
import 'package:booksclub/app/ui/widgets/custom_button.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:booksclub/app/ui/widgets/custom_text_field.dart';
import 'package:booksclub/app/ui/pages/user/pages/recover_password.dart';
import 'package:booksclub/app/ui/pages/user/pages/register_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../api.dart';
import 'package:go_router/go_router.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

}


class _LoginPageState extends State<LoginPage> {

  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _seePassword = false;
  

   @override
  void initState() {

    super.initState();
   
  }


  Future signIn() async {
    
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
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      var url = Uri.parse(Api.login);
      var response = await http.post(
        url,
        body: {
          'username': _emailController.text.trim(),
          'password': _passController.text.trim(),
        } 
      );
      
      
      await FirebaseAnalytics.instance.logLogin(
        parameters: {
          'name': 'login',
          'StatusCode': response.statusCode, 
        }
      );
      
      if(response.statusCode == 200) {
        String token = json.decode(response.body)['token'];
        await sharedPreferences.setString('token', 'Token $token');
        
          
          context.go('/tabs');
        
      } else {
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          AppLocalizations.of(context).invalid_email_or_password,
        Colors.redAccent
        );
        
      }
  }
  




  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ 
                
                Text(
                   AppLocalizations.of(context).app_name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 48,
                      ),), 
                const SizedBox(height: 15,),
                Center(
                  child: Text(
                    AppLocalizations.of(context).welcome,
                    style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 25,),
              
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,),
                  child: CustomTextField(
                    controller: _emailController, 
                    hint: AppLocalizations.of(context).email, 
                    obscureText: false, 
                    maxLength: 64,
                    prefixIcon: const Icon(Icons.person_outline),
                    keyboardType: TextInputType.emailAddress
                  ),
                ),
                const SizedBox(height: 10,),
                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: CustomTextField(
                    controller: _passController, 
                    hint: AppLocalizations.of(context).password, 
                    obscureText: !_seePassword, 
                    maxLength: 64,
                    keyboardType: TextInputType.visiblePassword,
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
                const SizedBox(height: 25,),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20,),
                 child: CustomButton(
                    text:  AppLocalizations.of(context).signin,
                    onTap: (){
                        // authBloc.login(
                        //   _emailController.text.toString().trim(),
                        //   _passController.text.toString().trim(),
                        // );
                        signIn();
                    },
                  ),
                ),
                
                const SizedBox(height: 25,),
                Padding(
                    padding: const EdgeInsets.only(right: 20, left:20),
                    child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector( 
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
                    return const RecoverPassword();
                  },
                ),
              );
                       
                      },
                      child: Text(
                      AppLocalizations.of(context).forgot_password,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  ),
                  const SizedBox(height: 35,),
                  Center(
                    child:Text(AppLocalizations.of(context).or, style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),)
                  ),
                  const SizedBox(height: 10,),
                  GestureDetector(
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
                    return const RegisterPage();
                  },
                ),
              );
                    },
                    child: Text(
                    AppLocalizations.of(context).signup,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        
                        fontSize: 22,
                      ),
                    ),
                  ),
                  
              
                ],
              ),
        )
      );
  }
  


   Future<bool> virifyUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
      
      if(token != null && token.isNotEmpty && token.startsWith('Token')) {
        return true;
      } else {
        sharedPreferences.clear();
        return false;
      }
  
  }


}