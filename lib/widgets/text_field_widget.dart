import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  
  const TextFieldWidget({
    super.key, 
    required this.hintText
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 12
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          size: 20,
        ),
        prefixIconColor: Colors.grey[400],
        hintText: hintText,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(14)
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(14)
        ),
        fillColor: Color(0xFFf0f2f5),
      ),
    );
  }
}