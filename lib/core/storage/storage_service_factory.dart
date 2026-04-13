import 'package:hive/hive.dart';
import 'local_storage_service.dart';


/// Factory class for managing storage service instances
class StorageServiceFactory {
  static OrderLocalStorageService? _orderService;
  static AddressLocalStorageService? _addressService;
  static UserAddressLocalStorageService? _userAddressService;
  static TransactionLocalStorageService? _transactionService;

  // Get singleton instances of storage services
  static OrderLocalStorageService get orders {
    _orderService ??= OrderLocalStorageService();
    return _orderService!;
  }

  static AddressLocalStorageService get deliveryAddresses {
    _addressService ??= AddressLocalStorageService();
    return _addressService!;
  }

  static UserAddressLocalStorageService get userAddresses {
    _userAddressService ??= UserAddressLocalStorageService();
    return _userAddressService!;
  }

  static TransactionLocalStorageService get transactions {
    _transactionService ??= TransactionLocalStorageService();
    return _transactionService!;
  }

  // Initialize all storage services (optional)
  static Future<void> initialize() async {
    // Pre-warm the services by accessing them
    orders;
    deliveryAddresses;
    userAddresses;
    transactions;
  }

  // Close all storage services (call when app is closing)
  static Future<void> close() async {
    await Hive.close();
    _orderService = null;
    _addressService = null;
    _userAddressService = null;
    _transactionService = null;
  }

  // Clear all data from all services (use with caution)
  static Future<void> clearAllData() async {
    await orders.clearAll();
    await deliveryAddresses.clearAll();
    await userAddresses.clearAll();
    await transactions.clearAll();
  }
}