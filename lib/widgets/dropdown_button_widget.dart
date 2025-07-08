import 'package:flutter/material.dart';

class DropdownButtonWidget extends StatefulWidget {
  final List<String> items;

  const DropdownButtonWidget({
    super.key, 
    required this.items
  });
  
  @override
  State<StatefulWidget> createState() => _DropdownButtonWidgetState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  late String dropdownValue = widget.items.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFf0f2f5),
        borderRadius: BorderRadius.circular(24)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
        value: dropdownValue,
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
          onChanged: (String? value) { 
            setState(() {
              dropdownValue = value!;
            });
          },
          isDense: true,
          dropdownColor: Color(0xFFf0f2f5),
          borderRadius: BorderRadius.circular(24),
          padding: EdgeInsets.only(left: 10),
        )
      ),
    );
  }
}
