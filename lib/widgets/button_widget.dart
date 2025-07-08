import 'package:flutter/material.dart';

class ButtonWidget extends StatefulWidget {
  final String text;
  final Function() onPressed;

  const ButtonWidget({
    super.key, 
    required this.text, 
    required this.onPressed
  });

  @override
  State<StatefulWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  bool isButtonDisabled = false;
  bool isHover = false;

  void enableButton() {
    setState(() {
      isButtonDisabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isButtonDisabled ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        backgroundColor: isHover ? Color(0xFF1978e5) : Color(0xFFf0f2f5)
      ),
      onHover: (value) => setState(() {
        isHover = value;
      }),
      child: Text(
        widget.text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: isHover ? Colors.white : Colors.black87
        ),
      ),
    );
  }
}