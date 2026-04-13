import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model/delivery_method.dart';
import '../../../../model/delivery_time_slot.dart';
import '../cubit/orders_cubit.dart';

class DeliveryTimeSlotSelector extends StatefulWidget {
  final DeliveryMethod deliveryMethod;
  final DeliveryTimeSlot? initialSlot;
  final ValueChanged<DeliveryTimeSlot?> onSlotSelected;

  const DeliveryTimeSlotSelector({
    super.key,
    required this.deliveryMethod,
    this.initialSlot,
    required this.onSlotSelected,
  });

  @override
  State<DeliveryTimeSlotSelector> createState() => _DeliveryTimeSlotSelectorState();
}

class _DeliveryTimeSlotSelectorState extends State<DeliveryTimeSlotSelector> {
  DateTime _selectedDate = DateTime.now();
  List<DeliveryTimeSlot> _availableSlots = [];
  DeliveryTimeSlot? _selectedSlot;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.initialSlot;
    _loadTimeSlots();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Choisir un créneau de livraison',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.deliveryMethod.estimatedHours > 0) ...[
              _buildDateSelector(context),
              const SizedBox(height: 16),
              _buildTimeSlots(context),
            ] else ...[
              _buildPickupInfo(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de livraison',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = _isSameDate(date, _selectedDate);
              final isToday = _isSameDate(date, DateTime.now());
              final isTomorrow = _isSameDate(date, DateTime.now().add(const Duration(days: 1)));

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedSlot = null;
                    _loadTimeSlots();
                  });
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday
                            ? 'Aujourd\'hui'
                            : isTomorrow
                                ? 'Demain'
                                : _getWeekdayName(date.weekday),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _getMonthName(date.month),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white70 : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucun créneau disponible pour cette date. Veuillez sélectionner une autre date.',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Créneaux disponibles',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _availableSlots.length,
          itemBuilder: (context, index) {
            final slot = _availableSlots[index];
            final isSelected = _selectedSlot?.id == slot.id;

            return GestureDetector(
              onTap: slot.isAvailable
                  ? () {
                      setState(() {
                        _selectedSlot = slot;
                      });
                      widget.onSlotSelected(slot);
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: slot.isAvailable
                      ? isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                          : colorScheme.surface
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: Border.all(
                    color: slot.isAvailable
                        ? isSelected
                            ? Theme.of(context).primaryColor
                            : colorScheme.outlineVariant
                        : colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slot.timeRange,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: slot.isAvailable
                                ? isSelected
                                    ? Theme.of(context).primaryColor
                                    : colorScheme.onSurface
                                : colorScheme.onSurface.withValues(alpha: 0.38),
                          ),
                        ),
                        if (slot.additionalFee != null && slot.additionalFee! > 0)
                          Text(
                            '+${slot.additionalFee!.toStringAsFixed(0)} F',
                            style: TextStyle(
                              fontSize: 10,
                              color: slot.isAvailable
                                  ? Colors.orange[700]
                                  : colorScheme.onSurface.withValues(alpha: 0.38),
                            ),
                          ),
                      ],
                    ),
                    if (!slot.isAvailable)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Complet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (isSelected)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPickupInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.store, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Retrait en magasin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Disponible dès aujourd\'hui pendant les heures d\'ouverture',
                      style: TextStyle(color: Colors.green[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lun - Sam: 8h - 20h\nDim: 9h - 18h',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _getWeekdayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return months[month - 1];
  }

  Future<void> _loadTimeSlots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cubit = context.read<OrdersCubit>();
      final slots = await cubit.getAvailableDeliveryTimeSlots(_selectedDate);

      setState(() {
        _availableSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}