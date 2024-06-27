import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final GestureTapCallback onTap;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38),
            color: _isHovered ? Colors.orange.withOpacity(0.8) : Color(0xFF1B2E52),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
