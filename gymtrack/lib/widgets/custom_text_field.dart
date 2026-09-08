import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(
        color: AppTheme.borderGreen,
        width: 1.6,
      ),
    );

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(
        color: AppTheme.textWhite,
        fontSize: 15,
      ),
      cursorColor: AppTheme.primaryGreen,
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: AppTheme.borderGreen,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(
            widget.prefixIcon,
            color: AppTheme.borderGreen,
            size: 24,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 46,
          minHeight: 24,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.borderGreen,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(
            color: AppTheme.primaryGreen,
            width: 2.0,
          ),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.6,
          ),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
