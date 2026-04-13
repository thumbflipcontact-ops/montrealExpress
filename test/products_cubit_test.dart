import 'package:flutter_test/flutter_test.dart';
import 'package:abdoul_express/features/products/presentation/bloc/products_cubit.dart';
import 'package:abdoul_express/features/products/data/product_repository.dart';
import 'package:abdoul_express/core/data.dart';

void main() {
  test('ProductsCubit loads mocked products', () async {
    final repo = MockProductRepository(mockProducts);
    final cubit = ProductsCubit(repo: repo);

    expect(cubit.state.isInitial, true);

    await cubit.loadProducts();

    expect(cubit.state.isLoaded, true);
    expect(cubit.state.products.length, mockProducts.length);
  });
}
