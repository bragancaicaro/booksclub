
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
 final TextEditingController controller;
 final String hint;
 final bool obscureText;
 final TextInputType keyboardType;
 final int maxLength;
 final String? errorText;
 final Widget? suffixIcon;
 final Widget? prefixIcon;
 final int? maxLines;
 const CustomTextField({
    super.key, 
    required this.controller, 
    required this.hint, 
    required this.obscureText, 
    required this.keyboardType, 
    required this.maxLength,
    this.errorText,
    this.suffixIcon, 
    this.prefixIcon, 
    this.maxLines, 
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: '',
        errorText: errorText,
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent) 
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200) 
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintMaxLines: maxLines,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey) 
        ),
        hintText: hint,
      ),
      
      
    );
  }
}
