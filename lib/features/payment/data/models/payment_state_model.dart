import '../../domain/entities/payment_state.dart';

class PaymentStateModel {
  final int id;
  final String name;

  PaymentStateModel({
    required this.id,
    required this.name,
  });

  factory PaymentStateModel.fromJson(Map<String, dynamic> json) {
    return PaymentStateModel(
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

  PaymentState toEntity() {
    return PaymentState(
      id: id,
      name: name,
    );
  }

  factory PaymentStateModel.fromEntity(PaymentState state) {
    return PaymentStateModel(
      id: state.id,
      name: state.name,
    );
  }
}
