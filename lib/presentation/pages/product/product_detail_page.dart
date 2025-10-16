import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/../../config/config.dart';
import '/../../domain/domain.dart';
import '../../presentation_container.dart';
import '../../shared/widgets/custom_product_field.dart';

class ProductDetailPage extends ConsumerWidget {

  final String productId;
  static const name = 'productDetailPage';

  const ProductDetailPage({super.key, required this.productId});


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authState = ref.watch( authProvider );
    final productState = ref.watch( productProvider(productId) );
    final color = AppTheme().getTheme().colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text( productState.product?.name ?? 'Cargando...'),
          backgroundColor: color.primary,
        ),
        body: productState.isLoading 
          ? const FullScreenLoader()
          : _ProductDetailBodyPage( product: productState.product! ),
      
        floatingActionButton:  ( authState.authStatus != AuthStatus.authenticated)
          ? null 
          : (authState.userData!.isAdmin) 
            ? 
              FloatingActionButton.extended(
                label: const Text('Guardar Producto'),
                icon: const Icon( Icons.save_as_outlined ),
                onPressed: () {
                  // context.push('/product/new');
                },
              )
            : null,
      ),
    );
  }
}

class _ProductDetailBodyPage extends ConsumerWidget {

  final Product product;
  
  const _ProductDetailBodyPage({ required this.product });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // final productState = ref.watch( productProvider(productId) );
    final textStyles = Theme.of(context).textTheme;

    return ListView(
      children: [

        SizedBox(
          height: 250,
          width: 600,
          child: CustomImagesGallery(images: product.images ),
        ),

        const SizedBox( height: 10 ),
        
        Center(child: Text( product.name, style: textStyles.titleSmall )),
        
        const SizedBox( height: 10 ),
        
        _ProductInformation( product: product ),

      ],
    );
  }
}

class _ProductInformation extends ConsumerWidget {

  final Product product;
  
  const _ProductInformation({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref ) {

    

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generales'),
          const SizedBox(height: 15 ),
          CustomProductField(
            readOnly: true,
            isTopField: true,
            label: 'Nombre',
            initialValue: product.name,
          ),

          CustomProductField( 
            readOnly: true,
            isBottomField: true,
            label: 'Precio',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: product.price.toString(),
          ),

          const SizedBox(height: 15 ),
          CustomProductField( 
            readOnly: true,
            isTopField: true,
            label: 'Existencias',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: product.stock.toString(),
          ),

          CustomProductField( 
            readOnly: true,
            maxLines: 6,
            label: 'Descripción',
            keyboardType: TextInputType.multiline,
            initialValue: product.description,
          ),


          const SizedBox(height: 100 ),
        ],
      ),
    );
  }
}

// class _ImageGallery extends StatelessWidget {

//   final List<String> images;
  
//   const _ImageGallery({required this.images});

//   @override
//   Widget build(BuildContext context) {

//     return PageView(
//       scrollDirection: Axis.horizontal,
//       controller: PageController(
//         viewportFraction: 0.7
//       ),
//       children: images.isEmpty
//         ? [ ClipRRect(
//             borderRadius: const BorderRadius.all(Radius.circular(20)),
//             child: Image.asset('assets/images/no-image.jpg', fit: BoxFit.cover )) 
//         ]
//         : images.map((e){
//           return ClipRRect(
//             borderRadius: const BorderRadius.all(Radius.circular(20)),
//             child: Image.network(e, fit: BoxFit.cover,),
//           );
//       }).toList(),
//     );
//   }
// }