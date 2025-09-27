import 'package:flutter/material.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';

class PetListError extends StatelessWidget {
  final String errorMessage;
  const PetListError({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        errorMessage,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(color: CustomColors.blueDark),
      ),
    );
  }
}
