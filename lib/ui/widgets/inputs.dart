import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oratio_app/ui/themes.dart';

class TextFieldd extends StatefulWidget {
  const TextFieldd(
      {super.key,
      required this.labeltext,
      required this.hintText,
      required this.controller,
      required this.isPassword,
      this.inputType = TextInputType.text,
      this.labelTextStyle,
      this.inputTextStyle,
      this.decoration,
      this.onChange,
      this.bg});
  final String labeltext;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType inputType;
  final TextStyle? labelTextStyle;
  final TextStyle? inputTextStyle;
  final InputDecoration? decoration;
  final Color? bg;
  final Function(String)? onChange;
  @override
  State<TextFieldd> createState() => _TextFielddState();
}

class _TextFielddState extends State<TextFieldd> {
  bool isvisible = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labeltext,
            style: widget.labelTextStyle ??
                TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.w600),
          ),
          const Gap(5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: AppColors.dimGray,
                borderRadius: BorderRadius.circular(5)),
            child: TextField(
              onChanged: widget.onChange,

              keyboardType: widget.inputType,
              obscureText: widget.isPassword ? isvisible : false,
              style: widget.inputTextStyle ??
                  TextStyle(
                    color: Colors.black.withOpacity(0.8),
                  ),
              controller: widget.controller,
              // cursorColor: AppColors.textColor,
              decoration: widget.decoration?.copyWith(
                    hintText: widget.hintText,
                  ) ??
                  InputDecoration(
                      hintStyle: TextStyle(
                          color: AppColors.gray, fontWeight: FontWeight.normal),
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      suffixIcon: widget.isPassword
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  isvisible = !isvisible;
                                });
                              },
                              child: Icon(
                                !isvisible
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                color: AppColors.dimGray,
                                size: 17,
                              ),
                            )
                          : null),
            ),
          )
        ],
      ),
    );
  }
}

class SubmitButtonV1 extends StatelessWidget {
  const SubmitButtonV1(
      {super.key,
      this.isOutline = false,
      this.outlineColor = Colors.white,
      required this.radius,
      required this.backgroundcolor,
      required this.child,
      this.height = 50,
      this.ontap});
  final double radius;
  final Color backgroundcolor;
  final Widget child;
  final double height;
  final bool isOutline;
  final Color outlineColor;
  final Function()? ontap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ontap?.call();
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border:
              isOutline ? Border.all(color: outlineColor, width: 1.5) : null,
          color: backgroundcolor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(child: child),
      ),
    );
  }
}
