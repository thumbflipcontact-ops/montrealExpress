part of 'address_cubit.dart';

enum _AddressStatus { initial, loading, loaded, error }

class AddressState extends Equatable {
  const AddressState._({
    required this.addresses,
    required this.status,
    this.error,
    this.isSaving = false,
  });

  const AddressState.initial()
    : this._(addresses: const [], status: _AddressStatus.initial);

  const AddressState.loading()
    : this._(addresses: const [], status: _AddressStatus.loading);

  const AddressState.loaded(List<Address> addresses)
    : this._(addresses: addresses, status: _AddressStatus.loaded);

  const AddressState.error(String? error)
    : this._(addresses: const [], status: _AddressStatus.error, error: error);

  final List<Address> addresses;
  final _AddressStatus status;
  final String? error;
  final bool isSaving;

  bool get isInitial => status == _AddressStatus.initial;
  bool get isLoading => status == _AddressStatus.loading;
  bool get isLoaded => status == _AddressStatus.loaded;
  bool get hasError => status == _AddressStatus.error;

  Address? get defaultAddress {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  AddressState copyWith({
    List<Address>? addresses,
    _AddressStatus? status,
    String? error,
    bool? isSaving,
  }) {
    return AddressState._(
      addresses: addresses ?? this.addresses,
      status: status ?? this.status,
      error: error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [addresses, status, error, isSaving];
}
