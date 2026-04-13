import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abdoul_express/model/payment.dart';

// Payment State
class PaymentState extends Equatable {
  final String? selectedMethodId;
  final List<Payment> payments;
  final bool isLoading;
  final String? error;
  final Payment? currentPayment;

  const PaymentState({
    this.selectedMethodId,
    this.payments = const [],
    this.isLoading = false,
    this.error,
    this.currentPayment,
  });

  @override
  List<Object?> get props => [
    selectedMethodId,
    payments,
    isLoading,
    error,
    currentPayment,
  ];

  PaymentState copyWith({
    String? selectedMethodId,
    List<Payment>? payments,
    bool? isLoading,
    String? error,
    Payment? currentPayment,
  }) {
    return PaymentState(
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPayment: currentPayment ?? this.currentPayment,
    );
  }
}

// Payment Cubit
class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(const PaymentState());

  void selectPaymentMethod(String methodId) {
    emit(state.copyWith(selectedMethodId: methodId));
  }

  Future<void> createPayment({
    required String orderId,
    required String userId,
    required double amount,
    required String methodId,
    String? transactionRef,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final payment = Payment(
        id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        userId: userId,
        amount: amount,
        methodId: methodId,
        status: PaymentStatus.pending,
        transactionRef: transactionRef,
        createdAt: DateTime.now(),
      );

      final updatedPayments = [...state.payments, payment];
      emit(
        state.copyWith(
          payments: updatedPayments,
          currentPayment: payment,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> uploadReceipt({
    required String paymentId,
    required String receiptPath,
    required String description,
    String? transactionRef,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate upload
      await Future.delayed(const Duration(seconds: 2));

      final paymentIndex = state.payments.indexWhere((p) => p.id == paymentId);
      if (paymentIndex != -1) {
        final updatedPayment = state.payments[paymentIndex].copyWith(
          receiptUrl: receiptPath,
          description: description,
          transactionRef: transactionRef,
          status: PaymentStatus.processing,
        );

        final updatedPayments = List<Payment>.from(state.payments);
        updatedPayments[paymentIndex] = updatedPayment;

        emit(
          state.copyWith(
            payments: updatedPayments,
            currentPayment: updatedPayment,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> loadPaymentHistory(String userId) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data for demonstration
      final mockPayments = [
        Payment(
          id: 'PAY-001',
          orderId: 'ORD-001',
          userId: userId,
          amount: 25000,
          methodId: 'wave',
          status: PaymentStatus.verified,
          transactionRef: 'WAVE123456',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          verifiedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Payment(
          id: 'PAY-002',
          orderId: 'ORD-002',
          userId: userId,
          amount: 15000,
          methodId: 'manual_receipt',
          status: PaymentStatus.processing,
          receiptUrl: '/path/to/receipt.jpg',
          description: 'Transfert bancaire effectué',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];

      emit(state.copyWith(payments: mockPayments, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
