class DeliveryTimeSlot {
  final String id;
  final String timeRange;
  final DateTime startTime;
  final DateTime endTime;
  final double? additionalFee;
  final bool isAvailable;
  final int? maxOrders;
  final int? currentOrders;

  const DeliveryTimeSlot({
    required this.id,
    required this.timeRange,
    required this.startTime,
    required this.endTime,
    this.additionalFee,
    required this.isAvailable,
    this.maxOrders,
    this.currentOrders,
  });

  String get feeDisplay => additionalFee != null ? '+${additionalFee!.toStringAsFixed(0)} F' : 'Gratuit';

  bool get isFullyBooked => maxOrders != null && currentOrders != null && currentOrders! >= maxOrders!;

  double get availabilityPercentage => maxOrders != null && currentOrders != null
      ? (currentOrders! / maxOrders!) * 100
      : 0;

  DeliveryTimeSlot copyWith({
    String? id,
    String? timeRange,
    DateTime? startTime,
    DateTime? endTime,
    double? additionalFee,
    bool? isAvailable,
    int? maxOrders,
    int? currentOrders,
  }) {
    return DeliveryTimeSlot(
      id: id ?? this.id,
      timeRange: timeRange ?? this.timeRange,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      additionalFee: additionalFee ?? this.additionalFee,
      isAvailable: isAvailable ?? this.isAvailable,
      maxOrders: maxOrders ?? this.maxOrders,
      currentOrders: currentOrders ?? this.currentOrders,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timeRange': timeRange,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'additionalFee': additionalFee,
      'isAvailable': isAvailable,
      'maxOrders': maxOrders,
      'currentOrders': currentOrders,
    };
  }

  factory DeliveryTimeSlot.fromJson(Map<String, dynamic> json) {
    return DeliveryTimeSlot(
      id: json['id'],
      timeRange: json['timeRange'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      additionalFee: json['additionalFee']?.toDouble(),
      isAvailable: json['isAvailable'],
      maxOrders: json['maxOrders'],
      currentOrders: json['currentOrders'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryTimeSlot &&
        other.id == id &&
        other.timeRange == timeRange &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.additionalFee == additionalFee &&
        other.isAvailable == isAvailable &&
        other.maxOrders == maxOrders &&
        other.currentOrders == currentOrders;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timeRange.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        additionalFee.hashCode ^
        isAvailable.hashCode ^
        maxOrders.hashCode ^
        currentOrders.hashCode;
  }

  @override
  String toString() {
    return 'DeliveryTimeSlot(id: $id, timeRange: $timeRange, startTime: $startTime, endTime: $endTime, additionalFee: $additionalFee, isAvailable: $isAvailable, maxOrders: $maxOrders, currentOrders: $currentOrders)';
  }
}

// Helper function to generate time slots for a specific date
List<DeliveryTimeSlot> generateTimeSlotsForDate(DateTime date) {
  final List<DeliveryTimeSlot> slots = [];
  final baseDate = DateTime(date.year, date.month, date.day);

  // Morning slots (8:00 - 12:00)
  slots.addAll([
    DeliveryTimeSlot(
      id: '${date.millisecondsSinceEpoch}_morning_1',
      timeRange: '08:00 - 10:00',
      startTime: baseDate.add(const Duration(hours: 8)),
      endTime: baseDate.add(const Duration(hours: 10)),
      isAvailable: true,
      maxOrders: 5,
      currentOrders: 2,
    ),
    DeliveryTimeSlot(
      id: '${date.millisecondsSinceEpoch}_morning_2',
      timeRange: '10:00 - 12:00',
      startTime: baseDate.add(const Duration(hours: 10)),
      endTime: baseDate.add(const Duration(hours: 12)),
      additionalFee: 500,
      isAvailable: true,
      maxOrders: 5,
      currentOrders: 1,
    ),
  ]);

  // Afternoon slots (12:00 - 18:00)
  slots.addAll([
    DeliveryTimeSlot(
      id: '${date.millisecondsSinceEpoch}_afternoon_1',
      timeRange: '12:00 - 14:00',
      startTime: baseDate.add(const Duration(hours: 12)),
      endTime: baseDate.add(const Duration(hours: 14)),
      isAvailable: true,
      maxOrders: 8,
      currentOrders: 6,
    ),
    DeliveryTimeSlot(
      id: '${date.millisecondsSinceEpoch}_afternoon_2',
      timeRange: '14:00 - 16:00',
      startTime: baseDate.add(const Duration(hours: 14)),
      endTime: baseDate.add(const Duration(hours: 16)),
      additionalFee: 500,
      isAvailable: true,
      maxOrders: 8,
      currentOrders: 3,
    ),
    DeliveryTimeSlot(
      id: '${date.millisecondsSinceEpoch}_afternoon_3',
      timeRange: '16:00 - 18:00',
      startTime: baseDate.add(const Duration(hours: 16)),
      endTime: baseDate.add(const Duration(hours: 18)),
      additionalFee: 1000,
      isAvailable: true,
      maxOrders: 6,
      currentOrders: 2,
    ),
  ]);

  // Evening slots (18:00 - 20:00)
  slots.add(DeliveryTimeSlot(
    id: '${date.millisecondsSinceEpoch}_evening',
    timeRange: '18:00 - 20:00',
    startTime: baseDate.add(const Duration(hours: 18)),
    endTime: baseDate.add(const Duration(hours: 20)),
    additionalFee: 1500,
    isAvailable: true,
    maxOrders: 4,
    currentOrders: 0,
  ));

  return slots;
}