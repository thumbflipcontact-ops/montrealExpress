import 'dart:async';

import 'package:abdoul_express/core/app_state.dart';
import 'package:abdoul_express/core/data.dart';
import 'package:abdoul_express/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:abdoul_express/features/home/presentation/pages/home_page.dart';
import 'package:abdoul_express/features/products/data/product_repository.dart';
import 'package:abdoul_express/features/products/presentation/bloc/products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abdoul_express/core/widgets.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets('HomePage search filters products', (WidgetTester tester) async {
    // Arrange
    final appController = AppController();
    final cartCubit = CartCubit(controller: appController);
    final repo = MockProductRepository(mockProducts);
    final productsCubit = ProductsCubit(repo: repo)..loadProducts();

    // Set screen size to a large phone/tablet size to avoid overflows
    tester.view.physicalSize = const Size(
      2400,
      3000,
    ); // 2400 / 3 = 800 logical width
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppState(
            controller: appController,
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: productsCubit),
                BlocProvider.value(value: cartCubit),
              ],
              child: const Scaffold(body: HomePage()),
            ),
          ),
        ),
      );

      // Act: Wait for products to load
      await tester.pumpAndSettle();

      // Assert: All products should be visible initially
      final productCards = find.byType(ProductCard);
      debugPrint('Found ${productCards.evaluate().length} product cards');

      expect(find.text('Coffret Cosmétiques'), findsOneWidget);

      // Act: Enter search query "sac"
      await tester.enterText(find.byType(TextField), 'sac');
      await tester.pumpAndSettle();

      // Assert: Only matching products should be visible
      expect(find.text('Sac à dos enfant'), findsOneWidget);
      expect(find.text('Sac à main minimal'), findsOneWidget);
      expect(find.text('Coffret Cosmétiques'), findsNothing);

      // Act: Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Assert: All products visible again
      expect(find.text('Coffret Cosmétiques'), findsOneWidget);
    }, createHttpClient: (_) => _MockHttpClient());
  });
}

class _MockHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Mock implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
}

class _MockHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get statusCode => 404;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return const Stream<List<int>>.empty().listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
