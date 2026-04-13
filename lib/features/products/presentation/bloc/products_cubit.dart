import 'package:bloc/bloc.dart';
import 'package:abdoul_express/model/product.dart';
import '../../data/product_repository.dart';
import 'package:equatable/equatable.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit({required this.productRepository})
      : super(const ProductsState.initial());

  final ProductRepository productRepository;

  Future<void> loadProducts({String? categoryId}) async {
    try {
      emit(const ProductsState.loading());
      final items = await productRepository.fetchProducts(categoryId: categoryId);
      emit(ProductsState.loaded(items));
    } catch (e) {
      emit(ProductsState.error(e.toString()));
    }
  }

  Future<void> loadFeaturedProducts() async {
    try {
      emit(const ProductsState.loading());
      final items = await productRepository.getFeaturedProducts();
      emit(ProductsState.loaded(items));
    } catch (e) {
      emit(ProductsState.error(e.toString()));
    }
  }

  Future<void> loadTrendingProducts() async {
    try {
      emit(const ProductsState.loading());
      final items = await productRepository.getTrendingProducts();
      emit(ProductsState.loaded(items));
    } catch (e) {
      emit(ProductsState.error(e.toString()));
    }
  }

  Future<void> searchProducts(String query) async {
    try {
      emit(const ProductsState.loading());
      final items = await productRepository.searchProducts(query: query);
      emit(ProductsState.loaded(items));
    } catch (e) {
      emit(ProductsState.error(e.toString()));
    }
  }

  Future<void> loadProductsByCategory(String categoryId) async {
    try {
      emit(const ProductsState.loading());
      final items = await productRepository.getProductsByCategory(categoryId: categoryId);
      emit(ProductsState.loaded(items));
    } catch (e) {
      emit(ProductsState.error(e.toString()));
    }
  }
}
