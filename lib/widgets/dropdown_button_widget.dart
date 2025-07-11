import 'package:flutter/material.dart';

class DropdownButtonWidget extends StatefulWidget {
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String?>? onChanged;

  const DropdownButtonWidget({
    super.key, 
    required this.items,
    required this.selectedItem,
    this.onChanged,
  });
  
  @override
  State<StatefulWidget> createState() => _DropdownButtonWidgetState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFf0f2f5),
        borderRadius: BorderRadius.circular(24)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
        value: widget.selectedItem,
          items: widget.items
            .map((name) => DropdownMenuItem<String>(
              value: name, 
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600
                ),
              ), 
            ))
            .toList(), 
          onChanged: widget.onChanged,
          isDense: true,
          dropdownColor: Color(0xFFf0f2f5),
          borderRadius: BorderRadius.circular(24),
          padding: EdgeInsets.only(left: 10),
        )
      ),
    );
  }
}
