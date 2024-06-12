import 'package:booksclub/app/api.dart';
import 'package:booksclub/app/ui/widgets/custom_button.dart';
import 'package:booksclub/app/ui/widgets/custom_snackbar.dart';
import 'package:booksclub/app/ui/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models/user.dart';
import '../../../../token/get_token.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

@override
State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>{
  User user = User();
  bool _isEditName = false;
  bool _isEditEmail = false;
  bool _isEditPassword = false;
  bool _seeCurrentPassword = false;
  bool _seePassword = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController =  TextEditingController();
  final _newPasswordController =  TextEditingController();
  bool _errorEmail = false;
   bool _errorName = false;
  bool _errorPassoword = false;
  @override
  void initState() {
    super.initState();
  }


  Future<void> _clearSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();

    context.go('/');
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
      future: fetchUserData(),
      builder: (context, snapshot) {
      if(snapshot.hasData){
        user = snapshot.data!;
        _nameController.text = user.name;
        _emailController.text = user.email;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            toolbarHeight: 72,
            automaticallyImplyLeading: true, // Exibe automaticamente o botão de voltar padrão
            
            actions: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(AppLocalizations.of(context).account,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
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
                  const SizedBox(
                    height: 14,
                  ),
                  
                  _isEditName ? 
                  CustomTextField(
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            maxLength: 32,
                            obscureText: false,
                            hint:AppLocalizations.of(context).enter_new_name,
                            errorText: _errorName ? AppLocalizations.of(context).enter_name : null,
                          suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.done_outlined
                                ), 
                              onPressed: () { 
                                editName(); 
                                setState(() {
                                  _isEditName = !_isEditName;
                                });
                              },
                  )
                  )
                      : 
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth: 150,
                          ),
                        
                          child:Text(
                          user.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                            ),),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditName = !_isEditName;
                            });
                            if(_nameController.text.toString().isEmpty){
                                setState(() {
                                  _errorName = true;
                                });
                            }
                          },
                          icon: const Icon(Icons.edit_outlined,
                          ),
                      )    
                      
                    ],
                    ),
                  
                  
                  const SizedBox(
                    height: 14,
                  ),
                
                
                  _isEditEmail ? 
                  CustomTextField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          maxLength: 64,
                          obscureText: false,
                          errorText: _errorEmail ? AppLocalizations.of(context).enter_email : null,
                          hint: AppLocalizations.of(context).enter_new_email,
                           suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.done_outlined
                              ), 
                              onPressed: () { 
                                  if(_emailController.text.toString().isEmpty){
                                    setState(() {
                                      _errorEmail = true;
                                    });
                                  }
                                  editEmail();
                                  
                              },
                
                            ),
                          ): 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 150,
                        ),
                        child:Text(
                        user.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                          ),),
                        IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditEmail = !_isEditEmail;
                          });
                          
                        },
                        icon: const Icon(Icons.edit_outlined,
                        ),
                    )    
                    
                  ],
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  _isEditPassword ? 
                  Column(
                  children: [
                    CustomTextField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !_seeCurrentPassword,
                            maxLength: 64,
                            hint: AppLocalizations.of(context).enter_current_password,
                            errorText: _errorPassoword ? AppLocalizations.of(context).password_dont_match : null,
                             suffixIcon: IconButton(
                                icon: Icon(
                                  _seeCurrentPassword 
                                  ? Icons.visibility_off_outlined 
                                  : Icons.visibility_outlined
                                ), 
                                onPressed: () { 
                                    setState(() {
                                      _seeCurrentPassword = !_seeCurrentPassword;
                                  
                                    });
                                },
                                  
                              ),
                           
                          
                          ),
                          const SizedBox(height: 10,),
                     CustomTextField(
                            controller: _newPasswordController,
                            obscureText: !_seePassword,
                            keyboardType: TextInputType.visiblePassword,
                            errorText: _errorPassoword ? AppLocalizations.of(context).password_dont_match : null,
                            maxLength: 64,
                            hint: AppLocalizations.of(context).enter_new_password,
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
                          const SizedBox(height: 10,),
                    CustomButton(text: AppLocalizations.of(context).save, onTap: () {
                    
                    if(_passwordController.text.toString() != _newPasswordController.text.toString()){
                      setState(() {
                        _errorPassoword = true;
                        _seeCurrentPassword = true;
                        _seePassword = true;
                      });
                      return;
                    }
                    
                     editPassword();
                          setState(() {
                            _isEditPassword = false;
                          }); 
                    },),
                  
                  ]
                                    ) :
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).edit_password,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                          ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditPassword = !_isEditPassword;
                          });
                          
                        },
                        icon: const Icon(Icons.edit_outlined,
                        ),
                    )    
                    
                  ],
                  ),
                  
                  const SizedBox(
                    height: 24,
                  ),
                            
                  GestureDetector(
                            onTap: () {
                              _clearSharedPreferences();
                              
                            },
                            child: Text(
                              AppLocalizations.of(context).signout,
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.black54,
                              ),
                            ),
                        ),
                          const SizedBox(height: 50),
                          GestureDetector(
                            onTap: () {


                              showDialog(
					  context: context,
					  builder: (BuildContext context) {
						return AlertDialog(
						  contentPadding: const EdgeInsets.all(18),
						  shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(4), // Defina o valor desejado, 0 para bordas retas
						  ),
						  title: Text(AppLocalizations.of(context).are_you_sure_want_delete),
						  actions: [
							TextButton(
							  onPressed: () {
								deleteAccount(user.id);
								Navigator.pop(context); // Fecha o AlertDialog
							  },
							  child: Text(AppLocalizations.of(context).yes, style: const TextStyle(color: Colors.redAccent),),
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
                            child: Text(
                              AppLocalizations.of(context).delete_account,
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.redAccent,
                              ),
                            ),
                        ),
                  
                  
                  
                  
                  
                  
                  
                  
                  
                
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Erro ao carregar dados: ${snapshot.error}');
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

Future<User> fetchUserData() async {
    try {
      var url = Uri.parse(Api.userData);
      final response = await http.get(
        url,
        headers: {
          'Authorization': (await getToken()) ?? '',
          'Content-Type': 'application/json; charset=utf-8',
        },
    );

    if (response.statusCode == 200) {

      final data = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      return User.fromJson(data);
    } else {
      // Se a resposta não for bem-sucedida, você pode lançar uma exceção ou retornar null, dependendo do que faz sentido para o seu caso.
      throw Exception('Erro na solicitação HTTP: ${response.body}');
    }
    } catch (error) {
      // Captura e trata qualquer exceção que possa ocorrer durante o processo
      rethrow; // Re-lança a exceção para que a função chamadora também possa lidar com ela
    }
  }


  Future editName() async {
    
    
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
                            
    final Map<String, String> body;
      var url = Uri.parse(Api.userUpdate);
      body = {
          'name': _nameController.text.trim(),
        };
      
      final encodedBody = jsonEncode(body);

      var response = await http.patch(
        url,  
        headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
        },
        body: encodedBody
      );
      setState(() {
        _isEditName = false;
      });
      
      if(response.statusCode == 200) {
        Navigator.of(context).pop();
        
        CustomSnackbar.show(context, 
        AppLocalizations.of(context).name_changed, 
        Colors.grey.shade500);
        
      } else {
        
        Navigator.of(context).pop(false);
        
        CustomSnackbar.show(context, 
        AppLocalizations.of(context).error_ocurred, 
        Colors.redAccent);
        
      }
  }
  
  Future editEmail() async {
    
    
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
                            
    final Map<String, String> body;
      var url = Uri.parse(Api.userUpdate);
      body = {
          'email': _emailController.text.trim(),
        };
      
      final encodedBody = jsonEncode(body);

      var response = await http.patch(
        url,  
        headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
        },
        body: encodedBody
      );
      setState(() {
        _isEditEmail = false;
      });
      
      if(response.statusCode == 200) {
        Navigator.of(context).pop();
        CustomSnackbar.show(context, 
        AppLocalizations.of(context).email_changed, 
        Colors.grey.shade500);
      
      } else {
        
        Navigator.of(context).pop(false);
        
        CustomSnackbar.show(context, 
        AppLocalizations.of(context).error_ocurred, 
        Colors.redAccent);
        
      }
  }


  Future editPassword() async {
    
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
                            
    final Map<String, String> body;
      var url = Uri.parse(Api.userUpdatePassword);
      body = {
          'password': _passwordController.text.trim(),
          'new_password': _newPasswordController.text.trim(),
        };
      
      final encodedBody = jsonEncode(body);

      var response = await http.put(
        url,  
        headers: {
          'Authorization': (await getToken() ?? ''),
          'Content-Type': 'application/json; charset=utf-8', 
        },
        body: encodedBody
      );
      setState(() {
        _isEditPassword = false;
      });
      
      if(response.statusCode == 200) {
        _passwordController.text = '';
        _newPasswordController.text = '';
        Navigator.of(context).pop();
        
         CustomSnackbar.show(context, 
        AppLocalizations.of(context).password_changed, 
        Colors.grey.shade500);
        
      } else {
        
        Navigator.of(context).pop(false);
         CustomSnackbar.show(context, 
        AppLocalizations.of(context).error_ocurred, 
        Colors.redAccent);
      }
  }


  Future deleteAccount(String id) async {

    var url = Uri.parse('${Api.userData}$id/');
    
    
    var response = await http.delete(
      url, 
      headers: {
        'Authorization': (await getToken() ?? ''),
        'Content-Type': 'application/json; charset=utf-8', 
      },
    );

	  if(response.statusCode == 204) {  
	    _clearSharedPreferences();
	  }
  }



}

class UserData {
  final String name;
  final String email;
  
  
  UserData({
    this.name = '',
    this.email = '',
    
  });

  bool get isEmpty =>
      name.isEmpty && 
      email.isEmpty;
}