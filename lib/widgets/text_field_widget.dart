import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String?>? onChanged;
  final Widget? suffixWidget;

  const TextFieldWidget({
    super.key, 
    required this.hintText,
    required this.onChanged,
    this.suffixWidget,
  });

  @override
  State<StatefulWidget> createState() => TextFieldWidgetState();
}

class TextFieldWidgetState extends State<TextFieldWidget> { 
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onChanged,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^\d+\.?\d{0,1}"))],
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
        hintText: widget.hintText,
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
        suffixIcon: widget.suffixWidget,
      ),
    );
  }
}