import 'package:abdoul_express/core/app_state.dart';
import 'package:abdoul_express/core/constants/app_constantes.dart';
import 'package:abdoul_express/core/theme.dart';
import 'package:abdoul_express/core/l10n/language_cubit.dart';
import 'package:abdoul_express/core/l10n/fallback_material_localizations.dart';
import 'package:abdoul_express/features/auth/presentation/cubit/auth_state.dart';
import 'package:abdoul_express/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:abdoul_express/features/auth/presentation/pages/login_page.dart';
import 'package:abdoul_express/core/services/onboarding_service.dart';
import 'package:abdoul_express/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/products/presentation/bloc/products_cubit.dart';
import 'features/products/data/product_repository.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/cart/data/data_sources/cart_remote_data_source.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';
import 'package:abdoul_express/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:abdoul_express/features/chat/domain/entities/message.dart';
import 'package:abdoul_express/features/chat/data/datasource/message_local_datasource.dart';
import 'package:abdoul_express/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:abdoul_express/features/search/presentation/cubit/search_cubit.dart';
import 'package:abdoul_express/features/orders/presentation/cubit/orders_cubit.dart';
import 'model/order.dart';
import 'model/delivery_address.dart';
import 'model/delivery_method.dart';
import 'models/transaction.dart';
import 'model/address.dart';

import 'package:abdoul_express/root_shell.dart';

/// Main entry point for the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await _initHive();

  runApp(const MyApp());
}

Future<void> _initHive() async {
  try {
    // Initialize Hive Flutter
    await Hive.initFlutter();

    // Get application documents directory for custom storage path
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Register Hive adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OrderStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(OrderItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(OrderAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(DeliveryAddressAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(DeliveryTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(DeliveryMethodAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(PaymentMethodAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(CashRegisterAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(AddressAdapter());
    }
    // Register chat message adapters
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(MessageAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(MessageStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(MessageTypeAdapter());
    }

    // Open Hive boxes
    await Hive.openBox<Order>('orders');
    await Hive.openBox<OrderItem>('order_items');
    await Hive.openBox<DeliveryAddress>('delivery_addresses');
    await Hive.openBox<DeliveryMethod>('delivery_methods');
    await Hive.openBox<Transaction>('transactions');
    await Hive.openBox<CashRegister>('cash_registers');
    await Hive.openBox<Address>('addresses');
    await Hive.openBox<Message>('messages');

    print('Hive initialized successfully');
  } catch (e) {
    print('Error initializing Hive: $e');
    // Continue without Hive if initialization fails
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = AppController();
    final authRepository = AuthRepository();
    final productRepository = ProductRepository();
    final cartDataSource = CartRemoteDataSource();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(
          create: (_) => AuthCubit(authRepository)..checkAuthStatus(),
        ),
        BlocProvider(
          create: (_) => ProductsCubit(productRepository: productRepository)
            ..loadProducts(),
        ),
        BlocProvider(
          create: (_) => CartCubit(cartDataSource: cartDataSource),
        ),
        BlocProvider(create: (_) => PaymentCubit()),
        BlocProvider(
          create: (_) => ChatCubit(messageRepository: MessageLocalDataSource()),
        ),
        BlocProvider(create: (_) => FavoritesCubit()),
        BlocProvider(create: (_) => SearchCubit(productRepository: productRepository)),
        BlocProvider(create: (_) => OrdersCubit()),
      ],
      child: AppState(
        controller: appController,
        child: BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, languageState) {
            return MaterialApp(
              title: AppConstantes.appName,
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.system,

              // Localization configuration
              locale: languageState.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                FallbackMaterialLocalizationsDelegate(),
                FallbackCupertinoLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'), // English
                Locale('fr', 'NE'), // French (Niger)
                Locale('ha'), // Hausa
              ],
              // Locale resolution callback to handle unsupported Material/Cupertino locales
              localeResolutionCallback: (locale, supportedLocales) {
                // If Hausa is selected, use French for Material/Cupertino widgets
                // but our app will still show Hausa strings
                if (locale?.languageCode == 'ha') {
                  return locale; // Return Hausa for our app
                }
                // For other locales, use default resolution
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode) {
                    return supportedLocale;
                  }
                }
                // Fallback to French
                return const Locale('fr', 'NE');
              },

              home: FutureBuilder<bool>(
                future: OnboardingService().isFirstLaunch(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final isFirstLaunch = snapshot.data!;

                  return BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        return const RootShell();
                      } else if (state is AuthUnauthenticated) {
                        // Check if first time launch to show Onboarding
                        // Otherwise, show Login page directly
                        return isFirstLaunch
                            ? const OnboardingPage()
                            : const LoginPage();
                      }
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
