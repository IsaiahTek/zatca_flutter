import 'package:flutter/material.dart';

class Tfield extends StatelessWidget {
  final String label;
  final double? width;
  final int? minline;
  final String? hint;
  final TextEditingController? controller;
  final bool? readOnly;
  const Tfield(
      {required this.label,
      this.width = 300,
      this.hint = '',
      this.minline = 1,
      this.controller,
      this.readOnly = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(
            height: 5,
          ),
          Container(
            color: Colors.white,
            child: TextField(
              maxLines: minline,
              style: TextStyle(fontSize: 15.0),
              controller: controller,
              readOnly: readOnly ?? false,
              decoration: InputDecoration(
                  isDense: true,
                  hintText: hint,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3))),
            ),
          )
        ],
      ),
    );
  }
}
