import '../../domain/domain.dart';
// import '../../config/config.dart';

class RealizedWorksMapper{

  static jsonToEntity( Map<String, dynamic> json) => Works(
    id: json['id'].toString(), 
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    image: json['image'] ?? '',
    // .startsWith('http')
    //   ? json['image']
    //   : '${Enviroment.baseUrl}/realized-works-rest/${json['image']}',
    //  != null 
    //   ? List<String>.from(json['images'].map(
    //     (image) => image.startsWith('http')
    //       ? image 
    //       : '${Enviroment.baseUrl}/realized-works-rest/$image'
    //     ))
    //   : [], 
  );

}