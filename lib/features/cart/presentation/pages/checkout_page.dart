import 'package:abdoul_express/core/widgets.dart';
import 'package:abdoul_express/core/app_state.dart';
import 'package:abdoul_express/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:abdoul_express/features/auth/presentation/cubit/auth_state.dart';
import 'package:abdoul_express/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:abdoul_express/features/payment/presentation/pages/payment_method_selection_page.dart';
import 'package:abdoul_express/features/location/presentation/pages/location_selection_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  String? _selectedLocation;
  double? _latitude;
  double? _longitude;

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('💳 [CheckoutPage] $message');
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final app = AppState.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(
              label: 'Nom complet',
              controller: _name,
              icon: Icons.person,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Veuillez entrer votre nom complet';
                }
                if (v.trim().length < 3) {
                  return 'Le nom doit contenir au moins 3 caractères';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),
            _field(
              label: 'Adresse complémentaire (optionnel)',
              controller: _address,
              icon: Icons.home,
              validator: null,
            ),
            const SizedBox(height: 12),

            // Niger phone field
            NigerPhoneField(controller: _phone, label: 'Téléphone'),

            const SizedBox(height: 12),

            // Notes field
            _field(
              label: 'Notes de livraison (optionnel)',
              controller: _notes,
              icon: Icons.note_outlined,
              validator: null,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            ),

            const SizedBox(height: 12),

            // Location selection button
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: InkWell(
                onTap: _selectLocation,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedLocation ??
                                  'Ajouter ma position de livraison',
                              style: TextStyle(
                                fontWeight: _selectedLocation != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: _selectedLocation != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (_selectedLocation != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Appuyez pour modifier',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colorScheme.outline),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 34),

            _summary(app.total),
            const SizedBox(height: 24),
            PrimaryButton(
              icon: Icons.payment,
              label: 'Choisir le mode de paiement',
              onPressed: () {
                _logDebug('User clicked payment method selection button');

                if (_formKey.currentState!.validate()) {
                  if (_selectedLocation == null) {
                    _logDebug('⚠️ Validation failed: No delivery location selected');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Veuillez sélectionner votre position de livraison',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final deliveryInfo = {
                    'name': _name.text,
                    'address': _selectedLocation!,
                    'additionalInfo': _address.text,
                    'phone': '+227${_phone.text}',
                    'notes': _notes.text,
                    'latitude': _latitude,
                    'longitude': _longitude,
                  };

                  _logDebug('✅ Validation passed. Proceeding to payment method selection');
                  _logDebug('Delivery info: ${deliveryInfo['name']}, ${deliveryInfo['phone']}, ${deliveryInfo['address']}');
                  _logDebug('Total amount: ${app.total.toStringAsFixed(0)} F CFA');

                  // Navigate to payment method selection
                  final authState = context.read<AuthCubit>().state;
                  final userId = authState is AuthAuthenticated
                      ? (authState.user?.id ?? 'guest')
                      : 'guest';

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<PaymentCubit>(),
                        child: PaymentMethodSelectionPage(
                          orderId:
                              'ORD-${DateTime.now().millisecondsSinceEpoch}',
                          userId: userId,
                          totalAmount: app.total,
                          deliveryInfo: deliveryInfo,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LocationSelectionPage()));

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedLocation = result['location'] as String;
        _latitude = result['latitude'] as double;
        _longitude = result['longitude'] as double;
      });
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _summary(double total) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.shopping_bag, color: cs.primary),
          const SizedBox(width: 12),
          const Expanded(child: Text('Total à payer')),
          Text(
            '${total.toStringAsFixed(0)} F CFA',
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
