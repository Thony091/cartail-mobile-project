import '../../domain/entities/payment_method.dart';

class PaymentMethodModel {
  final int id;
  final String name;

  PaymentMethodModel({
    required this.id,
    required this.name,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  PaymentMethod toEntity() {
    return PaymentMethod(
      id: id,
      name: name,
    );
  }

  factory PaymentMethodModel.fromEntity(PaymentMethod method) {
    return PaymentMethodModel(
      id: method.id,
      name: method.name,
    );
  }
}
