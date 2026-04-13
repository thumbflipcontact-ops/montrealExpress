import 'package:hive/hive.dart';
import 'package:abdoul_express/model/order.dart';
import 'package:abdoul_express/model/delivery_address.dart';
import 'package:abdoul_express/models/transaction.dart';
import 'package:abdoul_express/model/address.dart';

/// Abstract base class for local storage services
abstract class LocalStorageService<T> {
  Future<void> save(T item);
  Future<void> saveAll(List<T> items);
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<List<T>> getAllByUserId(String userId);
  Future<void> delete(String id);
  Future<void> deleteAll();
  Future<void> update(T item);
  Future<bool> exists(String id);
  Future<int> count();
  Future<void> clearAll();
}

/// Local storage service for Orders
class OrderLocalStorageService extends LocalStorageService<Order> {
  static const String _boxName = 'orders';

  Future<Box<Order>> _getBox() async {
    return await Hive.openBox<Order>(_boxName);
  }

  @override
  Future<void> save(Order order) async {
    final box = await _getBox();
    await box.put(order.id, order);
  }

  @override
  Future<void> saveAll(List<Order> orders) async {
    final box = await _getBox();
    final Map<String, Order> orderMap = {};
    for (final order in orders) {
      orderMap[order.id] = order;
    }
    await box.putAll(orderMap);
  }

  @override
  Future<Order?> getById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  @override
  Future<List<Order>> getAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<List<Order>> getAllByUserId(String userId) async {
    final box = await _getBox();
    return box.values
        .where((order) => order.userId == userId)
        .toList();
  }

  @override
  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<void> deleteAll() async {
    final box = await _getBox();
    await box.clear();
  }

  @override
  Future<void> update(Order order) async {
    await save(order);
  }

  @override
  Future<bool> exists(String id) async {
    final box = await _getBox();
    return box.containsKey(id);
  }

  @override
  Future<int> count() async {
    final box = await _getBox();
    return box.length;
  }

  @override
  Future<void> clearAll() async {
    await deleteAll();
  }

  // Additional order-specific methods
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final box = await _getBox();
    return box.values
        .where((order) => order.status == status)
        .toList();
  }

  Future<List<Order>> getUnsyncedOrders() async {
    final box = await _getBox();
    return box.values
        .where((order) => !order.isSynced)
        .toList();
  }

  Future<void> markAsSynced(String orderId) async {
    final box = await _getBox();
    final order = box.get(orderId);
    if (order != null) {
      final updatedOrder = order.copyWith(isSynced: true);
      await box.put(orderId, updatedOrder);
    }
  }
}

/// Local storage service for Delivery Addresses
class AddressLocalStorageService extends LocalStorageService<DeliveryAddress> {
  static const String _boxName = 'addresses';

  Future<Box<DeliveryAddress>> _getBox() async {
    return await Hive.openBox<DeliveryAddress>(_boxName);
  }

  @override
  Future<void> save(DeliveryAddress address) async {
    final box = await _getBox();
    await box.put(address.id, address);
  }

  @override
  Future<void> saveAll(List<DeliveryAddress> addresses) async {
    final box = await _getBox();
    final Map<String, DeliveryAddress> addressMap = {};
    for (final address in addresses) {
      addressMap[address.id] = address;
    }
    await box.putAll(addressMap);
  }

  @override
  Future<DeliveryAddress?> getById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  @override
  Future<List<DeliveryAddress>> getAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<List<DeliveryAddress>> getAllByUserId(String userId) async {
    // This would require adding userId to DeliveryAddress model
    // For now, return all addresses
    return getAll();
  }

  @override
  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<void> deleteAll() async {
    final box = await _getBox();
    await box.clear();
  }

  @override
  Future<void> update(DeliveryAddress address) async {
    await save(address);
  }

  @override
  Future<bool> exists(String id) async {
    final box = await _getBox();
    return box.containsKey(id);
  }

  @override
  Future<int> count() async {
    final box = await _getBox();
    return box.length;
  }

  @override
  Future<void> clearAll() async {
    await deleteAll();
  }

  // Additional address-specific methods
  Future<DeliveryAddress?> getDefaultAddress() async {
    final box = await _getBox();
    return box.values
        .where((address) => address.isDefault)
        .firstOrNull;
  }

  Future<void> setDefaultAddress(String addressId) async {
    final box = await _getBox();

    // Unset all current default addresses
    for (final address in box.values) {
      if (address.isDefault) {
        final updatedAddress = address.copyWith(isDefault: false, updatedAt: DateTime.now());
        await box.put(address.id, updatedAddress);
      }
    }

    // Set the new default address
    final address = box.get(addressId);
    if (address != null) {
      final updatedAddress = address.copyWith(isDefault: true, updatedAt: DateTime.now());
      await box.put(addressId, updatedAddress);
    }
  }
}

/// Local storage service for Transactions
class TransactionLocalStorageService extends LocalStorageService<Transaction> {
  static const String _boxName = 'transactions';

  Future<Box<Transaction>> _getBox() async {
    return await Hive.openBox<Transaction>(_boxName);
  }

  @override
  Future<void> save(Transaction transaction) async {
    final box = await _getBox();
    await box.put(transaction.id, transaction);
  }

  @override
  Future<void> saveAll(List<Transaction> transactions) async {
    final box = await _getBox();
    final Map<String, Transaction> transactionMap = {};
    for (final transaction in transactions) {
      transactionMap[transaction.id] = transaction;
    }
    await box.putAll(transactionMap);
  }

  @override
  Future<Transaction?> getById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  @override
  Future<List<Transaction>> getAll() async {
    final box = await _getBox();
    // Return transactions sorted by creation date (newest first)
    final transactions = box.values.toList();
    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return transactions;
  }

  @override
  Future<List<Transaction>> getAllByUserId(String userId) async {
    final box = await _getBox();
    return box.values
        .where((transaction) => transaction.customerId == userId)
        .toList();
  }

  @override
  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<void> deleteAll() async {
    final box = await _getBox();
    await box.clear();
  }

  @override
  Future<void> update(Transaction transaction) async {
    await save(transaction);
  }

  @override
  Future<bool> exists(String id) async {
    final box = await _getBox();
    return box.containsKey(id);
  }

  @override
  Future<int> count() async {
    final box = await _getBox();
    return box.length;
  }

  @override
  Future<void> clearAll() async {
    await deleteAll();
  }

  // Additional transaction-specific methods
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final box = await _getBox();
    return box.values
        .where((transaction) =>
            transaction.createdAt.isAfter(startDate) &&
            transaction.createdAt.isBefore(endDate))
        .toList();
  }

  Future<List<Transaction>> getUnsyncedTransactions() async {
    final box = await _getBox();
    return box.values
        .where((transaction) => !transaction.isSynced)
        .toList();
  }

  Future<double> getTotalIncome({DateTime? startDate, DateTime? endDate}) async {
    final box = await _getBox();
    final transactions = box.values.where((transaction) {
      if (!transaction.isIncome) return false;
      if (startDate != null && transaction.createdAt.isBefore(startDate)) return false;
      if (endDate != null && transaction.createdAt.isAfter(endDate)) return false;
      return true;
    });

    return transactions.fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    final box = await _getBox();
    final transactions = box.values.where((transaction) {
      if (!transaction.isExpense) return false;
      if (startDate != null && transaction.createdAt.isBefore(startDate)) return false;
      if (endDate != null && transaction.createdAt.isAfter(endDate)) return false;
      return true;
    });

    return transactions.fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  Future<void> markAsSynced(String transactionId) async {
    final box = await _getBox();
    final transaction = box.get(transactionId);
    if (transaction != null) {
      final updatedTransaction = transaction.copyWith(isSynced: true);
      await box.put(transactionId, updatedTransaction);
    }
  }
}

/// Local storage service for User Addresses
class UserAddressLocalStorageService extends LocalStorageService<Address> {
  static const String _boxName = 'addresses';

  Future<Box<Address>> _getBox() async {
    return await Hive.openBox<Address>(_boxName);
  }

  @override
  Future<void> save(Address address) async {
    final box = await _getBox();
    await box.put(address.id, address);
  }

  @override
  Future<void> saveAll(List<Address> addresses) async {
    final box = await _getBox();
    final Map<String, Address> addressMap = {};
    for (final address in addresses) {
      addressMap[address.id] = address;
    }
    await box.putAll(addressMap);
  }

  @override
  Future<Address?> getById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  @override
  Future<List<Address>> getAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<List<Address>> getAllByUserId(String userId) async {
    final box = await _getBox();
    return box.values
        .where((address) => address.userId == userId)
        .toList();
  }

  @override
  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<void> deleteAll() async {
    final box = await _getBox();
    await box.clear();
  }

  @override
  Future<void> update(Address address) async {
    await save(address);
  }

  @override
  Future<bool> exists(String id) async {
    final box = await _getBox();
    return box.containsKey(id);
  }

  @override
  Future<int> count() async {
    final box = await _getBox();
    return box.length;
  }

  @override
  Future<void> clearAll() async {
    await deleteAll();
  }

  // Additional address-specific methods
  Future<Address?> getDefaultAddress(String userId) async {
    final box = await _getBox();
    return box.values
        .where((address) => address.userId == userId && address.isDefault)
        .firstOrNull;
  }

  Future<void> setDefaultAddress(String addressId, String userId) async {
    final box = await _getBox();

    // Unset all current default addresses for this user
    for (final address in box.values) {
      if (address.userId == userId && address.isDefault) {
        final updatedAddress = address.copyWith(isDefault: false, updatedAt: DateTime.now());
        await box.put(address.id, updatedAddress);
      }
    }

    // Set the new default address
    final address = box.get(addressId);
    if (address != null && address.userId == userId) {
      final updatedAddress = address.copyWith(isDefault: true, updatedAt: DateTime.now());
      await box.put(addressId, updatedAddress);
    }
  }

  Future<List<Address>> getAddressesByCity(String city) async {
    final box = await _getBox();
    return box.values
        .where((address) => address.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  Future<List<Address>> getUnsyncedAddresses() async {
    final box = await _getBox();
    return box.values
        .where((address) => !address.isSynced)
        .toList();
  }

  Future<void> markAsSynced(String addressId) async {
    final box = await _getBox();
    final address = box.get(addressId);
    if (address != null) {
      final updatedAddress = address.copyWith(isSynced: true);
      await box.put(addressId, updatedAddress);
    }
  }
}