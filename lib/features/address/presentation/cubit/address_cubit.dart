import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:abdoul_express/model/address.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(const AddressState.initial());

  Future<void> loadAddresses(String userId) async {
    try {
      emit(const AddressState.loading());

      // Simulate API call - replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - replace with actual data from repository
      final addresses = <Address>[];

      emit(AddressState.loaded(addresses));
    } catch (e) {
      emit(AddressState.error(e.toString()));
    }
  }

  Future<void> addAddress(Address address) async {
    try {
      emit(state.copyWith(isSaving: true));

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedAddresses = List<Address>.from(state.addresses)
        ..add(address);
      emit(AddressState.loaded(updatedAddresses));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isSaving: false));
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      emit(state.copyWith(isSaving: true));

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedAddresses = state.addresses.map((a) {
        return a.id == address.id ? address : a;
      }).toList();

      emit(AddressState.loaded(updatedAddresses));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isSaving: false));
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      emit(state.copyWith(isSaving: true));

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedAddresses = state.addresses
          .where((a) => a.id != addressId)
          .toList();
      emit(AddressState.loaded(updatedAddresses));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isSaving: false));
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      emit(state.copyWith(isSaving: true));

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedAddresses = state.addresses.map((a) {
        return a.copyWith(isDefault: a.id == addressId);
      }).toList();

      emit(AddressState.loaded(updatedAddresses));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isSaving: false));
    }
  }
}
