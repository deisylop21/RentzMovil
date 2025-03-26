import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfirmButton extends StatelessWidget {
  final bool isLoading;
  final bool isSubmitting;
  final VoidCallback onPressed;

  const ConfirmButton({
    Key? key,
    required this.isLoading,
    required this.isSubmitting,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSubmitting)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.White),
                    strokeWidth: 2,
                  ),
                ),
              ),
            Text(
              isSubmitting ? "Procesando..." : "Confirmar Renta",
              style: TextStyle(fontSize: 18,
              color: AppTheme.text),
            ),
          ],
        ),
      ),
    );
  }
}