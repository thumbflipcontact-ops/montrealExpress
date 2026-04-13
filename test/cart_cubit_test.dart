import 'package:flutter_test/flutter_test.dart';
import 'package:abdoul_express/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:abdoul_express/core/app_state.dart';
import 'package:abdoul_express/core/data.dart';

void main() {
  test('CartCubit adds and removes items', () async {
    final controller = AppController();
    final cubit = CartCubit(controller: controller);

    expect(cubit.state.items.length, 0);

    final p = mockProducts[0];
    cubit.addToCart(CartItem(product: p, quantity: 2));
    expect(cubit.state.items.length, 1);
    expect(controller.cartCount, 2);

    cubit.setQuantity(p.id, 1);
    expect(controller.cartCount, 1);

    cubit.removeFromCart(p.id);
    expect(cubit.state.items.length, 0);
  });
}
