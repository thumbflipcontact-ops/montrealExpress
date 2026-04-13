import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable phone input field with Niger country code (+227) and flag
class NigerPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String label;
  final bool enabled;

  const NigerPhoneField({
    super.key,
    required this.controller,
    this.validator,
    this.label = 'Téléphone',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8), // Niger phone numbers are 8 digits
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: '90 12 34 56',
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Niger flag emoji
              const Text('🇳🇪', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                '+227',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 8),
            ],
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre numéro';
            }
            if (value.length != 8) {
              return 'Le numéro doit contenir 8 chiffres';
            }
            return null;
          },
    );
  }

  /// Get the full phone number with country code
  String getFullPhoneNumber() {
    return '+227${controller.text}';
  }

  /// Format phone number for display (90 12 34 56)
  static String formatPhoneNumber(String phone) {
    if (phone.length != 8) return phone;
    return '${phone.substring(0, 2)} ${phone.substring(2, 4)} ${phone.substring(4, 6)} ${phone.substring(6, 8)}';
  }
}
