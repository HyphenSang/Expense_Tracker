import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class SubButton extends StatelessWidget {
  const SubButton({super.key, required this.text, required this.onPressed, this.isLoading = false});
  
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final Size media = MediaQuery.sizeOf(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: isLoading ? null : onPressed,
        child: Container(
          height: media.height * 0.06,
          width: media.width * 0.9,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: media.height * 0.02,
                          color: Colors.white,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}