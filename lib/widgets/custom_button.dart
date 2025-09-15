import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  const CustomButton({super.key, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = onPressed == null;
    return Platform.isIOS
        ? CupertinoButton(
            onPressed: onPressed,
            child: isLoading ? const CupertinoActivityIndicator(color: CustomColors.white) : Text(label),
          )
        : GestureDetector(
            onTap: onPressed,
            child: Container(
              width: MediaQuery.of(context).size.width > 600 ? 300 : 160,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: onPressed != null ? CustomColors.orange : Colors.grey,
              ),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: CustomColors.white)),
              ),
            ),
          );
  }
}
