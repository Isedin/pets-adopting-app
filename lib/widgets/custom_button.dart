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
    return Platform.isIOS
        ? CupertinoButton(onPressed: onPressed, child: Text(label))
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
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CustomColors.white,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
  }
}
