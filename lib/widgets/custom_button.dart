import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color? color;
  final bool disabled;

  const CustomButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.disabled = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                disabled ? Colors.grey : color ?? Color(0xFF006738),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
                color: disabled ? Colors.black : Colors.white, fontSize: 18),
          ),
        ));
  }
}
