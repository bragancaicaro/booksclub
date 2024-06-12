import 'package:booksclub/app/ui/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({
    Key? key,
    this.radius = 8,
    }) : super(key: key);
  final double radius;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(Duration(milliseconds: 150)).then((value) {
                  return rootBundle.loadString('assets/privacy.md');
              }), 
              builder: ((context, snapshot) {
              if(snapshot.hasData){
                return Markdown(
                  data: snapshot.data!,
                  );
              }
              return Center(child: CircularProgressIndicator(),);
            })),
          ),
          

          CustomButton(text: AppLocalizations.of(context).ok, onTap: () {
            Navigator.pop(context);
          },)
        ],
      ),    
    
    );
  }
}