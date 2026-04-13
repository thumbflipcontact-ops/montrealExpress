part of 'products_cubit.dart';

class ProductsState extends Equatable {
  const ProductsState._({required this.products, required this.status, this.error});

  const ProductsState.initial() : this._(products: const [], status: _ProductsStatus.initial);
  const ProductsState.loading() : this._(products: const [], status: _ProductsStatus.loading);
  const ProductsState.loaded(List<Product> products) : this._(products: products, status: _ProductsStatus.loaded);
  const ProductsState.error(String? error) : this._(products: const [], status: _ProductsStatus.error, error: error);

  final List<Product> products;
  // ignore: library_private_types_in_public_api
  final _ProductsStatus status;
  final String? error;

  bool get isInitial => status == _ProductsStatus.initial;
  bool get isLoading => status == _ProductsStatus.loading;
  bool get isLoaded => status == _ProductsStatus.loaded;
  bool get hasError => status == _ProductsStatus.error;

  @override
  List<Object?> get props => [products, status, error];
}

enum _ProductsStatus { initial, loading, loaded, error }
