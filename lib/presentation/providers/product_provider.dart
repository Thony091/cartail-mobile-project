import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portafolio_project/domain/domain.dart';

import '../presentation_container.dart';

final productProvider = StateNotifierProvider.autoDispose.family<ProductNotifier, ProductState, String>(
  (ref, prductId) {

    final productsRepository = ref.watch( productsRepositoryProvider );

    return ProductNotifier(
      productsRepository: productsRepository, 
      productId: prductId
    );
  }
);



class ProductNotifier extends StateNotifier<ProductState> {
  
  final ProductsRepository productsRepository;

  ProductNotifier({
    required this.productsRepository,
    required String productId,
  }) : super(ProductState( id: productId )){
    loadProduct();
  }

  Future<void> loadProduct() async {
   
    try {

      final product = await productsRepository.getProductById(state.id);

      state = state.copyWith(
        isLoading: false,
        product: product,
      );
      
    } catch (e) {
      print('Error en LoadProduct desde Provider: $e');
    }
    state = state.copyWith(isLoading: true);
    final product = await productsRepository.getProductById(state.id);
    state = state.copyWith(product: product, isLoading: false);
  }

}



class ProductState{

  final String id;
  final Product? product;
  final bool isLoading;
  final bool isSaving;
  
  ProductState({
    required this.id,
    this.product,
    this.isLoading = true,
    this.isSaving = false,
  });
  ProductState copyWith({
    String? id,
    Product? product,
    bool? isLoading,
    bool? isSaving,
  }) {
    return ProductState(
      id: id ?? this.id,
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
