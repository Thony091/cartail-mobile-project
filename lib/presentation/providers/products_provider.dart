import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../presentation_container.dart';

//* state notifier provider
final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  
  final productsRepository = ref.watch( productsRepositoryProvider );
  
  return  ProductsNotifier(productsRepository: productsRepository);
});


//* State Notifier Provider
class ProductsNotifier extends StateNotifier<ProductsState>{
  
  final ProductsRepository productsRepository;
  
  ProductsNotifier({
    required this.productsRepository
  }) : super( ProductsState() ){
    loadNextPage();
  }
  
  Future loadNextPage() async {

    if ( state.isLoading || state.isLastPage) return;

    state = state.copyWith( isLoading: true );

    final products = await productsRepository.getProductsByPage(
      limit: state.limit,
      offset: state.offset
    );

    if ( products.isEmpty ) {
      state = state.copyWith(
        isLastPage: true,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      products: [ ...state.products, ...products ],
      offset: state.offset + state.limit,
      isLoading: false,
      isLastPage: false,
    );
  }



}


//* ProductsState
class ProductsState{

  final List<Product> products;
  final bool isLoading;
  final bool isLastPage;
  final int limit;
  final int offset;

  ProductsState({
    this.products = const[],
    this.isLoading = false,
    this.isLastPage = false,
    this.limit = 10,
    this.offset = 0,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLastPage,
    int? limit,
    int? offset,
  }) => ProductsState(
    products: products ?? this.products,
    isLoading: isLoading ?? this.isLoading,
    isLastPage: isLastPage ?? this.isLastPage,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
  );

  
}