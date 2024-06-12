import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();

}

class _StartPageState extends State<StartPage> {

  @override
  initState() {

    super.initState();
    
     virifyUser().then((haveUser) {
      if(haveUser){
       context.go('/tabs');
      } else {
        context.go('/login');
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: Text(
            AppLocalizations.of(context).app_name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 32,
                ),
          ),
        ),
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